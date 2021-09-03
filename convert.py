import pprint
import re

VIM_SCRIPT = "lua/filetype.vim"

lines = open(VIM_SCRIPT).readlines()


def find_normal_globs():
    ext_glob = re.compile(
        r"au\s+BufNewFile,BufRead\s+([\*\,\/\.\w]+)\s+setf\s+(\w+)"
    )
    asterisks = re.compile(r"\*")
    mapping: dict[str, str] = {}
    for line in lines:
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


def convert_glob_to_lua_regex(glob):
    glob = glob.replace(".", "%.")
    glob = glob.replace("*", ".*")
    return glob

    # ["*.git/modules/*/config",


# find_star_setfs()
# for r in regexes:
#     converted = convert_glob_to_lua_regex(r)
#     print(converted)

# import pyperclip

# print(convert_glob_to_lua_regex(pyperclip.paste()))

find_function_globs()
