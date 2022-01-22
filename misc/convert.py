"""This is the script I used to automatically convert most of the vim autocommands into lua.

Warning: This is crappy code. Please don't use this for anything! I only included this file
in case anyone was curious how I made the plugin.
"""

import pprint
import re

VIM_SCRIPT = "misc/filetype.vim"


def find_normal_globs():
    ext_glob = re.compile(r"au\s+BufNewFile,BufRead\s+([\+\*\,\/\.\w]+)\s+setf\s+(\w+)")
    asterisks = re.compile(r"\*")
    mapping: dict[str, str] = {}
    for line in lines:
        # if "cxx" in line:
        #     print(line)
        #     exit(1)
        match = ext_glob.search(line)
        if match is None:
            continue

        glob, ft = match.groups()
        for g in glob.split(","):
            mapping[g] = ft
            # print(f'["{g}"] = "{ft}"')

    # pprint.pprint(mapping)
    extensions: dict[str, str] = {}
    simple: dict[str, str] = {}
    complex: dict[str, str] = {}

    for glob, ft in mapping.items():
        num_asts = len(asterisks.findall(glob))
        if glob.startswith("*") and num_asts == 1:
            extensions[glob] = ft
        elif num_asts == 0:
            simple[glob] = ft

        else:
            complex[glob] = ft

    lua_print(simple)
    lua_print(extensions)
    lua_print(complex)


def find_function_cmds(flines):
    non_setf = re.compile(r"au\s+BufNewFile,BufRead\s+(\S+)\s*$")
    for line in flines:
        m = non_setf.search(line)
        if m is not None:
            print(m.group(1))
        elif "|" in line and "au" in line:
            print(line)


def find_star_setfs():
    star_glob = re.compile(
        r"au\s+BufNewFile,BufRead\s+(\S+)\s+call\s+s:StarSetf\('(\w+)'\)"
    )
    mappings: dict[str, str] = {}
    for line in lines:
        match = star_glob.search(line)
        if match is None:
            continue

        glob, ft = match.groups()
        mappings[glob] = ft

    for k, v in mappings.items():
        print(f"['{k}'] = '{v}',")


text = """M.star_sets = {
    [".*/etc/Muttrc%.d/.*"] = "muttrc",
    [".*/etc/proftpd/.*%.conf.*,.*/etc/proftpd/conf%..*/.*"] = "apachestyle",
    ["proftpd%.conf.*"] = "apachestyle",
    ["access%.conf.*,apache%.conf.*,apache2%.conf.*,httpd%.conf.*,srm%.conf.*"] = "apache",
    [".*/etc/apache2/.*%.conf.*,.*/etc/apache2/conf%..*/.*,.*/etc/apache2/mods-.*/.*,.*/etc/apache2/sites-.*/.*,.*/etc/httpd/conf%.d/.*%.conf.*"] = "apache",
    [".*asterisk/.*%.conf.*"] = "asterisk",
    [".*asterisk.*/.*voicemail%.conf.*"] = "asteriskvm",
    [".*/named/db%..*,.*/bind/db%..*"] = "bindzone",
    ["cabal%.project%..*"] = "cabalproject",
    ["crontab,crontab%..*,.*/etc/cron%.d/.*"] = "crontab",
    [".*/etc/dnsmasq%.d/.*"] = "dnsmasq",
    ["drac%..*"] = "dracula",
    [".*/%.fvwm/.*"] = "fvwm",
    [".*/tmp/lltmp.*"] = "gedcom",
    [".*/%.gitconfig%.d/.*,/etc/gitconfig%.d/.*"] = "gitconfig",
    [".*/gitolite-admin/conf/.*"] = "gitolite",
    ["%.gtkrc.*,gtkrc.*"] = "gtkrc",
    ["Prl.*%..*,JAM.*%..*"] = "jam",
    [".*%.properties_??_??_.*"] = "jproperties",
    ["Kconfig%..*"] = "kconfig",
    ["lilo%.conf.*"] = "lilo",
    [".*/etc/logcheck/.*%.d.*/.*"] = "logcheck",
    ["[mM]akefile.*"] = "make",
    ["[rR]akefile.*"] = "ruby",
    ["reportbug-.*"] = "mail",
    [".*/etc/modprobe%..*"] = "modconf",
    ["%.mutt{ng,}rc.*,.*/%.mutt{ng,}/mutt{ng,}rc.*"] = "muttrc",
    ["mutt{ng,}rc.*,Mutt{ng,}rc.*"] = "muttrc",
    ["%.neomuttrc.*,.*/%.neomutt/neomuttrc.*"] = "neomuttrc",
    ["neomuttrc.*,Neomuttrc.*"] = "neomuttrc",
    ["tmac%..*"] = "nroff",
    ["/etc/hostname%..*"] = "config",
    [".*/etc/pam%.d/.*"] = "pamconf",
    ["%.reminders.*"] = "remind",
    ["sgml%.catalog.*"] = "catalog",
    [".*%.vhdl_[0-9].*"] = "vhdl",
    [".*vimrc.*"] = "vim",
    ["Xresources.*,.*/app-defaults/.*,.*/Xresources/.*"] = "xdefaults",
    [".*xmodmap.*"] = "xmodmap",
    [".*/etc/xinetd%.d/.*"] = "xinetd",
    [".*/etc/yum%.repos%.d/.*"] = "dosini",
    ["%.zsh.*,%.zlog.*,%.zcompdump.*"] = "zsh",
    ["zsh.*,zlog.*"] = "zsh",
}"""
# def find_call_setfs():
#     star_glob = re.compile(r"au\s+BufNewFile,BufRead\s+(\S+)\s+call\s+(.+)")
#     mappings: dict[str, str] = {}
#     for line in lines:
#         match = star_glob.search(line)
#         if match is None:
#             continue

#         glob, ft = match.groups()
#         if "StarS" in ft:
#             continue
#         mappings[glob] = ft

#     extension = {}
#     literal = {}
#     complex = {}
#     for glob, ft in mappings.items():
#         num_asts = len(asterisks.findall(glob))
#         if glob.startswith('*') and num_asts == 1:

#         print(f"['{k}'] = [[call {v}]],")


def lua_print(d: dict):
    print("M.thing = {")
    for k, v in d.items():
        print(f"['{k}'] = [[{v}]],")
    print("}")


def find_function_globs():
    ext_glob = re.compile(r"au\s+BufNewFile,BufRead\s+(\S+)\s+call\s+(.+)")
    asterisks = re.compile(r"\*")
    mapping: dict[str, str] = {}
    for line in lines:
        match = ext_glob.search(line)

        if match is None:
            continue

        glob, ft = match.groups()
        if "s:Star" in ft:
            continue

        for g in glob.split(","):
            mapping[g] = ft

    extensions: dict[str, str] = {}
    simple: dict[str, str] = {}
    complex: dict[str, str] = {}

    for glob, ft in mapping.items():
        num_asts = len(asterisks.findall(glob))
        if glob.startswith("*") and num_asts == 1:
            extensions[glob] = ft
        elif num_asts == 0:
            simple[glob] = ft

        else:
            complex[glob] = ft

    lua_print(simple)
    lua_print(extensions)
    lua_print(complex)


def convert_glob_to_lua_regex(glob):
    glob = glob.replace(".", "%.")
    glob = glob.replace("*", ".*")
    return glob

    # ["*.git/modules/*/config",


def fix_lua_regexes(text):
    keyvals = re.compile(r'\["([^"]+)"\] = "([^"]+)"')
    matches = {}
    for line in text.split("\n"):
        result = keyvals.search(line)
        if result is None:
            continue

        glob, ft = result.groups()
        matches[glob] = ft

    fixed = {}
    for glob, ft in matches.items():
        if "{" not in glob:
            for pat in glob.split(","):
                fixed[pat] = ft
        else:
            fixed[glob] = ft
    lua_print(fixed)


def convert_lua_regex_vim(e):
    e = re.sub(r"%\.", r"\.", e)
    e = re.sub("/", r"\/", e)
    return e


def convert_lua_regexps_to_vim(flines):
    for line in flines:
        matches = re.search(r'"([^"]+)":', line)
        if matches is None:
            continue

        matches = matches.group(1)
        matches = re.sub(r"%\.", r"\.", matches)
        matches = re.sub("/", r"\/", matches)

        new_line = re.sub(r'"([^"]+)":', '"' + matches + '":', line)
        print(new_line.strip())


lines = open(VIM_SCRIPT).readlines()
find_function_cmds(lines)
