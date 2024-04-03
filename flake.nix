{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { flake-parts, self, ... } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-linux"];
      
      flake = {
        flakeModule = {
          imports = [./flake-module.nix];
        };
      };

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        ./flake-module.nix
      ];

      perSystem = { config, pkgs, ... }: {

        packages = {
          default = config.packages.result;
          result = config.neovim.result;
        };

        overlayAttrs = {
          inherit (config.packages) default;
        };

        devShells.default = pkgs.mkShell {
          name = "neovim.nix";
          packages = [
            config.neovim.result
          ];
        };

      };
};
}
