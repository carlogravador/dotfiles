# AGENTS.md

Instructions for AI coding agents operating in this repository.

## Project Overview

Ansible-managed dotfiles repository. Each tool is a self-contained Ansible role
under `roles/` that installs dependencies and symlinks configuration files.
Currently contains a single role (`nvim`) with a modular Lua-based Neovim config.

## Build / Lint / Test Commands

### Running the playbook

```bash
# Full run (all roles)
ansible-playbook playbook.yml

# Single role by tag
ansible-playbook playbook.yml --tags nvim

# Dry run (check mode — no changes made)
ansible-playbook playbook.yml --check

# Syntax check only
ansible-playbook playbook.yml --syntax-check
```

### Validation (no CI configured — run manually)

```bash
# YAML syntax validation (Ruby available on macOS)
ruby -e "require 'yaml'; Dir.glob('**/*.yml').each { |f| YAML.safe_load(File.read(f)); puts \"OK: #{f}\" }"

# Lua syntax validation (requires luac, ships with Neovim's LuaJIT)
find roles/*/files -name '*.lua' -exec luac -p {} \; -print

# Ansible lint (if installed)
ansible-lint playbook.yml

# YAML lint (if installed)
yamllint .
```

### Neovim plugin management

Plugins are managed by lazy.nvim inside Neovim, not from the shell:

```
:Lazy update     — Update all plugins
:Lazy sync       — Install missing + update + clean removed
:Mason           — Manage LSP servers, DAP adapters, linters, formatters
```

The `lazy-lock.json` lockfile is committed for reproducible installs.

## Code Style — Lua (Neovim config)

### Formatting

- **2-space indentation**, no tabs
- **Double quotes** for all strings: `require("core.options")`, `{ desc = "Save file" }`
- **Trailing commas** on the last element of multi-line tables
- Max line length: soft limit ~100 characters (see `colorcolumn` in options.lua)

### File structure

- `core/*.lua` files execute side effects directly (set options, create keymaps). No return value.
- `plugins/*.lua` files (except `init.lua`) **return a plugin spec table**: `return { ... }`
- `plugins/init.lua` bootstraps lazy.nvim and imports other plugin files via `{ import = "plugins.X" }`
- One file per plugin. One file per concern in `core/`.

### Requires and aliases

```lua
-- Top of config functions: alias frequently used modules
local cmp = require("cmp")
local map = vim.keymap.set
local opt = vim.opt
local augroup = vim.api.nvim_create_augroup
```

### Naming

- **snake_case** for all variables, functions, and augroup names
- Augroup names: short, descriptive: `"highlight_yank"`, `"lsp_keymaps"`
- Keymap desc values: short imperative phrases: `"Toggle file explorer"`, `"Go to definition"`

### Keymaps

- All keymaps **must** include a `desc` field
- Leader key is `Space`
- Plugin keymaps go in the plugin's own config function, not in `core/keymaps.lua`
- LSP keymaps are buffer-local, set in the `LspAttach` autocmd
- Prefix `desc` with the plugin/system name for scoped keymaps: `"LSP: Go to definition"`, `"DAP: Toggle breakpoint"`

### Error handling

- Use `pcall()` for optional requires: `local ok, mod = pcall(require, "module")`
- Use `pcall()` for API calls that may fail (e.g., setting cursor position)
- Use `ignore_errors: true` sparingly in Ansible, with a comment explaining why

### Comments

- **File header**: `-- <path> — <description>` (em dash), followed by explanatory block
- **Section dividers**: `-- ── Section Name ───────────────────────────`
- **Inline comments**: explain the *why*, not the *what*
- This is a teaching-oriented repo — comments should explain Neovim/Ansible concepts

### Lazy-loading

Use appropriate events to defer plugin loading:

```lua
event = "InsertEnter"                    -- Completion, snippets
event = { "BufReadPre", "BufNewFile" }   -- Treesitter, syntax-related
event = "VeryLazy"                       -- UI plugins (statusline)
```

## Code Style — YAML (Ansible)

### Formatting

- **2-space indentation**
- Start task files with `---` (YAML document marker)
- **Double quotes** for Jinja2 expressions: `"{{ ansible_env.HOME }}"`
- **Unquoted** for plain values: `state: present`, `become: true`
- **Double quotes** for octal modes: `mode: "0755"`

### Module naming

- **Always use Fully Qualified Collection Names (FQCN)**:
  - `ansible.builtin.file`, `ansible.builtin.apt`, `community.general.homebrew`
  - Never use short names like `file`, `apt`, `copy`

### Task naming

- Every task **must** have a `name:` field
- Sentence case, imperative: `"Install Neovim and dependencies via Homebrew (macOS)"`
- Include platform qualifier in parentheses for OS-specific tasks: `(macOS)`, `(Ubuntu/Debian)`

### Conditionals and loops

- `when:` for OS-specific tasks: `when: ansible_os_family == "Darwin"` / `"Debian"`
- `loop:` (modern syntax) instead of `with_items`
- Add inline comments on non-obvious loop items

### Role structure

When adding a new role:

```
roles/<tool>/
├── tasks/
│   ├── main.yml      # Entry point, includes install.yml + config.yml
│   ├── install.yml   # Package installation (OS-conditional)
│   └── config.yml    # Symlink/deploy config files
└── files/            # Config files to be symlinked
```

- Config files are **symlinked** to their target (not copied), so edits in the
  repo take effect immediately without re-running the playbook.
- Use `role_path` for portable paths: `"{{ role_path }}/files/..."`
- Always ensure parent directories exist before creating symlinks.
- Remove existing targets before symlinking to handle dir-to-symlink transitions.

### Adding a role to the playbook

```yaml
# In playbook.yml
roles:
  - role: <tool>
    tags: [<tool>]
```

## Repository Conventions

- No external linter/formatter configs exist yet. Follow the patterns in existing files.
- `lazy-lock.json` is version-controlled for reproducibility.
- No `.gitignore` exists — add one if introducing build artifacts or secrets.
- Commit messages: `<type>: <concise description>` with an optional body explaining the change.
