-- set leader to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-------------General Keymaps--------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

--clear serch highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment / decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal sizes" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })

keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Keymaps for navigation and selection (Normal + Insert modes)
keymap.set({"n","i"}, "<C-Right>", "$", { noremap = true, silent = true }) -- cmd + right arrow to go to end of line
keymap.set({"n","i"}, "<C-S-Right>", "v$", { noremap = true, silent = true }) -- cmd + shift + right arrow to select to end of line

-- Keymaps for moving lines (Normal mode only)
keymap.set("n", "<A-Down>", ":m .+1<CR>", { noremap = true, silent = true }) -- option + down arrow to move line down
keymap.set("n", "<A-Up>", ":m .-2<CR>", { noremap = true, silent = true }) -- option + up arrow to move line up
