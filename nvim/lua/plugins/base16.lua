return {
  "RRethy/base16-nvim",
  lazy = false,    -- load at startup
  priority = 1000, -- load before other plugins
  config = function()
    local base16 = require("base16-colorscheme")

    base16.setup({
      --Black Metal Bathory

      -- base00 = "#000000",
      -- base01 = "#121212",
      -- base02 = "#222222",
      -- base03 = "#333333",
      -- base04 = "#999999",
      -- base05 = "#c1c1c1",
      -- base06 = "#999999",
      -- base07 = "#c1c1c1",
      -- base08 = "#5f8787",
      -- base09 = "#aaaaaa",
      -- base0A = "#e78a53",
      -- base0B = "#fbcb97",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",

      --Black Metal Bathory Tweaked

      base00 = "#030303",
      base01 = "#080808",
      base02 = "#121212",
      base03 = "#333333",
      base04 = "#999999",
      base05 = "#c1c1c1",
      base06 = "#999999",
      base07 = "#c1c1c1",
      base08 = "#82709c",
      base09 = "#aaaaaa",
      base0A = "#d1a76b",
      base0B = "#e3c5a5",
      base0C = "#aaaaaa",
      base0D = "#696969",
      base0E = "#999999",
      base0F = "#444444",
    })
  end,
}
