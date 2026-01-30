#!/usr/bin/bash
set -e

time meson compile -C .build/release_gcc
time meson compile -C .build/release_clang
cp .misc/splash_screen.png .build/release_gcc/
cp .misc/splash_screen.png .build/release_clang/
