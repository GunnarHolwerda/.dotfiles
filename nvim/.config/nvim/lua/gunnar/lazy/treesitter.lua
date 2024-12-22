return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	lazy = false,
	config = function ()
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { 
				"lua", 
				"vim", 
				"vimdoc",
				"bash",
				"css",
				"git_config",
				"gitignore",
				"gitcommit",
				"go",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"markdown",
				"regex",
				"sql",
				"tmux",
				"typescript",
				"yaml",
			},
			-- Do not synchronously install enure_installed
			sync_install = false, 
			-- Automatically install missing parsers when entering buffer
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
			additional_vim_regex_highlighting = false,
		})
	end
}
