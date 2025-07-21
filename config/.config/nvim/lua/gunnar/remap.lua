vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex) -- Back to directory/tree view

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Neotree toggle
vim.keymap.set('n', '<C-\\>', ':Neotree toggle<CR>')
