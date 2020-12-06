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
  (count (passport: all id [
    # To validate that each line contains the required fields, verify that
    # the list of required attributes is a subset of the attributes in the
    # line.
    (isSubsetOf (attrNames passport) requiredFields)
    (builtins.match "19[2-9][0-9]|200[0-2]" passport.byr != null)
    (builtins.match "20(1[0-9]|20)" passport.iyr != null)
    (builtins.match "20(2[0-9]|30)" passport.eyr != null)
    (builtins.match "(1[5-8][0-9]|19[0-3])cm|(59|6[0-9]|7[0-6])in" passport.hgt != null)
    (builtins.match "#[[:xdigit:]]{6}" passport.hcl != null)
    (builtins.match "amb|blu|brn|gry|grn|hzl|oth" passport.ecl != null)
    (builtins.match "[[:digit:]]{9}" passport.pid != null)
  ]))
]
