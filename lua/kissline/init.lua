table.unpack = table.unpack or unpack -- 5.1 compatibility

local M = {}

local config = {
  statusline = {
    enable = true,
  },
  tabline = {
    enable = true,
  },
  bufline = {
    enable = false,
    abbr_bdelete = false,
  },
}

local function config_tabline()
  -- ## Select tabs
  for i = 1, 9 do
    vim.keymap.set('n', '<M-' .. i .. '>', i .. 'gt', { noremap = true })
  end
  vim.keymap.set('n', '<Tab>', 'gt', { noremap = true })
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

  local function rm_cur_buf(opts)
    bufline.rm_cur_buf(opts.bang)
  end
  vim.api.nvim_create_user_command('RmCurBuf', rm_cur_buf, {bang = true})

  if config.bufline.abbr_bdelete then
    vim.cmd('cnoreabbrev bd RmCurBuf')
    vim.cmd('cnoreabbrev bdel RmCurBuf')
    vim.cmd('cnoreabbrev bdelete RmCurBuf')
  end

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

function M.setup(user_options)
  config = vim.tbl_deep_extend('force', config, user_options)

  if config.bufline.enable and config.bufline.enable then
    config.tabline.enable = false
  end

  M.common = require('kissline.common')

  if config.statusline.enable then
    M.statusline = require('kissline.statusline')
  end

  if config.tabline.enable then
    M.tabline = require('kissline.tabline')
    config_tabline()
  end

  if config.bufline.enable then
    M.bufline = require('kissline.bufline')
    config_bufline()
  end

  vim.api.nvim_create_user_command(
    "BlSimTest",
    function(_)
      require('kissline_test.bl_sim').test()
    end,
    {}
  )
end

return M