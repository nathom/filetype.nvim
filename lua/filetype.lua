-- generate the filetype
mapping = require("mappings")

local M = {}
function M.set_filetype()
    -- relative path
    local filename = vim.fn.expand("%")
    print("filename: " .. filename)
    if filename == "" then
        return
    end

    -- match extension
    set_ft_extensions(filename, mapping.extensions)
    -- match literal filenames
    print("checking for literal match")
    set_ft_literal(filename, mapping.literal)

    -- now we check the ones that require regexps/globs
    local abs_path = vim.fn.expand("%:p")
    print("abs path: " .. abs_path)

    set_ft_complex(abs_path, mapping.endswith)

    -- check complex paths
    print("checking for complex matches with abs path = " .. abs_path)
    set_ft_complex(abs_path, mapping.complex)
    print("checking for star set complex matches with abs path = " .. abs_path)
    set_ft_complex(abs_path, mapping.star_sets)

    vim.g.did_load_filetypes = 1
end

function set_ft_extensions(filename, map)
    local i, j = filename:find("%.%w+$")
    if i ~= nil then
        local extension = filename:sub(i + 1, j)
        print("checking for extension match")
        local filetype = map[extension]
        if filetype ~= nil then
            set_ft_option(filetype)
        end
    end
end

function set_ft_literal(filename, map)
    local literal_match = mapping.literal[filename]
    if literal_match ~= nil then
        set_ft_option(literal_match)
    end
end

function set_ft_option(name)
    print("setting filetype to " .. name)
    if type(name) == "string" then
        vim.o.filetype = name
    elseif type(name) == "function" then
        print("calling function to set ft")
        name()
    end
end

if vim.g.ft_ignore_pat == nil then
    vim.g.ft_ignore_pat = [[\.\(Z\|gz\|bz2\|zip\|tgz\)$]]
end
local ft_ignore_regex = vim.regex(vim.g.ft_ignore_pat)
function star_set_ft_option(name)
    if not ft_ignore_regex:match_str(name) then
        print("star set " .. name)
        set_ft_option(name)
    else
        print("failed star set " .. name)
    end
end

function set_ft_complex(abs_path, map)
    for regexp, ft in pairs(map) do
        if abs_path:find(regexp) then
            set_ft_option(ft)
        end
    end
end

return M
