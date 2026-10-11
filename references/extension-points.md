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
