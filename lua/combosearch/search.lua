-- NOTE: This file contains a pure Lua implementation of the search functionality.
-- However, it is not currently used because the shell script provides better
-- streaming performance. The plugin still uses plugin/search.sh for actual searches.
-- This file is kept for future reference if we implement async search with vim.loop.

local M = {}

-- ANSI color codes for output formatting
M.colors = {
  black = '\27[30m',
  red = '\27[31m',
  green = '\27[32m',
  orange = '\27[33m',
  reset = '\27[0m'
}

-- Helper function to escape shell arguments
local function shellescape(str)
  return vim.fn.shellescape(str)
end

-- Helper function to strip whitespace
local function strip(str)
  return str:match('^%s*(.-)%s*$')
end

-- Colorize file output (for files without line numbers)
local function colorize_file_output(line)
  -- Pattern: filename:0:0
  return line:gsub('^(.*)(:0:0)$', M.colors.orange .. '%1' .. M.colors.black .. '%2' .. M.colors.reset)
end

-- Colorize grep output (for lines with content)
local function colorize_grep_output(line)
  -- Pattern: filename:line:column:content
  return line:gsub('^(.-):(%d+):(%d+)(:)', 
    M.colors.red .. '%1' .. M.colors.reset .. ':' .. 
    M.colors.green .. '%2' .. M.colors.reset .. ':' .. 
    M.colors.reset .. '%3%4 ')
end

-- Remove duplicates from results
local function deduplicate(results)
  local seen = {}
  local unique = {}
  
  for _, line in ipairs(results) do
    if not seen[line] then
      seen[line] = true
      table.insert(unique, line)
    end
  end
  
  return unique
end

-- Check if we're in a git repository
local function is_git_repo()
  return vim.fn.system('git -C . rev-parse 2>/dev/null; echo $?'):gsub('%s+', '') == '0'
end

-- Execute git-based search
function M.git_search(query)
  local results = {}
  
  -- Properly escape the query for shell
  local escaped_query = vim.fn.shellescape(query):sub(2, -2)  -- Remove outer quotes
  
  -- Search for files matching the pattern
  local file_cmd = string.format(
    'git --no-pager ls-files -cmo --exclude-standard %s | sed "s/$/:0:0/g"',
    vim.fn.shellescape(':(icase)**' .. query .. '**')
  )
  local files = vim.fn.systemlist(file_cmd)
  for _, file in ipairs(files) do
    table.insert(results, colorize_file_output(file))
  end
  
  -- Search for content matching the pattern
  local content_cmd = string.format(
    'git --no-pager grep -I -n -i --untracked %s | sed -E "s/:([0-9]+):/:\\1:0:/g"',
    vim.fn.shellescape(query)
  )
  local content_matches = vim.fn.systemlist(content_cmd)
  for _, match in ipairs(content_matches) do
    table.insert(results, colorize_grep_output(match))
  end
  
  -- Search for any content in files matching the pattern
  local file_content_cmd = string.format(
    'git --no-pager grep -I -n --untracked "[A-Za-z0-9]" %s | sed -E "s/:([0-9]+):/:\\1:0:/g"',
    vim.fn.shellescape(':(icase)**' .. query .. '**')
  )
  local file_content_matches = vim.fn.systemlist(file_content_cmd)
  for _, match in ipairs(file_content_matches) do
    table.insert(results, colorize_grep_output(match))
  end
  
  return deduplicate(results)
end

-- Execute filesystem-based search (non-git)
function M.filesystem_search(query)
  local results = {}
  
  -- Find files matching the pattern
  local file_cmd = string.format(
    'find . -type f -ipath %s 2>/dev/null | sed "s/$/:0:0/g"',
    vim.fn.shellescape('*' .. query .. '*')
  )
  local files = vim.fn.systemlist(file_cmd)
  for _, file in ipairs(files) do
    table.insert(results, colorize_file_output(file))
  end
  
  -- Grep for content matching the pattern
  local content_cmd = string.format(
    'grep -rIHin %s . 2>/dev/null | sed -E "s/:([0-9]+):/:\\1:0:/g"',
    vim.fn.shellescape(query)
  )
  local content_matches = vim.fn.systemlist(content_cmd)
  for _, match in ipairs(content_matches) do
    table.insert(results, colorize_grep_output(match))
  end
  
  -- Grep for any content in files matching the pattern
  local file_content_cmd = string.format(
    'grep -rIHin --include %s "[A-Za-z0-9]" . 2>/dev/null | sed -E "s/:([0-9]+):/:\\1:0:/g"',
    vim.fn.shellescape('*' .. query .. '*')
  )
  local file_content_matches = vim.fn.systemlist(file_content_cmd)
  for _, match in ipairs(file_content_matches) do
    table.insert(results, colorize_grep_output(match))
  end
  
  return deduplicate(results)
end

-- Main search function
function M.search(query, force_all)
  -- Remove dangerous characters from query
  query = query:gsub('["`\'%^%$]', '')
  
  -- Choose search method
  local results
  if is_git_repo() and not force_all then
    results = M.git_search(query)
  else
    results = M.filesystem_search(query)
  end
  
  return results
end

return M