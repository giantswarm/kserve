# Multi-stage build for the KServe controller.
# Fetches upstream source at the pinned version and cross-compiles for the target platform.
# renovate: datasource=github-releases depName=kserve/kserve
ARG KSERVE_VERSION=v0.17.0

# renovate: datasource=docker depName=golang
FROM --platform=$BUILDPLATFORM golang:1.25 AS builder

ARG KSERVE_VERSION
ARG TARGETOS
ARG TARGETARCH

WORKDIR /go/src/github.com/kserve/kserve

RUN git clone --depth 1 --branch ${KSERVE_VERSION} https://github.com/kserve/kserve.git .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -a -o manager ./cmd/manager

FROM gcr.io/distroless/static:nonroot
COPY --from=builder /go/src/github.com/kserve/kserve/manager /
ENTRYPOINT ["/manager"]
