# INSTALL — macOS + Arch (Hyprland) hybrid setup

Strategy: **system-first, mason-fallback**.
`mason.nvim` is configured with `PATH = "append"`, so `brew` / `pacman`
binaries win when present, and mason fills gaps on a fresh clone.

No OS forks in the config. Same repo works on both machines.

## 1. Arch Linux (Hyprland)

You already have `wl-clipboard`, so `opt.clipboard = "unnamedplus"` works.
Nothing extra needed for clipboard.

```bash
# core: nvim, toolchain for treesitter/blink, finder tools
sudo pacman -S --needed base-devel git curl tar unzip gzip \
  neovim tree-sitter-cli \
  nodejs npm python \
  ripgrep fd fzf bat \
  ttf-jetbrains-mono-nerd

# system-preferred LSP + formatters (fast, native; mason covers the rest)
sudo pacman -S --needed \
  lua-language-server pyright typescript-language-server typescript \
  clang go gopls rust rust-analyzer \
  bash-language-server shfmt stylua ruff prettier \
  php composer ruby

# gaps mason doesn't host well
gem install --user-install ruby-lsp rubocop
npm i -g intelephense
composer global require friendsofphp/php-cs-fixer

# optional: match the old macOS TS fallback path (else config just skips it)
mkdir -p ~/.local/share/ts && npm i --prefix ~/.local/share/ts typescript
```

Hyprland notes:

- Use `<leader>cf` / `<leader>f` to format. `<S-C-f>` rarely reaches Neovim
  through foot/kitty/alacritty + Hyprland bindings, it is kept for macOS only.
- Set your terminal font to `JetBrainsMono Nerd Font` or icons show as boxes.
- If yanks stop reaching system, verify: `wl-copy --version` and
  `:checkhealth provider.clipboard` inside nvim.

## 2. macOS (existing machine)

```bash
brew install neovim git node python ripgrep fd fzf bat \
  lua-language-server pyright typescript typescript-language-server \
  llvm go gopls rust-analyzer bash-language-server shfmt stylua ruff prettier \
  php composer ruby

gem install ruby-lsp rubocop
npm i -g intelephense
```

Or save as `Brewfile` and `brew bundle`:

```ruby
brew "neovim"
brew "git"
brew "node"
brew "python"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "bat"
brew "lua-language-server"
brew "pyright"
brew "typescript"
brew "typescript-language-server"
brew "llvm"
brew "go"
brew "gopls"
brew "rust-analyzer"
brew "bash-language-server"
brew "shfmt"
brew "stylua"
brew "ruff"
brew "prettier"
brew "php"
brew "composer"
brew "ruby"
```

## 3. First run on a fresh clone

```bash
git clone <repo> ~/.config/nvim
nvim
# inside nvim:
:Lazy sync
:Mason          # should show the ensure_installed list, empty on Arch if pacman covered it
:checkhealth
```

What mason auto-installs as fallback (`lua/plugins/mason.lua`):

- LSP: `lua-language-server, pyright, typescript-language-server, clangd,
  gopls, rust-analyzer, bash-language-server, intelephense`
- Formatters: `stylua, ruff, prettier, clang-format, shfmt, php-cs-fixer, rubocop`
- Skipped: `gofmt/rustfmt` (ship with go/rust), `ruby-lsp` (via gem).

## 4. Verify

```vim
:checkhealth provider.clipboard lsp treesitter conform
:Mason
:ConformInfo
:LspInfo
```

| Symptom | Fix |
|---|---|
| `live_grep` empty | install `ripgrep` |
| `:FzfLua files` slow | install `fd` |
| `stylua/prettier/...` missing | `:Mason` or pacman/brew it |
| Boxes instead of icons | switch terminal to Nerd Font |
| `<S-C-f>` does nothing on Arch | expected, use `<leader>cf` |
