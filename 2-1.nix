{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:
with lib;
pipe ./2-input.txt [
  readFile
  (splitString "\n")
  (map (builtins.match "([[:digit:]]+)-([[:digit:]]+) ([[:alpha:]]): (.*)"))
  (filter (match: match != null))
  (map (match: {
    min = toInt (elemAt match 0);
    max = toInt (elemAt match 1);
    char = elemAt match 2;
    password = elemAt match 3;
  }))
  (count ({ password, char, min, max }: pipe password [
    stringToCharacters
    (count (c: c == char))
    (n: n >= min && n <= max)
  ]))
]
