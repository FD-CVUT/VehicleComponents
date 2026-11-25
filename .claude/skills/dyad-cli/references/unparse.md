# `dyad unparse`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad unparse`

read an AST as JSON and unparse it into Dyad source

Read the Dyad AST as JSON from stdin and unparse it into Dyad source code,
written to stdout.

This is the inverse of `dyad parse`, so the two compose into a round trip.

Input that is not an AST as `dyad parse` prints it is rejected, naming the first
node or field that is missing, mistyped or of an unknown kind, with its path in
the JSON. Input that is empty, or is not JSON, is rejected the same way, saying
what was expected; for input that is not JSON, the JSON parser's own message
follows. Fields the unparser does not read, such as spans, may be left out.

**Examples**

Round-trip a component through its AST:

```
dyad create DyadTutorial; dyad parse DyadTutorial.Hello --dir DyadTutorial | dyad unparse
```
