# Dotfiles

Ansible-managed dotfiles for provisioning development machines. Each tool is a self-contained Ansible role that installs dependencies and deploys configuration.

## Supported Platforms

- macOS (Homebrew)
- Ubuntu / Debian (apt)

## Quick Start

```bash
# 1. Install Ansible
brew install ansible        # macOS
sudo apt install ansible    # Ubuntu/Debian

# 2. Clone this repo
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# 3. Run the playbook
ansible-playbook playbook.yml
```

To run only a specific role:

```bash
ansible-playbook playbook.yml --tags nvim   # nvim | tmux | fzf
```

## What's Included

### Neovim (`roles/nvim`)

Modular Lua configuration using `vim.pack` — the built-in plugin manager introduced in Neovim 0.12. No external plugin manager required.

**Plugins:**

| Plugin | Purpose |
|--------|---------|
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Autocompletion (LSP, buffer, path, snippets) |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Language server configuration |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting and code understanding |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | Fuzzy finder (files, grep, buffers, symbols) |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | Auto-pairs, surround, diff overlay, tabline |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) + [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debugging (codelldb for C/C++) |
| [nvim-tmux-navigation](https://github.com/alexghergh/nvim-tmux-navigation) | Seamless pane navigation between Neovim and tmux |
| [sidekick.nvim](https://github.com/folke/sidekick.nvim) | AI assistant (GitHub Copilot / OpenCode TUI) |

**LSP servers** (installed via `install_lsp.yml`): `bashls`, `clangd`, `cmake`, `copilot`, `docker_language_server`, `lua_ls`, `pyright`

**Key keybindings (leader = Space):**

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>fw` | n/v | Grep word under cursor / visual selection |
| `<leader>fs` | n | Document symbols |
| `<leader>fd` | n | Document diagnostics |
| `<leader>gc` | n | Git commits |
| `<leader>gs` | n | Git status |
| `<leader>e` | n | Toggle file explorer |
| `<leader>E` | n | Find current file in explorer |
| `K` | n | LSP: Hover documentation |
| `grn` | n | LSP: Rename symbol |
| `gra` | n/x | LSP: Code action |
| `grr` | n | LSP: Find references |
| `gri` | n | LSP: Go to implementation |
| `gO` | n | LSP: Document symbols (loclist) |
| `<leader>sd` | n | LSP: Show diagnostics in floating window |
| `<C-h/j/k/l>` | n | Navigate between Neovim/tmux panes |
| `F5` | n | DAP: Start/continue debug |
| `<leader>b` | n | DAP: Toggle breakpoint |
| `<leader>B` | n | DAP: Set conditional breakpoint |
| `<leader>du` | n | DAP: Toggle UI |
| `F10` / `F11` / `F12` | n | DAP: Step over / into / out |
| `<leader>aa` | n | Sidekick: Toggle AI assistant |
| `<leader>at` | n/x | Sidekick: Send this (selection or cursor) |
| `<leader>ap` | n/x | Sidekick: Select prompt |
| `<C-.>` | n/t/i/x | Sidekick: Focus AI panel |

### tmux (`roles/tmux`)

tmux configuration with the TokyoNight Moon theme and custom status-bar scripts.

- **Theme**: `tokyonight_moon.tmux` (sourced from `~/.config/tmux/`)
- **Plugin manager**: [TPM](https://github.com/tmux-plugins/tpm) with `vim-tmux-navigator`
- **Status bar scripts**: `cpu.sh`, `disk.sh`, `ram.sh` (installed to `~/.config/tmux/scripts/`)
- **Key bindings**: vi-style copy mode; `hjkl` pane navigation; new windows/splits inherit current path

### fzf (`roles/fzf`)

Shell environment file (`~/.config/fzf/.fzfenv.sh`) with TokyoNight Moon colours for fzf. Source it from your shell profile to activate:

```bash
# In ~/.zshrc or ~/.bashrc
source ~/.config/fzf/.fzfenv.sh
```

## Project Structure

```
dotfiles/
├── ansible.cfg                   # Ansible defaults (local connection)
├── inventory/localhost.yml       # Inventory targeting local machine
├── playbook.yml                  # Main playbook
└── roles/
    ├── nvim/
    │   ├── tasks/
    │   │   ├── main.yml          # Entry point (includes install + config)
    │   │   ├── install.yml       # Install Neovim and dependencies
    │   │   ├── install_lsp.yml   # Install LSP servers
    │   │   └── config.yml        # Symlink config to ~/.config/nvim
    │   └── files/nvim/           # Neovim configuration (symlinked)
    │       ├── init.lua
    │       ├── lua/core/         # Options, keymaps, autocommands
    │       ├── plugin/           # Plugin configs (auto-sourced by Neovim)
    │       └── ftplugin/         # Filetype-specific settings
    ├── tmux/
    │   ├── tasks/
    │   │   ├── main.yml
    │   │   ├── install.yml
    │   │   └── config.yml
    │   └── files/tmux/           # tmux config + theme + status scripts
    └── fzf/
        ├── tasks/
        │   ├── main.yml
        │   ├── install.yml
        │   └── config.yml
        └── files/.fzfenv.sh      # fzf shell environment (source from profile)
```

## Adding a New Tool

1. Create the role directory:

   ```bash
   mkdir -p roles/<tool>/tasks roles/<tool>/files
   ```

2. Create `roles/<tool>/tasks/main.yml` with install and config tasks.

3. Put config files in `roles/<tool>/files/`.

4. Add the role to `playbook.yml`:

   ```yaml
   roles:
     - role: nvim
       tags: [nvim]
     - role: <tool>
       tags: [<tool>]
   ```

5. Run:

   ```bash
   ansible-playbook playbook.yml --tags <tool>
   ```
