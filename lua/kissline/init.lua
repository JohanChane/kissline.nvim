table.unpack = table.unpack or unpack -- 5.1 compatibility

local M = {}

local function config_tabline()
  -- ## Select tabs
  for i = 1, 9 do
    vim.keymap.set('n', '<M-' .. i .. '>', i .. 'gt', { noremap = true })
  end
  vim.keymap.set('n', '<Tab>', 'gt', { noremap = true })
  -- terminal emulator sends the same sequence for <Tab> and <C-I>. See [ref](https://github.com/neovim/neovim/issues/20126#issuecomment-1296036118)
  vim.keymap.set("n", "<C-I>", "<C-I>", { noremap = true })

  vim.keymap.set('n', '<S-Tab>', 'gT', { noremap = true })
  vim.keymap.set('n', '<M-0>', '<Cmd>tablast<CR>', { noremap = true, })

  -- ## Move tabs
  vim.keymap.set('n', '<M-S-h>', '<Cmd>-tabmove<CR>', { noremap = true })
  vim.keymap.set('n', '<M-S-l>', '<Cmd>+tabmove<CR>', { noremap = true })

  -- ## Close tabs
  for i = 1, 9 do
    vim.keymap.set('n', '<Leader>q' .. i, '<Cmd>' .. i .. 'tabclose<CR>', { noremap = true })
  end
  vim.keymap.set('n', '<Leader>qq', '<Cmd>quit<CR>', { noremap = true, desc = 'close current tab' })
  vim.keymap.set('n', '<Leader>qo', '<Cmd>tabonly<CR>', { noremap = true, desc = 'close other tabs' })
  vim.keymap.set('n', '<Leader>qr', '<Cmd>.+1,$tabdo tabc<CR>', { noremap = true, desc = 'close right tabs' })
  vim.keymap.set('n', '<Leader>ql', '<Cmd>0,tabp|1,tabdo tabc<CR>', { noremap = true, desc = 'close left tabs' })
end

local function config_bufline()
  local bufline = require('kissline').bufline

  -- ## Select buftab
  for i = 1, 9 do
    vim.keymap.set('n', '<M-' .. i .. '>', function()
      bufline.select_tab(i)
    end, { noremap = true, silent = true })
  end

  vim.keymap.set('n', '<Tab>', function()
    bufline.select_tab('+1')
  end, { noremap = true, silent = true })

  -- terminal emulator sends the same sequence for <Tab> and <C-I>. See [ref](https://github.com/neovim/neovim/issues/20126#issuecomment-1296036118)
  vim.keymap.set("n", "<C-I>", "<C-I>", { noremap = true })

  vim.keymap.set('n', '<S-Tab>', function()
    bufline.select_tab('-1')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<M-0>', function()
    bufline.select_tab('$')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', 'g<Tab>', function()
    bufline.select_last_buf()
  end, { noremap = true, silent = true })

  -- ## Move buftab
  vim.keymap.set('n', '<M-S-h>', function()
    bufline.move_buf('-1')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<M-S-l>', function()
    bufline.move_buf('+1')
  end, { noremap = true, silent = true })

  -- ## Close(Delete) buftab
  for i = 1, 9 do
    vim.keymap.set('n', '<Leader>q' .. i, function()
      bufline.rm_buf_for_tab(i)
    end, { noremap = true })
  end
  vim.keymap.set('n', '<Leader>qq', function()
    bufline.rm_cur_buf()
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<Leader>ql', function()
    bufline.rm_left_bufs()
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<Leader>qr', function()
    bufline.rm_right_bufs()
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<Leader>qo', function()
    bufline.rm_other_bufs()
  end, { noremap = true, silent = true })
end

function M.setup(opts)
  local config = require('kissline.config')
  config.setup_opts = vim.tbl_deep_extend('force', config.default_opts, opts)

  local setup_opts = config.setup_opts

  if setup_opts.bufline.enable and setup_opts.bufline.enable then
    setup_opts.tabline.enable = false
  end

  if setup_opts.statusline.enable then
    M.statusline = require('kissline.statusline')
  end

  if setup_opts.tabline.enable then
    M.tabline = require('kissline.tabline')
    config_tabline()
  end

  if setup_opts.bufline.enable then
    M.bufline = require('kissline.bufline')
    config_bufline()
  end
end

return M
