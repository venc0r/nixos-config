function SetColors()
    vim.opt.background = "dark"

    vim.cmd("colorscheme gruvbox")
    local hl = function(thing, opts)
        vim.api.nvim_set_hl(0, thing, opts)
    end
    hl("Normal", { bg = "none" })
    hl("ZenFloat", { bg = "none" })
    hl("SignColumn", { bg = "none" })
    hl("ColorColumn", { bg = "#504945", })
end

function SetLightColors()
    vim.opt.background = "light"

    vim.cmd("colorscheme gruvbox")
    local hl = function(thing, opts)
        vim.api.nvim_set_hl(0, thing, opts)
    end
    hl("Normal", { bg = "none" })
    hl("ZenFloat", { bg = "none" })
    hl("SignColumn", { bg = "none" })
end

return {
    "ellisonleao/gruvbox.nvim",
    config = function()
        require("gruvbox").setup({
            terminal_colors = false, -- add neovim terminal colors
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = true,
                emphasis = true,
                comments = true,
                operators = false,
                folds = true,
            },
            strikethrough = true,
            invert_selection = true,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = true,    -- invert background for search, diffs, statuslines and errors
            contrast = "hard", -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        })

        SetColors()
        -- SetLightColors()
    end
}
