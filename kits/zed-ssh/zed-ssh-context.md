This sandbox is driven from the Zed editor running on the host, connected over SSH through the sbx
SSH endpoint (`<sandbox-name>.sbx`, Zed remote development). Nothing graphical runs here.

The Zed remote server lives in `~/.zed_server`. The host workspace is mounted at the same path
as on the host. Network access is limited by the sandbox policy: the Zed server download hosts
are allowed, other hosts must be allowed with `sbx policy allow network <host>` on the host.
