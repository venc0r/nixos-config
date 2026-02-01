local autocmd = vim.api.nvim_create_autocmd

vim.filetype.add({
    extension = {
        inc = function(_, bufnr)
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            local start = math.max(0, line_count - 5)
            local lines = vim.api.nvim_buf_get_lines(bufnr, start, line_count, false)
            for _, line in ipairs(lines) do
                local ft = line:match('[vV]im%s*:%s*.*%sft=(%w+)')
                    or line:match('[vV]im%s*:%s*.*%sfiletype=(%w+)')
                    or line:match('[vV]im%s*:%s*set%s+ft=(%w+)')
                    or line:match('[vV]im%s*:%s*set%s+filetype=(%w+)')
                if ft then return ft end
            end
        end,
    },
})

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
