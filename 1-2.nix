# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:
with lib;
let
  input = pipe ./1-input.txt [
    readFile
    (splitString "\n")
    (filter (s: s != ""))
    (map toInt)
  ];
in
pipe [ input input ] [
  (crossLists (x1: x2: { sum = x1 + x2; elements = [ x1 x2 ]; }))
  (filter (line: line.sum < 2020))
  (concatMap (line:
    let candidates = filter (x: ! elem x line.elements && line.sum + x == 2020) input;
    in map (candidate: line.elements ++ [ candidate ]) candidates))
  head
  (foldl' builtins.mul 1)
]
