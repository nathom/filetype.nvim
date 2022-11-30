local util = require("filetype.util")

local M = {}

-- A map from executable name to filetype.
M.shebang = {
    ["node"] = "javascript",
    ["tclsh"] = "tcl",
    ["ksh"] = {
        filetype = "ksh",
        on_detect = function()
            vim.b.is_kornshell = 1
            vim.b.is_bash = nil
            vim.b.is_dash = nil
            vim.b.is_sh = nil
        end,
    },
    ["bash"] = {
        filetype = "bash",
        on_detect = function()
            vim.b.is_bash = 1
            vim.b.is_kornshell = nil
            vim.b.is_dash = nil
            vim.b.is_sh = nil
        end,
    },
    ["dash"] = {
        filetype = "dash",
        on_detect = function()
            vim.b.is_dash = 1
            vim.b.is_kornshell = nil
            vim.b.is_bash = nil
            vim.b.is_sh = nil
        end,
    },
    ["sh"] = {
        filetype = "sh",
        on_detect = function()
            vim.b.is_sh = 1
            vim.b.is_kornshell = vim.g.is_kornshell
            vim.b.is_bash = vim.g.is_bash or vim.g.bash_is_sh
            vim.b.is_dash = vim.g.is_dash
        end,
    },
}

--- Checks the first line in the buffer for a shebang If there is one, set the
--- filetype appropriately.
--- Taken from vim.filetype.detect
---
--- @param args table|nil
---             * fallback string|nil The shell binary that is returned as the
---                                   filetype if no filetype is associated with it
---             * force_shebang_check boolean Forces checking the shebang line even
---                                           if a fallback filetype is defined
---             * check_contents boolean Decides whether the buffer content is
---                                      checked for shell-like filetypes.
--- @return string|nil The detected filetype
function M.sh(args)
    args = args or {}

    if vim.fn.did_filetype() ~= 0 then
        -- Filetype was already detected or detection should be skipped
        return
    end

    local name = args.fallback

    -- Analyze the first line if there is no file type
    if not name or args.force_shebang_check then
        name = M.analyze_shebang(util.getline()) or name
    end

    -- Check the contents of the file if it overrides the shebang or the
    -- passed name
    name = (args.check_contents and M.shell(name, util.getlines())) or name

    -- prioritize the passed shebang over the builtin map. use the passed name
    -- if it isn't defined in either
    name = (M.shebang and M.shebang[name]) or name
    if type(name) == "table" then
        name.on_detect()
        name = name.filetype
    end

    return name
end

--- Function to extract the binary name from from the shebang
---
--- @param shebang string The shebang to analyze
--- @return string|nil The extracted binary name
function M.analyze_shebang(shebang)
    if not shebang or type(shebang) ~= "string" then
        return -- Not a string, so don't bother
    end

    -- The regex requires that all binaries end in an alpha character, so that
    -- the same shell with different version numbers as suffix are treated the same
    -- (python3 => python | zsh-5.9 => zsh | test-b#in_sh2 => test-b#in_sh )
    return shebang:match("#!.*/env%s+([^/%s]*%a)") or shebang:match("#!.*/([^/%s]*%a)")
end

--- For shell-like file types, check for an "exec" command hidden in a comment,
--- as used for Tcl.
--- Taken from vim.filetype.detect
---
--- @param name string|nil The filetype returned if the contents don't hint to a
---                        different filetype
--- @param contents table An array of the lines in the buffer
--- @return string|nil The detected filetype
function M.shell(name, contents)
    if vim.fn.did_filetype() ~= 0 then
        -- Filetype was already detected or detection should be skipped
        return
    end

    local prev_line = ""
    for _, line in ipairs(contents) do
        line = line:lower()
        if line:find("%s*exec%s") and not prev_line:find("^%s*#.*\\$") then
            -- Found an "exec" line after a comment with continuation
            if util.match_vim_regex(line, [[\c\<tclsh\|\<wish]]) then
                return "tclsh"
            end
        end
        prev_line = line
    end

    return name
end

--- The function tries to determine which csh varient is this filetype. The
--- function still checks if shebang matches or not
--- Taken from vim.filetype.detect
---
--- @return string|nil The detected filetype
function M.csh()
    if vim.fn.did_filetype() ~= 0 then
        -- Filetype was already detected
        return
    end

    local fallback
    if vim.g.filetype_csh then
        fallback = vim.g.filetype_csh
    elseif string.find(vim.o.shell, "tcsh") then
        fallback = "tcsh"
    else
        fallback = "csh"
    end

    return M.sh({ fallback = fallback, force_shebang_check = true })
end

--- This function checks for the kind of assembly that is wanted by the user, or
--- can be detected from the first five lines of the file.
--- Taken from vim.filetype.detect
---
--- @return string The detected filetype
function M.asm()
    local syntax = vim.b.asmsyntax
    if not syntax or syntax == "" then
        syntax = M.asm_syntax()
    end

    vim.b.asmsyntax = syntax
    return syntax
end

--- Checks the first 5 lines for a asmsyntax=foo override.
--- Only whitespace characters can be present immediately before or after this statement.
--- Taken from vim.filetype.detect
---
--- @return string The detected filetype or g:asmsyntax or "asm"
function M.asm_syntax()
    local lines = " " .. util.getlines_as_string(0, 5, " "):lower() .. " "
    local match = lines:match("%sasmsyntax=([a-zA-Z0-9]+)%s")
    if match then
        return match
    end

    if
        util.findany(
            lines,
            { "%.title", "%.ident", "%.macro", "%.subtitle", "%.library" }
        )
    then
        return "vmasm"
    end

    -- Defaults to g:asmsyntax or GNU
    return (vim.g.asmsyntax ~= 0 and vim.g.asmsyntax) or "asm"
end

--- This function checks for user define g:filetype_euphoria and returns
--- "euphoira3" if it isn't set
--- Taken from vim.filetype.detect
---
--- @return string The detected filetype
function M.euphoria_check()
    if vim.g.filetype_euphoria then
        return vim.g.filetype_euphoria
    end

    return "euphoria3"
end

--- This function checks for user define g:filetype_euphoria and checks
--- the contents of the first 100 lines for hints if it isn't set
--- Taken from vim.filetype.detect
---
--- @return string The detected filetype
function M.eiffel_check()
    if vim.g.filetype_euphoria then
        return vim.g.filetype_euphoria
    end

    for _, line in ipairs(util.getlines(0, 100)) do
        if util.findany(line, { "^%s*<'%s*$", "^%s*'>%s*$" }) then
            return "specman"
        end
    end

    return "eiffel"
end

--- This function checks for user define g:filetype_euphoria and checks
--- the contents of the first 100 lines for hints if it isn't set
--- Taken from vim.filetype.detect
---
--- @return string The detected filetype
function M.elixir_check()
    if vim.g.filetype_euphoria then
        return vim.g.filetype_euphoria
    end

    for _, line in ipairs(util.getlines(0, 100)) do
        if util.match_vim_regex(line, [[\c^--\|^ifdef\>\|^include\>]]) then
            return "euphoria3"
        end
    end

    return "elixir"
end

return M
