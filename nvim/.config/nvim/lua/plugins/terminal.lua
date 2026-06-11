return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 15,
      open_mapping = false, -- we set our own keymap
      direction = "horizontal",
      shade_terminals = false,
      persist_size = true,
    })
  end,
}
