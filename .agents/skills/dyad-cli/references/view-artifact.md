# `dyad view artifact`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad view artifact <urn>`

show an artifact from the store in the browser

Serve an artifact from the artifact store (see `dyad artifacts`) and open it in
the default browser. How it is shown depends on its media type, which is
declared when the artifact is added (`dyad artifacts add --media-type`):

- `application/vnd.dyad.web-bundle+zip`: a zip holding a web page, with
  `index.html` at its root. Its files are served at the root of the server. The
  page's script runs in your browser, so view only bundles whose author you
  trust. The server lets it load and fetch only from the server itself.

- `application/vnd.dyad.time-series`: a DyadArtifacts result file, shown in the
  artifact viewer, which lists the visualizations the file describes and draws
  the one you pick. The browser loads DuckDB-Wasm and the plotting libraries
  from jsDelivr, so it needs to reach the internet.

- `image/png`, `image/jpeg`, `image/gif`, `image/webp` and `image/svg+xml`: the
  image, served at the root.

An artifact of any other media type is refused. The store is the one `--config`
names, else the one whose `dyad-store.json` is nearest the working directory.

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
| `-c,--config #0` | no | The store's config file (default: the nearest dyad-store.json) |
| `--port #0` | no | The port to serve on (default: any free port) |
| `--open` | no | Open the page in the default browser (--no-open to only print the URL) |

**Examples**

Show an artifact:

```
dyad view artifact urn:dyad:artifact:sha256-0123…
```
