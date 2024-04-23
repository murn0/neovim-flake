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
      cfg = config.neovim.lazy;
    in {
      options = with types; {
        neovim.lazy = {
          package = mkPackageOption pkgs.vimPlugins "lazy.nvim" {
            default = "lazy-nvim";
            pkgsText = "pkgs.vimPlugins";
          };

          result = mkOption {
            type = package;
            internal = true;
          };
        };
      };

      config = {
        neovim = {
          lazy = {
            result = let
              baseSettings = {
                # cfg.settingsで上書き可
                defaults.lazy = true;
                performance.rtp.reset = false;
                install.missing = false;
                disabled_plugins = [
                  "gzip"
                  "matchit"
                  "matchparen"
                  "netrwPlugin"
                  "shada"
                  "spellfile"
                  "tarPlugin"
                  "tohtml"
                  "zipPlugin"
                ];
              };

              opts = generators.toLua {} (baseSettings // cfg.settings);

              mkPlugin = name: attrs:
                {
                  inherit name;
                  dir =
                    if attrs.package != null
                    then attrs.package
                    else
                      buildVimPlugin {
                        inherit name;
                        inherit (attrs) src;
                        leaveDotGit = true; # So some lazy features (commands) work properly
                      };
                }
                // optionalAttrs (attrs.dependencies != {}) {
                  dependencies = let
                    deps = mapAttrs mkPlugin attrs.dependencies;
                  in
                    attrValues deps;
                }
                // optionalAttrs (isDerivation attrs.init || isPath attrs.init) {
                  init = lib.generators.mkLuaInline ''dofile "${attrs.init}"'';
                }
                // optionalAttrs (isBool attrs.config) {
                  inherit (attrs) config;
                }
                // optionalAttrs (isString attrs.config) {
                  config = lib.generators.mkLuaInline attrs.config;
                }
                // optionalAttrs (isDerivation attrs.config || isPath attrs.config) {
                  config = lib.generators.mkLuaInline ''dofile "${attrs.config}"'';
                }
                // optionalAttrs (isAttrs attrs.config) {
                  config = true;
                  opts = attrs.config;
                }
                // filterAttrsRecursive (n: v: v != null) (getAttrs [
                    "lazy"
                    "event"
                    "ft"
                    "keys"
                    "priority"
                    "main"
                    "cmd"
                  ]
                  attrs);

              spec = generators.toLua {} (mapAttrsToList mkPlugin cfg.plugins);
            in
              pkgs.runCommand "plugins.lua" {
                nativeBuildInputs = with pkgs; [stylua];
                passAsFile = ["text"];
                preferLocalBuild = true;
                allowSubstitutes = false;
                text = ''
                  vim.opt.rtp:prepend "${cfg.package}"
                  require("lazy").setup(${spec}, ${opts})
                '';
              } ''
                target=$out
                mkdir -p "$(dirname "$target")"
                if [ -e "$textPath" ]; then
                  mv "$textPath" "$target"
                else
                  echo -n "$text" > "$target"
                fi

                stylua --config-path ${../../stylua.toml} $target
              '';
          };

          dependencies = let
            mapPluginsRec = fn: lib.mapAttrsToList (name: attrs: (fn name attrs) ++ (lib.mapAttrsToList fn attrs.dependencies)) cfg.plugins;
            collect = mapPluginsRec (name: attrs: attrs.runtimeDeps);
          in
            mkAfter (flatten collect);
        };
      };
    });
  };
}
