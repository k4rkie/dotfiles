return {
  {
      "mason-org/mason-lspconfig.nvim",
      opts = {},
      dependencies = {
          { "mason-org/mason.nvim", opts = {} },
          "neovim/nvim-lspconfig",
      },
  },
  {
        "saghen/blink.cmp",
        version = "1.*",
        config = function()
            require("blink.cmp").setup({
            fuzzy = { implementation = "lua" } 
            })
        end,
    }	
}
