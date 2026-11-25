# `dyad format`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad format <file_or_directory>`

format Dyad source files in place

Format every `.dyad` file in one or more files or whole directories. Directories
are searched recursively, so nested sources are not skipped.

Every file is parsed and formatted before any of them is written, and no file is
changed if any file has an error, so a failed run never leaves some files
formatted and others not. Each formatted file is first written to a sibling
temporary file and flushed to disk, and the temporary files are renamed into
place only once all of them are written, so a failed write leaves every source
file untouched.

Each file that formatting changed is named on stdout as `wrote <file>`. A file
that is already formatted is not rewritten. When it found files but changed
none, the command prints `unchanged <file_or_directory>` instead, with a
trailing `/` when it was given a directory.

Pass `--dryrun` to print the formatted result to stdout instead of writing it
back.

| Option | Required | Description |
| --- | --- | --- |
| `-n,--dryrun` | no | Write the formatted output to stdout instead of the file |
| `-i,--inline` | no | Use inline metadata |

**Examples**

Format an entire library:

```
dyad format MyLib
```

Preview the formatting of one file:

```
dyad format MyLib/dyad/Hello.dyad --dryrun
```
