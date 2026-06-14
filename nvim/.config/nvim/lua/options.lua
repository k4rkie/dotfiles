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
vim.opt.signcolumn = "yes"

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.undofile = true

vim.opt.clipboard = "unnamedplus"

vim.opt.cmdheight = 0

vim.opt.winborder = "single"

vim.opt.scrolloff = 999

vim.diagnostic.config({
  virtual_text = { severity = vim.diagnostic.severity.ERROR },
  -- virtual_text = false,
  signs = false,
  underline = { severity = vim.diagnostic.severity.ERROR },
  -- underline = false,
})

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

local prompt_bg = "#000000"

vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = prompt_bg })
vim.api.nvim_set_hl(0, "TelescopePromptCounter", { bg = prompt_bg })


-- Built-In tabline config
vim.o.showtabline = 2

-- set the tabline to a Lua function
vim.o.tabline = "%!v:lua.tabline()"

function _G.tabline()
  local s = ""
  for i = 1, vim.fn.tabpagenr("$") do
    local buflist = vim.fn.tabpagebuflist(i)
    local winnr = vim.fn.tabpagewinnr(i)
    local buf = buflist[winnr]
    local bufname = vim.fn.bufname(buf)
    -- placeholder for unnamed buffers
    if bufname == "" then
      bufname = "[No Name]"
    end
    -- filename only
    bufname = vim.fn.fnamemodify(bufname, ":t")
    -- show [+] if the buffer is modified
    if vim.fn.getbufvar(buf, "&mod") == 1 then
      bufname = bufname .. " [+]"
    end
    -- highlight current tab
    if i == vim.fn.tabpagenr() then
      s = s .. "%#TabLineSel#"
    else
      s = s .. "%#TabLine#"
    end
    -- make tab clickable
    s = s .. "%" .. i .. "T"

    -- add filename
    s = s .. " " .. bufname .. " "
  end
  -- fill the rest
  s = s .. "%#TabLineFill#"
  return s
end

vim.api.nvim_set_hl(0, "TabLineSel", {
  fg = "#000000",
  bg = "#888888",
  bold = true,
})
vim.api.nvim_set_hl(0, "TabLine", {
  fg = "#c1c1c1",
  bg = "#000000",
})

vim.api.nvim_set_hl(0, "TabLineFill", {
  bg = "#000000",
})

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
vim.lsp.log.set_level("OFF")
