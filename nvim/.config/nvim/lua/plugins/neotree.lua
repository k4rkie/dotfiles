return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function ()
        require("neo-tree").setup({
            sources = { "filesystem" },
            window = {
                width = 20,
            },
            -- git_status = {
            --     follow_current_file = true,
            --     symbols = {
            --         unstaged = "[U]",
            --         staged = "[S]",
            --     },
            -- },
        })
    end
}
}
