# Neovim Configuration

A clean, OS-agnostic **Neovim 0.12+** configuration built for **C/C++, Python, and Java** across **macOS**, **Linux (`glibc`)**, and **Windows**.

---

## Use Cases
* **C/C++, Python, and Java development** — Pre-wired LSP (`clangd`, `neocmake`, `basedpyright`, `jdtls` + Lombok, `lua_ls`), manual formatting (`clang-format`, `ruff`, `google-java-format`, `stylua`), linting (`clang-tidy`, `ruff`), docstrings (`neogen` for Doxygen, Google Python, and Javadoc), and step-through debugging (`codelldb`, `debugpy`, `java-debug-adapter`).
* **Cross-OS portability (macOS, Linux `glibc`, & Windows)** — Zero hardcoded OS paths; tools and parsers install automatically via `lazy.nvim`, `mason.nvim`, and `nvim-treesitter`.
* **Keyboard-only, minimal-chrome workflow** — Transparent `rose-pine` theme, upright (non-italic) text, buffer-based file editing (`oil.nvim`), fast fuzzy search (`fzf-lua`), single-pane debugging (`nvim-dap-view`), and a centered floating terminal (`toggleterm.nvim`).

## Non-Use Cases
* **Mouse-driven editing** — Mouse support is intentionally disabled (`mouse = ""`).
* **Auto-formatting on save** — Files are never reformatted behind your back on `:w`; formatting is strictly triggered on demand (`<leader>cf`).
* **Implicit OS clipboard syncing** — Standard yanks/deletes (`y`, `d`, `c`) stay inside Neovim registers and do not overwrite your system clipboard unless you explicitly use `"+`.
* **Persistent IDE sidebars & tab bars** — No file-tree drawer (`nvim-tree`/`neo-tree`), no buffer tabline, and no multi-split `nvim-dap-ui`.
* **Frontend / other language stacks out of the box** — Web/Rust/Go toolchains are not pre-installed (though easy to add in `lua/plugins/lsp.lua`).
* **Neovim `< 0.12` or `musl`-only prebuilt binaries** — Relies on Neovim `0.12+` APIs (`vim.lsp.config`, `winborder`, `vim.snippet`, `nvim-treesitter` `main` branch) and macOS/Linux (`glibc`)/Windows Mason binaries.

---

## System Prerequisites

Requires **Neovim `0.12+`**, a **Nerd Font** in your terminal, and:

* **macOS (`brew`):**
  ```sh
  brew install git llvm node python openjdk@21 fzf ripgrep fd tree-sitter
  ```
* **Linux (`glibc` — e.g. Void `xbps`, Ubuntu/Debian `apt`, Arch `pacman`):**
  ```sh
  # Void Linux
  sudo xbps-install -S git gcc clang nodejs python3 openjdk21 fzf ripgrep fd tree-sitter curl unzip tar make

  # Ubuntu / Debian
  sudo apt install git build-essential clang nodejs npm python3 python3-venv openjdk-21-jdk fzf ripgrep fd-find tree-sitter-cli curl unzip tar

  # Arch Linux
  sudo pacman -S git base-devel clang nodejs npm python jdk21-openjdk fzf ripgrep fd tree-sitter-cli curl unzip tar
  ```
* **Windows (`winget` — native PowerShell or WSL2):**
  ```powershell
  winget install Git.Git LLVM.LLVM OpenJS.NodeJS.LTS Python.Python.3.12 Microsoft.OpenJDK.21 junegunn.fzf BurntSushi.ripgrep.MSVC sharkdp.fd Treesitter.TreesitterCLI
  ```

Clone into `~/.config/nvim` (macOS / Linux / WSL2) or `%LOCALAPPDATA%\nvim` (native Windows). On first launch (`nvim`), `lazy.nvim`, `nvim-treesitter`, and `mason-tool-installer` automatically install all plugins, parsers, language servers, formatters, linters, and debuggers. Run `:Copilot auth` once to sign in to GitHub Copilot.

---

## Keyboard Shortcuts

**Leader & LocalLeader:** `<Space>`

### General & Built-in
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<Esc>` | Normal | Clear search highlights |
| `"+y` / `"+p` | Normal / Visual | Copy to / paste from OS system clipboard |
| `gcc` / `gc` | Normal / Visual | Comment line / selection |
| `za` / `zR` / `zM` | Normal | Toggle fold / Open all folds / Close all folds |

### File Explorer (`oil.nvim`) & Terminal (`toggleterm.nvim`)
| Key | Mode | Action |
| :--- | :--- | :--- |
| `-` | Normal | Open parent directory in `oil.nvim` (`:w` saves file renames/creates/deletes, `g.` toggles dotfiles, `g?` shows help) |
| `<C-\>` *(or `:ToggleTerm`)* | Normal / Term | Toggle centered floating terminal |
| `<C-\><C-n>` | Terminal | Switch terminal to Normal mode (`i` returns to terminal input) |

### Fuzzy Finder (`fzf-lua`)
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<leader>ff` | Normal | Find files (includes dotfiles, respects `.gitignore`) |
| `<leader>fg` | Normal | Live grep across project |
| `<leader>fw` | Normal | Grep word under cursor |
| `<leader>fb` | Normal | Open buffers |
| `<leader>fr` | Normal | Recent files |
| `<leader>fd` | Normal | Workspace diagnostics |
| `<leader>fs` / `<leader>fS` | Normal | Document symbols / Workspace symbols |
| `<leader>fh` / `<leader>fk` | Normal | Help tags / Active keymaps |

### LSP, Formatting, Linting & Docstrings
| Key | Mode | Action |
| :--- | :--- | :--- |
| `gd` / `gD` / `gy` | Normal | Go to definition / declaration / type definition |
| `K` | Normal | Hover documentation (`K` again focuses popup) |
| `grn` / `gra` | Normal | Rename symbol / Code actions |
| `grr` / `gri` / `gO` | Normal | References / Implementation / Symbol outline |
| `<C-s>` | Insert | Function signature help |
| `<leader>cd` / `[d` / `]d` | Normal | Line diagnostic float / Prev & next diagnostic |
| `<leader>th` | Normal | Toggle LSP inlay hints |
| `<leader>ch` | Normal *(C/C++)* | Switch between header and source (`clangd`) |
| `<leader>co` | Normal *(Java)* | Organize imports (`jdtls`) |
| `<leader>crv` / `<leader>crc` / `<leader>crm` | Normal / Visual *(Java)* | Extract variable / constant / method (`jdtls`) |
| `<leader>cf` | Normal / Visual | Format buffer or selection (`conform.nvim`) |
| `<leader>cl` | Normal | Run linter on buffer (`nvim-lint`) |
| `<leader>nf` | Normal | Generate Doxygen / Python / Javadoc docstring (`neogen`) |

### Completion (`nvim-cmp`) & Copilot (`copilot.lua`)
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<C-n>` / `<C-p>` *(or `<Tab>` / `<S-Tab>`)* | Insert | Next / previous completion item (or snippet placeholder) |
| `<CR>` | Insert | Confirm **explicitly selected** item (otherwise normal newline) |
| `<C-Space>` / `<C-e>` | Insert | Trigger completion / Abort menu |
| `<C-b>` / `<C-f>` | Insert | Scroll documentation popup up / down |
| `<M-l>` / `<M-k>` / `<M-j>` | Insert | Accept Copilot ghost text (full / word / line) |
| `<M-]>` / `<M-[>` / `<C-]>` | Insert | Next / previous / dismiss Copilot suggestion |

### Motions, Surround, Undo & Git
| Key | Mode | Action |
| :--- | :--- | :--- |
| `s` / `S` | Normal / Visual / Op | Flash jump / Flash Treesitter node selection |
| `ys{motion}{char}` / `cs{old}{new}` / `ds{char}` | Normal | Add / change / delete surrounding pairs (`nvim-surround`) |
| `<leader>u` | Normal | Toggle visual undo tree (`undotree`) |
| `<leader>gd` / `<leader>gq` | Normal | Open / close Git `diffview` (and 3-way merge view) |
| `<leader>gh` / `<leader>gH` | Normal | Current file git history / Branch git history |

### Debugging (`nvim-dap` + `nvim-dap-view`)
| Key | Mode | Action |
| :--- | :--- | :--- |
| `<F5>` | Normal | Start debugging / Continue |
| `<F10>` / `<F11>` / `<F12>` | Normal | Step Over / Step Into / Step Out |
| `<leader>db` / `<leader>dB` | Normal | Toggle breakpoint / Conditional breakpoint |
| `<leader>dv` | Normal | Toggle `nvim-dap-view` (`W` Watches, `S` Scopes, `E` Exceptions, `B` Breakpoints, `T` Threads, `R` REPL, `C` Console) |
| `<leader>dr` / `<leader>dl` / `<leader>dq` | Normal | Toggle REPL / Run last session / Terminate session |
| `<leader>dt` / `<leader>dT` | Normal *(Java)* | Debug nearest JUnit test / Debug test class |

---

## Directory Layout

```text
~/.config/nvim/ (or %LOCALAPPDATA%\nvim\ on Windows)
├── init.lua
├── lazy-lock.json
└── lua/
    ├── config/
    │   ├── autocmds.lua           # Yank highlight, indent overrides, Treesitter attach
    │   ├── jdtls.lua              # Cross-OS Eclipse JDTLS + Lombok + Java DAP setup
    │   ├── keymaps.lua            # Base keybindings
    │   ├── lazy.lua               # lazy.nvim bootstrap
    │   └── options.lua            # Core editor options
    └── plugins/
        ├── colorscheme.lua        # rose-pine (main, upright, transparent)
        ├── completion.lua         # nvim-cmp + copilot.lua
        ├── dap.lua                # nvim-dap + nvim-dap-view + mason-nvim-dap
        ├── editor.lua             # autopairs, surround, flash, undotree, neogen, diffview
        ├── formatting_linting.lua # conform.nvim + nvim-lint
        ├── lsp.lua                # mason + lspconfig + nvim-jdtls
        ├── navigation.lua         # oil.nvim + fzf-lua
        ├── treesitter.lua         # nvim-treesitter (main branch)
        └── ui.lua                 # lualine + web-devicons + toggleterm
```
