# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let allSeats = genList id (128 * 8);
in
pipe ./5-input.txt [
  readFile
  (splitString "\n")
  (filter (s: s != ""))
  (map (spec: foldl'
    (state: action:
      let
        rp = (state.rl + state.rh) / 2;
        cp = (state.cl + state.ch) / 2;
      in
      if action == "F" then state // { rh = rp; }
      else if action == "B" then state // { rl = rp + 1; }
      else if action == "L" then state // { ch = cp; }
      else if action == "R" then state // { cl = cp + 1; }
      else throw "unknown action ${action}")
    { rl = 0; rh = 127; cl = 0; ch = 7; }
    (stringToCharacters spec)
  ))
  (map (state:
    if state.rl != state.rh then throw "row did not converge: ${toString state.rl}, ${toString state.rh}"
    else if state.cl != state.ch then throw "column did not converge: ${toString state.cl}, ${toString state.ch}"
    else { row = state.rl; column = state.cl; }))
  (map ({ row, column }: row * 8 + column))
  (flip subtractLists allSeats)
  (seats: partition (seat: elem (seat - 1) seats || elem (seat + 1) seats) seats)
  (getAttr "wrong")
]
