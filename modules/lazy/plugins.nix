{
  lib,
  flake-parts-lib,
  ...
}:
with lib; let
  inherit (flake-parts-lib) mkPerSystemOption;

  pluginSpec = with types; {
    options = {
      src = mkOption {
        type = nullOr (oneOf [attrs path]);
        default = null;
      };
      package = mkOption {
        type = nullOr package;
        default = null;
      };
      name = mkOption {
        type = nullOr str;
        default = null;
      };
      lazy = mkOption {
        type = nullOr bool;
        default = null;
      };
      dependencies = mkOption {
        type = attrsOf (submodule pluginSpec);
        default = {};
      };
      init = mkOption {
        type = nullOr (oneOf [package path]);
        default = null;
      };
      config = mkOption {
        type = nullOr (oneOf [attrs bool package path str]);
        default = null;
      };
      opts = mkOption {
        type = attrs;
        default = {};
      };
      event = mkOption {
        type = nullOr (oneOf [str (listOf str)]);
        default = null;
      };
      ft = mkOption {
        type = nullOr (oneOf [str (listOf str)]);
        default = null;
      };
      keys = mkOption {
        type = nullOr (oneOf [str (listOf str)]);
        default = null;
      };
      main = mkOption {
        type = nullOr str;
        default = null;
      };
      cmd = mkOption {
        type = nullOr (oneOf [str (listOf str)]);
        default = null;
      };
      priority = mkOption {
        type = nullOr int;
        default = null;
      };
      runtimeDeps = mkOption {
        type = listOf package;
        default = [];
      };
    };
  };
in {
  options = {
    perSystem = mkPerSystemOption ({
      config,
      pkgs,
      ...
    }: let
      cfg = config.neovim.lazy.plugins;
    in {
      options = with types; {
        neovim.lazy.plugins = mkOption {
          type = attrsOf (submodule pluginSpec);
          default = {
          };
        };
      };
    });
  };
}
