return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false,
	config = function()
		require("nvim-treesitter").install({
			"bash",
			"css",
			"git_config",
			"gitcommit",
			"gitignore",
			"go",
			"html",
			"javascript",
			"jsdoc",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"regex",
			"sql",
			"tmux",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function(args)
				if pcall(vim.treesitter.start, args.buf) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
