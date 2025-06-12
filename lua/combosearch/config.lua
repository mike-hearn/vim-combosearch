local M = {}

-- Default configuration
local defaults = {
  -- Trigger key for normal search
  trigger_key = nil,
  -- Trigger key for search all (non-git)
  trigger_key_all = nil,
  -- Number of characters before search triggers
  pattern_length = 3,
  -- Whether to use exact matching in fzf
  fzf_exact_match = true,
  -- FZF preview options
  preview_position = 'right:50%:hidden',
  preview_position_alt = 'up:60%',
}

-- Current configuration
M.options = {}

-- Setup function to merge user config with defaults
function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})
  
  -- Set up key mappings if specified
  if M.options.trigger_key then
    vim.keymap.set('n', M.options.trigger_key, function()
      require('combosearch').search(nil, false)
    end, { silent = true, desc = 'Combo search' })
  end
  
  if M.options.trigger_key_all then
    vim.keymap.set('n', M.options.trigger_key_all, function()
      require('combosearch').search_all(false)
    end, { silent = true, desc = 'Combo search all' })
  end
end

-- Get a config value
function M.get(key)
  return M.options[key]
end

return M