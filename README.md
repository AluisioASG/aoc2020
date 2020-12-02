<!--
SPDX-FileCopyrightText: 2020 Aluísio Augusto Silva Gonçalves <https://aasg.name>

SPDX-License-Identifier: CC0-1.0
-->

# Advent of Code 2020

This repository contains [my] solutions to the puzzles from [Advent of Code 2020].

So far I've been writing the solutions as [Nix] expressions.
You can run them with:

```sh
nix-instantiate --eval --strict --expr "import ./$DAY-$TASK.nix {}"
```

[advent of code 2020]: https://adventofcode.com/2020
[my]: https://aasg.name
[nix]: https://nixos.org
