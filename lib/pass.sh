#!/usr/bin/env bash
cd $(dirname $0)/..

nix run .#pass-nix -- $@
