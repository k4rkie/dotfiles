return {
  -- 1. The Rocks provider (handles the 'magick' dependency)
  {
    "vhyrro/luarocks.nvim",
    priority = 1000,
    cmd = { "LazyRocks" },
    opts = {
      rocks = { "magick" },
    },
  },
  -- 2. The Image plugin itself
  {
    "3rd/image.nvim",
    dependencies = { "luarocks.nvim" },
    config = function()
      require("image").setup({
        backend = "kitty", -- Best for Arch (Kitty/WezTerm)
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
        },
        max_width = 100,
        max_height = 12,
        window_overlap_clear_enabled = true,
        -- Crucial for your Tmux setup
        tmux_passthrough_enabled = true,
      })
    end,
  },
}
