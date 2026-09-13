#!/bin/bash
set -euo pipefail;

BOOST_VER=1.92.0;
LIBS=$(sed -n 's/.*BOOST_INCLUDE_LIBRARIES\s*"\([^"]*\)".*/\1/p' CMakeLists.txt | tr ';' ' ');
if [ -d projects/boost ]; then
  cd projects/boost;
  git fetch --depth=1 origin;
  git reset --hard boost-$BOOST_VER;
  git gc --prune=now;
else
  git clone -b boost-$BOOST_VER --depth 1 https://github.com/boostorg/boost.git projects/boost;
  cd projects/boost;
fi
git submodule update --init --depth 1 tools/boostdep;
for lib in $LIBS; do
  git submodule update --init --depth 1 "libs/$lib";
  python tools/boostdep/depinst/depinst.py -X test -X example -g "--depth 1 --jobs 4" $lib;
done
cd libs/thread;
git apply ../../../../patches/boost_thread.patch;
