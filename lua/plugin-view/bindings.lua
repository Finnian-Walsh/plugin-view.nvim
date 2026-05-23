local utils = require "plugin-view.utils"

---@private
local M = {}

local get_plugin_name = function(line)
  return line:match "^([^%s]+)"
end

local get_plugin_data = function(line)
  return { name = get_plugin_name(line), active = line:match "Yes$" }
end

M.setup = function(buf, win)
  utils.add_keymap(buf, "n", "q", function()
    vim.api.nvim_win_close(win, true)
  end)
  utils.add_keymap(buf, "n", "<ESC>", function()
    vim.api.nvim_win_close(win, true)
  end)
  utils.add_keymap(buf, "n", "U", function()
    vim.pack.update()
  end)
  utils.add_keymap(buf, "n", "u", function()
    local plugin_name = get_plugin_name(vim.api.nvim_get_current_line())
    if not plugin_name then
      vim.notify("Plugin not found in current line", vim.log.levels.ERROR)
      return
    end

    vim.pack.update { plugin_name }
  end)
  utils.add_keymap(buf, "n", "d", function()
    local plugin_data = get_plugin_data(vim.api.nvim_get_current_line())
    if not plugin_data.name then
      vim.notify("Plugin not found in current line", vim.log.levels.ERROR)
      return
    end

    if plugin_data.active then
      vim.notify("Plugin is currently in use", vim.log.levels.WARN)
      return
    end

    vim.pack.del { plugin_data.name }

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    table.remove(lines, vim.api.nvim_win_get_cursor(0)[1])

    local opts = { buf = buf }

    vim.api.nvim_set_option_value("modifiable", true, opts)
    vim.api.nvim_set_option_value("readonly", false, opts)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    vim.api.nvim_set_option_value("modifiable", false, opts)
    vim.api.nvim_set_option_value("readonly", true, opts)
  end)
end

return M
