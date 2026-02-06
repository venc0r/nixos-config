return
{ -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
                return vim.fn.executable 'make' == 1
            end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },
        { 'debugloop/telescope-undo' },
        { 'nvim-tree/nvim-web-devicons' },
        -- { 'venc0r/telescope-k8s.nvim', opts = {}}
    },
    config = function()
        require('telescope').setup {
            extensions = {
                ['ui-select'] = {
                    require('telescope.themes').get_dropdown(),
                },
            },
        }

        -- Enable Telescope extensions if they are installed
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')
        pcall(require('telescope').load_extension, 'git_worktree')
        pcall(require('telescope').load_extension, 'harpoon')
        -- pcall(require('telescope').load_extension, 'telescope_k8s')
        pcall(require('telescope').load_extension, 'undo')

        -- See `:help telescope.builtin`
        local builtin = require('telescope.builtin')

        vim.keymap.set('n', '<leader>tg', ':Telescope git_worktree <C-n>')
        vim.keymap.set('n', '<leader>hm', '<CMD>Telescope harpoon marks<CR>')
        vim.keymap.set('n', '<leader>/', '<CMD>Telescope current_buffer_fuzzy_find<CR>')
        -- vim.keymap.set('n', '<leader>k', '<CMD>Telescope telescope_k8s show_pods<CR>')

        vim.keymap.set('n', '<leader>ts', builtin.find_files)
        vim.keymap.set('n', '<leader>tt', builtin.git_files)
        vim.keymap.set('n', '<leader>tn', builtin.live_grep)
        vim.keymap.set('n', '<leader>te', builtin.grep_string)

        vim.keymap.set('n', '<leader>s.', builtin.oldfiles)
        vim.keymap.set('n', '<leader>ss', builtin.builtin)

        vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                -- winblend = 10,
                previewer = true,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })

        vim.keymap.set('n', '<leader>vrc', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end)
    end,
}
