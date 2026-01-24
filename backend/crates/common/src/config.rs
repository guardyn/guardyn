use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct ServiceConfig {
    pub service_name: String,
    pub host: String,
    pub port: u16,
    pub database: DatabaseConfig,
    pub messaging: MessagingConfig,
    pub observability: ObservabilityConfig,
    #[serde(default)]
    pub auth: AuthConfig,
}

#[derive(Debug, Deserialize)]
pub struct DatabaseConfig {
    pub tikv_pd_endpoints: Vec<String>,
    pub scylladb_nodes: Vec<String>,
}

#[derive(Debug, Deserialize)]
pub struct MessagingConfig {
    pub nats_url: String,
}

#[derive(Debug, Deserialize)]
pub struct ObservabilityConfig {
    pub otlp_endpoint: String,
    pub log_level: String,
}

/// Authentication configuration
#[derive(Debug, Deserialize)]
pub struct AuthConfig {
    /// JWT signing secret (must be at least 32 bytes in production)
    ///
    /// CRITICAL: Never use default in production!
    /// Set via GUARDYN_AUTH__JWT_SECRET environment variable
    #[serde(default = "default_jwt_secret")]
    pub jwt_secret: String,

    /// JWT token expiration in seconds (default: 1 hour)
    #[serde(default = "default_jwt_expiration")]
    pub jwt_expiration_secs: u64,

    /// Refresh token expiration in seconds (default: 30 days)
    #[serde(default = "default_refresh_expiration")]
    pub refresh_expiration_secs: u64,
}

fn default_jwt_secret() -> String {
    // WARNING: This is only for development!
    // In production, GUARDYN_AUTH__JWT_SECRET must be set
    tracing::warn!("Using default JWT secret - NOT SAFE FOR PRODUCTION!");
    "UNSAFE_DEV_SECRET_CHANGE_IN_PRODUCTION_32BYTES".to_string()
}

fn default_jwt_expiration() -> u64 {
    3600 // 1 hour
}

fn default_refresh_expiration() -> u64 {
    30 * 24 * 3600 // 30 days
}

impl Default for AuthConfig {
    fn default() -> Self {
        Self {
            jwt_secret: default_jwt_secret(),
            jwt_expiration_secs: default_jwt_expiration(),
            refresh_expiration_secs: default_refresh_expiration(),
        }
    }
}

impl ServiceConfig {
    pub fn load() -> Result<Self, config::ConfigError> {
        let _cfg = config::Config::builder()
            .add_source(config::Environment::with_prefix("GUARDYN").separator("__"))
            .build()?;
        
        // Parse comma-separated strings into arrays
        let mut builder = config::Config::builder();
        
        // TiKV endpoints
        if let Ok(tikv_str) = std::env::var("GUARDYN_DATABASE__TIKV_PD_ENDPOINTS") {
            let endpoints: Vec<String> = tikv_str.split(',').map(|s| s.trim().to_string()).collect();
            builder = builder.set_override("database.tikv_pd_endpoints", endpoints)?;
        }
        
        // ScyllaDB nodes
        if let Ok(scylla_str) = std::env::var("GUARDYN_DATABASE__SCYLLADB_NODES") {
            let nodes: Vec<String> = scylla_str.split(',').map(|s| s.trim().to_string()).collect();
            builder = builder.set_override("database.scylladb_nodes", nodes)?;
        }
        
        // Other config from env
        if let Ok(service_name) = std::env::var("GUARDYN_SERVICE_NAME") {
            builder = builder.set_override("service_name", service_name)?;
        }
        if let Ok(host) = std::env::var("GUARDYN_HOST") {
            builder = builder.set_override("host", host)?;
        }
        if let Ok(port) = std::env::var("GUARDYN_PORT") {
            builder = builder.set_override("port", port)?;
        }
        if let Ok(nats_url) = std::env::var("GUARDYN_MESSAGING__NATS_URL") {
            builder = builder.set_override("messaging.nats_url", nats_url)?;
        }
        if let Ok(otlp_endpoint) = std::env::var("GUARDYN_OBSERVABILITY__OTLP_ENDPOINT") {
            builder = builder.set_override("observability.otlp_endpoint", otlp_endpoint)?;
        }
        if let Ok(log_level) = std::env::var("GUARDYN_OBSERVABILITY__LOG_LEVEL") {
            builder = builder.set_override("observability.log_level", log_level)?;
        }

        // Auth configuration
        if let Ok(jwt_secret) = std::env::var("GUARDYN_AUTH__JWT_SECRET") {
            builder = builder.set_override("auth.jwt_secret", jwt_secret)?;
        }
        if let Ok(jwt_exp) = std::env::var("GUARDYN_AUTH__JWT_EXPIRATION_SECS") {
            builder = builder.set_override("auth.jwt_expiration_secs", jwt_exp)?;
        }
        if let Ok(refresh_exp) = std::env::var("GUARDYN_AUTH__REFRESH_EXPIRATION_SECS") {
            builder = builder.set_override("auth.refresh_expiration_secs", refresh_exp)?;
        }
        
        builder.build()?.try_deserialize()
    }
}
