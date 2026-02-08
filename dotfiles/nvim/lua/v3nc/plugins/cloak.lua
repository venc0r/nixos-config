return {
    "laytan/cloak.nvim",
    config = function()
        require("cloak").setup({
            enabled = false,
            cloak_character = '*',
            highlight_group = 'Comment',
            cloak_length = nil,
            try_all_patterns = true,
            cloak_telescope = true,
            patterns = {
                {
                    file_pattern = 'credentials',
                    cloak_pattern = '(.+ *= *).+',
                    replace = '%1',
                },
                {
                    file_pattern = '.env*',
                    cloak_pattern = ':.+',
                    replace = nil,
                },
                {
                    file_pattern = '*.y*ml',
                    cloak_pattern = ':.+',
                    replace = nil,
                },
                {
                    file_pattern = 'terraform.tfvars',
                    cloak_pattern = '(.+ += ).+',
                    replace = '%1',
                },
            },
        })
    end
}
