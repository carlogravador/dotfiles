# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Overview

Ansible-managed dotfiles repository. Each tool is a self-contained Ansible role
under `roles/` that installs dependencies and symlinks config files into `~/.config/`.
Three roles: `nvim` (modular Lua-based Neovim config using `vim.pack`), `tmux`
(config + TokyoNight Moon theme + status-bar scripts), and `fzf` (shell env file).

No Cursor rules, no Copilot instructions file — this file is the sole agent instruction surface.

## Build / Lint / Test Commands

### Running the playbook

```bash
ansible-playbook playbook.yml                  # all roles
ansible-playbook playbook.yml --tags nvim      # single role (nvim | tmux | fzf)
ansible-playbook playbook.yml --check          # dry run (no changes)
ansible-playbook playbook.yml --syntax-check   # syntax only
```

`ansible.cfg` sets `inventory = inventory/localhost.yml` (local connection, no SSH).
No extra flags are needed.

### Validation (no CI — run manually)

```bash
# YAML syntax (Ruby, available on macOS)
ruby -e "require 'yaml'; Dir.glob('**/*.yml').each { |f| YAML.safe_load(File.read(f)); puts \"OK: #{f}\" }"

# Lua syntax (luac ships with Neovim's LuaJIT)
find roles/*/files -name '*.lua' -exec luac -p {} \; -print

ansible-lint playbook.yml   # if ansible-lint is installed
yamllint .                  # if yamllint is installed
```

### Formatting

```bash
# Format Lua files (stylua, config: .stylua.toml)
stylua roles/nvim/files/nvim/

# Check Lua formatting without applying changes
stylua --check roles/nvim/files/nvim/

# Format Ansible/YAML files (yamlfmt, config: .yamlfmt.yml)
yamlfmt playbook.yml roles/*/tasks/*.yml inventory/localhost.yml

# Check YAML formatting without applying changes
yamlfmt -dry -lint playbook.yml roles/*/tasks/*.yml inventory/localhost.yml
```

### Neovim plugin management

Plugins use `vim.pack` (Neovim 0.12+ built-in — not lazy.nvim). Run inside Neovim:

```
:lua vim.pack.update()           -- update all plugins
:lua vim.pack.update({"name"})   -- update one plugin
:checkhealth vim.pack            -- diagnose issues
```

The lockfile `roles/nvim/files/nvim/nvim-pack-lock.json` is listed in `.gitignore`
and is **not** committed; it is generated locally on first install.

## Code Style — Lua (Neovim config)

### Formatting

- **2-space indentation**, no tabs
- **Double quotes** for all strings: `require("core.options")`, `{ desc = "Save file" }`
- **Trailing commas** on the last element of multi-line tables
- Max line length: soft limit ~120 characters (see `colorcolumn` in `core/options.lua`)
- Global indent default is **4 spaces** (set in `core/options.lua`); `ftplugin/` overrides
  to 2 for Lua, JS/TS, JSON, YAML, CSS, HTML via `require("core.indent").set(2)`

### File structure

- `init.lua` — entry point. Load order: `vim.loader.enable()`, then `core.options`,
  `core.keymaps`, `core.autocmds`, a `PackChanged` autocmd (runs `:TSUpdate` after
  treesitter upgrades), then Neovim auto-sources `plugin/` files alphabetically.
- `lua/core/*.lua` — execute side effects directly (options, keymaps, autocmds). No return value.
- `plugin/*.lua` — **auto-sourced by Neovim** alphabetically. Each file calls `vim.pack.add()`,
  then configures the plugin. Use numeric prefixes (`00-`, `01-`) to force load order.
- `ftplugin/<filetype>.lua` — **auto-sourced per filetype**. One file per filetype. Use for
  indent overrides and treesitter folding. C/C++ additionally set `vim.bo.cindent`.
- One file per plugin concern. One file per concern in `core/`.

### Naming, aliases, and style

- **snake_case** for all variables, functions, and augroup names
- Top of each file: alias frequently used globals — `local map = vim.keymap.set`,
  `local opt = vim.opt`, `local augroup = vim.api.nvim_create_augroup`,
  `local autocmd = vim.api.nvim_create_autocmd`
- Augroup names: short and descriptive — `"highlight_yank"`, `"lsp_keymaps"`
- Keymap `desc`: short imperative phrase — `"Toggle file explorer"`, `"Go to definition"`

### Keymaps

- All keymaps **must** include a `desc` field
- Leader key is `Space` (Neovim default; explicit `mapleader` assignment is commented out)
- Plugin keymaps go in the plugin's own `plugin/*.lua` file, not in `core/keymaps.lua`
- LSP keymaps are buffer-local, set inside the `LspAttach` autocmd in `plugin/02-lsp.lua`
- Prefix `desc` with the subsystem: `"LSP: Go to definition"`, `"DAP: Toggle breakpoint"`
- `d`, `D`, `c`, `C`, `x`, `X` are mapped to the black-hole register (`"_`) — use
  `<leader>d`/`<leader>D` for clipboard-aware deletes

### Error handling and lazy loading

- Use `pcall()` for optional requires: `local ok, mod = pcall(require, "module")`
- Use `pcall()` for API calls that may fail (e.g., setting cursor position)
- Lazy-load via autocmd (`once = true`) when needed; prefer simplicity over micro-optimisation

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

### Symlink pattern (used in all three roles)

Config files are **symlinked** so edits in the repo take effect immediately.
Three-step pattern: (1) ensure parent `~/.config` directory exists, (2) remove any
existing target to handle dir-to-symlink transitions, (3) create the symlink:

```yaml
- name: Symlink <tool> config from dotfiles repo
  ansible.builtin.file:
    src: "{{ role_path }}/files/<tool>"
    dest: "{{ ansible_env.HOME }}/.config/<tool>"
    state: link
```

- Use `role_path` for portable `src` paths — never hardcode `~` or `$HOME`
- Shell scripts (e.g., tmux status-bar scripts) require a separate task to set `mode: "0755"`

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
via `ansible.builtin.include_tasks`. To add a new role, add it to `playbook.yml` as
`- role: <tool>` with `tags: [<tool>]`.

## Repository Conventions

- `.gitignore` exists at repo root — update if introducing build artifacts or secrets
- `nvim-pack-lock.json` is gitignored; do not attempt to commit it
- The `fzf` role's `.fzfenv.sh` must be sourced from the user's shell profile to take effect
- No external linter/formatter configs; follow patterns in existing files
- Commit messages: `<type>: <concise description>` with an optional body explaining the change
