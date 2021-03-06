# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  lines = pipe ./3-input.txt [
    readFile
    (splitString "\n")
    (filter (s: s != ""))
    (map stringToCharacters)
  ];
  height = length lines;
  width = length (head lines);
  treeIndexes = flip map lines (flip pipe [
    (imap0 (i: c: if c == "#" then i else null))
    (filter (i: i != null))
  ]);

  isClear = row: col:
    let
      treeRow = elemAt treeIndexes row;
      col' = rem col width;
    in
    row < height -> ! elem col' treeRow;
  travel = trees: row: col:
    let
      trees' = trees + (if isClear row col then 0 else 1);
      row' = row + 1;
      col' = col + 3;
    in
    if row > height then trees
    else travel trees' row' col';
in
travel 0 0 0
