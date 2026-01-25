#!/usr/bin/bash
set -e

thisScriptsFilePath="$(readlink --canonicalize-existing "$0")"
thisScriptsDirPath="$(dirname "$thisScriptsFilePath")"
cd $thisScriptsDirPath



rm -rf .cache
rm -rf .build
mkdir .build

mkdir .build/dbg
mkdir .build/dbg/shaders
wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_dev"
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/dbg/
CXX_LD=mold CC_LD=mold meson setup .build/dbg -DWICKED_BUILD_DIR=$wi_build_dir -Dbuildtype=debug -Dcpp_args="-DDEVBUILD=1" -Dc_args="-DDEVBUILD=1"

mkdir .build/dev
mkdir .build/dev/shaders
wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_dev"
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/dev/
CXX_LD=mold CC_LD=mold meson setup .build/dev -DWICKED_BUILD_DIR=$wi_build_dir -Dbuildtype=custom -Ddebug=false -Dcpp_args="-DDEVBUILD=1" -Dc_args="-DDEVBUILD=1"

mkdir .build/release_gcc
mkdir .build/release_gcc/shaders
wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_release_gcc"
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/release_gcc/
CXX_LD=mold CC_LD=mold meson setup .build/release_gcc -Db_pch=false -DWICKED_BUILD_DIR=$wi_build_dir -Dbuildtype=release -Dprefer_static=true

mkdir .build/release_clang
mkdir .build/release_clang/shaders
wi_build_dir="3rdparty/turanszkij_WickedEngine/.build_release_clang"
cp $wi_build_dir/WickedEngine/libdxcompiler.so .build/release_clang/
CXX=clang++ CC=clang CXX_LD=lld CC_LD=lld meson setup .build/release_clang -Db_pch=false -DWICKED_BUILD_DIR=$wi_build_dir -Dbuildtype=release -Dprefer_static=true

cp .build/dev/compile_commands.json .
