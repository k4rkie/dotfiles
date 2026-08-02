return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      require("oil").setup({
        confirmation = {
          max_width = 0.35,
          min_width = { 24, 0.25 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = "single",
          win_options = {
            winblend = 0,
          }
        },
        float = {
          padding = 1,
          max_width = 0.7,
          max_height = 0.6,
          border = "single",
          win_options = {
            winblend = 0,
          },
          get_win_title = nil,
        },
        view_options = {
          show_hidden = true
        },
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },
        delete_to_trash = true,
      })
    end
  }
}
