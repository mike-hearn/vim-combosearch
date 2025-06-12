-- Test file for combosearch plugin
-- Run this with :luafile test_combosearch.lua

-- Test configuration
local combosearch = require('combosearch')

-- Test with custom configuration
combosearch.setup({
  trigger_key = '<c-p>',
  trigger_key_all = '<c-s-p>',
  pattern_length = 3,
  fzf_exact_match = true,
})

print("Combosearch plugin loaded successfully!")
print("Available commands:")
print("  :ComboSearch [query] - Search in git repository (if available)")
print("  :ComboSearchAll - Force search all files (ignore git)")
print("  <c-p> - Trigger combo search")
print("  <c-s-p> - Trigger combo search all")

-- Test search module
local search = require('combosearch.search')
print("\nTesting search module...")
print("Is git repo: " .. tostring(vim.fn.system('git -C . rev-parse 2>/dev/null; echo $?'):gsub('%s+', '') == '0'))

-- Test config module
local config = require('combosearch.config')
print("\nConfiguration values:")
print("  pattern_length: " .. config.get('pattern_length'))
print("  fzf_exact_match: " .. tostring(config.get('fzf_exact_match')))