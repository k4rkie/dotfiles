return {
  "RRethy/base16-nvim",
  lazy = false,    -- load at startup
  priority = 1000, -- load before other plugins
  config = function()
    local base16 = require("base16-colorscheme")

    base16.setup({

      -- Black Metal Base(Tweaked)

      -- base00 = "#000000",
      -- base01 = "#000000",
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
      -- base0A = "#e78a53",
      -- base0B = "#fbcb97",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",
      --
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

      -- Black Metal (Dark Funeral)
      --
      -- base00 = "#000000",
      -- base01 = "#000000",
      -- base02 = "#222222",
      -- base03 = "#333333",
      -- base04 = "#999999",
      -- base05 = "#c1c1c1",
      -- base06 = "#999999",
      -- base07 = "#c1c1c1",
      -- base08 = "#5f8787",
      -- base09 = "#aaaaaa",
      -- base0A = "#5f81a5",
      -- base0B = "#d0dfff",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",

      -- Gruvbox Dark

      -- base00 = "#000000",
      -- base01 = "#000000",
      -- base02 = "#3c3836",
      -- base03 = "#504945",
      -- base04 = "#a89984",
      -- base05 = "#ebdbb2",
      -- base06 = "#d5c4a1",
      -- base07 = "#fbf1c7",
      -- base08 = "#fb4934",
      -- base09 = "#fe8019",
      -- base0A = "#fabd2f",
      -- base0B = "#b8bb26",
      -- base0C = "#8ec07c",
      -- base0D = "#83a598",
      -- base0E = "#d3869b",
      -- base0F = "#d65d0e",

      -- Gruvbox Material Dark Hard

      base00 = "#000000",
      base01 = "#000000",
      base02 = "#2c2826",
      base03 = "#3c3733",
      base04 = "#a89984",
      base05 = "#ddc7a1",
      base06 = "#ebdbb2",
      base07 = "#fbf1c7",
      base08 = "#ea6962",
      base09 = "#e78a4e",
      base0A = "#d8a657",
      base0B = "#a9b665",
      base0C = "#89b482",
      base0D = "#7daea3",
      base0E = "#d3869b",
      base0F = "#bd6f3e",
    })
  end,
}
