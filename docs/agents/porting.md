# Porting from the course repo

The steps for bringing a component or a whole domain over from the course repo
(dr14-make/16ESPD, package `VehicleSystemsComponents`). The spec, FD-CVUT/VehicleComponents#1,
says under Contents what comes over, what is promoted from lectures, and what stays; the domain's
issue names its components. Work the steps in order, each to its done-condition.

1. **Inventory.** List every course component the issue names, the lecture copies and near-copies
   of each, and the test models, data and icons they use. Done when each candidate has a fate:
   comes over, promoted, merged into another, stays in the course, or deferred.
2. **Promotion.** Check each lecture candidate against the Promotion rule in `AGENTS.md`: ports, a
   real vehicle part, no twin in the library, a test. Done when each one passes all four or is
   marked as staying or deferred, with the failed condition named.
3. **Simplification.** Pair every simple component with its general one and apply the
   Simplification rule. Done when no two components left model the same thing.
4. **Place and name.** Give each component its module path from the module tree and a name by the
   Naming rule. Done when each has its row in `MIGRATION.md`, with a note for every change a
   caller sees (a parameter turned input, a new default, a dropped port).
5. **Source.** Bring the Dyad source over and make it follow the component rules: Connections
   (inputs wired, no `u = time`, no conditional part), Initial conditions on the owner, data as
   `dyad://VehicleComponents/...` with the files in `assets/`. Done when `mise run compile`
   succeeds.
6. **Docstring and icon.** Write the docstring the Docstrings rule asks for and give the
   component its icon by the Icons rule. Done when every public component with ports has both.
7. **Rig.** Write the component's rig in its domain's `Tests` submodule, by
   `docs/agents/tests.md`. Derive each asserted value by hand in the rig's docstring. Done when
   `mise run test` passes and the seeded snapshots are committed.
8. **Layout.** Lay out each component and rig by `docs/agents/layout.md`. Done when no part is
   unplaced and every strict diagram meets the strict layout.
9. **Done.** Work through the Done checklist in `AGENTS.md`. Done when every box holds for every
   component the PR touches.
