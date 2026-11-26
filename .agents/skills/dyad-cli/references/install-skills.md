# `dyad install skills`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad install skills`

install the skill that teaches coding agents to use this CLI

Skills: install the `dyad-cli` skill, which teaches a coding agent to use this
CLI. It is generated from this CLI's own commands, so it always describes the
version that installed it. It goes into `~/.claude/skills` for Claude Code and
`~/.agents/skills` for Codex, or, with `--project <dir>`, into that project's
`.claude/skills` and `.agents/skills`.

A project install into a Dyad library also brings the library's agent resources
up to date: the Dyad documentation, standard library reference and skills in
`agent_resources/`, which `dyad create` installs and which are not committed,
plus a pointer to each of those skills in `.claude/skills` and `.agents/skills`.

Every step checks whether it is already done, so running this twice does nothing
the second time. Pass `--dry-run` to see the plan without acting on it.

| Option | Required | Description |
| --- | --- | --- |
| `--dry-run` | no | Report what would be done without doing it |
| `--project #0` | no | Install the skill into this project's .claude/skills and .agents/skills instead of your home directory |

**Examples**

Install the skill for your user:

```
dyad install skills
```

Install it into a library, and refresh its agent resources:

```
dyad install skills --project .
```
