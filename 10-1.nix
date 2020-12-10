# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  input = pipe ./10-input.txt [
    readFile
    (splitString "\n")
    (filter (s: s != ""))
    (map toInt)
  ];
  ratings = pipe input [
    (sort (a: b: a < b))
    (xs: [ 0 ] ++ xs ++ [ (last xs + 3) ])
  ];
  differences = foldl'
    ({ result, prev }: cur: {
      result = result ++ [ (cur - prev) ];
      prev = cur;
    })
    { result = [ ]; prev = head ratings; }
    (tail ratings);
in
foldl' builtins.mul 1 [
  (count (x: x == 1) differences.result)
  (count (x: x == 3) differences.result)
]
