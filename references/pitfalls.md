# Symptom to cause

| Symptom | Likely cause | See |
|---|---|---|
| Def label/description stay English under another language | DefInjected file not in a `<DefType>/` subfolder, or wrong key format | localization |
| Faction name stays English in an old save | Scribed `Faction.Name`; null it on load | mapgen-and-lifecycle |
| Spawned pawns show no faction | FactionDef `hidden` true | defs-and-xml |
| Structure sometimes missing at game start | random-sample placement failed; use full scan with distance tiers | mapgen-and-lifecycle |
| Structure missing on the 2nd new game in one session | static state (`Map.uniqueID` restarts at 0); reset in `GameComponent` constructor | mapgen-and-lifecycle |
| Structure deleted after generation | later scatter step; register `UsedRects` | mapgen-and-lifecycle |
| Group stands still in front of a wall | `JobGiver_AITrashColonyClose` plus ranged weapon, or `AttackStatic` on an unreachable target | lords-and-ai |
| Raid wave does nothing and its lord vanishes | `JobGiver_AISapper` with no duty focus searches only 50 cells | lords-and-ai |
| Pawns react seconds late after being given orders | duty change does not end the current job; `EndCurrentJob(InterruptForced, true)` | lords-and-ai |
| Some pawns of a group never detect anything | double modulo gating (lord tick and pawn id) | lords-and-ai |
| Group flickers between wander and attack | no rally cooldown | lords-and-ai |
| Next lord in the list skips a tick | `RemoveLord` called inside a toil tick; use `ShouldFail` + `Cleanup` | lords-and-ai |
| Guard with a ranged weapon only fights in melee | shield belt blocks ranged | gameplay-snippets |
| Summoned pawns starve or collapse | needs not topped up | gameplay-snippets |
| Red error box instead of a texture | `Graphic_Single` on a folder path, or wrong texPath | defs-and-xml |
| Texture looks stretched | `drawSize` ignores a non-square image | defs-and-xml |
| `graphicData defines a shadowInfo but staticSunShadowHeight > 0` | both shadow systems set | defs-and-xml |
| `CS0012 ... netstandard` | missing `-r:netstandard.dll` | toolchain |
| `CS0507` on `TickRare` | must be `public override`, not `protected` | api-lookup |
| `CS2012` cannot write the DLL | game running | toolchain |
| `Faction leader for X is null` | non-hidden faction with no leader source | defs-and-xml |
| Mod setting new default does not appear | existing settings file keeps the old value | gameplay-snippets |
| Letters or pawns fail during generation | not available during map generation; defer to first tick | mapgen-and-lifecycle |
