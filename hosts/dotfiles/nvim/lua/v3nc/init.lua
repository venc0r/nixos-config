require("v3nc.settings")
require("v3nc.keymap")
require("v3nc.lazy")

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

-- inside plugin config
-- vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
--     pattern = "*",
--     callback = function()
--         require("lint").try_lint()
--     end
-- })

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = vim.api.nvim_create_augroup('trim_whitespace', { clear = true }),
    pattern = "*",
    command = [[%s/\s\+$//e]],
})
--
-- Silence the specific position encoding message
local notify_original = vim.notify
vim.notify = function(msg, ...)
  if
    msg
    and (
      msg:match 'position_encoding param is required'
      or msg:match 'Defaulting to position encoding of the first client'
      or msg:match 'multiple different client offset_encodings'
      or msg:match 'vim.lsp.util.jump_to_location is deprecated'
    )
  then
    return
  end
  return notify_original(msg, ...)
end
