local util = require("filetype.util")
local detect = require("filetype.detect")

local M = {}

M.extensions = {
    ["ms"] = function()
        return detect.nroff() or "xmath"
    end,
    ["xpm"] = function()
        if util.getline():find("XPM2") then
            return "xpm2"
        else
            return "xpm"
        end
    end,
    ["module"] = function()
        if util.getline():find("%<%?php") then
            return "php"
        else
            return "virata"
        end
    end,
    ["pkg"] = function()
        if util.getline():find("%<%?php") then
            return "php"
        else
            return "virata"
        end
    end,
    ["hw"] = function()
        if util.getline():find("%<%?php") then
            return "php"
        else
            return "virata"
        end
    end,
    ["ts"] = function()
        if util.getline():find("<%?xml") then
            return "xml"
        else
            return "typescript"
        end
    end,
    ["ttl"] = function()
        if util.getline():find("^@?(prefix|base)") then
            return "stata"
        end
    end,
    ["t"] = function(args)
        return detect.nroff() or detect.perl(args.file_path, args.file_ext) or "tads"
    end,
    ["class"] = function()
        -- Decimal escape sequence
        -- The original was "^\xca\xfe\xba\xbe"
        if util.getline():find("^\x202\x254\x186\x190") then
            return "stata"
        end
    end,
    ["smi"] = function()
        if util.getline():find("smil") then
            return "smil"
        else
            return "mib"
        end
    end,
    ["smil"] = function()
        if util.getline():find("<?%s*xml.*?>") then
            return "xml"
        else
            return "smil"
        end
    end,
    ["cls"] = function()
        local first_line = util.getline()
        if first_line:find("^%%") then
            return "tex"
        elseif first_line:sub(1, 1) == "#" and first_line:find("rexx") then
            return "rexx"
        else
            return "st"
        end
    end,
    ["install"] = function()
        if util.getline():find("%<%?php") then
            return "php"
        else
            return detect.sh({ fallback = "bash" })
        end
    end,
    ["decl"] = function()
        if util.getlines_as_string(0, 3, " "):find("^%<%!SGML") then
            return "sgmldecl"
        end
    end,
    ["sgm"] = function()
        return detect.sgml()
    end,
    ["sgml"] = function()
        return detect.sgml()
    end,
    ["reg"] = function()
        if
            util.getline():find(
                "^REGEDIT[0-9]*%s*$|^Windows Registry Editor Version %d*%.%d*%s*$"
            )
        then
            return "registry"
        end
    end,
    ["pm"] = function()
        if util.getline():find("XPM2") then
            return "xpm2"
        elseif util.getline():find("XPM") then
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
        if util.getline():find("^%s*%(%s*edif") then
            return "edif"
        else
            return "clojure"
        end
    end,
    ["rul"] = function()
        local top_file = util.getlines(0, 6)
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
        if util.getline():find("^%#%#") then
            return "python"
        else
            return "cobol"
        end
    end,
    -- Complicated functions
    ["asp"] = function()
        if vim.g.filetype_asp ~= nil then
            return vim.g.filetype_asp
        elseif util.getlines_as_string(0, 3, " "):find("perlscript") then
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
        if util.getline():find("^%/%*") then
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
        return detect.asm()
    end,
    ["s"] = function()
        return detect.asm()
    end,
    ["S"] = function()
        return detect.asm()
    end,
    ["a"] = function()
        return detect.asm()
    end,
    ["A"] = function()
        return detect.asm()
    end,
    ["mac"] = function()
        return detect.asm()
    end,
    ["lst"] = function()
        return detect.asm()
    end,
    ["bas"] = function()
        return detect.vbasic()
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
    ["ex"] = function()
        return detect.elixir_check()
    end,
    ["eu"] = function()
        return detect.euphoria_check()
    end,
    ["ew"] = function()
        return detect.euphoria_check()
    end,
    ["exu"] = function()
        return detect.euphoria_check()
    end,
    ["exw"] = function()
        return detect.euphoria_check()
    end,
    ["EU"] = function()
        return detect.euphoria_check()
    end,
    ["EW"] = function()
        return detect.euphoria_check()
    end,
    ["EX"] = function()
        return detect.euphoria_check()
    end,
    ["EXU"] = function()
        return detect.euphoria_check()
    end,
    ["EXW"] = function()
        return detect.euphoria_check()
    end,
    ["e"] = function()
        return detect.eiffel_check()
    end,
    ["E"] = function()
        return detect.eiffel_check()
    end,
    ["ent"] = function()
        return detect.eiffel_check()
    end,
    ["d"] = function()
        vim.cmd([[call dist#ft#DtraceCheck()]])
    end,
    ["com"] = function()
        vim.cmd([[call dist#ft#BindzoneCheck('dcl')]])
    end,
    ["html"] = function()
        return detect.html()
    end,
    ["htm"] = function()
        return detect.html()
    end,
    ["shtml"] = function()
        return detect.html()
    end,
    ["stm"] = function()
        return detect.html()
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
        return detect.sh({ fallback = "bash" })
    end,
    ["bash"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["eclass"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["ksh"] = function()
        return detect.sh({ fallback = "ksh" })
    end,
    ["etc/profile"] = function()
        return detect.sh({ fallback = "sh", force_shebang_check = true })
    end,
    ["sh"] = function()
        return detect.sh({ fallback = "sh", force_shebang_check = true })
    end,
    ["env"] = function()
        return detect.sh({ fallback = "sh", force_shebang_check = true })
    end,
    ["tcsh"] = function()
        return detect.sh({ fallback = "tcsh" })
    end,
    ["csh"] = function()
        return detect.csh()
    end,
    ["rules"] = function()
        vim.cmd([[call dist#ft#FTRules()]])
    end,
    ["sql"] = function()
        return detect.sql()
    end,
    ["tex"] = function(args)
        return detect.tex(args.file_path)
    end,
    ["frm"] = function()
        return detect.vbasic_form()
    end,
    ["xml"] = function()
        return detect.xml()
    end,
    ["y"] = function()
        vim.cmd([[call dist#ft#FTy()]])
    end,
    ["dtml"] = function()
        return detect.html()
    end,
    ["pt"] = function()
        return detect.html()
    end,
    ["cpt"] = function()
        return detect.html()
    end,
    ["zsql"] = function()
        return detect.sql()
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
        if util.getline():find("XConfigurator") then
            vim.b.xf86conf_xfree86_version = 3
        end
        return "xf86conf"
    end,
    ["INDEX"] = function()
        if
            util.getline():find(
                "^%s*(distribution|installed_software|root|bundle|product)%s*$"
            )
        then
            return "psf"
        end
    end,
    ["INFO"] = function()
        if
            util.getline():find(
                "^%s*(distribution|installed_software|root|bundle|product)%s*$"
            )
        then
            return "psf"
        end
    end,
    ["control"] = function()
        if util.getline():find("^Source%:") then
            return "debcontrol"
        end
    end,
    ["NEWS"] = function()
        if util.getline():find("%; urgency%=") then
            return "debchangelog"
        end
    end,
    ["indent.pro"] = function()
        vim.cmd([[call dist#ft#ProtoCheck('indent')]])
    end,
    [".bashrc"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["bashrc"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["bash.bashrc"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["PKGBUILD"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["APKBUILD"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    [".kshrc"] = function()
        return detect.sh({ fallback = "ksh" })
    end,
    [".profile"] = function()
        return detect.sh({ fallback = "sh", force_shebang_check = true })
    end,
    [".tcshrc"] = function()
        return detect.sh({ fallback = "tcsh" })
    end,
    ["tcsh.tcshrc"] = function()
        return detect.sh({ fallback = "tcsh" })
    end,
    ["tcsh.login"] = function()
        return detect.sh({ fallback = "tcsh" })
    end,
    [".login"] = function()
        return detect.csh()
    end,
    [".cshrc"] = function()
        return detect.csh()
    end,
    ["csh.cshrc"] = function()
        return detect.csh()
    end,
    ["csh.login"] = function()
        return detect.csh()
    end,
    ["csh.logout"] = function()
        return detect.csh()
    end,
    [".alias"] = function()
        return detect.csh()
    end,
    [".d"] = function()
        return detect.sh({ fallback = "bash" })
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
        if util.getline():find("%; urgency%=") then
            return "debchangelog"
        else
            return "changelog"
        end
    end,
    ["%.bashrc.*"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["%.bash[_-]profile"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["%.bash[_-]logout"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["%.bash[_-]aliases"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["%.bash%-fc[_-]"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["PKGBUILD.*"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["APKBUILD.*"] = function()
        return detect.sh({ fallback = "bash" })
    end,
    ["%.kshrc.*"] = function()
        return detect.sh({ fallback = "ksh" })
    end,
    ["%.profile.*"] = function()
        return detect.sh({ fallback = "sh", force_shebang_check = true })
    end,
    ["%.tcshrc.*"] = function()
        return detect.sh({ fallback = "tcsh" })
    end,
    ["%.login.*"] = function()
        return detect.csh()
    end,
    ["%.cshrc.*"] = function()
        return detect.csh()
    end,
}

return M
