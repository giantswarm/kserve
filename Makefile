# renovate: datasource=github-releases depName=kserve/kserve
KSERVE_VERSION ?= v0.17.0

CHART_DIR := helm

.PHONY: sync-charts
sync-charts:
	rm -rf $(CHART_DIR)/kserve-resources $(CHART_DIR)/kserve-crd $(CHART_DIR)/kserve-runtime-configs
	helm pull oci://ghcr.io/kserve/charts/kserve-resources --version $(KSERVE_VERSION) --untar --untardir $(CHART_DIR)/
	helm pull oci://ghcr.io/kserve/charts/kserve-crd --version $(KSERVE_VERSION) --untar --untardir $(CHART_DIR)/
	helm pull oci://ghcr.io/kserve/charts/kserve-runtime-configs --version $(KSERVE_VERSION) --untar --untardir $(CHART_DIR)/

.PHONY: build
build:
	docker buildx build --platform linux/arm64 -t kserve-controller:dev --load .
