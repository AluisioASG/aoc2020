{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:
with lib;
pipe ./1-input.txt [
  readFile
  (splitString "\n")
  (filter (s: s != ""))
  (map toInt)
  (xs: crossLists (x1: x2: [ x1 x2 ]) [ xs xs ])
  (findFirst (pair: (foldl' add 0 pair) == 2020)
    (throw "no matching pair found"))
  (foldl' builtins.mul 1)
]
