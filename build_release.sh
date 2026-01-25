#!/usr/bin/bash
set -e

time meson compile -C .build/release_gcc
time meson compile -C .build/release_clang
