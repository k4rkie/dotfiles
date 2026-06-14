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
      --
      --Black Metal Venom

      -- base00 = "#000000",
      -- base01 = "#000000",
      -- base02 = "#121212",
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

      base00 = "#000000",
      base01 = "#000000",
      base02 = "#121212",
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
      --
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

      -- Gruvbox Material Dark Hard

      -- base00 = "#000000",
      -- base01 = "#000000",
      -- base02 = "#2c2826",
      -- base03 = "#3c3733",
      -- base04 = "#a89984",
      -- base05 = "#E9DFCD",
      -- base06 = "#ebdbb2",
      -- base07 = "#fbf1c7",
      -- base08 = "#8f8680", -- warm gray: errors, diffs
      -- base09 = "#9e948e", -- warm gray: numbers, constants
      -- base0A = "#a69a88", -- warm tone: functions, types
      -- base0B = "#94988c", -- cool gray: strings
      -- base0C = "#8a8e8c", -- neutral gray: info, accents
      -- base0D = "#8e908c", -- neutral gray: links, headings
      -- base0E = "#968e92", -- mauve gray: keywords
      -- base0F = "#807a76", -- dark gray: deprecated
    })
  end,
}
