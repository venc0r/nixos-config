return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-context' },
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup({
            ensure_installed = { 'bash', 'dockerfile', 'go', 'gotmpl', 'html', 'java', 'javascript', 'json', 'lua',
                'make', 'markdown', 'php', 'python', 'ruby', 'sql', 'toml', 'terraform', 'typescript', 'vimdoc', 'yaml' },
            auto_install = true,
            sync_install = false,
            ignore_install = {},
            indent = { enable = true },

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            textobjects = {
                enable = true,
            },
            rainbow = {
                enable = true,
            }
        })

        local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
        parser_config.gotmpl = {
            install_info = {
                url = "https://github.com/ngalaiko/tree-sitter-go-template",
                files = { "src/parser.c" }
            },
            filetype = "helm",
            used_by = { "helm", "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" }
        }
        vim.treesitter.language.register("gotmpl", "helm")

        require("treesitter-context").setup({
            enable = true,
            throttle = true,
            max_lines = 0,
            show_all_context = true,
            patterns = {
                default = {
                    "function",
                    "method",
                    "for",
                    "while",
                    "if",
                    "switch",
                    "case",
                },
                yaml = {
                    "block",
                },
            },
        })
    end
}
