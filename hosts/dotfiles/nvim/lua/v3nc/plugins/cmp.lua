return {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp-signature-help',

        -- snippets
        {
            'L3MON4D3/LuaSnip',
            build = (function()
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
            dependencies = {
                {
                    'rafamadriz/friendly-snippets',
                    config = function()
                        require('luasnip.loaders.from_vscode').lazy_load()
                    end,
                },
            },
        },
        'saadparwaiz1/cmp_luasnip',
        --
        -- Addons
        'ray-x/lsp_signature.nvim',
        'kkharji/lspsaga.nvim',
        'onsails/lspkind-nvim',
    },
    config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local lspkind = require('lspkind')
        luasnip.config.setup({})
        lspkind.init({
            symbol_map = {
                Supermaven = "",
            },
        })

        cmp.setup {
            preselect = 'None',
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            completion = {
                completeopt = 'menu,menuone,noinsert,noselect'
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                ['<C-n>'] = cmp.mapping.select_next_item(),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-u>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-y>'] = cmp.mapping.confirm { select = true },
                ['<C-l>'] = cmp.mapping(function()
                    if luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    end
                end, { 'i', 's' }),
                ['<C-h>'] = cmp.mapping(function()
                    if luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    end
                end, { 'i', 's' }),
                ['<Tab>'] = vim.NIL,
                ['<S-Tab>'] = vim.NIL,
            }),
            sources = {
                { name = 'path',                    priority = 7, max_item_count = 10 },
                { name = 'nvim_lsp',                priority = 6, max_item_count = 20 },
                { name = 'supermaven',              priority = 5, max_item_count = 10 },
                { name = 'nvim_lua',                priority = 4, max_item_count = 10 },
                { name = 'luasnip',                 priority = 3, max_item_count = 10 },
                { name = 'buffer',                  priority = 2, max_item_count = 10 },
                { name = 'nvim_lsp_signature_help', priority = 1, max_item_count = 10 },
            },
            formatting = {
                expandable_indicator = true,
                fields = { "abbr", "kind", "menu" },
                format = lspkind.cmp_format {
                    with_text = true,
                    menu = {
                        nvim_lsp = "[LSP]",
                        supermaven = "[AI]",
                        path = "[path]",
                        buffer = "[buf]",
                        luasnip = "[lua_snip]",
                        nvim_lua = "[lua]",
                        nvim_lsp_signature_help = "[sig]",
                        ['vim-dadbod-completion'] = "[DB]",
                    },
                },
            },
        }
        cmp.setup.filetype({ "sql" }, {
            sources = {
                { name = "vim-dadbod-completion", priority = 30, max_item_count = 10 },
                { name = "buffer",                priority = 20, max_item_count = 10 },
            },
            formatting = {
                expandable_indicator = true,
                fields = { "abbr", "kind", "menu" },
                format = lspkind.cmp_format {
                    with_text = true,
                    menu = {
                        buffer = "[buf]",
                        ['vim-dadbod-completion'] = "[DB]",
                    },
                },
            },
        })
    end,
}
