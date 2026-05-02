return {
  "RRethy/base16-nvim",
  lazy = false,    -- load at startup
  priority = 1000, -- load before other plugins
  config = function()
    local base16 = require("base16-colorscheme")

    base16.setup({

      -- Black Metal Base

      -- base00 = "#080808",
      -- base01 = "#121212",
      -- base02 = "#222222",
      -- base03 = "#333333",
      -- base04 = "#999999",
      -- base05 = "#c1c1c1",
      -- base06 = "#999999",
      -- base07 = "#c1c1c1",
      -- base08 = "#5f8787",
      -- base09 = "#aaaaaa",
      -- base0A = "#a06666",
      -- base0B = "#dd9999",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",

      --Black Metal Venom

      -- base00 = "#080808",
      -- base01 = "#121212",
      -- base02 = "#222222",
      -- base03 = "#333333",
      -- base04 = "#999999",
      -- base05 = "#c1c1c1",
      -- base06 = "#999999",
      -- base07 = "#c1c1c1",
      -- base08 = "#5f8787",
      -- base09 = "#aaaaaa",
      -- base0A = "#79241f",
      -- base0B = "#f8f7f2",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",

      --Black Metal Bathory

      base00 = "#080808",
      base01 = "#121212",
      base02 = "#222222",
      base03 = "#333333",
      base04 = "#999999",
      base05 = "#c1c1c1",
      base06 = "#999999",
      base07 = "#c1c1c1",
      base08 = "#5f8787",
      base09 = "#aaaaaa",
      base0A = "#e78a53",
      base0B = "#fbcb97",
      base0C = "#aaaaaa",
      base0D = "#888888",
      base0E = "#999999",
      base0F = "#444444",

      --Black metal khold

      -- base00 = "#080808",
      -- base01 = "#121212",
      -- base02 = "#222222",
      -- base03 = "#333333",
      -- base04 = "#999999",
      -- base05 = "#c1c1c1",
      -- base06 = "#999999",
      -- base07 = "#c1c1c1",
      -- base08 = "#5f8787",
      -- base09 = "#aaaaaa",
      -- base0A = "#974b46",
      -- base0B = "#eceee3",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",

    })
  end,
}
