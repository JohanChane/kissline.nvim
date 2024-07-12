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
      bufline.select_tabnr(vim.api.nvim_get_current_buf(), i)
    end, { noremap = true, silent = true })
  end

  vim.keymap.set('n', '<Tab>', function()
    bufline.select_tabnr(vim.api.nvim_get_current_buf(), '+1')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<S-Tab>', function()
    bufline.select_tabnr(vim.api.nvim_get_current_buf(), '-1')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<M-0>', function()
    bufline.select_tabnr(vim.api.nvim_get_current_buf(), '$')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', 'g<Tab>', function()
    bufline.last_bufnr()
  end, { noremap = true, silent = true })

  -- ## Move buftab
  vim.keymap.set('n', '<M-S-h>', function()
    local last_bufnr = bufline.move_bufnr(vim.api.nvim_get_current_buf(), '-1')
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<M-S-l>', function()
    local last_bufnr = bufline.move_bufnr(vim.api.nvim_get_current_buf(), '+1')
  end, { noremap = true, silent = true })

  -- ## Close(Delete) buftab
  for i = 1, 9 do
    vim.keymap.set('n', '<Leader>q' .. i, function()
      bufline.delete_bufnr_by_tab(i)
    end, { noremap = true })
  end
  vim.keymap.set('n', '<Leader>qq', function()
    --vim.api.nvim_buf_delete(0, {})
    bufline.delete_cur_buf()
  end, { noremap = true, silent = true })

  if config.bufline.abbr_bdelete then
    local function delete_cur_buf()
      bufline.delete_cur_buf()
    end
    vim.api.nvim_create_user_command('DeleteCurBuf', delete_cur_buf, {})

    vim.cmd('cnoreabbrev bd DeleteCurBuf')
    vim.cmd('cnoreabbrev bdel DeleteCurBuf')
    vim.cmd('cnoreabbrev bdelete DeleteCurBuf')
  end

  vim.keymap.set('n', '<Leader>ql', function()
    bufline.delete_left_bufnrs(vim.api.nvim_get_current_buf())
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<Leader>qr', function()
    bufline.delete_right_bufnrs(vim.api.nvim_get_current_buf())
  end, { noremap = true, silent = true })

  vim.keymap.set('n', '<Leader>qo', function()
    bufline.delete_other_bufnrs(vim.api.nvim_get_current_buf())
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
end

return M
