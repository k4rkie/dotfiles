return {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true },
        scroll = {
          animate = {
            duration = { step = 10, total = 200 },
            easing = "linear",
          },
          -- faster animation when repeating scroll after delay
          animate_repeat = {
            delay = 100, -- delay in ms before using the repeat animation
            duration = { step = 5, total = 50 },
            easing = "linear",
          },
        },
        picker = {
          prompt = "-> ",
          layout = "ivy",
          layouts = {
            ivy = {
              layout = {
                box = "vertical",
                backdrop = false,
                row = -1,
                width = 0,
                height = 0.5,
                border = "top",
                title = " {title} {live} {flags}",
                title_pos = "left",
                { win = "input", height = 1, border = "bottom" },
                {
                  box = "horizontal",
                  { win = "list",    border = "none" },
                  { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                },
              },
            },
          }
        },
        dashboard = {
          width = 50,
          preset = {
            ---@type fun(cmd:string, opts:table)|nil
            pick = nil,
            -- Used by the `header` section
            ---@type snacks.dashboard.Item[]
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
            header = [[
,---,---,---,---,---,---,---,---,---,---,---,---,---,-------,
| ` | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 0 | + | ' | <-    |
|---'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-----|
| ->| | Q | W | E | R | T | Y | U | I | O | P | ] | ^ |     |
|-----',--',--',--',--',--',--',--',--',--',--',--',--'| 󰌑  |
| Caps | A | S | D | F | G | H | J | K | L | \ | [ | * |    |
|------'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'-,-'---'----|
|       | Z | X | C | V | B | N | M | , | . | - |         |
|------,-'---,---'-,-'---'---'---'---'---'---'-,-'---,------|
| ctrl |    | alt |                           | alt | ctrl |
'------'-----'-----'---------------------------'-----'------'
      ]],
          },
          sections = {
            { section = "header" },
            { section = "keys",   indent = 0, padding = 1 },
            { section = "startup" },
          },
        }
      }
    },
    vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = "#888888" })
