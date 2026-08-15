vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('auto-save', { clear = true }),
  callback = function()
    -- `nofile` is a 'buftype', not a 'filetype' -- guarding on filetype here
    -- never matched, so scratch/plugin buffers were included in the `wall`.
    if vim.bo.modified and vim.bo.buftype == '' then
      vim.cmd 'silent! wall'
    end
  end,
  desc = 'Auto-save on common edit-related events',
})
