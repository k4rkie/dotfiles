local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local plugins = require("plugins") -- loads lua/plugins/init.lua

require("lazy").setup(plugins)




-- Setup lazy.nvim
-- require("lazy").setup({
-- {
--   "nvim-telescope/telescope.nvim",
--   tag = "v0.2.0",
--   dependencies = { "nvim-lua/plenary.nvim", "mollerhoj/telescope-recent-files.nvim", },
--   config = function()
--      require("telescope").load_extension("recent-files")
--   end
-- },
-- Markdown Renderer
-- {
--   "MeanderingProgrammer/render-markdown.nvim",
--   dependencies = {
--     "nvim-treesitter/nvim-treesitter",
--     "nvim-mini/mini.nvim",
--   },
--   opts = {},
-- },
-- Cool Icons
-- { "nvim-tree/nvim-web-devicons", opts = {} },
-- Flash
-- {
--   "folke/flash.nvim",
--   event = "VeryLazy",
--   opts = {},
--   keys = {
--     { "S", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
--   },
-- },
-- -- Autopairs
-- {
--   "windwp/nvim-autopairs",
--   event = "InsertEnter",
--   opts = {},
-- },
-- LSP support
-- {
--     "mason-org/mason-lspconfig.nvim",
--     opts = {},
--     dependencies = {
--         { "mason-org/mason.nvim", opts = {} },
--         "neovim/nvim-lspconfig",
--     },
-- },
-- Minimal autocomplete
-- {
--     "saghen/blink.cmp",
--     version = "1.*",
--     config = function()
--         require("blink.cmp").setup({
--         fuzzy = { implementation = "lua" }
--         })
--     end,
-- },
-- {
--     "akinsho/toggleterm.nvim",
--     version = "*",
--     config = function()
--         require("toggleterm").setup{
--             size = 20,
--             open_mapping = [[<C-\>]],
--             shade_terminals = true,
--             direction = "float",      -- float / horizontal / vertical
--             close_on_exit = true,
--         }
--     end
-- },
-- -- ---@type LazySpec
-- {
--   "mikavilpas/yazi.nvim",
--   version = "*", -- use the latest stable version
--   event = "VeryLazy",
--   dependencies = {
--     { "nvim-lua/plenary.nvim", lazy = true },
--   },
--   keys = {
--     -- 👇 in this section, choose your own keymappings!
--     {
--       "<leader>yy",
--       mode = { "n", "v" },
--       "<cmd>Yazi<cr>",
--       desc = "Open yazi at the current file",
--     },
--     {
--       -- Open in the current working directory
--       "<leader>cw",
--       "<cmd>Yazi cwd<cr>",
--       desc = "Open the file manager in nvim's working directory",
--     },
--     {
--       "<c-up>",
--       "<cmd>Yazi toggle<cr>",
--       desc = "Resume the last yazi session",
--     },
--   },
--   ---@type YaziConfig | {}
--   opts = {
--     -- if you want to open yazi instead of netrw, see below for more info
--     open_for_directories = false,
--     keymaps = {
--       show_help = "<f1>",
--     },
--   },
--   -- 👇 if you use `open_for_directories=true`, this is recommended
--   init = function()
--     -- mark netrw as loaded so it's not loaded at all.
--     --
--     -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
--     vim.g.loaded_netrwPlugin = 1
--   end,
-- },
-- Surround Nvim
-- {
--   "kylechui/nvim-surround",
--   version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
--   event = "VeryLazy",
--   config = function()
--       require("nvim-surround").setup({
--         keymaps = {
--           normal = "sn",
--           visual = "sn"
--         }
--       })
--   end
-- },
-- {
--   'brenoprata10/nvim-highlight-colors',
--   config = function()
--   	require('nvim-highlight-colors').setup({})
--   end
-- },
-- })
