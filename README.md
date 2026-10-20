# sbx-dev-environment-lego
> Dev Environment Lego: Snap It Together

Brick by Brick: Building Your Dev Environment with Docker Sandbox Kits.

## I want ...

### VSCode + Rust + Claude

Create a `sbxenv.vscode.yaml` file:

```yaml
schemaVersion: "1"

name: code-dev-env

agent: vscode-ssh

kits:
  - ./kits/vscode-ssh
  - ./kits/nushell
  - ./kits/claude-code
  - ./kits/rust-toolchain

workspace: ./demo

# https://docs.docker.com/ai/sandboxes/configuration/environment-files/
# sbx setup ssh
```

Run:
```bash
sbx env create -f sbxenv.vscode.yaml --force
code --new-window --remote ssh-remote+code-dev-env.sbx $PWD/demo
# stop:
# sbx env rm -f sbxenv.vscode.yaml --force
```


### Zed Editor + Golang + Docker Agent


Create a `sbxenv.zed.yaml` file:

```yaml
schemaVersion: "1"

name: zed-dev-env

agent: zed-ssh

# Relative paths resolve against the directory of this file.
kits:
  - ./kits/zed-ssh
  - ./kits/nushell
  - ./kits/docker-agent
  - ./kits/go-toolchain

workspace: ./demo

# https://docs.docker.com/ai/sandboxes/configuration/environment-files/
# sbx setup ssh
```

Run:
```bash
sbx env create -f sbxenv.zed.yaml --force
zed --new ssh://zed-dev-env.sbx$PWD/demo
# stop:
# sbx env rm -f sbxenv.zed.yaml --force
```
