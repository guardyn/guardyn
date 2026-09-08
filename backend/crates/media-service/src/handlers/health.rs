//! Health check handler
//!
//! `media-service` was the only backend service without a `Health` RPC, so an
//! operator had no way to tell a running-but-broken instance from a healthy one
//! short of uploading a file.

use std::collections::HashMap;
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};

use tonic::{Request, Response, Status};

use crate::proto::common::health_status::Status as HealthStatusEnum;
use crate::proto::common::{HealthStatus, Timestamp};
use crate::proto::media::HealthRequest;
use crate::{db, storage};

/// Report the service's own health plus that of each store it depends on.
///
/// Always returns `Ok`: a `Health` RPC that fails transport-level tells a probe
/// nothing it can act on. An unreachable store is reported as `UNHEALTHY` in the
/// body, with the failing component named in `components`.
pub async fn handle(
    _request: Request<HealthRequest>,
    db: Arc<db::DatabaseClient>,
    storage: Arc<storage::StorageClient>,
) -> Result<Response<HealthStatus>, Status> {
    let mut components = HashMap::new();
    let mut healthy = true;

    match db.health_check().await {
        Ok(()) => {
            components.insert("tikv".to_string(), "healthy".to_string());
        }
        Err(e) => {
            // The error is logged, not returned: it can carry endpoint detail,
            // and a health probe is an unauthenticated surface.
            tracing::warn!(error = %e, "TiKV health check failed");
            components.insert("tikv".to_string(), "unhealthy".to_string());
            healthy = false;
        }
    }

    match storage.health_check().await {
        Ok(()) => {
            components.insert("minio".to_string(), "healthy".to_string());
        }
        Err(e) => {
            tracing::warn!(error = %e, "Object store health check failed");
            components.insert("minio".to_string(), "unhealthy".to_string());
            healthy = false;
        }
    }

    // SystemTime rather than chrono: media-service does not depend on chrono, and a
    // timestamp is not worth a new dependency edge.
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    Ok(Response::new(HealthStatus {
        status: if healthy {
            HealthStatusEnum::Healthy as i32
        } else {
            HealthStatusEnum::Unhealthy as i32
        },
        version: env!("CARGO_PKG_VERSION").to_string(),
        timestamp: Some(Timestamp {
            seconds: now.as_secs() as i64,
            nanos: now.subsec_nanos() as i32,
        }),
        components,
    }))
}
