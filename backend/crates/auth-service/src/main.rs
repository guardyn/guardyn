/// Authentication Service
///
/// Handles:
/// - User registration
/// - Login/logout
/// - Device management
/// - Session handling
/// - JWT token generation

use guardyn_iommon::{config::ServiceConfig, observability};
use tokio::net::TcpListener;
use std::convert::Infallible;
use hyper::{Body, Request, Response, Server, Method, StatusCode};
use hyper::service::{make_service_fn, service_fn};

async fn handle_request(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    let response = match (req.method(), req.uri().path()) {
        (&Method::GET, "/health") => {
            Response::builder()
                .status(StatusCode::OK)
                .body(Body::from("OK"))
                .unwrap()
        }
        (&Method::GET, "/ready") => {
            Response::builder()
                .status(StatusCode::OK)
                .body(Body::from("READY"))
                .unwrap()
        }
        _ => {
            Response::builder()
                .status(StatusCode::NOT_FOUND)
                .body(Body::from("Not Found"))
                .unwrap()
        }
    };
    Ok(response)
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let config = ServiceConfig::load()?;
    observability::init_tracing(&config.service_name, &config.observability.log_level);

    tracing::info!("Starting authentication service on {}:{}", config.host, config.port);

    // Start HTTP server
    let addr = format!("{}:{}", config.host, config.port).parse()?;
    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, Infallible>(service_fn(handle_request))
    });
    let server = Server::bind(&addr).serve(make_svc);
    
    tracing::info!("Auth service listening on {}", addr);
    if let Err(e) = server.await {
        tracing::error!("Server error: {}", e);
    }

    Ok(())
}
    // TODO: Start health check endpoints

    tracing::info!("Authentication service ready");

    // Keep service running
    tokio::signal::ctrl_c().await?;
    tracing::info!("Shutting down authentication service");

    Ok(())
}
