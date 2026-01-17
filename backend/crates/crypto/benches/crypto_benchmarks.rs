//! Crypto benchmarks for guardyn-crypto
//!
//! Run with: cargo bench -p guardyn-crypto

use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};

fn bench_padding(c: &mut Criterion) {
    use guardyn_crypto::{pad_message, unpad_message};

    let mut group = c.benchmark_group("PADMÉ Padding");

    for size in [16, 64, 256, 1024, 4096, 16384] {
        let data: Vec<u8> = (0..size).map(|i| (i % 256) as u8).collect();

        group.bench_with_input(
            BenchmarkId::new("pad", size),
            &data,
            |b, data| {
                b.iter(|| pad_message(black_box(data)).unwrap());
            },
        );

        let padded = pad_message(&data).unwrap();
        group.bench_with_input(
            BenchmarkId::new("unpad", size),
            &padded,
            |b, padded| {
                b.iter(|| unpad_message(black_box(padded)).unwrap());
            },
        );
    }

    group.finish();
}

fn bench_x3dh(c: &mut Criterion) {
    use guardyn_crypto::X3DHProtocol;

    let mut group = c.benchmark_group("X3DH Key Exchange");

    group.bench_function("generate_key_bundle", |b| {
        b.iter(|| {
            let mut protocol = X3DHProtocol::new();
            protocol.generate_key_bundle().unwrap()
        });
    });

    group.finish();
}

fn bench_pqxdh(c: &mut Criterion) {
    use guardyn_crypto::generate_hybrid_key_bundle;

    let mut group = c.benchmark_group("PQXDH Hybrid Key Exchange");

    group.bench_function("generate_classical_bundle", |b| {
        b.iter(|| {
            generate_hybrid_key_bundle(true, false).unwrap()
        });
    });

    #[cfg(feature = "pq")]
    group.bench_function("generate_hybrid_bundle", |b| {
        b.iter(|| {
            generate_hybrid_key_bundle(true, true).unwrap()
        });
    });

    group.finish();
}

criterion_group!(benches, bench_padding, bench_x3dh, bench_pqxdh);
criterion_main!(benches);
