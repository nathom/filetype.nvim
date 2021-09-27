-- generate the filetype
local mapping = require("mappings")

local function setf(filetype)
    vim.cmd("setf " .. filetype)
end

local function set_filetype(name)
    if type(name) == "string" then
        setf(name)
        return true
    elseif type(name) == "function" then
        local result = name()
        if type(result) == "string" then
            setf(name)
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

local function try_regex(abs_path, map, star_set)
    local loaded_filetype = false
    for regexp, ft in pairs(map) do
        if abs_path:find(regexp) then
            if star_set then
                loaded_filetype = star_set_filetype(ft) or loaded_filetype
            else
                loaded_filetype = set_filetype(ft) or loaded_filetype
            end
        end
    end
    return loaded_filetype
end

local function try_extensions(extension, map)
    local filetype = map[extension]
    if filetype ~= nil then
        return set_filetype(filetype)
    end
    return false
end

local function try_literal(filename, map)
    local literal_match = map[filename]
    if literal_match ~= nil then
        return set_filetype(literal_match)
    end
    return false
end

local M = {}
function M.resolve()
    -- Just in case
    vim.g.did_load_filetypes = 1

    -- Relative path
    local relative_path = vim.fn.expand("%")
    if relative_path == "" then
        return
    end

    -- Indices of extension
    local i, j = relative_path:find("%.%w+$")

    -- Text of extension
    local extension
    if i ~= nil then
        extension = relative_path:sub(i + 1, j)
    end

    -- We first check the ones that only require a table lookup
    -- because they're the fastest

    -- Lookup file extension
    if extension ~= nil then
        if try_extensions(extension, mapping.extensions) then
            return
        end

        if try_extensions(extension, mapping.function_extensions) then
            return
        end
    end

    -- Lookup filename (for files like .vimrc or .bashrc)
    local filename = relative_path:gsub(".*%/", "")

    if try_literal(filename, mapping.literal) then
        return
    end
    if try_literal(filename, mapping.function_simple) then
        return
    end

    -- Finally, we check the ones that require regexes
    -- try_regex is relatively slow because it has to iterate through
    -- the key-value pairs and run a regex for each one
    local abs_path = vim.fn.expand("%:p")

    -- I left the endswith table separate in case there is an optimization to
    -- deal with that better. For now, I'm just using regex
    if try_regex(abs_path, mapping.endswith) then
        return
    end

    if try_regex(abs_path, mapping.complex) then
        return
    end

    -- These require the use of a special function that excludes
    -- certain filetypes from being binded to autocommands
    -- using g:ft_ignore_pat
    if try_regex(abs_path, mapping.star_sets, true) then
        return
    end

    -- At this point, no filetype has been detected
    -- so let's just default to the extension name
    if extension then
        setf(extension)
    else -- There is no extension
        setf("FALLBACK")
    end
end

return M
