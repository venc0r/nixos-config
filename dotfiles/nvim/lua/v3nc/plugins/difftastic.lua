return {
    'clabby/difftastic.nvim',
    dependencies = {
        'MunifTanjim/nui.nvim',
        'folke/snacks.nvim',
    },
    config = function()
        require('difftastic-nvim').setup({
            download = false,
            snacks_picker = { enabled = true },
        })
    end,
}
