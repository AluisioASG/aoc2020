# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  sumsTo = xs: n:
    let
      t1 = head xs;
      t2 = n - t1;
    in
    if xs == [ ] then null
    else if t1 != t2 && elem t2 xs then [ t1 t2 ]
    else sumsTo (tail xs) n;

  sumsToContiguous = xs: n:
    let
      sumOnIncreasingWindow = xs: count: acc:
        let acc' = acc + elemAt xs (count - 1);
        in
        if count > (length xs) || acc' > n then null
        else if acc' == n then take count xs
        else sumOnIncreasingWindow xs (count + 1) acc';

      sumFromHere = sumOnIncreasingWindow xs 1 0;
    in
    if xs == [ ] then null
    else if xs == [ n ] then xs
    else if sumFromHere != null then sumFromHere
    else sumsToContiguous (tail xs) n;

  validateIndex = xs: windowLength: i:
    let
      n = elemAt xs i;
      window = sublist (i - windowLength) windowLength xs;
    in
    sumsTo window n != null;

  validateInput = xs: windowLength:
    map (validateIndex xs windowLength) (range windowLength (length xs - 1));


  input = pipe ./9-input.txt [
    readFile
    (splitString "\n")
    (filter (s: s != ""))
    (map toInt)
  ];

  firstInvalid = pipe input [
    (flip validateInput 25)
    (indexOf false)
    (add 25) # compensate for validateInput nuking the first preamble
    (elemAt input)
  ];
in
pipe firstInvalid [
  (sumsToContiguous input)
  (sort (a: b: a < b))
  (sorted: [ (head sorted) (last sorted) ])
  (foldl' add 0)
]
