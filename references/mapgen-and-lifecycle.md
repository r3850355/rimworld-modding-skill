# Map generation and game lifecycle

## GenStep order (Base_Player)

10 to 100 grids, 200 to 300 terrain, 390 roads, 400 to 500 critical structures, 700 to 800 non-critical structures, **750 ScatterRuinsSimple, 850 FindPlayerStartSpot, 875 ScenParts, 900 Plants, 950 SteamGeysers, 960 AncientMiscDebris, 970 RockChunks**, 1120 CaveHives, 1150 Snow, 1200 Animals, 1500 Fog, 1600 MutatorFinal, 1700 GravshipMarker.

Register yours with an XML patch:

```xml
<Patch><Operation Class="PatchOperationAdd">
  <xpath>Defs/MapGeneratorDef[defName="Base_Player"]/genSteps</xpath>
  <value><li>MY_GenStepDefName</li></value>
</Operation></Patch>
```

## Placing a structure

- Colony centre: `MapGenerator.PlayerStartSpotValid ? MapGenerator.PlayerStartSpot : map.Center`.
- **Register the footprint** so later scatter steps do not delete it: `MapGenerator.GetOrGenerateVar<List<CellRect>>("UsedRects").Add(rect.ExpandedBy(1))`. `GenStep_ScatterThings.ScatterAt` calls `GetEdifice(map)?.Destroy()` over its clear-space lump; steam geysers (950) and rock chunks (970) run after a step at 860.
- **Do a full scan, not random sampling.** Sampling 400 random cells and testing a 3x3 footprint fails on cramped maps, so the structure never appears. Build a per-cell "clear" array once, find every valid footprint, then pick one. Tier the distance requirement (60, 45, 30, 18 cells) rather than failing.
- Pick uniformly among valid cells. Ranking by "farthest from centre" pins things to a map corner.
- `terrainAffordanceNeeded` is only enforced for player-placed buildings. A spawned building needs its own terrain check (match the def; `Heavy` fails on sand and ice, `Light` is safer).
- Letters and pawn generation are not usable during map generation. Do them on the first `TickRare` after the map is live (guard with a saved `introDone` flag).
- Players only: `map.Parent.Faction == Faction.OfPlayer && map.Parent.def.canBePlayerHome && !map.IsPocketMap`.

## Static state survives new games

Statics persist until the program exits. `Map.uniqueID` restarts at 0 in a new game, so a static `HashSet<int>` of "maps that have a tower" makes the second game after returning to the menu skip generation. Fix both parts:
1. Decide "already has one" from the map's actual contents (`listerThings.ThingsOfDef`), not a static set.
2. Reset every static in a `GameComponent` **constructor** (one is built per `Game`, for both new games and loads).

Static cooldowns keyed on `GenTicks.TicksGame` also break on loading an older save (negative delta). Treat a negative delta as expired.

## GameComponent

Auto-discovered via `typeof(GameComponent).AllSubclassesNonAbstract()`, needs a constructor taking `Game`. Hooks: `StartedNewGame`, `LoadedGame`, `FinalizeInit` (a new game reaches `FinalizeInit` during `InitNewGame`; a load reaches `LoadedGame`), `GameComponentTick`, `ExposeData`. Implement both load hooks if you migrate state.

## Faction state in saves

`Faction.Name` is a scribed field, set once to `FactionDef.fixedName` at creation, so the creation-time language is frozen into the save. Null it after load so `Faction.Name` falls back to `def.LabelCap`. Do not guard on `name == def.fixedName`: DefInjected has already overwritten `def.fixedName` with the translation by then, so it never matches. `Faction.hidden` is also scribed (`bool?`); clearing the def flag does not fix saves that already stored it.

## Tick cadence

`TickerType.Rare` = 250 ticks, `Long` = 2000. `MapComponent` ticks every tick (no interval base class). Never scan the whole map per tick. Needs: see `gameplay-snippets.md`.

## Settings that are saved but never read

A mod setting that only exists in `ExposeData` and the settings window does nothing. When adding a setting, grep for its use in the code that should obey it (here the "enable map generation" checkbox was never read by the GenStep for a long time).

## Mine designations are per cell

`DesignationDef` Mine has `targetType Cell`. `designationManager.DesignationOn(thing, Mine)` logs `Designations of type Mine are indexed by location only` and returns null. Use `DesignationAt(cell, DesignationDefOf.Mine)` and `AddDesignation(new Designation(cell, def))`. `Building.DeSpawn` removes them through `DesignationManager.Notify_BuildingDespawned` (for defs with `removeIfBuildingDespawned`), so to carry an order onto a replacement node: record the occupied cells that have one before `base.DeSpawn`, spawn the replacement, then re-add them.

## Regrowing a Mineable

`Mineable.DestroyMined` is not virtual and calls `Building.Destroy` via `base.`, so overriding `Destroy` never sees mining. Every path ends in `DeSpawn(mode)`: mining and killing blows are `DestroyMode.KillFinalize`, uninstalling (`MakeMinified`) is `Vanish`. Override `DeSpawn`, regrow only for `KillFinalize`, spawn the replacement after `base.DeSpawn`.

## Game updates and the toolchain

A game update can change the layout under `Managed` (a 1.7 build had no `mscorlib.dll`, ran on .NET 10 with Unity stubs). If `build.sh` suddenly reports CS0006 on every reference, check `Version.txt` and the Steam branch (`appmanifest_294100.acf` -> `BetaKey`) before touching code. Decompiled source and API notes are valid only for the version they were made from. Workshop mods also reorganise: the Harmony mod moved from `Current/Assemblies` to `<version>/Assemblies`.
