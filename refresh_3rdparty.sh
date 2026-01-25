#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath


rm -rf .shaders/*
cd 3rdparty
./refresh_WickedEngine.sh
cd $thisScriptsDirPath
