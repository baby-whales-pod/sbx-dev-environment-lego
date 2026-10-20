## Nushell

`nu` is installed (a static binary, `/usr/local/bin/nu`): a shell with structured
(tabular) data instead of plain text — `ls`, `ps`, `open` and pipelines return
typed tables you filter/sort/reshape with `where`, `sort-by`, `select`, `get`,
instead of piping through `grep`/`awk`/`cut`. It is not the sandbox's login
shell; invoke it explicitly (`nu -c '...'` or `nu script.nu`) when structured
data handling helps, otherwise keep using bash.
