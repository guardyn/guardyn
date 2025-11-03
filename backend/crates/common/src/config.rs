use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct ServiceConfig {
    pub service_name: String,
    pub host: String,
    pub port: u16,
    pub database: DatabaseConfig,
    pub messaging: MessagingConfig,
    pub observability: ObservabilityConfig,
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

impl ServiceConfig {
    pub fn load() -> Result<Self, config::ConfigError> {
        config::Config::builder()
            .add_source(config::Environment::with_prefix("GUARDYN"))
            .build()?
            .try_deserialize()
    }
}
