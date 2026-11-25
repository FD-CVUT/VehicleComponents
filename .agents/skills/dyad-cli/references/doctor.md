# `dyad doctor`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad doctor [directory]`

diagnose this machine's Julia setup and JuliaHub sign-in

Check that everything `dyad compile` depends on is present and consistent, and
report what is not.

The compiler needs a working Julia, and which Julia it uses is decided by three
mechanisms in order: the `JULIA_EXECUTABLE` environment variable, the package's
`.vscode/settings.json`, and finally whatever `julia` is on `PATH`.
`JULIA_EXECUTABLE`, like the settings' `julia.executablePath`, may carry
arguments after the executable, separated by spaces (`julia +1.10`); a value
that names an existing file is used whole, so a path containing a space works; a
relative path such as `tools/julia` is taken from the package directory; on
Windows the `.exe` may be left off. Quotes around the whole value, which `cmd`'s
`set` keeps, are removed. A settings file that cannot be parsed is skipped
silently, so this command reports which mechanism is actually in effect.

It also checks the Julia channel. A project names the Dyad kernel it needs in
the `[dyad]` section of its `Project.toml`, and the juliaup channel carrying
that kernel is `dyad-<version>`. The check compares what the project requires
against what juliaup has installed and what the settings select.

And it checks the JuliaHub sign-in that `dyad auth` and JuliaHub's `jh` tool
share: whether there is one, whether its token has expired, and whether Julia's
package manager has a copy it can use -- one that has not expired, for the
server `JULIA_PKG_SERVER` names. These are warnings, since public packages
install without one.

Nothing here modifies anything, refreshes a token, or touches the network. Use
`dyad install julia` and `dyad auth` to fix what it reports.

The exit status is 1 only when an error was found; warnings and informational
findings report 0.

| Option | Required | Description |
| --- | --- | --- |
| `--json` | no | Report findings as JSON instead of text |

**Examples**

Diagnose the package in the current directory:

```
dyad doctor
```

Diagnose a specific package:

```
dyad doctor MyLib
```

Emit findings for CI to consume:

```
dyad doctor --json
```
