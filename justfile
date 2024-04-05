default:
    @just --list

basic:
    nix run ./example#default

local:
    nix run --override-input neovim-flake path:./. ./example#default
