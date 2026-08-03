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

-- vim.opt.scrolloff = 999

vim.o.foldlevel = 99

vim.diagnostic.config({
  virtual_text = {
    severity = vim.diagnostic.severity.ERROR,
    format = function(d)
      local msg = d.message:gsub("\n", " ")
      if #msg > 80 then
        return msg:sub(1, 80) .. "…"
      end
      return msg
    end,
  },
  signs = false,
  underline = { severity = vim.diagnostic.severity.ERROR },
  float = {
    border = "single",
    focusable = false,
    scope = "cursor",
  },
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

vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })

vim.api.nvim_set_hl(0, "BlinkCmpMenu", { fg = "#c1c1c1", bg = "#030303" })
vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = "#c1c1c1" })
vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = "#2b2b2b", bold = true })
vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = "#c1c1c1" })
vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = "#e3c5a5" })
vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", { fg = "#999999" })
vim.api.nvim_set_hl(0, "BlinkCmpSource", { fg = "#696969" })

local prompt_bg = "#030303"

vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptCounter", { bg = prompt_bg })


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

-- Disable logging the diagnostics
-- vim.lsp.log.set_level("OFF")
