default:
	@echo "Run 'just --list' to view available tasks."


kube-create:
	@echo "[kube:create] Creating k3d cluster using infra/k3d-config.yaml"
	k3d cluster create --config infra/k3d-config.yaml

kube-delete:
	@echo "[kube:delete] Deleting k3d cluster guardyn3-poc"
	k3d cluster delete guardyn3-poc || true

kube-bootstrap:
	@echo "[kube:bootstrap] Installing core components"
	bash infra/scripts/bootstrap.sh


k8s-deploy service:
	bash infra/scripts/deploy.sh "{{service}}"

verify-kube:
	@echo "[verify:kube] Running smoke checks"
	bash infra/scripts/verify.sh

teardown:
	@echo "[teardown] Destroying cluster and cleaning up"
	just kube-delete
