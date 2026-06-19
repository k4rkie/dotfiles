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

      -- Base16 Tokyodark Terminal

      base00 = "#0A0A0F",
      base01 = "#101019",
      base02 = "#212234",
      base03 = "#282c34",
      base04 = "#4a5057",
      base05 = "#a0a8cd",
      base06 = "#a0a8cd",
      base07 = "#a0a8cd",
      base08 = "#d9798b",
      base09 = "#e09367",
      base0A = "#c49f69",
      base0B = "#8bb362",
      base0C = "#48968f",
      base0D = "#7593d1",
      base0E = "#9A7EC5",
      base0F = "#6b3f47",
    })
  end,
}
