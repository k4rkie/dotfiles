return {
  'stevearc/conform.nvim',
  config = function()
    require("conform").setup({
      formatters = {
        prettier = {
          command = "prettier",
        },
        gofmt = {
          command = "gofmt"
        }
      },
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        go = { "gofmt" },
      },
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
    })
  end,
}
