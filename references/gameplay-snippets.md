# Gameplay snippets

## Needs

```csharp
Need_Food food = pawn.needs?.food;  if (food != null && food.CurLevelPercentage < 0.6f) food.CurLevelPercentage = 1f;
Need_Rest rest = pawn.needs?.rest;  // same pattern
Need_Mood mood = pawn.needs?.mood;  // recomputed from thoughts every 150 ticks
```
Faction pawns spawned by your own code cannot eat from the colony and will starve. Top up on a timer from a `GameComponent` (every 600 ticks for food and rest, every 150 for mood; mood on a slower cadence drops between ticks). Filter to your faction: `Find.FactionManager.FirstFactionOfDef(def)` and `map.mapPawns.SpawnedPawnsInFaction(f)`.

## Generating and equipping a pawn

```csharp
var req = new PawnGenerationRequest(kind, faction, PawnGenerationContext.NonPlayer, tile: map.Tile,
    mustBeCapableOfViolence: true, canGeneratePawnRelations: false, colonistRelationChanceFactor: 0f,
    allowAddictions: false, forceNoIdeo: true, developmentalStages: DevelopmentalStage.Adult);
Pawn p = PawnGenerator.GeneratePawn(req);       // sets the faction via SetFactionDirect
```
- Replace armour: `pawn.apparel.DestroyAll()` then `pawn.apparel.Wear((Apparel)ThingMaker.MakeThing(def, GenStuff.DefaultStuffFor(def)), dropReplacedApparel: false)`.
- Replace weapon: `pawn.equipment.DestroyAllEquipment()` then `AddEquipment((ThingWithComps)thing)`.
- Quality: `thing.TryGetComp<CompQuality>()?.SetQuality(QualityCategory.Legendary, ArtGenerationContext.Outsider)`.
- Base-game gear defNames: `Gun_ChargeRifle`, `Gun_LMG`, `Gun_AssaultRifle`, `Apparel_PowerArmor`, `Apparel_PowerArmorHelmet`, `Apparel_ArmorRecon`, `Apparel_ArmorHelmetRecon`.
- **A shield belt (`blocksRangedWeapons`) stops the wearer using ranged weapons** (`CompShield.CompAllowVerbCast`). Do not give it to a ranged unit.
- Colony wealth: `map.wealthWatcher.WealthTotal`.
- Storyteller points: `StorytellerUtility.DefaultThreatPointsNow(map)`.

## Letters

```csharp
Find.LetterStack.ReceiveLetter(label, text, myLetterDef, new LookTargets(thingOrPawns));
```
`LookTargets` accepts a Thing or a list of pawns and gives a jump-to button. `LetterDef.pauseMode` (`Never` / `MajorThreat` / `AnyThreat` / `AnyLetter`) decides pausing. Vanilla `LetterDefOf.ThreatBig` plays an alert and may pause. Not usable during map generation.

## ModSettings

`ModSettings` subclass with `Scribe_Values.Look(ref x, "x", default)`, a `Clamp()` on load and after edits, and `Mod.DoSettingsWindowContents` using a `Listing_Standard` (`CheckboxLabeled`, `Slider`). `GetSettings<T>()` in the `Mod` constructor.

## Debug actions

`[DebugAction("Category", "Label", false, false, false, false, false, 0, false, actionType = DebugActionType.ToolMap, allowedGameStates = AllowedGameStates.PlayingOnMap)]` on a `static` method; `UI.MouseCell()` for the cursor cell. Worth adding a `Log pawns` action printing lord, duty, job, target, food, downed: it turns "AI does nothing" reports into one log line.

## Time

`GenDate.TicksPerDay` 60000, `TicksPerHour` 2500. 600 ticks is 10 seconds at 1x.

## Pawn name colour

`PawnNameColorUtility.PawnNameColorOf(Pawn)` is static and reads a private static list of reds for all hostile factions. There is no Def field or event for it and the faction colour only tints the icon. The only way to recolour one faction is an optional Harmony postfix; see `extension-points.md`.
