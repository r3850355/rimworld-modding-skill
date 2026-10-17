# Localization

## Keyed (`Languages/<Lang>/Keyed/*.xml`)

Strings your C# calls with `"KEY".Translate(args)`. Files are enumerated recursively; any subfolder is fine. Root element `<LanguageData>`. Keep English and the translation key-for-key identical (`scripts/validate_mod.py` checks this). In the XML text, a backslash followed by `n` is the newline; when writing the file from a script, check the file contains that two-character sequence and not a real line break.

## DefInjected (`Languages/<Lang>/DefInjected/<DefType>/*.xml`)

Overrides fields that already exist in your Def XML (label, description, ...).

- **Only the first-level subfolders are read**, and each folder name is resolved as a def type (`ThingDef`, `FactionDef`, `PawnKindDef`, `HediffDef`, `ThoughtDef`, ...). A file placed directly in `DefInjected/` is **silently ignored**, with no error. This is the usual reason "def names show in English".
- Key format is `<DefName>.<fieldPath>`, root `<LanguageData>`. Example: `<MYMOD_Tower.label>`, `<MYMOD_Faction.fixedName>`. Not `<ThingDef.MYMOD_Tower>`.
- List items: numeric index or handle both work, e.g. `MYMOD_Hediff.stages.0.label`, `MYMOD_Thought.stages.0.description`.
- Fields marked `[NoTranslate]` or `[Unsaved]` throw a hard error if injected. `[MustTranslate]` fields (e.g. `FactionDef.fixedName`) are the ones to translate.
- Folder name binding: a language folder named `ChineseTraditional` binds to the game's `ChineseTraditional (繁體中文)`; `LegacyFolderName` strips the parenthesis.

## Symptom check

If only def labels and descriptions are untranslated while Keyed strings work, `DefInjected` is mislaid or mis-keyed. If a Keyed string shows its raw key, `LoadFolders.xml` or the Keyed file is wrong.

## The faction name trap

See `mapgen-and-lifecycle.md`: a scribed `Faction.Name` keeps the old language in existing saves until nulled.
