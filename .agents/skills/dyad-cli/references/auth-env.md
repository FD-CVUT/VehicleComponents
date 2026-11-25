# `dyad auth env`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad auth env`

print the JuliaHub login as environment variables

Print `JULIAHUB_HOST`, `JULIAHUB_PORT`, `JULIAHUB_ID_TOKEN`,
`JULIAHUB_ID_TOKEN_EXPIRES` and the matching `INVOCATION_*` variables, one
assignment per line, refreshing the token first if it has expired. These are the
variables `jh auth env` prints, but each value is single-quoted, so the output
is safe to `eval` whatever the server put in the token.

This prints the token itself, so that another tool can use it: do not paste its
output anywhere public.

**Examples**

Export the login to the shell:

```
eval "$(dyad auth env)"
```
