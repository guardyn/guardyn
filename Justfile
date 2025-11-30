default: @echo "Run 'just --list' to view available tasks."

kube-create: @echo "[kube:create] Creating k3d cluster using infra/k3d-config.yaml" k3d cluster create --config infra/k3d-config.yaml

kube-delete: @echo "[kube:delete] Deleting k3d cluster guardyn-poc" k3d cluster delete guardyn-poc || true

kube-bootstrap: @echo "[kube:bootstrap] Installing core components" bash infra/scripts/bootstrap.sh

k8s-deploy service: bash infra/scripts/deploy.sh "{{service}}"

verify-kube: @echo "[verify:kube] Running smoke checks" bash infra/scripts/verify.sh

teardown: @echo "[teardown] Destroying cluster and cleaning up" just kube-delete

# Port-forwarding with auto-restart watchdog

port-forward: @echo "[port-forward] Starting port-forward watchdog (Ctrl+C to stop)" bash infra/scripts/port-forward-watchdog.sh

# Port-forwarding without Envoy (for native apps only)

port-forward-native: @echo "[port-forward] Starting port-forward watchdog for native apps" bash infra/scripts/port-forward-watchdog.sh --no-envoy --no-chromedriver

# Port-forwarding status check

port-forward-status: bash infra/scripts/port-forward-watchdog.sh --status

# Stop all port-forwards

port-forward-stop: bash infra/scripts/port-forward-watchdog.sh --stop

# Run two-user chat E2E test

test-chat: @echo "[test] Running two-user chat E2E test" bash backend/crates/e2e-tests/scripts/test-two-user-chat.sh

# Run all messaging E2E tests

test-messaging: @echo "[test] Running all messaging E2E tests" bash backend/crates/e2e-tests/scripts/test-two-user-chat.sh --all
