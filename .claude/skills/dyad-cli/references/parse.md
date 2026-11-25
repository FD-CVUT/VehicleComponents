# `dyad parse`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad parse <component>`

export the Dyad AST of a component as JSON

Export the Dyad AST as JSON from a component in a library.

The component is named as `<Library>.<Module>.<Component>`, and the JSON is
written to stdout so it can be piped into other tools -- including `dyad
unparse`, which turns it back into Dyad source.

| Option | Required | Description |
| --- | --- | --- |
| `-d,--dir #0` | no | Directory of the Dyad library |

**Examples**

Print the AST of the Hello component:

```
dyad parse DyadTutorial.Hello --dir DyadTutorial
```

Round-trip a component through its AST:

```
dyad parse DyadTutorial.Hello --dir DyadTutorial | dyad unparse
```
