return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        { 'j-hui/fidget.nvim', opts = {} },
        { 'folke/neodev.nvim', opts = {} },
        'SmiteshP/nvim-navic',
    },
    config = function()
        -- Prevent LSPs that can't handle non-file URIs from attaching to
        -- fugitive/gitsigns buffers (they panic or error on these URI schemes)
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

                local navic = require('nvim-navic')
                if client.server_capabilities.documentSymbolProvider then
                    navic.attach(client, event.buf)
                end
            end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        local servers = {
            gopls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
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
                            -- https://github.com/redhat-developer/vscode-tekton/tree/main/scheme
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

        require('mason').setup()

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            'stylua', -- Used to format Lua code
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

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
}
