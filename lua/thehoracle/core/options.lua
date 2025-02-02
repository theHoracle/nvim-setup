vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

-- line numbers
opt.relativenumber = true --shoe relative line numebers
opt.number = true -- show absolute line number on cursor line (when rel is on)

-- tabs and indentation 
opt.tabstop = 2 -- 2 space for tabs
opt.shiftwidth = 2  --2  spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent fron current line when starting new one

-- line wrapping
opt.wrap = false -- disable line wrapping
opt.smartcase = true  -- if include mixedcase in search, we make it case sensitive

--cursor line
opt.cursorline = true -- highlight the current cursor line


----- appeareace
--
--turn on termguicolors for nightfly colorscheme to work, use item2 or anyother true color terminal
--
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be dark
opt.signcolumn = "yes" -- show sign column so that text does not shift

--backspace
opt.backspace = "indent,eol,start" -- allow backspace on indentm eond of line or insert mode start position
-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true 
opt.splitbelow = true

-- turn off swapfile
opt.swapfile = false
