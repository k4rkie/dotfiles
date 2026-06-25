return {
  "iamcco/markdown-preview.nvim",
  lazy = false,
  build = function()
    local path = vim.fn.fnamemodify(vim.fn.finddir("markdown-preview.nvim", "~"), ":h")
    vim.fn.jobstart({ "nix-shell", "-p", "nodejs", "--run", "cd " .. path .. "/app && npm install" })
  end,
  init = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
    vim.g.mkdp_port = 9000
    vim.g.mkdp_browser = vim.fn.executable("zen-beta") == 1 and "zen-beta" or "firefox"
  end,
}
