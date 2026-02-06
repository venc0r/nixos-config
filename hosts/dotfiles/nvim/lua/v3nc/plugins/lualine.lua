return {
    'nvim-lualine/lualine.nvim',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        'SmiteshP/nvim-navic',
        'nvim-tree/nvim-tree.lua',
        'tpope/vim-fugitive',
    },
    opts = {
        options = {
            theme = 'gruvbox',
        },
        sections = {
            lualine_c = {
                { 'filename', path = 2 },
                {
                    function()
                        return require("nvim-navic").get_location()
                    end,
                    cond = function()
                        return require("nvim-navic").is_available()
                    end
                },
            },
        },
        extensions = { 'nvim-tree', 'fugitive' }
    },
}
