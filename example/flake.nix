{
  description = "Basic usage of murn0/neovim-flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    neovim-flake.url = "github:murn0/neovim-flake";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.neovim-flake.flakeModule
      ];

      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
      perSystem = {
        config,
        # inputs',
        pkgs,
        ...
      }: {
        neovim = {
          # package = inputs'.neovim-nightly.packages.neovim;
          configPath = ./.;
          initLua.src = ./init.lua;
        };

        packages = {
          default = config.neovim.result;
        };
      };
    };
}
