## Rust

`cargo`, `rustc`, `rustfmt`, `clippy` and `rust-analyzer` are installed
(`/usr/local/rustup`), with `gcc` as the linker. Run `cargo build`, `cargo test`
and `cargo clippy` before reporting a task complete; format with `cargo fmt`.
Prefer `rust-analyzer` for navigation and refactoring (definitions, references,
rename) over text search. There is no `rustup`: the toolchain version is fixed
by the kit. Crates come from crates.io; other hosts may be blocked.
