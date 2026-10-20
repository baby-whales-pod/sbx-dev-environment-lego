# syntax=docker/dockerfile:1

# --- build stage: download Go, build gopls with that same Go -----------------
FROM debian:trixie-slim AS build
ARG GO_VERSION
ARG GOPLS_VERSION=latest
ARG TARGETARCH

# A heredoc RUN does not stop at the first failing line by itself: every
# script starts with `set -eu`.
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
set -eu
curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" \
  | tar -C /usr/local -xz
rm -rf /usr/local/go/test
EOF

# Static gopls, installed straight into the overlay tree.
ENV PATH=/usr/local/go/bin:${PATH} \
    CGO_ENABLED=0 \
    GOBIN=/out/usr/local/bin \
    GOFLAGS=-trimpath
RUN <<EOF
set -eu
go install "golang.org/x/tools/gopls@${GOPLS_VERSION}"
ln -s /usr/local/go/bin/go    /out/usr/local/bin/go
ln -s /usr/local/go/bin/gofmt /out/usr/local/bin/gofmt
EOF

# --- overlay: only the toolchain and the binaries land on the workload -------
FROM scratch
COPY --from=build /usr/local/go /usr/local/go
COPY --from=build /out/ /
