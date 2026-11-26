# `dyad artifacts retention add`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts retention add`

Add a retention rule

Adds a rule and prints it as JSON. `--selector` is required: a JSON selector
such as `{"kind":"class","class":"derived"}` or `{"kind":"urn","urn":"…"}`.
`--seconds` is how long matching artifacts are kept after creation; omit it to
keep them indefinitely. Artifacts no rule matches are kept indefinitely. A `urn`
selector must name an artifact in the store.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |
| `--selector #0` | yes | Rule selector as JSON |
| `--seconds #0` | no | Retention seconds after creation (omit for indefinite) |
| `--description #0` | no | Description of the rule |

**Examples**

Keep derived data for two days:

```
dyad artifacts retention add --selector '{"kind":"class","class":"derived"}' --seconds 172800 --description "derived data kept 2 days"
```

Pin one artifact forever:

```
dyad artifacts retention add --selector '{"kind":"urn","urn":"urn:dyad:artifact:…"}'
```
