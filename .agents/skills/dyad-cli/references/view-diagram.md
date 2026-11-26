# `dyad view diagram`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad view diagram <component>`

show a component's diagram in the browser, live

Serve the diagram of a component definition, open it in the default browser, and
redraw it whenever a source file in the library changes. `<component>` is
`<Library>.<Module>.<Component>`, or just the component's name for one at the
top of the library in `--dir`. The problems found while drawing the diagram are
shown on the page, below it.

The page is served on 127.0.0.1 under a random host name, `<id>.localhost`, and
the server answers only requests addressed to that name, so nothing that does
not know it -- another web page the browser has open, or another user of the
machine -- can read the page. Opening the browser does pass the URL to the
system's opener as an argument, which other users of the machine can see while
it runs; pass `--no-open` and open the printed URL yourself to avoid that. The
command prints `serving <what> at <url>` on stdout and runs until you press
Ctrl-C.

When there is no display -- in an SSH session, or on Linux without X11 or
Wayland -- no browser is opened: forward the port with `ssh -L` and open the URL
on your own machine. Pass `--port` to choose the port, so that you know it
before you forward it. Under WSL the page opens in the Windows browser, which
reaches the server through WSL's `localhost` forwarding, with `wslview` if it is
installed and `rundll32.exe` otherwise.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |
| `--port #0` | no | The port to serve on (default: any free port) |
| `--open` | no | Open the page in the default browser (--no-open to only print the URL) |

**Examples**

Show a component's diagram:

```
dyad view diagram SimpleRLC --dir .
```

Serve it on a known port, for forwarding over SSH:

```
dyad view diagram SimpleRLC --dir . --port 8123 --no-open
```
