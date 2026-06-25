#!/usr/bin/env bash

exec tmux new-session -A -s vscode-$(basename $PWD)

