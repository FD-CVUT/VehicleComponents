---
name: package-management
description: Ensure all dependencies are present in the workspace before compiling a Dyad package. Load before executing `compile_tool`, when the user asks to compile, or to resolve "Package not found in path" error.
---

# package-management

This skill lives in this library's `agent_resources/skills/package-management/SKILL.md`, next to the documentation and standard library reference it links to. Read that file now and follow it; the paths in it are relative to that file.

If `agent_resources/` is missing -- it is not committed -- restore it by running `dyad install skills --project .` in the library's root.
