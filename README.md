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
   the gsoci image defaults in the resources charts' `values.yaml`, the
   image-less classic runtimes, and the generated schema files; the full list
   is under [Giant Swarm overlays](#giant-swarm-overlays-on-the-vendored-charts)).
2. Verify the Go version in the Dockerfiles matches upstream's `go.mod`.
3. Run `pre-commit run -a` until clean (regenerates schemas and chart READMEs)
   and `make check-image-registry` (every image default is a gsoci reference).
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
   well-known `LLMInferenceServiceConfig` presets, rendered into the release
   namespace. Their `ghcr.io/llm-d/` images are rewritten at render time to
   `kserve.llmisvcConfigs.imageRegistry`, by default the digest-identical
   mirror set [giantswarm/llm-d](https://github.com/giantswarm/llm-d) keeps on
   `gsoci.azurecr.io/giantswarm/` at the same tags; `ghcr.io/llm-d/` renders
   upstream's images. `kserve.llmisvcConfigs.images.<preset>.<container>`
   then replaces the image of one container of one preset (`main` for the
   runtime, `llm-d-routing-sidecar` for the decode presets' sidecar) -- for
   GPU nodes that need another build of the same runtime, such as an arm64
   vLLM on unified-memory Blackwell nodes; the chart README has the precedence
   and the entrypoint an override image must serve. The agent-platform chart
   consumes exactly this as its `kserve-runtime-configs` component
   (`llmisvcConfigs` on, `servingruntime` off, no registry value).

The controller images default to `gsoci.azurecr.io/giantswarm/kserve-controller`
and `gsoci.azurecr.io/giantswarm/llmisvc-controller` at the pinned
`kserve.version` tag, which the release pipeline publishes alongside the
repo-versioned tags.

## Images

Every image the charts reference by default is a `gsoci.azurecr.io/giantswarm/`
reference; nothing is pulled from Docker Hub, quay.io or ghcr.io, so an
installation that pulls from one registry overrides nothing and a Kyverno
signature policy that trusts one Giant Swarm identity admits them all:

- `kserve-controller` and `llmisvc-controller` are built here (multi-arch,
  signed by the release pipeline).
- The KServe images the controllers inject or run -- `agent`, `router`,
  `storage-initializer`, `art-explainer`, `kserve-localmodel-controller`,
  `kserve-localmodelnode-agent` -- and the controller's `kube-rbac-proxy`
  sidecar are mirrored and signed by
  [giantswarm/retagger](https://github.com/giantswarm/retagger) under their
  upstream tags.
- The llm-d images the `LLMInferenceServiceConfig` presets pin are mirrored by
  [giantswarm/llm-d](https://github.com/giantswarm/llm-d)
  (`kserve.llmisvcConfigs.imageRegistry`, see above).
- The classic `ClusterServingRuntime`s of `kserve-runtime-configs` ship no
  image: the Giant Swarm serving path is llm-d only. With
  `kserve.servingruntime.enabled: true` a runtime renders only when its `image`
  is set; rendering fails when none is.

`make check-image-registry` (`hack/check-image-registry.py`, also the
`check-image-registry` CircleCI job every chart publish requires) renders every
chart with its defaults and its feature switches on and fails on any image
reference outside `gsoci.azurecr.io` -- in the manifests, in the JSON blocks of
the `inferenceservice-config` ConfigMap, and in `values.yaml`.

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
- `kserve-runtime-configs`: the llmisvc presets' `ghcr.io/llm-d/` images are
  rewritten to `kserve.llmisvcConfigs.imageRegistry` (default
  `gsoci.azurecr.io/giantswarm/`), a container named in
  `kserve.llmisvcConfigs.images.<preset>.<container>` gets that image, and
  their hardcoded `namespace: kserve` follows `.Release.Namespace`
  (`kserve-common.replaceNamespace`); the file under `files/` stays upstream's
  verbatim, a preset without an override renders byte for byte. The
  helm-unittest suites under `helm/*/tests/` run with `make helm-test` (the
  `chart-test` CircleCI job).
- `kserve-resources`, `kserve-llmisvc-resources`: every image default in
  `values.yaml` is a `gsoci.azurecr.io/giantswarm/` reference (see
  [Images](#images)), the Renovate-pinned `rbacProxyImage` included.
- `kserve-runtime-configs`: the classic runtimes' `image` values are empty and
  `templates/runtimes/resources.yaml` renders only runtimes that have one
  (failing when none has).
- Giant Swarm-only files: `.schema.yaml`, `values.schema.json`,
  `zz_generated.app-platform.values.yaml`, `.kube-linter.yaml`.

## Local build

```bash
make build
```
