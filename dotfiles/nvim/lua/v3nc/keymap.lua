vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- folding?
vim.keymap.set("v", "<leader>fc", ":fold<CR>")
vim.keymap.set("v", "<leader>fo", ":foldopen<CR>")

-- aaaarrrrggggl
vim.keymap.set("n", "Q", "<nop>")

-- Y copy end to line
vim.keymap.set("n", "Y", "y$")

-- stay centered when searching
vim.keymap.set("n", "*", "*zzzv")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-D>", "<C-D>zzzv")
vim.keymap.set("n", "<C-U>", "<C-U>zzzv")
vim.keymap.set("n", "<C-E>", "jzzzv")
vim.keymap.set("n", "<C-Y>", "kzzzv")

-- stay at position when joining lines
vim.keymap.set("n", "J", function()
    return "mz" .. vim.v.count .. "J`z"
end, { expr = true })
vim.keymap.set("n", "gJ", function()
    return "mz" .. vim.v.count .. "gJ`z"
end, { expr = true })

-- do not modify jumplist when jumping by paragaph
vim.keymap.set("n", "{", ":nnoremap <{ silent = true }> { :<C-u>execute 'keepjumps normal!' v:count1 . '{zz'<CR>", {silent = true })
vim.keymap.set("n", "}", ":nnoremap <{ silent = true }> } :<C-u>execute 'keepjumps normal!' v:count1 . '}zz'<CR>", {silent = true })

-- random binds
vim.keymap.set("n", "<C-S>", "<CMD>wa<CR>")

-- lsp commands
vim.keymap.set("n", "<leader>=", function() vim.lsp.buf.format { async = true } end)
vim.keymap.set("n", "<leader>lo", function() vim.diagnostic.enable(false) end)
vim.keymap.set("n", "<leader>ll", function() vim.diagnostic.enable() end)
vim.keymap.set("n", "<leader>_", "<CMD>set iskeyword-=_<CR>")

-- encoding data
vim.keymap.set("v", "<leader>ave",
    [[dmm:r!ansible-vault encrypt_string '<C-R>"' --encrypt-vault-id default --vault-id default@~/.ansible/.vault_pass<CR><CR>'mJ]])
vim.keymap.set("v", "<leader>avep",
    [[dmm:r!ansible-vault encrypt_string '<C-R>"' --encrypt-vault-id postgres --vault-id postgres@~/.ansible/.vault_pass_postgres<CR><CR>'mJ]])
vim.keymap.set("v", "<leader>aveo",
    [[dmm:r!ansible-vault encrypt_string '<C-R>"' --encrypt-vault-id oracle --vault-id=oracle@~/.ansible/.vault_pass_oracle<CR><CR>'mJ]])
vim.keymap.set("v", "<leader>avdo", "10<gv:!ansible-vault decrypt --vault-id=oracle@~/.ansible/.vault_pass_oracle<CR>")
vim.keymap.set("v", "<leader>avdp", "10<gv:!ansible-vault decrypt --vault-id=postgres@~/.ansible/.vault_pass_postgres<CR>")
vim.keymap.set("v", "<leader>avd", "10<gv:!ansible-vault decrypt --vault-id=default@~/.ansible/.vault_pass<CR>")
vim.keymap.set("n", "<leader>avf",
    "<CMD>!ansible-vault encrypt --encrypt-vault-id default --vault-password-file ~/.ansible/.vault_pass %<CR>")
vim.keymap.set("n", "<leader>avfo",
    "<CMD>!ansible-vault encrypt --encrypt-vault-id oracle --vault-id=oracle@~/.ansible/.vault_pass_oracle %<CR>")
vim.keymap.set("n", "<leader>avfp",
    "<CMD>!ansible-vault encrypt --encrypt-vault-id postgres --vault-id=postgres@~/.ansible/.vault_pass_postgres %<CR>")
vim.keymap.set("n", "<leader>64", [[viW"by<CMD>let @b=system('base64 --decode', @b)<cr>gv"bP]])
vim.keymap.set("v", "<leader>64", [["by<CMD>let @b=system('base64 --decode', @b)<cr>gv"bP]])
vim.keymap.set("n", "<leader>46", [[viW"by<CMD>let @b=system('base64 -w0', @b)<cr>gv"bP]])
vim.keymap.set("v", "<leader>46", [["by<CMD>let @b=system('base64 -w0', @b)<cr>gv"bP]])

-- replace the word under the cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- golang errors snipped
vim.keymap.set(
    "n",
    "<leader>ne",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

-- yaml lsp snippet
vim.keymap.set(
    "n",
    "<leader>yl",
    "O# yaml-language-server: $schema=file:///home/v3nc/kubernetes_schema/all.json<Esc>"
)

-- harpoon
vim.keymap.set("n", "<leader>a", function() require('harpoon.mark').add_file() end, { silent = true })
vim.keymap.set("n", "<leader>o", function() require('harpoon.ui').toggle_quick_menu() end, { silent = true })

-- left hand
vim.keymap.set("n", "<leader>1", function() require('harpoon.ui').nav_file(1) end, { silent = true })
vim.keymap.set("n", "<leader>2", function() require('harpoon.ui').nav_file(2) end, { silent = true })
vim.keymap.set("n", "<leader>3", function() require('harpoon.ui').nav_file(3) end, { silent = true })
vim.keymap.set("n", "<leader>4", function() require('harpoon.ui').nav_file(4) end, { silent = true })
vim.keymap.set("n", "<leader>5", function() require('harpoon.ui').nav_file(5) end, { silent = true })

-- right hand
vim.keymap.set("n", "<leader>6", function() require('harpoon.ui').nav_file(6) end, { silent = true })
vim.keymap.set("n", "<leader>7", function() require('harpoon.ui').nav_file(7) end, { silent = true })
vim.keymap.set("n", "<leader>8", function() require('harpoon.ui').nav_file(8) end, { silent = true })
vim.keymap.set("n", "<leader>9", function() require('harpoon.ui').nav_file(9) end, { silent = true })
vim.keymap.set("n", "<leader>0", function() require('harpoon.ui').nav_file(0) end, { silent = true })

-- Close open buffer
vim.keymap.set("n", "<Leader>q", "<CMD>bd<CR>zz")

vim.keymap.set("i", "<C-c>", "<Esc>")

-- Jump in qf list
vim.keymap.set("n", "<Leader>w", "<CMD>cnext<CR>zz")
vim.keymap.set("n", "<Leader>f", "<CMD>cprev<CR>zz")

-- git binds
vim.keymap.set("n", "<Leader>gg", "<CMD>Git<CR><C-w>o")
vim.keymap.set("n", "<Leader>gp", "<CMD>Git push <CR>")
vim.keymap.set("n", "<Leader>gb", "<CMD>diffget //2<CR>")
vim.keymap.set("n", "<Leader>gj", "<CMD>diffget //3<CR>")
vim.keymap.set("n", "<Leader>wtc", "<CMD>r ! curl -sL http://whatthecommit.com/index.txt<CR>kJ")
vim.keymap.set("n", "<Leader>spr", [[<CMD>r ! curl -sL https://sprichwortgenerator.de/ | grep spwort | sed 's/.*>\(.*\)<.*/\1/'<CR>kJ]])

-- move visible block
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keep highlighted when indenting
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- paste over
vim.keymap.set("x", "<leader>p", [["_dP]])

-- tmux
vim.keymap.set("n", "<C-q>", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>")

-- snippets
vim.keymap.set("n", "<leader>se", function() require("scissors").editSnippet() end)
vim.keymap.set({ "v", "n", "x" }, "<leader>sa", function() require("scissors").addNewSnippet() end)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>vq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal next to the file
vim.keymap.set('n', '<leader>ft', function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local opts = {
    relative = 'editor',
    row = (vim.o.lines - height) / 2,
    col = (vim.o.columns - width) / 2,
    width = width,
    height = height,
    style = 'minimal',
    border = 'single',
  }
  local cwd = vim.fn.expand('%:p:h')
  vim.api.nvim_open_win(buf, true, opts)
  vim.fn.termopen(vim.o.shell, { cwd = cwd })
  vim.cmd('startinsert')
end)
