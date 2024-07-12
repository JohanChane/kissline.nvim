--- StatusLine ---

local M = {}

vim.o.laststatus = 2

-- ## active
-- section_name -> highlight_group_name
local kiss_sts_line_higroups = {
  mode     = 'KissLineMode',
  file1    = 'KissLineFile1',
  file2    = 'KissLineFile2',
  space    = 'KissLineSpace',
  percent  = 'KissLinePercent',
  lineinfo = 'KissLineLineInfo',
}

-- Mode mapping
local kiss_sts_line_mode = {
  n = 'normal',
  i = 'insert',
  v = 'visual',
  V = 'visual_line',
  [''] = 'visual_block',
  R = 'replace',
  c = 'command',
  t = 'terminal',
}

-- active
local section_hl_values = {
  -- deus theme. See [colorscheme](https://github.com/itchyny/lightline.vim/tree/master/autoload/lightline/colorscheme)
  normal = {
    mode     = { fg = '#292c33', bg = '#98c379', ctermfg = 235, ctermbg = 114, bold = true },
    file1    = { fg = '#98c379', bg = '#292c33', ctermfg = 114, ctermbg = 235 },
    space    = { fg = '#98c379', bg = '#292c33', ctermfg = 114, ctermbg = 235 },
    file2    = { fg = '#98c379', bg = '#292c33', ctermfg = 114, ctermbg = 235 },
    percent  = { fg = '#abb2bf', bg = '#3e4452', ctermfg = 114, ctermbg = 236 },
    lineinfo = { fg = '#292c33', bg = '#98c379', ctermfg = 235, ctermbg = 114 },
  }
}

section_hl_values.insert = vim.deepcopy(section_hl_values.normal)
section_hl_values.visual = vim.deepcopy(section_hl_values.normal)
section_hl_values.visual_line = section_hl_values.visual
section_hl_values.visual_block = section_hl_values.visual
section_hl_values.replace = vim.deepcopy(section_hl_values.normal)

section_hl_values.insert.mode = { fg = '#292c33', bg = '#61afef', ctermfg = 235, ctermbg = 39, bold = true }
section_hl_values.visual.mode = { fg = '#292c33', bg = '#c678dd', ctermfg = 235, ctermbg = 170, bold = true }
section_hl_values.replace.mode = { fg = '#292c33', bg = '#e06c75', ctermfg = 235, ctermbg = 204, bold = true }

-- ### Final higroup
-- {normal = {mode -> KissLineMode_normal, file1 -> KissLineFile1_normal, ...}, insert ...}
local kiss_sts_line_final_higroups = {}

local function get_mode_name(m)
  return kiss_sts_line_mode[m]
end

-- section_name -> final highlight_group_name
local function get_final_sect_higroup_name(sect_name, mode)
  return string.format('%s_%s', kiss_sts_line_higroups[sect_name], mode)
end

-- {mode = ..., file1 = ..., ...}
local function get_final_higroups(m)
  local mode = get_mode_name(m) or 'normal'
  mode = section_hl_values[mode] and mode or 'normal'
  local final_higroups = kiss_sts_line_final_higroups[mode]
  if final_higroups then
    return final_higroups
  end

  -- vim.api.nvim_set_hl(0, 'KissLineMode_normal', section_hl_values.normal.mode)
  -- vim.api.nvim_set_hl(0, 'KissLineMode_normal', section_hl_values.normal.file1)
  -- ...
  -- vim.api.nvim_set_hl(0, 'KissLineMode_normal', section_hl_values.insert.mode)
  -- vim.api.nvim_set_hl(0, 'KissLineMode_normal', section_hl_values.insert.file1)
  -- ...
  kiss_sts_line_final_higroups[mode] = {}
  for sect_name, group in pairs(kiss_sts_line_higroups) do
    local final_higroup_name = get_final_sect_higroup_name(sect_name, mode)
    kiss_sts_line_final_higroups[mode][sect_name] = final_higroup_name

    local final_sect_higroups = section_hl_values[mode][sect_name]
    vim.api.nvim_set_hl(0, final_higroup_name, final_sect_higroups)
  end

  return kiss_sts_line_final_higroups[mode]
end

-- ## inactive
local kiss_sts_line_nc_higroups = {
  mode     = 'KissLineModeNC',
  file1    = 'KissLineFile1NC',
  file2    = 'KissLineFile2NC',
  space    = 'KissLineSpaceNC',
  percent  = 'KissLinePercentNC',
  lineinfo = 'KissLineLineInfoNC',
}

-- inactive
local section_hl_nc_values = {
  file1    = { fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238 },
  space    = { fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238 },
  file2    = { fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238 },
  percent  = { fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238 },
  lineinfo = { fg = '#292c33', bg = '#61afef', ctermfg = 39, ctermbg = 235 },
}

vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.file1, section_hl_nc_values.file1)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.space, section_hl_nc_values.space)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.file2, section_hl_nc_values.file2)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.percent, section_hl_nc_values.percent)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.lineinfo, section_hl_nc_values.lineinfo)

-- statusline cache: Save the statusline information that only updates when certain events occur. e.g. BufEnter, BufNew ...
local sl_cache = {
  --git_info = nil,
}

local function update_sl_cache()
  --git_info
end

local function kiss_line_helper(is_active)
  local hl_groups
  if is_active then
    hl_groups = get_final_higroups(vim.fn.mode())
    --vim.print(vim.inspect(hl_groups))
  else
    hl_groups = kiss_sts_line_nc_higroups
  end

  local mode_section
  if is_active then
    mode_section = table.concat({
      ' ',
      vim.fn.mode(), ' ',
      vim.o.paste and 'PASTE ' or '',
    })
  end

  local bufname = vim.fn.bufname()
  local is_named_buf = bufname ~= ''

  local filepath_str = is_named_buf and vim.fn.fnamemodify(bufname, ':p~') or '[No Name]'
  if #filepath_str > 80 then
    filepath_str = vim.fn.pathshorten(filepath_str, 2)
  end

  local file_section1 = table.concat({
    ' ',
    vim.bo.readonly and '[RO] ' or '',
    filepath_str, ' ',
    vim.bo.modified and '[+] ' or '',
  })

  local file_section2 = table.concat({
    vim.bo.filetype, vim.bo.filetype ~= '' and '|' or '',
    vim.bo.fileencoding, vim.bo.fileencoding ~= '' and '|' or '',
    vim.bo.fileformat, ' ',
  })

  local percent_section = table.concat({
    string.format('%3d%%%%', math.floor((vim.fn.line('.') / vim.fn.line('$')) * 100)), ' ',
  })
  local lineinfo_section = table.concat({
    string.format('%4d:%-3d', vim.fn.line('.'), vim.fn.col('.'))
  })

  local statusline
  if is_active then
    statusline =
        '%<'
        .. '%#' .. hl_groups.mode .. '#' .. mode_section
        .. '%#' .. hl_groups.file1 .. '#' .. file_section1
        .. '%#' .. hl_groups.space .. '#' .. '%='
        .. '%#' .. hl_groups.file2 .. '#' .. file_section2
        .. '%#' .. hl_groups.percent .. '#' .. percent_section
        .. '%#' .. hl_groups.lineinfo .. '#' .. lineinfo_section
  else
    statusline =
        '%<'
        .. '%#' .. hl_groups.file1 .. '#' .. file_section1
        .. '%#' .. hl_groups.space .. '#' .. '%='
        .. '%#' .. hl_groups.file2 .. '#' .. file_section2
        .. '%#' .. hl_groups.percent .. '#' .. percent_section
        .. '%#' .. hl_groups.lineinfo .. '#' .. lineinfo_section
  end

  return statusline
end

M.kissline = function()
  return kiss_line_helper(true)
end

local kissline_augroup = require('kissline').common.kissline_augroup

vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
  group = kissline_augroup,
  pattern = '*',
  callback = function(ev)
    if ev.event == 'BufEnter' then
      update_sl_cache()
    end
    vim.wo.statusline = '%!v:lua.require("kissline").statusline.kissline()'
  end,
})

vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  group = kissline_augroup,
  pattern = '*',
  callback = function(_)
    local statusline = kiss_line_helper(false)
    vim.wo.statusline = statusline
  end,
})

return M
