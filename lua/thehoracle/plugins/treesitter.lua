return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = { { "windwp/nvim-ts-autotag", opts = {} } },
	config = function()
		local ts = require("nvim-treesitter")
		ts.setup({})
		ts.install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"go",
			"rust",
			"python",
		})
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true }),
			callback = function(ev)
				local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
				if lang and pcall(vim.treesitter.start, ev.buf, lang) then
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
		vim.keymap.set({ "n", "x" }, "<C-space>", function()
			local node = vim.treesitter.get_node()
			if vim.fn.mode():match("[vV]") and node then
				node = node:parent() or node
			end
			if not node then
				return
			end
			local sr, sc, er, ec = node:range()
			vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
			vim.cmd("normal! v")
			vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
		end, { desc = "Select syntax node" })
	end,
}
