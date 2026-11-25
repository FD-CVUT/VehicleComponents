# `dyad snapshot`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad snapshot [directory]`

capture a workspace and its dependencies into a zip file

Capture a workspace into a single zip file.

The snapshot holds the Dyad sources, assets, `Project.toml` and `Manifest.toml`
of the given package and of every dependency that is itself a Dyad component
library, along with the built-in Dyad library, so the snapshot reproduces
exactly what was loaded.

Generated Julia code is not captured by default, since it can be regenerated
from the sources that are. Pass `--extended` to include it, which is worth doing
when the generated code is itself what is under investigation.

The file is named `<Package>-<hash>.zip`, where the hash is taken over the
contents of the snapshot, so two snapshots share a name only when they hold the
same content. An existing file of that name is replaced.

A snapshot is a frozen reproduction: it is meant for bug reports, fixtures and
sharing a state to look at, and a workspace loaded from one is read-only.

| Option | Required | Description |
| --- | --- | --- |
| `--debug #0` | no | debug pattern (e.g., "workspace:init" or "codegen:mtk" or "*") |
| `--project #0` | no | Path to the Project.toml to use, relative to the current working directory (not the package directory) |
| `-o,--output #0` | no | Directory to write the snapshot into |
| `-e,--extended` | no | Also capture the generated Julia code under generated/ |

**Examples**

Snapshot the package in the current directory:

```
dyad snapshot
```

Snapshot a package into ./reports:

```
dyad snapshot MyLib -o reports
```

Include the generated Julia code in the snapshot:

```
dyad snapshot MyLib --extended
```
