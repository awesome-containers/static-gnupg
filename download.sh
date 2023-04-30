#!/usr/bin/env bash

set -eu

for pkg in "$@"; do
  version="${pkg//-/_}_version"; version="${version^^}"
  echo "Download $pkg ${!version}"
  curl -#Lo "$pkg.tar.bz2" "$GNUPG_FTP/$pkg/$pkg-${!version}.tar.bz2"
  mkdir -p "./$pkg"
  tar -xvf "$pkg.tar.bz2" --strip-components=1 -C "./$pkg"
  rm -f "$pkg.tar.bz2"
done
