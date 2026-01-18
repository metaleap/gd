#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath



rm -rf .cache
rm -rf .build
mkdir .build

wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_dev"
mkdir .build/debug
mkdir .build/debug/shaders
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/debug/
meson setup -DWICKED_BUILD_DIR=$wi_build_dir --native-file meson_native.ini .build/debug -Db_sanitize=undefined

wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_release_gcc"
mkdir .build/release_gcc
mkdir .build/release_gcc/shaders
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/release_gcc/
meson setup -DWICKED_BUILD_DIR=$wi_build_dir -Dbuildtype=release -Dprefer_static=true .build/release_gcc

wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_release_clang"
mkdir .build/release_clang
mkdir .build/release_clang/shaders
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/release_clang/
CXX=clang++ CC=clang CXX_LD=lld C_LD=lld meson setup -DWICKED_BUILD_DIR=$wi_build_dir -Dbuildtype=release -Dprefer_static=true .build/release_clang

cp .build/debug/compile_commands.json .
