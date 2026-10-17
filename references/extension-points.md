# Extension points (no Harmony)

Some installs have no `0Harmony.dll` and `Assembly-CSharp` does not reference `HarmonyLib`. A mod written against it will not compile or load. An XML `PatchOperation` is not a Harmony patch and is fine.

| Need | Extension point |
|---|---|
| Absorb or modify damage to your own building | Override `Thing.PreApplyDamage(ref DamageInfo dinfo, out bool absorbed)`. `dinfo.Def == DamageDefOf.Bomb` for explosions. Only affects that building |
| React when a lord's pawn is damaged | Override `LordToil.Notify_PawnDamaged(Pawn, DamageInfo)`. `Lord.Notify_PawnDamaged` forwards **only to `CurLordToil`, never to `LordJob`** |
| Run code on map generation | Custom `GenStep` + `GenStepDef` + `PatchOperationAdd` on `MapGeneratorDef[defName="Base_Player"]/genSteps` |
| Run code each tick, on a slow cadence | `ThingComp` / `Building` with `tickerType` Rare (250), Long (2000); `GameComponent.GameComponentTick` |
| Custom AI | Custom `DutyDef` (auto-indexed) + custom `JobGiver`; `ThinkNode_Duty` builds its subnode table from `DefDatabase<DutyDef>.AllDefs` |
| Uninstallable / reinstallable building | `ThingDef.minifiedDef` is the only switch |
| Per-game state, load and new-game hooks | `GameComponent` (auto-discovered, constructor takes `Game`) with `LoadedGame()` / `FinalizeInit()` |
| Mod settings | `ModSettings` + `Mod.DoSettingsWindowContents`; saved by `Dialog_ModSettings.PreClose` |
| Dev menu actions | `[DebugAction("Category", "Label", ..., actionType = DebugActionType.ToolMap)]` on a static method |
| Bind defNames to fields so typos become startup errors | A `[DefOf]` static class |

Pawn removal with the safe pattern: see `lords-and-ai.md`.

## When there really is no extension point: an optional Harmony patch

Pawn name colour is the example: `PawnNameColorUtility.PawnNameColorOf(Pawn)` is a static method that reads a private static list of reds for every hostile faction. No Def field, event or virtual method changes it, and the faction's own colour only tints its icon.

Pattern that keeps the mod working without Harmony:
- Put all `using HarmonyLib` code in its own file and class, never in a class the rest of the mod needs.
- Detect Harmony first (`AppDomain.CurrentDomain.GetAssemblies()` has an assembly named `0Harmony`), then call the patch class from a `[MethodImpl(NoInlining)]` method. A method that references a missing type only fails when it is JIT-compiled, so a player without Harmony never triggers it.
- Patch by reflection and `new HarmonyMethod(methodInfo)`; use a `Postfix(..., ref ReturnType __result)`.
- `About.xml`: `loadAfter` `brrainz.harmony`, not `modDependencies`, to keep it optional.
- Compile against the Workshop Harmony DLL (`steamapps/workshop/content/294100/2009463077/Current/Assemblies/0Harmony.dll`, version 2.4.1, supports 1.6) but do not copy it into the mod. Other workshop folders contain old Harmony copies for 1.0 to 1.4 that are not the ones to use.
- Unverified in game as of writing: that the patched colour shows in every UI (map labels, colonist lists).
