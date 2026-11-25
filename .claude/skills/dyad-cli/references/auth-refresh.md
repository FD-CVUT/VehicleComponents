# `dyad auth refresh`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad auth refresh`

refresh the JuliaHub token now

Exchange the stored refresh token for a new token, whether or not the current
one has expired, and write it to both places the login is kept.

`dyad auth env` refreshes an expired token by itself, but Julia's package
manager cannot refresh this one, so run this when `dyad doctor` reports that the
token has expired.

The login is stored exactly where and how JuliaHub's `jh` tool stores it: in
`~/.juliahub`, readable only by you, and in `<depot>/servers/<server>/auth.toml`
(the depot is the first entry of `JULIA_DEPOT_PATH`, else `~/.julia`), where
Julia's package manager reads it. Either tool can use a login made by the other.

**Examples**

Refresh the token:

```
dyad auth refresh
```
