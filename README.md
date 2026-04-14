# kserve

Giant Swarm build of the [KServe](https://github.com/kserve/kserve) controller. Produces:

- **Container image**: `gsoci.azurecr.io/giantswarm/kserve-controller` (multi-arch: amd64 + arm64)
- **Helm charts** (OCI): `kserve-resources`, `kserve-crd`, and `kserve-runtime-configs` in the `giantswarm-catalog`

## Upstream version

Currently pinned to **v0.17.0**. The version is set in:

- `Dockerfile` (`KSERVE_VERSION` build arg -- tracked by Renovate)
- `Makefile` (`KSERVE_VERSION` variable -- tracked by Renovate)
- `helm/*/Chart.yaml` (vendored from upstream, updated via `make sync-charts`)

## Updating to a new upstream version

Renovate opens PRs when a new KServe release appears on GitHub. After merging:

1. Run `make sync-charts` to re-vendor the Helm charts at the new version.
2. Verify the Go version in the `Dockerfile` matches upstream's `go.mod`.
3. Commit, push, and tag.

## Chart restructuring (v0.17.0+)

Starting with v0.17.0, upstream split the single `kserve` chart into three:

| Chart | Purpose |
|---|---|
| `kserve-resources` | Controller deployment, RBAC, webhooks, inferenceservice-config |
| `kserve-crd` | CRD definitions |
| `kserve-runtime-configs` | ClusterServingRuntimes and LLM inference configs |

Consumers that previously used `kserve` need to reference `kserve-resources` instead.

## Local build

```bash
make build
```
