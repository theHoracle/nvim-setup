#!/usr/bin/env bash
set -euo pipefail
make
# Release archives can contain Nix-specific libiconv paths on macOS.
if [[ "$(uname -s)" == Darwin ]]; then
  for library in lua/avante_*.so; do
    [[ -f "$library" ]] || continue
    dependency=$(otool -L "$library" | awk '/\/nix\/store\/.*libiconv/ {print $1; exit}')
    if [[ -n "$dependency" ]]; then
      install_name_tool -change "$dependency" /usr/lib/libiconv.2.dylib "$library"
    fi
    codesign --force --sign - "$library"
  done
fi
