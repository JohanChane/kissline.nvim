local M = {}

M.test = function()
  local BlSim = require('kissline.bl_sim').BlSim
  local bl_sim = BlSim:new({ debug = true })

  -- ## select
  print('--- select ---')
  bl_sim:update_buflist({6, 1, 7, 4, 7, 3, 9, 8, 9, 6})
  bl_sim:log('update', { inspect = true })
  bl_sim:select_buf(3)
  bl_sim:select_tab(1)
  bl_sim:select_tab(3)
  bl_sim:select_tab(5)
  bl_sim:select_tab(0)
  bl_sim:log('select', { inspect = true })

  -- ## move
  -- clear
  bl_sim:rm_other_bufs()
  bl_sim:rm_buf(bl_sim:selbufnr())

  print('--- move ---')
  bl_sim:update_buflist({6, 1, 7, 4, 7, 3, 9, 8, 9, 6})
  bl_sim:select_buf(3)
  bl_sim:log('update', { inspect = true })
  bl_sim:move_tab('$')
  bl_sim:move_tab('-1')
  bl_sim:move_tab('-1')
  bl_sim:move_tab('+1')
  bl_sim:move_tab('+1')
  bl_sim:move_tab('0')
  bl_sim:move_tab(0)
  bl_sim:log('move', { inspect = true })

  -- ## new/remove buf
  print('--- new/remove ---')
  for _, bufnr in ipairs({6, 7, 3, 7, 4, 3, 5, 2, 1, 8}) do
    bl_sim:add_buf(bufnr)
  end
  bl_sim:log('new', { inspect = true })

  for _, bufnr in ipairs({7, 8, 7, 4, 1, 6, 4, 4, 8, 8}) do
    bl_sim:rm_buf(bufnr)
  end
  bl_sim:log('remove', { inspect = true })

  bl_sim:select_buf(4)
  bl_sim:rm_buf(bl_sim:selbufnr())
  bl_sim:rm_buf(bl_sim:selbufnr())
  bl_sim:rm_buf(bl_sim:selbufnr())

  bl_sim:rm_left_bufs()
  bl_sim:rm_right_bufs()
  bl_sim:rm_other_bufs()
  bl_sim:log('new/remove', { inspect = true })
end

return M
