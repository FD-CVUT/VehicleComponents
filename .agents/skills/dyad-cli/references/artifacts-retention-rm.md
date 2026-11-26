# `dyad artifacts retention rm`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad artifacts retention rm <urn>`

Delete a retention rule

Deletes the rule with this URN. Fails if the store has no such rule.

| Option | Required | Description |
| --- | --- | --- |
| `-c,--config #0` | no | Path to dyad-store.json (default: the nearest one above the working directory) |

**Examples**

Delete a rule:

```
dyad artifacts retention rm urn:dyad:policy:…
```
