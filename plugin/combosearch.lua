-- vim-combosearch - Neovim Lua plugin
-- Combined filename and file content search using fzf

-- Don't load if already loaded
if vim.g.loaded_combosearch then
  return
end
vim.g.loaded_combosearch = true

-- Load the plugin with default settings
require('combosearch').setup()