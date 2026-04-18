require('lazy_setup')
require('options')
require('keymaps')
require('statusline')

vim.opt.cursorline = false

vim.cmd(":hi statusline guibg=NONE")

local hl = vim.api.nvim_get_hl(0, { name = "String" })
vim.api.nvim_set_hl(0, "String", {
  fg = hl.fg,
  italic = false,
})
