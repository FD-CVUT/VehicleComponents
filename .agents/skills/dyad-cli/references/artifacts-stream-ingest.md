# `dyad artifacts stream ingest`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts stream ingest`

Ingest NDJSON points from stdin into a new stream

Creates a stream and reads NDJSON points from stdin, pushing them in batches of
`--batch` (default 50). The schema comes from `--schema`, or else the first line
must be `{"$schema": …}`. A `{"$seal": true}` line ends input early.

At end of input the stream is sealed into a content-addressed artifact and `{
stream, sealedArtifact }` is printed as JSON, or with `--on-eof discard` it is
discarded. Progress goes to stderr; `--signals` echoes the named signals of each
point to stdout as NDJSON. `--run` must name a run in the store.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--schema #0` | no | JSON Schema file (else the first line must be {"$schema": …}) |
| `--run #0` | no | Attach the stream to this run |
| `--role #0` | no | Role label for the stream |
| `--signals #0` | no | Comma-separated signals to echo to stdout |
| `--batch #0` | no | Points per push batch |
| `--on-eof #0` | no | What to do at end of input: seal \| discard |

**Examples**

Ingest points and seal:

```
simulate | dyad artifacts stream ingest --run urn:dyad:run:… --role trajectory
```

Ingest with a schema file, echoing two signals:

```
simulate | dyad artifacts stream ingest --schema schema.json --signals t,x
```
