vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave', 'InsertLeave' }, {
  callback = function()
    if vim.bo.modified and vim.bo.filetype ~= 'nofile' then
      vim.cmd 'silent! wall'
    end
  end,
  desc = 'Auto-save on common edit-related events',
})
