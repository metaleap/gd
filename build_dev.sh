#!/usr/bin/bash
set -e

time meson compile -C .build/dev
cp .build/dev/compile_commands.json .
