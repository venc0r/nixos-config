return {
    'neovim-treesitter/nvim-treesitter',
    dependencies = { 'neovim-treesitter/treesitter-parser-registry', 'nvim-treesitter/nvim-treesitter-context' },
    lazy = false,
    build = ':TSUpdate',
    config = function()
        local ts = require('nvim-treesitter')

        ts.install(ts.get_available())

        vim.api.nvim_create_autocmd('FileType', {
            pattern = '*',
            callback = function()
                pcall(vim.treesitter.start)
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })

        vim.treesitter.language.register("gotmpl", "helm")

        require("treesitter-context").setup({
            enable = true,
            max_lines = 0,
            mode = 'cursor',
            multiline_threshold = 20,
            trim_scope = 'outer',
        })
    end
}
