return {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
        local lint = require('lint')
        lint.linters_by_ft = {
            sh = { 'shellcheck' },
            yaml = { 'yamllint' },
            ansible = { 'ansible_lint' },
            python = { 'pylint' },
            dockerfile = { "hadolint" },
            json = { "jsonlint" },
        }

        lint.linters.shellcheck = {
            name = 'shellcheck',
            cmd = 'shellcheck',
            stdin = false,
            args = {
                '-o', 'all', '-x',
                '--format', 'json',
            },
            ignore_exitcode = true,
            parser = function(output)
                local decoded = vim.fn.json_decode(output)
                local diagnostics = {}
                local severities = {
                    error = vim.lsp.protocol.DiagnosticSeverity.Error,
                    warning = vim.lsp.protocol.DiagnosticSeverity.Warning,
                    info = vim.lsp.protocol.DiagnosticSeverity.Information,
                    style = vim.lsp.protocol.DiagnosticSeverity.Hint,
                }
                for _, item in ipairs(decoded or {}) do
                    table.insert(diagnostics, {
                        lnum = item.line - 1,
                        col = item.column - 1,
                        end_lnum = item.endLine - 1,
                        end_col = item.endColumn - 1,
                        code = item.code,
                        severity = assert(severities[item.level], 'missing mapping for severity ' .. item.level),
                        message = "SC[[" .. item.code .. "]] " .. item.message,
                    })
                end
                return diagnostics
            end,
        }

        lint.linters.yamllint = {
            name = "yamllint",
            cmd = 'yamllint',
            stdin = false,
            args = {
                '--strict',
                '--format', 'parsable',
                '-c', os.getenv("HOME") .. '/.config/yamllint/config',
            },
            ignore_exitcode = true,
            parser = require('lint.parser').from_pattern(
                '([^:]+):(%d+):(%d+): %[(.+)%] (.+) %((.+)%)',
                { 'file', 'lnum', 'col', 'severity', 'message', 'code' },
                {
                    ['error'] = vim.diagnostic.severity.ERROR,
                    ['warning'] = vim.diagnostic.severity.WARN,
                },
                {
                    ['source'] = 'yamllint',
                }),
        }

        local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = lint_augroup,
            callback = function()
                require('lint').try_lint()
            end,
        })
    end,
}
