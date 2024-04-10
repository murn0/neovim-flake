{
  lib,
  flake-parts-lib,
  ...
}:
with lib; let
  inherit (flake-parts-lib) mkPerSystemOption;
in {
  imports = [
    ./modules/initLua.nix
    ./modules/wrapper.nix
    ./modules/plugins
  ];

  options = {
    perSystem = mkPerSystemOption ({
      config,
      pkgs,
      ...
    }: let
      cfg = config.neovim;
    in {
      options = with types; {
        neovim = {
          package = mkPackageOption pkgs "neovim-unwrapped" {};

          env = mkOption {
            type = attrs;
            default = {};
            description = "Environment variables to bake into the final Neovim derivation's runtime";
          };

          dependencies = mkOption {
            type = listOf package;
            default = [];
            description = "Additional binaries to bake into the final Neovim derivation's PATH";
          };

          configPath = mkOption {
            type = nullOr path;
            default = null;
          };

          initLua = {
            src = mkOption {
              type = nullOr path;
              default = null;
            };
          };

          result = mkOption {
            type = package;
            description = "The final Neovim derivation, with all user configuration baked in";
          };
        };
      };

      config = {
        neovim = {
          result = pkgs.wrapNeovimUnstable cfg.package (cfg.wrapperConfig
            // {
              wrapperArgs = cfg.wrapperConfig.wrapperArgs ++ cfg.extraWrapperArgs;
            });
        };
      };
    });
  };
}
