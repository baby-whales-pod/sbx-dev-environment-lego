# syntax=docker/dockerfile:1

# --- build stage: download the docker-agent binary -------------------------
FROM debian:trixie-slim AS build
ARG DOCKER_AGENT_VERSION
ARG TARGETARCH

RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

# The release assets are plain static binaries named docker-agent-linux-<arch>
# (amd64, arm64), which TARGETARCH already spells.
RUN <<EOF
set -eu
mkdir -p /out/usr/local/bin
curl -fsSL "https://github.com/docker/docker-agent/releases/download/v${DOCKER_AGENT_VERSION}/docker-agent-linux-${TARGETARCH}" \
  -o /out/usr/local/bin/docker-agent
chmod 0755 /out/usr/local/bin/docker-agent
EOF

# --- overlay: only the docker-agent binary lands on the workload -------------
# A mixin's image config (USER, ENTRYPOINT, CMD) is never kept by the composed
# image, so there is nothing to declare here: start it with `docker-agent run`.
FROM scratch
COPY --from=build /out/ /
