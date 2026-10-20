# syntax=docker/dockerfile:1

# --- build stage: download the mm binary -----------------------------------
FROM debian:trixie-slim AS build
ARG TARGETARCH
ARG MM_VERSION

RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
set -eu
mkdir -p /out/usr/local/bin
curl -fsSL "https://rickub.com/bots-garden/mini-me/releases/download/${MM_VERSION}/mm-${MM_VERSION#v}-linux-${TARGETARCH}" -o /out/usr/local/bin/mm
chmod 0755 /out/usr/local/bin/mm
EOF

# --- overlay: only the mm binary lands on the workload -----------------------
# A mixin's image config (USER, ENTRYPOINT, CMD) is never kept by the composed
# image, so there is nothing to declare here: start it with `mm -tui`.
FROM scratch
COPY --from=build /out/ /
