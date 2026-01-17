# E2E Test Scripts

This directory contains scripts for running end-to-end tests and performance tests for Guardyn.

## Test Scripts

### `run-e2e-tests.sh`

Runs all E2E integration tests for the Guardyn MVP.

**Usage:**

```bash
backend/crates/e2e-tests/scripts/run-e2e-tests.sh
```

**What it does:**

- Validates k3d cluster is running
- Checks that required services are deployed
- Runs all 8 E2E test scenarios (registration, messaging, groups, etc.)
- Reports test results

### `run-performance-tests.sh`

Runs k6 performance/load tests for auth and messaging services.

**Usage:**

```bash
backend/crates/e2e-tests/scripts/run-performance-tests.sh [auth|messaging]
```

**Examples:**

```bash
# Run all performance tests
backend/crates/e2e-tests/scripts/run-performance-tests.sh

# Run auth service tests only
backend/crates/e2e-tests/scripts/run-performance-tests.sh auth

# Run messaging service tests only
backend/crates/e2e-tests/scripts/run-performance-tests.sh messaging
```

**What it does:**

- Sets up port-forwarding to services
- Runs k6 load tests with 50 concurrent virtual users
- Reports performance metrics (latency, throughput, success rate)
- Cleans up port-forwards on exit

### `k6-test.sh`

Wrapper script that automatically enters Nix environment before running performance tests.

**Usage:**

```bash
backend/crates/e2e-tests/scripts/k6-test.sh [auth|messaging]
```

**Recommended:** Use this script instead of `run-performance-tests.sh` if you're not already in a Nix shell.

**What it does:**

- Detects if k6 is available in current environment
- If not, automatically enters Nix development shell
- Runs `run-performance-tests.sh` with provided arguments

## Prerequisites

All test scripts require:

1. **k3d cluster running:**

   ```bash
   k3d cluster list  # Should show guardyn-poc
   ```

2. **Services deployed:**

   ```bash
   kubectl get pods -n apps
   # Should show auth-service and messaging-service running
   ```

3. **Nix environment** (for performance tests):

   ```bash
   nix develop --extra-experimental-features 'nix-command flakes'
   ```

## Quick Reference

| Task | Command |
|------|---------|
| Run all E2E tests | `backend/crates/e2e-tests/scripts/run-e2e-tests.sh` |
| Run performance tests (with Nix wrapper) | `backend/crates/e2e-tests/scripts/k6-test.sh` |
| Run performance tests (direct) | `backend/crates/e2e-tests/scripts/run-performance-tests.sh` |
| Auth performance only | `backend/crates/e2e-tests/scripts/k6-test.sh auth` |
| Messaging performance only | `backend/crates/e2e-tests/scripts/k6-test.sh messaging` |

## Test Suites

### MVP Tests (`e2e_mvp_simplified.rs`)

Core messaging functionality tests:

| Test | Description |
|------|-------------|
| `test_01_user_registration` | User registration and login |
| `test_02_send_message` | Direct message sending |
| `test_03_group_creation` | Group creation and joining |
| `test_04_group_messaging` | Group message sending |
| `test_05_presence` | Online status updates |
| `test_06_push_notifications` | Push token registration |
| `test_07_message_history` | Message history retrieval |
| `test_08_full_flow` | Complete user flow |

### Phase 2 Tests (`e2e_phase2_features.rs`)

Enhanced messenger features tests:

| Test | Description |
|------|-------------|
| `test_phase2_01_add_and_remove_reaction` | Emoji reactions on messages |
| `test_phase2_02_read_receipts` | Read receipt tracking |
| `test_phase2_03_forward_message` | Message forwarding with attribution |
| `test_phase2_04_edit_message` | Message editing with version history |
| `test_phase2_05_disappearing_messages` | Auto-delete message configuration |
| `test_phase2_06_multiple_reactions` | Multi-user reactions in groups |

**Running Phase 2 tests:**

```bash
# Run all Phase 2 tests
cargo test -p guardyn-e2e-tests --test e2e_phase2_features -- --nocapture --test-threads=1

# Run specific test
cargo test -p guardyn-e2e-tests --test e2e_phase2_features test_phase2_01 -- --nocapture
```

## Documentation

For detailed testing documentation, see:

- [`docs/TESTING_GUIDE.md`](../../../docs/TESTING_GUIDE.md) - Complete testing guide
- [`docs/QUICKSTART_TESTING.md`](../../../docs/QUICKSTART_TESTING.md) - Quick reference
- [`tests/test_scenarios.md`](../tests/test_scenarios.md) - Test scenarios documentation
- [`performance/README.md`](../performance/README.md) - Performance testing details

