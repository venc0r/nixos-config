return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-context' },
    build = ':TSUpdate',
    config = function()
        -- Install parsers
        local parsers = { 'bash', 'dockerfile', 'go', 'gotmpl', 'html', 'java', 'javascript', 'json', 'lua',
            'make', 'markdown', 'php', 'python', 'ruby', 'sql', 'toml', 'terraform', 'typescript', 'vimdoc', 'yaml' }
        
        require('nvim-treesitter').install(parsers)

        -- Custom parser for Go templates
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

        -- Treesitter context
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
