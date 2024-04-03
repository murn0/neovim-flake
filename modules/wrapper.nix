{lib, flake-parts-lib, ...}:
with lib; let
  inherit (builtins) path isPath;
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
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
          wrapperConfig = mkOption {
            type = attrs;
            default = pkgs.neovimUtils.makeNeovimConfig {
              withNodeJs = true;

              # luaRcContentなどに指定したluaコードをinit.luaとして出力しない
              # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/neovim/wrapper.nix
              wrapRc = false;
            };
          };

          extraWrapperArgs = mkOption {
            type = listOf str;
            default = let
              configDir = pkgs.symlinkJoin {
                name = "neovim-config-dir";
                paths = (path {
                  name = "neovim-config-dir-src";
                  path = cfg.configPath;
                  filter = path: type: type == "directory" || hasSuffix ".lua" path;
                });
              };
            in
              optionals (cfg.env != {}) (
                flatten
                  (mapAttrsToList
                    (name: value: [ "--set" "${name}" "${value}" ])
                    cfg.env)
              )
              ++ optionals (cfg.dependencies != []) [
                "--prefix" "PATH" ":" "${makeBinPath cfg.dependencies}"
              ]
              ++ optionals (isPath cfg.configPath) [
                "--add-flags"
                ''--cmd "set runtimepath^=${configDir}"''
              ]
              ++ optionals (isPath cfg.initLua.src) [
                "--add-flags"
                ''-u ${cfg.initLua.result}''
              ];
          };
        };
      };
    });
  };
}
