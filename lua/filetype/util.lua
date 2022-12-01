local M = {}

--- Function to get a specific line from the current buffer current buffer. The
--- function is zero-indexed.
---
--- @param i number|nil The line index, 0 if nil
--- @return string The line contents at index i or an empty string
function M.getline(i)
    i = i or 0
    return M.getlines(i, i + 1)[1] or ""
end

--- Function to get a range of lines from the current buffer current buffer. The
--- function is zero-indexed.
---
--- @param i number|nil The start index, 0 if nil
--- @param j number|nil The end index (exclusive), buffer length if nil
--- @return table<string> Array of lines, can be empty
function M.getlines(i, j)
    i = i or 0
    j = j or -1
    return vim.api.nvim_buf_get_lines(0, i, j, false)
end

--- Function to get a range of lines from the current buffer current buffer. The
--- function is zero-indexed.
---
--- @param i number|nil The start index, 0 if nil
--- @param j number|nil The end index (exclusive), buffer length if nil
--- @param sep string|nil The line separator, empty string if nil
--- @return string String representing lines concatenated by sep
function M.getlines_as_string(i, j, sep)
    sep = sep or ""
    return table.concat(M.getlines(i, j), sep)
end

--- Check whether the given string matches the Vim regex pattern. It
--- stores the patterns in a cache
---
--- @param s string String to check against regex against
--- @param pattern string Vim regex pattern
--- @return integer(s) The byte indices for the beginning and end of the match
M.match_vim_regex = vim.filetype.matchregex

--- Check whether a string matches any of the given Lua patterns.
---
---@param s string The string to check
---@param patterns table<string> A list of Lua patterns
---@return boolean `true` if s matched a pattern, else `false`
M.findany = vim.filetype.findany

return M
