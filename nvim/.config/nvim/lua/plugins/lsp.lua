return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config.nil_ls = {
        cmd = { "/run/current-system/sw/bin/nil" },
        filetypes = { "nix" },
      }
      vim.lsp.enable("nil_ls")
      vim.lsp.config.lua_ls = {
        cmd = { "/run/current-system/sw/bin/lua-language-server" },
        filetypes = { "lua" },
      }
      vim.lsp.enable("lua_ls")
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    config = function()
      require("blink.cmp").setup({
        fuzzy = { implementation = "lua" },
        completion = {
          menu = {
            scrollbar = false,
          },
        },
      })
    end,
  }
}
