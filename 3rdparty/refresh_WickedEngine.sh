#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath

depVer="0.72.0"
depDirName="turanszkij_WickedEngine"


### clean up, fetch zip, extract zip:

rm -rf $depDirName
rm -f .tmp.zip
wget -O .tmp.zip https://github.com/turanszkij/WickedEngine/archive/refs/tags/v$depVer.zip
unzip .tmp.zip
rm -f .tmp.zip
mv WickedEngine-$depVer $depDirName

### build

cd $depDirName

rm -rf .build_RelWithDebInfo
mkdir .build_RelWithDebInfo
cd .build_RelWithDebInfo
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWICKED_ENABLE_IPO=NO -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make
cp compile_commands.json ../compile_commands.json
cd ..

rm -rf .build_Release
mkdir .build_Release
cd .build_Release
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make
cd ..

cd $thisScriptsDirPath
