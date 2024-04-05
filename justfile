default:
    @just --list

basic:
    nix run ./example#default

dev:
    nix run ./dev#default

local:
    nix run --override-input neovim-flake path:./. ./example#default
