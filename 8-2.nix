# SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>
#
# SPDX-License-Identifier: CC0-1.0

{ pkgs ? import <nixpkgs> { }
, aasg-nixexprs ? fetchTarball "https://git.sr.ht/~aasg/nixexprs/archive/master.tar.gz"
}:
with import "${aasg-nixexprs}/lib/extension.nix" { inherit (pkgs) lib; };
let
  updateAt = updater: xs: n:
    (take n xs) ++ [ (updater (elemAt xs n)) ] ++ (drop (n + 1) xs);
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
  execFinite = state: program:
    let
      nextInstruction = state: elemAt program state.pc;
      initTracker = genList (_: false) (length program);
      updateTracker = updateAt (_: true);
      execTrackState = state: tracker:
        if state.pc >= length program then state // { reason = "end"; }
        else if elemAt tracker state.pc then state // { reason = "loop"; }
        else execTrackState (execInstruction { state = state; instr = nextInstruction state; }) (updateTracker tracker state.pc);
    in
    execTrackState state initTracker;
  genFixes = program: flip genList (length program) (flip updateAt program (instr:
    if instr.op == "nop" then { op = "jmp"; inherit (instr) arg; }
    else if instr.op == "jmp" then { op = "nop"; inherit (instr) arg; }
    else instr));
in
pipe ./8-input.txt [
  readFile
  (splitString "\n")
  (filter (s: s != ""))
  (map parseInstruction)
  genFixes
  (map (execFinite { acc = 0; pc = 0; }))
  (findSingle (result: result.reason == "end")
    (throw "no terminating program found")
    (throw "multiple terminating programs found"))
  (getAttr "acc")
]
