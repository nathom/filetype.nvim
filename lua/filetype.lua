-- generate the filetype
mapping = require("mappings")

loaded_filetype = false

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
        try_extensions(extension, mapping.extensions)
        if loaded_filetype then
            return
        end

        try_extensions(extension, mapping.function_extensions)
        if loaded_filetype then
            return
        end
    end

    -- Lookup filename (for files like .vimrc or .bashrc)
    local filename = relative_path:gsub(".*%/", "")

    try_literal(filename, mapping.literal)
    if loaded_filetype then
        return
    end
    try_literal(filename, mapping.function_simple)
    if loaded_filetype then
        return
    end

    -- Finally, we check the ones that require regexes
    local abs_path = vim.fn.expand("%:p")

    -- I left the endswith table separate in case there is an optimization to
    -- deal with that better. For now, I'm just using regex
    try_regex(abs_path, mapping.endswith)
    if loaded_filetype then
        return
    end

    try_regex(abs_path, mapping.complex)
    if loaded_filetype then
        return
    end

    -- These require the use of a special function that excludes
    -- certain filetypes from being binded to autocommands
    -- using g:ft_ignore_pat
    try_regex(abs_path, mapping.star_sets, true)
    if loaded_filetype then
        return
    end

    -- At this point, no filetype has been detected
    -- so let's just default to the extension name
    vim.o.filetype = extension
end

-- TODO: change so that the extension isnt being calculated over
-- and over again
function try_extensions(extension, map)
    local filetype = map[extension]
    if filetype ~= nil then
        set_filetype(filetype)
    end
end

function try_literal(filename, map)
    local literal_match = map[filename]
    if literal_match ~= nil then
        set_filetype(literal_match)
    end
end

function set_filetype(name)
    if type(name) == "string" then
        vim.o.filetype = name
        loaded_filetype = true
    elseif type(name) == "function" then
        local result = name()
        if type(result) == "string" then
            vim.o.filetype = result
            loaded_filetype = true
        end
    end
end

if vim.g.ft_ignore_pat == nil then
    vim.g.ft_ignore_pat = [[\.\(Z\|gz\|bz2\|zip\|tgz\)$]]
end
local ft_ignore_regex = vim.regex(vim.g.ft_ignore_pat)

function star_set_filetype(name)
    if not ft_ignore_regex:match_str(name) then
        set_filetype(name)
    else
    end
end

function try_regex(abs_path, map, star_set)
    for regexp, ft in pairs(map) do
        if abs_path:find(regexp) then
            if star_set then
                star_set_filetype(ft)
            else
                set_filetype(ft)
            end
        end
    end
end

return M
