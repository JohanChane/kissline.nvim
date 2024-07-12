--- KissBufLine ---

vim.o.showtabline = 2

local function is_excluded(bufnr)
  local is_ex = vim.fn.buflisted(bufnr) == 0
      or vim.fn.getbufvar(bufnr, '&filetype') == 'qf' -- quickfix
      or vim.fn.getbufvar(bufnr, '&buftype') == 'terminal'
  return is_ex
end

local bufline_cache = {
  bufnr_list = {},        -- for tabnr, bufnr in ipairs(bufnr_list)
  buftabnr_map = {},      -- bufnr-tabnr mapping

  seltab_bufnr = nil,     -- selected tab bufnr, not current bufnr.
  old_seltab_bufnr = nil, -- the old value of seltab_bufnr. And used for last_bufnr.

  buflist_changed = nil,  -- Used to trigger update bufnr_list
}

local function get_bufnr(tabnr)
  return bufline_cache.bufnr_list[tabnr]
end

local function get_tabnr(bufnr)
  return bufline_cache.buftabnr_map[bufnr]
end

-- BufDelete is before deleting a buffer. And use `BufDeletePos` is better. See [ref](https://github.com/vim/vim/issues/11041)
local function has_bufline_changed()
  if not bufline_cache.buflist_changed then
    return false
  end

  if bufline_cache.buflist_changed.event == 'BufDelete' then
    local bufnr = bufline_cache.buflist_changed.bufnr
    if vim.fn.buflisted(bufnr) ~= 0 then
      return false
    end
  end

  return true
end

local function update_bufline()
  if not has_bufline_changed() then
    return
  end

  local function get_seltab_bufnr()
    return bufline_cache
        .old_seltab_bufnr -- Because `bufline_cache.seltab_bufnr` has updated before entering udpate_bufline()
  end

  -- ## bufnr_list
  local new_bufnr_list_asc = {} -- bufnr is ascend
  local bufnr_set = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if not is_excluded(bufnr) then
      table.insert(new_bufnr_list_asc, bufnr)
      bufnr_set[bufnr] = true
    end
  end

  -- Delete old bufnrs
  local new_bufnr_list = {}
  local new_bufnr_set = {}
  for _, bufnr in ipairs(bufline_cache.bufnr_list) do
    if bufnr_set[bufnr] then
      table.insert(new_bufnr_list, bufnr)
      new_bufnr_set[bufnr] = true
    end
  end

  -- Add new bufnrs
  local seltab_bufnr = get_seltab_bufnr()
  local seltabnr = get_tabnr(seltab_bufnr) or 0
  for _, bufnr in pairs(new_bufnr_list_asc) do
    if not new_bufnr_set[bufnr] then
      table.insert(new_bufnr_list, seltabnr + 1, bufnr)
    end
  end

  bufline_cache.bufnr_list = new_bufnr_list

  -- ## buftabnr_map
  local new_buftabnr_map = {}
  for tabnr, bufnr in ipairs(bufline_cache.bufnr_list) do
    new_buftabnr_map[bufnr] = tabnr
  end

  bufline_cache.buftabnr_map = new_buftabnr_map

  bufline_cache.buflist_changed = nil
end

local function kiss_buf_sel(bufnr)
  local bufname = vim.fn.bufname(bufnr)
  if bufname ~= '' then
    bufname = vim.fn.fnamemodify(bufname, ':t') -- get file name
  else
    bufname = '[No Name]'
  end

  -- Add a plus sign if the buffer is modified
  if vim.fn.getbufvar(bufnr, '&mod') == 1 then
    bufname = bufname .. '+'
  end

  return bufname
end

_G.KissLineSwitchBuf = function(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
end

-- This function is running after the events(e.g. BufDelete) callback function.
local function kissbufline()
  update_bufline()

  local bufnr_list = bufline_cache.bufnr_list

  local tab_sect_str = ''                  -- tab section string
  local cur_tab_sect_width = 0
  local tab_sect_width = vim.o.columns - 0 -- The entire tab page displays tabs, so subtract 0.
  local does_contain_seltab = false
  local left_more_str = '<<'
  local right_more_str = '>>'
  for tabnr, bufnr in ipairs(bufnr_list) do
    -- Select the highlighting
    local the_tab_str = ''
    if bufnr == bufline_cache.seltab_bufnr then
      the_tab_str = the_tab_str .. '%#TabLineSel#'
      does_contain_seltab = true
    else
      the_tab_str = the_tab_str .. '%#TabLine#'
    end

    -- Set the buffer number (for mouse clicks)
    if vim.fn.has('tablineat') then
      the_tab_str = the_tab_str .. '%' .. bufnr .. '@v:lua.KissLineSwitchBuf@'
    end

    -- The label is the buffer name
    local the_tab_content = ' ' .. tabnr .. ':' .. kiss_buf_sel(bufnr) .. ' ' -- content is what you see
    the_tab_str = the_tab_str .. the_tab_content

    -- Generate the tab page
    if (cur_tab_sect_width + #the_tab_content) <= tab_sect_width then
      tab_sect_str = tab_sect_str .. the_tab_str
      cur_tab_sect_width = cur_tab_sect_width + #the_tab_content
    else
      if not does_contain_seltab then
        tab_sect_str = left_more_str .. the_tab_str
        cur_tab_sect_width = #left_more_str + #the_tab_content
      else
        if bufnr == bufline_cache.seltab_bufnr then -- the seltab across the tab page.
          -- It will be the first tab in the next tab page
          tab_sect_str = left_more_str .. the_tab_str
          cur_tab_sect_width = #left_more_str + #the_tab_content
        else
          tab_sect_str = tab_sect_str .. the_tab_str
          tab_sect_str = tab_sect_str .. right_more_str
          cur_tab_sect_width = cur_tab_sect_width + #the_tab_str + #right_more_str
          break
        end
      end
    end
  end

  local tabline_str = ''
  tabline_str = tabline_str
      .. tab_sect_str .. '%<'
      .. '%#TabLineFill#%T'

  return tabline_str
end

local function amend_tabnr(tabnr)
  local tab_num = #bufline_cache.bufnr_list
  if tabnr < 1 then
    tabnr = 1
  elseif tabnr > tab_num then
    tabnr = tab_num
  end

  return tabnr
end

local function set_current_bufnr(bufnr)
  if bufnr == nil then
    return
  end

  vim.api.nvim_set_current_buf(bufnr)
end

local kissline_augroup = require('kissline').common.kissline_augroup

-- `BufAdd` does not include `VimEnter`
vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter', 'BufDelete' }, {
  group = kissline_augroup,
  pattern = '*',
  callback = function(ev)
    if is_excluded(ev.buf) then
      return
    end

    bufline_cache.buflist_changed = {
      event = ev.event,
      bufnr = ev.buf
    }
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = kissline_augroup,
  pattern = '*',
  callback = function(ev)
    if is_excluded(ev.buf) then
      return
    end

    -- Re-enter the same buffer. e.g. open a file manager (ranger) and quit.
    if ev.buf == bufline_cache.seltab_bufnr then
      return
    end

    bufline_cache.old_seltab_bufnr = bufline_cache.seltab_bufnr
    bufline_cache.seltab_bufnr = ev.buf
  end,
})

vim.o.tabline = '%!v:lua.require("kissline").bufline.kissbufline()'

-- pos: '-<offset>', '+<offset>', '<tabnr>', '$'
local function calculate_tabnr(tabnr, pos)
  local dst_tabnr
  if pos:sub(1, 1) == '+' or pos:sub(1, 1) == '-' then
    dst_tabnr = tabnr + tonumber(pos)
  elseif pos == '$' then
    dst_tabnr = #bufline_cache.bufnr_list
  else
    dst_tabnr = tonumber(pos) or 1
  end
  return dst_tabnr
end

local function get_bufnr_by_pos(bufnr, pos)
  local tabnr = get_tabnr(bufnr)
  local dst_tabnr = calculate_tabnr(tabnr, pos)
  local tab_num = #bufline_cache.bufnr_list
  if dst_tabnr < 1 then
    dst_tabnr = tab_num
  elseif dst_tabnr > tab_num then
    dst_tabnr = 1
  end

  return get_bufnr(dst_tabnr)
end

-- `vim.api.nvim_get_current_buf()` will return `nil` sometime.
local function amend_bufnr(bufnr)
  return bufnr or bufline_cache.seltab_bufnr
end

local function amend_pos(pos)
  if type(pos) == 'number' and math.floor(pos) == pos then
    pos = tostring(pos)
  end

  return pos
end

-- pos: '-<offset>', '+<offset>', '<tabnr>' or <tabnr>, '$'
local function select_tabnr(bufnr, pos)
  bufnr = amend_bufnr(bufnr)
  set_current_bufnr(get_bufnr_by_pos(bufnr, amend_pos(pos)))
end

local function left_bufnrs(bufnr)
  bufnr = amend_bufnr(bufnr)

  local left_bnrs = {}
  for _, bnr in ipairs(bufline_cache.bufnr_list) do
    if bnr == bufnr then
      break
    else
      table.insert(left_bnrs, bnr)
    end
  end

  return left_bnrs
end

local function delete_left_bufnrs(bufnr)
  local left_bnrs = left_bufnrs(bufnr)
  for _, bnr in ipairs(left_bnrs) do
    vim.api.nvim_buf_delete(bnr, {})
  end

  vim.api.nvim__redraw({ tabline = true }) -- To prevent delays in updating. Optional
end

local function right_bufnrs(bufnr)
  bufnr = amend_bufnr(bufnr)

  local right_bnrs = {}
  for i = #bufline_cache.bufnr_list, 1, -1 do
    if bufline_cache.bufnr_list[i] == bufnr then
      break
    else
      table.insert(right_bnrs, bufline_cache.bufnr_list[i])
    end
  end

  return right_bnrs
end

local function delete_right_bufnrs(bufnr)
  local right_bnrs = right_bufnrs(bufnr)
  for _, bnr in ipairs(right_bnrs) do
    vim.api.nvim_buf_delete(bnr, {})
  end

  vim.api.nvim__redraw({ tabline = true }) -- To prevent delays in updating. Optional
end

local function other_bufnrs(bufnr)
  bufnr = amend_bufnr(bufnr)

  local other_bnrs = {}
  for _, bnr in ipairs(bufline_cache.bufnr_list) do
    if bnr ~= bufnr then
      table.insert(other_bnrs, bnr)
    end
  end

  return other_bnrs
end

local function delete_other_bufnrs(bufnr)
  local other_bnrs = other_bufnrs(bufnr)
  for _, bnr in ipairs(other_bnrs) do
    vim.api.nvim_buf_delete(bnr, {})
  end

  vim.api.nvim__redraw({ tabline = true }) -- To prevent delays in updating. Optional
end

local function last_bufnr()
  set_current_bufnr(bufline_cache.old_seltab_bufnr)
end

-- pos: '-<offset>', '+<offset>', '<tabnr>' or <tabnr>, '$'
local function move_bufnr(bufnr, pos)
  bufnr = amend_bufnr(bufnr)

  local tabnr = get_tabnr(bufnr)
  local dst_tabnr = calculate_tabnr(tabnr, amend_pos(pos))
  dst_tabnr = amend_tabnr(dst_tabnr)

  table.remove(bufline_cache.bufnr_list, tabnr)
  table.insert(bufline_cache.bufnr_list, dst_tabnr, bufnr)

  vim.api.nvim__redraw({ tabline = true })
end

local function delete_cur_buf()
  local cur_bufnr = vim.api.nvim_get_current_buf()

  if is_excluded(cur_bufnr) then
    vim.api.nvim_buf_delete(cur_bufnr, {})
    return
  end

  -- displaye left tab after deleting buffer.
  -- `:h :bd`: If buffer [N] is the current buffer, another buffer will be displayed instead.
  if #bufline_cache.bufnr_list <= 1 then
    vim.api.nvim_buf_delete(cur_bufnr, {})
    return
  end

  local cur_tabnr = get_tabnr(cur_bufnr)
  -- Since tabnr 1 will be deleted, tabnr 2 will be selected.
  local prev_tabnr = cur_tabnr == 1 and 2 or cur_tabnr - 1

  set_current_bufnr(get_bufnr(prev_tabnr))
  vim.api.nvim_buf_delete(cur_bufnr, {})
end

local function delete_bufnr_by_tab(tabnr)
  tabnr = amend_tabnr(tabnr)
  local bufnr = get_bufnr(tabnr)
  local cur_bufnr = vim.api.nvim_get_current_buf()
  if bufnr == cur_bufnr then
    delete_cur_buf()
  else
    vim.api.nvim_buf_delete(bufnr, {})
  end
end

return {
  kissbufline = kissbufline,

  select_tabnr = select_tabnr,

  delete_left_bufnrs = delete_left_bufnrs,
  delete_right_bufnrs = delete_right_bufnrs,
  delete_other_bufnrs = delete_other_bufnrs,
  delete_cur_buf = delete_cur_buf,
  delete_bufnr_by_tab = delete_bufnr_by_tab,

  last_bufnr = last_bufnr,

  move_bufnr = move_bufnr,
}
