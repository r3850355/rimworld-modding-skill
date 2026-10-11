#!/usr/bin/env bash
# One-time setup: Roslyn compiler, ILSpy decompiler, and the decompiled Assembly-CSharp.
# usage: RIMWORLD="E:/SteamLibrary/steamapps/common/RimWorld" TOOLS=~/totools bash setup-tools.sh
# Requires: curl, unzip, and a .NET runtime (net6 or newer) for ilspycmd.
set -eu

RIMWORLD="${RIMWORLD:?set RIMWORLD to the game install folder}"
TOOLS="${TOOLS:-$HOME/totools}"
MANAGED="$RIMWORLD/RimWorldWin64_Data/Managed"
mkdir -p "$TOOLS"
cd "$TOOLS"

# NuGet downloads need -L (the first response is a redirect page).
if [ ! -f roslyn/tasks/net472/csc.exe ]; then
  curl -L -o roslyn.nupkg https://www.nuget.org/api/v2/package/Microsoft.Net.Compilers.Toolset/4.11.0
  mkdir -p roslyn && unzip -q -o roslyn.nupkg -d roslyn
fi

if [ ! -f ilspy/tools/net6.0/any/ilspycmd.dll ]; then
  curl -L -o ilspy.nupkg https://www.nuget.org/api/v2/package/ilspycmd/8.2.0.7535
  mkdir -p ilspy && unzip -q -o ilspy.nupkg -d ilspy
fi

if [ ! -d src ] || [ -z "$(ls -A src 2>/dev/null)" ]; then
  mkdir -p src
  DOTNET_ROLL_FORWARD=LatestMajor dotnet ilspy/tools/net6.0/any/ilspycmd.dll \
    -p -o src "$MANAGED/Assembly-CSharp.dll"
fi

echo "csc:  $TOOLS/roslyn/tasks/net472/csc.exe"
echo "src:  $TOOLS/src ($(find src -name '*.cs' | wc -l) files)"
echo "Re-run after a game update (delete src first) to refresh the decompiled source."
