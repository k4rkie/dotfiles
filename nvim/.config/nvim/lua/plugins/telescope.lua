return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.0",
  dependencies = { "nvim-lua/plenary.nvim", "mollerhoj/telescope-recent-files.nvim" },
  config = function()
    require("telescope").load_extension("recent-files")
  end,
}

