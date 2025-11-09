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
        let mut cfg = config::Config::builder()
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
        
        builder.build()?.try_deserialize()
    }
}
