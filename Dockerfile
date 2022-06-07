#ARG BUILDER_IMAGE=index.docker.io/library/golang@sha256:634cda4edda00e59167e944cdef546e2d62da71ef1809387093a377ae3404df0
ARG BUILDER_IMAGE=golang:1.17-bullseye
ARG RUNTIME_IMAGE=gcr.io/distroless/static-debian11

FROM $BUILDER_IMAGE as builder

WORKDIR /workspace

COPY .git .git
COPY go.mod go.mod
COPY go.sum go.sum
COPY pkg/ pkg/
COPY cmd/ cmd/

RUN set -x && CGO_ENABLED=0 GOOS=linux GO111MODULE=on \
        go build -a -v \
        -trimpath \
        -tags osusergo,netgo,static_build \
        -o monero-exporter \
        ./cmd/monero-exporter

FROM $RUNTIME_IMAGE

WORKDIR /
COPY --chown=nonroot:nonroot --from=builder /workspace/monero-exporter .
USER nonroot:nonroot

ENTRYPOINT ["/monero-exporter"]
