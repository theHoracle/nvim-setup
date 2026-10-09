return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = { "lewis6991/async.nvim" },
	lazy = false,
	config = function()
		local refactor = require("refactoring")
		refactor.setup({})
		for key, action in pairs({
			re = "extract_func",
			rf = "extract_func_to_file",
			rv = "extract_var",
			ri = "inline_var",
			rI = "inline_func",
		}) do
			vim.keymap.set({ "n", "x" }, "<leader>" .. key, function()
				return refactor[action]()
			end, { expr = true, desc = "Refactor: " .. action })
		end
	end,
}
