--- KissBufLine ---

vim.o.showtabline = 2

vim.api.nvim_set_hl(0, 'TabLineSelUnfocused', { fg = '#98c379', bg = '#3e4451', ctermfg = 235, ctermbg = 114 })

-- Check if a buffer should be excluded from the buffer line
local function is_excluded(bufnr)
  local is_ex = vim.fn.buflisted(bufnr) == 0
      or vim.fn.getbufvar(bufnr, '&filetype') == 'qf' -- quickfix
      or vim.fn.getbufvar(bufnr, '&buftype') == 'terminal'
  return is_ex
end

local BlSim = require('kissline.bl_sim').BlSim
--[[
Currently, new/delete buffer and set current buffer are invoked by Neovim's event triggers. Additionally, when the tabline is redrawn, the state of the emulator and Neovim will be automatically synchronized.
--]]
local bl_sim = BlSim:new({ debug = false }) -- buffer line simulator

local bl_cache = {                          -- buffer line cache
  buflist_changed = {},                     -- Used to trigger updates for the buffer list
  bufnr_jump_to = nil,                      -- Save the bufnr on the left of the deleted buffer.
  -- In Neovim Deleting the current buffer will switch to the previous buffer in the jumplist.
}

local function delay_redrawing_tabline(timeout)
  vim.defer_fn(function()
    vim.api.nvim__redraw({ tabline = true })
  end, timeout)
end

-- Check if the buffer line has changed
local function has_bufline_changed()
  if bl_cache.buflist_changed['BufDelete'] then
    local ev = bl_cache.buflist_changed['BufDelete']
    if vim.fn.getbufvar(ev.buf, 'buf_deleting') ~= 1 then
      bl_sim:log('BufDelete', {}, string.format('ev.buf: ', ev.buf))
      bl_cache.buflist_changed = {}
      return true
    else
      bl_sim:log('After BufDelete before BufDeletePost', {}, string.format('ev.buf: ', ev.buf))
      delay_redrawing_tabline(50)
      return false -- Note: After `BufDelete` before `BufDeletePost`. Other event handling must occur after `BufDeletePost`.
    end
  end

  for event, _ in pairs(bl_cache.buflist_changed) do
    if event ~= 'BufDelete' then
      if bl_cache.buflist_changed[event] then
        bl_cache.buflist_changed = {}
        bl_sim:log(string.format('%s', event))
        return true
      end
    end
  end

  return false
end

-- Update the buffer line
local function update_bufline()
  -- ## Update buflist
  if has_bufline_changed() then
    bl_sim:set_buflist_sync(false)
  end

  local bufnr_list_included = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if not is_excluded(bufnr) then
      table.insert(bufnr_list_included, bufnr)
    end
  end

  if #bl_sim:bufnr_list() ~= #bufnr_list_included then
    bl_sim:set_buflist_sync(false)
  end

  bl_sim:update_buflist(bufnr_list_included)

  -- ## Update the selected buffer
  local cur_bufnr = vim.api.nvim_get_current_buf()
  if not is_excluded(cur_bufnr) then
    bl_sim:update_selbuf(cur_bufnr)
  end
end

-- Select the buffer name
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

-- Switch to the selected buffer
_G.KissLineSwitchBuf = function(bufnr)
  vim.api.nvim_set_current_buf(bufnr)
end

-- This function is running after the events (e.g., BufDelete) callback function.
local function kissbufline()
  bl_sim:log('redraw tabline', { inspect = false })

  update_bufline()

  local bufnr_list = bl_sim:bufnr_list()

  local tab_sect_str = ''                  -- tab section string
  local cur_tab_sect_width = 0
  local tab_sect_width = vim.o.columns - 0 -- The entire tab page displays tabs, so subtract 0.
  local does_contain_seltab = false
  local left_more_str = '<<'
  local right_more_str = '>>'
  for tabnr, bufnr in ipairs(bufnr_list) do
    -- Select the highlighting
    local the_tab_str = ''
    if bufnr == vim.api.nvim_get_current_buf() then
      the_tab_str = the_tab_str .. '%#TabLineSel#'
    elseif tabnr == bl_sim:seltabnr() then
      the_tab_str = the_tab_str .. '%#TabLineSelUnfocused#'
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
        if bufnr == bl_sim:selbufnr() then -- the seltab across the tab page.
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

-- Set the current buffer
local function set_cur_buf(bufnr)
  if not bl_sim:does_bufnr_exist(bufnr) then
    bl_sim:log(string.format('bufnr (%s) does not exist', bufnr))
    return
  end

  vim.api.nvim_set_current_buf(bufnr)
end

-- delete buffer
local function nvim_rm_buf(bufnr, force)
  vim.api.nvim_buf_delete(bufnr, { force = force or false })
end

local function rm_bufs(bufnr_list, force)
  for _, bufnr in ipairs(bufnr_list) do
    if not force then
      if vim.fn.getbufvar(bufnr, '&mod') ~= 1 then
        nvim_rm_buf(bufnr, force)
      end
    else
      nvim_rm_buf(bufnr, force)
    end
  end
end

local kissline_augroup = require('kissline.common').kissline_augroup

-- BufDelete is before deleting a buffer. And use `BufDeletePost` is better. See [ref](https://github.com/vim/vim/issues/11041)
-- `BufAdd` does not include `VimEnter`
vim.api.nvim_create_autocmd({ 'BufAdd', 'VimEnter', 'BufDelete' }, {
  group = kissline_augroup,
  pattern = '*',
  callback = function(ev)
    if is_excluded(ev.buf) then
      return
    end

    bl_cache.buflist_changed[ev.event] = ev

    if ev.event == 'BufDelete' then
      bl_sim:rm_buf(ev.buf)     -- Just for getting the bufnr from bl_sim

      if ev.buf == vim.api.nvim_get_current_buf() then
        bl_cache.bufnr_jump_to = bl_sim:selbufnr()
      end

      vim.fn.setbufvar(ev.buf, 'buf_deleting', 1) -- For `BufDeletePost`

      -- The reason for adding this code is that after restoring the session, without any other operations, directly using the shortcut to delete bufnrs, Neovim does not refresh the tabline.
      delay_redrawing_tabline(50)
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter' }, {
  group = kissline_augroup,
  pattern = '*',
  callback = function(ev)
    if bl_cache.bufnr_jump_to then
      if ev.buf == bl_cache.bufnr_jump_to then
        bl_cache.bufnr_jump_to = nil
      else
        set_cur_buf(bl_cache.bufnr_jump_to)
        bl_cache.bufnr_jump_to = nil
        return
      end
    end

    if is_excluded(ev.buf) then
      return
    end

    bl_sim:log('BufEnter:before selecting buf', { inspect = true })
    bl_sim:select_buf(ev.buf)
    bl_sim:log('BufEnter:after selecting buf', { inspect = true })
  end,
})

vim.o.tabline = '%!v:lua.require("kissline").bufline.kissbufline()'

-- Select the tab at the given position
-- pos: '-<offset>', '+<offset>', '<tabnr>' or <tabnr>, '$'
local function select_tab(pos)
  set_cur_buf(bl_sim:get_bufnr_at_pos(pos)) -- Will trigger BufEnter event. So the bufline_simulator doesn't need to select tab.
end

-- Select the last buffer
local function select_last_buf()
  set_cur_buf(bl_sim:last_selbufnr())
  bl_sim:log('select last bufnr', { inspect = true })
end

-- Remove buffers to the left of the current buffer
local function rm_left_bufs()
  local left_bufnrs = bl_sim:rm_left_bufs()
  if not left_bufnrs then
    return
  end

  rm_bufs(left_bufnrs)
  bl_sim:log('delete left bufs', { inspect = true })
end

-- Remove buffers to the right of the current buffer
local function rm_right_bufs()
  local right_bufnrs = bl_sim:rm_right_bufs()
  if not right_bufnrs then
    return
  end

  rm_bufs(right_bufnrs)
  bl_sim:log('delete right bufs', { inspect = true })
end

-- Remove buffers other than the current buffer
local function rm_other_bufs()
  local other_bufnrs = bl_sim:rm_other_bufs()
  if not other_bufnrs then
    return
  end

  rm_bufs(other_bufnrs)
  bl_sim:log('delete other bufs', { inspect = true })
end

-- Move the buffer to the given position
-- pos: '-<offset>', '+<offset>', '<tabnr>' or <tabnr>, '$'
local function move_buf(pos)
  bl_sim:move_tab(pos)
  vim.api.nvim__redraw({ tabline = true })
end

local function rm_buf(bufnr, force)
  nvim_rm_buf(bufnr, force)
end

-- Delete the buffer for the given tab number
local function rm_buf_for_tab(tabnr, force)
  rm_buf(bl_sim:get_bufnr(tabnr), force)
end

-- Remove the current buffer
local function rm_cur_buf(force)
  bl_sim:log('remove cur buf:before remove', { inspect = true })
  rm_buf(vim.api.nvim_get_current_buf(), force)
  bl_sim:log('remove cur buf:after remove', { inspect = true })
end

return {
  kissbufline = kissbufline,

  select_tab = select_tab,

  select_last_buf = select_last_buf,

  rm_left_bufs = rm_left_bufs,
  rm_right_bufs = rm_right_bufs,
  rm_other_bufs = rm_other_bufs,
  rm_cur_buf = rm_cur_buf,
  rm_buf_for_tab = rm_buf_for_tab,

  move_buf = move_buf,
}
