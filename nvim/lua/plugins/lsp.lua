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
        cmd = { "nil" },
        filetypes = { "nix" },
        settings = {
          ["nil"] = {
            nix = {
              flake = {
                autoArchive = false,
              },
            },
          },
        },
      }
      vim.lsp.enable("nil_ls")

      -- golang lsp
      vim.lsp.config.gopls = {
        cmd = { "gopls" },
        filetypes = { "go" },
      }
      vim.lsp.enable("gopls")

      -- lua lsp
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
      }
      vim.lsp.enable("lua_ls")

      -- c/cpp lsp
      vim.lsp.config.clangd = {
        cmd = { "clangd" },
        filetypes = { "c" },
      }
      vim.lsp.enable("clangd")

      -- zig lsp
      vim.lsp.config.zls = {
        cmd = { "zls" },
        filetypes = { "zig" },
      }
      vim.lsp.enable("zls")

      vim.lsp.config.rust_analyzer = {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
      }
      vim.lsp.enable("rust_analyzer")

      -- typescript-language-server
      vim.lsp.config.typescript_ls = {
        cmd = { "typescript-language-server", "--stdio" },
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
            border = "single",
            min_width = 15,
            max_height = 8,
            scrollbar = false,
            winhighlight =
            "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
          },
        },
      })
    end,
  }
}
