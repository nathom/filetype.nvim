-- generate the filetype
mapping = require("mappings")

local M = {}
function M.set_filetype()
    if vim.g.ft_ignore_pat == nil then
        vim.g.ft_ignore_pat = [[\.\(Z\|gz\|bz2\|zip\|tgz\)$]]
    end

    -- relative path
    local filename = vim.fn.expand("%")
    print("filename: " .. filename)
    if filename == "" then
        return
    end

    -- match extension
    local i, j = filename:find("%.%w+$")
    if i ~= nil then
        local extension = filename:sub(i + 1, j)
        print("checking for extension match")
        local filetype = mapping.extensions[extension]
        if filetype ~= nil then
            set_ft_option(filetype)
        end
    end

    -- match literal filenames
    print("checking for literal match")
    local literal_match = mapping.literal[filename]
    if literal_match ~= nil then
        set_ft_option(literal_match)
    end

    -- now we check the ones that require regexps/globs
    local abs_path = vim.fn.expand("%:p")
    print("abs path: " .. abs_path)
    for regexp, ft in pairs(mapping.endswith) do
        if abs_path:find(regexp) then
            set_ft_option(ft)
        end
    end

    -- check complex paths
    print("checking for complex matches with abs path = " .. abs_path)
    for regexp, ft in pairs(mapping.complex) do
        if abs_path:find(regexp) then
            set_ft_option(ft)
        end
    end

    -- check complex paths with star set
    print("checking for star set complex matches with abs path = " .. abs_path)
    for regexp, ft in pairs(mapping.star_sets) do
        if abs_path:find(regexp) then
            star_set_ft_option(ft)
        end
    end
end

function set_ft_option(name)
    print("setting filetype to " .. name)
    vim.o.filetype = name
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

function gen_endswith_regexp(token)
    return token .. "$"
end

return M
