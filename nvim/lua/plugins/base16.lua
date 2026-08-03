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
      -- base0A = "#79241f",
      -- base0B = "#f8f7f2",
      -- base0C = "#aaaaaa",
      -- base0D = "#888888",
      -- base0E = "#999999",
      -- base0F = "#444444",

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
      base08 = "#7f7094",
      base09 = "#aaaaaa",
      base0A = "#d1a76b",
      base0B = "#d6b38d",
      base0C = "#aaaaaa",
      base0D = "#696969",
      base0E = "#999999",
      base0F = "#444444",

      --Black metal khold

      -- base00 = "#030303",
      -- base01 = "#080808",
      -- base02 = "#121212",
      -- base03 = "#333333",
      -- base04 = "#999999",
      -- base05 = "#d1d1d1",
      -- base06 = "#999999",
      -- base07 = "#d1d1d1",
      -- base08 = "#806D93",
      -- base09 = "#aaaaaa",
      -- base0A = "#974b46",
      -- base0B = "#E3C5A5",
      -- base0C = "#aaaaaa",
      -- base0D = "#696969",
      -- base0E = "#aaaaaa",
      -- base0F = "#444444",

      -- Black Metal (Dark Funeral)

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

      -- base00 = "#0A0A0F",
      -- base01 = "#101019",
      -- base02 = "#212234",
      -- base03 = "#282c34",
      -- base04 = "#4a5057",
      -- base05 = "#a0a8cd",
      -- base06 = "#a0a8cd",
      -- base07 = "#a0a8cd",
      -- base08 = "#d9798b",
      -- base09 = "#e09367",
      -- base0A = "#c49f69",
      -- base0B = "#8bb362",
      -- base0C = "#48968f",
      -- base0D = "#7593d1",
      -- base0E = "#9A7EC5",
      -- base0F = "#6b3f47",

      -- Base16 Rose-Pine Darker

      -- base00 = "#0A0A0F",
      -- base01 = "#101019",
      -- base02 = "#26233a",
      -- base03 = "#6e6a86",
      -- base04 = "#908caa",
      -- base05 = "#e0def4",
      -- base06 = "#e0def4",
      -- base07 = "#524f67",
      -- base08 = "#eb6f92",
      -- base09 = "#f6c177",
      -- base0A = "#ebbcba",
      -- base0B = "#31748f",
      -- base0C = "#9ccfd8",
      -- base0D = "#c4a7e7",
      -- base0E = "#f6c177",
      -- base0F = "#524f67",

      -- Base16 Bark

      -- base00 = "#030303",
      -- base01 = "#080808",
      -- base02 = "#2b2b2b",
      -- base03 = "#505050",
      -- base04 = "#b0b0b0",
      -- base05 = "#d0d0d0",
      -- base06 = "#e0e0e0",
      -- base07 = "#fafafa",
      -- base08 = "#ab4642",
      -- base09 = "#dc9656",
      -- base0A = "#f7ca88",
      -- base0B = "#a1b56c",
      -- base0C = "#86c1b9",
      -- base0D = "#7cafc2",
      -- base0E = "#ba8baf",
      -- base0F = "#a16946",

    })
  end,
}
