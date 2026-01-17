return {
  "nvim-telescope/telescope.nvim",
  tag = "v0.2.0",
  dependencies = { "nvim-lua/plenary.nvim", "mollerhoj/telescope-recent-files.nvim" },
  config = function()
    require("telescope").load_extension("recent-files")
    require("telescope").setup({
        pickers = {
            find_files = {
            }
        },
        defaults = {
            file_ignore_patterns = {
                "node_modules",
                "venv",
                "%.venv",
                "__pycache__",
            },

            border = true,
            results_title = false,
            preview_title = false,

            borderchars = {
                "─", "│", "─", "│",
                "╭", "╮", "╯", "╰",
            },

            layout_strategy = "horizontal",
            layout_config = {
                prompt_position = "bottom",
                width = 0.9,
                height = 0.85,
                preview_width = 0.6,
            },

            sorting_strategy = "descending",
            winblend = 0,
            selection_caret = "➜ ",
            entry_prefix = "  ",
            path_display = { "truncate" },
        },
        extensions = {
            fzf = {}
        },

    })
end,
}

