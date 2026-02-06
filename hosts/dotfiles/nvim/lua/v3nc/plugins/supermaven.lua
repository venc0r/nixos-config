return {
    "supermaven-inc/supermaven-nvim",
    enabled = function()
        local excluded_hosts = { "jma-21m70012ge", "shell01vp" ,"shell02vp" }
        local current_host = vim.fn.hostname()

        for _, host in ipairs(excluded_hosts) do
            if current_host == host then
                return false
            end
        end
        return true
    end,
    config = function()
        require("supermaven-nvim").setup({
            color = {
                suggestion_color = "#ffffff",
                cterm = 244,
            },
            log_level = "off",
            disable_inline_completion = true,
            disable_keymaps = true,
        })
    end,
}
