return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- nix lsp
      vim.lsp.config.nil_ls = {
        cmd = { "/run/current-system/sw/bin/nil" },
        filetypes = { "nix" },
      }
      vim.lsp.enable("nil_ls")


      -- golang lsp
      vim.lsp.config.gopls = {
        cmd = { "/run/current-system/sw/bin/gopls" },
        filetypes = { "go" },
      }
      vim.lsp.enable("gopls")

      -- lua lsp
      vim.lsp.config.lua_ls = {
        cmd = { "/run/current-system/sw/bin/lua-language-server" },
        filetypes = { "lua" },
      }
      vim.lsp.enable("lua_ls")


      -- c/cpp lsp
      vim.lsp.config.clangd = {
        cmd = { "/run/current-system/sw/bin/clangd" },
        filetypes = { "c" },
      }
      vim.lsp.enable("clangd")


      -- typescript-language-server
      vim.lsp.config.typescript_ls = {
        cmd = { "/run/current-system/sw/bin/typescript-language-server", "--stdio" },
        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
      }
      vim.lsp.enable("typescript_ls")
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
