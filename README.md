# kserve

Giant Swarm build of the [KServe](https://github.com/kserve/kserve) controllers. Produces:

- **Container images** (multi-arch: amd64 + arm64):
  - `gsoci.azurecr.io/giantswarm/kserve-controller` -- the classic KServe controller (`cmd/manager`)
  - `gsoci.azurecr.io/giantswarm/llmisvc-controller` -- the LLMInferenceService controller (`cmd/llmisvc`)
- **Helm charts** (OCI, `gsoci.azurecr.io/charts/giantswarm/<chart>`): `kserve-resources`, `kserve-crd`,
  `kserve-runtime-configs`, `kserve-llmisvc-crd`, and `kserve-llmisvc-resources`

## Upstream version

Currently pinned to **v0.20.0**. The version is set in:

- `Dockerfile` and `Dockerfile.llmisvc` (`KSERVE_VERSION` build arg -- tracked by Renovate)
- `helm/*/Chart.yaml` and `helm/*/values.yaml` (`appVersion` / `kserve.version`, vendored from upstream)

## Updating to a new upstream version

Renovate opens PRs when a new KServe release appears on GitHub (bumping the
`KSERVE_VERSION` build args). After merging:

1. Re-vendor the Helm charts by hand from the upstream tag's `charts/` tree
   (the charts are byte-copies of upstream plus a small set of deliberate
   Giant Swarm overlays -- Chart.yaml metadata, team label in `_helpers.tpl`,
   the gsoci default image in `kserve-llmisvc-resources/values.yaml`, and the
   generated schema files).
2. Verify the Go version in the Dockerfiles matches upstream's `go.mod`.
3. Run `pre-commit run -a` until clean (regenerates schemas and chart READMEs).
4. Commit, push, and tag.

## Charts

Starting with v0.17.0, upstream split the single `kserve` chart; since v0.20.0
the LLMInferenceService (llmisvc) control plane ships as its own pair of charts:

| Chart | Purpose |
|---|---|
| `kserve-resources` | Classic controller deployment, RBAC, webhooks, inferenceservice-config |
| `kserve-crd` | CRDs for the classic control plane (InferenceService etc.) |
| `kserve-runtime-configs` | ClusterServingRuntimes and llmisvc config presets |
| `kserve-llmisvc-crd` | `LLMInferenceService` / `LLMInferenceServiceConfig` CRDs |
| `kserve-llmisvc-resources` | llmisvc controller deployment, RBAC, webhooks, GIE CRDs |

Consumers that previously used `kserve` need to reference `kserve-resources` instead.

## LLMInferenceService (llmisvc) install order

The llmisvc control plane is independent of the classic controller. Install:

1. **Gateway API CRDs** (standard channel) -- prerequisite, not shipped here:
   `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml`
   (KServe v0.20.0 builds against Gateway API v1.5.1)
2. `kserve-llmisvc-crd` -- the `LLMInferenceService` / `LLMInferenceServiceConfig` CRDs.
3. `kserve-llmisvc-resources` -- the llmisvc controller. By default this also
   installs the Gateway API Inference Extension CRDs (`InferencePool` etc.)
   embedded in the chart; set `kserve.llmisvc.createGIECRDs: false` if those
   CRDs are managed elsewhere. Like `kserve-resources`, the chart also creates
   the shared resources (`inferenceservice-config` ConfigMap, self-signed
   cert-manager Issuer, default ClusterStorageContainer); when installing it
   alongside `kserve-resources` in the same namespace, set
   `kserve.createSharedResources: false` on one of the two releases.
4. `kserve-runtime-configs` with `kserve.llmisvcConfigs.enabled: true` -- the
   well-known `LLMInferenceServiceConfig` presets. The images the presets pin
   are mirrored/built by [giantswarm/llm-d](https://github.com/giantswarm/llm-d).

The controller image defaults to `gsoci.azurecr.io/giantswarm/llmisvc-controller`
at the pinned `kserve.version` tag, which the release pipeline publishes
alongside the repo-versioned tags.

## Giant Swarm overlays on the vendored charts

The charts are byte copies of upstream `charts/<name>` except for these
deliberate changes. Re-apply them after a re-vendor:

- `Chart.yaml` of every chart: Giant Swarm annotations, icon, `version: "[[ .Version ]]"`.
- `_helpers.tpl`: the `application.giantswarm.io/team` label (the whole file in
  `kserve-crd` and `kserve-llmisvc-crd`).
- `kserve-crd`, `kserve-llmisvc-crd`: `crd.keep` (default `true`) adds
  `helm.sh/resource-policy: keep` to every CRD (the `ClusterStorageContainer`
  CRD gets it injected into the document loaded from `files/`).
- `kserve-llmisvc-crd`: the conversion-webhook service namespace and the
  `cert-manager.io/inject-ca-from` annotation render `.Release.Namespace`
  instead of the hardcoded `kserve`.
- `kserve-resources`: Renovate-pinned `rbacProxyImage`;
  `kserve-llmisvc-resources`: the `gsoci.azurecr.io/giantswarm/llmisvc-controller`
  default image.
- Giant Swarm-only files: `.schema.yaml`, `values.schema.json`,
  `zz_generated.app-platform.values.yaml`, `.kube-linter.yaml`.

## Local build

```bash
make build
```
