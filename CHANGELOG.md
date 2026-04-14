# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Update to KServe v0.17.0 (Go 1.25, chart restructuring).
- Upstream chart `kserve` renamed to `kserve-resources`; added new `kserve-runtime-configs` chart.
- Add Renovate custom manager for automatic KServe version tracking.

## [0.1.0] - 2026-04-14

### Added

- Initial repository setup: Dockerfile, CI pipeline, vendored Helm charts for KServe v0.16.0.
