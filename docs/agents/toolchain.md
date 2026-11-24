# Toolchain: version pin, Dyad upgrades, dependencies, CI

## Version pin

`DYAD_STUDIO_VERSION` in `mise.toml` is the one line that pins the toolchain. It names the Dyad
Studio release (the VSIX on Open VSX) whose compiler generates `generated/`. The Studio and kernel
versions differ: CI installs the Julia build of the kernel that compiler reports, and
`scripts/check-generated` requires `[dyad] kernel` in `Project.toml` to match it.

## Upgrading Dyad

Upgrade only through the Dyad Studio extension, in a PR of its own:

1. Let the extension migrate the project, including the kernel channel in
   `.vscode/settings.json`.
2. Set `DYAD_STUDIO_VERSION` to the installed Studio version.
3. Regenerate `generated/` with `mise run compile`.
4. Commit all of it together.

Done when `mise run check` passes; it fails while the pin, `Project.toml` and `generated/`
disagree. Then recheck the redeclaration rule in `AGENTS.md` (Examples and platforms): Dyad 3.5
ignores a redeclaration written at a declaration site.

## Dependencies

The Dyad build bundles the Dyad standard libraries in its system image, so they need no registry
and no precompiling; every other dependency is in General. That is why CI needs no secret: the
build itself comes from the public JuliaHub juliabin server. A dependency only DyadRegistry serves
(such as DiscreteComponents, unless a Dyad release bundles it) would need a long-term JuliaHub
token, which only a JuliaHub admin issues.

## CI

The workflows in `.github/workflows/` and the `setup-dyad` action are the source of truth for what
runs. `scripts/check-generated` also fails on files left in `generated/` by a deleted module.
