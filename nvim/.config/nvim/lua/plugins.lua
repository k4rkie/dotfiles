local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" if not (vim.uv or vim.loop).fs_stat(lazypath) then
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

-- Setup lazy.nvim
require("lazy").setup({

  {
    "RRethy/nvim-base16",
    priority = 1000,
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.0",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.nvim",
    },
    opts = {},
  },

  { "nvim-tree/nvim-web-devicons", opts = {} },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  -- LSP support
  {
      "mason-org/mason-lspconfig.nvim",
      opts = {},
      dependencies = {
          { "mason-org/mason.nvim", opts = {} },
          "neovim/nvim-lspconfig",
      },
  },
  -- Minimal autocomplete
    {
        "saghen/blink.cmp",
        version = "1.*",
        config = function()
            require("blink.cmp").setup({
            fuzzy = { implementation = "lua" } 
            })
        end,
    },
  {
      "akinsho/toggleterm.nvim",
      version = "*",
      config = function()
          require("toggleterm").setup{
              size = 20,
              open_mapping = [[<C-\>]],
              shade_terminals = true,
              direction = "float",      -- float / horizontal / vertical
              close_on_exit = true,
          }
      end
  },
})

