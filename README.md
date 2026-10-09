# theHoracle development setup

Neovim configuration for TypeScript, Python, and Rust, with Tokyo Night colors,
Nerd Font icons, Telescope, completion/snippets, Git tools, formatting, and AI tools.
Requires Neovim 0.12+, a C compiler, and tree-sitter-cli 0.26.1+.

## Restore on macOS

Install Apple Command Line Tools and Homebrew, then:

```sh
git clone https://github.com/theHoracle/nvim-setup ~/.config/nvim
brew bundle --file=~/.config/nvim/machine/Brewfile
fnm install --lts
fnm default lts-latest
uv python install
```

Install Rust using the official rustup installer, then run:

```sh
rustup component add rust-analyzer rustfmt clippy
```

The `machine/` folder contains snapshots of the shell and Ghostty settings.
Review and copy `machine/zsh/.zprofile` and `.zshrc` into your home directory.
Copy `machine/ghostty/config.ghostty` to
`~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`.
The shell maps `vim` and `vi` to Neovim. After loading it, install pnpm with
`npm install -g --allow-scripts=pnpm pnpm` and run `pnpm setup`.
The Brewfile installs Bun and JetBrainsMono Nerd Font.
The existing tmux configuration is in `tmux-setup/.tmux.conf` (copy to `~/.tmux.conf`).

Git identity and GitHub authentication can be restored with:

```sh
git config --global user.name theHoracle
git config --global user.email jamesthehoracle@gmail.com
gh auth login
gh auth setup-git
```

Open Neovim to install plugins and Mason tools. `lazy-lock.json` records the tested
plugin revisions; use `:Lazy restore` to return to them, or `:Lazy update` to update.
Tree-sitter parsers install automatically; `:TSUpdate` updates them.
Avante's build hook fixes the macOS libiconv path in upstream release binaries and
signs the repaired libraries. Provider credentials are supplied through environment
variables and are not stored in this repository.

## Plugin review — October 2026

All retained external plugins were updated to their current default branches or
the latest release matching existing version constraints. Stable plugins were kept
when they still serve a useful role; age alone was not treated as abandonment.

Removed:

- Dressing: archived upstream; Avante uses native input and Telescope selection.
- Neodev: archived upstream; replaced with Lazydev for Lua development.
- Lspsaga: no configured features; existing LSP/Telescope bindings cover the role.
- mini.pick and fzf-lua: unused alternatives to the configured Telescope picker.
- Copilot: only an optional dependency; Avante is configured for OpenAI.
- Cockpit: experimental test UI without a project-specific setup.
- cellular-automaton: novelty animation with no development function.

Migrated Tree-sitter to its maintained main branch and native Neovim highlighting,
removing the old compatibility shim. Migrated LSP setup to `vim.lsp.config` and
`vim.lsp.enable`, Mason to the mason-org repositories, Avante to avante-corp and
its current provider settings, session commands, and refactoring keybindings.
The custom local dingllm shortcuts were preserved; their providers/models may
need adjustment for the services you use.

Validation: all 53 plugin configurations and native libraries load; fenced
Markdown containing TypeScript, Python, and Rust parses and renders; ts_ls,
pyright, and rust_analyzer attach to real source files. No paid AI requests were
made during validation.

Maintenance sources: [Dressing](https://github.com/stevearc/dressing.nvim),
[Neodev](https://github.com/folke/neodev.nvim),
[Tree-sitter](https://github.com/nvim-treesitter/nvim-treesitter),
[Mason LSP](https://github.com/mason-org/mason-lspconfig.nvim),
[LSP config](https://github.com/neovim/nvim-lspconfig).
