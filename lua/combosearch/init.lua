local M = {}

local config = require('combosearch.config')
local search = require('combosearch.search')

-- Check if executable exists
local function check_executable(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Validate system compatibility
local function validate_compatibility()
  -- Check for Windows
  if vim.fn.has('win32') == 1 then
    vim.notify('Combosearch: Windows support is experimental. Some features may not work correctly.', vim.log.levels.WARN)
  end
  
  -- Check for fzf.vim
  if vim.fn.exists(':FZF') == 0 then
    vim.notify('Combosearch: fzf.vim is required but not found. Please install junegunn/fzf.vim', vim.log.levels.ERROR)
    return false
  end
  
  -- Check for required executables
  local required_cmds = {'git', 'grep', 'find', 'sed'}
  local missing = {}
  
  for _, cmd in ipairs(required_cmds) do
    if not check_executable(cmd) then
      table.insert(missing, cmd)
    end
  end
  
  if #missing > 0 then
    vim.notify(
      string.format('Combosearch: Missing required executables: %s', table.concat(missing, ', ')),
      vim.log.levels.ERROR
    )
    return false
  end
  
  return true
end

-- Helper function to strip whitespace
local function strip(str)
  return str:match('^%s*(.-)%s*$')
end

-- Create search command that streams results
local function create_search_command(query, force_all)
  local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':p:h:h:h')
  local search_script = plugin_dir .. '/plugin/search.sh'
  
  -- Set LC_ALL=C for consistent behavior and performance
  local cmd = 'LC_ALL=C ' .. search_script .. ' ' .. vim.fn.shellescape(query)
  if force_all then
    cmd = cmd .. ' all'
  end
  
  return cmd
end

-- Handle input with auto-trigger
local function get_input_with_trigger(prompt, extra_chars)
  local input = ''
  local pattern_length = config.get('pattern_length') + (extra_chars or 0)
  
  -- Create autocmd group
  local group = vim.api.nvim_create_augroup('combosearch_input', { clear = true })
  
  -- Set up autocmd for input monitoring
  vim.api.nvim_create_autocmd('CmdlineChanged', {
    group = group,
    pattern = '@',
    callback = function()
      if #vim.fn.getcmdline() >= pattern_length then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        vim.cmd('echo " "')
        vim.cmd('redraw!')
      end
    end
  })
  
  -- Get input
  input = vim.fn.input(prompt)
  
  -- Clean up autocmd
  vim.api.nvim_del_augroup_by_id(group)
  
  -- Strip whitespace
  return strip(input)
end

-- Common search implementation
local function run_search(opts)
  if not validate_compatibility() then
    return
  end
  
  local query = opts.initial_query
  if not query then
    query = get_input_with_trigger(opts.prompt, opts.extra_chars)
  end
  
  if query == '' then
    return
  end
  
  -- Build fzf options string
  local fzf_opts_str = '--prompt="Combo> " --ansi --multi --reverse'
  
  if config.get('fzf_exact_match') then
    fzf_opts_str = fzf_opts_str .. ' --exact'
  end
  
  -- Add initial query
  fzf_opts_str = fzf_opts_str .. ' -q ' .. vim.fn.shellescape(query)
  
  -- Create the search command that streams results
  local search_cmd = create_search_command(query, opts.force_all)
  
  -- Choose preview position based on bang
  local preview_pos = opts.bang and config.get('preview_position_alt') or config.get('preview_position')
  
  -- Call fzf with streaming results and preview
  vim.fn['fzf#vim#grep'](
    search_cmd,
    1,
    vim.fn['fzf#vim#with_preview']({
      options = fzf_opts_str
    }, preview_pos, '?'),
    opts.bang
  )
end

-- Main search function
function M.search(initial_query, bang)
  run_search({
    prompt = 'File/code search: ',
    initial_query = initial_query,
    force_all = false,
    bang = bang,
    extra_chars = 0
  })
end

-- Search all (force filesystem search)
function M.search_all(bang)
  run_search({
    prompt = 'File/code search (all): ',
    force_all = true,
    bang = bang,
    extra_chars = 2
  })
end

-- Setup function
function M.setup(opts)
  config.setup(opts)
  
  -- Create commands with bang support
  vim.api.nvim_create_user_command('ComboSearch', function(args)
    M.search(args.args ~= '' and args.args or nil, args.bang)
  end, { nargs = '?', bang = true })
  
  vim.api.nvim_create_user_command('ComboSearchAll', function(args)
    M.search_all(args.bang)
  end, { bang = true })
end

return M