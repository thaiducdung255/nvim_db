local api = vim.api
local buf, win
local position = 0

local TITLE = {
  db = ' DATABASES ',
  tb = ' TABLES ',
  schema = ' SCHEMAS ',
  conn = ' CONNECTIONS ',
}

local FILE_PATH = '~/_nvim.db'

local function center(str)
  local width = api.nvim_win_get_width(0)
  local shift = math.floor(width / 2) - math.floor(#str / 2)
  return string.rep(' ', shift) .. str
end

local function create_win(win_opts)
  local _buf = api.nvim_create_buf(false, true)

  -- get dimenstions of the window
  local width = api.nvim_get_option("columns")
  local height = api.nvim_get_option("lines")

  -- calculate our floating window sizes
  local win_height = math.ceil(height * 0.8 - 4)
  local win_width = math.ceil(width * 0.8)

  -- and its starting position
  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = nil

  if win_opts.is_border_win then
    opts = {
      style = "minimal",
      relative = "editor",
      row = row - 1,
      col = col - 1,
      width = win_width + 2,
      height = win_height + 2,
    }

    -- draw border
    local left_sep = math.floor((win_width - #win_opts.title) / 2)
    local right_sep = math.ceil((win_width - #win_opts.title) / 2)
    print(win_width, left_sep, right_sep, #win_opts.title, left_sep + right_sep + #win_opts.title)

    local border_lines = { '╔' .. string.rep('═', left_sep) .. win_opts.title .. string.rep('═', right_sep) .. '╗' }
    local middle_line = '║' .. string.rep(' ', win_width) .. '║'
    local bottom_line = '╚' .. string.rep('═', win_width) .. '╝'

    for _ = 1, win_height do
      table.insert(border_lines, middle_line)
    end

    table.insert(border_lines, bottom_line)
    api.nvim_buf_set_lines(_buf, 0, -1, false, border_lines)
    api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout!"' .. _buf)
  else
    opts = {
      style = "minimal",
      relative = "editor",
      row = row,
      col = col,
      width = win_width,
      height = win_height,
    }
  end

  local _win = api.nvim_open_win(
    _buf,
    true,
    opts
  )

  return _win, _buf
end

local function open_win(title)
  local _, _ = create_win({ title = title, is_border_win = true })
  win, buf = create_win({ is_border_win = false })
end

local function show_connections(direction)
  local file = io.open(FILE_PATH, "rb")
  if not file then
    os.execute('mkdir -p ' .. FILE_PATH)
  else
    local connections = {}
    api.nvim_buf_set_option(buf, "modifiable", true)
    position = position + direction
    if position < 0 then position = 0 end

    for connection_str in file:lines() do
      connections[#connections + 1] = connection_str
    end

    api.nvim_buf_set_lines(buf, 3, -1, false, connections)
    api.nvim_buf_set_option(buf, "modifiable", false)
  end
  -- api.nvim_buf_set_option(buf, "modifiable", true)
  -- position = position + direction
  -- if position < 0 then position = 0 end
  --
  -- local result = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r HEAD~' .. position)
  --
  -- if #result == 0 then
  --   table.insert(result, '')
  -- end
  --
  -- for k, _ in pairs(result) do
  --   result[k] = ' ' .. result[k]
  -- end
  --
  -- api.nvim_buf_set_lines(buf, 1, 2, false, { center('HEAD-' .. position) })
  -- api.nvim_buf_set_lines(buf, 3, -1, false, result)
  --
  -- api.nvim_buf_add_highlight(buf, -1, "DBUIHeader", 1, 0, -1)
  -- api.nvim_buf_set_option(buf, "modifiable", false)
end

local function close_window()
  api.nvim_win_close(win, true)
end

local function open_file()
  local str = api.nvim_get_current_line()
  close_window()
  api.nvim_command('edit ' .. str)
end

local function move_cursor()
  local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
  api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function set_mappings()
  local mappings = {
    ['N'] = 'update_view(-1)',
    ['E'] = 'update_view(1)',
    ['<CR>'] = 'open_file()',
    ['q'] = 'close_window()',
    ['i'] = 'move_cursor()',
  }

  local keymap_opts = { silent = true, noremap = true, nowait = true }

  for k, v in pairs(mappings) do
    api.nvim_buf_set_keymap(
      buf,
      'n',
      k,
      ':lua require"nvim_db".' .. v .. '<CR>',
      keymap_opts
    )
  end

  local other_chars = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'k', 'h', 'l'
  }

  for _, v in ipairs(other_chars) do
    api.nvim_buf_set_keymap(
      buf,
      'n',
      v,
      '',
      keymap_opts
    )

    api.nvim_buf_set_keymap(
      buf,
      'n',
      v:upper(),
      '',
      keymap_opts
    )
  end
end

local function nvim_db()
  position = 0
  open_win(TITLE.conn)
  set_mappings()
  show_connections(0)
  -- api.nvim_win_set_cursor(win, { 4, 0 })
end

return {
  nvim_db = nvim_db,
  update_view = show_connections,
  open_file = open_file,
  close_window = close_window,
  move_cursor = move_cursor,
}
