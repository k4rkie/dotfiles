vim.g.mapleader = ' '

vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })            --Save file with spcae w

vim.keymap.set('n', '<leader>qq', ':bd<CR>', { desc = 'Close current buffer' }) --Close the current buffer with space qq

vim.keymap.set('n', "<C-e>",function() require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })end, { desc = 'Neotree cwd' })


----------------------------------------------------------------------------------------------------------------------
-- Telescope Nvim

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>gb', builtin.current_buffer_fuzzy_find, { desc = 'Telescope fuzzy search current buffer' })
vim.keymap.set('n', '<leader>mp', builtin.man_pages, { desc = 'Telescope search man pages' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>km', builtin.keymaps, { desc = 'Telescope search keymaps' })

vim.keymap.set('n', '<leader>nv', function()
    builtin.find_files {
        cwd = vim.fn.stdpath("config")
    }
end, { desc = 'Telescope open nvim config directory' })

vim.keymap.set('n', '<leader>ff', function()
    require('telescope').extensions['recent-files'].recent_files({})

end, { noremap = true, silent = true })

----------------------------------------------------------------------------------------------------------------------
-- Harpoon
local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>hp", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-j>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():next() end)

----------------------------------------------------------------------------------------------------------------------
