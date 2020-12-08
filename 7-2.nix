# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  containedBags = bag: rules:
    foldl' add 0
      (mapAttrsToList (contained: qty: qty * (1 + (containedBags contained rules))) rules.${bag});
in
pipe ./7-input.txt [
  readFile
  (splitString "\n")
  (filter (s: s != ""))
  (map (builtins.match "(.+) bags contain (.+)\."))
  (map (matches: {
    name = elemAt matches 0;
    value = pipe (elemAt matches 1) [
      (splitString ", ")
      (map (builtins.match ("([[:digit:]]+) (.+) bags?")))
      (remove null)
      (map (matches: nameValuePair (elemAt matches 1) (toInt (elemAt matches 0))))
      listToAttrs
    ];
  }))
  listToAttrs
  (containedBags "shiny gold")
]
