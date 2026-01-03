#!/bin/bash

set -e

brew update
brew install automake cmake git gettext libtool texinfo m4 zlib
brew upgrade

cd deps
[ ! -d build ] && mkdir build
cd build
cmake ..
make
cd ../..
[ ! -d build ] && mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH="$PWD/../deps/build/destdir/usr/local"
make
cd ..
./makeApp.sh