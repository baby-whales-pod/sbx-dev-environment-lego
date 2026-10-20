# syntax=docker/dockerfile:1

# --- build stage: run the official installer, keep only the binary ----------
FROM debian:trixie-slim AS build
ARG CLAUDE_VERSION

RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

# The installer puts the binary under $HOME/.local/share/claude/versions/ and
# symlinks it from $HOME/.local/bin/claude. Copy the real (self-contained)
# executable to /usr/local/bin, so nothing depends on the agent's home.
RUN <<EOF
set -eu
export HOME=/tmp/claude-home
mkdir -p "$HOME"
curl -fsSL https://claude.ai/install.sh | bash -s -- "${CLAUDE_VERSION}"
mkdir -p /out/usr/local/bin
cp -L "$HOME/.local/bin/claude" /out/usr/local/bin/claude
chmod 0755 /out/usr/local/bin/claude
EOF

# --- overlay: only the claude binary lands on the workload -------------------
# A mixin's image config (USER, ENTRYPOINT, CMD) is never kept by the composed
# image, so there is nothing to declare here: start it with `claude`.
FROM scratch
COPY --from=build /out/ /

# First-run answers, so `claude` goes straight to its prompt: theme, onboarding
# and terminal-setup screens already done, and the folder-trust question already
# answered for "/" (it covers every workspace path, the sandbox being the
# isolation). Owned by the agent user (UID 1000): claude rewrites this file.
COPY --chown=1000:1000 config/claude.json /home/agent/.claude.json
