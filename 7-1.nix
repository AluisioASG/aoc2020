# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  findAllowances = bags: rules:
    let
      bags' = sort (a: b: a < b) bags;
      containers = concatMap (bag: attrNames (filterAttrs (container: contained: elem bag contained) rules)) bags';
      newBags = unique (sort (a: b: a < b) (bags' ++ containers));
    in
    if newBags == bags' then bags else findAllowances newBags rules;
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
      (map (builtins.match ("[[:digit:]]+ (.+) bags?")))
      (remove null)
      concatLists
    ];
  }))
  listToAttrs
  (findAllowances [ "shiny gold" ])
  length
  (flip sub 1)
]
