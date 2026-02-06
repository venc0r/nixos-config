return {
    "folke/zen-mode.nvim",
    config = function()
        require("zen-mode").setup {
            window = {
                backdrop = 0.95,
            },
            plugins = {
                alacritty = {
                    enabled = true,
                    font = "18", -- font size
                },
            },
            on_open = function()
                local hl = function(thing, opts)
                    vim.api.nvim_set_hl(0, thing, opts)
                end

                hl("NormalFloat", {
                    bg = "none"
                })
            end,
            on_close = function()
                local hl = function(thing, opts)
                    vim.api.nvim_set_hl(0, thing, opts)
                end

                hl("NormalFloat", {
                    bg = "#504945"
                })
            end
        }
    end
}
