# `dyad auth status`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad auth status`

show whether you are signed in to JuliaHub

Show the stored login: the server, whether the token is still valid, when it was
issued and expires, whether it can be refreshed, and whose it is. No token is
printed, and nothing is refreshed.

The exit status is 1 when there is no stored login.

**Examples**

Show the login:

```
dyad auth status
```
