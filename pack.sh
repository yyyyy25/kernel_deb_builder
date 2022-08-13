#!/usr/bin/env bash
VMLINUX_PATH="$(find . -name *vmlinux)"
BZIMAGE_PATH="$(find . -name *bzImage)"
KO_PATH="$(find . -name *ko)"
CONFIG_PATH="$(find . -name *.config)"
tar cvf - $VMLINUX_PATH $BZIMAGE_PATH $KO_PATH $CONFIG_PATH | zstd - -o linux-${{ matrix.version }}.tar.zst 
