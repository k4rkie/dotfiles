vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.mouse = "a"

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
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
vim.opt.signcolumn = "number"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.undofile = true

vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 0
vim.opt.winborder = "single"

vim.opt.foldlevel = 99
vim.opt.autoread = true

vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
  },
  signs = false,
  underline = { severity = vim.diagnostic.severity.ERROR },
})

-- Define explicit colors for LSP diagnostics
-- ColorScheme autocmd ensures these survive async colorscheme loads (base16)
local function set_diagnostic_hl()
  local set_hl = vim.api.nvim_set_hl

  set_hl(0, "DiagnosticError", { fg = "#FF5555", bold = true })
  set_hl(0, "DiagnosticWarn", { fg = "#E5C07B" })
  set_hl(0, "DiagnosticInfo", { fg = "#E5C07B" })
  set_hl(0, "DiagnosticHint", { fg = "#E5C07B" })

  set_hl(0, "DiagnosticVirtualTextError", { fg = "#FF5555" })
  set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#E5C07B" })
  set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#E5C07B" })
  set_hl(0, "DiagnosticVirtualTextHint", { fg = "#E5C07B" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserDiagnosticHL", { clear = true }),
  pattern = "*",
  callback = set_diagnostic_hl,
})
vim.schedule(set_diagnostic_hl)

vim.opt.guicursor = {
  "n-v-c:block",
  "i:block",
  "r:block",
  "o:block",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions = vim.opt_local.formatoptions
        - "r"
        - "o"
        - "c"
  end
})

-- Define the colors
vim.api.nvim_set_hl(0, "TodoComment", { fg = "#83a598", bg = "#1a1a1a", bold = true })
vim.api.nvim_set_hl(0, "FixmeComment", { fg = "#fb4934", bg = "#1a1a1a", bold = true })
vim.api.nvim_set_hl(0, "WarningComment", { fg = "#fe8019", bg = "#1a1a1a", bold = true })
vim.api.nvim_set_hl(0, "NoteComment", { fg = "#a89984", bg = "#1a1a1a", bold = true })

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

-- highlight yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.highlight.on_yank({ timeout = 200, visual = true })
  end,
})

-- restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
      -- defer centering slightly so it's applied after render
      vim.schedule(function()
        vim.cmd("normal! zz")
      end)
    end
  end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  command = "wincmd L",
})

-- Disable logging the diagnostics
vim.lsp.log.set_level("OFF")
