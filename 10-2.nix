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

  # The input is a graph.  Count the paths from start to finish.
  # Thanks to the folks at https://redd.it/ka9yj0 for pointing at the
  # right direction, took me a few steps to find the correct algorithm.
  reachableFrom = xs: n:
    filter (x: x - n > 0 && x - n <= 3) xs;
  pathsCount = foldr
    (n: reachmap: reachmap // { ${toString n} = foldl' add 0 (map (n': reachmap.${toString n'}) (reachableFrom ratings n)); })
    ((listToAttrs (map (n: nameValuePair (toString n) 0) ratings)) // { ${toString (last ratings)} = 1; })
    (init ratings);
in
pathsCount."0"
