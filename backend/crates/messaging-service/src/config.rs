//! Messaging-service configuration.
//!
//! Deliberately thin. Endpoints, host, port, log level and OTLP all come from
//! `guardyn_common::config::ServiceConfig`; this module exists only for the JWT
//! secret, whose fallback variable name predates that loader.

/// Get the JWT secret from environment variables
///
/// Reads from GUARDYN_AUTH__JWT_SECRET first (preferred), then falls back to JWT_SECRET.
/// This ensures consistency with auth-service which signs the tokens.
///
/// # Warning
/// Using the default value is insecure and should only be used for development.
pub fn get_jwt_secret() -> String {
    std::env::var("GUARDYN_AUTH__JWT_SECRET")
        .or_else(|_| std::env::var("JWT_SECRET"))
        .unwrap_or_else(|_| {
            tracing::warn!("Using default JWT secret - DO NOT USE IN PRODUCTION");
            "development-secret-change-in-production".to_string()
        })
}
