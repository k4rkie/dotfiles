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
          max_width = 0.9,
          min_width = { 40, 0.4 },
          width = nil,
          max_height = 0.9,
          min_height = { 5, 0.1 },
          height = nil,
          border = true,
          win_options = {
            winblend = 0,
          }
        },
        float = {
          padding = 2,
          max_width = 0.8,
          max_height = 0.8,
          border = nil,
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
