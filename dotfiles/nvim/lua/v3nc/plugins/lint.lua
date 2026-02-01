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
            terraform = { "checkov" },
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

        lint.linters.shellcheck_j2 = {
            name = 'shellcheck_j2',
            cmd = 'bash',
            stdin = false,
            args = { '-c', 'j2 --undefined "$1" 2>/dev/null | shellcheck -s bash --format json -', '_' },
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

        lint.linters.checkov = {
            name = 'checkov',
            cmd = 'checkov',
            stdin = false,
            args = { '--quiet', '--soft-fail', '-o', 'json', '-f' },
            ignore_exitcode = true,
            stream = 'stdout',
            parser = function(output, bufnr)
                local diagnostics = {}
                local ok, decoded = pcall(vim.json.decode, output)
                if not ok or not decoded then return diagnostics end
                for _, check in ipairs((decoded.results or {}).failed_checks or {}) do
                    local lnum = (check.file_line_range and check.file_line_range[1] or 1) - 1
                    local end_lnum = (check.file_line_range and check.file_line_range[2] or lnum + 1) - 1
                    table.insert(diagnostics, {
                        source = 'checkov',
                        lnum = lnum,
                        end_lnum = end_lnum,
                        col = 0,
                        end_col = 0,
                        severity = vim.diagnostic.severity.WARN,
                        code = check.check_id,
                        message = string.format('[%s] %s (%s)', check.check_id, check.check and check.check.name or '', check.resource or ''),
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
                if vim.fn.expand('%:t'):match('%.sh%.j2$') then
                    require('lint').try_lint('shellcheck_j2')
                else
                    require('lint').try_lint()
                end
            end,
        })
    end,
}
