local M = {}

--[[
# Description of BlSim (Buffer Line Simulator)

## Purpose of BlSim
BlSim is a class used to simulate buffer lines. Its purpose is to centralize the management of code related to buffer line behavior.

It doesn't associate with other components, and you can even use it independently. This allows you to test it very conveniently.

If you scatter behavior code everywhere and then combine it with some events of Neovim, it can be difficult to locate issues if problems arise, especially when dealing with asynchronous tasks.

## Usage of BlSim
BlSim simulates the execution of an action, and then Neovim executes this action.

Finally, you set Neovim's state to the state after BlSim's execution.

If the external state changes, synchronize the internal state with the external state.

## Behavior Description
1.  A newly added buffer will appear to the right of the selected buffer, and then it will switch to the newly added buffer.
2.  After deleting the current buffer, it will switch to the buffer on the left. If the first tab is deleted, it will switch to the first tab. If a non-current buffer is deleted, it will not switch.
3.  When switching to the next tab, if it is the last tab, it will switch to the first tab. Similarly, when switching to the previous tab, if it is the first tab, it will switch to the last tab. Moving tabs will not exhibit this behavior.
--]]
BlSim = {}
BlSim.__index = BlSim

function BlSim:new(_opt)
  local self = setmetatable({}, BlSim)

  _opt = _opt or {}

  local _bufnr_list = {}
  local _bufnr_set = {}
  local _selbufnr = nil
  local _last_selbufnr = nil
  local _is_buflist_sync = false  -- Whether the internal simulator is synchronized with the external

  local _debug = _opt.debug

  local function _inspect()
    print('bufnr_list:')
    print(vim.inspect(_bufnr_list))
    print('bufnr_set:')
    print(vim.inspect(_bufnr_set))
    print('selbufnr:', _selbufnr)
    print('last_selbufnr:', _last_selbufnr)
    print('seltabnr:', self:seltabnr())
    print('last_seltabnr:', self:last_selbufnr())
  end

  function self:log(title, opt, msg)
    if not _debug then
      return
    end

    opt = opt or {}

    local info = debug.getinfo(2, "Sln")
    local source = info and info.source or "unknown source"
    local currentline = info and info.currentline or "unknown line"
    local name = info and info.name or "unknown function"

    local filename = source:match("^.+/(.+)$") or source
    local timestamp = os.date("%M:%S")

    print(string.format('## %s [%s:%s:%s] %s', timestamp, filename, currentline, name, title))
    if msg then
      print('msg: ', msg)
    end
    if opt.inspect then
      _inspect()
    end
  end

  function self:bufnr_list()
    return _bufnr_list
  end

  function self:selbufnr()
    return _selbufnr
  end

  function self:seltabnr()
    return self:get_tabnr(_selbufnr)
  end

  function self:last_selbufnr()
    return _last_selbufnr
  end

  function self:last_seltabnr()
    return self:get_tabnr(_last_selbufnr)
  end

  function self:get_tabnr(bufnr)
    for tnr, bnr in ipairs(_bufnr_list) do
      if bnr == bufnr then
        return tnr
      end
    end
  end

  function self:get_bufnr(tabnr)
    return _bufnr_list[tabnr]
  end

  function self:does_bufnr_exist(bufnr)
    return _bufnr_set[bufnr]
  end

  function self:does_tabnr_exist(tabnr)
    return _bufnr_list[tabnr]
  end

  function self:is_buflist_sync()
    return _is_buflist_sync
  end

  function self:set_buflist_sync(is_sync)
    _is_buflist_sync = is_sync
  end

  function self:select_buf(bufnr)
    if not self:does_bufnr_exist(bufnr) then
      return
    end

    if bufnr == _selbufnr then
      return
    end

    _last_selbufnr = _selbufnr
    _selbufnr = bufnr
  end

  function self:select_last_buf()
    self:select_buf(_last_selbufnr)
  end

  function self:add_buf(bufnr)
    if not bufnr then
      return
    end

    if self:does_bufnr_exist(bufnr) then
      self:select_buf(bufnr)
      return
    end

    -- New buffer on the right of seltab
    local tabnr = #_bufnr_list == 0 and 1 or self:seltabnr() + 1    -- Ref: rm_tab()
    table.insert(_bufnr_list, tabnr, bufnr)
    _bufnr_set[bufnr] = true

    self:select_buf(bufnr)

    self:set_buflist_sync(false)
  end

  function self:rm_tab(tabnr)
    if not self:does_tabnr_exist(tabnr) then
      return
    end

    self:set_buflist_sync(false)

    local bufnr = self:get_bufnr(tabnr)
    table.remove(_bufnr_list, tabnr)
    _bufnr_set[bufnr] = nil

    if bufnr == _selbufnr then
      -- Select the left tab of seltab after remove tab
      local prev_tabnr = tabnr - 1 < 1 and 1 or tabnr - 1
      local prev_bufnr = self:get_bufnr(prev_tabnr)
      self:select_buf(prev_bufnr)
    end
  end

  function self:rm_buf(bufnr)
    self:rm_tab(self:get_tabnr(bufnr))
  end

  -- pos: '-<offset>', '+<offset>', '<tabnr>', '$'
  local function _get_tabnr_with_pos(pos)
    if type(pos) == 'number' then
      pos = tostring(pos)
    end

    local dst_tabnr
    if pos:sub(1, 1) == '+' or pos:sub(1, 1) == '-' then
      local seltabnr = self:seltabnr()
      if not seltabnr then
        return
      end
      dst_tabnr = seltabnr + tonumber(pos)
    elseif pos == '$' then
      dst_tabnr = #_bufnr_list
    else
      dst_tabnr = tonumber(pos)
    end
    return dst_tabnr
  end

  function self:get_bufnr_at_pos(pos)
    local tabnr = _get_tabnr_with_pos(pos)
    if tabnr < 1 then
      tabnr = #_bufnr_list
    elseif tabnr > #_bufnr_list then
      tabnr = 1
    end

    return self:get_bufnr(tabnr)
  end

  -- pos: '-<offset>', '+<offset>', '<tabnr>', '$'
  function self:select_tab(pos)
    local dst_bufnr = self:get_bufnr_at_pos(pos)
    self:select_buf(dst_bufnr)
  end

  -- pos: '-<offset>', '+<offset>', '<tabnr>', '$'
  function self:move_tab(pos)
    local dst_tabnr = _get_tabnr_with_pos(pos)
    local src_tabnr = self:seltabnr()
    if not dst_tabnr or not self:does_tabnr_exist(dst_tabnr) or dst_tabnr == src_tabnr then
      return
    end

    table.remove(_bufnr_list, src_tabnr)
    table.insert(_bufnr_list, dst_tabnr, _selbufnr)
  end

  function self:rm_left_bufs()
    local seltabnr = self:seltabnr()
    if not seltabnr or seltabnr <= 1 then
      return
    end

    self:set_buflist_sync(false)

    local left_bufnrs = { table.unpack(_bufnr_list, 1, seltabnr - 1) }

    _bufnr_list = { table.unpack(_bufnr_list, seltabnr, #_bufnr_list) }
    _bufnr_set = {}
    for _, bufnr in ipairs(_bufnr_list) do
      _bufnr_set[bufnr] = true
    end

    if not self:does_bufnr_exist(_last_selbufnr) then
      _last_selbufnr = _selbufnr
    end

    return left_bufnrs
  end

  function self:rm_right_bufs()
    local seltabnr = self:seltabnr()
    if not seltabnr or seltabnr >= #_bufnr_list then
      return
    end

    self:set_buflist_sync(false)

    local right_bufnrs = { table.unpack(_bufnr_list, seltabnr + 1, #_bufnr_list) }

    _bufnr_list = { table.unpack(_bufnr_list, 1, seltabnr) }
    _bufnr_set = {}
    for _, bufnr in ipairs(_bufnr_list) do
      _bufnr_set[bufnr] = true
    end

    if not self:does_bufnr_exist(_last_selbufnr) then
      _last_selbufnr = _selbufnr
    end

    return right_bufnrs
  end

  function self:rm_other_bufs()
    if not _selbufnr then
      return
    end

    self:set_buflist_sync(false)

    local other_bufnrs = {}
    -- copy
    for _, bufnr in ipairs(_bufnr_list) do
      table.insert(other_bufnrs, bufnr)
    end
    table.remove(other_bufnrs, self:seltabnr())

    _bufnr_list = { _selbufnr }
    _bufnr_set = {}
    _bufnr_set[_selbufnr] = true

    _last_selbufnr = _selbufnr

    return other_bufnrs
  end

  function self:update_buflist(bufnr_list_included) -- bufnrs in bufnr_list are included
    if self:is_buflist_sync() then
      self:log('bufnr_list have not updated', { inspect = true })
      return
    end

    local bufnr_set = {}
    for _, bufnr in ipairs(bufnr_list_included) do
      bufnr_set[bufnr] = true
    end

    -- ## Delete old bufnrs
    local deleted_bufnrs = {}
    for _, bufnr in ipairs(_bufnr_list) do
      if not bufnr_set[bufnr] then
        table.insert(deleted_bufnrs, bufnr)
      end
    end
    for _, bufnr in ipairs(deleted_bufnrs) do
      self:rm_buf(bufnr)
    end

    -- ## Add new bufnrs
    local new_bufnrs = {}
    for _, bufnr in ipairs(bufnr_list_included) do
      if not self:does_bufnr_exist(bufnr) then
        table.insert(new_bufnrs, bufnr)
      end
    end
    for _, bufnr in ipairs(new_bufnrs) do
      self:add_buf(bufnr)
    end

    self:set_buflist_sync(true)
    self:log('bufnr_list have updated', { inspect = true })
  end

  function self:update_selbuf(cur_bufnr)    -- cur_bufnr is a included bufnr
    if cur_bufnr ~= self:selbufnr() then
      _selbufnr = cur_bufnr
    end
  end

  return self
end

return {
  BlSim = BlSim
}
