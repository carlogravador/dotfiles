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
ansible-playbook playbook.yml --tags nvim
```

## What's Included

### Neovim (`roles/nvim`)

Modular Lua configuration managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

**Plugins:**

| Plugin | Purpose |
|--------|---------|
| [mason.nvim](https://github.com/williamboman/mason.nvim) + [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP server management and configuration |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion (LSP, buffer, path, snippets) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting and code understanding |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | Fuzzy finder (files, grep, buffers, symbols) |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | File explorer |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) + [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debugging (codelldb for Rust/C/C++) |

**LSP servers auto-installed via Mason:**

- `lua_ls` — Lua
- `rust_analyzer` — Rust
- `clangd` — C / C++

**Key keybindings (leader = Space):**

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Find buffers |
| `<leader>e` | n | Toggle file explorer |
| `gd` | n | Go to definition |
| `gr` | n | Find references |
| `K` | n | Hover documentation |
| `<leader>ca` | n,v | Code actions |
| `<leader>rn` | n | Rename symbol |
| `<leader>f` | n | Format file |
| `F5` | n | Start/continue debug |
| `<leader>b` | n | Toggle breakpoint |
| `F10` / `F11` / `F12` | n | Step over / into / out |

## Project Structure

```
dotfiles/
├── ansible.cfg                 # Ansible defaults (local connection)
├── inventory/localhost.yml     # Inventory targeting local machine
├── playbook.yml                # Main playbook
└── roles/
    └── nvim/
        ├── tasks/
        │   ├── main.yml        # Entry point (includes install + config)
        │   ├── install.yml     # Install neovim and dependencies
        │   └── config.yml      # Symlink config to ~/.config/nvim
        └── files/nvim/         # Neovim configuration (symlinked)
            ├── init.lua
            └── lua/
                ├── core/       # Options, keymaps, autocommands
                └── plugins/    # Plugin specs (one file per plugin)
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
