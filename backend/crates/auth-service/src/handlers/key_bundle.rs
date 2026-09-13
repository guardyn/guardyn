/// Key bundle handlers - for E2EE key exchange
use crate::{proto::auth::*, proto::common::*, AuthServiceImpl};
use tonic::{Request, Response, Status};

/// Convert a stored bundle into the wire form.
///
/// Pure, so the one thing worth asserting about the read path - that it is faithful - can
/// be asserted without a live TiKV.
///
/// The ML-KEM fields are carried across exactly as stored, `None` included. `None` means
/// this device published no post-quantum pre-key: a classical-only peer, not a missing
/// bundle and not an error. Nothing here repairs a half-pair into a classical bundle
/// either - that would be the relay performing the very SRS 4a downgrade an attacker wants,
/// and `KeyBundle::validate_for_store` is what makes the half-pair unreachable instead.
fn to_proto(kb: crate::db::KeyBundle) -> KeyBundle {
    KeyBundle {
        identity_key: kb.identity_key,
        signed_pre_key: kb.signed_pre_key,
        signed_pre_key_signature: kb.signed_pre_key_signature,
        one_time_pre_keys: kb.one_time_pre_keys,
        created_at: Some(Timestamp {
            seconds: kb.created_at,
            nanos: 0,
        }),
        ml_kem_public: kb.ml_kem_public,
        ml_kem_public_signature: kb.ml_kem_public_signature,
    }
}

/// Get key bundle for a user
pub async fn get(
    service: &AuthServiceImpl,
    request: Request<GetKeyBundleRequest>,
) -> Result<Response<GetKeyBundleResponse>, Status> {
    let req = request.into_inner();

    // An empty device_id means "any device", which auth.proto has documented since this RPC
    // existed. The resolved id comes back with the bundle rather than being echoed from the
    // request: with an empty request the caller does not know which device answered, and it
    // needs to, because a ratchet is per-device.
    match service
        .db
        .get_key_bundle_for_any_device(&req.user_id, &req.device_id)
        .await
    {
        Ok(Some((device_id, kb))) => {
            let key_bundle = to_proto(kb);

            let success = GetKeyBundleSuccess {
                user_id: req.user_id.clone(),
                device_id,
                key_bundle: Some(key_bundle),
            };
            Ok(Response::new(GetKeyBundleResponse {
                result: Some(get_key_bundle_response::Result::Success(success)),
            }))
        }
        Ok(None) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::NotFound as i32,
                message: "Key bundle not found".to_string(),
                details: std::collections::HashMap::new(),
            };
            Ok(Response::new(GetKeyBundleResponse {
                result: Some(get_key_bundle_response::Result::Error(error)),
            }))
        }
        Err(e) => {
            tracing::error!("Database error: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Internal server error".to_string(),
                details: std::collections::HashMap::new(),
            };
            Ok(Response::new(GetKeyBundleResponse {
                result: Some(get_key_bundle_response::Result::Error(error)),
            }))
        }
    }
}

/// Upload pre-keys for key rotation
pub async fn upload(
    service: &AuthServiceImpl,
    request: Request<UploadPreKeysRequest>,
) -> Result<Response<UploadPreKeysResponse>, Status> {
    let req = request.into_inner();

    // Validate access token
    let claims = match crate::jwt::validate_token(&req.access_token, &service.jwt_secret) {
        Ok(c) => c,
        Err(_) => {
            let error = ErrorResponse {
                code: error_response::ErrorCode::Unauthorized as i32,
                message: "Invalid or expired token".to_string(),
                details: std::collections::HashMap::new(),
            };
            return Ok(Response::new(UploadPreKeysResponse {
                result: Some(upload_pre_keys_response::Result::Error(error)),
            }));
        }
    };

    let keys_count = req.one_time_pre_keys.len() as u32;

    // One-time pre-keys only. This used to build a whole `db::KeyBundle` with empty identity
    // material and hand it to `store_key_bundle`, whose comment claimed it would "keep
    // existing identity key" - but that method writes every path unconditionally, so a single
    // upload blanked the caller's identity key, signed pre-key and signature. The account then
    // stayed reachable to itself and unreachable to every peer, which is the worst shape a
    // failure can take.
    match service
        .db
        .store_one_time_pre_keys(&claims.sub, &claims.device_id, &req.one_time_pre_keys)
        .await
    {
        Ok(_) => {
            let success = UploadPreKeysSuccess {
                keys_uploaded: keys_count,
                total_keys_available: keys_count, // TODO: Query actual total from DB
            };
            Ok(Response::new(UploadPreKeysResponse {
                result: Some(upload_pre_keys_response::Result::Success(success)),
            }))
        }
        Err(e) => {
            tracing::error!("Failed to store key bundle: {}", e);
            let error = ErrorResponse {
                code: error_response::ErrorCode::InternalError as i32,
                message: "Failed to upload keys".to_string(),
                details: std::collections::HashMap::new(),
            };
            Ok(Response::new(UploadPreKeysResponse {
                result: Some(upload_pre_keys_response::Result::Error(error)),
            }))
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use prost::Message;

    /// A `KeyBundle` exactly as a client built before tags 6 and 7 existed, assembled
    /// from the protobuf wire spec rather than from prost.
    ///
    /// Encoding the Rust struct and comparing against itself would prove only that prost
    /// agrees with prost. The claim PR-36 rests on is narrower and about *other* binaries:
    /// that a v1.0.1 peer's bytes still mean what they meant. So each record here is
    /// written out as `(field_number << 3) | wire_type`, then a length, then the payload.
    /// A field number that silently changed would fail here instead of in production.
    fn v1_0_1_golden() -> Vec<u8> {
        let mut b = Vec::new();
        b.extend_from_slice(&[0x0a, 32]); // 1: identity_key
        b.extend_from_slice(&[1u8; 32]);
        b.extend_from_slice(&[0x12, 32]); // 2: signed_pre_key
        b.extend_from_slice(&[2u8; 32]);
        b.extend_from_slice(&[0x1a, 64]); // 3: signed_pre_key_signature
        b.extend_from_slice(&[3u8; 64]);
        b.extend_from_slice(&[0x22, 32]); // 4: one_time_pre_keys[0]
        b.extend_from_slice(&[4u8; 32]);
        b.extend_from_slice(&[0x2a, 2, 0x08, 1]); // 5: created_at { seconds: 1 }
        b
    }

    /// The same bundle as a Rust value. `..Default::default()` leaves tags 6 and 7 `None`.
    fn classical_bundle() -> KeyBundle {
        KeyBundle {
            identity_key: vec![1u8; 32],
            signed_pre_key: vec![2u8; 32],
            signed_pre_key_signature: vec![3u8; 64],
            one_time_pre_keys: vec![vec![4u8; 32]],
            created_at: Some(Timestamp {
                seconds: 1,
                nanos: 0,
            }),
            ..Default::default()
        }
    }

    /// Forward compatibility: a bundle published by a client that predates PR-36 still
    /// decodes, with every classical field intact and no ML-KEM material invented.
    #[test]
    fn v1_0_1_bundle_decodes_with_no_ml_kem_material() {
        let decoded = KeyBundle::decode(v1_0_1_golden().as_slice()).expect("v1.0.1 bundle decodes");

        assert_eq!(decoded, classical_bundle());
        assert!(
            decoded.ml_kem_public.is_none(),
            "an absent field must stay absent, not become Some(empty)"
        );
        assert!(decoded.ml_kem_public_signature.is_none());
    }

    /// Absence costs nothing on the wire. This is what makes the change additive for a
    /// deployment where no client has been updated yet: every byte is where it was.
    #[test]
    fn absent_ml_kem_material_costs_no_bytes() {
        assert_eq!(classical_bundle().encode_to_vec(), v1_0_1_golden());
    }

    /// Backward compatibility, as a prefix property.
    ///
    /// prost emits fields in declaration order, and tags 6 and 7 are declared after 5, so a
    /// hybrid bundle is byte-for-byte the v1.0.1 encoding followed by two further records.
    /// That is precisely the condition under which a decoder that has never heard of those
    /// tags skips them as unknown fields and recovers the identical old message - and it is
    /// checkable without an old decoder, which cannot be instantiated from this tree.
    #[test]
    fn ml_kem_material_appends_to_the_v1_0_1_encoding() {
        let hybrid = KeyBundle {
            ml_kem_public: Some(vec![5u8; 1184]),
            ml_kem_public_signature: Some(vec![6u8; 64]),
            ..classical_bundle()
        };

        let encoded = hybrid.encode_to_vec();
        let golden = v1_0_1_golden();

        assert!(
            encoded.starts_with(&golden),
            "ML-KEM material must append to the v1.0.1 encoding, never reorder or displace it"
        );
        assert!(encoded.len() > golden.len());
        assert_eq!(
            KeyBundle::decode(encoded.as_slice()).expect("hybrid decodes"),
            hybrid
        );
    }

    /// A key without its signature is representable on the wire - nothing in protobuf can
    /// forbid it - so rejecting it is a client obligation, not a schema guarantee. The rule
    /// lives in `docs/spec/SRS.md` and is enforced by PR-39 (#50); `verify_hybrid_bundle`
    /// currently returns `Ok(())` for this shape. This test pins the hazard, not the fix.
    #[test]
    fn a_half_pair_survives_a_round_trip_and_must_be_rejected_downstream() {
        let half = KeyBundle {
            ml_kem_public: Some(vec![5u8; 1184]),
            ..classical_bundle()
        };

        let decoded = KeyBundle::decode(half.encode_to_vec().as_slice()).expect("decodes");
        assert!(decoded.ml_kem_public.is_some());
        assert!(decoded.ml_kem_public_signature.is_none());
    }

    /// A stored bundle with ML-KEM material reaches the wire with it intact.
    #[test]
    fn stored_ml_kem_material_reaches_the_wire() {
        let stored = crate::db::KeyBundle {
            identity_key: vec![1u8; 32],
            signed_pre_key: vec![2u8; 32],
            signed_pre_key_signature: vec![3u8; 64],
            one_time_pre_keys: vec![vec![4u8; 32]],
            created_at: 1,
            ml_kem_public: Some(vec![5u8; 1184]),
            ml_kem_public_signature: Some(vec![6u8; 64]),
        };

        let wire = to_proto(stored);

        assert_eq!(wire.ml_kem_public, Some(vec![5u8; 1184]));
        assert_eq!(wire.ml_kem_public_signature, Some(vec![6u8; 64]));
        assert_eq!(
            wire,
            KeyBundle {
                ml_kem_public: Some(vec![5u8; 1184]),
                ml_kem_public_signature: Some(vec![6u8; 64]),
                ..classical_bundle()
            }
        );
    }

    /// A classical-only device is served as a complete bundle, not as an absence.
    ///
    /// The distinction matters because every *classical* field missing from the store makes
    /// `get_key_bundle` return `None` and the RPC answer `NOT_FOUND`. ML-KEM material is the
    /// first field for which absence is a legitimate state, so the read path must not treat
    /// it the same way.
    #[test]
    fn an_absent_ml_kem_pair_still_yields_a_whole_bundle() {
        let stored = crate::db::KeyBundle {
            identity_key: vec![1u8; 32],
            signed_pre_key: vec![2u8; 32],
            signed_pre_key_signature: vec![3u8; 64],
            one_time_pre_keys: vec![vec![4u8; 32]],
            created_at: 1,
            ml_kem_public: None,
            ml_kem_public_signature: None,
        };

        let wire = to_proto(stored);

        assert_eq!(wire, classical_bundle());
        assert!(wire.ml_kem_public.is_none());
        assert!(wire.ml_kem_public_signature.is_none());
        assert_eq!(
            wire.encode_to_vec(),
            v1_0_1_golden(),
            "a classical-only device must still look exactly like a v1.0.1 bundle on the wire"
        );
    }
}
