##@ Helm

HELM_UNITTEST_VERSION := 1.0.3
# Every chart with a tests/ directory (helm-unittest suites).
CHARTS_WITH_TESTS := $(patsubst helm/%/tests,%,$(wildcard helm/*/tests))

.PHONY: helm-test
helm-test: helm-unittest ## Run every chart check (what the chart-test CircleCI job runs).

# The charts carry architect's `[[ .Version ]]` placeholder, which helm refuses to load, so every
# chart is staged in a temporary directory with a stand-in version before helm lint and helm
# unittest see it (what the generated lint-chart target does with `architect helm template`).
.PHONY: helm-unittest
helm-unittest: helm-plugin-unittest ## Lint and run the helm-unittest suites of every chart with a tests/ directory.
	@set -eu; for chart in $(CHARTS_WITH_TESTS); do \
	  staged=$$(mktemp -d); \
	  cp -a "helm/$$chart/." "$$staged/"; \
	  sed -i 's/^version: .*/version: 0.0.0-test/' "$$staged/Chart.yaml"; \
	  echo "==> $$chart"; \
	  if helm lint --strict "$$staged" && helm unittest "$$staged"; then rm -rf "$$staged"; else rm -rf "$$staged"; exit 1; fi; \
	done

.PHONY: helm-plugin-unittest
helm-plugin-unittest:
	@helm plugin list | grep -q '^unittest' || helm plugin install https://github.com/helm-unittest/helm-unittest --version $(HELM_UNITTEST_VERSION)
