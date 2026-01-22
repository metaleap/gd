#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath

# cd 3rdparty/turanszkij_WickedEngine/.build_dbg/Editor && AMD_VULKAN_ICD=RADV DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1 ./Editor
cd 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor && AMD_VULKAN_ICD=RADV DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1 ./Editor
cd $thisScriptsDirPath
cp 3rdparty/turanszkij_WickedEngine/.build_release_gcc/Editor/config.ini 3rdparty/
