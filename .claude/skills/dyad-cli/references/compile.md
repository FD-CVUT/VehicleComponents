# `dyad compile`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad compile [directory]`

compile Dyad files into Julia source

Compile the Dyad files in `./dyad` of the specified Julia package.

The path to the package is given as the argument, and the Dyad files are
expected to be in the `./dyad` directory of that package. The generated Julia
code is written into `./generated` of the same package. The entry file that
`dyad create` writes, `./src/<Package>.jl`, includes it, so the package can be
loaded with `using <Package>` once compilation succeeds.

Once the generated code is written, the command names each generated file on
stdout with what happened to it: `wrote <file>` when it was new or its contents
changed, `skipped <file> (byte identical)` when it already held exactly what
would have been written and was left untouched, and `deleted <file>` when it is
no longer generated. Leaving an identical file alone keeps its modification
time, so tools that watch `./generated`, such as Revise, see only real changes.
When compilation reports an error, nothing is generated and nothing is printed
on stdout; the one exception is a failure while writing the generated files,
which is reported as an error after some of them may have been written.

With `--watch`, the compiler stays running and recompiles whenever a `.dyad` or
`.toml` file under the package changes, printing the same lines after each pass
that succeeds. The process stays alive until interrupted.

| Option | Required | Description |
| --- | --- | --- |
| `--debug #0` | no | debug pattern (e.g., "workspace:init" or "codegen:mtk" or "*") |
| `--project #0` | no | Path to the Project.toml to use, relative to the current working directory (not the package directory) |
| `-w,--watch` | no | Watch for file changes and recompile |

**Examples**

Compile the DyadTutorial package living in ./DyadTutorial:

```
dyad compile DyadTutorial
```

Compile the package in the current directory:

```
dyad compile
```

Recompile whenever a source file changes:

```
dyad compile --watch
```
