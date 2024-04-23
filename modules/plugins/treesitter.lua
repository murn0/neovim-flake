return function()
  require("nvim-treesitter.configs").setup({
    auto_install = false,
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<M-Up>", -- 選択範囲の拡大
        node_incremental = "<M-Up>", -- 選択範囲の拡大
        scope_incremental = false,
        node_decremental = "<M-Down>", -- 選択範囲の縮小
      },
    },
  })
end
