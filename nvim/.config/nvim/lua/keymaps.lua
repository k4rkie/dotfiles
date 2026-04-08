
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })

vim.keymap.set("n", "<leader>qq", ":bd<CR>", { desc = "Close current buffer" })

vim.keymap.set("n", "<C-e>", ":Oil<CR>", { desc = "Open oil" })

vim.keymap.set("n", "<A-l>", ":tabn<CR>", { desc = "Switch to next tab" })
vim.keymap.set("n", "<A-h>", ":tabp<CR>", { desc = "Switch to pervious tab" })

-- Telescope 

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>gb", builtin.current_buffer_fuzzy_find, { desc = "Telescope fuzzy search current buffer" })
vim.keymap.set("n", "<leader>mp", builtin.man_pages, { desc = "Telescope search man pages" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>km", builtin.keymaps, { desc = "Telescope search keymaps" })

vim.keymap.set("n", "<leader>nv", function()
  builtin.find_files {
    cwd = vim.fn.stdpath("config")
  }
end, { desc = "Telescope open nvim config directory" })

vim.keymap.set("n", "<leader>ff", function()
  require("telescope").extensions["recent-files"].recent_files({})

end, { noremap = true, silent = true }, { desc = "Telescope find files" })

-- Lsp
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
})

