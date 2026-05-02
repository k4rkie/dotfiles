return {
  "ej-shafran/compile-mode.nvim",
  version = "^5.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "m00qek/baleia.nvim",
    tag = "v1.3.0"
  },
  config = function()
    ---@type CompileModeOpts
    vim.g.compile_mode = {
      -- Visuals & Focus
      baleia_setup = true,             -- Colors in the output
      focus_compilation_buffer = true, -- Jump to the window on run
      auto_scroll = true,              -- Follow the output

      -- Pro integration
      use_diagnostics = true, -- Show errors in the code itself

      -- Behavior
      ask_about_save = true, -- Always save before building
    }
  end
}
