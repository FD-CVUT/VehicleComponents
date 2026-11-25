# `dyad artifacts record-run`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts record-run`

Record a simulation run with role-labeled inputs and outputs

Records a run and prints it as JSON. `--input` and `--output` are repeatable and
take `urn[:role]`. `--parent` records design lineage: this run's parameters were
seeded from that run. `--run-key` stores the DyadWasm run identity so results
join across engines.

Every artifact and run referenced must already exist in the store; otherwise
nothing is recorded and the command fails. `--model` is checked only for being a
model URN, since models are referenced rather than registered. `--params` must
be a JSON object.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--run-key #0` | no | DyadWasm run identity |
| `--model #0` | no | Model URN |
| `--analysis #0` | no | Analysis type |
| `--params #0` | no | Parameter set as JSON |
| `--parent #0` | no | URN of the run whose parameters seeded this one |
| `--input #0` | no | Input artifact reference `urn[:role]` (repeatable) |
| `--output #0` | no | Output artifact reference `urn[:role]` (repeatable) |

**Examples**

Record a transient run:

```
dyad artifacts record-run --analysis transient --params '{"h": 0.7}' --input urn:dyad:artifact:…:mesh --output urn:dyad:artifact:…:trajectory
```
