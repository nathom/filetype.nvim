-- generate the filetype
local map = require("filetype.mappings")

-- Lua implementation of the setfiletype builtin function.
-- See :help setf
local function setf(filetype)
    if vim.fn.did_filetype() == 0 then
        vim.bo.filetype = filetype
    end
end

local function set_filetype(name)
    if type(name) == "string" then
        setf(name)
        return true
    elseif type(name) == "function" then
        local result = name()
        if type(result) == "string" then
            setf(result)
            return true
        end
    end
    return false
end

if vim.g.ft_ignore_pat == nil then
    vim.g.ft_ignore_pat = [[\.\(Z\|gz\|bz2\|zip\|tgz\)$]]
end
local ft_ignore_regex = vim.regex(vim.g.ft_ignore_pat)

-- Loop through the regex-filetype pairs in the map table
-- and check if absolute_path matches any of them
-- Returns true if the filetype was set
local function try_regex(absolute_path, maps, star_set)
    if star_set and ft_ignore_regex:match_str(absolute_path) then
        return false
    end
    for regexp, ft in pairs(maps) do
        if absolute_path:find(regexp) then
            if set_filetype(ft) then
                return true
            end
        end
    end
    return false
end

-- Check the first line in the buffer for a shebang
-- If there is one, set the filetype appropriately
local function analyze_shebang()
    local fstline = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
    if fstline then
        return fstline:match("#!%s*/usr/bin/env%s+(%a+)$") or fstline:match("#!%s*/.*/(%a+)$")
    end
end

local M = {}

function M.setup(opts)
    if opts.overrides then
        for table_name, table in pairs(opts.overrides) do
            for filename, filetype in pairs(table) do
                map[table_name][filename] = filetype
            end
        end
    end
end

function M.resolve()
    -- Just in case
    vim.g.did_load_filetypes = 1

    local filetype

    local filename = vim.fn.expand("%:t")
    if filename == "" then
        return
    end

    -- Extension
    local ext = filename:match("%.(%w+)$")

    -- We first check the ones that only require a table lookup
    -- because they're the fastest

    -- Lookup file extension
    if ext then
        filetype = map.extensions[ext] or map.function_extensions[ext]
        if filetype then
            set_filetype(filetype)
            return
        end
    end

    -- Lookup filename
    local literal = map.literal[filename] or map.function_literal[filename]
    if literal then
        set_filetype(literal)
    end

    -- Finally, we check the ones that require regexes.
    -- try_regex is relatively slow because it has to iterate through
    -- the key-value pairs and run a regex for each one

    local absolute_path = vim.fn.expand("%:p")

    -- The endswith table is left separate in case there an an optimization t
    -- that can be applied later. As of now, it's just using regexes.
    for ends, ft in pairs(map.endswith) do
        if vim.endswith(absolute_path, ends) then
            setf(ft)
            return
        end
    end

    if try_regex(absolute_path, map.complex) then
        return
    end

    -- These require the use of a special function that excludes
    -- certain filetypes from being binded to autocommands
    -- using g:ft_ignore_pat
    if try_regex(absolute_path, map.star_sets, true) then
        return
    end

    -- At this point, no filetype has been detected
    -- so let's just default to the extension, if it has one
    if ext then
        set_filetype(ext)
        return
    end

    -- If there is no extension, look for a shebang
    -- and set the filetype to that
    local shebang = analyze_shebang()
    if shebang then
        shebang = map.shebang[shebang] or shebang
        set_filetype(shebang)
    end
end

return M
