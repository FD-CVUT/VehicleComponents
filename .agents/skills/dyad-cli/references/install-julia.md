# `dyad install julia`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad install julia [directory]`

install juliaup and the Julia channel this project needs

Julia: bring this machine to the state `dyad compile` needs -- juliaup
installed, the project's Dyad channel available, and that channel selected. The
channel comes from the `[dyad] kernel` entry in the project's `Project.toml`, so
the project decides what gets installed; `--channel` overrides that.

Dyad channels are published to a JuliaHub versions database rather than the
stock juliaup one, which is why a server is configured alongside them. A server
already configured in the package is kept, since pointing at an internal mirror
is a deliberate choice; `--server` is what replaces it.

Two steps need `--yes`: installing juliaup itself, which downloads and runs an
installer, and installing the channel from a server other than the default that
the package's own settings name, since that server came with the repository
rather than from you. `--server` and `JULIAUP_SERVER` count as your choice.

Every step checks whether it is already done, so running this twice does nothing
the second time. Pass `--dry-run` to see the plan without acting on it.

| Option | Required | Description |
| --- | --- | --- |
| `--dry-run` | no | Report what would be done without doing it |
| `--yes` | no | Allow steps that download and run an installer, or install from a server the package configures |
| `--server #0` | no | The juliaup versions database to install Dyad channels from (default: an already-configured server, else https://juliahub.com/juliabin) |
| `--channel #0` | no | Install this channel instead of the one the project requires |

**Examples**

Show what would be done:

```
dyad install julia --dry-run
```

Set up the current package:

```
dyad install julia --yes
```

Use the internal versions database:

```
dyad install julia --yes --server https://internal.juliahub.com/juliabin
```
