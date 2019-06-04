.PHONY: help
SDK_VER="v0.6.0"
KUBE_VER="v1.13.0"
VM_DRIVER=none
MAKEFLAGS += --no-print-directory
OP_PATH=''
OK=\033[0;32m
WARN=\033[0;33m
ERR=\033[0;31m
NC=\033[0m
force_color_prompt=yes
VERBOSE=0

help:
	@grep -E '^[a-zA-Z0-9/._-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check_path:
	@if [ ! -d ${OP_PATH} ]; then echo "Operator path not found"; exit 1; fi

dependencies.check: ## Check your local dependencies
	@scripts/utils/check-deps.py
	@echo "Cheking dependencies finished"

dependencies.install.yq: ## Install yq
	@curl -Lo yq https://github.com/mikefarah/yq/releases/download/2.2.1/yq_linux_amd64
	@chmod +x yq
	@sudo mv yq /usr/local/bin/
	@echo "Installed"

dependencies.install.jq: ## Install jq
	@curl -Lo jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	@chmod +x jq
	@sudo mv jq /usr/local/bin/
	@echo "Installed"

dependencies.install.operator-courier: ## Install operator-courier
	@python3 -m pip install operator-courier
	@echo "Installed"

dependencies.install.operator-sdk: ## Install operator-sdk
	@curl -Lo operator-sdk "https://github.com/operator-framework/operator-sdk/releases/download/${SDK_VER}/operator-sdk-${SDK_VER}-x86_64-linux-gnu"
	@chmod +x operator-sdk
	@sudo mv operator-sdk /usr/local/bin/
	@echo "Installed"

dependencies.install.kubectl: ## Install kubectl 
	@curl -Lo kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBE_VER}/bin/linux/amd64/kubectl"
	@chmod +x kubectl
	@sudo mv kubectl /usr/local/bin/
	@echo "Installed"

dependencies.install.crictl: ## Install crictl
	@curl -Lo crictl.tar.gz "https://github.com/kubernetes-sigs/cri-tools/releases/download/${KUBE_VER}/crictl-${KUBE_VER}-linux-amd64.tar.gz"
	@tar -zxvf crictl.tar.gz
	@chmod +x crictl
	@sudo mv crictl /usr/local/bin/
	@rm crictl.tar.gz
	@echo "Installed"

dependencies.install.minikube: ## Install the local minikube
	@curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
	@chmod +x minikube
	@sudo mv minikube /usr/local/bin/
	@echo "Installed"

minikube.start: ## Start local minikube
	@scripts/ci/run-script "minikube start --vm-driver=${VM_DRIVER} --kubernetes-version="v1.12.0" --extra-config=apiserver.v=4 -p operator" "Start minikube"

operator.olm.install: ## Install OLM to your cluster
	@scripts/ci/run-script "scripts/ci/install-olm-local" "Install OLM"

operator.registry.build: check_path ## Build registry image
	@scripts/ci/run-script "scripts/ci/build-registry-image" "Build registry image"


operator.test: check_path ## Operator test which run courier and scoreboard
	@make operator.verify
	@if [ -f ~/.kube/config ]; then printf "Find kube config %s\t[ ${OK} LOCAL ${NC} ]\n"  | expand  -t 50; else printf "Find kube config %s\t[ ${WARN} NOT FOUND ${NC} ]\n"  | expand  -t 50; make minikube.start; fi
	@make operator.olm.install
	@make operator.registry.build
	@scripts/ci/run-script "scripts/ci/operator-test" "Test operator with scoreboard"

operator.verify: check_path ## Run only courier
	@scripts/ci/run-script "operator-courier verify --ui_validate_io ${OP_PATH}" "Verify operator"
