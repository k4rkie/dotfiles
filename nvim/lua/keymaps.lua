vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })

vim.keymap.set("n", "<leader>qq", ":bd<CR>", { desc = "Close current buffer" })

vim.keymap.set("n", "<leader>rr", ":restart<CR>", { desc = "Restart Nvim" })
vim.keymap.set("n", "<C-e>", ":Oil<CR>", { desc = "Open oil in cwd" })

vim.keymap.set("n", "<C-h>", ":%s/", { desc = "Open search and replace" })

vim.keymap.set("n", "<A-l>", ":tabn<CR>", { desc = "Switch to next tab" })
vim.keymap.set("n", "<A-h>", ":tabp<CR>", { desc = "Switch to pervious tab" })

vim.keymap.set("n", "<A-`>", ":ToggleTerm<CR>", { desc = "Toggle terminal (Ctrl-`)" })
vim.keymap.set("t", "<A-`>", function()
  require("toggleterm").toggle()
end, { desc = "Toggle terminal (Ctrl-`)" })

vim.keymap.set("n", "<leader>dg", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { silent = true })

-- Move selected lines up and down in Visual Mode
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv=gv")

-- Snacks Picker
-- vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.smart({ filter = { cwd = true } })
end, { desc = "Smart find files" })
vim.keymap.set("n", "<leader>fg", function()
  Snacks.picker.grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>gb", function()
  Snacks.picker.grep_buffers()
end, { desc = "Grep open buffer" })
vim.keymap.set("n", "<leader>fb", function()
  Snacks.picker.buffers()
end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.projects()
end, { desc = "Find projects" })
vim.keymap.set("n", "<leader>fh", function()
  Snacks.picker.help()
end, { desc = "Help Pages" })

-- Lsp
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
    end, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
})

vim.keymap.set("n", "gx", [[:silent! execute '!xdg-open ' . shellescape(expand('<cfile>'), 1)<CR>]], { silent = false })
