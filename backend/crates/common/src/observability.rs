//! Observability module for Guardyn services
//!
//! Provides unified tracing, logging, and metrics initialization.
//! Supports:
//! - JSON structured logging
//! - OpenTelemetry distributed tracing
//! - OTLP export to Tempo
//!
//! # Usage
//!
//! ```rust,ignore
//! use guardyn_common::observability;
//!
//! #[tokio::main]
//! async fn main() {
//!     let _guard = observability::init_tracing(
//!         "my-service",
//!         "info",
//!         Some("http://otel-collector:4317"),
//!     );
//!     // ... your application code
//! }
//! ```

use opentelemetry::trace::TracerProvider as _;
use opentelemetry_otlp::WithExportConfig;
use opentelemetry_sdk::{
    runtime,
    trace::{RandomIdGenerator, Sampler, TracerProvider},
    Resource,
};
use opentelemetry::KeyValue;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

/// Guard that ensures proper shutdown of the tracing pipeline
pub struct TracingGuard {
    provider: Option<TracerProvider>,
}

impl Drop for TracingGuard {
    fn drop(&mut self) {
        if let Some(provider) = self.provider.take() {
            // Flush all pending spans before shutdown
            if let Err(e) = provider.shutdown() {
                eprintln!("Error shutting down tracer provider: {:?}", e);
            }
        }
    }
}

/// Initialize tracing with OpenTelemetry support
///
/// # Arguments
/// * `service_name` - Name of the service for trace attribution
/// * `log_level` - Logging level (debug, info, warn, error)
/// * `otlp_endpoint` - Optional OTLP endpoint for trace export (e.g., "http://tempo:4317")
///
/// # Returns
/// A `TracingGuard` that ensures proper shutdown when dropped
pub fn init_tracing(
    service_name: &str,
    log_level: &str,
    otlp_endpoint: Option<&str>,
) -> TracingGuard {
    // Build the subscriber layers
    let env_filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| log_level.into());

    // JSON formatting layer for structured logs
    let fmt_layer = tracing_subscriber::fmt::layer()
        .json()
        .with_file(true)
        .with_line_number(true)
        .with_thread_ids(true)
        .with_target(true);

    // Try to initialize OpenTelemetry if endpoint is provided
    let provider = if let Some(endpoint) = otlp_endpoint {
        match init_opentelemetry_tracer(service_name, endpoint) {
            Ok((tracer, provider)) => {
                // Initialize with OpenTelemetry
                let otel_layer = tracing_opentelemetry::layer().with_tracer(tracer);
                tracing_subscriber::registry()
                    .with(env_filter)
                    .with(fmt_layer)
                    .with(otel_layer)
                    .init();
                Some(provider)
            }
            Err(e) => {
                eprintln!("Failed to initialize OpenTelemetry: {:?}", e);
                // Fallback to standard logging
                tracing_subscriber::registry()
                    .with(env_filter)
                    .with(fmt_layer)
                    .init();
                None
            }
        }
    } else {
        // Initialize without OpenTelemetry
        tracing_subscriber::registry()
            .with(env_filter)
            .with(fmt_layer)
            .init();
        None
    };

    tracing::info!(
        service = service_name,
        otlp_endpoint = ?otlp_endpoint,
        "Tracing initialized"
    );

    TracingGuard { provider }
}

/// Initialize OpenTelemetry tracer with OTLP exporter
fn init_opentelemetry_tracer(
    service_name: &str,
    endpoint: &str,
) -> anyhow::Result<(opentelemetry_sdk::trace::Tracer, TracerProvider)> {
    // Configure OTLP exporter
    let exporter = opentelemetry_otlp::SpanExporter::builder()
        .with_tonic()
        .with_endpoint(endpoint)
        .build()?;

    // Build tracer provider with resource attributes
    let provider = TracerProvider::builder()
        .with_batch_exporter(exporter, runtime::Tokio)
        .with_sampler(Sampler::AlwaysOn)
        .with_id_generator(RandomIdGenerator::default())
        .with_resource(Resource::new(vec![
            KeyValue::new(
                opentelemetry_semantic_conventions::resource::SERVICE_NAME,
                service_name.to_string(),
            ),
            KeyValue::new(
                opentelemetry_semantic_conventions::resource::SERVICE_VERSION,
                env!("CARGO_PKG_VERSION").to_string(),
            ),
            KeyValue::new(
                "deployment.environment",
                std::env::var("DEPLOYMENT_ENV").unwrap_or_else(|_| "development".to_string()),
            ),
        ]))
        .build();

    // Create tracer from provider
    let tracer = provider.tracer(service_name.to_string());

    Ok((tracer, provider))
}

/// Legacy initialization function for backward compatibility
///
/// Use `init_tracing` with otlp_endpoint parameter for new services that need distributed tracing.
#[deprecated(since = "0.2.0", note = "Use init_tracing with otlp_endpoint parameter instead")]
pub fn init_tracing_legacy(service_name: &str, log_level: &str) {
    let _ = init_tracing(service_name, log_level, None);
}
