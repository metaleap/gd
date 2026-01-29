#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath

cp 3rdparty/config.ini 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor/
cp 3rdparty/startup.lua 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor/
cd 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor
./Editor
cd $thisScriptsDirPath
cp 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor/config.ini 3rdparty/
cp 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor/startup.lua 3rdparty/

# AMD_VULKAN_ICD=RADV DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1
