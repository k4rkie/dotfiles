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

      -- base00 = "#000000",
      -- base01 = "#080808",
      -- base02 = "#121212",
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

      -- Base16 Tokyo Night Terminal Dark

      base00 = "#0E0E17",
      base01 = "#13131C",
      base02 = "#2f3549",
      base03 = "#444b6a",
      base04 = "#787c99",
      base05 = "#787c99",
      base06 = "#cbccd1",
      base07 = "#d5d6db",
      base08 = "#f7768e",
      base09 = "#ff9e64",
      base0A = "#e0af68",
      base0B = "#41a6b5",
      base0C = "#7dcfff",
      base0D = "#7aa2f7",
      base0E = "#bb9af7",
      base0F = "#d18616",
    })
  end,
}
