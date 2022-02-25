local M = {}

local function getlines(i, j)
    return table.concat(
        vim.api.nvim_buf_get_lines(0, i - 1, j or i, true),
        "\n"
    )
end

M.extensions = {
    ["ms"] = function()
        vim.cmd([[if !dist#ft#FTnroff() | setf xmath | endif]])
    end,
    ["xpm"] = function()
        if getlines(1):find("XPM2") then
            return "xpm2"
        else
            return "xpm"
        end
    end,
    ["module"] = function()
        if getlines(1):find("%<%?php") then
            return "php"
        else
            return "virata"
        end
    end,
    ["pkg"] = function()
        if getlines(1):find("%<%?php") then
            return "php"
        else
            return "virata"
        end
    end,
    ["hw"] = function()
        if getlines(1):find("%<%?php") then
            return "php"
        else
            return "virata"
        end
    end,
    ["ts"] = function()
        if getlines(1):find("<%?xml") then
            return "xml"
        else
            return "typescript"
        end
    end,
    ["ttl"] = function()
        if getlines(1):find("^@?(prefix|base)") then
            return "stata"
        end
    end,
    ["t"] = function()
        -- Don't know how to translate this :(
        vim.cmd(
            [[if !dist#ft#FTnroff() && !dist#ft#FTperl() | setf tads | endif]]
        )
    end,
    ["class"] = function()
        -- Decimal escape sequence
        -- The original was "^\xca\xfe\xba\xbe"
        if getlines(1):find("^\x202\x254\x186\x190") then
            return "stata"
        end
    end,
    ["smi"] = function()
        if getlines(1):find("smil") then
            return "smil"
        else
            return "mib"
        end
    end,
    ["smil"] = function()
        if getlines(1):find("<?%s*xml.*?>") then
            return "xml"
        else
            return "smil"
        end
    end,
    ["cls"] = function()
        local first_line = getlines(1)
        if first_line:find("^%%") then
            return "tex"
        elseif first_line:sub(1, 1) == "#" and first_line:find("rexx") then
            return "rexx"
        else
            return "st"
        end
    end,
    ["install"] = function()
        if getlines(1):find("%<%?php") then
            return "php"
        else
            vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
        end
    end,
    ["decl"] = function()
        if getlines(1, 3):find("^%<%!SGML") then
            return "sgmldecl"
        end
    end,
    ["sgm"] = function()
        local top_file = getlines(1, 5)
        if top_file:find("linuxdoc") then
            return "sgmlnx"
        elseif
            getlines(1):find("%<%!DOCTYPE.*DocBook")
            or getlines(2):find("<!DOCTYPE.*DocBook")
        then
            vim.b.docbk_type = "sgml"
            vim.b.docbk_ver = 4
            return "docbk"
        else
            return "sgml"
        end
    end,
    ["sgml"] = function()
        local top_file = getlines(1, 5)
        if top_file:find("linuxdoc") then
            return "sgmlnx"
        elseif
            getlines(1):find("%<%!DOCTYPE.*DocBook")
            or getlines(2):find("<!DOCTYPE.*DocBook")
        then
            vim.b.docbk_type = "sgml"
            vim.b.docbk_ver = 4
            return "docbk"
        else
            return "sgml"
        end
    end,
    ["reg"] = function()
        if
            getlines(1):find(
                "^REGEDIT[0-9]*%s*$|^Windows Registry Editor Version %d*%.%d*%s*$"
            )
        then
            return "registry"
        end
    end,
    ["pm"] = function()
        if getlines(1):find("XPM2") then
            return "xpm2"
        elseif getlines(1):find("XPM") then
            return "xpm"
        else
            return "perl"
        end
    end,
    ["me"] = function()
        if
            vim.fn.expand("<afile>") ~= "read.me"
            and vim.fn.expand("<afile>") ~= "click.me"
        then
            return "nroff"
        end
    end,
    ["m4"] = function()
        if not vim.fn.expand("<afile>"):find("(html.m4$|fvwm2rc)") then
            return "m4"
        end
    end,
    ["edn"] = function()
        if getlines(1):find("^%s*%(%s*edif") then
            return "edif"
        else
            return "clojure"
        end
    end,
    ["rul"] = function()
        local top_file = getlines(1, 6)
        if top_file:find("InstallShield") then
            return "ishd"
        else
            return "diva"
        end
    end,
    ["prg"] = function()
        if vim.fn.exists("g:filetype_prg") == 1 then
            return vim.g.filetype_prg
        else
            return "clipper"
        end
    end,
    ["cpy"] = function()
        if getlines(1):find("^%#%#") then
            return "python"
        else
            return "cobol"
        end
    end,
    -- Complicated functions
    ["asp"] = function()
        if vim.g.filetype_asp ~= nil then
            return vim.g.filetype_asp
        elseif getlines(1, 3):find("perlscript") then
            return "aspperl"
        else
            return "aspvbs"
        end
    end,
    ["asa"] = function()
        if vim.g.filetype_asa ~= nil then
            return vim.g.filetype_asa
        else
            return "aspvbs"
        end
    end,
    ["cmd"] = function()
        if getlines(1):find("^%/%*") then
            return "rexx"
        else
            return "dosbatch"
        end
    end,
    ["cc"] = function()
        if vim.fn.exists("cynlib_syntax_for_cc") == 1 then
            return "cynlib"
        else
            return "cpp"
        end
    end,
    ["cpp"] = function()
        if vim.fn.exists("cynlib_syntax_for_cpp") == 1 then
            return "cynlib"
        else
            return "cpp"
        end
    end,
    ["inp"] = function()
        vim.cmd([[call dist#ft#Check_inp()]])
    end,
    ["asm"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["s"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["S"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["a"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["A"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["mac"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["lst"] = function()
        vim.cmd([[call dist#ft#FTasm()]])
    end,
    ["bas"] = function()
        vim.cmd([[call dist#ft#FTVB("basic")]])
    end,
    ["btm"] = function()
        vim.cmd([[call dist#ft#FTbtm()]])
    end,
    ["db"] = function()
        vim.cmd([[call dist#ft#BindzoneCheck('')]])
    end,
    ["c"] = function()
        vim.cmd([[call dist#ft#FTlpc()]])
    end,
    ["h"] = function()
        vim.cmd([[call dist#ft#FTheader()]])
    end,
    ["ch"] = function()
        vim.cmd([[call dist#ft#FTchange()]])
    end,
    ["ent"] = function()
        vim.cmd([[call dist#ft#FTent()]])
    end,
    ["ex"] = function()
        vim.cmd([[call dist#ft#ExCheck()]])
    end,
    ["eu"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["ew"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["exu"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["exw"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["EU"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["EW"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["EX"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["EXU"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["EXW"] = function()
        vim.cmd([[call dist#ft#EuphoriaCheck()]])
    end,
    ["d"] = function()
        vim.cmd([[call dist#ft#DtraceCheck()]])
    end,
    ["com"] = function()
        vim.cmd([[call dist#ft#BindzoneCheck('dcl')]])
    end,
    ["e"] = function()
        vim.cmd([[call dist#ft#FTe()]])
    end,
    ["E"] = function()
        vim.cmd([[call dist#ft#FTe()]])
    end,
    ["html"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["htm"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["shtml"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["stm"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["idl"] = function()
        vim.cmd([[call dist#ft#FTidl()]])
    end,
    ["pro"] = function()
        vim.cmd([[call dist#ft#ProtoCheck('idlang')]])
    end,
    ["m"] = function()
        vim.cmd([[call dist#ft#FTm()]])
    end,
    ["mms"] = function()
        vim.cmd([[call dist#ft#FTmms()]])
    end,
    ["*.mm"] = function()
        vim.cmd([[call dist#ft#FTmm()]])
    end,
    ["pp"] = function()
        vim.cmd([[call dist#ft#FTpp()]])
    end,
    ["pl"] = function()
        vim.cmd([[call dist#ft#FTpl()]])
    end,
    ["PL"] = function()
        vim.cmd([[call dist#ft#FTpl()]])
    end,
    ["inc"] = function()
        vim.cmd([[call dist#ft#FTinc()]])
    end,
    ["w"] = function()
        vim.cmd([[call dist#ft#FTprogress_cweb()]])
    end,
    ["i"] = function()
        vim.cmd([[call dist#ft#FTprogress_asm()]])
    end,
    ["p"] = function()
        vim.cmd([[call dist#ft#FTprogress_pascal()]])
    end,
    ["r"] = function()
        vim.cmd([[call dist#ft#FTr()]])
    end,
    ["R"] = function()
        vim.cmd([[call dist#ft#FTr()]])
    end,
    ["mc"] = function()
        vim.cmd([[call dist#ft#McSetf()]])
    end,
    ["ebuild"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["bash"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["eclass"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["ksh"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("ksh")]])
    end,
    ["etc/profile"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH(getline(1))]])
    end,
    ["sh"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH(getline(1))]])
    end,
    ["env"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH(getline(1))]])
    end,
    ["tcsh"] = function()
        vim.cmd([[call dist#ft#SetFileTypeShell("tcsh")]])
    end,
    ["csh"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    ["rules"] = function()
        vim.cmd([[call dist#ft#FTRules()]])
    end,
    ["sql"] = function()
        vim.cmd([[call dist#ft#SQL()]])
    end,
    ["tex"] = function()
        vim.cmd([[call dist#ft#FTtex()]])
    end,
    ["frm"] = function()
        vim.cmd([[call dist#ft#FTVB("form")]])
    end,
    ["xml"] = function()
        vim.cmd([[call dist#ft#FTxml()]])
    end,
    ["y"] = function()
        vim.cmd([[call dist#ft#FTy()]])
    end,
    ["dtml"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["pt"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["cpt"] = function()
        vim.cmd([[call dist#ft#FThtml()]])
    end,
    ["zsql"] = function()
        vim.cmd([[call dist#ft#SQL()]])
    end,
}
M.literal = {
    ["xorg.conf-4"] = function()
        vim.b.xf86conf_xfree86_version = 4
        return "xf86conf"
    end,
    ["xorg.conf"] = function()
        vim.b.xf86conf_xfree86_version = 4
        return "xf86conf"
    end,
    ["XF86Config"] = function()
        if getlines(1):find("XConfigurator") then
            vim.b.xf86conf_xfree86_version = 3
        end
        return "xf86conf"
    end,
    ["INDEX"] = function()
        if
            getlines(1):find(
                "^%s*(distribution|installed_software|root|bundle|product)%s*$"
            )
        then
            return "psf"
        end
    end,
    ["INFO"] = function()
        if
            getlines(1):find(
                "^%s*(distribution|installed_software|root|bundle|product)%s*$"
            )
        then
            return "psf"
        end
    end,
    ["control"] = function()
        if getlines(1):find("^Source%:") then
            return "debcontrol"
        end
    end,
    ["NEWS"] = function()
        if getlines(1):find("%; urgency%=") then
            return "debchangelog"
        end
    end,
    ["indent.pro"] = function()
        vim.cmd([[call dist#ft#ProtoCheck('indent')]])
    end,
    [".bashrc"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["bashrc"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["bash.bashrc"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["PKGBUILD"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["APKBUILD"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    [".kshrc"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("ksh")]])
    end,
    [".profile"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH(getline(1))]])
    end,
    [".tcshrc"] = function()
        vim.cmd([[call dist#ft#SetFileTypeShell("tcsh")]])
    end,
    ["tcsh.tcshrc"] = function()
        vim.cmd([[call dist#ft#SetFileTypeShell("tcsh")]])
    end,
    ["tcsh.login"] = function()
        vim.cmd([[call dist#ft#SetFileTypeShell("tcsh")]])
    end,
    [".login"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    [".cshrc"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    ["csh.cshrc"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    ["csh.login"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    ["csh.logout"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    [".alias"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    [".d"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
}

M.complex = {
    [".*/xorg%.conf%.d/.*%.conf"] = function()
        vim.b.xf86conf_xfree86_version = 4
        return "xf86conf"
    end,
    [".*printcap"] = function()
        vim.b.ptcap_type = "print"
        return "ptcap"
    end,
    [".*termcap"] = function()
        vim.b.ptcap_type = "term"
        return "ptcap"
    end,
    ["[cC]hange[lL]og"] = function()
        if getlines(1):find("%; urgency%=") then
            return "debchangelog"
        else
            return "changelog"
        end
    end,
    ["%.bashrc.*"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["%.bash[_-]profile"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["%.bash[_-]logout"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["%.bash[_-]aliases"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["%.bash%-fc[_-]"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["PKGBUILD.*"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["APKBUILD.*"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("bash")]])
    end,
    ["%.kshrc.*"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH("ksh")]])
    end,
    ["%.profile.*"] = function()
        vim.cmd([[call dist#ft#SetFileTypeSH(getline(1))]])
    end,
    ["%.tcshrc.*"] = function()
        vim.cmd([[call dist#ft#SetFileTypeShell("tcsh")]])
    end,
    ["%.login.*"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
    ["%.cshrc.*"] = function()
        vim.cmd([[call dist#ft#CSH()]])
    end,
}

M.shebang = {
    ["bash"] = "sh",
    ["node"] = "javascript",
    ["python3"] = "python",
}

return M
