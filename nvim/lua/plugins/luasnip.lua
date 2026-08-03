return {
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      -- This loads all the snippets from friendly-snippets
      -- (React, JS, Go, Rust, etc.)
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
