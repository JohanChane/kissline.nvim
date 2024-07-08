-- ## StatusLine
vim.o.laststatus = 2

local kiss_sts_line_higroups = {
  mode     = 'KissLineMode',
  file1    = 'KissLineFile1',
  file2    = 'KissLineFile2',
  space    = 'KissLineSpace',
  percent  = 'KissLinePercent',
  lineinfo = 'KissLineLineInfo',
}

-- active
local section_hl_values = {
  -- deus theme. See [colorscheme](https://github.com/itchyny/lightline.vim/tree/master/autoload/lightline/colorscheme)
  mode     = {fg = '#292c33', bg = '#98c379', ctermfg = 235, ctermbg = 114, bold = true},
  file1    = {fg = '#98c379', bg = '#292c33', ctermfg = 114, ctermbg = 235},
  space    = {fg = '#98c379', bg = '#292c33', ctermfg = 114, ctermbg = 235},
  file2    = {fg = '#98c379', bg = '#292c33', ctermfg = 114, ctermbg = 235},
  percent  = {fg = '#abb2bf', bg = '#3e4452', ctermfg = 114, ctermbg = 236},
  lineinfo = {fg = '#292c33', bg = '#98c379', ctermfg = 235, ctermbg = 114},
}

vim.api.nvim_set_hl(0, kiss_sts_line_higroups.mode,     section_hl_values.mode)
vim.api.nvim_set_hl(0, kiss_sts_line_higroups.file1,    section_hl_values.file1)
vim.api.nvim_set_hl(0, kiss_sts_line_higroups.space,    section_hl_values.space)
vim.api.nvim_set_hl(0, kiss_sts_line_higroups.file2,    section_hl_values.file2)
vim.api.nvim_set_hl(0, kiss_sts_line_higroups.percent,  section_hl_values.percent)
vim.api.nvim_set_hl(0, kiss_sts_line_higroups.lineinfo, section_hl_values.lineinfo)

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
  file1    = {fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238},
  space    = {fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238},
  file2    = {fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238},
  percent  = {fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238},
  lineinfo = {fg = '#abb2bf', bg = '#3e4452', ctermfg = 243, ctermbg = 238},
}

vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.file1,    section_hl_nc_values.file1)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.space,    section_hl_nc_values.space)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.file2,    section_hl_nc_values.file2)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.percent,  section_hl_nc_values.percent)
vim.api.nvim_set_hl(0, kiss_sts_line_nc_higroups.lineinfo, section_hl_nc_values.lineinfo)

-- statusline cache: Save the statusline information that only updates when certain events occur. e.g. WinEnter, BufEnter, ...
local sl_cache = {}

local function update_sl_cache()
  local bufname = vim.fn.bufname()
  local is_named_buf = bufname ~= ''

  local fullpath = vim.fn.expand(vim.fn.expand('%:p'))
  local filepath = is_named_buf and vim.fn.fnamemodify(fullpath, ':~') or '[No Name]'
  if #filepath > 80 then
    filepath = vim.fn.pathshorten(filepath, 2)
  end
  sl_cache.filepath = filepath
end

local function kiss_line_helper(is_active)
  local hl_groups
  if is_active then
    hl_groups = kiss_sts_line_higroups
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

  local file_section1 = table.concat({
    ' ',
    vim.bo.readonly and '[RO] ' or '',
    sl_cache.filepath, ' ',
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

function KissLine()
  return kiss_line_helper(true)
end

local group = vim.api.nvim_create_augroup('KissLine', { clear = true })

vim.api.nvim_create_autocmd({'WinEnter', 'BufEnter'}, {
    group = group,
    pattern = '*',
    callback = function(_)
      update_sl_cache()
      vim.wo.statusline = '%!v:lua.KissLine()'
    end,
})

vim.api.nvim_create_autocmd({'WinLeave'}, {
    group = group,
    pattern = '*',
    callback = function(_)
      local statusline = kiss_line_helper(false)
      vim.wo.statusline = statusline
    end,
})

-- ## TabLine
vim.o.showtabline = 1

-- deus theme
vim.api.nvim_set_hl(0, 'TabLineSel', {fg = '#292c33', bg = '#98C379', ctermfg = 235, ctermbg = 114})

local function kiss_tab_sel(n)
  local buflist = vim.fn.tabpagebuflist(n)
  local winnr = vim.fn.tabpagewinnr(n)
  local bufname = vim.fn.bufname(buflist[winnr])
  if bufname ~= '' then
    bufname = vim.fn.fnamemodify(bufname, ':t')    -- get file name
  else
    bufname = '[No Name]'
  end

  -- Add a plus sign if the buffer is modified
  if vim.fn.getbufvar(buflist[winnr], '&mod') == 1 then
    bufname = bufname .. '+'
  end

  return bufname
end

function KissTabLine()
  local s = ''
  local tabnr = vim.fn.tabpagenr('$')

  for i = 1, tabnr do
    -- Select the highlighting
    if i == vim.fn.tabpagenr() then
      s = s .. '%#TabLineSel#'
    else
      s = s .. '%#TabLine#'
    end

    -- Set the tab page number (for mouse clicks)
    s = s .. '%' .. i .. 'T'

    -- The label is made by kiss_tab_sel()
    s = s .. ' ' .. i .. ':' .. kiss_tab_sel(i) .. ' '
  end

  -- After the last tab fill with TabLineFill and reset tab page nr
  s = s .. '%#TabLineFill#%T'

  -- Right-align the label to `X` the current tab page
  --if tabnr > 1 then
  --  s = s .. '%=%#TabLine#%999XX'
  --end

  return s
end

vim.o.tabline = '%!v:lua.KissTabLine()'
