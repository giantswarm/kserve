# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Bump `giantswarm/architect` orb to `8.1.0` and enable `split-china-push: true` on the tag-build `push-to-registries-release` job; add a companion `sync-china-registry` job that mirrors the image from gsoci to Aliyun via the in-China `giantswarm/galaxy-runner` self-hosted runner. The cross-Pacific `docker buildx` push to Aliyun (which was timing out and blocking the tag job) is gone.
- Migrate image pushes from the deprecated `architect/push-to-registries-multiarch` job to `push-to-registries` with `multiarch: true`. Picks up the orb v8.1.0 QEMU/binfmt auto-registration, hardened buildx bootstrap, and standard OCI image labels.
- Update to KServe v0.17.0 (Go 1.25, chart restructuring).
- Upstream chart `kserve` renamed to `kserve-resources`; added new `kserve-runtime-configs` chart.
- Add Renovate custom manager for automatic KServe version tracking.

## [0.1.0] - 2026-04-14

### Added

- Initial repository setup: Dockerfile, CI pipeline, vendored Helm charts for KServe v0.16.0.
