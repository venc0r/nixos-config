return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-context' },
    build = ':TSUpdate',
    config = function()
        -- Install parsers
        local parsers = { 'bash', 'dockerfile', 'go', 'gotmpl', 'html', 'java', 'javascript', 'json', 'lua',
            'make', 'markdown', 'php', 'python', 'ruby', 'sql', 'toml', 'terraform', 'typescript', 'vimdoc', 'yaml' }
        
        require('nvim-treesitter').install(parsers)

        -- Register gotmpl for helm files (gotmpl parser is now built-in)
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
