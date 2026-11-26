# `dyad install`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad install [directory]`

install everything this machine needs: Julia and the agent skills

Run both `dyad install julia` and `dyad install skills`. The two are
independent: a Julia step that stops for consent does not stop the skill from
being installed.

Every step checks whether it is already done, so running this twice does nothing
the second time. Pass `--dry-run` to see the plan without acting on it.

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

Skills: install the `dyad-cli` skill, which teaches a coding agent to use this
CLI. It is generated from this CLI's own commands, so it always describes the
version that installed it. It goes into `~/.claude/skills` for Claude Code and
`~/.agents/skills` for Codex, or, with `--project <dir>`, into that project's
`.claude/skills` and `.agents/skills`.

A project install into a Dyad library also brings the library's agent resources
up to date: the Dyad documentation, standard library reference and skills in
`agent_resources/`, which `dyad create` installs and which are not committed,
plus a pointer to each of those skills in `.claude/skills` and `.agents/skills`.

| Option | Required | Description |
| --- | --- | --- |
| `--dry-run` | no | Report what would be done without doing it |
| `--yes` | no | Allow steps that download and run an installer, or install from a server the package configures |
| `--server #0` | no | The juliaup versions database to install Dyad channels from (default: an already-configured server, else https://juliahub.com/juliabin) |
| `--channel #0` | no | Install this channel instead of the one the project requires |
| `--project #0` | no | Install the skill into this project's .claude/skills and .agents/skills instead of your home directory |

**Examples**

Show what would be done:

```
dyad install --dry-run
```

Set up the current package and install the skill:

```
dyad install --yes
```
