# syntax=docker/dockerfile:1

# --- build stage: the Rust toolchain, through rustup ------------------------
FROM debian:trixie-slim AS rust
ARG RUST_VERSION

# A heredoc RUN does not stop at the first failing line by itself: every
# script starts with `set -eu`.
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates
rm -rf /var/lib/apt/lists/*
EOF

# rust-src is what rust-analyzer reads the standard library from.
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo
RUN <<EOF
set -eu
curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path \
  --profile minimal \
  --default-toolchain "${RUST_VERSION}" \
  --component rustfmt,clippy,rust-analyzer,rust-src
EOF

# The workload has no RUSTUP_HOME to find a toolchain with, so the rustup
# proxies would not work there: link the toolchain's own binaries instead.
# rustc finds its sysroot from its real path, through the links.
RUN <<EOF
set -eu
toolchain="$(ls -d /usr/local/rustup/toolchains/*)"
mkdir -p /out/usr/local/bin
for bin in cargo rustc rustdoc rustfmt cargo-fmt cargo-clippy clippy-driver rust-analyzer; do
  ln -s "${toolchain}/bin/${bin}" "/out/usr/local/bin/${bin}"
done
# Kept in the overlay at the same path: the links point into it.
mkdir -p /out/usr/local/rustup/toolchains
mv "${toolchain}" /out/usr/local/rustup/toolchains/
EOF

# --- linker stage: what the workload lacks to link, from its own distro ------
# rustc links through `cc`, and build scripts (the cc crate) compile C: the
# shell template has neither gcc nor binutils nor the libc headers. The .deb
# files apt would add to *that* image are unpacked into the overlay, so they
# match its Ubuntu release and the libraries already installed.
FROM docker/sandbox-templates:shell AS linker
USER root
RUN <<EOF
set -eu
apt-get update
apt-get install -y --no-install-recommends --download-only gcc libc6-dev
mkdir -p /out
for deb in /var/cache/apt/archives/*.deb; do
  dpkg-deb -x "${deb}" /out
done
# Set by update-alternatives in a real install, which unpacking skips.
ln -sf gcc /out/usr/bin/cc
rm -rf /out/usr/share/doc /out/usr/share/man /out/usr/share/info /out/usr/share/locale
EOF

# --- overlay: only the toolchain, the links and the C toolchain land ---------
FROM scratch
COPY --from=linker /out/ /
COPY --from=rust /out/ /
