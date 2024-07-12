--- TabLine ---
local M = {}

vim.o.showtabline = 1

local function kiss_tab_sel(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  local winnr = vim.fn.tabpagewinnr(tabnr)
  local bufname = vim.fn.bufname(buflist[winnr])
  if bufname ~= '' then
    bufname = vim.fn.fnamemodify(bufname, ':t') -- get file name
  else
    bufname = '[No Name]'
  end

  -- Add a plus sign if the buffer is modified
  if vim.fn.getbufvar(buflist[winnr], '&mod') == 1 then
    bufname = bufname .. '+'
  end

  return bufname
end

M.kisstabline = function()
  local tab_sect_str = ''                  -- tab section string
  local cur_tab_sect_width = 0
  local tab_sect_width = vim.o.columns - 0 -- The entire tab page displays tabs, so subtract 0.
  local does_contain_seltab = false
  local left_more_str = '<<'
  local right_more_str = '>>'
  for tabnr = 1, vim.fn.tabpagenr('$') do
    -- Select the highlighting
    local the_tab_str = ''
    if tabnr == vim.fn.tabpagenr() then
      the_tab_str = the_tab_str .. '%#TabLineSel#'
      does_contain_seltab = true
    else
      the_tab_str = the_tab_str .. '%#TabLine#'
    end

    -- Set the buffer number (for mouse clicks)
    if vim.fn.has('tablineat') then
      the_tab_str = the_tab_str .. '%' .. tabnr .. 'T'
    end

    -- The label is the buffer name
    local the_tab_content = ' ' .. tabnr .. ':' .. kiss_tab_sel(tabnr) .. ' ' -- content is what you see
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
        if tabnr == vim.fn.tabpagenr() then -- the seltab across the tab page.
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

  -- Right-align the label to `X` the current tab page
  --if vim.fn.tabpagenr('$') > 1 then
  --  tabline_str = tabline_str .. '%=%#TabLine#%999XX'
  --end

  return tabline_str
end

vim.o.tabline = '%!v:lua.require("kissline").tabline.kisstabline()'

return M
