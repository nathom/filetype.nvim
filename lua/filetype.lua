-- generate the filetype
mapping = require("mappings")

loaded_filetype = false

local M = {}
function M.set_filetype()
    -- Relative path
    local filename = vim.fn.expand("%")
    if filename == "" then
        return
    end

    -- Indices of extension
    local i, j = filename:find("%.%w+$")

    -- Text of extension
    local extension
    if i ~= nil then
        extension = filename:sub(i + 1, j)
    end

    -- We first check the ones that only require a table lookup
    -- because theyre the fastest

    -- Lookup file extension
    if extension ~= nil then
        set_ft_extensions(extension, mapping.extensions)

        if loaded_filetype then
            return
        end

        set_ft_extensions(extension, mapping.function_extensions)
        if loaded_filetype then
            return
        end
    end

    -- Lookup filename (for files like .vimrc or .bashrc)
    set_ft_literal(filename, mapping.literal)
    if loaded_filetype then
        return
    end
    set_ft_literal(filename, mapping.function_simple)
    if loaded_filetype then
        return
    end

    -- Finally, we check the ones that require regexes
    local abs_path = vim.fn.expand("%:p")

    -- I left the endswith table separate in case there is an optimization to
    -- deal with that better. For now, im just using regexes
    set_ft_complex(abs_path, mapping.endswith)
    if loaded_filetype then
        return
    end

    set_ft_complex(abs_path, mapping.complex)
    if loaded_filetype then
        return
    end

    -- These require the use of a special function that excludes
    -- certain filetypes from being binded to autocommands
    -- using g:ft_ignore_pat
    set_ft_complex(abs_path, mapping.star_sets, true)
    if loaded_filetype then
        return
    end

    -- Just in case
    vim.g.did_load_filetypes = 1
end

-- TODO: change so that the extension isnt being calculated over
-- and over again
function set_ft_extensions(filename, map)
    local i, j = filename:find("%.%w+$")
    if i ~= nil then
        local extension = filename:sub(i + 1, j)
        -- print("checking for extension match")
        local filetype = map[extension]
        if filetype ~= nil then
            set_ft_option(filetype)
        end
    end
end

function set_ft_literal(filename, map)
    print("checking literal with fn=" .. filename)
    local literal_match = map[filename]
    print("match=" .. tostring(literal_match))
    if literal_match ~= nil then
        set_ft_option(literal_match)
    end
end

function set_ft_option(name)
    -- print("setting filetype to " .. name)
    if type(name) == "string" then
        vim.o.filetype = name
        loaded_filetype = true
    elseif type(name) == "function" then
        -- print("calling function to set ft")
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
function star_set_ft_option(name)
    if not ft_ignore_regex:match_str(name) then
        -- print("star set " .. name)
        set_ft_option(name)
    else
        -- print("failed star set " .. name)
    end
end

function set_ft_complex(abs_path, map, star_set)
    for regexp, ft in pairs(map) do
        if abs_path:find(regexp) then
            if star_set then
                star_set_ft_option(ft)
            else
                set_ft_option(ft)
            end
        end
    end
end

return M
