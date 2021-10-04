-- generate the filetype
local map = require("filetype.mappings")

local function set_filetype(name)
    if type(name) == "string" then
        vim.bo.filetype = name
        return true
    elseif type(name) == "function" then
        local n = name()
        if type(n) == "string" then
            vim.bo.filetype = n
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

local function try_regex(abs_path, maps, star_set)
    local ok = false
    for regexp, ft in pairs(maps) do
        if abs_path:find(regexp) then
            if star_set then
                ok = star_set_filetype(ft)
            else
                ok = set_filetype(ft)
            end
            if ok then
                return true
            end
        end
    end
    return false
end

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

    -- filetype
    local filetype

    -- filename
    local filename = vim.fn.expand("%:t")
    if filename == "" then
        return
    end

    -- extension
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

    local literal = map.literal[filename] or map.function_literal[filename]
    if literal then
        set_filetype(literal)
    end

    -- Finally, we check the ones that require regexes
    -- try_regex is relatively slow because it has to iterate through
    -- the key-value pairs and run a regex for each one
    local abs_path = vim.fn.expand("%:p")

    -- I left the endswith table separate in case there is an optimization to
    -- deal with that better. For now, I'm just using regex
    if try_regex(abs_path, map.endswith) then
        return
    end

    if try_regex(abs_path, map.complex) then
        return
    end

    -- These require the use of a special function that excludes
    -- certain filetypes from being binded to autocommands
    -- using g:ft_ignore_pat
    if try_regex(abs_path, map.star_sets, true) then
        return
    end

    -- At this point, no filetype has been detected
    -- so let's just default to the extension name
    if ext then
        set_filetype(ext)
        return
    end

    -- Try to find the shebang and set filetype
    local shebang = analyze_shebang()
    if shebang then
        shebang = map.shebang[shebang] or shebang
        set_filetype(shebang)
    end
end

return M
