return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		-- Base linter configuration
		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Check for ANY ESLint config in project hierarchy
		local function has_eslint_config()
			return vim.fs.find({
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
				"package.json",
			}, {
				upward = true,
				path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
			})[1]
		end

		-- Silent fallback for missing ESLint config
		local function safe_eslint()
			if not has_eslint_config() then
				return {} -- Return empty table to disable linter
			end
			return { "eslint_d" } -- Return normal linter
		end

		-- Dynamic linter configuration
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				-- Update linters based on current config presence
				lint.linters_by_ft = vim.tbl_deep_extend("force", lint.linters_by_ft, {
					javascript = safe_eslint(),
					typescript = safe_eslint(),
					javascriptreact = safe_eslint(),
					typescriptreact = safe_eslint(),
					svelte = safe_eslint(),
				})

				lint.try_lint()
			end,
		})
	end,
}
