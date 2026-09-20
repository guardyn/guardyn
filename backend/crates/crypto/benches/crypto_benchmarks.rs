//! Crypto benchmarks for guardyn-crypto
//!
//! Run with: just bench, or `cargo bench -p guardyn-crypto` directly.

use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion};

fn bench_padding(c: &mut Criterion) {
    use guardyn_crypto::{pad_message, unpad_message};

    let mut group = c.benchmark_group("PADMÉ Padding");

    for size in [16, 64, 256, 1024, 4096, 16384] {
        let data: Vec<u8> = (0..size).map(|i| (i % 256) as u8).collect();

        group.bench_with_input(BenchmarkId::new("pad", size), &data, |b, data| {
            b.iter(|| pad_message(black_box(data)).unwrap());
        });

        let padded = pad_message(&data).unwrap();
        group.bench_with_input(BenchmarkId::new("unpad", size), &padded, |b, padded| {
            b.iter(|| unpad_message(black_box(padded)).unwrap());
        });
    }

    group.finish();
}

fn bench_x3dh(c: &mut Criterion) {
    use guardyn_crypto::X3DHProtocol;

    let mut group = c.benchmark_group("X3DH Key Exchange");

    group.bench_function("generate_key_bundle", |b| {
        b.iter(|| X3DHProtocol::generate_key_bundle().unwrap());
    });

    group.finish();
}

fn bench_pqxdh(c: &mut Criterion) {
    use ed25519_dalek::SigningKey;
    use guardyn_crypto::generate_hybrid_key_bundle;
    use guardyn_crypto::pqxdh::{derive_recipient_shared_secret, derive_sender_shared_secret};
    use x25519_dalek::{PublicKey as X25519PublicKey, StaticSecret as X25519Secret};

    let mut group = c.benchmark_group("PQXDH Hybrid Key Exchange");

    group.bench_function("generate_classical_bundle", |b| {
        b.iter(|| generate_hybrid_key_bundle(true, false).unwrap());
    });

    #[cfg(feature = "pq")]
    group.bench_function("generate_hybrid_bundle", |b| {
        b.iter(|| generate_hybrid_key_bundle(true, true).unwrap());
    });

    // Key generation happens once per device registration. Everything below happens once per
    // session, and is the ML-KEM cost a user can actually feel.
    //
    // The two arms are comparable because they are the same code. `derive_sender_shared_secret`
    // and `derive_recipient_shared_secret` are not feature-gated; the classical and hybrid arms
    // differ only in whether the recipient bundle carries an ML-KEM prekey. Same X25519
    // Diffie-Hellmans, same HKDF, same `info` string. Neither function verifies a signature, so
    // subtracting one arm from the other leaves the ML-KEM half and nothing else: encapsulation
    // for the sender, decapsulation for the recipient, each including the key decode that feeds
    // it. That is what makes the difference a post-quantum price rather than two unrelated
    // numbers.
    //
    // Every key is minted once, outside `b.iter`. ML-KEM-768 key generation costs far more than
    // a single encapsulation, so building bundles per iteration would spend the measurement on
    // setup - the same trap `pqxdh_decapsulate` hoists a `OnceLock` to avoid. The ephemeral
    // keypair is hoisted for a different reason: a real handshake mints a fresh one, but that
    // cost falls identically on both arms, so including it would dilute the ratio without making
    // either number more honest.
    let mut rng = rand::thread_rng();
    let sender_identity = SigningKey::generate(&mut rng);
    let sender_ephemeral = X25519Secret::random_from_rng(&mut rng);

    // The two sides want different halves of the identity key and passing the wrong one still
    // type-checks - both are `&[u8; 32]`. The sender passes the Ed25519 seed, the recipient the
    // Ed25519 public key.
    let identity_seed = sender_identity.to_bytes();
    let identity_public = sender_identity.verifying_key().to_bytes();
    let ephemeral_secret = sender_ephemeral.to_bytes();
    let ephemeral_public = *X25519PublicKey::from(&sender_ephemeral).as_bytes();

    // A classical bundle, not a hybrid bundle with the ciphertext withheld. Since PR-120 the
    // responder gate is an exhaustive four-arm match running before any Diffie-Hellman, and a
    // decapsulation key with no ciphertext is `Err(Protocol)`. `generate_hybrid_key_bundle(true,
    // false)` leaves `pq_decapsulation_key` `None`, giving the `(None, None)` arm - the only
    // shape a classical agreement can legally take.
    let (classical_bundle, classical_private) = generate_hybrid_key_bundle(true, false).unwrap();

    group.bench_function("sender_agreement_classical", |b| {
        b.iter(|| {
            derive_sender_shared_secret(
                black_box(&identity_seed),
                black_box(&ephemeral_secret),
                black_box(&classical_bundle),
            )
            .unwrap()
        });
    });

    group.bench_function("recipient_agreement_classical", |b| {
        b.iter(|| {
            derive_recipient_shared_secret(
                black_box(&classical_private),
                black_box(&identity_public),
                black_box(&ephemeral_public),
                None,
            )
            .unwrap()
        });
    });

    #[cfg(feature = "pq")]
    {
        let (hybrid_bundle, hybrid_private) = generate_hybrid_key_bundle(true, true).unwrap();

        group.bench_function("sender_agreement_hybrid", |b| {
            b.iter(|| {
                derive_sender_shared_secret(
                    black_box(&identity_seed),
                    black_box(&ephemeral_secret),
                    black_box(&hybrid_bundle),
                )
                .unwrap()
            });
        });

        // One initiator run supplies the ciphertext the responder bench replays. The initiator's
        // wire output is the 32-byte ephemeral public key followed by the 1088-byte ML-KEM
        // ciphertext, split here exactly as the responder splits it.
        let (_, additional_data) =
            derive_sender_shared_secret(&identity_seed, &ephemeral_secret, &hybrid_bundle).unwrap();
        let pq_ciphertext = additional_data[32..].to_vec();

        group.bench_function("recipient_agreement_hybrid", |b| {
            b.iter(|| {
                derive_recipient_shared_secret(
                    black_box(&hybrid_private),
                    black_box(&identity_public),
                    black_box(&ephemeral_public),
                    Some(black_box(pq_ciphertext.as_slice())),
                )
                .unwrap()
            });
        });
    }

    group.finish();
}

criterion_group!(benches, bench_padding, bench_x3dh, bench_pqxdh);
criterion_main!(benches);
