{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:
with lib;
let
  findAt = xs: n: if (length xs) < n then null else elemAt xs n;
in
pipe ./2-input.txt [
  readFile
  (splitString "\n")
  (map (builtins.match "([[:digit:]]+)-([[:digit:]]+) ([[:alpha:]]): (.*)"))
  (filter (match: match != null))
  (map (match: {
    p1 = toInt (elemAt match 0);
    p2 = toInt (elemAt match 1);
    char = elemAt match 2;
    password = elemAt match 3;
  }))
  (count ({ password, char, p1, p2 }: pipe password [
    stringToCharacters
    (chars: { c1 = (findAt chars (p1 - 1)); c2 = (findAt chars (p2 - 1)); })
    ({ c1, c2 }: (c1 == char && c2 != char) || (c2 == char && c1 != char))
  ]))
]
