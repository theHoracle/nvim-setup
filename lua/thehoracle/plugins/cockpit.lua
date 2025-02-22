return {
	"ThePrimeagen/cockpit",
	config = function()
		require("cockpit")
		vim.keymap.set("n", "<leader>ct", "<cmd>CockpitTest<CR>")
		vim.keymap.set("n", "<leader>cr", "<cmd>CockpitRefresh<CR>")
	end,
}
