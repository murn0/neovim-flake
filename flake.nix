{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-nix.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    flake-parts,
    self,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];

      flake = {
        flakeModule = {
          imports = [./flake-module.nix];
        };
      };

      imports = [
        inputs.pre-commit-nix.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
        ./flake-module.nix
      ];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        packages = {
          default = config.packages.result;
          result = config.neovim.result;
        };

        overlayAttrs = {
          inherit (config.packages) default;
        };

        apps = {
          basic.program = pkgs.writeShellApplication {
            name = "example-basic";
            text = ''
              nix run ./example#default
            '';
          };

          check-local.program = pkgs.writeShellApplication {
            name = "check-local";
            text = ''
              nix run --override-input neovim-flake path:./. ./example#default
            '';
          };
        };

        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          name = "neovim.nix";
          packages = [
            config.neovim.result
          ];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        pre-commit = {
          settings = {
            hooks.alejandra.enable = true;
            hooks.stylua.enable = true;
          };
        };
      };
    };
}
