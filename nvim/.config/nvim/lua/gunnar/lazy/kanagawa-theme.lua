return {
	"rebelot/kanagawa.nvim",
	lazy = false, -- Make sure we load during startup because its main color scheme
	priority = 1000, -- load before all the other start plugins
	opts = {},
	config = function()
		vim.cmd("colorscheme kanagawa")
	end
}
