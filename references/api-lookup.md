# API lookup in the decompiled source

`$TOOLS/src/` is the ground truth. Grep it; do not rely on memory.

```
grep -rn "class LordToil\b" $TOOLS/src
grep -n "public .*MakeNewLord" $TOOLS/src/Verse.AI.Group/LordMaker.cs
```

## Folder layout quirks (1.6.4871)

Namespaces map to folders: `Verse/`, `Verse.AI/`, `Verse.AI.Group/`, `RimWorld/`, `RimWorld.Planet/`, `LudeonTK/`. Some files are not where the namespace suggests:

- `LetterDef`, `MapGeneratorDef`, `GenStepDef`, `PawnGenerator`, `PawnGenerationRequest`, `ThingDef`, `Def`, `Game`, `GameComponent`, `MapPawns`, `ListerBuildings` are under `Verse/`.
- `DutyDef`, `PawnDuty`, `JobGiver_Wander`, `JobGiver_WanderAnywhere`, `JobDriver_*`, `AttackTargetFinder`, `Toils_Combat` are under `Verse.AI/`.
- `Lord`, `LordJob`, `LordToil`, `LordManager`, `LordMaker` are under `Verse.AI.Group/`.
- `TerrainAffordanceDefOf`, `JobDefOf`, `LetterDefOf`, `Faction`, `FactionDef`, `FactionGenerator`, `FactionManager`, `JobGiver_AI*`, `WealthWatcher`, `Need_*`, `ThoughtWorker_Hediff`, `Pawn_ApparelTracker`, `CompQuality` are under `RimWorld/`.
- `MapParent` is under `RimWorld.Planet/`.
- Debug actions: `[DebugAction]` is in `LudeonTK`.

## Names that differ from older versions

| Old or guessed | Actual 1.6 |
|---|---|
| `Thing.Health` | `Thing.HitPoints` |
| `LordMaker.MakeLord` | `LordMaker.MakeNewLord(Faction, LordJob, Map, IEnumerable<Pawn>)` |
| `Verse.MapGen` | `Verse.MapGenerator` |
| `ThingDef.MarketValue` | `ThingDef.BaseMarketValue` (`Thing.MarketValue` does exist) |
| `Pawn.IsBeingCarried` | `pawn.CarriedBy != null` |
| `MapPawns.AllPawnsSpawned` returns `List<Pawn>` | returns `IReadOnlyList<Pawn>` |
| `DutyDefOf.AssaultThing` | exists but is `[MayRequireRoyalty]`: null without the DLC |
| `baseMoodEffect` on `ThoughtDef` | it is on `ThoughtStage` |

## Useful verification greps

- Faction fields scribed or not: `Scribe_Values.Look` in `RimWorld/Faction.cs`.
- Whether an XML field is translatable: `[MustTranslate]` / `[NoTranslate]` on the field. `[NoTranslate]` and `[Unsaved]` throw a hard error if you inject into them.
- Whether a field exists on a def at all: grep `public <type> <name>;` in the def's class, e.g. `FactionDef.cs`.
- Def validation messages (the "Config error in ..." lines in `Player.log`): grep `ConfigErrors` in the def's class.
- Vanilla XML for patterns to copy: `<RimWorld>/Data/Core/Defs/...` (DutyDefs, FactionDefs, PawnKindDefs, ThingDefs).

## Game log

`~/AppData/LocalLow/Ludeon Studios/RimWorld by Ludeon Studios/Player.log` (Windows). Grep it for your mod prefix and for `Exception`. Many `XML error` lines come from other mods and DLC and are unrelated.
