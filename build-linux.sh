#! /usr/bin/bash

cmake -B build-linux -GNinja -DCMAKE_PREFIX_PATH=$HOME/Qt/6.11.0/gcc_64
cmake --build build-linux
