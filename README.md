# Neovim Configuration

## Requirements

- `xclip` for global clipboard
- `ripgrep` for better searching
- `fd-find` for faster file finding (`fd` command)

## Plugin management

Plugins are managed by Neovim's built-in `vim.pack` (Neovim 0.12+). The first
startup installs the configured plugins and writes `nvim-pack-lock.json` in
this directory. Commit that lockfile to make installs reproducible.

Each file in `plugin/` is auto-sourced by Neovim and owns both its
`vim.pack.add()` declaration and its plugin configuration. Add or remove a
plugin by adding or removing one of those files.

To update plugins, run:

```vim
:lua vim.pack.update()
```

Review the update buffer and use `:write` to accept the updates, then restart
Neovim. Run `:checkhealth vim.pack` to inspect the package installation.

## LSP Servers

- `pyright` for Python
- `clangd` for C/C++
- `texlab` for LaTeX
- `tinymist` for Typst
- `ts_ls` for JavaScript/TypeScript
- `vue-language-server` for Vue.js
- `rust-analyzer` for Rust
- `lua-language-server` for Lua

## Formatters

- `black` and `isort` for Python
- `clang-format` for C/C++
- `latexindent` for LaTeX
- `typstyle` for Typst
- `prettier` for JavaScript/TypeScript/HTML/CSS/JSON/React/Vue/Markdown
- `rustfmt` for Rust
- `stylua` for Lua
- `shfmt` for Shell scripts
