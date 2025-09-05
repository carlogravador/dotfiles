-- Initialize a flag to toggle LSPs on or off
local lsp_enabled = true
-- Store buffers attached to each LSP client
local attached_buffers_by_client = {}
-- Store configurations for each LSP client
local client_configs = {}

-- Store a reference to the original buf_attach_client function
local original_buf_attach_client = vim.lsp.buf_attach_client

-- Function to add a buffer to the client's buffer table
local function add_buf(client_id, buf)
    if not attached_buffers_by_client[client_id] then
        attached_buffers_by_client[client_id] = {}
    end

    -- Check if the buffer is already in the list
    local exists = false
    for _, value in ipairs(attached_buffers_by_client[client_id]) do
        if value == buf then
            exists = true
            break
        end
    end

    -- Add the buffer if it doesn’t already exist in the client’s list
    if not exists then
        table.insert(attached_buffers_by_client[client_id], buf)
    end
end

-- Middleware function to control LSP client attachment to buffers
-- Prevents LSP client from reattaching if LSPs are disabled
vim.lsp.buf_attach_client = function(bufnr, client_id)
    if not lsp_enabled then
        -- Cache client configuration if not already stored
        if not client_configs[client_id] then
            local client_config = vim.lsp.get_client_by_id(client_id)
            client_configs[client_id] = (client_config and client_config.config) or {}
        end

        -- Add buffer to client’s attached buffer list and stop the client
        add_buf(client_id, bufnr)
        vim.lsp.stop_client(client_id)

        return false                                    -- Indicate the client should not attach
    end
    return original_buf_attach_client(bufnr, client_id) -- Use the original attachment method if enabled LSP
end

-- Update state with new client IDs after a toggle
local function update_clients_ids(ids_map)
    local new_attached_buffers_by_client = {}
    local new_client_configs = {}

    -- Map each client ID to its new ID and carry over configurations
    for client_id, buffers in pairs(attached_buffers_by_client) do
        local new_id = ids_map[client_id]
        new_attached_buffers_by_client[new_id] = buffers
        new_client_configs[new_id] = client_configs[client_id]
    end

    attached_buffers_by_client = new_attached_buffers_by_client -- Update global attached buffer table
    client_configs = new_client_configs                         -- Update global client config table
end

-- Stops the client, waiting up to 5 seconds; force quits if needed
local function client_stop(client)
    vim.lsp.stop_client(client.id, false)

    local timer = vim.uv.new_timer() -- Create a timer
    local max_attempts = 50          -- Set max attempts to check if stopped
    local attempts = 0               -- Track the number of attempts

    timer:start(100, 100, vim.schedule_wrap(function()
        attempts = attempts + 1

        if client.is_stopped() then -- Check if the client is stopped
            timer:stop()
            timer:close()
            vim.diagnostic.reset()               -- Reset diagnostics for the client
        elseif attempts >= max_attempts then     -- If max attempts reached
            vim.lsp.stop_client(client.id, true) -- Force stop the client
            timer:stop()
            timer:close()
            vim.diagnostic.reset() -- Reset diagnostics for the client
        end
    end))
end

-- Toggle LSPs on or off, managing client states and attached buffers
local function toggle_lsp()
    if lsp_enabled then                 -- If LSP is currently enabled, disable it
        client_configs = {}             -- Clear client configurations
        attached_buffers_by_client = {} -- Clear attached buffers

        -- Loop through all active LSP clients
        for _, client in ipairs(vim.lsp.get_clients()) do
            client_configs[client.id] = client.config -- Cache client config

            -- Loop through all buffers attached to the client
            for buf, _ in pairs(client.attached_buffers) do
                add_buf(client.id, buf)                   -- Add buffer to the client’s buffer table
                vim.lsp.buf_detach_client(buf, client.id) -- Detach the client from the buffer
            end

            client_stop(client) -- Stop the client
        end

        print("LSPs Disabled")
    else -- If LSP is currently disabled, enable it
        local new_ids = {}

        -- Reinitialize clients with previous configurations
        for client_id, buffers in pairs(attached_buffers_by_client) do
            local client_config = client_configs[client_id]                -- Retrieve client config
            local new_client_id, err = vim.lsp.start_client(client_config) -- Start client with config

            new_ids[client_id] = new_client_id                             -- Map old client ID to new client ID

            if err then                                                    -- Notify if there was an error starting the client
                vim.notify(err, vim.log.levels.WARN)
                return nil
            end

            -- Reattach buffers to the newly started client
            for _, buf in ipairs(buffers) do
                original_buf_attach_client(buf, new_client_id)
            end
        end

        update_clients_ids(new_ids) -- Update client IDs
        print("LSPs Enabled")       -- Notify that LSPs are enabled
    end

    lsp_enabled = not lsp_enabled -- Toggle the LSP enabled flag
end

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- Also add border on diagnostic float window
        vim.diagnostic.config({
            float = {
                border = 'rounded'
            }
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)

                vim.lsp.handlers["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'})
                vim.lsp.handlers["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'})
                vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                                vim.lsp.diagnostic.on_publish_diagnostics, {
                                    -- Enable underline, use default values
                                    underline = true,
                                    -- disable virtual text
                                    virtual_text = false,
                                    -- Use a function to dynamically turn signs off
                                    -- and on, using buffer local variables
                                    -- signs = function(bufnr, client_id)
                                    --   return vim.bo[bufnr].show_signs == false
                                    -- end,
                                    signs = true,
                                    -- Disable a feature
                                    update_in_insert = false
                                })
                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local opts = { buffer = ev.buf, silent = true }

                -- set keybinds
                opts.desc = "Show LSP references"
                vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

                opts.desc = "Go to declaration"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

                opts.desc = "Show LSP definitions"
                vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

                opts.desc = "Show LSP implementations"
                vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

                -- opts.desc = "Show LSP type definitions"
                vim.keymap.set("n", "st", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

                opts.desc = "Show line diagnostics"
                vim.keymap.set('n', '<leader>sd', vim.diagnostic.open_float, opts)

                opts.desc = "Show buffer diagnostics"
                vim.keymap.set("n", "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file


                opts.desc = "See available code actions"
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

                opts.desc = "Smart rename"
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

                opts.desc = "Go to previous diagnostic"
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

                opts.desc = "Go to next diagnostic"
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

                opts.desc = "Show documentation for what is under cursor"
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

                opts.desc = "Diagnostics in loclist"
                vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

                opts.desc = "Restart LSP"
                vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

                -- Set key mapping to toggle LSP on or off with <leader>tl
                vim.keymap.set("n", "<leader>tl", toggle_lsp)
            end,
        })

        -- used to enable autocompletion (assign to every lsp server config)
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        -- (not in youtube nvim video)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        ---------------------------- START if not using mason ----------------------------
        -- setup LSP here
        -- Listed LSP should be installed in the system manually
        -- local servers = {
        --     'bashls',
        --     'clangd',
        --     'cmake',
        --     'cssls',
        --     'cssmodules_ls',
        --     'dockerls',
        --     'eslint',
        --     'html',
        --     'jsonls',
        --     'pyright',
        --     'sqlls',
        --     'yamlls'
        -- }

        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        -- for _, lsp in ipairs(servers) do
        --     require('lspconfig')[lsp].setup({
        --         on_attach = on_attach,
        --         flags = lsp_flags
        --     })
        -- end
        ---------------------------- END if not using mason ----------------------------


        -- import mason_lspconfig plugin
        -- local mason_lspconfig = require("mason-lspconfig")
        --
        -- mason_lspconfig.setup_handlers({
        --     -- default handler for installed servers
        --     function(server_name)
        --         lspconfig[server_name].setup({})
        --         -- lspconfig[server_name].setup({
        --         --     capabilities = capabilities,
        --         -- })
        --     end,
        --     ["lua_ls"] = function()
        --         -- configure lua server (with special settings)
        --         lspconfig["lua_ls"].setup({
        --             -- capabilities = capabilities,
        --             settings = {
        --                 Lua = {
        --                     -- make the language server recognize "vim" global
        --                     diagnostics = {
        --                         globals = { "vim" },
        --                     },
        --                     completion = {
        --                         callSnippet = "Replace",
        --                     },
        --                 },
        --             },
        --         })
        -- end,
        -- })
    end,
}
