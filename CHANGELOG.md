# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `kserve-resources`, `kserve-llmisvc-resources`: every image default is a `gsoci.azurecr.io/giantswarm/` reference -- the KServe images the controllers inject or run (`agent`, `router`, `storage-initializer`, `art-explainer`, `kserve-localmodel-controller`, `kserve-localmodelnode-agent`) and the `kube-rbac-proxy` sidecar through their retagger mirrors, the classic controller like the llmisvc controller already was. Nothing is pulled from Docker Hub or quay.io.
- `kserve-runtime-configs`: the classic `ClusterServingRuntime`s ship no third-party runtime image any more (every `kserve.servingruntime.<runtime>.image` is empty; `art.image` follows the mirror). With `kserve.servingruntime.enabled: true` a runtime renders only when its image is set, and rendering fails when no runtime has one. The Giant Swarm serving path is llm-d only; `enabled: false`, the default, renders as before.
- The release pipeline publishes `kserve-controller` under the KServe version it builds (`v0.20.0`), as it already did for `llmisvc-controller`; that tag is what `kserve-resources` resolves to by default.

### Added

- `kserve-runtime-configs`: `kserve.llmisvcConfigs.images.<preset>.<container>` replaces the image of one container of one well-known `LLMInferenceServiceConfig` preset after the registry rewrite -- `main` for the runtime, `llm-d-routing-sidecar` for the decode presets' sidecar -- and every other preset renders unchanged; the render fails for a preset or container the file does not have. An installation whose GPU nodes need another build of the same runtime (arm64 vLLM on unified-memory Blackwell nodes) names it once per preset instead of overriding `spec.template` in every preset. The chart README documents the precedence and the entrypoint an override image must serve. `make helm-test` and the `chart-test` CircleCI job run the chart's helm-unittest suites.
- `hack/check-image-registry.py` (`make check-image-registry`; the `check-image-registry` CircleCI job every chart publish requires) renders every chart with its defaults and its feature switches on and fails on any image reference outside `gsoci.azurecr.io`, in the manifests, in the JSON blocks of the `inferenceservice-config` ConfigMap and in `values.yaml`.
- `kserve-crd` and `kserve-llmisvc-crd`: every CRD carries `helm.sh/resource-policy: keep` (value `crd.keep`, default `true`), so `helm uninstall` -- or turning the chart off as a dependency of an umbrella chart -- leaves the CRDs and every InferenceService, ServingRuntime and LLMInferenceService on the cluster. Removing them becomes a deliberate `kubectl delete crd`.

### Fixed

- `kserve-llmisvc-crd`: the conversion webhook of the `LLMInferenceService` and `LLMInferenceServiceConfig` CRDs and their `cert-manager.io/inject-ca-from` annotation follow the release namespace instead of the hardcoded `kserve`, like `kserve-llmisvc-resources` already does. Install the CRD chart into the namespace the llmisvc controller runs in.

## [0.0.36] - 2026-06-21

### Changed



- Point the chart `icon` to the Giant Swarm-hosted KServe logo (`https://s.giantswarm.io/app-icons/kserve/1/light.svg`) in `kserve-crd`, `kserve-resources`, and `kserve-runtime-configs`, replacing the external `raw.githubusercontent.com/kserve/website` URL.
- Bump `giantswarm/architect` orb to `8.2.2` and re-enable cosign keyless chart signing (`sign: false` removed from every `push-to-app-catalog*` invocation). v8.2.2 ships [architect-orb#772](https://github.com/giantswarm/architect-orb/pull/772) which upgrades the `app-build-suite` executor image from `1.8.0-circleci` to `1.8.1-circleci` -- the new image includes the `cosign` binary that v8.2.0's chart signing defaults require. Closes [architect-orb#769](https://github.com/giantswarm/architect-orb/issues/769).
- Bump `giantswarm/architect` orb to `8.2.1` to pick up [architect-orb#767](https://github.com/giantswarm/architect-orb/pull/767): `image-login-to-registries` is now POSIX-portable, unblocking `architect/sync-china-registry` (the gsoci -> Aliyun mirror via the in-China `giantswarm/galaxy-runner`). The v8.1.0 refactor accidentally introduced bash-only `${!var}` indirect expansion in the shared login command, which BusyBox `/bin/sh` (used by the regctl executor) rejected with `bad substitution` -- so no Aliyun mirror has been happening since the migration to `split-china-push: true`. v8.2.x also enables cosign keyless signing, SLSA provenance, and SBOM attestations by default for public images and charts.
- Bump `giantswarm/architect` orb to `8.1.0` and enable `split-china-push: true` on the tag-build `push-to-registries-release` job; add a companion `sync-china-registry` job that mirrors the image from gsoci to Aliyun via the in-China `giantswarm/galaxy-runner` self-hosted runner. The cross-Pacific `docker buildx` push to Aliyun (which was timing out and blocking the tag job) is gone.
- Migrate image pushes from the deprecated `architect/push-to-registries-multiarch` job to `push-to-registries` with `multiarch: true`. Picks up the orb v8.1.0 QEMU/binfmt auto-registration, hardened buildx bootstrap, and standard OCI image labels.
- Update to KServe v0.17.0 (Go 1.25, chart restructuring).
- Upstream chart `kserve` renamed to `kserve-resources`; added new `kserve-runtime-configs` chart.
- Add Renovate custom manager for automatic KServe version tracking.

## [0.1.0] - 2026-04-14

### Added

- Initial repository setup: Dockerfile, CI pipeline, vendored Helm charts for KServe v0.16.0.

[Unreleased]: https://github.com/giantswarm/kserve/compare/v0.0.36...HEAD
[0.0.36]: https://github.com/giantswarm/kserve/compare/v0.0.35...v0.0.36
