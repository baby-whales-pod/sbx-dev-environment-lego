# syntax=docker/dockerfile:1
# zed-ssh: the shell template, plus what the Zed remote server expects on an SSH
# host. The template's entrypoint (bash) is kept: Zed reaches the sandbox
# through the sbx SSH endpoint, not through the entrypoint.
FROM docker/sandbox-templates:shell

USER root

# The Zed remote server (~/.zed_server) is a Linux binary fetched as a .gz: it
# needs gzip plus curl or wget to download and unpack itself. git is used by the
# project panel and tasks. Most are already in the template; listing them keeps
# the kit working if the template slims down.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libstdc++6 tar gzip curl wget ca-certificates procps git; \
    rm -rf /var/lib/apt/lists/*

USER agent

WORKDIR /home/agent/workspace
