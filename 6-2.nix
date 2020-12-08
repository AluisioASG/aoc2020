# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let allAnswers = lowerChars;
in
pipe ./6-input.txt [
  readFile
  (splitString "\n")
  # Group up lines separated by blank lines.
  (flip foldl' { result = [ ]; current = [ ]; } (acc: line:
    if line == ""
    then { result = acc.result ++ [ acc.current ]; current = [ ]; }
    else { result = acc.result; current = acc.current ++ [ line ]; }
  ))
  ({ result, ... }: map (map stringToCharacters) result)
  (map (foldl' intersectLists allAnswers))
  (map length)
  (foldl' add 0)
]
