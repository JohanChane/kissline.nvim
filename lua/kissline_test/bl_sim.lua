-- Test `:lua require('kissline_test.bl_sim').test()`
local kl_log = require('kissline.log').Log:new({
  enable = true
})

local M = {}

M.test = function()
  local BlSim = require('kissline.bl_sim').BlSim
  local bl_sim = BlSim:new({ debug = true })

  -- ## select
  print('--- select ---')
  bl_sim:update_buflist({ 6, 1, 7, 4, 7, 3, 9, 8, 9, 6 })
  kl_log:log('update', '', { inspect = function() bl_sim:inspect() end })
  bl_sim:select_buf(3)
  bl_sim:select_tab(1)
  bl_sim:select_tab(3)
  bl_sim:select_tab(5)
  bl_sim:select_tab(0)
  kl_log:log('select', '', { inspect = function() bl_sim:inspect() end })

  -- ## move
  -- clear
  bl_sim:rm_other_bufs()
  bl_sim:rm_buf(bl_sim:selbufnr())

  print('--- move ---')
  bl_sim:update_buflist({ 6, 1, 7, 4, 7, 3, 9, 8, 9, 6 })
  bl_sim:select_buf(3)
  kl_log:log('update', '', { inspect = function() bl_sim:inspect() end })
  bl_sim:move_tab('$')
  bl_sim:move_tab('-1')
  bl_sim:move_tab('-1')
  bl_sim:move_tab('+1')
  bl_sim:move_tab('+1')
  bl_sim:move_tab('0')
  bl_sim:move_tab(0)
  kl_log:log('move', '', { inspect = function() bl_sim:inspect() end })

  -- ## new/remove buf
  print('--- new/remove ---')
  for _, bufnr in ipairs({ 6, 7, 3, 7, 4, 3, 5, 2, 1, 8 }) do
    bl_sim:add_buf(bufnr)
  end
  kl_log:log('new', '', { inspect = function() bl_sim:inspect() end })

  for _, bufnr in ipairs({ 7, 8, 7, 4, 1, 6, 4, 4, 8, 8 }) do
    bl_sim:rm_buf(bufnr)
  end
  kl_log:log('remove', '', { inspect = function() bl_sim:inspect() end })

  bl_sim:select_buf(4)
  bl_sim:rm_buf(bl_sim:selbufnr())
  bl_sim:rm_buf(bl_sim:selbufnr())
  bl_sim:rm_buf(bl_sim:selbufnr())

  bl_sim:rm_left_bufs()
  bl_sim:rm_right_bufs()
  bl_sim:rm_other_bufs()
  kl_log:log('new/remove', '', { inspect = function() bl_sim:inspect() end })
end

return M
