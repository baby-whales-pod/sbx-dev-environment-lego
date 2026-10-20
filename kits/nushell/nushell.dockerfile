# syntax=docker/dockerfile:1

# --- build stage: download the static (musl) nu binary ---------------------
FROM debian:trixie-slim AS build
ARG NUSHELL_VERSION
ARG TARGETARCH

# A heredoc RUN does not stop at the first failing line by itself: every
# script starts with `set -eu`.
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

# The musl build is statically linked, so it runs unmodified on whatever
# base image (glibc or musl) the overlay lands on, unlike the gnu build,
# which would be tied to this build stage's own glibc.
RUN <<EOF
set -eu
case "${TARGETARCH}" in
  amd64) arch=x86_64 ;;
  arm64) arch=aarch64 ;;
  *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;;
esac
mkdir -p /out/usr/local/bin
curl -fsSL "https://github.com/nushell/nushell/releases/download/${NUSHELL_VERSION}/nu-${NUSHELL_VERSION}-${arch}-unknown-linux-musl.tar.gz" \
  | tar -xz -C /out/usr/local/bin --strip-components=1 "nu-${NUSHELL_VERSION}-${arch}-unknown-linux-musl/nu"
chmod 0755 /out/usr/local/bin/nu
EOF

# --- overlay: only the nu binary lands on the workload -----------------------
FROM scratch
COPY --from=build /out/ /
