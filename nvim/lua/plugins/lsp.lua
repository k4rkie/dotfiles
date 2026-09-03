return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Enable file watching so basedpyright/pyright picks up new files without restart
      -- blink.cmp + nvim defaults have didChangeWatchedFiles.dynamicRegistration = false
      local base_caps = require("blink.cmp").get_lsp_capabilities({
        workspace = {
          didChangeWatchedFiles = { dynamicRegistration = true, relativePatternSupport = true },
          fileOperations = {
            dynamicRegistration = true,
            didCreate = true,
            didRename = true,
            didDelete = true,
            willCreate = true,
            willRename = true,
            willDelete = true,
          },
        },
      })

      vim.lsp.config("*", {
        capabilities = base_caps,
      })

      -- basedpyright: ensure workspace diagnostics + auto search paths
      -- pyproject.toml handles most of this, but lsp settings act as fallback
      vim.lsp.config("basedpyright", {
        capabilities = base_caps,
        settings = {
          basedpyright = {
            analysis = {
              diagnosticMode = "workspace",
              autoSearchPaths = true,
              autoImportCompletions = true,
              typeCheckingMode = "basic",
            },
          },
        },
      })

      vim.lsp.config("nil_ls", {
        settings = {
          ["nil"] = {
            formatting = {
              command = { "nixfmt" },
            },
            nix = {
              flake = {
                autoArchive = false,
                autoEvalInputs = false,
              },
            },
          },
        },
      })
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
