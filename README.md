# rimworld-modding (Claude Code skill)

Condensed, verified notes for building RimWorld 1.6 C# mods without re-reading docs each time. Written from a complete mod build, with every API claim checked against the decompiled `Assembly-CSharp`.

## Install

Copy this folder to `~/.claude/skills/rimworld-modding/` (or a project's `.claude/skills/`). Claude loads `SKILL.md` and reads a `references/` file only when the task needs it, which keeps token use small.

## One-time tool setup

```
RIMWORLD="<game folder>" TOOLS=~/totools bash scripts/setup-tools.sh
```
Downloads the Roslyn compiler and ILSpy, and decompiles the game to `$TOOLS/src` (about 9,200 files) for API lookup. Re-run after a game update.

## Contents

- `SKILL.md`: rules and an index of which reference to read.
- `references/`: toolchain, API lookup, extension points (no Harmony), Lord/Duty AI, map generation and lifecycle, defs and XML, localization, gameplay snippets, symptom-to-cause table.
- `scripts/`: `setup-tools.sh`, `build.sh`, `validate_mod.py`.

Verified against RimWorld 1.6.4871 (Assembly-CSharp 1.6.9676). Behavior that only shows in game is marked as unverified where it applies.
