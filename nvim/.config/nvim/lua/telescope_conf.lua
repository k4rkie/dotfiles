
require("telescope").setup({
  pickers = {
    find_files = {
    }
  },
  defaults = {
    border = true,
    results_title = false,
    preview_title = false,

    borderchars = {
      "─", "│", "─", "│",
      "╭", "╮", "╯", "╰",
    },

    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "bottom",
      width = 0.9,
      height = 0.85,
      preview_width = 0.6,
    },

    sorting_strategy = "descending",
    winblend = 0,
    selection_caret = "➜ ",
    entry_prefix = "  ",
    path_display = { "truncate" },
  },
  extensions = {
    fzf = {}
  }
})

vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })

local prompt_bg = "#080808" 

vim.api.nvim_set_hl(0, "TelescopePromptNormal",  { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptBorder",  { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptTitle",   { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix",  { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptCounter", { bg = prompt_bg })
