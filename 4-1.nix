# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let requiredFields = [ "byr" "iyr" "eyr" "hgt" "hcl" "ecl" "pid" ];
in
pipe ./4-input.txt [
  readFile
  (splitString "\n")
  # Group up lines separated by blank lines.
  (flip foldl' { result = [ ]; current = [ ]; } (acc: line:
    if line == ""
    then { result = acc.result ++ [ acc.current ]; current = [ ]; }
    else { result = acc.result; current = acc.current ++ [ line ]; }
  ))
  ({ result, ... }: map (lines: concatStringsSep " " lines) result)
  # Convert each line into an attrset, with key-value pairs separated
  # by a single space and keys separated from values by a colon.
  (map (flip pipe [
    (splitString " ")
    (map (kv:
      let pair = splitString ":" kv; in nameValuePair (elemAt pair 0) (elemAt pair 1)))
    listToAttrs
  ]))
  # To validate that each line contains the required fields, verify that
  # the list of required attributes is a subset of the attributes in the
  # line.
  (map attrNames)
  (count (fields: isSubsetOf fields requiredFields))
]
