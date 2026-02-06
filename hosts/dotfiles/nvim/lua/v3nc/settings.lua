vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.compatible = false
vim.opt.hidden = true

vim.opt.errorbells = false
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.showmode = false
vim.opt.laststatus = 2

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.mouse = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "100"
vim.opt.cursorline = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.path = "**"
vim.opt.wildmenu = true

vim.opt.previewheight = 20
vim.opt.termguicolors = true

vim.bo.filetype = "on"

vim.opt.foldlevelstart = 20
vim.opt.foldmethod = "manual"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- vim.opt.lazyredraw = true

-- Yank to clipboard
vim.opt.clipboard = "unnamedplus"
