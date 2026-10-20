# syntax=docker/dockerfile:1
# vscode-ssh: the shell template, plus what the VS Code server expects on a
# Remote-SSH host. The template's entrypoint (bash) is kept: VS Code reaches the
# sandbox through the sbx SSH endpoint, not through the entrypoint.
FROM docker/sandbox-templates:shell

USER root

# The VS Code server is a glibc Node.js build: it needs libstdc++, and tar/gzip
# plus curl or wget to unpack (or fetch) itself. procps gives it `ps` for its
# process checks. Most are already in the template; listing them keeps the kit
# working if the template slims down.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libstdc++6 tar gzip curl wget ca-certificates procps git; \
    rm -rf /var/lib/apt/lists/*

USER agent

# Default machine settings for the VS Code server, applied to every Remote-SSH
# window on this sandbox (the user's host settings still win for UI options).
RUN --mount=type=bind,target=/tmp/kit set -eux; \
    install -D -m 0644 /tmp/kit/config/machine-settings.json \
      /home/agent/.vscode-server/data/Machine/settings.json

WORKDIR /home/agent/workspace
