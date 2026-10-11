# Toolchain

Offline build of a RimWorld 1.6 mod with no dotnet SDK and no Visual Studio.

## Setup (one time): `scripts/setup-tools.sh`

Produces, under `$TOOLS` (default `~/totools`):
- `roslyn/tasks/net472/csc.exe`: Roslyn 4.11.0 from the `Microsoft.Net.Compilers.Toolset` NuGet package. The framework `csc.exe` that ships with Windows is C# 5 only; do not use it.
- `ilspy/tools/net6.0/any/ilspycmd.dll`: decompiler (ilspycmd 8.2.0.7535). Needs a .NET runtime, run with `DOTNET_ROLL_FORWARD=LatestMajor`.
- `src/`: Assembly-CSharp decompiled to about 9,200 `.cs` files (about 50 MB).

NuGet download with `curl` needs `-L`, otherwise you get a ~220-byte redirect page instead of the package.

Game DLLs are in `<RimWorld>/RimWorldWin64_Data/Managed`.

## Compile

`scripts/build.sh`. Flags that matter:
- `-nostdlib+` with an explicit `-r:` for every game DLL.
- **Include `netstandard.dll`**, or you get `CS0012: 'ValueType' is defined in an assembly that is not referenced`.
- Reference at minimum: mscorlib, netstandard, System, System.Core, System.Xml, System.Xml.Linq, System.Drawing, UnityEngine, UnityEngine.CoreModule, UnityEngine.IMGUIModule, UnityEngine.TextRenderingModule, UnityEngine.ImageConversionModule, Assembly-CSharp.
- Target net472. Output goes to `<mod>/1.6/Assemblies/`.

## Windows Git Bash and tooling quirks

- **`CS2012` cannot open the DLL for writing:** the game is running. Compile to a temp path to check code (`OUT=../_check.dll`), rebuild after closing the game.
- **Python and PowerShell do not see Git Bash's `/tmp`.** Write scratch files inside the project (and git-ignore `_*.py`), or use the Windows temp path.
- **Long Python edits in a bash heredoc break on quotes.** Write the script to a file with the Write tool, then run it.
- **Console encoding is cp950 (Traditional Chinese).** `print()` of CJK fails with `UnicodeEncodeError`, and CJK in PowerShell output turns into mojibake. Write results to a UTF-8 file and read that, or avoid printing CJK.
- PowerShell reflection dumper: needs a `HashSet<string>` guard in the `AssemblyResolve` handler or it recurses until StackOverflow.
- Git on Windows prints `LF will be replaced by CRLF` warnings; harmless.

## Mod folder layout

```
About/About.xml
LoadFolders.xml          (<v1.6><li>/</li><li>1.6</li></v1.6>; "/" means the mod root)
1.6/Defs  1.6/Patches  1.6/Assemblies
Languages/English/Keyed  Languages/<Lang>/DefInjected/<DefType>/
Textures/Things/...
Source/
```

`supportedVersions` only `1.6`. Use a unique `packageId` (`author.modname`); a placeholder collides with other mods, so replace it before publishing.
