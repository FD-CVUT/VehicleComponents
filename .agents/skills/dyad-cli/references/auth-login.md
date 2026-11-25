# `dyad auth login`

Part of the [`dyad-cli`](../SKILL.md) skill.

## `dyad auth login`

sign in to JuliaHub

Sign in with JuliaHub's device flow: this prints a URL to open in a browser,
where you approve the sign-in, and waits until you have.

The login is stored exactly where and how JuliaHub's `jh` tool stores it: in
`~/.juliahub`, readable only by you, and in `<depot>/servers/<server>/auth.toml`
(the depot is the first entry of `JULIA_DEPOT_PATH`, else `~/.julia`), where
Julia's package manager reads it. Either tool can use a login made by the other.

The server is the one `--server` names, else the one you last signed in to, else
`juliahub.com`. A bare name is a JuliaHub subdomain, so `--server acme` means
`acme.juliahub.com`, and a URL means its host, so `--server
https://acme.juliahub.com/` does too.

| Option | Required | Description |
| --- | --- | --- |
| `-s,--server #0` | no | The JuliaHub server to sign in to (default: the last one used, else juliahub.com) |

**Examples**

Sign in to JuliaHub:

```
dyad auth login
```

Sign in to a JuliaHub instance:

```
dyad auth login --server acme
```
