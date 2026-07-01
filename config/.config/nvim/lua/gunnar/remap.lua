vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Back to directory/tree view

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Neotree toggle
vim.keymap.set('n', '<C-\\>', ':Neotree toggle<CR>')
vim.keymap.set('n', '<leader>p', ':Neotree toggle<CR>')

-- Alternate (last) file
vim.keymap.set('n', '<leader><Tab>', '<C-^>')

-- System clipboard with Cmd+C / Cmd+V
vim.keymap.set('v', '<D-c>', '"+y')
vim.keymap.set({'n', 'v'}, '<D-v>', '"+p')
vim.keymap.set('i', '<D-v>', '<C-r>+')
