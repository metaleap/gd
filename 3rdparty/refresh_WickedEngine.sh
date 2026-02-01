#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath

depVer="0.72.0"
depDirName="turanszkij_WickedEngine"


### clean up, fetch zip, extract zip:

# rm -rf $depDirName
# rm -f .tmp.zip
# wget -O .tmp.zip https://github.com/turanszkij/WickedEngine/archive/refs/tags/v$depVer.zip
# unzip .tmp.zip
# rm -f .tmp.zip
# mv WickedEngine-$depVer $depDirName
# mkdir $depDirName/.shaders
# mkdir $depDirName/.shaders/spirv

### build

cd $depDirName


# rm -rf .build_dbg
# mkdir .build_dbg
# cd .build_dbg
# cmake .. -DCMAKE_BUILD_TYPE=Debug -DWICKED_TESTS=OFF -DWICKED_IMGUI_EXAMPLE=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
# make
# cd ..

# rm -rf .build_dev
# mkdir .build_dev
# cd .build_dev
# cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWICKED_ENABLE_IPO=NO -DWICKED_EDITOR=OFF -DWICKED_TESTS=OFF -DWICKED_IMGUI_EXAMPLE=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
# make
# cp compile_commands.json ../compile_commands.json
# cd ..

# rm -rf .build_release_gcc
# mkdir .build_release_gcc
# cd .build_release_gcc
# cmake .. -DCMAKE_BUILD_TYPE=Release -DWICKED_TESTS=OFF -DWICKED_IMGUI_EXAMPLE=OFF
# make
# cd ..

# rm -rf .build_release_clang
# mkdir .build_release_clang
# cd .build_release_clang
# CXX=clang++ CC=clang CXX_LD=lld CC_LD=lld C_LD=lld cmake .. -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -DWICKED_EDITOR=OFF -DWICKED_TESTS=OFF -DWICKED_IMGUI_EXAMPLE=OFF
# CXX=clang++ CC=clang CXX_LD=lld CC_LD=lld C_LD=lld make
# cd ..


cd $thisScriptsDirPath
mkdir -p turanszkij_WickedEngine/.build_dbg/Editor/themes
mkdir -p turanszkij_WickedEngine/.build_release_gcc/Editor/themes
cp *.witheme turanszkij_WickedEngine/.build_dbg/Editor/themes/
cp *.witheme turanszkij_WickedEngine/.build_release_gcc/Editor/themes/
cp config.ini turanszkij_WickedEngine/.build_dbg/Editor/
cp config.ini turanszkij_WickedEngine/.build_release_gcc/Editor/
cp startup.lua turanszkij_WickedEngine/.build_dbg/Editor/
cp startup.lua turanszkij_WickedEngine/.build_release_gcc/Editor/
