require('lazy_setup')
require('options')
require('keymaps')
require('statusline')

-- vim.opt.cursorline = false

vim.cmd(":hi statusline guibg=NONE")

local hl = vim.api.nvim_get_hl(0, { name = "String" })
vim.api.nvim_set_hl(0, "String", {
  fg = hl.fg,
  italic = false,
})

-- Define the colors
vim.api.nvim_set_hl(0, "TodoComment", { fg = "#5f8787", bg = "#121212", bold = true })
vim.api.nvim_set_hl(0, "FixmeComment", { fg = "#af5f5f", bg = "#121212", bold = true })
vim.api.nvim_set_hl(0, "WarningComment", { fg = "#dfaf87", bg = "#121212", bold = true })
vim.api.nvim_set_hl(0, "NoteComment", { fg = "#aaaaaa", bg = "#121212", bold = true })

-- Create a function to apply these patterns to any file you open
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    vim.fn.matchadd("TodoComment", "TODO:")
    vim.fn.matchadd("FixmeComment", "FIXME:")
    vim.fn.matchadd("WarningComment", "WARNING:")
    vim.fn.matchadd("NoteComment", "NOTE:")
  end,
})
