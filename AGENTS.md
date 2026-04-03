# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Overview

Ansible-managed dotfiles repository. Each tool is a self-contained Ansible role
under `roles/` that installs dependencies and symlinks configuration files.
Currently contains three roles: `nvim` (modular Lua-based Neovim config), `tmux`
(config + Tokyo Night theme + status-bar scripts), and `fzf` (shell env file).

## Build / Lint / Test Commands

### Running the playbook

```bash
ansible-playbook playbook.yml                  # all roles
ansible-playbook playbook.yml --tags nvim      # single role
ansible-playbook playbook.yml --check          # dry run (no changes)
ansible-playbook playbook.yml --syntax-check   # syntax only
```

`ansible.cfg` sets the inventory to `inventory/localhost.yml` and disables
`.retry` files and host-key checking — no extra flags needed.

### Validation (no CI — run manually)

```bash
# YAML syntax (Ruby, available on macOS)
ruby -e "require 'yaml'; Dir.glob('**/*.yml').each { |f| YAML.safe_load(File.read(f)); puts \"OK: #{f}\" }"

# Lua syntax (luac ships with Neovim's LuaJIT)
find roles/*/files -name '*.lua' -exec luac -p {} \; -print

ansible-lint playbook.yml   # if ansible-lint is installed
yamllint .                  # if yamllint is installed
```

### Neovim plugin management

Plugins use `vim.pack` (Neovim 0.12+ built-in). Run inside Neovim:

```
:lua vim.pack.update()          — update all plugins
:lua vim.pack.update({'name'})  — update one plugin
:checkhealth vim.pack           — diagnose issues
```

The lockfile `roles/nvim/files/nvim/nvim-pack-lock.json` is committed for
reproducible installs.

## Code Style — Lua (Neovim config)

### Formatting

- **2-space indentation**, no tabs
- **Double quotes** for all strings: `require("core.options")`, `{ desc = "Save file" }`
- **Trailing commas** on the last element of multi-line tables
- Max line length: soft limit ~120 characters (see `colorcolumn` in `core/options.lua`)

### File structure

- `init.lua` — entry point; loads core modules and defines `PackChanged` hooks.
- `lua/core/*.lua` — execute side effects directly (options, keymaps, autocmds). No return value.
- `plugin/*.lua` — **auto-sourced by Neovim** alphabetically. Each file calls `vim.pack.add()`,
  then configures the plugin. Use numeric prefixes (`00-`, `01-`) to force load order.
- `ftplugin/<filetype>.lua` — **auto-sourced per filetype**. Use for indent overrides
  (`require("core.indent").set(2)`) and enabling treesitter folding. One file per filetype.
- One file per plugin concern. One file per concern in `core/`.

### Requires, aliases, and naming

```lua
-- Top of file: alias frequently used globals
local map     = vim.keymap.set
local opt     = vim.opt
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
```

- **snake_case** for all variables, functions, and augroup names
- Augroup names: short and descriptive — `"highlight_yank"`, `"lsp_keymaps"`
- Keymap `desc`: short imperative phrase — `"Toggle file explorer"`, `"Go to definition"`

### Keymaps

- All keymaps **must** include a `desc` field
- Leader key is `Space` (default — not explicitly set in `core/keymaps.lua`)
- Plugin keymaps go in the plugin's own `plugin/*.lua` file, not in `core/keymaps.lua`
- LSP keymaps are buffer-local, set inside the `LspAttach` autocmd
- Prefix `desc` with the subsystem: `"LSP: Go to definition"`, `"DAP: Toggle breakpoint"`

### Error handling and lazy loading

- Use `pcall()` for optional requires: `local ok, mod = pcall(require, "module")`
- Use `pcall()` for API calls that may fail (e.g., setting cursor position)
- Lazy-load via autocmd when necessary; prefer simplicity over micro-optimisation:

```lua
vim.api.nvim_create_autocmd("InsertEnter", { once = true, callback = function()
  vim.pack.add({ "https://github.com/user/plugin" })
  require("plugin").setup()
end })
```

### Comments

- **File header**: `-- <path> — <description>` (em dash), followed by explanatory block
- **Section dividers**: `-- ── Section Name ───────────────────────────`
- **Inline comments**: explain the *why*, not the *what*
- This is a teaching-oriented repo — comments should explain Neovim/Ansible concepts

## Code Style — YAML (Ansible)

### Formatting and module naming

- **2-space indentation**; start task files with `---`
- **Double quotes** for Jinja2: `"{{ ansible_env.HOME }}"` and octal modes: `mode: "0755"`
- **Unquoted** for plain values: `state: present`, `become: true`
- **Always use FQCN**: `ansible.builtin.file`, `ansible.builtin.apt`, `community.general.homebrew`
  — never short names like `file`, `apt`, `copy`

### Tasks

- Every task **must** have a `name:` field; sentence case, imperative verb
- Include platform qualifier: `"Install Neovim and dependencies via Homebrew (macOS)"`
- `when:` for OS guards: `ansible_os_family == "Darwin"` / `"Debian"`
- `loop:` (not `with_items`); add inline comments on non-obvious items
- `ignore_errors: true` requires an inline comment explaining why

### Role structure

```
roles/<tool>/
├── tasks/
│   ├── main.yml      # Entry point; includes install.yml + config.yml
│   ├── install.yml   # Package installation (OS-conditional)
│   └── config.yml    # Symlink/deploy config files
└── files/            # Config files to be symlinked
```

Extended roles may add extra task files (e.g., `install_lsp.yml` in `nvim`) included
via `ansible.builtin.include_tasks`. Config files are **symlinked** (not copied) so
edits in the repo take effect without re-running the playbook.

- Use `role_path` for portable paths: `"{{ role_path }}/files/..."`
- Always ensure parent directories exist before creating symlinks
- Remove existing targets before symlinking to handle dir-to-symlink transitions
- Shell scripts (e.g., tmux status-bar scripts) must be `mode: "0755"` via a separate task

### Adding a role to the playbook

```yaml
# In playbook.yml
- role: <tool>
  tags: [<tool>]
```

## Repository Conventions

- `.gitignore` exists at the repo root — update it if introducing build artifacts or secrets
- `roles/nvim/files/nvim/nvim-pack-lock.json` is version-controlled for reproducibility
- No external linter/formatter configs exist yet; follow the patterns in existing files
- Commit messages: `<type>: <concise description>` with an optional body explaining the change
