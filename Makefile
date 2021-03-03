
default: manifests

ifeq ($(VERSION),)
VERSION=$(shell git describe --tags  --long)-$(shell date +"%Y%m%d%H%M%S")
endif

# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

CRD_OPTIONS ?= "crd:trivialVersions=true"

# Generate manifests e.g. CRD, RBAC etc.
manifests: controller-gen
	mkdir -p config/crd/db
	$(CONTROLLER_GEN) $(CRD_OPTIONS) paths="./api/db/v1" output:crd:artifacts:config=config/crd/db

# Generate code
generate: controller-gen
	$(CONTROLLER_GEN) object:headerFile="hack/boilerplate.go.txt" paths="./api/db/v1/..."

# find or download controller-gen
# download controller-gen if necessary
controller-gen:
ifeq (, $(shell which controller-gen))
	@{ \
	set -e ;\
	CONTROLLER_GEN_TMP_DIR=$$(mktemp -d) ;\
	cd $$CONTROLLER_GEN_TMP_DIR ;\
	go mod init tmp ;\
	go get sigs.k8s.io/controller-tools/cmd/controller-gen@v0.4.0 ;\
	rm -rf $$CONTROLLER_GEN_TMP_DIR ;\
	}
CONTROLLER_GEN=$(GOBIN)/controller-gen
else
CONTROLLER_GEN=$(shell which controller-gen)
endif