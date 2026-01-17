//! Rate Limiting Middleware for Tonic gRPC
//!
//! Provides Tower layer and service for rate limiting gRPC requests.

use std::future::Future;
use std::net::IpAddr;
use std::pin::Pin;
use std::sync::Arc;
use std::task::{Context, Poll};

use http::{Request, Response, StatusCode};
use pin_project::pin_project;
use tower::{Layer, Service};

use crate::rate_limit::{RateLimitError, RateLimiter};

/// Header name for forwarded IP address
const X_FORWARDED_FOR: &str = "x-forwarded-for";
const X_REAL_IP: &str = "x-real-ip";

/// Header name for user ID (set by auth middleware)
const X_USER_ID: &str = "x-user-id";

/// Extract client IP from request headers
fn extract_client_ip<B>(request: &Request<B>) -> Option<IpAddr> {
    // Try X-Forwarded-For first (may have multiple IPs, take the first)
    if let Some(forwarded) = request.headers().get(X_FORWARDED_FOR) {
        if let Ok(value) = forwarded.to_str() {
            if let Some(first_ip) = value.split(',').next() {
                if let Ok(ip) = first_ip.trim().parse() {
                    return Some(ip);
                }
            }
        }
    }

    // Try X-Real-IP
    if let Some(real_ip) = request.headers().get(X_REAL_IP) {
        if let Ok(value) = real_ip.to_str() {
            if let Ok(ip) = value.trim().parse() {
                return Some(ip);
            }
        }
    }

    None
}

/// Extract user ID from request headers
fn extract_user_id<B>(request: &Request<B>) -> Option<String> {
    request
        .headers()
        .get(X_USER_ID)
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_string())
}

/// Tower Layer for rate limiting
#[derive(Clone)]
pub struct RateLimitLayer {
    limiter: Arc<RateLimiter>,
}

impl RateLimitLayer {
    /// Create a new rate limit layer
    pub fn new(limiter: RateLimiter) -> Self {
        Self {
            limiter: Arc::new(limiter),
        }
    }

    /// Create from an Arc'd limiter (for sharing across services)
    pub fn from_arc(limiter: Arc<RateLimiter>) -> Self {
        Self { limiter }
    }
}

impl<S> Layer<S> for RateLimitLayer {
    type Service = RateLimitService<S>;

    fn layer(&self, service: S) -> Self::Service {
        RateLimitService {
            inner: service,
            limiter: Arc::clone(&self.limiter),
        }
    }
}

/// Tower Service that applies rate limiting
#[derive(Clone)]
pub struct RateLimitService<S> {
    inner: S,
    limiter: Arc<RateLimiter>,
}

impl<S> RateLimitService<S> {
    /// Get the underlying limiter for configuration
    pub fn limiter(&self) -> &RateLimiter {
        &self.limiter
    }
}

/// Result of rate limit check
#[derive(Debug, Clone)]
pub enum RateLimitCheckResult {
    /// Request is allowed, contains remaining request count
    Allowed { remaining: u32 },
    /// Request is rate limited
    Limited(RateLimitError),
}

impl<S, ReqBody, ResBody> Service<Request<ReqBody>> for RateLimitService<S>
where
    S: Service<Request<ReqBody>, Response = Response<ResBody>> + Clone + Send + 'static,
    S::Future: Send + 'static,
    ReqBody: Send + 'static,
    ResBody: Default + Send + 'static,
{
    type Response = S::Response;
    type Error = S::Error;
    type Future = RateLimitFuture<S::Future, ResBody>;

    fn poll_ready(&mut self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        self.inner.poll_ready(cx)
    }

    fn call(&mut self, request: Request<ReqBody>) -> Self::Future {
        let ip = extract_client_ip(&request);
        let user_id = extract_user_id(&request);

        // Check rate limit
        match self.limiter.check(ip, user_id.as_deref()) {
            Ok(()) => {
                // Record the request
                self.limiter.record(ip, user_id.as_deref());

                // Calculate remaining requests for headers
                let remaining = ip
                    .map(|ip| self.limiter.remaining_for_ip(ip))
                    .unwrap_or(u32::MAX);

                RateLimitFuture::Allowed {
                    future: self.inner.call(request),
                    remaining,
                }
            }
            Err(err) => RateLimitFuture::Limited { error: Some(err) },
        }
    }
}

/// Future for rate-limited requests
#[pin_project(project = RateLimitFutureProj)]
pub enum RateLimitFuture<F, B> {
    /// Request was allowed
    Allowed {
        #[pin]
        future: F,
        remaining: u32,
    },
    /// Request was rate limited
    Limited {
        error: Option<RateLimitError>,
    },
    /// Phantom for body type
    #[doc(hidden)]
    _Phantom(std::marker::PhantomData<B>),
}

impl<F, B, E> Future for RateLimitFuture<F, B>
where
    F: Future<Output = Result<Response<B>, E>>,
    B: Default,
{
    type Output = Result<Response<B>, E>;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
        match self.project() {
            RateLimitFutureProj::Allowed { future, remaining } => {
                match future.poll(cx) {
                    Poll::Ready(Ok(mut response)) => {
                        // Add rate limit headers
                        let headers = response.headers_mut();
                        if let Ok(value) = remaining.to_string().parse() {
                            headers.insert("x-ratelimit-remaining", value);
                        }
                        Poll::Ready(Ok(response))
                    }
                    other => other,
                }
            }
            RateLimitFutureProj::Limited { error } => {
                let err = error.take().unwrap();
                let (status, retry_after) = match &err {
                    RateLimitError::LimitExceeded { retry_after, .. } => {
                        (StatusCode::TOO_MANY_REQUESTS, Some(retry_after.as_secs()))
                    }
                    RateLimitError::IpBlocked { .. } => (StatusCode::FORBIDDEN, None),
                    RateLimitError::UserBlocked { .. } => (StatusCode::FORBIDDEN, None),
                };

                let mut response = Response::builder()
                    .status(status)
                    .body(B::default())
                    .unwrap();

                if let Some(retry) = retry_after {
                    if let Ok(value) = retry.to_string().parse() {
                        response.headers_mut().insert("retry-after", value);
                    }
                }

                // Log the rate limit event
                tracing::warn!(
                    error = %err,
                    status = %status,
                    "Rate limit applied"
                );

                Poll::Ready(Ok(response))
            }
            RateLimitFutureProj::_Phantom(_) => unreachable!(),
        }
    }
}

/// Interceptor for tonic that applies rate limiting
/// Use this for simpler integration with tonic services
pub fn rate_limit_interceptor(
    limiter: Arc<RateLimiter>,
) -> impl Fn(tonic::Request<()>) -> Result<tonic::Request<()>, tonic::Status> + Clone {
    move |mut request: tonic::Request<()>| {
        // Extract IP from metadata
        let ip = request
            .metadata()
            .get(X_FORWARDED_FOR)
            .or_else(|| request.metadata().get(X_REAL_IP))
            .and_then(|v| v.to_str().ok())
            .and_then(|s| s.split(',').next())
            .and_then(|s| s.trim().parse().ok());

        // Extract user ID from metadata
        let user_id = request
            .metadata()
            .get(X_USER_ID)
            .and_then(|v| v.to_str().ok())
            .map(|s| s.to_string());

        // Check rate limit
        match limiter.check(ip, user_id.as_deref()) {
            Ok(()) => {
                limiter.record(ip, user_id.as_deref());

                // Add remaining count to extensions for downstream use
                let remaining = ip
                    .map(|ip| limiter.remaining_for_ip(ip))
                    .unwrap_or(u32::MAX);
                request.extensions_mut().insert(RateLimitCheckResult::Allowed { remaining });

                Ok(request)
            }
            Err(RateLimitError::LimitExceeded { retry_after, .. }) => {
                Err(tonic::Status::resource_exhausted(format!(
                    "Rate limit exceeded. Retry after {} seconds.",
                    retry_after.as_secs()
                )))
            }
            Err(RateLimitError::IpBlocked { ip }) => {
                Err(tonic::Status::permission_denied(format!(
                    "IP address {} is blocked",
                    ip
                )))
            }
            Err(RateLimitError::UserBlocked { user_id }) => {
                Err(tonic::Status::permission_denied(format!(
                    "User {} is blocked",
                    user_id
                )))
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_extract_forwarded_ip() {
        let request = Request::builder()
            .header(X_FORWARDED_FOR, "192.168.1.1, 10.0.0.1")
            .body(())
            .unwrap();

        let ip = extract_client_ip(&request);
        assert_eq!(ip, Some("192.168.1.1".parse().unwrap()));
    }

    #[test]
    fn test_extract_real_ip() {
        let request = Request::builder()
            .header(X_REAL_IP, "10.0.0.1")
            .body(())
            .unwrap();

        let ip = extract_client_ip(&request);
        assert_eq!(ip, Some("10.0.0.1".parse().unwrap()));
    }

    #[test]
    fn test_extract_user_id() {
        let request = Request::builder()
            .header(X_USER_ID, "user-123")
            .body(())
            .unwrap();

        let user_id = extract_user_id(&request);
        assert_eq!(user_id, Some("user-123".to_string()));
    }

    #[test]
    fn test_no_ip_header() {
        let request = Request::builder().body(()).unwrap();

        let ip = extract_client_ip(&request);
        assert_eq!(ip, None);
    }

    #[test]
    fn test_invalid_ip() {
        let request = Request::builder()
            .header(X_FORWARDED_FOR, "not-an-ip")
            .body(())
            .unwrap();

        let ip = extract_client_ip(&request);
        assert_eq!(ip, None);
    }
}
