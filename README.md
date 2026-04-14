# kserve

Giant Swarm build of the [KServe](https://github.com/kserve/kserve) controller. Produces:

- **Container image**: `gsoci.azurecr.io/giantswarm/kserve-controller` (multi-arch: amd64 + arm64)
- **Helm charts** (OCI): `kserve` and `kserve-crd` in the `giantswarm-catalog`

## Upstream version

Currently pinned to **v0.16.0**. The version is set in:

- `Dockerfile` (`KSERVE_VERSION` build arg)
- `helm/kserve/Chart.yaml`
- `helm/kserve-crd/Chart.yaml`
- `Makefile` (`KSERVE_VERSION` variable)

## Updating to a new upstream version

1. Update `KSERVE_VERSION` in the `Dockerfile` and `Makefile`.
2. Run `make sync-charts` to pull the new Helm charts from upstream.
3. Verify the Go version in the `Dockerfile` matches upstream's `go.mod`.
4. Commit, push, and tag.

## Local build

```bash
make build
```
