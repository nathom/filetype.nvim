-- generate the filetype
local builtin_map = require("filetype.mappings")
local custom_map = nil

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

local function star_set_filetype(name)
    if not ft_ignore_regex:match_str(name) then
        return set_filetype(name)
    end
    return false
end

-- Loop through the regex-filetype pairs in the map table
-- and check if absolute_path matches any of them
-- Returns true if the filetype was set
local function try_regex(absolute_path, maps, star_set)
    for regexp, ft in pairs(maps) do
        if absolute_path:find(regexp) then
            if star_set then
                if star_set_filetype(ft) then
                    return true
                end
            else
                if set_filetype(ft) then
                    return true
                end
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
        return fstline:match("#!%s*/usr/bin/env%s+(%a+)$")
            or fstline:match("#!%s*/.*/(%a+)$")
    end
end

local M = {}

function M.setup(opts)
    if opts.overrides then
        custom_map = opts.overrides
    end
end

-- Trys to match the tables in map to the filename components given
-- Returns true if a match was found, otherwise false
local function try_filetype_map(absolute_path, filename, ext, map)
    -- We first check the ones that only require a table lookup
    -- because they're the fastest

    -- Lookup file extension
    if ext then
        filetype = map.extensions[ext] or map.function_extensions[ext]
        if filetype then
            set_filetype(filetype)
            return true
        end
    end

    -- Lookup filename
    local literal = map.literal[filename] or map.function_literal[filename]
    if literal then
        set_filetype(literal)
        return true
    end

    -- Finally, we check the ones that require regexes.
    -- try_regex is relatively slow because it has to iterate through
    -- the key-value pairs and run a regex for each one

    -- The endswith table is left separate in case there an an optimization
    -- that can be applied later. As of now, it's just using regexes.
    if try_regex(absolute_path, map.endswith) then
        return true
    end

    if try_regex(absolute_path, map.complex) then
        return true
    end

    -- These require the use of a special function that excludes
    -- certain filetypes from being binded to autocommands
    -- using g:ft_ignore_pat
    if try_regex(absolute_path, map.star_sets, true) then
        return true
    end

    return false
end

function M.resolve()
    -- Just in case
    vim.g.did_load_filetypes = 1

    local filetype

    local expand = vim.fn.expand

    local filename = expand("%:t")
    if filename == "" then
        return
    end

    -- Extension
    local ext = filename:match("%S%.(%w+)$")

    local absolute_path = expand("%:p")

    -- Try to match the custom defined filetypes
    if custom_map ~= nil then
        -- Avoid indexing nil
        for table_name, _ in pairs(builtin_map) do
            if custom_map[table_name] == nil then
                custom_map[table_name] = {}
            end
        end

        if try_filetype_map(absolute_path, filename, ext, custom_map) then
            return
        end
    end

    -- Try to match filename to builtin filetypes
    if try_filetype_map(absolute_path, filename, ext, builtin_map) then
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
        shebang = builtin_map.shebang[shebang] or shebang
        set_filetype(shebang)
    end
end

return M
