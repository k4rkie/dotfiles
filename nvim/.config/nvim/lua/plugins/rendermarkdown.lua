return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
  config = function()
    require('render-markdown').setup({
      render_modes = true,
      completions = { lsp = { enabled = true } },
      pipe_table = { preset = 'heavy' },
      link = { hyperlink = '󰌷 ' },
      heading = {
        sign = false,
        icons = { ' ', ' ', ' ', ' ', ' ', ' ' },
        position = 'inline',
      },
    })
  end
}
