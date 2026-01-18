//! Guardyn Crypto FFI Library
//!
//! This crate provides Flutter Rust Bridge bindings for guardyn-crypto,
//! enabling Flutter applications to use Rust cryptography via FFI.
//!
//! # Architecture
//!
//! ```text
//! ┌─────────────────────────────────────┐
//! │        Flutter App (Dart)           │
//! └─────────────────┬───────────────────┘
//!                   │ FFI
//! ┌─────────────────▼───────────────────┐
//! │       guardyn-crypto-ffi            │ ◄── This crate
//! │   (flutter_rust_bridge bindings)    │
//! └─────────────────┬───────────────────┘
//!                   │ Rust
//! ┌─────────────────▼───────────────────┐
//! │        guardyn-crypto               │
//! │  (X3DH, Double Ratchet, MLS, PQXDH) │
//! └─────────────────────────────────────┘
//! ```
//!
//! # Features
//!
//! - `pq` - Enable post-quantum cryptography (ML-KEM-768)
//! - `full` - Enable all features (default)

pub mod api;
pub mod frb_generated;

pub use api::*;
