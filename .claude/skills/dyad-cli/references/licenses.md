# `dyad licenses`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad licenses`

print the licences and notices of everything dyad includes

Print every licence text and notice that applies to the software distributed as
dyad: dyad's own notice, then the third-party software it includes, then where
to get the source code of the components whose licences require that it be
offered.

The third-party software is every npm package dyad is built from and, in the
standalone binary, the DuckDB library and the Bun runtime it embeds, with the
libraries compiled into them. Components that share a licence text are listed
together, each with its own copyright notices, and the text is printed once.

Each build prints the notices of the code it contains. The npm package prints
those of its installed dependencies. A standalone binary prints those of the npm
packages bundled into it, the Bun runtime, and DuckDB unless that build replaces
it. Each release publishes a binary's notices beside it as <binary>.NOTICES.txt.

**Examples**

Print the licences and notices:

```
dyad licenses
```

Save them alongside a redistributed binary:

```
dyad licenses > THIRD-PARTY-NOTICES.txt
```
