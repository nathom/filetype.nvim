local detect = require("filetype.detect")

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
                set_filetype(ft)
                return true
            end
        end
    end
    return false
end

local function try_lookup(query, map)
    if query == nil or map == nil then
        return false
    end
    if map[query] ~= nil then
        set_filetype(map[query])
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

    local absolute_path = vim.api.nvim_buf_get_name(0)

    if vim.bo.filetype == "bqfpreview" then
        absolute_path = vim.fn.expand("<amatch>")
    end

    if #absolute_path == 0 then
        return
    end

    local filename = absolute_path:match(".*[\\/](.*)")
    local ext = filename:match(".+%.(%w+)")

    -- Used at the end if no filetype is detected or an extension isn't available
    local detect_sh_args

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

        if try_regex(absolute_path, custom_map.function_complex) then
            return
        end

        if try_regex(absolute_path, custom_map.star_sets, true) then
            return
        end

        -- Extend the shebang_map with users map and override already existing
        -- values
        for binary, ft in pairs(custom_map.shebang) do
            detect.shebang[binary] = ft
        end

        detect_sh_args.fallback = custom_map.default_filetype
        detect_sh_args.force_shebang_check = custom_map.force_shebang_check
        detect_sh_args.check_contents = custom_map.check_sh_contents
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

    -- If there is no extension, look for a shebang and set the filetype to
    -- that. Look for a shebang override in custom_map first. If there is none,
    -- check the default shebangs defined in function_maps. Otherwise, default
    -- to setting the filetype to the value of shebang itself.
    local ft = detect.sh(detect_sh_args)
    set_filetype(ft)
end

return M
