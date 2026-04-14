KSERVE_VERSION ?= v0.16.0
CHART_DIR := helm

.PHONY: sync-charts
sync-charts:
	rm -rf $(CHART_DIR)/kserve $(CHART_DIR)/kserve-crd
	helm pull oci://ghcr.io/kserve/charts/kserve --version $(KSERVE_VERSION) --untar --untardir $(CHART_DIR)/
	helm pull oci://ghcr.io/kserve/charts/kserve-crd --version $(KSERVE_VERSION) --untar --untardir $(CHART_DIR)/

.PHONY: build
build:
	docker buildx build --platform linux/arm64 -t kserve-controller:dev --load .
