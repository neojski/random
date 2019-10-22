#!/bin/bash

echo "open! Core ;; $@" > test.ml
dune build main.exe
cat /dev/stdin | ./_build/default/main.exe
