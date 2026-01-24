return {
	'nvim-telescope/telescope.nvim', tag = '0.1.8',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
	},
	opts = {},
	config = function()
		require('telescope').setup {
			defaults = {
				file_ignore_patterns = {
					"node_modules/",
					".git/",
					"vendor/",
					"%.lock",
					"__pycache__/",
					"%.pyc",
					"target/",
					"build/",
					"dist/",
					"%.class",
				}
			},
			pickers = {
				find_files = {
					theme = "ivy",
					hidden = true,
					no_ignore = true,  -- Show files even if in .gitignore
				},
				git_files = {
					theme = "dropdown"
				},
				grep_string = {
					theme = "ivy",
					additional_args = { "--hidden", "--no-ignore" }
				},
				live_grep = {
					theme = "ivy",
					additional_args = { "--hidden", "--no-ignore" }
				}
			},
			extensions = {
				fzf = {}
			}
		}

		require('telescope').load_extension('fzf')

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>fp', builtin.find_files)
		vim.keymap.set('n', '<leader>fh', builtin.help_tags)
		vim.keymap.set('n', '<C-p>', builtin.find_files)
		vim.keymap.set('n', '<D-p>', builtin.find_files)  -- Cmd+p (requires terminal support)
		vim.keymap.set('n', '<leader>ps', function()
		builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end, { desc = 'Telescope project search' })

		-- Go straight to editing neovim config
		vim.keymap.set('n', '<leader>en', function()
			builtin.find_files { cwd = vim.fn.stdpath("config") }
		end)

		require("gunnar.config.telescope.multi_grep").setup()
	end
}
