# Multi-stage build for the KServe controller.
# Fetches upstream source at the pinned version and cross-compiles for the target platform.
ARG KSERVE_VERSION=v0.16.0

FROM --platform=$BUILDPLATFORM golang:1.24 AS builder

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
