vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })            --Save file with spcae w

vim.keymap.set('n', '<leader>qq', ':bd<CR>', { desc = 'Close current buffer' }) --Close the current buffer with space qq


----------------------------------------------------------------------------------------------------------------------
-- Telescope Nvim

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>gb', builtin.current_buffer_fuzzy_find, { desc = 'Telescope fuzzy search current buffer' })
vim.keymap.set('n', '<leader>mp', builtin.man_pages, { desc = 'Telescope search man pages' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>nv', function()
    builtin.find_files {
        cwd = vim.fn.stdpath("config")
    }
end, { desc = 'Open nvim config directory' })

vim.keymap.set('n', '<leader>ff', function()
    require('telescope').extensions['recent-files'].recent_files({})
end, { noremap = true, silent = true })


----------------------------------------------------------------------------------------------------------------------
