This sandbox is driven from VS Code running on the host, connected over SSH through the sbx
SSH endpoint (`<sandbox-name>.sbx`, VS Code Remote-SSH). Nothing graphical runs here.

The VS Code server lives in `~/.vscode-server`. The host workspace is mounted at the same path
as on the host. Network access is limited by the sandbox policy: the VS Code server download
hosts and the extension marketplaces are allowed, other hosts must be allowed with
`sbx policy allow network <host>` on the host.
