# Lords, duties and pawn AI

## Lord lifecycle

- `LordMaker.MakeNewLord(faction, lordJob, map, pawns)` is the only factory. A lord with no pawns is removed unless `LordJob.ShouldExistWithoutPawns`.
- `LordJob` has one abstract method, `CreateGraph()`. `LordToil` has abstract `UpdateAllDuties()`.
- **Never call `lordManager.RemoveLord` from inside a toil tick.** `LordManagerTick` iterates `lords` with a forward `for`, then a second reverse loop removes any lord whose `CurLordToil == null || ShouldFail`. Removing mid-iteration silently skips the next lord's tick. Instead: set a flag, return it from `public override bool ShouldFail`, and hand survivors off in `public override void Cleanup()` (called after the lord is out of the list).
- `Lord.RemovePawn(p)` clears `p.mindState.duty` and `p.lord`. `Lord.AddPawn` errors if the pawn still has a lord. To move a pawn: `oldLord.Notify_PawnLost(p, PawnLostCondition.ForcedToJoinOtherLord)`, then add or create the new lord. Collect first, then move; the list mutates.
- A lord's pawn list is mutated by `Notify_PawnLost`. Snapshot `ownedPawns` into a list before looping when your loop can move pawns.
- Read survivors **before** `Cleanup` finishes; `Lord.Cleanup` clears duties and lord references on whatever is still owned.
- `LordJob.ShouldRemovePawn(p, reason)`: return false for `PawnLostCondition.Incapped` to keep downed members.
- Never use `LordJob_AssaultColony` if a spec forbids it; write your own LordJob instead.

## Changing a duty does not stop the current job

Setting `pawn.mindState.duty` only affects the next time the think tree runs. A pawn mid-walk or mid-wait keeps its job until it ends, which looks like a delayed reaction. After reassigning duties:

```csharp
pawn.jobs?.EndCurrentJob(JobCondition.InterruptForced, startNewJob: true);
```

## DutyDef

Own `DutyDef` (XML `thinkNode Class="ThinkNode_Priority"`), because `DutyDefOf.AssaultThing` is `[MayRequireRoyalty]`. Vanilla `AssaultColony` tree for reference:

```
JobGiver_TakeCombatEnhancingDrug
JobGiver_AIFightEnemies (targetAcquireRadius 65, targetKeepRadius 72)
JobGiver_AITrashColonyClose      <- attacks walls within 5 cells
JobGiver_AITrashBuildingsDistant
JobGiver_AIGotoNearestHostile
JobGiver_AITrashBuildingsDistant (attackAllInert)
JobGiver_AISapper
```

Hazards in these givers:
- **`JobGiver_AITrashColonyClose` makes pawns attack any wall within 5 cells.** A pawn that cannot hurt a wall (ranged only) then stands idle in front of it. Leave it out when you do not want wall-hitting.
- **`JobGiver_AISapper` with no duty focus only searches player targets within 50 cells** (`DistanceToSquared <= 2500`) and returns null otherwise. A group spawned further away does nothing and its lord disbands. **Give each pawn a duty focus** (nearest colonist or colony building); with a focus the sapper walks anywhere and attacks a wall or door only when the path is fully blocked. Set `canMineMineables` / `canMineNonMineables` false to forbid digging.
- `JobGiver_AIFightEnemies` finds hostile pawns with line of sight, handles shooting positions and cover. It never targets non-hostile pawns.
- `JobGiver_AIFightEnemy` has `GetFlagPosition` / `GetFlagRadius` hooks. Override them to confine target acquisition to a leash around a point (guards).
- `JobGiver_AIDefendPoint` (vanilla `DefendBase` duty) holds a point using `duty.focus` and `duty.radius`.
- `AttackStatic` on a target the pawn cannot hit just stands there. Check `verb.CanHitTarget(target)` and issue `Goto` otherwise.
- `AttackTargetFinder.BestAttackTarget` requires `HostileTo`; it cannot target neutrals. Write your own giver to attack neutral factions.

## Wandering

`RCellFinder.RandomWanderDestFor` warns and misbehaves above 12 cells (`Region.GridSize`). For a long hop use `CellFinder.TryFindRandomReachableNearbyCell(pos, map, radius, TraverseParms, validator, null, out cell)`.

## Patterns that worked

- **Detection without per-tick scans:** in `LordToil.LordToilTick`, stagger each pawn by `(TicksGame + pawn.thingIDNumber) % interval == 0`. Do not also gate on the lord's own tick counter; two modulo gates make most pawns unreachable.
- **Solo vs group fight:** a pawn that spots a target either rallies same-lord neighbours into a temporary attack lord, or (group mode off) makes a one-member attack lord. Ending the temporary lord returns survivors to a fresh wander lord.
- **Cooldown after rally:** after a group disbands, everyone is still standing at the target. Without a cooldown the group flickers between wander and attack. Static cooldown timers must tolerate a negative delta (see `mapgen-and-lifecycle.md`).
- **Idle check before disbanding:** treat a group as engaged if any member has a non-wait job, not only if it has `enemyTarget`. Marching and breaking a wall have no target in range.
- **Guards:** own lord + own duty using `JobGiver_AIDefendPoint`-style givers, never pulled by the rally logic. To make a few chase an attacker, swap those pawns to a second duty and `EndCurrentJob`; end the chase on attacker death, downed, timeout, or leash distance.
- **Notify on guard damage:** override `LordToil.Notify_PawnDamaged`; `dinfo.Instigator` is the shooter even for ranged attacks (verified: guards react to snipers).
- **Raid wave:** own `LordJob` whose toil is the attack toil with a march focus, refreshed every ~250 ticks. Not a vanilla assault job.
