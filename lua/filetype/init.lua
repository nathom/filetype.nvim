-- generate the filetype
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

-- Check the first line in the buffer for a shebang
-- If there is one, set the filetype appropriately
local function analyze_shebang()
    local fstline = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
    if fstline then
        return fstline:match("#!%s*/usr/bin/env%s+(%a+)$")
            or fstline:match("#!%s*/.*/(%a+)$")
    end
end

-- Loop through the regex-filetype pairs in the map table
-- and check if absolute_path matches any of them
-- Returns true if the filetype was set
local function try_regex(absolute_path, maps, star_set)
    if maps == nil then
        return false
    end
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

local function try_lookup(query, map)
    if map == nil then
        return false
    end
    if map[query] ~= nil then
        set_filetype(map[query])
        return true
    end
    return false
end

-- Trys to match the tables in map to the filename components given
-- Returns true if a match was found, otherwise false
local function try_all_maps(absolute_path, filename, ext, extensions)
    -- We first check the ones that only require a table lookup
    -- because they're the fastest

    -- Lookup file extension
    if ext then
        if try_lookup(ext, map.extensions) then
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

local M = {}

function M.setup(opts)
    if opts.overrides then
        custom_map = opts.overrides
    end
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
        if try_lookup(ext, custom_map.extensions) then
            return
        end

        if try_lookup(filename, custom_map.literal) then
            return
        end

        if try_lookup(ext, custom_map.function_extensions) then
            return
        end

        if try_lookup(filename, custom_map.function_literal) then
            return
        end

        if try_regex(absolute_path, custom_map.endswith) then
            return
        end

        if try_regex(absolute_path, custom_map.complex) then
            return
        end
        if try_regex(absolute_path, custom_map.star_sets, true) then
            return
        end

        -- if try_filetype_map(absolute_path, filename, ext, custom_map) then
        --     return
        -- end
    end

    local extension_map = require("filetype.mappings.extensions")
    if try_lookup(ext, extension_map) then
        return
    end

    local literal_map = require("filetype.mappings.literal")
    if try_lookup(filename, literal_map) then
        return
    end

    local function_maps = require("filetype.mappings.function")
    if try_lookup(ext, function_maps.extensions) then
        return
    end
    if try_lookup(filename, function_maps.literal) then
        return
    end

    if try_regex(absolute_path, function_maps.complex) then
        return
    end

    local complex_maps = require("filetype.mappings.complex")
    if try_regex(absolute_path, complex_maps.endswith) then
        return
    end
    if try_regex(absolute_path, complex_maps.complex) then
        return
    end
    if try_regex(absolute_path, complex_maps.star_sets, true) then
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
        shebang = custom_map.shebang[shebang]
            or builtin_map.shebang[shebang]
            or shebang
        set_filetype(shebang)
    end
end

return M
