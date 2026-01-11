vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>w', ':w<CR>', {desc = 'Save file'}) --Save file with spcae w 

vim.keymap.set('n', '<leader>qq', ':bd<CR>', {desc = 'Close current buffer'})  --Close the current buffer with space qq

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set('n', '<leader>yy', ':Ex %:p:h<CR>', {desc = 'FileExplorer here'})


vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    vim.keymap.set("n", "q", ":bd<CR>", { buffer = true, silent = true })
  end,
})

