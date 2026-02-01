local servers = {
    gopls = {},
    lua_ls = {
        settings = {
            Lua = {
                completion = {
                    callSnippet = 'Replace',
                },
                diagnostics = { disable = { 'missing-fields' } },
            },
        },
    },
    helm_ls = {},
    ansiblels = {
        filetypes = { "yaml.ansible" },
    },
    terraformls = {},
    yamlls = {
        settings = {
            redhat = {
                telemetry = {
                    enabled = false,
                }
            },
            yaml = {
                keyOrdering = false,
                schemas = {
                    ["https://raw.githubusercontent.com/helm-unittest/helm-unittest/main/schema/helm-testsuite.json"] = {
                        "*_test.yaml" },
                    ["https://raw.githubusercontent.com/redhat-developer/vscode-tekton/main/scheme/tekton.dev/v1_Pipeline.json"] = {
                        "tekton/pipelines/templates/pipelines/*.yaml" },
                    ["https://raw.githubusercontent.com/redhat-developer/vscode-tekton/main/scheme/tekton.dev/v1_Task.json"] = {
                        "tekton/pipelines/templates/tekton_tasks/*.yaml" },
                    ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
                        "azure-pipeline*.y*ml", "pipeline*.y*ml", "*/.azdo/*" },
                    ["kubernetes"] = {
                        "kubectl-edit*.yaml" }
                }
            }
        },
    }
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, { 'stylua' })

return {
    {
        'williamboman/mason.nvim',
        cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall', 'MasonLog' },
        opts = {},
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        event = 'VeryLazy',
        dependencies = { 'williamboman/mason.nvim' },
        opts = {
            ensure_installed = ensure_installed,
            auto_update = false,
            run_on_start = false,
        },
    },
    {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        { 'j-hui/fidget.nvim', opts = {} },
        { 'folke/neodev.nvim', opts = {} },
        'SmiteshP/nvim-navic',
    },
    config = function()
        local codelens_ns = vim.api.nvim_create_namespace('custom_codelens')
        local default_codelens_ns_new = vim.api.nvim_create_namespace('nvim.lsp.codelens')
        local default_codelens_ns_old = vim.api.nvim_create_namespace('vim_lsp_codelens')
        local codelens_timers = {}
        local codelens_delay_ms = 3000
        local uv = vim.uv or vim.loop

        local function clear_custom_codelens(bufnr)
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_clear_namespace(bufnr, codelens_ns, 0, -1)
                vim.api.nvim_buf_clear_namespace(bufnr, default_codelens_ns_new, 0, -1)
                vim.api.nvim_buf_clear_namespace(bufnr, default_codelens_ns_old, 0, -1)
                pcall(vim.lsp.codelens.enable, false, { bufnr = bufnr })
            end
        end

        local function stop_codelens_timer(bufnr)
            local t = codelens_timers[bufnr]
            if t then
                t:stop()
                if not t:is_closing() then t:close() end
                codelens_timers[bufnr] = nil
            end
        end

        local function render_current_codelens(bufnr)
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            if vim.api.nvim_get_current_buf() ~= bufnr then return end
            local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
            local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
            vim.lsp.buf_request(bufnr, 'textDocument/codeLens', params, function(err, result, ctx)
                if err or not result then return end
                if not vim.api.nvim_buf_is_valid(bufnr) then return end
                if vim.api.nvim_get_current_buf() ~= bufnr then return end
                if vim.api.nvim_win_get_cursor(0)[1] - 1 ~= cursor_line then return end
                clear_custom_codelens(bufnr)
                local function place(lens)
                    if not (lens.command and lens.command.title) then return end
                    vim.api.nvim_buf_set_extmark(bufnr, codelens_ns, lens.range.start.line, 0, {
                        virt_lines_above = true,
                        virt_lines = { { { lens.command.title, 'LspCodeLens' } } },
                    })
                end
                local best, best_span
                for _, lens in ipairs(result) do
                    local s, e = lens.range.start.line, lens.range['end'].line
                    if cursor_line >= s and cursor_line <= e then
                        local span = e - s
                        if not best or span < best_span then
                            best, best_span = lens, span
                        end
                    end
                end
                if not best then return end
                if best.command and best.command.title then
                    place(best)
                else
                    local client = vim.lsp.get_client_by_id(ctx.client_id)
                    if client then
                        client:request('codeLens/resolve', best, function(rerr, resolved)
                            if not rerr and resolved and vim.api.nvim_buf_is_valid(bufnr) then
                                if vim.api.nvim_get_current_buf() == bufnr
                                    and vim.api.nvim_win_get_cursor(0)[1] - 1 == cursor_line then
                                    place(resolved)
                                end
                            end
                        end, bufnr)
                    end
                end
            end)
        end

        local function schedule_codelens(bufnr)
            stop_codelens_timer(bufnr)
            local timer = uv.new_timer()
            codelens_timers[bufnr] = timer
            timer:start(codelens_delay_ms, 0, vim.schedule_wrap(function()
                stop_codelens_timer(bufnr)
                render_current_codelens(bufnr)
            end))
        end

        local original_buf_attach = vim.lsp.buf_attach_client
        vim.lsp.buf_attach_client = function(bufnr, client_id)
            local client = vim.lsp.get_client_by_id(client_id)
            if client and vim.tbl_contains({ 'terraformls', 'helm_ls' }, client.name) then
                local bufname = vim.api.nvim_buf_get_name(bufnr)
                if bufname:match('^fugitive://') or bufname:match('^gitsigns://') then
                    return false
                end
            end
            return original_buf_attach(bufnr, client_id)
        end

        vim.api.nvim_create_autocmd('LspAttach', {

            group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
            callback = function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                local bufname = vim.api.nvim_buf_get_name(event.buf)

                if client and bufname:match('^%w+://') and not bufname:match('^file://') then
                    local problematic_lsps = { 'terraformls' }
                    if vim.tbl_contains(problematic_lsps, client.name) then
                        vim.lsp.buf_detach_client(event.buf, client.id)
                        return
                    end
                end

                local opts = { buffer = event.buf }
                vim.keymap.set('n', 'gd', require('telescope.builtin').lsp_definitions, opts)
                vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, opts)
                vim.keymap.set('n', 'gI', require('telescope.builtin').lsp_implementations, opts)
                vim.keymap.set('n', '<leader>D', require('telescope.builtin').lsp_type_definitions, opts)
                vim.keymap.set('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, opts)
                vim.keymap.set('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, opts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
                -- if vim.bo[event.buf].buftype ~= "" or vim.bo[event.buf].filetype == "helm" then
                --     vim.lsp.stop_client(vim.lsp.get_clients({ name = "yamlls" }))
                -- end

                if client and client.server_capabilities.codeLensProvider and not vim.b[event.buf].custom_codelens then
                    vim.b[event.buf].custom_codelens = true
                    local grp = vim.api.nvim_create_augroup('custom-codelens-' .. event.buf, { clear = true })
                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufEnter', 'InsertLeave' }, {
                        group = grp,
                        buffer = event.buf,
                        callback = function()
                            clear_custom_codelens(event.buf)
                            schedule_codelens(event.buf)
                        end,
                    })
                    vim.api.nvim_create_autocmd({ 'BufLeave', 'BufUnload' }, {
                        group = grp,
                        buffer = event.buf,
                        callback = function()
                            stop_codelens_timer(event.buf)
                            clear_custom_codelens(event.buf)
                        end,
                    })
                    schedule_codelens(event.buf)
                    for _, delay in ipairs({ 50, 250, 750, 1500 }) do
                        vim.defer_fn(function() clear_custom_codelens(event.buf) end, delay)
                    end
                end

                local navic = require('nvim-navic')
                if client.server_capabilities.documentSymbolProvider then
                    navic.attach(client, event.buf)
                end
            end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        require('mason-lspconfig').setup {
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off formatting for tsserver)
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        }

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end,
    },
}
