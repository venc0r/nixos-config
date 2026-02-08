local autocmd = vim.api.nvim_create_autocmd

autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*/templates/*.yaml,*/templates/*.tpl,*.gotmpl,helmfile*.yaml",
    callback = function()
        vim.bo.filetype = "helm"
        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.shiftwidth = 2
    end,
})

autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.star",
    callback = function()
        vim.bo.filetype = "python"
    end,
})

autocmd({ 'BufRead', 'BufNew' }, {
    pattern = 'Jenkinsfile*',
    callback = function()
        vim.bo.filetype = "groovy"
    end,
})

autocmd({ 'BufRead', 'BufNew' }, {
    pattern = '*.tfvars',
    callback = function()
        vim.bo.filetype = "terraform"
    end,
})

autocmd({ 'BufRead', 'BufNew' }, {
    pattern = 'Dockerfile*',
    callback = function()
        vim.bo.filetype = "dockerfile"
    end,
})
