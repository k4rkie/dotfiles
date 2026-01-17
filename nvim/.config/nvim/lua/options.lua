vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.mouse = "a"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.undofile = true

vim.opt.clipboard = "unnamedplus"

vim.opt.cmdheight = 0

vim.diagnostic.config({
    virtual_text = { severity = vim.diagnostic.severity.ERROR },
    signs = false,
    underline = false,
    -- virtual_lines = true,
})

vim.opt.guicursor = {
  "n-v-c:block",
  "i:block",
  "r:block",
  "o:block",
}

-- colorscheme
vim.cmd[[colorscheme jellybeans-muted]]

vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })

local prompt_bg = "#111111" 

vim.api.nvim_set_hl(0, "TelescopePromptNormal",  { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptTitle",   { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix",  { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptCounter", { bg = prompt_bg })
