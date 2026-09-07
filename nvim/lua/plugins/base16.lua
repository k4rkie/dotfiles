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
      base0B = "#a1955f",
      base0C = "#aaaaaa",
      base0D = "#696969",
      base0E = "#999999",
      base0F = "#444444",

      -- Base16 Jellybeans

      -- base00 = "#121212",
      -- base01 = "#929292",
      -- base02 = "#bdbdbd",
      -- base03 = "#c5c5c5",
      -- base04 = "#cdcdcd",
      -- base05 = "#d5d5d5",
      -- base06 = "#dedede",
      -- base07 = "#ffffff",
      -- base08 = "#ffa1a1",
      -- base09 = "#ffba7b",
      -- base0A = "#ffdca0",
      -- base0B = "#bddeab",
      -- base0C = "#1ab2a8",
      -- base0D = "#b1d8f6",
      -- base0E = "#fbdaff",
      -- base0F = "#713939",

      -- base00 = "#0c0e16",
      -- base01 = "#181c2c",
      -- base02 = "#232a40",
      -- base03 = "#5a6178",
      -- base04 = "#939bb2",
      -- base05 = "#cbd4ec",
      -- base06 = "#d9e0f3",
      -- base07 = "#e6ecfa",
      -- base08 = "#e2727e",
      -- base09 = "#82a6e0",
      -- base0A = "#d8c062",
      -- base0B = "#7cc596",
      -- base0C = "#6dd8d0",
      -- base0D = "#7aa0e8",
      -- base0E = "#b79ae0",
      -- base0F = "#3a4260",

    })
  end,
}
