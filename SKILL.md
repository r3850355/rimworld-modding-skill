---
name: rimworld-modding
description: Build, debug and localize RimWorld 1.6 C# mods without reading docs from scratch. Use when creating or changing a RimWorld mod (Defs XML, ThingComp, Building, GenStep, Lord/Duty AI, ModSettings, DefInjected translations), when checking a game API signature against the decompiled Assembly-CSharp, or when compiling a mod offline without Visual Studio or Harmony.
---

# RimWorld 1.6 modding

Verified facts and gotchas from a full mod build. Read only the reference file for the task at hand; do not load them all.

## Rules that save the most time

1. **Never guess an API. Grep the decompiled source** (set up once with `scripts/setup-tools.sh`). Older-version knowledge is often wrong: it is `Thing.HitPoints` (not `Health`), `LordMaker.MakeNewLord` (not `MakeLord`), `Verse.MapGenerator` (not `MapGen`).
2. **Prefer real extension points over Harmony.** Many installs ship no `0Harmony.dll`. See `references/extension-points.md`.
3. **Validate before launching the game:** `python scripts/validate_mod.py <mod root>` (XML parse, duplicate defNames, translation-key symmetry, DefInjected layout).
4. **A running game locks the output DLL** (`CS2012`). Compile to a temp path to check code, then rebuild after the game is closed.

## Which file to read

| Task | File |
|---|---|
| Set up tools, compile, decompile, shell quirks on Windows | `references/toolchain.md` |
| Find a class or method, decompile layout quirks | `references/api-lookup.md` |
| Hook behavior without Harmony | `references/extension-points.md` |
| Pawn AI: Lord, LordToil, DutyDef, JobGiver, raids, guards | `references/lords-and-ai.md` |
| Map generation, GenStep order, placing structures, game-start state | `references/mapgen-and-lifecycle.md` |
| ThingDef, HediffDef, ThoughtDef, FactionDef, PawnKindDef, textures, shadows | `references/defs-and-xml.md` |
| Translations, DefInjected, Keyed | `references/localization.md` |
| Needs, gear, letters, settings, name colour | `references/gameplay-snippets.md` |
| Symptom to cause lookup | `references/pitfalls.md` |

## Workflow

1. Check `references/pitfalls.md` for the symptom first; most bugs on this list recur.
2. Verify any API you are unsure of in the decompiled source (`references/api-lookup.md`).
3. Write code, compile (`scripts/build.sh`), run `scripts/validate_mod.py`.
4. Anything that only shows in game (AI behavior, map generation timing) cannot be verified offline. Say so, and ask for a log line or a `Log tower pawns`-style debug dump instead of guessing.
