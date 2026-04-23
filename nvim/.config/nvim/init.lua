require('lazy_setup')
require('options')
require('keymaps')
require('statusline')

vim.opt.cursorline = false

vim.cmd(":hi statusline guibg=NONE")

local hl = vim.api.nvim_get_hl(0, { name = "String" })
vim.api.nvim_set_hl(0, "String", {
  fg = hl.fg,
  italic = false,
})


vim.api.nvim_create_user_command('Khoj', function(opts)
  -- 1. Execute the tool manually
  -- vim.fn.system returns the output of the command as a string
  local cmd = "khoj -d ./testDir -k " .. vim.fn.shellescape(opts.args)
  local output = vim.fn.system(cmd)

  -- 2. Push the output directly to the quickfix list
  -- 'c' tells it to use the Quickfix list (not the location list)
  -- 'r' tells it to replace the current list
  vim.fn.setqflist({}, 'r', { title = 'Khoj Results', lines = vim.split(output, "\n") })

  -- 3. Open the window
  vim.cmd('copen')
end, { nargs = 1 })
