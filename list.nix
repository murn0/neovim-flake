{
  plugins = {
    nvim-treesitter = {
      runtimeDeps = ["ripgrep"];
      config = ../plugins/treesitter.lua;
      event = ["BufReadPost"];
      dependencies = {
        nvim-treesitter-textobjects = {
          dependencies = {
            plugins2 = {
              runtimeDeps = ["plugins2deps"];
            };
          };
          runtimeDeps = [
            "jq"
            "git"
          ];
        };
      };
    };
  };
}
