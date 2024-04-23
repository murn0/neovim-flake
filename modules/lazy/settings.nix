{
  lib,
  flake-parts-lib,
  ...
}:
with lib; let
  inherit (flake-parts-lib) mkPerSystemOption;
in {
  options = {
    perSystem = mkPerSystemOption ({
      config,
      pkgs,
      ...
    }: let
      cfg = config.neovim.lazy.settings;
    in {
      options = with types; {
        neovim.lazy.settings = mkOption {
          type = attrs;
          default = {};
        };
      };
    });
  };
}
