# `dyad artifacts stream subscribe`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts stream subscribe <urn>`

Subscribe to a stream until it seals

Emits the stream's points as NDJSON on stdout until it seals or is discarded.
`--replay` chooses which existing points are sent first: `all` (default), `none`
or `last:N`. `--since` resumes after a sequence number.

Live points reach only subscribers in the process that writes them, and only one
process can open a store at a time, so for a stream that is still open this
prints the points recorded so far, says so on stderr, and exits 0. Follow a live
stream over the HTTP API instead. Fails if the store has no such stream.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--replay #0` | no | all \| none \| last:N |
| `--since #0` | no | Resume from this sequence number |
| `--signals #0` | no | Comma-separated signal subset |

**Examples**

Follow a stream from the start:

```
dyad artifacts stream subscribe urn:dyad:stream:…
```

Follow only new points of two signals:

```
dyad artifacts stream subscribe urn:dyad:stream:… --replay none --signals t,x
```
