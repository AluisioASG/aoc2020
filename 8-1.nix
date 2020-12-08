# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  parseInstruction = s:
    let
      matches = builtins.match "([[:lower:]]{3}) (\\+|(-))?([[:digit:]]+)" s;
      op = elemAt matches 0;
      num = elemAt matches 3;
      sign = optionalString (elemAt matches 2 != null) "-";
      num' = toInt "${sign}${num}";
    in
    { op = op; arg = num'; };
  execInstruction = { state, instr }:
    if instr.op == "acc" then { acc = state.acc + instr.arg; pc = state.pc + 1; }
    else if instr.op == "jmp" then { acc = state.acc; pc = state.pc + instr.arg; }
    else if instr.op == "nop" then { acc = state.acc; pc = state.pc + 1; }
    else throw "unknown operation: ${instr.op}";
  execFinite = program: state:
    let
      nextInstruction = state: elemAt program state.pc;
      initTracker = genList (_: false) (length program);
      updateTracker = tracker: pc:
        (take pc tracker) ++ [ true ] ++ (drop (pc + 1) tracker);
      execTrackState = state: tracker:
        if state.pc >= length program then state
        else if elemAt tracker state.pc then state
        else execTrackState (execInstruction { state = state; instr = nextInstruction state; }) (updateTracker tracker state.pc);
    in
    execTrackState state initTracker;
in
pipe ./8-input.txt [
  readFile
  (splitString "\n")
  (filter (s: s != ""))
  (map parseInstruction)
  (program: execFinite program { acc = 0; pc = 0; })
  (getAttr "acc")
]
