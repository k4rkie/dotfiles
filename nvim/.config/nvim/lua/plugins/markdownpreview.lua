return {
  "iamcco/markdown-preview.nvim",
  lazy = false,
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_port = 9000
    vim.g.mkdp_browser = "helium"
  end,
}
