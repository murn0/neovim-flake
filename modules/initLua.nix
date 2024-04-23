{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (lib) mkOption types concatStringsSep optional;
  inherit (flake-parts-lib) mkPerSystemOption;
in {
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
          initLua = {
            preConfig = mkOption {
              type = types.lines;
              default = "";
              description = "Extra contents for init.lua before everything else";
            };

            postConfig = mkOption {
              type = types.lines;
              default = "";
              description = "Extra contents for init.lua before everything else";
            };

            result = mkOption {
              internal = true;
              type = package;
              default = pkgs.writeTextFile {
                name = "init.lua";
                text = concatStringsSep "\n" (
                  optional (cfg.initLua.preConfig != "") ''
                    -- preConfig
                    ${cfg.initLua.preConfig}
                  ''
                  ++ [
                    ''
                      -- Load ${cfg.initLua.src}
                      ${builtins.readFile "${cfg.initLua.src}"}
                    ''
                  ]
                  ++ optional (cfg.lazy.plugins != {}) ''
                    -- Load plugins setting
                    vim.cmd.source "${cfg.lazy.result}"
                  ''
                  ++ optional (cfg.initLua.preConfig != "") ''
                    -- postConfig
                    ${cfg.initLua.postConfig}
                  ''
                );
              };
            };
          };
        };
      };
    });
  };
}
