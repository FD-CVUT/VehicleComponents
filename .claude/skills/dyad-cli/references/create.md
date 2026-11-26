# `dyad create`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad create <package>`

create a template Dyad component library

Create a template Dyad component library, with a pre-defined `Hello` component
and `World` analysis.

The library is written to `<dir>/<package>`, so `dyad create Hello` creates a
directory called `Hello` inside the current directory. The command prints `wrote
<dir>/<package>` on stdout once it is written and, when the initial compilation
succeeds, the lines `dyad compile` prints for the code it generated.

This is a full Julia package with a `Project.toml` file, a `src/` directory, and
a `dyad/` directory holding the Hello component and World analysis. You can then
use `Pkg.dev("<dir>/<package>")` in Julia to make the package available and load
it with `using <package>`.

The library also gets the Dyad agent resources -- the language documentation,
standard library reference and skills the Dyad Agent uses -- in
`agent_resources/`, which is not committed, and a pointer to each of those
skills in `.claude/skills` and `.agents/skills`, where Claude Code and Codex
look for them. Pass `--no-agent-resources` to leave them out; `dyad install
skills --project <dir>` adds or refreshes them later.

The library is always written to disk before compilation is attempted, so a
non-zero exit status means the initial compilation failed even though the
library itself was created.

| Option | Required | Description |
| --- | --- | --- |
| `--debug #0` | no | debug pattern (e.g., "workspace:init" or "codegen:mtk" or "*") |
| `-d,--dir #0` | no | Directory to create the library in |
| `--agent-resources` | no | Install the Dyad agent resources and their skills (default: true) |

**Examples**

Create a library called DyadTutorial:

```
dyad create DyadTutorial
```

Create it inside ./libraries:

```
dyad create DyadTutorial --dir libraries
```

Create it without the agent resources:

```
dyad create DyadTutorial --no-agent-resources
```
