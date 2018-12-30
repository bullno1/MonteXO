# MonteXO - A simple TicTacToe AI using Monte Carlo Tree Search

[![License](https://img.shields.io/badge/license-BSD-blue.svg)](LICENSE)

This is a fairly unoptimized generic implementation of Monte Carlo Tree Search (MCTS) in Lua.

## How to run

[Love2D](https://love2d.org/) is required.

```sh
love .
```

Click on any tile to put your piece.

## Known issues

Sometime, the AI is too focused on building its own chain that it ignores obvious threats.
Some paramters could be tweaked but I have not found the right values.
Some domain knowledge of the game could be added to `Rule.getValidMoves` but I do not really have any.
