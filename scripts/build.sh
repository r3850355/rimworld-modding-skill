#!/usr/bin/env bash
# Compile a RimWorld 1.6 mod. Run from the mod root.
# usage: RIMWORLD=... CSC=... DLL_NAME=MyMod.dll bash build.sh
#        OUT=../_check.dll bash build.sh     (compile check only, when the game locks the DLL)
set -u

RIMWORLD="${RIMWORLD:?set RIMWORLD to the game install folder}"
CSC="${CSC:-$HOME/totools/roslyn/tasks/net472/csc.exe}"
DLL_NAME="${DLL_NAME:?set DLL_NAME, e.g. MyMod.dll}"
OUT="${OUT:-1.6/Assemblies/$DLL_NAME}"
MANAGED="$RIMWORLD/RimWorldWin64_Data/Managed"

mkdir -p "$(dirname "$OUT")"
SOURCES=$(find Source -name '*.cs' | sort)

"$CSC" -nologo -target:library -out:"$OUT" -langversion:latest -nostdlib+ -optimize+ \
  -r:"$MANAGED/mscorlib.dll" \
  -r:"$MANAGED/netstandard.dll" \
  -r:"$MANAGED/System.dll" \
  -r:"$MANAGED/System.Core.dll" \
  -r:"$MANAGED/System.Xml.dll" \
  -r:"$MANAGED/System.Xml.Linq.dll" \
  -r:"$MANAGED/System.Drawing.dll" \
  -r:"$MANAGED/UnityEngine.dll" \
  -r:"$MANAGED/UnityEngine.CoreModule.dll" \
  -r:"$MANAGED/UnityEngine.IMGUIModule.dll" \
  -r:"$MANAGED/UnityEngine.TextRenderingModule.dll" \
  -r:"$MANAGED/UnityEngine.ImageConversionModule.dll" \
  -r:"$MANAGED/Assembly-CSharp.dll" \
  $SOURCES
