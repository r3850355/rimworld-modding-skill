# Defs and XML

## ThingDef (building)

- A building with a `<comps>` list that is a hediff needs `hediffClass HediffWithComps`.
- Uninstallable and reinstallable: `<minifiedDef>MinifiedThing</minifiedDef>`. A minifiable thing should be in a thing category, or `Player.log` shows `is minifiable but not in any thing category`.
- `<designationCategory>None</designationCategory>` is invalid; omit the field.
- Impassable 3x3: `passability Impassable`, `size (3,3)`, `rotatable false`, `Flammability 0`, `claimable false`, `deconstructible false`, `destroyable true`.

## Graphics

- `Graphic_Single`: one PNG, `texPath` without extension. `Graphic_Random` / `Graphic_Collection`: `texPath` is a **folder** of variants (vanilla `SculptureLarge`). Using `Graphic_Single` on a folder path draws the red error box.
- Texture size: 128 px per cell. A 3x3 building is 384x384. **If the image is not square, set `drawSize` from its real size** (384x360 gives `(3,2.8125)`), or it is stretched.
- Shadows: `staticSunShadowHeight` and `graphicData.shadowData` are mutually exclusive; defining both prints `graphicData defines a shadowInfo but staticSunShadowHeight > 0`. Vanilla shadow is an axis-aligned box and cannot follow a silhouette. For `shadowData`, `volume` is (x width, y height, z depth) in cells and `offset` shifts it (negative z moves toward the foot). To use a silhouette-shaped shadow, set both to 0 and bake the shadow into the PNG.
- `castEdgeShadows false` removes the soft edge shadow.

## HediffDef plus ThoughtDef: one effect, no desync

- Stat: `<stages><li><statOffsets><WorkSpeedGlobal>0.30</WorkSpeedGlobal></statOffsets></li></stages>`. `WorkSpeedGlobal` has default base 1, so an offset of 0.30 is +30%.
- Mood: `ThoughtDef` with `workerClass ThoughtWorker_Hediff` and `<hediff>MyHediff</hediff>`; `baseMoodEffect` is on the `ThoughtStage`.
- Self-expiry: `HediffCompProperties_Disappears` (`disappearsAfterTicks`). To keep it alive, refresh `HediffComp_Disappears.ticksToDisappear` directly each cycle (refreshing via `SetDuration` also works but makes the tooltip dishonest). Make the expiry longer than the refresh interval to avoid flicker at the boundary.
- Animals have no mood need; filter `RaceProps.Humanlike`.

## FactionDef (hidden enemy faction spawned by your own code)

- `hidden` true also suppresses the faction label on every pawn (`Pawn.FactionDesc`, `CharacterCardUtility`), so pawns look factionless. Leave it false. To keep it out of world UI use `displayInFactionSelection false`, `settlementGenerationWeight 0`, `requiredCountAtGameStart 0`, `startingCountAtWorldCreation 0`.
- Not hidden means it needs a leader (`Faction.TryGenerateNewLeader` runs from `NewGeneratedFaction`): supply `<pawnGroupMakers />` (empty is enough), `<fixedLeaderKinds>`, and `maxPawnCostPerTotalPointsCurve` (`ConfigErrors` requires the curve whenever `pawnGroupMakers` is non-null). No Combat group maker keeps it out of raids and caravan meetings; `raidsForbidden true` as well.
- `permanentEnemy` + `naturalEnemy` + goodwill locked to -100 (`SetRelation` both directions).
- Create it yourself: `FactionGenerator.NewGeneratedFactionWithRelations(def, new List<FactionRelation>(), hidden: false)` then `Find.FactionManager.Add(created)`.
- Invalid fields that look valid: `defaultPawnGroupKind` and a stray `maxPawnCostPerTotalPointsCurve` without group makers.

## PawnKindDef

- Gear fields: `apparelMoney`, `weaponMoney`, `apparelTags`, `weaponTags`, `itemQuality`, `gearHealthRange`, `techHediffsChance`. Tribal tier: `apparelTags Neolithic`, `weaponTags NeolithicMeleeBasic / NeolithicRangedBasic / NeolithicMeleeDecent / NeolithicRangedHeavy`. Industrial: `IndustrialBasic`, `IndustrialMilitaryBasic`, `IndustrialAdvanced`, `SimpleGun`, `Gun`.
- Set `defaultFactionDef`.
- Verify every field against `Verse/PawnKindDef.cs`; unknown ones only show as an XML error in the log.

## LoadFolders.xml

`<li>/</li>` is special-cased to the mod root, so `<v1.6><li>/</li><li>1.6</li></v1.6>` loads both the root and `1.6/`.

## defName hygiene

Prefix everything (`MYMOD_`). A FactionDef must not share a defName with a building. Run `scripts/validate_mod.py` for duplicates.

## Player-buildable or not

`BuildableDef.BuildableByPlayer` is simply `designationCategory != null`. Remove `designationCategory` and the thing never shows in the architect menu; it can still be uninstalled and reinstalled through `minifiedDef` (the install flow does not read `designationCategory`). Also drop `WorkToBuild` and any `costList`.

## Resource nodes that regrow and can be moved

Make them `Mineable` subclasses, not Plants: a Plant cannot be minified, so a tree built as a Plant can never be picked up and reinstalled. The vanilla Mine order then harvests them. A `ThingDef` for one needs `thingClass` (yours), `mineable true`, `passability Impassable`, `minifiedDef MinifiedThing`, `building.mineableThing` / `mineableYield`, and `alwaysUninstallable true`. Size can be larger than 1x1; vanilla has no 2x2 mineable but nothing in the mining code assumes one cell (not verified in game).

Vanilla yields for reference: a components vein gives `ComponentIndustrial` x2, so keep that low rather than copying a steel yield of 40.

## Textures: size rule

128 px per cell: 1x1 is 128, 2x2 is 256, 3x3 is 384. Square PNG with alpha, `Graphic_Single`, `texPath` without extension, file under `Textures/...`. Match `drawSize` to the real aspect ratio; a non-square image is stretched.
