local M = {}

M.kissline_augroup = vim.api.nvim_create_augroup('KissLine', { clear = true })

-- ## Tabline/Bufline highlighting
-- deus theme
vim.api.nvim_set_hl(0, 'TabLineSel', { fg = '#292c33', bg = '#98C379', ctermfg = 235, ctermbg = 114 })
-- TabLine
-- TabLineFill

return M
