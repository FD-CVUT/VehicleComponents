# `dyad document`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad document [library]`

generate Markdown documentation for a library

Generate a Documenter project for a library in `<dir>/docs`, with the Markdown
pages under `<dir>/docs/src`. On success the command prints `wrote <dir>/docs`
on stdout.

HTML documentation can then be rendered from it by running `julia
--project=<library>/docs <library>/docs/make.jl`, which writes into
`<library>/docs/build/`.

The library defaults to the one named by the package in `--dir`.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |
| `--project #0` | no | Path to the Project.toml to use, relative to the current working directory (not the package directory) |
| `--highlight` | no | Enable syntax highlighting in code blocks |

**Examples**

Document the library in the current directory:

```
dyad document
```

Document a named library:

```
dyad document DyadTutorial --dir DyadTutorial
```

Document it without syntax highlighting:

```
dyad document --no-highlight
```
