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
        neovim = {
          lazy = {
            package = mkPackageOption pkgs.vimPlugins "lazy.nvim" {
              default = "lazy-nvim";
              pkgsText = "pkgs.vimPlugins";
            };

            settings = mkOption {
              type = submodule {
                # freeformType = attrsOf anything;
                options = {
                  # dev = {
                  #   path = mkOption {
                  #     type = nullOr (oneOf [path str]);
                  #     default = null;
                  #   };
                  # };
                  install = {
                    missing = mkOption {
                      type = bool;
                      default = false;
                    };
                  };
                };
              };
            };

            result = mkOption {
              type = package;
              internal = true;
            };
          };
        };
      };

      config = {
        neovim = {
          lazy = {
            result = let
              opts = lib.generators.toLua {} ({performance.rtp.reset = false;} // cfg.settings);
            in
              pkgs.runCommand "plugins.lua" {
                nativeBuildInputs = with pkgs; [stylua];
                passAsFile = ["text"];
                preferLocalBuild = true;
                allowSubstitutes = false;
                text = ''
                  vim.opt.rtp:prepend "${cfg.package}"
                  require("lazy").setup({}, ${opts})
                '';
              } ''
                target=$out
                mkdir -p "$(dirname "$target")"
                if [ -e "$textPath" ]; then
                  mv "$textPath" "$target"
                else
                  echo -n "$text" > "$target"
                fi

                stylua --config-path ${../stylua.toml} $target
              '';
          };
        };
      };
    });
  };
}
