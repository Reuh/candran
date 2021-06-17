local function _() -- candran.can:2
local util = {} -- ./candran/util.can:1
util["search"] = function(modpath, exts) -- ./candran/util.can:3
if exts == nil then exts = {} end -- ./candran/util.can:3
for _, ext in ipairs(exts) do -- ./candran/util.can:4
for path in package["path"]:gmatch("[^;]+") do -- ./candran/util.can:5
local fpath = path:gsub("%.lua", "." .. ext):gsub("%?", (modpath:gsub("%.", "/"))) -- ./candran/util.can:6
local f = io["open"](fpath) -- ./candran/util.can:7
if f then -- ./candran/util.can:8
f:close() -- ./candran/util.can:9
return fpath -- ./candran/util.can:10
end -- ./candran/util.can:10
end -- ./candran/util.can:10
end -- ./candran/util.can:10
end -- ./candran/util.can:10
util["load"] = function(str, name, env) -- ./candran/util.can:16
if _VERSION == "Lua 5.1" then -- ./candran/util.can:17
local fn, err = loadstring(str, name) -- ./candran/util.can:18
if not fn then -- ./candran/util.can:19
return fn, err -- ./candran/util.can:19
end -- ./candran/util.can:19
return env ~= nil and setfenv(fn, env) or fn -- ./candran/util.can:20
else -- ./candran/util.can:20
if env then -- ./candran/util.can:22
return load(str, name, nil, env) -- ./candran/util.can:23
else -- ./candran/util.can:23
return load(str, name) -- ./candran/util.can:25
end -- ./candran/util.can:25
end -- ./candran/util.can:25
end -- ./candran/util.can:25
util["recmerge"] = function(...) -- ./candran/util.can:30
local r = {} -- ./candran/util.can:31
for _, t in ipairs({ ... }) do -- ./candran/util.can:32
for k, v in pairs(t) do -- ./candran/util.can:33
if type(v) == "table" then -- ./candran/util.can:34
r[k] = util["merge"](v, r[k]) -- ./candran/util.can:35
else -- ./candran/util.can:35
r[k] = v -- ./candran/util.can:37
end -- ./candran/util.can:37
end -- ./candran/util.can:37
end -- ./candran/util.can:37
return r -- ./candran/util.can:41
end -- ./candran/util.can:41
util["merge"] = function(...) -- ./candran/util.can:44
local r = {} -- ./candran/util.can:45
for _, t in ipairs({ ... }) do -- ./candran/util.can:46
for k, v in pairs(t) do -- ./candran/util.can:47
r[k] = v -- ./candran/util.can:48
end -- ./candran/util.can:48
end -- ./candran/util.can:48
return r -- ./candran/util.can:51
end -- ./candran/util.can:51
return util -- ./candran/util.can:54
end -- ./candran/util.can:54
local util = _() or util -- ./candran/util.can:58
package["loaded"]["candran.util"] = util or true -- ./candran/util.can:59
local function _() -- ./candran/util.can:62
local ipairs, pairs, setfenv, tonumber, loadstring, type = ipairs, pairs, setfenv, tonumber, loadstring, type -- ./candran/cmdline.lua:5
local tinsert, tconcat = table["insert"], table["concat"] -- ./candran/cmdline.lua:6
local function commonerror(msg) -- ./candran/cmdline.lua:8
return nil, ("[cmdline]: " .. msg) -- ./candran/cmdline.lua:9
end -- ./candran/cmdline.lua:9
local function argerror(msg, numarg) -- ./candran/cmdline.lua:12
msg = msg and (": " .. msg) or "" -- ./candran/cmdline.lua:13
return nil, ("[cmdline]: bad argument #" .. numarg .. msg) -- ./candran/cmdline.lua:14
end -- ./candran/cmdline.lua:14
local function iderror(numarg) -- ./candran/cmdline.lua:17
return argerror("ID not valid", numarg) -- ./candran/cmdline.lua:18
end -- ./candran/cmdline.lua:18
local function idcheck(id) -- ./candran/cmdline.lua:21
return id:match("^[%a_][%w_]*$") and true -- ./candran/cmdline.lua:22
end -- ./candran/cmdline.lua:22
return function(t_in, options, params) -- ./candran/cmdline.lua:73
local t_out = {} -- ./candran/cmdline.lua:74
for i, v in ipairs(t_in) do -- ./candran/cmdline.lua:75
local prefix, command = v:sub(1, 1), v:sub(2) -- ./candran/cmdline.lua:76
if prefix == "$" then -- ./candran/cmdline.lua:77
tinsert(t_out, command) -- ./candran/cmdline.lua:78
elseif prefix == "-" then -- ./candran/cmdline.lua:79
for id in command:gmatch("[^,;]+") do -- ./candran/cmdline.lua:80
if not idcheck(id) then -- ./candran/cmdline.lua:81
return iderror(i) -- ./candran/cmdline.lua:81
end -- ./candran/cmdline.lua:81
t_out[id] = true -- ./candran/cmdline.lua:82
end -- ./candran/cmdline.lua:82
elseif prefix == "!" then -- ./candran/cmdline.lua:84
local f, err = loadstring(command) -- ./candran/cmdline.lua:85
if not f then -- ./candran/cmdline.lua:86
return argerror(err, i) -- ./candran/cmdline.lua:86
end -- ./candran/cmdline.lua:86
setfenv(f, t_out)() -- ./candran/cmdline.lua:87
elseif v:find("=") then -- ./candran/cmdline.lua:88
local ids, val = v:match("^([^=]+)%=(.*)") -- ./candran/cmdline.lua:89
if not ids then -- ./candran/cmdline.lua:90
return argerror("invalid assignment syntax", i) -- ./candran/cmdline.lua:90
end -- ./candran/cmdline.lua:90
if val == "false" then -- ./candran/cmdline.lua:91
val = false -- ./candran/cmdline.lua:92
elseif val == "true" then -- ./candran/cmdline.lua:93
val = true -- ./candran/cmdline.lua:94
else -- ./candran/cmdline.lua:94
val = val:sub(1, 1) == "$" and val:sub(2) or tonumber(val) or val -- ./candran/cmdline.lua:96
end -- ./candran/cmdline.lua:96
for id in ids:gmatch("[^,;]+") do -- ./candran/cmdline.lua:98
if not idcheck(id) then -- ./candran/cmdline.lua:99
return iderror(i) -- ./candran/cmdline.lua:99
end -- ./candran/cmdline.lua:99
t_out[id] = val -- ./candran/cmdline.lua:100
end -- ./candran/cmdline.lua:100
else -- ./candran/cmdline.lua:100
tinsert(t_out, v) -- ./candran/cmdline.lua:103
end -- ./candran/cmdline.lua:103
end -- ./candran/cmdline.lua:103
if options then -- ./candran/cmdline.lua:106
local lookup, unknown = {}, {} -- ./candran/cmdline.lua:107
for _, v in ipairs(options) do -- ./candran/cmdline.lua:108
lookup[v] = true -- ./candran/cmdline.lua:108
end -- ./candran/cmdline.lua:108
for k, _ in pairs(t_out) do -- ./candran/cmdline.lua:109
if lookup[k] == nil and type(k) == "string" then -- ./candran/cmdline.lua:110
tinsert(unknown, k) -- ./candran/cmdline.lua:110
end -- ./candran/cmdline.lua:110
end -- ./candran/cmdline.lua:110
if # unknown > 0 then -- ./candran/cmdline.lua:112
return commonerror("unknown options: " .. tconcat(unknown, ", ")) -- ./candran/cmdline.lua:113
end -- ./candran/cmdline.lua:113
end -- ./candran/cmdline.lua:113
if params then -- ./candran/cmdline.lua:116
local missing = {} -- ./candran/cmdline.lua:117
for _, v in ipairs(params) do -- ./candran/cmdline.lua:118
if t_out[v] == nil then -- ./candran/cmdline.lua:119
tinsert(missing, v) -- ./candran/cmdline.lua:119
end -- ./candran/cmdline.lua:119
end -- ./candran/cmdline.lua:119
if # missing > 0 then -- ./candran/cmdline.lua:121
return commonerror("missing parameters: " .. tconcat(missing, ", ")) -- ./candran/cmdline.lua:122
end -- ./candran/cmdline.lua:122
end -- ./candran/cmdline.lua:122
return t_out -- ./candran/cmdline.lua:125
end -- ./candran/cmdline.lua:125
end -- ./candran/cmdline.lua:125
local cmdline = _() or cmdline -- ./candran/cmdline.lua:130
package["loaded"]["candran.cmdline"] = cmdline or true -- ./candran/cmdline.lua:131
local function _() -- ./candran/cmdline.lua:134
local n, v = "serpent", "0.302" -- ./candran/serpent.lua:24
local c, d = "Paul Kulchenko", "Lua serializer and pretty printer" -- ./candran/serpent.lua:25
local snum = { -- ./candran/serpent.lua:26
[tostring(1 / 0)] = "1/0 --[[math.huge]]", -- ./candran/serpent.lua:26
[tostring(- 1 / 0)] = "-1/0 --[[-math.huge]]", -- ./candran/serpent.lua:26
[tostring(0 / 0)] = "0/0" -- ./candran/serpent.lua:26
} -- ./candran/serpent.lua:26
local badtype = { -- ./candran/serpent.lua:27
["thread"] = true, -- ./candran/serpent.lua:27
["userdata"] = true, -- ./candran/serpent.lua:27
["cdata"] = true -- ./candran/serpent.lua:27
} -- ./candran/serpent.lua:27
local getmetatable = debug and debug["getmetatable"] or getmetatable -- ./candran/serpent.lua:28
local pairs = function(t) -- ./candran/serpent.lua:29
return next, t -- ./candran/serpent.lua:29
end -- ./candran/serpent.lua:29
local keyword, globals, G = {}, {}, (_G or _ENV) -- ./candran/serpent.lua:30
for _, k in ipairs({ -- ./candran/serpent.lua:31
"and", -- ./candran/serpent.lua:31
"break", -- ./candran/serpent.lua:31
"do", -- ./candran/serpent.lua:31
"else", -- ./candran/serpent.lua:31
"elseif", -- ./candran/serpent.lua:31
"end", -- ./candran/serpent.lua:31
"false", -- ./candran/serpent.lua:31
"for", -- ./candran/serpent.lua:32
"function", -- ./candran/serpent.lua:32
"goto", -- ./candran/serpent.lua:32
"if", -- ./candran/serpent.lua:32
"in", -- ./candran/serpent.lua:32
"local", -- ./candran/serpent.lua:32
"nil", -- ./candran/serpent.lua:32
"not", -- ./candran/serpent.lua:32
"or", -- ./candran/serpent.lua:32
"repeat", -- ./candran/serpent.lua:32
"return", -- ./candran/serpent.lua:33
"then", -- ./candran/serpent.lua:33
"true", -- ./candran/serpent.lua:33
"until", -- ./candran/serpent.lua:33
"while" -- ./candran/serpent.lua:33
}) do -- ./candran/serpent.lua:33
keyword[k] = true -- ./candran/serpent.lua:33
end -- ./candran/serpent.lua:33
for k, v in pairs(G) do -- ./candran/serpent.lua:34
globals[v] = k -- ./candran/serpent.lua:34
end -- ./candran/serpent.lua:34
for _, g in ipairs({ -- ./candran/serpent.lua:35
"coroutine", -- ./candran/serpent.lua:35
"debug", -- ./candran/serpent.lua:35
"io", -- ./candran/serpent.lua:35
"math", -- ./candran/serpent.lua:35
"string", -- ./candran/serpent.lua:35
"table", -- ./candran/serpent.lua:35
"os" -- ./candran/serpent.lua:35
}) do -- ./candran/serpent.lua:35
for k, v in pairs(type(G[g]) == "table" and G[g] or {}) do -- ./candran/serpent.lua:36
globals[v] = g .. "." .. k -- ./candran/serpent.lua:36
end -- ./candran/serpent.lua:36
end -- ./candran/serpent.lua:36
local function s(t, opts) -- ./candran/serpent.lua:38
local name, indent, fatal, maxnum = opts["name"], opts["indent"], opts["fatal"], opts["maxnum"] -- ./candran/serpent.lua:39
local sparse, custom, huge = opts["sparse"], opts["custom"], not opts["nohuge"] -- ./candran/serpent.lua:40
local space, maxl = (opts["compact"] and "" or " "), (opts["maxlevel"] or math["huge"]) -- ./candran/serpent.lua:41
local maxlen, metatostring = tonumber(opts["maxlength"]), opts["metatostring"] -- ./candran/serpent.lua:42
local iname, comm = "_" .. (name or ""), opts["comment"] and (tonumber(opts["comment"]) or math["huge"]) -- ./candran/serpent.lua:43
local numformat = opts["numformat"] or "%.17g" -- ./candran/serpent.lua:44
local seen, sref, syms, symn = {}, { "local " .. iname .. "={}" }, {}, 0 -- ./candran/serpent.lua:45
local function gensym(val) -- ./candran/serpent.lua:46
return "_" .. (tostring(tostring(val)):gsub("[^%w]", ""):gsub("(%d%w+)", function(s) -- ./candran/serpent.lua:48
if not syms[s] then -- ./candran/serpent.lua:48
symn = symn + 1 -- ./candran/serpent.lua:48
syms[s] = symn -- ./candran/serpent.lua:48
end -- ./candran/serpent.lua:48
return tostring(syms[s]) -- ./candran/serpent.lua:48
end)) -- ./candran/serpent.lua:48
end -- ./candran/serpent.lua:48
local function safestr(s) -- ./candran/serpent.lua:49
return type(s) == "number" and tostring(huge and snum[tostring(s)] or numformat:format(s)) or type(s) ~= "string" and tostring(s) or ("%q"):format(s):gsub("\
", "n"):gsub("\26", "\\026") -- ./candran/serpent.lua:51
end -- ./candran/serpent.lua:51
local function comment(s, l) -- ./candran/serpent.lua:52
return comm and (l or 0) < comm and " --[[" .. select(2, pcall(tostring, s)) .. "]]" or "" -- ./candran/serpent.lua:52
end -- ./candran/serpent.lua:52
local function globerr(s, l) -- ./candran/serpent.lua:53
return globals[s] and globals[s] .. comment(s, l) or not fatal and safestr(select(2, pcall(tostring, s))) or error("Can't serialize " .. tostring(s)) -- ./candran/serpent.lua:54
end -- ./candran/serpent.lua:54
local function safename(path, name) -- ./candran/serpent.lua:55
local n = name == nil and "" or name -- ./candran/serpent.lua:56
local plain = type(n) == "string" and n:match("^[%l%u_][%w_]*$") and not keyword[n] -- ./candran/serpent.lua:57
local safe = plain and n or "[" .. safestr(n) .. "]" -- ./candran/serpent.lua:58
return (path or "") .. (plain and path and "." or "") .. safe, safe -- ./candran/serpent.lua:59
end -- ./candran/serpent.lua:59
local alphanumsort = type(opts["sortkeys"]) == "function" and opts["sortkeys"] or function(k, o, n) -- ./candran/serpent.lua:60
local maxn, to = tonumber(n) or 12, { -- ./candran/serpent.lua:61
["number"] = "a", -- ./candran/serpent.lua:61
["string"] = "b" -- ./candran/serpent.lua:61
} -- ./candran/serpent.lua:61
local function padnum(d) -- ./candran/serpent.lua:62
return ("%0" .. tostring(maxn) .. "d"):format(tonumber(d)) -- ./candran/serpent.lua:62
end -- ./candran/serpent.lua:62
table["sort"](k, function(a, b) -- ./candran/serpent.lua:63
return (k[a] ~= nil and 0 or to[type(a)] or "z") .. (tostring(a):gsub("%d+", padnum)) < (k[b] ~= nil and 0 or to[type(b)] or "z") .. (tostring(b):gsub("%d+", padnum)) -- ./candran/serpent.lua:66
end) -- ./candran/serpent.lua:66
end -- ./candran/serpent.lua:66
local function val2str(t, name, indent, insref, path, plainindex, level) -- ./candran/serpent.lua:67
local ttype, level, mt = type(t), (level or 0), getmetatable(t) -- ./candran/serpent.lua:68
local spath, sname = safename(path, name) -- ./candran/serpent.lua:69
local tag = plainindex and ((type(name) == "number") and "" or name .. space .. "=" .. space) or (name ~= nil and sname .. space .. "=" .. space or "") -- ./candran/serpent.lua:72
if seen[t] then -- ./candran/serpent.lua:73
sref[# sref + 1] = spath .. space .. "=" .. space .. seen[t] -- ./candran/serpent.lua:74
return tag .. "nil" .. comment("ref", level) -- ./candran/serpent.lua:75
end -- ./candran/serpent.lua:75
if type(mt) == "table" and metatostring ~= false then -- ./candran/serpent.lua:77
local to, tr = pcall(function() -- ./candran/serpent.lua:78
return mt["__tostring"](t) -- ./candran/serpent.lua:78
end) -- ./candran/serpent.lua:78
local so, sr = pcall(function() -- ./candran/serpent.lua:79
return mt["__serialize"](t) -- ./candran/serpent.lua:79
end) -- ./candran/serpent.lua:79
if (to or so) then -- ./candran/serpent.lua:80
seen[t] = insref or spath -- ./candran/serpent.lua:81
t = so and sr or tr -- ./candran/serpent.lua:82
ttype = type(t) -- ./candran/serpent.lua:83
end -- ./candran/serpent.lua:83
end -- ./candran/serpent.lua:83
if ttype == "table" then -- ./candran/serpent.lua:86
if level >= maxl then -- ./candran/serpent.lua:87
return tag .. "{}" .. comment("maxlvl", level) -- ./candran/serpent.lua:87
end -- ./candran/serpent.lua:87
seen[t] = insref or spath -- ./candran/serpent.lua:88
if next(t) == nil then -- ./candran/serpent.lua:89
return tag .. "{}" .. comment(t, level) -- ./candran/serpent.lua:89
end -- ./candran/serpent.lua:89
if maxlen and maxlen < 0 then -- ./candran/serpent.lua:90
return tag .. "{}" .. comment("maxlen", level) -- ./candran/serpent.lua:90
end -- ./candran/serpent.lua:90
local maxn, o, out = math["min"](# t, maxnum or # t), {}, {} -- ./candran/serpent.lua:91
for key = 1, maxn do -- ./candran/serpent.lua:92
o[key] = key -- ./candran/serpent.lua:92
end -- ./candran/serpent.lua:92
if not maxnum or # o < maxnum then -- ./candran/serpent.lua:93
local n = # o -- ./candran/serpent.lua:94
for key in pairs(t) do -- ./candran/serpent.lua:95
if o[key] ~= key then -- ./candran/serpent.lua:95
n = n + 1 -- ./candran/serpent.lua:95
o[n] = key -- ./candran/serpent.lua:95
end -- ./candran/serpent.lua:95
end -- ./candran/serpent.lua:95
end -- ./candran/serpent.lua:95
if maxnum and # o > maxnum then -- ./candran/serpent.lua:96
o[maxnum + 1] = nil -- ./candran/serpent.lua:96
end -- ./candran/serpent.lua:96
if opts["sortkeys"] and # o > maxn then -- ./candran/serpent.lua:97
alphanumsort(o, t, opts["sortkeys"]) -- ./candran/serpent.lua:97
end -- ./candran/serpent.lua:97
local sparse = sparse and # o > maxn -- ./candran/serpent.lua:98
for n, key in ipairs(o) do -- ./candran/serpent.lua:99
local value, ktype, plainindex = t[key], type(key), n <= maxn and not sparse -- ./candran/serpent.lua:100
if opts["valignore"] and opts["valignore"][value] or opts["keyallow"] and not opts["keyallow"][key] or opts["keyignore"] and opts["keyignore"][key] or opts["valtypeignore"] and opts["valtypeignore"][type(value)] or sparse and value == nil then -- ./candran/serpent.lua:105
 -- ./candran/serpent.lua:106
elseif ktype == "table" or ktype == "function" or badtype[ktype] then -- ./candran/serpent.lua:106
if not seen[key] and not globals[key] then -- ./candran/serpent.lua:107
sref[# sref + 1] = "placeholder" -- ./candran/serpent.lua:108
local sname = safename(iname, gensym(key)) -- ./candran/serpent.lua:109
sref[# sref] = val2str(key, sname, indent, sname, iname, true) -- ./candran/serpent.lua:110
end -- ./candran/serpent.lua:110
sref[# sref + 1] = "placeholder" -- ./candran/serpent.lua:111
local path = seen[t] .. "[" .. tostring(seen[key] or globals[key] or gensym(key)) .. "]" -- ./candran/serpent.lua:112
sref[# sref] = path .. space .. "=" .. space .. tostring(seen[value] or val2str(value, nil, indent, path)) -- ./candran/serpent.lua:113
else -- ./candran/serpent.lua:113
out[# out + 1] = val2str(value, key, indent, nil, seen[t], plainindex, level + 1) -- ./candran/serpent.lua:115
if maxlen then -- ./candran/serpent.lua:116
maxlen = maxlen - # out[# out] -- ./candran/serpent.lua:117
if maxlen < 0 then -- ./candran/serpent.lua:118
break -- ./candran/serpent.lua:118
end -- ./candran/serpent.lua:118
end -- ./candran/serpent.lua:118
end -- ./candran/serpent.lua:118
end -- ./candran/serpent.lua:118
local prefix = string["rep"](indent or "", level) -- ./candran/serpent.lua:122
local head = indent and "{\
" .. prefix .. indent or "{" -- ./candran/serpent.lua:123
local body = table["concat"](out, "," .. (indent and "\
" .. prefix .. indent or space)) -- ./candran/serpent.lua:124
local tail = indent and "\
" .. prefix .. "}" or "}" -- ./candran/serpent.lua:125
return (custom and custom(tag, head, body, tail, level) or tag .. head .. body .. tail) .. comment(t, level) -- ./candran/serpent.lua:126
elseif badtype[ttype] then -- ./candran/serpent.lua:127
seen[t] = insref or spath -- ./candran/serpent.lua:128
return tag .. globerr(t, level) -- ./candran/serpent.lua:129
elseif ttype == "function" then -- ./candran/serpent.lua:130
seen[t] = insref or spath -- ./candran/serpent.lua:131
if opts["nocode"] then -- ./candran/serpent.lua:132
return tag .. "function() --[[..skipped..]] end" .. comment(t, level) -- ./candran/serpent.lua:132
end -- ./candran/serpent.lua:132
local ok, res = pcall(string["dump"], t) -- ./candran/serpent.lua:133
local func = ok and "((loadstring or load)(" .. safestr(res) .. ",'@serialized'))" .. comment(t, level) -- ./candran/serpent.lua:134
return tag .. (func or globerr(t, level)) -- ./candran/serpent.lua:135
else -- ./candran/serpent.lua:135
return tag .. safestr(t) -- ./candran/serpent.lua:136
end -- ./candran/serpent.lua:136
end -- ./candran/serpent.lua:136
local sepr = indent and "\
" or ";" .. space -- ./candran/serpent.lua:138
local body = val2str(t, name, indent) -- ./candran/serpent.lua:139
local tail = # sref > 1 and table["concat"](sref, sepr) .. sepr or "" -- ./candran/serpent.lua:140
local warn = opts["comment"] and # sref > 1 and space .. "--[[incomplete output with shared/self-references skipped]]" or "" -- ./candran/serpent.lua:141
return not name and body .. warn or "do local " .. body .. sepr .. tail .. "return " .. name .. sepr .. "end" -- ./candran/serpent.lua:142
end -- ./candran/serpent.lua:142
local function deserialize(data, opts) -- ./candran/serpent.lua:145
local env = (opts and opts["safe"] == false) and G or setmetatable({}, { -- ./candran/serpent.lua:147
["__index"] = function(t, k) -- ./candran/serpent.lua:148
return t -- ./candran/serpent.lua:148
end, -- ./candran/serpent.lua:148
["__call"] = function(t, ...) -- ./candran/serpent.lua:149
error("cannot call functions") -- ./candran/serpent.lua:149
end -- ./candran/serpent.lua:149
}) -- ./candran/serpent.lua:149
local f, res = (loadstring or load)("return " .. data, nil, nil, env) -- ./candran/serpent.lua:151
if not f then -- ./candran/serpent.lua:152
f, res = (loadstring or load)(data, nil, nil, env) -- ./candran/serpent.lua:152
end -- ./candran/serpent.lua:152
if not f then -- ./candran/serpent.lua:153
return f, res -- ./candran/serpent.lua:153
end -- ./candran/serpent.lua:153
if setfenv then -- ./candran/serpent.lua:154
setfenv(f, env) -- ./candran/serpent.lua:154
end -- ./candran/serpent.lua:154
return pcall(f) -- ./candran/serpent.lua:155
end -- ./candran/serpent.lua:155
local function merge(a, b) -- ./candran/serpent.lua:158
if b then -- ./candran/serpent.lua:158
for k, v in pairs(b) do -- ./candran/serpent.lua:158
a[k] = v -- ./candran/serpent.lua:158
end -- ./candran/serpent.lua:158
end -- ./candran/serpent.lua:158
return a -- ./candran/serpent.lua:158
end -- ./candran/serpent.lua:158
return { -- ./candran/serpent.lua:159
["_NAME"] = n, -- ./candran/serpent.lua:159
["_COPYRIGHT"] = c, -- ./candran/serpent.lua:159
["_DESCRIPTION"] = d, -- ./candran/serpent.lua:159
["_VERSION"] = v, -- ./candran/serpent.lua:159
["serialize"] = s, -- ./candran/serpent.lua:159
["load"] = deserialize, -- ./candran/serpent.lua:160
["dump"] = function(a, opts) -- ./candran/serpent.lua:161
return s(a, merge({ -- ./candran/serpent.lua:161
["name"] = "_", -- ./candran/serpent.lua:161
["compact"] = true, -- ./candran/serpent.lua:161
["sparse"] = true -- ./candran/serpent.lua:161
}, opts)) -- ./candran/serpent.lua:161
end, -- ./candran/serpent.lua:161
["line"] = function(a, opts) -- ./candran/serpent.lua:162
return s(a, merge({ -- ./candran/serpent.lua:162
["sortkeys"] = true, -- ./candran/serpent.lua:162
["comment"] = true -- ./candran/serpent.lua:162
}, opts)) -- ./candran/serpent.lua:162
end, -- ./candran/serpent.lua:162
["block"] = function(a, opts) -- ./candran/serpent.lua:163
return s(a, merge({ -- ./candran/serpent.lua:163
["indent"] = "  ", -- ./candran/serpent.lua:163
["sortkeys"] = true, -- ./candran/serpent.lua:163
["comment"] = true -- ./candran/serpent.lua:163
}, opts)) -- ./candran/serpent.lua:163
end -- ./candran/serpent.lua:163
} -- ./candran/serpent.lua:163
end -- ./candran/serpent.lua:163
local serpent = _() or serpent -- ./candran/serpent.lua:167
package["loaded"]["candran.serpent"] = serpent or true -- ./candran/serpent.lua:168
local function _() -- ./candran/serpent.lua:172
local util = require("candran.util") -- ./compiler/lua54.can:1
local targetName = "Lua 5.4" -- ./compiler/lua54.can:3
local unpack = unpack or table["unpack"] -- ./compiler/lua54.can:5
return function(code, ast, options, macros) -- ./compiler/lua54.can:7
if macros == nil then macros = { -- ./compiler/lua54.can:7
["functions"] = {}, -- ./compiler/lua54.can:7
["variables"] = {} -- ./compiler/lua54.can:7
} end -- ./compiler/lua54.can:7
local lastInputPos = 1 -- ./compiler/lua54.can:9
local prevLinePos = 1 -- ./compiler/lua54.can:10
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua54.can:11
local lastLine = 1 -- ./compiler/lua54.can:12
local indentLevel = 0 -- ./compiler/lua54.can:15
local function newline() -- ./compiler/lua54.can:17
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua54.can:18
if options["mapLines"] then -- ./compiler/lua54.can:19
local sub = code:sub(lastInputPos) -- ./compiler/lua54.can:20
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua54.can:21
if source and line then -- ./compiler/lua54.can:23
lastSource = source -- ./compiler/lua54.can:24
lastLine = tonumber(line) -- ./compiler/lua54.can:25
else -- ./compiler/lua54.can:25
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua54.can:27
lastLine = lastLine + (1) -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
prevLinePos = lastInputPos -- ./compiler/lua54.can:32
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua54.can:34
end -- ./compiler/lua54.can:34
return r -- ./compiler/lua54.can:36
end -- ./compiler/lua54.can:36
local function indent() -- ./compiler/lua54.can:39
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:40
return newline() -- ./compiler/lua54.can:41
end -- ./compiler/lua54.can:41
local function unindent() -- ./compiler/lua54.can:44
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:45
return newline() -- ./compiler/lua54.can:46
end -- ./compiler/lua54.can:46
local states = { -- ./compiler/lua54.can:51
["push"] = {}, -- ./compiler/lua54.can:52
["destructuring"] = {}, -- ./compiler/lua54.can:53
["scope"] = {}, -- ./compiler/lua54.can:54
["macroargs"] = {} -- ./compiler/lua54.can:55
} -- ./compiler/lua54.can:55
local function push(name, state) -- ./compiler/lua54.can:58
table["insert"](states[name], state) -- ./compiler/lua54.can:59
return "" -- ./compiler/lua54.can:60
end -- ./compiler/lua54.can:60
local function pop(name) -- ./compiler/lua54.can:63
table["remove"](states[name]) -- ./compiler/lua54.can:64
return "" -- ./compiler/lua54.can:65
end -- ./compiler/lua54.can:65
local function set(name, state) -- ./compiler/lua54.can:68
states[name][# states[name]] = state -- ./compiler/lua54.can:69
return "" -- ./compiler/lua54.can:70
end -- ./compiler/lua54.can:70
local function peek(name) -- ./compiler/lua54.can:73
return states[name][# states[name]] -- ./compiler/lua54.can:74
end -- ./compiler/lua54.can:74
local function var(name) -- ./compiler/lua54.can:79
return options["variablePrefix"] .. name -- ./compiler/lua54.can:80
end -- ./compiler/lua54.can:80
local function tmp() -- ./compiler/lua54.can:84
local scope = peek("scope") -- ./compiler/lua54.can:85
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua54.can:86
table["insert"](scope, var) -- ./compiler/lua54.can:87
return var -- ./compiler/lua54.can:88
end -- ./compiler/lua54.can:88
local nomacro = { -- ./compiler/lua54.can:92
["variables"] = {}, -- ./compiler/lua54.can:92
["functions"] = {} -- ./compiler/lua54.can:92
} -- ./compiler/lua54.can:92
local required = {} -- ./compiler/lua54.can:95
local requireStr = "" -- ./compiler/lua54.can:96
local function addRequire(mod, name, field) -- ./compiler/lua54.can:98
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua54.can:99
if not required[req] then -- ./compiler/lua54.can:100
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua54.can:101
required[req] = true -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
local loop = { -- ./compiler/lua54.can:107
"While", -- ./compiler/lua54.can:107
"Repeat", -- ./compiler/lua54.can:107
"Fornum", -- ./compiler/lua54.can:107
"Forin", -- ./compiler/lua54.can:107
"WhileExpr", -- ./compiler/lua54.can:107
"RepeatExpr", -- ./compiler/lua54.can:107
"FornumExpr", -- ./compiler/lua54.can:107
"ForinExpr" -- ./compiler/lua54.can:107
} -- ./compiler/lua54.can:107
local func = { -- ./compiler/lua54.can:108
"Function", -- ./compiler/lua54.can:108
"TableCompr", -- ./compiler/lua54.can:108
"DoExpr", -- ./compiler/lua54.can:108
"WhileExpr", -- ./compiler/lua54.can:108
"RepeatExpr", -- ./compiler/lua54.can:108
"IfExpr", -- ./compiler/lua54.can:108
"FornumExpr", -- ./compiler/lua54.can:108
"ForinExpr" -- ./compiler/lua54.can:108
} -- ./compiler/lua54.can:108
local function any(list, tags, nofollow) -- ./compiler/lua54.can:112
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:112
local tagsCheck = {} -- ./compiler/lua54.can:113
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:114
tagsCheck[tag] = true -- ./compiler/lua54.can:115
end -- ./compiler/lua54.can:115
local nofollowCheck = {} -- ./compiler/lua54.can:117
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:118
nofollowCheck[tag] = true -- ./compiler/lua54.can:119
end -- ./compiler/lua54.can:119
for _, node in ipairs(list) do -- ./compiler/lua54.can:121
if type(node) == "table" then -- ./compiler/lua54.can:122
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:123
return node -- ./compiler/lua54.can:124
end -- ./compiler/lua54.can:124
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:126
local r = any(node, tags, nofollow) -- ./compiler/lua54.can:127
if r then -- ./compiler/lua54.can:128
return r -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
return nil -- ./compiler/lua54.can:132
end -- ./compiler/lua54.can:132
local function search(list, tags, nofollow) -- ./compiler/lua54.can:137
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:137
local tagsCheck = {} -- ./compiler/lua54.can:138
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:139
tagsCheck[tag] = true -- ./compiler/lua54.can:140
end -- ./compiler/lua54.can:140
local nofollowCheck = {} -- ./compiler/lua54.can:142
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:143
nofollowCheck[tag] = true -- ./compiler/lua54.can:144
end -- ./compiler/lua54.can:144
local found = {} -- ./compiler/lua54.can:146
for _, node in ipairs(list) do -- ./compiler/lua54.can:147
if type(node) == "table" then -- ./compiler/lua54.can:148
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:149
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua54.can:150
table["insert"](found, n) -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:154
table["insert"](found, node) -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
return found -- ./compiler/lua54.can:159
end -- ./compiler/lua54.can:159
local function all(list, tags) -- ./compiler/lua54.can:163
for _, node in ipairs(list) do -- ./compiler/lua54.can:164
local ok = false -- ./compiler/lua54.can:165
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:166
if node["tag"] == tag then -- ./compiler/lua54.can:167
ok = true -- ./compiler/lua54.can:168
break -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
if not ok then -- ./compiler/lua54.can:172
return false -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
return true -- ./compiler/lua54.can:176
end -- ./compiler/lua54.can:176
local tags -- ./compiler/lua54.can:180
local function lua(ast, forceTag, ...) -- ./compiler/lua54.can:182
if options["mapLines"] and ast["pos"] then -- ./compiler/lua54.can:183
lastInputPos = ast["pos"] -- ./compiler/lua54.can:184
end -- ./compiler/lua54.can:184
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua54.can:186
end -- ./compiler/lua54.can:186
local UNPACK = function(list, i, j) -- ./compiler/lua54.can:190
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua54.can:191
end -- ./compiler/lua54.can:191
local APPEND = function(t, toAppend) -- ./compiler/lua54.can:193
return "do" .. indent() .. "local " .. var("a") .. " = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(" .. var("a") .. ", 1, " .. var("a") .. ".n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua54.can:194
end -- ./compiler/lua54.can:194
local CONTINUE_START = function() -- ./compiler/lua54.can:196
return "do" .. indent() -- ./compiler/lua54.can:197
end -- ./compiler/lua54.can:197
local CONTINUE_STOP = function() -- ./compiler/lua54.can:199
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua54.can:200
end -- ./compiler/lua54.can:200
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua54.can:202
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua54.can:202
if noLocal == nil then noLocal = false end -- ./compiler/lua54.can:202
local vars = {} -- ./compiler/lua54.can:203
local values = {} -- ./compiler/lua54.can:204
for _, list in ipairs(destructured) do -- ./compiler/lua54.can:205
for _, v in ipairs(list) do -- ./compiler/lua54.can:206
local var, val -- ./compiler/lua54.can:207
if v["tag"] == "Id" or v["tag"] == "AttributeId" then -- ./compiler/lua54.can:208
var = v -- ./compiler/lua54.can:209
val = { -- ./compiler/lua54.can:210
["tag"] = "Index", -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "Id", -- ./compiler/lua54.can:210
list["id"] -- ./compiler/lua54.can:210
}, -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "String", -- ./compiler/lua54.can:210
v[1] -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
elseif v["tag"] == "Pair" then -- ./compiler/lua54.can:211
var = v[2] -- ./compiler/lua54.can:212
val = { -- ./compiler/lua54.can:213
["tag"] = "Index", -- ./compiler/lua54.can:213
{ -- ./compiler/lua54.can:213
["tag"] = "Id", -- ./compiler/lua54.can:213
list["id"] -- ./compiler/lua54.can:213
}, -- ./compiler/lua54.can:213
v[1] -- ./compiler/lua54.can:213
} -- ./compiler/lua54.can:213
else -- ./compiler/lua54.can:213
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua54.can:215
end -- ./compiler/lua54.can:215
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua54.can:217
val = { -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["rightOp"], -- ./compiler/lua54.can:218
var, -- ./compiler/lua54.can:218
{ -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["leftOp"], -- ./compiler/lua54.can:218
val, -- ./compiler/lua54.can:218
var -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
elseif destructured["rightOp"] then -- ./compiler/lua54.can:219
val = { -- ./compiler/lua54.can:220
["tag"] = "Op", -- ./compiler/lua54.can:220
destructured["rightOp"], -- ./compiler/lua54.can:220
var, -- ./compiler/lua54.can:220
val -- ./compiler/lua54.can:220
} -- ./compiler/lua54.can:220
elseif destructured["leftOp"] then -- ./compiler/lua54.can:221
val = { -- ./compiler/lua54.can:222
["tag"] = "Op", -- ./compiler/lua54.can:222
destructured["leftOp"], -- ./compiler/lua54.can:222
val, -- ./compiler/lua54.can:222
var -- ./compiler/lua54.can:222
} -- ./compiler/lua54.can:222
end -- ./compiler/lua54.can:222
table["insert"](vars, lua(var)) -- ./compiler/lua54.can:224
table["insert"](values, lua(val)) -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
if # vars > 0 then -- ./compiler/lua54.can:228
local decl = noLocal and "" or "local " -- ./compiler/lua54.can:229
if newlineAfter then -- ./compiler/lua54.can:230
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua54.can:231
else -- ./compiler/lua54.can:231
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua54.can:233
end -- ./compiler/lua54.can:233
else -- ./compiler/lua54.can:233
return "" -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
tags = setmetatable({ -- ./compiler/lua54.can:241
["Block"] = function(t) -- ./compiler/lua54.can:243
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua54.can:244
if hasPush and hasPush == t[# t] then -- ./compiler/lua54.can:245
hasPush["tag"] = "Return" -- ./compiler/lua54.can:246
hasPush = false -- ./compiler/lua54.can:247
end -- ./compiler/lua54.can:247
local r = push("scope", {}) -- ./compiler/lua54.can:249
if hasPush then -- ./compiler/lua54.can:250
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:251
end -- ./compiler/lua54.can:251
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:253
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua54.can:254
end -- ./compiler/lua54.can:254
if t[# t] then -- ./compiler/lua54.can:256
r = r .. (lua(t[# t])) -- ./compiler/lua54.can:257
end -- ./compiler/lua54.can:257
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua54.can:259
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua54.can:260
end -- ./compiler/lua54.can:260
return r .. pop("scope") -- ./compiler/lua54.can:262
end, -- ./compiler/lua54.can:262
["Do"] = function(t) -- ./compiler/lua54.can:268
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua54.can:269
end, -- ./compiler/lua54.can:269
["Set"] = function(t) -- ./compiler/lua54.can:272
local expr = t[# t] -- ./compiler/lua54.can:274
local vars, values = {}, {} -- ./compiler/lua54.can:275
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua54.can:276
for i, n in ipairs(t[1]) do -- ./compiler/lua54.can:277
if n["tag"] == "DestructuringId" then -- ./compiler/lua54.can:278
table["insert"](destructuringVars, n) -- ./compiler/lua54.can:279
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua54.can:280
else -- ./compiler/lua54.can:280
table["insert"](vars, n) -- ./compiler/lua54.can:282
table["insert"](values, expr[i]) -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
if # t == 2 or # t == 3 then -- ./compiler/lua54.can:287
local r = "" -- ./compiler/lua54.can:288
if # vars > 0 then -- ./compiler/lua54.can:289
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua54.can:290
end -- ./compiler/lua54.can:290
if # destructuringVars > 0 then -- ./compiler/lua54.can:292
local destructured = {} -- ./compiler/lua54.can:293
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:294
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:295
end -- ./compiler/lua54.can:295
return r -- ./compiler/lua54.can:297
elseif # t == 4 then -- ./compiler/lua54.can:298
if t[3] == "=" then -- ./compiler/lua54.can:299
local r = "" -- ./compiler/lua54.can:300
if # vars > 0 then -- ./compiler/lua54.can:301
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:302
t[2], -- ./compiler/lua54.can:302
vars[1], -- ./compiler/lua54.can:302
{ -- ./compiler/lua54.can:302
["tag"] = "Paren", -- ./compiler/lua54.can:302
values[1] -- ./compiler/lua54.can:302
} -- ./compiler/lua54.can:302
}, "Op")) -- ./compiler/lua54.can:302
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua54.can:303
r = r .. (", " .. lua({ -- ./compiler/lua54.can:304
t[2], -- ./compiler/lua54.can:304
vars[i], -- ./compiler/lua54.can:304
{ -- ./compiler/lua54.can:304
["tag"] = "Paren", -- ./compiler/lua54.can:304
values[i] -- ./compiler/lua54.can:304
} -- ./compiler/lua54.can:304
}, "Op")) -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
if # destructuringVars > 0 then -- ./compiler/lua54.can:307
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua54.can:308
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:309
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:310
end -- ./compiler/lua54.can:310
return r -- ./compiler/lua54.can:312
else -- ./compiler/lua54.can:312
local r = "" -- ./compiler/lua54.can:314
if # vars > 0 then -- ./compiler/lua54.can:315
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:316
t[3], -- ./compiler/lua54.can:316
{ -- ./compiler/lua54.can:316
["tag"] = "Paren", -- ./compiler/lua54.can:316
values[1] -- ./compiler/lua54.can:316
}, -- ./compiler/lua54.can:316
vars[1] -- ./compiler/lua54.can:316
}, "Op")) -- ./compiler/lua54.can:316
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua54.can:317
r = r .. (", " .. lua({ -- ./compiler/lua54.can:318
t[3], -- ./compiler/lua54.can:318
{ -- ./compiler/lua54.can:318
["tag"] = "Paren", -- ./compiler/lua54.can:318
values[i] -- ./compiler/lua54.can:318
}, -- ./compiler/lua54.can:318
vars[i] -- ./compiler/lua54.can:318
}, "Op")) -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
if # destructuringVars > 0 then -- ./compiler/lua54.can:321
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua54.can:322
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:323
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:324
end -- ./compiler/lua54.can:324
return r -- ./compiler/lua54.can:326
end -- ./compiler/lua54.can:326
else -- ./compiler/lua54.can:326
local r = "" -- ./compiler/lua54.can:329
if # vars > 0 then -- ./compiler/lua54.can:330
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:331
t[2], -- ./compiler/lua54.can:331
vars[1], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Op", -- ./compiler/lua54.can:331
t[4], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Paren", -- ./compiler/lua54.can:331
values[1] -- ./compiler/lua54.can:331
}, -- ./compiler/lua54.can:331
vars[1] -- ./compiler/lua54.can:331
} -- ./compiler/lua54.can:331
}, "Op")) -- ./compiler/lua54.can:331
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua54.can:332
r = r .. (", " .. lua({ -- ./compiler/lua54.can:333
t[2], -- ./compiler/lua54.can:333
vars[i], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Op", -- ./compiler/lua54.can:333
t[4], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Paren", -- ./compiler/lua54.can:333
values[i] -- ./compiler/lua54.can:333
}, -- ./compiler/lua54.can:333
vars[i] -- ./compiler/lua54.can:333
} -- ./compiler/lua54.can:333
}, "Op")) -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
if # destructuringVars > 0 then -- ./compiler/lua54.can:336
local destructured = { -- ./compiler/lua54.can:337
["rightOp"] = t[2], -- ./compiler/lua54.can:337
["leftOp"] = t[4] -- ./compiler/lua54.can:337
} -- ./compiler/lua54.can:337
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:338
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:339
end -- ./compiler/lua54.can:339
return r -- ./compiler/lua54.can:341
end -- ./compiler/lua54.can:341
end, -- ./compiler/lua54.can:341
["While"] = function(t) -- ./compiler/lua54.can:345
local r = "" -- ./compiler/lua54.can:346
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua54.can:347
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:348
if # lets > 0 then -- ./compiler/lua54.can:349
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:350
for _, l in ipairs(lets) do -- ./compiler/lua54.can:351
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua54.can:355
if # lets > 0 then -- ./compiler/lua54.can:356
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:357
end -- ./compiler/lua54.can:357
if hasContinue then -- ./compiler/lua54.can:359
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:360
end -- ./compiler/lua54.can:360
r = r .. (lua(t[2])) -- ./compiler/lua54.can:362
if hasContinue then -- ./compiler/lua54.can:363
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:364
end -- ./compiler/lua54.can:364
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:366
if # lets > 0 then -- ./compiler/lua54.can:367
for _, l in ipairs(lets) do -- ./compiler/lua54.can:368
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua54.can:369
end -- ./compiler/lua54.can:369
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua54.can:371
end -- ./compiler/lua54.can:371
return r -- ./compiler/lua54.can:373
end, -- ./compiler/lua54.can:373
["Repeat"] = function(t) -- ./compiler/lua54.can:376
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua54.can:377
local r = "repeat" .. indent() -- ./compiler/lua54.can:378
if hasContinue then -- ./compiler/lua54.can:379
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:380
end -- ./compiler/lua54.can:380
r = r .. (lua(t[1])) -- ./compiler/lua54.can:382
if hasContinue then -- ./compiler/lua54.can:383
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:384
end -- ./compiler/lua54.can:384
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua54.can:386
return r -- ./compiler/lua54.can:387
end, -- ./compiler/lua54.can:387
["If"] = function(t) -- ./compiler/lua54.can:390
local r = "" -- ./compiler/lua54.can:391
local toClose = 0 -- ./compiler/lua54.can:392
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:393
if # lets > 0 then -- ./compiler/lua54.can:394
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:395
toClose = toClose + (1) -- ./compiler/lua54.can:396
for _, l in ipairs(lets) do -- ./compiler/lua54.can:397
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua54.can:401
for i = 3, # t - 1, 2 do -- ./compiler/lua54.can:402
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua54.can:403
if # lets > 0 then -- ./compiler/lua54.can:404
r = r .. ("else" .. indent()) -- ./compiler/lua54.can:405
toClose = toClose + (1) -- ./compiler/lua54.can:406
for _, l in ipairs(lets) do -- ./compiler/lua54.can:407
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:408
end -- ./compiler/lua54.can:408
else -- ./compiler/lua54.can:408
r = r .. ("else") -- ./compiler/lua54.can:411
end -- ./compiler/lua54.can:411
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua54.can:413
end -- ./compiler/lua54.can:413
if # t % 2 == 1 then -- ./compiler/lua54.can:415
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua54.can:416
end -- ./compiler/lua54.can:416
r = r .. ("end") -- ./compiler/lua54.can:418
for i = 1, toClose do -- ./compiler/lua54.can:419
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:420
end -- ./compiler/lua54.can:420
return r -- ./compiler/lua54.can:422
end, -- ./compiler/lua54.can:422
["Fornum"] = function(t) -- ./compiler/lua54.can:425
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua54.can:426
if # t == 5 then -- ./compiler/lua54.can:427
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua54.can:428
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua54.can:429
if hasContinue then -- ./compiler/lua54.can:430
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:431
end -- ./compiler/lua54.can:431
r = r .. (lua(t[5])) -- ./compiler/lua54.can:433
if hasContinue then -- ./compiler/lua54.can:434
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:435
end -- ./compiler/lua54.can:435
return r .. unindent() .. "end" -- ./compiler/lua54.can:437
else -- ./compiler/lua54.can:437
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua54.can:439
r = r .. (" do" .. indent()) -- ./compiler/lua54.can:440
if hasContinue then -- ./compiler/lua54.can:441
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:442
end -- ./compiler/lua54.can:442
r = r .. (lua(t[4])) -- ./compiler/lua54.can:444
if hasContinue then -- ./compiler/lua54.can:445
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:446
end -- ./compiler/lua54.can:446
return r .. unindent() .. "end" -- ./compiler/lua54.can:448
end -- ./compiler/lua54.can:448
end, -- ./compiler/lua54.can:448
["Forin"] = function(t) -- ./compiler/lua54.can:452
local destructured = {} -- ./compiler/lua54.can:453
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua54.can:454
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua54.can:455
if hasContinue then -- ./compiler/lua54.can:456
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:457
end -- ./compiler/lua54.can:457
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua54.can:459
if hasContinue then -- ./compiler/lua54.can:460
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:461
end -- ./compiler/lua54.can:461
return r .. unindent() .. "end" -- ./compiler/lua54.can:463
end, -- ./compiler/lua54.can:463
["Local"] = function(t) -- ./compiler/lua54.can:466
local destructured = {} -- ./compiler/lua54.can:467
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:468
if t[2][1] then -- ./compiler/lua54.can:469
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:470
end -- ./compiler/lua54.can:470
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:472
end, -- ./compiler/lua54.can:472
["Let"] = function(t) -- ./compiler/lua54.can:475
local destructured = {} -- ./compiler/lua54.can:476
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:477
local r = "local " .. nameList -- ./compiler/lua54.can:478
if t[2][1] then -- ./compiler/lua54.can:479
if all(t[2], { -- ./compiler/lua54.can:480
"Nil", -- ./compiler/lua54.can:480
"Dots", -- ./compiler/lua54.can:480
"Boolean", -- ./compiler/lua54.can:480
"Number", -- ./compiler/lua54.can:480
"String" -- ./compiler/lua54.can:480
}) then -- ./compiler/lua54.can:480
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:481
else -- ./compiler/lua54.can:481
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:486
end, -- ./compiler/lua54.can:486
["Localrec"] = function(t) -- ./compiler/lua54.can:489
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua54.can:490
end, -- ./compiler/lua54.can:490
["Goto"] = function(t) -- ./compiler/lua54.can:493
return "goto " .. lua(t, "Id") -- ./compiler/lua54.can:494
end, -- ./compiler/lua54.can:494
["Label"] = function(t) -- ./compiler/lua54.can:497
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua54.can:498
end, -- ./compiler/lua54.can:498
["Return"] = function(t) -- ./compiler/lua54.can:501
local push = peek("push") -- ./compiler/lua54.can:502
if push then -- ./compiler/lua54.can:503
local r = "" -- ./compiler/lua54.can:504
for _, val in ipairs(t) do -- ./compiler/lua54.can:505
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua54.can:506
end -- ./compiler/lua54.can:506
return r .. "return " .. UNPACK(push) -- ./compiler/lua54.can:508
else -- ./compiler/lua54.can:508
return "return " .. lua(t, "_lhs") -- ./compiler/lua54.can:510
end -- ./compiler/lua54.can:510
end, -- ./compiler/lua54.can:510
["Push"] = function(t) -- ./compiler/lua54.can:514
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua54.can:515
r = "" -- ./compiler/lua54.can:516
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:517
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua54.can:518
end -- ./compiler/lua54.can:518
if t[# t] then -- ./compiler/lua54.can:520
if t[# t]["tag"] == "Call" then -- ./compiler/lua54.can:521
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua54.can:522
else -- ./compiler/lua54.can:522
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
return r -- ./compiler/lua54.can:527
end, -- ./compiler/lua54.can:527
["Break"] = function() -- ./compiler/lua54.can:530
return "break" -- ./compiler/lua54.can:531
end, -- ./compiler/lua54.can:531
["Continue"] = function() -- ./compiler/lua54.can:534
return "goto " .. var("continue") -- ./compiler/lua54.can:535
end, -- ./compiler/lua54.can:535
["Nil"] = function() -- ./compiler/lua54.can:542
return "nil" -- ./compiler/lua54.can:543
end, -- ./compiler/lua54.can:543
["Dots"] = function() -- ./compiler/lua54.can:546
local macroargs = peek("macroargs") -- ./compiler/lua54.can:547
if macroargs and not nomacro["variables"]["..."] and macroargs["..."] then -- ./compiler/lua54.can:548
nomacro["variables"]["..."] = true -- ./compiler/lua54.can:549
local r = lua(macroargs["..."], "_lhs") -- ./compiler/lua54.can:550
nomacro["variables"]["..."] = nil -- ./compiler/lua54.can:551
return r -- ./compiler/lua54.can:552
else -- ./compiler/lua54.can:552
return "..." -- ./compiler/lua54.can:554
end -- ./compiler/lua54.can:554
end, -- ./compiler/lua54.can:554
["Boolean"] = function(t) -- ./compiler/lua54.can:558
return tostring(t[1]) -- ./compiler/lua54.can:559
end, -- ./compiler/lua54.can:559
["Number"] = function(t) -- ./compiler/lua54.can:562
return tostring(t[1]) -- ./compiler/lua54.can:563
end, -- ./compiler/lua54.can:563
["String"] = function(t) -- ./compiler/lua54.can:566
return ("%q"):format(t[1]) -- ./compiler/lua54.can:567
end, -- ./compiler/lua54.can:567
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua54.can:570
local r = "(" -- ./compiler/lua54.can:571
local decl = {} -- ./compiler/lua54.can:572
if t[1][1] then -- ./compiler/lua54.can:573
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua54.can:574
local id = lua(t[1][1][1]) -- ./compiler/lua54.can:575
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:576
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua54.can:577
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:578
r = r .. (id) -- ./compiler/lua54.can:579
else -- ./compiler/lua54.can:579
r = r .. (lua(t[1][1])) -- ./compiler/lua54.can:581
end -- ./compiler/lua54.can:581
for i = 2, # t[1], 1 do -- ./compiler/lua54.can:583
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua54.can:584
local id = lua(t[1][i][1]) -- ./compiler/lua54.can:585
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:586
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua54.can:587
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:588
r = r .. (", " .. id) -- ./compiler/lua54.can:589
else -- ./compiler/lua54.can:589
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
r = r .. (")" .. indent()) -- ./compiler/lua54.can:595
for _, d in ipairs(decl) do -- ./compiler/lua54.can:596
r = r .. (d .. newline()) -- ./compiler/lua54.can:597
end -- ./compiler/lua54.can:597
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua54.can:599
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua54.can:600
end -- ./compiler/lua54.can:600
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua54.can:602
if hasPush then -- ./compiler/lua54.can:603
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:604
else -- ./compiler/lua54.can:604
push("push", false) -- ./compiler/lua54.can:606
end -- ./compiler/lua54.can:606
r = r .. (lua(t[2])) -- ./compiler/lua54.can:608
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua54.can:609
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:610
end -- ./compiler/lua54.can:610
pop("push") -- ./compiler/lua54.can:612
return r .. unindent() .. "end" -- ./compiler/lua54.can:613
end, -- ./compiler/lua54.can:613
["Function"] = function(t) -- ./compiler/lua54.can:615
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua54.can:616
end, -- ./compiler/lua54.can:616
["Pair"] = function(t) -- ./compiler/lua54.can:619
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua54.can:620
end, -- ./compiler/lua54.can:620
["Table"] = function(t) -- ./compiler/lua54.can:622
if # t == 0 then -- ./compiler/lua54.can:623
return "{}" -- ./compiler/lua54.can:624
elseif # t == 1 then -- ./compiler/lua54.can:625
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua54.can:626
else -- ./compiler/lua54.can:626
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua54.can:628
end -- ./compiler/lua54.can:628
end, -- ./compiler/lua54.can:628
["TableCompr"] = function(t) -- ./compiler/lua54.can:632
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua54.can:633
end, -- ./compiler/lua54.can:633
["Op"] = function(t) -- ./compiler/lua54.can:636
local r -- ./compiler/lua54.can:637
if # t == 2 then -- ./compiler/lua54.can:638
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:639
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua54.can:640
else -- ./compiler/lua54.can:640
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua54.can:642
end -- ./compiler/lua54.can:642
else -- ./compiler/lua54.can:642
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:645
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua54.can:646
else -- ./compiler/lua54.can:646
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
return r -- ./compiler/lua54.can:651
end, -- ./compiler/lua54.can:651
["Paren"] = function(t) -- ./compiler/lua54.can:654
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua54.can:655
end, -- ./compiler/lua54.can:655
["MethodStub"] = function(t) -- ./compiler/lua54.can:658
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:664
end, -- ./compiler/lua54.can:664
["SafeMethodStub"] = function(t) -- ./compiler/lua54.can:667
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:674
end, -- ./compiler/lua54.can:674
["LetExpr"] = function(t) -- ./compiler/lua54.can:681
return lua(t[1][1]) -- ./compiler/lua54.can:682
end, -- ./compiler/lua54.can:682
["_statexpr"] = function(t, stat) -- ./compiler/lua54.can:686
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua54.can:687
local r = "(function()" .. indent() -- ./compiler/lua54.can:688
if hasPush then -- ./compiler/lua54.can:689
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:690
else -- ./compiler/lua54.can:690
push("push", false) -- ./compiler/lua54.can:692
end -- ./compiler/lua54.can:692
r = r .. (lua(t, stat)) -- ./compiler/lua54.can:694
if hasPush then -- ./compiler/lua54.can:695
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:696
end -- ./compiler/lua54.can:696
pop("push") -- ./compiler/lua54.can:698
r = r .. (unindent() .. "end)()") -- ./compiler/lua54.can:699
return r -- ./compiler/lua54.can:700
end, -- ./compiler/lua54.can:700
["DoExpr"] = function(t) -- ./compiler/lua54.can:703
if t[# t]["tag"] == "Push" then -- ./compiler/lua54.can:704
t[# t]["tag"] = "Return" -- ./compiler/lua54.can:705
end -- ./compiler/lua54.can:705
return lua(t, "_statexpr", "Do") -- ./compiler/lua54.can:707
end, -- ./compiler/lua54.can:707
["WhileExpr"] = function(t) -- ./compiler/lua54.can:710
return lua(t, "_statexpr", "While") -- ./compiler/lua54.can:711
end, -- ./compiler/lua54.can:711
["RepeatExpr"] = function(t) -- ./compiler/lua54.can:714
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua54.can:715
end, -- ./compiler/lua54.can:715
["IfExpr"] = function(t) -- ./compiler/lua54.can:718
for i = 2, # t do -- ./compiler/lua54.can:719
local block = t[i] -- ./compiler/lua54.can:720
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua54.can:721
block[# block]["tag"] = "Return" -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
return lua(t, "_statexpr", "If") -- ./compiler/lua54.can:725
end, -- ./compiler/lua54.can:725
["FornumExpr"] = function(t) -- ./compiler/lua54.can:728
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua54.can:729
end, -- ./compiler/lua54.can:729
["ForinExpr"] = function(t) -- ./compiler/lua54.can:732
return lua(t, "_statexpr", "Forin") -- ./compiler/lua54.can:733
end, -- ./compiler/lua54.can:733
["Call"] = function(t) -- ./compiler/lua54.can:739
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:740
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:741
elseif t[1]["tag"] == "Id" and not nomacro["functions"][t[1][1]] and macros["functions"][t[1][1]] then -- ./compiler/lua54.can:742
local macro = macros["functions"][t[1][1]] -- ./compiler/lua54.can:743
local replacement = macro["replacement"] -- ./compiler/lua54.can:744
local r -- ./compiler/lua54.can:745
nomacro["functions"][t[1][1]] = true -- ./compiler/lua54.can:746
if type(replacement) == "function" then -- ./compiler/lua54.can:747
local args = {} -- ./compiler/lua54.can:748
for i = 2, # t do -- ./compiler/lua54.can:749
table["insert"](args, lua(t[i])) -- ./compiler/lua54.can:750
end -- ./compiler/lua54.can:750
r = replacement(unpack(args)) -- ./compiler/lua54.can:752
else -- ./compiler/lua54.can:752
local macroargs = util["merge"](peek("macroargs")) -- ./compiler/lua54.can:754
for i, arg in ipairs(macro["args"]) do -- ./compiler/lua54.can:755
if arg["tag"] == "Dots" then -- ./compiler/lua54.can:756
macroargs["..."] = (function() -- ./compiler/lua54.can:757
local self = {} -- ./compiler/lua54.can:757
for j = i + 1, # t do -- ./compiler/lua54.can:757
self[#self+1] = t[j] -- ./compiler/lua54.can:757
end -- ./compiler/lua54.can:757
return self -- ./compiler/lua54.can:757
end)() -- ./compiler/lua54.can:757
elseif arg["tag"] == "Id" then -- ./compiler/lua54.can:758
if t[i + 1] == nil then -- ./compiler/lua54.can:759
error(("bad argument #%s to macro %s (value expected)"):format(i, t[1][1])) -- ./compiler/lua54.can:760
end -- ./compiler/lua54.can:760
macroargs[arg[1]] = t[i + 1] -- ./compiler/lua54.can:762
else -- ./compiler/lua54.can:762
error(("unexpected argument type %s in macro %s"):format(arg["tag"], t[1][1])) -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
push("macroargs", macroargs) -- ./compiler/lua54.can:767
r = lua(replacement) -- ./compiler/lua54.can:768
pop("macroargs") -- ./compiler/lua54.can:769
end -- ./compiler/lua54.can:769
nomacro["functions"][t[1][1]] = nil -- ./compiler/lua54.can:771
return r -- ./compiler/lua54.can:772
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua54.can:773
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua54.can:774
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:775
else -- ./compiler/lua54.can:775
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:777
end -- ./compiler/lua54.can:777
else -- ./compiler/lua54.can:777
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:780
end -- ./compiler/lua54.can:780
end, -- ./compiler/lua54.can:780
["SafeCall"] = function(t) -- ./compiler/lua54.can:784
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:785
return lua(t, "SafeIndex") -- ./compiler/lua54.can:786
else -- ./compiler/lua54.can:786
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua54.can:788
end -- ./compiler/lua54.can:788
end, -- ./compiler/lua54.can:788
["_lhs"] = function(t, start, newlines) -- ./compiler/lua54.can:793
if start == nil then start = 1 end -- ./compiler/lua54.can:793
local r -- ./compiler/lua54.can:794
if t[start] then -- ./compiler/lua54.can:795
r = lua(t[start]) -- ./compiler/lua54.can:796
for i = start + 1, # t, 1 do -- ./compiler/lua54.can:797
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua54.can:798
end -- ./compiler/lua54.can:798
else -- ./compiler/lua54.can:798
r = "" -- ./compiler/lua54.can:801
end -- ./compiler/lua54.can:801
return r -- ./compiler/lua54.can:803
end, -- ./compiler/lua54.can:803
["Id"] = function(t) -- ./compiler/lua54.can:806
local r = t[1] -- ./compiler/lua54.can:807
local macroargs = peek("macroargs") -- ./compiler/lua54.can:808
if not nomacro["variables"][t[1]] then -- ./compiler/lua54.can:809
nomacro["variables"][t[1]] = true -- ./compiler/lua54.can:810
if macroargs and macroargs[t[1]] then -- ./compiler/lua54.can:811
r = lua(macroargs[t[1]]) -- ./compiler/lua54.can:812
elseif macros["variables"][t[1]] ~= nil then -- ./compiler/lua54.can:813
local macro = macros["variables"][t[1]] -- ./compiler/lua54.can:814
if type(macro) == "function" then -- ./compiler/lua54.can:815
r = macro() -- ./compiler/lua54.can:816
else -- ./compiler/lua54.can:816
r = lua(macro) -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
nomacro["variables"][t[1]] = nil -- ./compiler/lua54.can:821
end -- ./compiler/lua54.can:821
return r -- ./compiler/lua54.can:823
end, -- ./compiler/lua54.can:823
["AttributeId"] = function(t) -- ./compiler/lua54.can:826
if t[2] then -- ./compiler/lua54.can:827
return t[1] .. " <" .. t[2] .. ">" -- ./compiler/lua54.can:828
else -- ./compiler/lua54.can:828
return t[1] -- ./compiler/lua54.can:830
end -- ./compiler/lua54.can:830
end, -- ./compiler/lua54.can:830
["DestructuringId"] = function(t) -- ./compiler/lua54.can:834
if t["id"] then -- ./compiler/lua54.can:835
return t["id"] -- ./compiler/lua54.can:836
else -- ./compiler/lua54.can:836
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua54.can:838
local vars = { ["id"] = tmp() } -- ./compiler/lua54.can:839
for j = 1, # t, 1 do -- ./compiler/lua54.can:840
table["insert"](vars, t[j]) -- ./compiler/lua54.can:841
end -- ./compiler/lua54.can:841
table["insert"](d, vars) -- ./compiler/lua54.can:843
t["id"] = vars["id"] -- ./compiler/lua54.can:844
return vars["id"] -- ./compiler/lua54.can:845
end -- ./compiler/lua54.can:845
end, -- ./compiler/lua54.can:845
["Index"] = function(t) -- ./compiler/lua54.can:849
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:850
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:851
else -- ./compiler/lua54.can:851
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:853
end -- ./compiler/lua54.can:853
end, -- ./compiler/lua54.can:853
["SafeIndex"] = function(t) -- ./compiler/lua54.can:857
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:858
local l = {} -- ./compiler/lua54.can:859
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua54.can:860
table["insert"](l, 1, t) -- ./compiler/lua54.can:861
t = t[1] -- ./compiler/lua54.can:862
end -- ./compiler/lua54.can:862
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua54.can:864
for _, e in ipairs(l) do -- ./compiler/lua54.can:865
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua54.can:866
if e["tag"] == "SafeIndex" then -- ./compiler/lua54.can:867
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua54.can:868
else -- ./compiler/lua54.can:868
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua54.can:873
return r -- ./compiler/lua54.can:874
else -- ./compiler/lua54.can:874
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua54.can:876
end -- ./compiler/lua54.can:876
end, -- ./compiler/lua54.can:876
["_opid"] = { -- ./compiler/lua54.can:881
["add"] = "+", -- ./compiler/lua54.can:882
["sub"] = "-", -- ./compiler/lua54.can:882
["mul"] = "*", -- ./compiler/lua54.can:882
["div"] = "/", -- ./compiler/lua54.can:882
["idiv"] = "//", -- ./compiler/lua54.can:883
["mod"] = "%", -- ./compiler/lua54.can:883
["pow"] = "^", -- ./compiler/lua54.can:883
["concat"] = "..", -- ./compiler/lua54.can:883
["band"] = "&", -- ./compiler/lua54.can:884
["bor"] = "|", -- ./compiler/lua54.can:884
["bxor"] = "~", -- ./compiler/lua54.can:884
["shl"] = "<<", -- ./compiler/lua54.can:884
["shr"] = ">>", -- ./compiler/lua54.can:884
["eq"] = "==", -- ./compiler/lua54.can:885
["ne"] = "~=", -- ./compiler/lua54.can:885
["lt"] = "<", -- ./compiler/lua54.can:885
["gt"] = ">", -- ./compiler/lua54.can:885
["le"] = "<=", -- ./compiler/lua54.can:885
["ge"] = ">=", -- ./compiler/lua54.can:885
["and"] = "and", -- ./compiler/lua54.can:886
["or"] = "or", -- ./compiler/lua54.can:886
["unm"] = "-", -- ./compiler/lua54.can:886
["len"] = "#", -- ./compiler/lua54.can:886
["bnot"] = "~", -- ./compiler/lua54.can:886
["not"] = "not" -- ./compiler/lua54.can:886
} -- ./compiler/lua54.can:886
}, { ["__index"] = function(self, key) -- ./compiler/lua54.can:889
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua54.can:890
end }) -- ./compiler/lua54.can:890
local code = lua(ast) .. newline() -- ./compiler/lua54.can:896
return requireStr .. code -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
local lua54 = _() or lua54 -- ./compiler/lua54.can:902
package["loaded"]["compiler.lua54"] = lua54 or true -- ./compiler/lua54.can:903
local function _() -- ./compiler/lua54.can:906
local function _() -- ./compiler/lua54.can:908
local util = require("candran.util") -- ./compiler/lua54.can:1
local targetName = "Lua 5.4" -- ./compiler/lua54.can:3
local unpack = unpack or table["unpack"] -- ./compiler/lua54.can:5
return function(code, ast, options, macros) -- ./compiler/lua54.can:7
if macros == nil then macros = { -- ./compiler/lua54.can:7
["functions"] = {}, -- ./compiler/lua54.can:7
["variables"] = {} -- ./compiler/lua54.can:7
} end -- ./compiler/lua54.can:7
local lastInputPos = 1 -- ./compiler/lua54.can:9
local prevLinePos = 1 -- ./compiler/lua54.can:10
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua54.can:11
local lastLine = 1 -- ./compiler/lua54.can:12
local indentLevel = 0 -- ./compiler/lua54.can:15
local function newline() -- ./compiler/lua54.can:17
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua54.can:18
if options["mapLines"] then -- ./compiler/lua54.can:19
local sub = code:sub(lastInputPos) -- ./compiler/lua54.can:20
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua54.can:21
if source and line then -- ./compiler/lua54.can:23
lastSource = source -- ./compiler/lua54.can:24
lastLine = tonumber(line) -- ./compiler/lua54.can:25
else -- ./compiler/lua54.can:25
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua54.can:27
lastLine = lastLine + (1) -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
prevLinePos = lastInputPos -- ./compiler/lua54.can:32
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua54.can:34
end -- ./compiler/lua54.can:34
return r -- ./compiler/lua54.can:36
end -- ./compiler/lua54.can:36
local function indent() -- ./compiler/lua54.can:39
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:40
return newline() -- ./compiler/lua54.can:41
end -- ./compiler/lua54.can:41
local function unindent() -- ./compiler/lua54.can:44
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:45
return newline() -- ./compiler/lua54.can:46
end -- ./compiler/lua54.can:46
local states = { -- ./compiler/lua54.can:51
["push"] = {}, -- ./compiler/lua54.can:52
["destructuring"] = {}, -- ./compiler/lua54.can:53
["scope"] = {}, -- ./compiler/lua54.can:54
["macroargs"] = {} -- ./compiler/lua54.can:55
} -- ./compiler/lua54.can:55
local function push(name, state) -- ./compiler/lua54.can:58
table["insert"](states[name], state) -- ./compiler/lua54.can:59
return "" -- ./compiler/lua54.can:60
end -- ./compiler/lua54.can:60
local function pop(name) -- ./compiler/lua54.can:63
table["remove"](states[name]) -- ./compiler/lua54.can:64
return "" -- ./compiler/lua54.can:65
end -- ./compiler/lua54.can:65
local function set(name, state) -- ./compiler/lua54.can:68
states[name][# states[name]] = state -- ./compiler/lua54.can:69
return "" -- ./compiler/lua54.can:70
end -- ./compiler/lua54.can:70
local function peek(name) -- ./compiler/lua54.can:73
return states[name][# states[name]] -- ./compiler/lua54.can:74
end -- ./compiler/lua54.can:74
local function var(name) -- ./compiler/lua54.can:79
return options["variablePrefix"] .. name -- ./compiler/lua54.can:80
end -- ./compiler/lua54.can:80
local function tmp() -- ./compiler/lua54.can:84
local scope = peek("scope") -- ./compiler/lua54.can:85
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua54.can:86
table["insert"](scope, var) -- ./compiler/lua54.can:87
return var -- ./compiler/lua54.can:88
end -- ./compiler/lua54.can:88
local nomacro = { -- ./compiler/lua54.can:92
["variables"] = {}, -- ./compiler/lua54.can:92
["functions"] = {} -- ./compiler/lua54.can:92
} -- ./compiler/lua54.can:92
local required = {} -- ./compiler/lua54.can:95
local requireStr = "" -- ./compiler/lua54.can:96
local function addRequire(mod, name, field) -- ./compiler/lua54.can:98
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua54.can:99
if not required[req] then -- ./compiler/lua54.can:100
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua54.can:101
required[req] = true -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
local loop = { -- ./compiler/lua54.can:107
"While", -- ./compiler/lua54.can:107
"Repeat", -- ./compiler/lua54.can:107
"Fornum", -- ./compiler/lua54.can:107
"Forin", -- ./compiler/lua54.can:107
"WhileExpr", -- ./compiler/lua54.can:107
"RepeatExpr", -- ./compiler/lua54.can:107
"FornumExpr", -- ./compiler/lua54.can:107
"ForinExpr" -- ./compiler/lua54.can:107
} -- ./compiler/lua54.can:107
local func = { -- ./compiler/lua54.can:108
"Function", -- ./compiler/lua54.can:108
"TableCompr", -- ./compiler/lua54.can:108
"DoExpr", -- ./compiler/lua54.can:108
"WhileExpr", -- ./compiler/lua54.can:108
"RepeatExpr", -- ./compiler/lua54.can:108
"IfExpr", -- ./compiler/lua54.can:108
"FornumExpr", -- ./compiler/lua54.can:108
"ForinExpr" -- ./compiler/lua54.can:108
} -- ./compiler/lua54.can:108
local function any(list, tags, nofollow) -- ./compiler/lua54.can:112
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:112
local tagsCheck = {} -- ./compiler/lua54.can:113
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:114
tagsCheck[tag] = true -- ./compiler/lua54.can:115
end -- ./compiler/lua54.can:115
local nofollowCheck = {} -- ./compiler/lua54.can:117
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:118
nofollowCheck[tag] = true -- ./compiler/lua54.can:119
end -- ./compiler/lua54.can:119
for _, node in ipairs(list) do -- ./compiler/lua54.can:121
if type(node) == "table" then -- ./compiler/lua54.can:122
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:123
return node -- ./compiler/lua54.can:124
end -- ./compiler/lua54.can:124
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:126
local r = any(node, tags, nofollow) -- ./compiler/lua54.can:127
if r then -- ./compiler/lua54.can:128
return r -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
return nil -- ./compiler/lua54.can:132
end -- ./compiler/lua54.can:132
local function search(list, tags, nofollow) -- ./compiler/lua54.can:137
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:137
local tagsCheck = {} -- ./compiler/lua54.can:138
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:139
tagsCheck[tag] = true -- ./compiler/lua54.can:140
end -- ./compiler/lua54.can:140
local nofollowCheck = {} -- ./compiler/lua54.can:142
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:143
nofollowCheck[tag] = true -- ./compiler/lua54.can:144
end -- ./compiler/lua54.can:144
local found = {} -- ./compiler/lua54.can:146
for _, node in ipairs(list) do -- ./compiler/lua54.can:147
if type(node) == "table" then -- ./compiler/lua54.can:148
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:149
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua54.can:150
table["insert"](found, n) -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:154
table["insert"](found, node) -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
return found -- ./compiler/lua54.can:159
end -- ./compiler/lua54.can:159
local function all(list, tags) -- ./compiler/lua54.can:163
for _, node in ipairs(list) do -- ./compiler/lua54.can:164
local ok = false -- ./compiler/lua54.can:165
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:166
if node["tag"] == tag then -- ./compiler/lua54.can:167
ok = true -- ./compiler/lua54.can:168
break -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
if not ok then -- ./compiler/lua54.can:172
return false -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
return true -- ./compiler/lua54.can:176
end -- ./compiler/lua54.can:176
local tags -- ./compiler/lua54.can:180
local function lua(ast, forceTag, ...) -- ./compiler/lua54.can:182
if options["mapLines"] and ast["pos"] then -- ./compiler/lua54.can:183
lastInputPos = ast["pos"] -- ./compiler/lua54.can:184
end -- ./compiler/lua54.can:184
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua54.can:186
end -- ./compiler/lua54.can:186
local UNPACK = function(list, i, j) -- ./compiler/lua54.can:190
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua54.can:191
end -- ./compiler/lua54.can:191
local APPEND = function(t, toAppend) -- ./compiler/lua54.can:193
return "do" .. indent() .. "local " .. var("a") .. " = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(" .. var("a") .. ", 1, " .. var("a") .. ".n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua54.can:194
end -- ./compiler/lua54.can:194
local CONTINUE_START = function() -- ./compiler/lua54.can:196
return "do" .. indent() -- ./compiler/lua54.can:197
end -- ./compiler/lua54.can:197
local CONTINUE_STOP = function() -- ./compiler/lua54.can:199
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua54.can:200
end -- ./compiler/lua54.can:200
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua54.can:202
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua54.can:202
if noLocal == nil then noLocal = false end -- ./compiler/lua54.can:202
local vars = {} -- ./compiler/lua54.can:203
local values = {} -- ./compiler/lua54.can:204
for _, list in ipairs(destructured) do -- ./compiler/lua54.can:205
for _, v in ipairs(list) do -- ./compiler/lua54.can:206
local var, val -- ./compiler/lua54.can:207
if v["tag"] == "Id" or v["tag"] == "AttributeId" then -- ./compiler/lua54.can:208
var = v -- ./compiler/lua54.can:209
val = { -- ./compiler/lua54.can:210
["tag"] = "Index", -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "Id", -- ./compiler/lua54.can:210
list["id"] -- ./compiler/lua54.can:210
}, -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "String", -- ./compiler/lua54.can:210
v[1] -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
elseif v["tag"] == "Pair" then -- ./compiler/lua54.can:211
var = v[2] -- ./compiler/lua54.can:212
val = { -- ./compiler/lua54.can:213
["tag"] = "Index", -- ./compiler/lua54.can:213
{ -- ./compiler/lua54.can:213
["tag"] = "Id", -- ./compiler/lua54.can:213
list["id"] -- ./compiler/lua54.can:213
}, -- ./compiler/lua54.can:213
v[1] -- ./compiler/lua54.can:213
} -- ./compiler/lua54.can:213
else -- ./compiler/lua54.can:213
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua54.can:215
end -- ./compiler/lua54.can:215
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua54.can:217
val = { -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["rightOp"], -- ./compiler/lua54.can:218
var, -- ./compiler/lua54.can:218
{ -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["leftOp"], -- ./compiler/lua54.can:218
val, -- ./compiler/lua54.can:218
var -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
elseif destructured["rightOp"] then -- ./compiler/lua54.can:219
val = { -- ./compiler/lua54.can:220
["tag"] = "Op", -- ./compiler/lua54.can:220
destructured["rightOp"], -- ./compiler/lua54.can:220
var, -- ./compiler/lua54.can:220
val -- ./compiler/lua54.can:220
} -- ./compiler/lua54.can:220
elseif destructured["leftOp"] then -- ./compiler/lua54.can:221
val = { -- ./compiler/lua54.can:222
["tag"] = "Op", -- ./compiler/lua54.can:222
destructured["leftOp"], -- ./compiler/lua54.can:222
val, -- ./compiler/lua54.can:222
var -- ./compiler/lua54.can:222
} -- ./compiler/lua54.can:222
end -- ./compiler/lua54.can:222
table["insert"](vars, lua(var)) -- ./compiler/lua54.can:224
table["insert"](values, lua(val)) -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
if # vars > 0 then -- ./compiler/lua54.can:228
local decl = noLocal and "" or "local " -- ./compiler/lua54.can:229
if newlineAfter then -- ./compiler/lua54.can:230
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua54.can:231
else -- ./compiler/lua54.can:231
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua54.can:233
end -- ./compiler/lua54.can:233
else -- ./compiler/lua54.can:233
return "" -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
tags = setmetatable({ -- ./compiler/lua54.can:241
["Block"] = function(t) -- ./compiler/lua54.can:243
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua54.can:244
if hasPush and hasPush == t[# t] then -- ./compiler/lua54.can:245
hasPush["tag"] = "Return" -- ./compiler/lua54.can:246
hasPush = false -- ./compiler/lua54.can:247
end -- ./compiler/lua54.can:247
local r = push("scope", {}) -- ./compiler/lua54.can:249
if hasPush then -- ./compiler/lua54.can:250
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:251
end -- ./compiler/lua54.can:251
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:253
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua54.can:254
end -- ./compiler/lua54.can:254
if t[# t] then -- ./compiler/lua54.can:256
r = r .. (lua(t[# t])) -- ./compiler/lua54.can:257
end -- ./compiler/lua54.can:257
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua54.can:259
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua54.can:260
end -- ./compiler/lua54.can:260
return r .. pop("scope") -- ./compiler/lua54.can:262
end, -- ./compiler/lua54.can:262
["Do"] = function(t) -- ./compiler/lua54.can:268
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua54.can:269
end, -- ./compiler/lua54.can:269
["Set"] = function(t) -- ./compiler/lua54.can:272
local expr = t[# t] -- ./compiler/lua54.can:274
local vars, values = {}, {} -- ./compiler/lua54.can:275
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua54.can:276
for i, n in ipairs(t[1]) do -- ./compiler/lua54.can:277
if n["tag"] == "DestructuringId" then -- ./compiler/lua54.can:278
table["insert"](destructuringVars, n) -- ./compiler/lua54.can:279
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua54.can:280
else -- ./compiler/lua54.can:280
table["insert"](vars, n) -- ./compiler/lua54.can:282
table["insert"](values, expr[i]) -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
if # t == 2 or # t == 3 then -- ./compiler/lua54.can:287
local r = "" -- ./compiler/lua54.can:288
if # vars > 0 then -- ./compiler/lua54.can:289
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua54.can:290
end -- ./compiler/lua54.can:290
if # destructuringVars > 0 then -- ./compiler/lua54.can:292
local destructured = {} -- ./compiler/lua54.can:293
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:294
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:295
end -- ./compiler/lua54.can:295
return r -- ./compiler/lua54.can:297
elseif # t == 4 then -- ./compiler/lua54.can:298
if t[3] == "=" then -- ./compiler/lua54.can:299
local r = "" -- ./compiler/lua54.can:300
if # vars > 0 then -- ./compiler/lua54.can:301
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:302
t[2], -- ./compiler/lua54.can:302
vars[1], -- ./compiler/lua54.can:302
{ -- ./compiler/lua54.can:302
["tag"] = "Paren", -- ./compiler/lua54.can:302
values[1] -- ./compiler/lua54.can:302
} -- ./compiler/lua54.can:302
}, "Op")) -- ./compiler/lua54.can:302
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua54.can:303
r = r .. (", " .. lua({ -- ./compiler/lua54.can:304
t[2], -- ./compiler/lua54.can:304
vars[i], -- ./compiler/lua54.can:304
{ -- ./compiler/lua54.can:304
["tag"] = "Paren", -- ./compiler/lua54.can:304
values[i] -- ./compiler/lua54.can:304
} -- ./compiler/lua54.can:304
}, "Op")) -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
if # destructuringVars > 0 then -- ./compiler/lua54.can:307
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua54.can:308
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:309
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:310
end -- ./compiler/lua54.can:310
return r -- ./compiler/lua54.can:312
else -- ./compiler/lua54.can:312
local r = "" -- ./compiler/lua54.can:314
if # vars > 0 then -- ./compiler/lua54.can:315
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:316
t[3], -- ./compiler/lua54.can:316
{ -- ./compiler/lua54.can:316
["tag"] = "Paren", -- ./compiler/lua54.can:316
values[1] -- ./compiler/lua54.can:316
}, -- ./compiler/lua54.can:316
vars[1] -- ./compiler/lua54.can:316
}, "Op")) -- ./compiler/lua54.can:316
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua54.can:317
r = r .. (", " .. lua({ -- ./compiler/lua54.can:318
t[3], -- ./compiler/lua54.can:318
{ -- ./compiler/lua54.can:318
["tag"] = "Paren", -- ./compiler/lua54.can:318
values[i] -- ./compiler/lua54.can:318
}, -- ./compiler/lua54.can:318
vars[i] -- ./compiler/lua54.can:318
}, "Op")) -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
if # destructuringVars > 0 then -- ./compiler/lua54.can:321
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua54.can:322
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:323
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:324
end -- ./compiler/lua54.can:324
return r -- ./compiler/lua54.can:326
end -- ./compiler/lua54.can:326
else -- ./compiler/lua54.can:326
local r = "" -- ./compiler/lua54.can:329
if # vars > 0 then -- ./compiler/lua54.can:330
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:331
t[2], -- ./compiler/lua54.can:331
vars[1], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Op", -- ./compiler/lua54.can:331
t[4], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Paren", -- ./compiler/lua54.can:331
values[1] -- ./compiler/lua54.can:331
}, -- ./compiler/lua54.can:331
vars[1] -- ./compiler/lua54.can:331
} -- ./compiler/lua54.can:331
}, "Op")) -- ./compiler/lua54.can:331
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua54.can:332
r = r .. (", " .. lua({ -- ./compiler/lua54.can:333
t[2], -- ./compiler/lua54.can:333
vars[i], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Op", -- ./compiler/lua54.can:333
t[4], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Paren", -- ./compiler/lua54.can:333
values[i] -- ./compiler/lua54.can:333
}, -- ./compiler/lua54.can:333
vars[i] -- ./compiler/lua54.can:333
} -- ./compiler/lua54.can:333
}, "Op")) -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
if # destructuringVars > 0 then -- ./compiler/lua54.can:336
local destructured = { -- ./compiler/lua54.can:337
["rightOp"] = t[2], -- ./compiler/lua54.can:337
["leftOp"] = t[4] -- ./compiler/lua54.can:337
} -- ./compiler/lua54.can:337
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:338
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:339
end -- ./compiler/lua54.can:339
return r -- ./compiler/lua54.can:341
end -- ./compiler/lua54.can:341
end, -- ./compiler/lua54.can:341
["While"] = function(t) -- ./compiler/lua54.can:345
local r = "" -- ./compiler/lua54.can:346
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua54.can:347
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:348
if # lets > 0 then -- ./compiler/lua54.can:349
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:350
for _, l in ipairs(lets) do -- ./compiler/lua54.can:351
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua54.can:355
if # lets > 0 then -- ./compiler/lua54.can:356
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:357
end -- ./compiler/lua54.can:357
if hasContinue then -- ./compiler/lua54.can:359
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:360
end -- ./compiler/lua54.can:360
r = r .. (lua(t[2])) -- ./compiler/lua54.can:362
if hasContinue then -- ./compiler/lua54.can:363
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:364
end -- ./compiler/lua54.can:364
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:366
if # lets > 0 then -- ./compiler/lua54.can:367
for _, l in ipairs(lets) do -- ./compiler/lua54.can:368
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua54.can:369
end -- ./compiler/lua54.can:369
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua54.can:371
end -- ./compiler/lua54.can:371
return r -- ./compiler/lua54.can:373
end, -- ./compiler/lua54.can:373
["Repeat"] = function(t) -- ./compiler/lua54.can:376
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua54.can:377
local r = "repeat" .. indent() -- ./compiler/lua54.can:378
if hasContinue then -- ./compiler/lua54.can:379
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:380
end -- ./compiler/lua54.can:380
r = r .. (lua(t[1])) -- ./compiler/lua54.can:382
if hasContinue then -- ./compiler/lua54.can:383
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:384
end -- ./compiler/lua54.can:384
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua54.can:386
return r -- ./compiler/lua54.can:387
end, -- ./compiler/lua54.can:387
["If"] = function(t) -- ./compiler/lua54.can:390
local r = "" -- ./compiler/lua54.can:391
local toClose = 0 -- ./compiler/lua54.can:392
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:393
if # lets > 0 then -- ./compiler/lua54.can:394
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:395
toClose = toClose + (1) -- ./compiler/lua54.can:396
for _, l in ipairs(lets) do -- ./compiler/lua54.can:397
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua54.can:401
for i = 3, # t - 1, 2 do -- ./compiler/lua54.can:402
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua54.can:403
if # lets > 0 then -- ./compiler/lua54.can:404
r = r .. ("else" .. indent()) -- ./compiler/lua54.can:405
toClose = toClose + (1) -- ./compiler/lua54.can:406
for _, l in ipairs(lets) do -- ./compiler/lua54.can:407
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:408
end -- ./compiler/lua54.can:408
else -- ./compiler/lua54.can:408
r = r .. ("else") -- ./compiler/lua54.can:411
end -- ./compiler/lua54.can:411
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua54.can:413
end -- ./compiler/lua54.can:413
if # t % 2 == 1 then -- ./compiler/lua54.can:415
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua54.can:416
end -- ./compiler/lua54.can:416
r = r .. ("end") -- ./compiler/lua54.can:418
for i = 1, toClose do -- ./compiler/lua54.can:419
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:420
end -- ./compiler/lua54.can:420
return r -- ./compiler/lua54.can:422
end, -- ./compiler/lua54.can:422
["Fornum"] = function(t) -- ./compiler/lua54.can:425
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua54.can:426
if # t == 5 then -- ./compiler/lua54.can:427
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua54.can:428
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua54.can:429
if hasContinue then -- ./compiler/lua54.can:430
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:431
end -- ./compiler/lua54.can:431
r = r .. (lua(t[5])) -- ./compiler/lua54.can:433
if hasContinue then -- ./compiler/lua54.can:434
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:435
end -- ./compiler/lua54.can:435
return r .. unindent() .. "end" -- ./compiler/lua54.can:437
else -- ./compiler/lua54.can:437
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua54.can:439
r = r .. (" do" .. indent()) -- ./compiler/lua54.can:440
if hasContinue then -- ./compiler/lua54.can:441
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:442
end -- ./compiler/lua54.can:442
r = r .. (lua(t[4])) -- ./compiler/lua54.can:444
if hasContinue then -- ./compiler/lua54.can:445
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:446
end -- ./compiler/lua54.can:446
return r .. unindent() .. "end" -- ./compiler/lua54.can:448
end -- ./compiler/lua54.can:448
end, -- ./compiler/lua54.can:448
["Forin"] = function(t) -- ./compiler/lua54.can:452
local destructured = {} -- ./compiler/lua54.can:453
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua54.can:454
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua54.can:455
if hasContinue then -- ./compiler/lua54.can:456
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:457
end -- ./compiler/lua54.can:457
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua54.can:459
if hasContinue then -- ./compiler/lua54.can:460
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:461
end -- ./compiler/lua54.can:461
return r .. unindent() .. "end" -- ./compiler/lua54.can:463
end, -- ./compiler/lua54.can:463
["Local"] = function(t) -- ./compiler/lua54.can:466
local destructured = {} -- ./compiler/lua54.can:467
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:468
if t[2][1] then -- ./compiler/lua54.can:469
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:470
end -- ./compiler/lua54.can:470
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:472
end, -- ./compiler/lua54.can:472
["Let"] = function(t) -- ./compiler/lua54.can:475
local destructured = {} -- ./compiler/lua54.can:476
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:477
local r = "local " .. nameList -- ./compiler/lua54.can:478
if t[2][1] then -- ./compiler/lua54.can:479
if all(t[2], { -- ./compiler/lua54.can:480
"Nil", -- ./compiler/lua54.can:480
"Dots", -- ./compiler/lua54.can:480
"Boolean", -- ./compiler/lua54.can:480
"Number", -- ./compiler/lua54.can:480
"String" -- ./compiler/lua54.can:480
}) then -- ./compiler/lua54.can:480
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:481
else -- ./compiler/lua54.can:481
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:486
end, -- ./compiler/lua54.can:486
["Localrec"] = function(t) -- ./compiler/lua54.can:489
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua54.can:490
end, -- ./compiler/lua54.can:490
["Goto"] = function(t) -- ./compiler/lua54.can:493
return "goto " .. lua(t, "Id") -- ./compiler/lua54.can:494
end, -- ./compiler/lua54.can:494
["Label"] = function(t) -- ./compiler/lua54.can:497
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua54.can:498
end, -- ./compiler/lua54.can:498
["Return"] = function(t) -- ./compiler/lua54.can:501
local push = peek("push") -- ./compiler/lua54.can:502
if push then -- ./compiler/lua54.can:503
local r = "" -- ./compiler/lua54.can:504
for _, val in ipairs(t) do -- ./compiler/lua54.can:505
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua54.can:506
end -- ./compiler/lua54.can:506
return r .. "return " .. UNPACK(push) -- ./compiler/lua54.can:508
else -- ./compiler/lua54.can:508
return "return " .. lua(t, "_lhs") -- ./compiler/lua54.can:510
end -- ./compiler/lua54.can:510
end, -- ./compiler/lua54.can:510
["Push"] = function(t) -- ./compiler/lua54.can:514
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua54.can:515
r = "" -- ./compiler/lua54.can:516
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:517
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua54.can:518
end -- ./compiler/lua54.can:518
if t[# t] then -- ./compiler/lua54.can:520
if t[# t]["tag"] == "Call" then -- ./compiler/lua54.can:521
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua54.can:522
else -- ./compiler/lua54.can:522
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
return r -- ./compiler/lua54.can:527
end, -- ./compiler/lua54.can:527
["Break"] = function() -- ./compiler/lua54.can:530
return "break" -- ./compiler/lua54.can:531
end, -- ./compiler/lua54.can:531
["Continue"] = function() -- ./compiler/lua54.can:534
return "goto " .. var("continue") -- ./compiler/lua54.can:535
end, -- ./compiler/lua54.can:535
["Nil"] = function() -- ./compiler/lua54.can:542
return "nil" -- ./compiler/lua54.can:543
end, -- ./compiler/lua54.can:543
["Dots"] = function() -- ./compiler/lua54.can:546
local macroargs = peek("macroargs") -- ./compiler/lua54.can:547
if macroargs and not nomacro["variables"]["..."] and macroargs["..."] then -- ./compiler/lua54.can:548
nomacro["variables"]["..."] = true -- ./compiler/lua54.can:549
local r = lua(macroargs["..."], "_lhs") -- ./compiler/lua54.can:550
nomacro["variables"]["..."] = nil -- ./compiler/lua54.can:551
return r -- ./compiler/lua54.can:552
else -- ./compiler/lua54.can:552
return "..." -- ./compiler/lua54.can:554
end -- ./compiler/lua54.can:554
end, -- ./compiler/lua54.can:554
["Boolean"] = function(t) -- ./compiler/lua54.can:558
return tostring(t[1]) -- ./compiler/lua54.can:559
end, -- ./compiler/lua54.can:559
["Number"] = function(t) -- ./compiler/lua54.can:562
return tostring(t[1]) -- ./compiler/lua54.can:563
end, -- ./compiler/lua54.can:563
["String"] = function(t) -- ./compiler/lua54.can:566
return ("%q"):format(t[1]) -- ./compiler/lua54.can:567
end, -- ./compiler/lua54.can:567
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua54.can:570
local r = "(" -- ./compiler/lua54.can:571
local decl = {} -- ./compiler/lua54.can:572
if t[1][1] then -- ./compiler/lua54.can:573
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua54.can:574
local id = lua(t[1][1][1]) -- ./compiler/lua54.can:575
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:576
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua54.can:577
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:578
r = r .. (id) -- ./compiler/lua54.can:579
else -- ./compiler/lua54.can:579
r = r .. (lua(t[1][1])) -- ./compiler/lua54.can:581
end -- ./compiler/lua54.can:581
for i = 2, # t[1], 1 do -- ./compiler/lua54.can:583
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua54.can:584
local id = lua(t[1][i][1]) -- ./compiler/lua54.can:585
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:586
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua54.can:587
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:588
r = r .. (", " .. id) -- ./compiler/lua54.can:589
else -- ./compiler/lua54.can:589
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
r = r .. (")" .. indent()) -- ./compiler/lua54.can:595
for _, d in ipairs(decl) do -- ./compiler/lua54.can:596
r = r .. (d .. newline()) -- ./compiler/lua54.can:597
end -- ./compiler/lua54.can:597
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua54.can:599
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua54.can:600
end -- ./compiler/lua54.can:600
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua54.can:602
if hasPush then -- ./compiler/lua54.can:603
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:604
else -- ./compiler/lua54.can:604
push("push", false) -- ./compiler/lua54.can:606
end -- ./compiler/lua54.can:606
r = r .. (lua(t[2])) -- ./compiler/lua54.can:608
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua54.can:609
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:610
end -- ./compiler/lua54.can:610
pop("push") -- ./compiler/lua54.can:612
return r .. unindent() .. "end" -- ./compiler/lua54.can:613
end, -- ./compiler/lua54.can:613
["Function"] = function(t) -- ./compiler/lua54.can:615
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua54.can:616
end, -- ./compiler/lua54.can:616
["Pair"] = function(t) -- ./compiler/lua54.can:619
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua54.can:620
end, -- ./compiler/lua54.can:620
["Table"] = function(t) -- ./compiler/lua54.can:622
if # t == 0 then -- ./compiler/lua54.can:623
return "{}" -- ./compiler/lua54.can:624
elseif # t == 1 then -- ./compiler/lua54.can:625
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua54.can:626
else -- ./compiler/lua54.can:626
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua54.can:628
end -- ./compiler/lua54.can:628
end, -- ./compiler/lua54.can:628
["TableCompr"] = function(t) -- ./compiler/lua54.can:632
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua54.can:633
end, -- ./compiler/lua54.can:633
["Op"] = function(t) -- ./compiler/lua54.can:636
local r -- ./compiler/lua54.can:637
if # t == 2 then -- ./compiler/lua54.can:638
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:639
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua54.can:640
else -- ./compiler/lua54.can:640
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua54.can:642
end -- ./compiler/lua54.can:642
else -- ./compiler/lua54.can:642
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:645
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua54.can:646
else -- ./compiler/lua54.can:646
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
return r -- ./compiler/lua54.can:651
end, -- ./compiler/lua54.can:651
["Paren"] = function(t) -- ./compiler/lua54.can:654
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua54.can:655
end, -- ./compiler/lua54.can:655
["MethodStub"] = function(t) -- ./compiler/lua54.can:658
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:664
end, -- ./compiler/lua54.can:664
["SafeMethodStub"] = function(t) -- ./compiler/lua54.can:667
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:674
end, -- ./compiler/lua54.can:674
["LetExpr"] = function(t) -- ./compiler/lua54.can:681
return lua(t[1][1]) -- ./compiler/lua54.can:682
end, -- ./compiler/lua54.can:682
["_statexpr"] = function(t, stat) -- ./compiler/lua54.can:686
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua54.can:687
local r = "(function()" .. indent() -- ./compiler/lua54.can:688
if hasPush then -- ./compiler/lua54.can:689
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:690
else -- ./compiler/lua54.can:690
push("push", false) -- ./compiler/lua54.can:692
end -- ./compiler/lua54.can:692
r = r .. (lua(t, stat)) -- ./compiler/lua54.can:694
if hasPush then -- ./compiler/lua54.can:695
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:696
end -- ./compiler/lua54.can:696
pop("push") -- ./compiler/lua54.can:698
r = r .. (unindent() .. "end)()") -- ./compiler/lua54.can:699
return r -- ./compiler/lua54.can:700
end, -- ./compiler/lua54.can:700
["DoExpr"] = function(t) -- ./compiler/lua54.can:703
if t[# t]["tag"] == "Push" then -- ./compiler/lua54.can:704
t[# t]["tag"] = "Return" -- ./compiler/lua54.can:705
end -- ./compiler/lua54.can:705
return lua(t, "_statexpr", "Do") -- ./compiler/lua54.can:707
end, -- ./compiler/lua54.can:707
["WhileExpr"] = function(t) -- ./compiler/lua54.can:710
return lua(t, "_statexpr", "While") -- ./compiler/lua54.can:711
end, -- ./compiler/lua54.can:711
["RepeatExpr"] = function(t) -- ./compiler/lua54.can:714
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua54.can:715
end, -- ./compiler/lua54.can:715
["IfExpr"] = function(t) -- ./compiler/lua54.can:718
for i = 2, # t do -- ./compiler/lua54.can:719
local block = t[i] -- ./compiler/lua54.can:720
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua54.can:721
block[# block]["tag"] = "Return" -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
return lua(t, "_statexpr", "If") -- ./compiler/lua54.can:725
end, -- ./compiler/lua54.can:725
["FornumExpr"] = function(t) -- ./compiler/lua54.can:728
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua54.can:729
end, -- ./compiler/lua54.can:729
["ForinExpr"] = function(t) -- ./compiler/lua54.can:732
return lua(t, "_statexpr", "Forin") -- ./compiler/lua54.can:733
end, -- ./compiler/lua54.can:733
["Call"] = function(t) -- ./compiler/lua54.can:739
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:740
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:741
elseif t[1]["tag"] == "Id" and not nomacro["functions"][t[1][1]] and macros["functions"][t[1][1]] then -- ./compiler/lua54.can:742
local macro = macros["functions"][t[1][1]] -- ./compiler/lua54.can:743
local replacement = macro["replacement"] -- ./compiler/lua54.can:744
local r -- ./compiler/lua54.can:745
nomacro["functions"][t[1][1]] = true -- ./compiler/lua54.can:746
if type(replacement) == "function" then -- ./compiler/lua54.can:747
local args = {} -- ./compiler/lua54.can:748
for i = 2, # t do -- ./compiler/lua54.can:749
table["insert"](args, lua(t[i])) -- ./compiler/lua54.can:750
end -- ./compiler/lua54.can:750
r = replacement(unpack(args)) -- ./compiler/lua54.can:752
else -- ./compiler/lua54.can:752
local macroargs = util["merge"](peek("macroargs")) -- ./compiler/lua54.can:754
for i, arg in ipairs(macro["args"]) do -- ./compiler/lua54.can:755
if arg["tag"] == "Dots" then -- ./compiler/lua54.can:756
macroargs["..."] = (function() -- ./compiler/lua54.can:757
local self = {} -- ./compiler/lua54.can:757
for j = i + 1, # t do -- ./compiler/lua54.can:757
self[#self+1] = t[j] -- ./compiler/lua54.can:757
end -- ./compiler/lua54.can:757
return self -- ./compiler/lua54.can:757
end)() -- ./compiler/lua54.can:757
elseif arg["tag"] == "Id" then -- ./compiler/lua54.can:758
if t[i + 1] == nil then -- ./compiler/lua54.can:759
error(("bad argument #%s to macro %s (value expected)"):format(i, t[1][1])) -- ./compiler/lua54.can:760
end -- ./compiler/lua54.can:760
macroargs[arg[1]] = t[i + 1] -- ./compiler/lua54.can:762
else -- ./compiler/lua54.can:762
error(("unexpected argument type %s in macro %s"):format(arg["tag"], t[1][1])) -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
push("macroargs", macroargs) -- ./compiler/lua54.can:767
r = lua(replacement) -- ./compiler/lua54.can:768
pop("macroargs") -- ./compiler/lua54.can:769
end -- ./compiler/lua54.can:769
nomacro["functions"][t[1][1]] = nil -- ./compiler/lua54.can:771
return r -- ./compiler/lua54.can:772
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua54.can:773
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua54.can:774
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:775
else -- ./compiler/lua54.can:775
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:777
end -- ./compiler/lua54.can:777
else -- ./compiler/lua54.can:777
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:780
end -- ./compiler/lua54.can:780
end, -- ./compiler/lua54.can:780
["SafeCall"] = function(t) -- ./compiler/lua54.can:784
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:785
return lua(t, "SafeIndex") -- ./compiler/lua54.can:786
else -- ./compiler/lua54.can:786
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua54.can:788
end -- ./compiler/lua54.can:788
end, -- ./compiler/lua54.can:788
["_lhs"] = function(t, start, newlines) -- ./compiler/lua54.can:793
if start == nil then start = 1 end -- ./compiler/lua54.can:793
local r -- ./compiler/lua54.can:794
if t[start] then -- ./compiler/lua54.can:795
r = lua(t[start]) -- ./compiler/lua54.can:796
for i = start + 1, # t, 1 do -- ./compiler/lua54.can:797
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua54.can:798
end -- ./compiler/lua54.can:798
else -- ./compiler/lua54.can:798
r = "" -- ./compiler/lua54.can:801
end -- ./compiler/lua54.can:801
return r -- ./compiler/lua54.can:803
end, -- ./compiler/lua54.can:803
["Id"] = function(t) -- ./compiler/lua54.can:806
local r = t[1] -- ./compiler/lua54.can:807
local macroargs = peek("macroargs") -- ./compiler/lua54.can:808
if not nomacro["variables"][t[1]] then -- ./compiler/lua54.can:809
nomacro["variables"][t[1]] = true -- ./compiler/lua54.can:810
if macroargs and macroargs[t[1]] then -- ./compiler/lua54.can:811
r = lua(macroargs[t[1]]) -- ./compiler/lua54.can:812
elseif macros["variables"][t[1]] ~= nil then -- ./compiler/lua54.can:813
local macro = macros["variables"][t[1]] -- ./compiler/lua54.can:814
if type(macro) == "function" then -- ./compiler/lua54.can:815
r = macro() -- ./compiler/lua54.can:816
else -- ./compiler/lua54.can:816
r = lua(macro) -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
nomacro["variables"][t[1]] = nil -- ./compiler/lua54.can:821
end -- ./compiler/lua54.can:821
return r -- ./compiler/lua54.can:823
end, -- ./compiler/lua54.can:823
["AttributeId"] = function(t) -- ./compiler/lua54.can:826
if t[2] then -- ./compiler/lua54.can:827
return t[1] .. " <" .. t[2] .. ">" -- ./compiler/lua54.can:828
else -- ./compiler/lua54.can:828
return t[1] -- ./compiler/lua54.can:830
end -- ./compiler/lua54.can:830
end, -- ./compiler/lua54.can:830
["DestructuringId"] = function(t) -- ./compiler/lua54.can:834
if t["id"] then -- ./compiler/lua54.can:835
return t["id"] -- ./compiler/lua54.can:836
else -- ./compiler/lua54.can:836
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua54.can:838
local vars = { ["id"] = tmp() } -- ./compiler/lua54.can:839
for j = 1, # t, 1 do -- ./compiler/lua54.can:840
table["insert"](vars, t[j]) -- ./compiler/lua54.can:841
end -- ./compiler/lua54.can:841
table["insert"](d, vars) -- ./compiler/lua54.can:843
t["id"] = vars["id"] -- ./compiler/lua54.can:844
return vars["id"] -- ./compiler/lua54.can:845
end -- ./compiler/lua54.can:845
end, -- ./compiler/lua54.can:845
["Index"] = function(t) -- ./compiler/lua54.can:849
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:850
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:851
else -- ./compiler/lua54.can:851
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:853
end -- ./compiler/lua54.can:853
end, -- ./compiler/lua54.can:853
["SafeIndex"] = function(t) -- ./compiler/lua54.can:857
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:858
local l = {} -- ./compiler/lua54.can:859
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua54.can:860
table["insert"](l, 1, t) -- ./compiler/lua54.can:861
t = t[1] -- ./compiler/lua54.can:862
end -- ./compiler/lua54.can:862
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua54.can:864
for _, e in ipairs(l) do -- ./compiler/lua54.can:865
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua54.can:866
if e["tag"] == "SafeIndex" then -- ./compiler/lua54.can:867
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua54.can:868
else -- ./compiler/lua54.can:868
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua54.can:873
return r -- ./compiler/lua54.can:874
else -- ./compiler/lua54.can:874
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua54.can:876
end -- ./compiler/lua54.can:876
end, -- ./compiler/lua54.can:876
["_opid"] = { -- ./compiler/lua54.can:881
["add"] = "+", -- ./compiler/lua54.can:882
["sub"] = "-", -- ./compiler/lua54.can:882
["mul"] = "*", -- ./compiler/lua54.can:882
["div"] = "/", -- ./compiler/lua54.can:882
["idiv"] = "//", -- ./compiler/lua54.can:883
["mod"] = "%", -- ./compiler/lua54.can:883
["pow"] = "^", -- ./compiler/lua54.can:883
["concat"] = "..", -- ./compiler/lua54.can:883
["band"] = "&", -- ./compiler/lua54.can:884
["bor"] = "|", -- ./compiler/lua54.can:884
["bxor"] = "~", -- ./compiler/lua54.can:884
["shl"] = "<<", -- ./compiler/lua54.can:884
["shr"] = ">>", -- ./compiler/lua54.can:884
["eq"] = "==", -- ./compiler/lua54.can:885
["ne"] = "~=", -- ./compiler/lua54.can:885
["lt"] = "<", -- ./compiler/lua54.can:885
["gt"] = ">", -- ./compiler/lua54.can:885
["le"] = "<=", -- ./compiler/lua54.can:885
["ge"] = ">=", -- ./compiler/lua54.can:885
["and"] = "and", -- ./compiler/lua54.can:886
["or"] = "or", -- ./compiler/lua54.can:886
["unm"] = "-", -- ./compiler/lua54.can:886
["len"] = "#", -- ./compiler/lua54.can:886
["bnot"] = "~", -- ./compiler/lua54.can:886
["not"] = "not" -- ./compiler/lua54.can:886
} -- ./compiler/lua54.can:886
}, { ["__index"] = function(self, key) -- ./compiler/lua54.can:889
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua54.can:890
end }) -- ./compiler/lua54.can:890
targetName = "Lua 5.3" -- ./compiler/lua53.can:1
tags["AttributeId"] = function(t) -- ./compiler/lua53.can:4
if t[2] then -- ./compiler/lua53.can:5
error("target " .. targetName .. " does not support variable attributes") -- ./compiler/lua53.can:6
else -- ./compiler/lua53.can:6
return t[1] -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
local code = lua(ast) .. newline() -- ./compiler/lua54.can:896
return requireStr .. code -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
local lua54 = _() or lua54 -- ./compiler/lua54.can:902
return lua54 -- ./compiler/lua53.can:18
end -- ./compiler/lua53.can:18
local lua53 = _() or lua53 -- ./compiler/lua53.can:22
package["loaded"]["compiler.lua53"] = lua53 or true -- ./compiler/lua53.can:23
local function _() -- ./compiler/lua53.can:26
local function _() -- ./compiler/lua53.can:28
local function _() -- ./compiler/lua53.can:30
local util = require("candran.util") -- ./compiler/lua54.can:1
local targetName = "Lua 5.4" -- ./compiler/lua54.can:3
local unpack = unpack or table["unpack"] -- ./compiler/lua54.can:5
return function(code, ast, options, macros) -- ./compiler/lua54.can:7
if macros == nil then macros = { -- ./compiler/lua54.can:7
["functions"] = {}, -- ./compiler/lua54.can:7
["variables"] = {} -- ./compiler/lua54.can:7
} end -- ./compiler/lua54.can:7
local lastInputPos = 1 -- ./compiler/lua54.can:9
local prevLinePos = 1 -- ./compiler/lua54.can:10
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua54.can:11
local lastLine = 1 -- ./compiler/lua54.can:12
local indentLevel = 0 -- ./compiler/lua54.can:15
local function newline() -- ./compiler/lua54.can:17
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua54.can:18
if options["mapLines"] then -- ./compiler/lua54.can:19
local sub = code:sub(lastInputPos) -- ./compiler/lua54.can:20
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua54.can:21
if source and line then -- ./compiler/lua54.can:23
lastSource = source -- ./compiler/lua54.can:24
lastLine = tonumber(line) -- ./compiler/lua54.can:25
else -- ./compiler/lua54.can:25
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua54.can:27
lastLine = lastLine + (1) -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
prevLinePos = lastInputPos -- ./compiler/lua54.can:32
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua54.can:34
end -- ./compiler/lua54.can:34
return r -- ./compiler/lua54.can:36
end -- ./compiler/lua54.can:36
local function indent() -- ./compiler/lua54.can:39
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:40
return newline() -- ./compiler/lua54.can:41
end -- ./compiler/lua54.can:41
local function unindent() -- ./compiler/lua54.can:44
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:45
return newline() -- ./compiler/lua54.can:46
end -- ./compiler/lua54.can:46
local states = { -- ./compiler/lua54.can:51
["push"] = {}, -- ./compiler/lua54.can:52
["destructuring"] = {}, -- ./compiler/lua54.can:53
["scope"] = {}, -- ./compiler/lua54.can:54
["macroargs"] = {} -- ./compiler/lua54.can:55
} -- ./compiler/lua54.can:55
local function push(name, state) -- ./compiler/lua54.can:58
table["insert"](states[name], state) -- ./compiler/lua54.can:59
return "" -- ./compiler/lua54.can:60
end -- ./compiler/lua54.can:60
local function pop(name) -- ./compiler/lua54.can:63
table["remove"](states[name]) -- ./compiler/lua54.can:64
return "" -- ./compiler/lua54.can:65
end -- ./compiler/lua54.can:65
local function set(name, state) -- ./compiler/lua54.can:68
states[name][# states[name]] = state -- ./compiler/lua54.can:69
return "" -- ./compiler/lua54.can:70
end -- ./compiler/lua54.can:70
local function peek(name) -- ./compiler/lua54.can:73
return states[name][# states[name]] -- ./compiler/lua54.can:74
end -- ./compiler/lua54.can:74
local function var(name) -- ./compiler/lua54.can:79
return options["variablePrefix"] .. name -- ./compiler/lua54.can:80
end -- ./compiler/lua54.can:80
local function tmp() -- ./compiler/lua54.can:84
local scope = peek("scope") -- ./compiler/lua54.can:85
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua54.can:86
table["insert"](scope, var) -- ./compiler/lua54.can:87
return var -- ./compiler/lua54.can:88
end -- ./compiler/lua54.can:88
local nomacro = { -- ./compiler/lua54.can:92
["variables"] = {}, -- ./compiler/lua54.can:92
["functions"] = {} -- ./compiler/lua54.can:92
} -- ./compiler/lua54.can:92
local required = {} -- ./compiler/lua54.can:95
local requireStr = "" -- ./compiler/lua54.can:96
local function addRequire(mod, name, field) -- ./compiler/lua54.can:98
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua54.can:99
if not required[req] then -- ./compiler/lua54.can:100
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua54.can:101
required[req] = true -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
local loop = { -- ./compiler/lua54.can:107
"While", -- ./compiler/lua54.can:107
"Repeat", -- ./compiler/lua54.can:107
"Fornum", -- ./compiler/lua54.can:107
"Forin", -- ./compiler/lua54.can:107
"WhileExpr", -- ./compiler/lua54.can:107
"RepeatExpr", -- ./compiler/lua54.can:107
"FornumExpr", -- ./compiler/lua54.can:107
"ForinExpr" -- ./compiler/lua54.can:107
} -- ./compiler/lua54.can:107
local func = { -- ./compiler/lua54.can:108
"Function", -- ./compiler/lua54.can:108
"TableCompr", -- ./compiler/lua54.can:108
"DoExpr", -- ./compiler/lua54.can:108
"WhileExpr", -- ./compiler/lua54.can:108
"RepeatExpr", -- ./compiler/lua54.can:108
"IfExpr", -- ./compiler/lua54.can:108
"FornumExpr", -- ./compiler/lua54.can:108
"ForinExpr" -- ./compiler/lua54.can:108
} -- ./compiler/lua54.can:108
local function any(list, tags, nofollow) -- ./compiler/lua54.can:112
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:112
local tagsCheck = {} -- ./compiler/lua54.can:113
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:114
tagsCheck[tag] = true -- ./compiler/lua54.can:115
end -- ./compiler/lua54.can:115
local nofollowCheck = {} -- ./compiler/lua54.can:117
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:118
nofollowCheck[tag] = true -- ./compiler/lua54.can:119
end -- ./compiler/lua54.can:119
for _, node in ipairs(list) do -- ./compiler/lua54.can:121
if type(node) == "table" then -- ./compiler/lua54.can:122
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:123
return node -- ./compiler/lua54.can:124
end -- ./compiler/lua54.can:124
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:126
local r = any(node, tags, nofollow) -- ./compiler/lua54.can:127
if r then -- ./compiler/lua54.can:128
return r -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
return nil -- ./compiler/lua54.can:132
end -- ./compiler/lua54.can:132
local function search(list, tags, nofollow) -- ./compiler/lua54.can:137
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:137
local tagsCheck = {} -- ./compiler/lua54.can:138
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:139
tagsCheck[tag] = true -- ./compiler/lua54.can:140
end -- ./compiler/lua54.can:140
local nofollowCheck = {} -- ./compiler/lua54.can:142
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:143
nofollowCheck[tag] = true -- ./compiler/lua54.can:144
end -- ./compiler/lua54.can:144
local found = {} -- ./compiler/lua54.can:146
for _, node in ipairs(list) do -- ./compiler/lua54.can:147
if type(node) == "table" then -- ./compiler/lua54.can:148
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:149
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua54.can:150
table["insert"](found, n) -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:154
table["insert"](found, node) -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
return found -- ./compiler/lua54.can:159
end -- ./compiler/lua54.can:159
local function all(list, tags) -- ./compiler/lua54.can:163
for _, node in ipairs(list) do -- ./compiler/lua54.can:164
local ok = false -- ./compiler/lua54.can:165
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:166
if node["tag"] == tag then -- ./compiler/lua54.can:167
ok = true -- ./compiler/lua54.can:168
break -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
if not ok then -- ./compiler/lua54.can:172
return false -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
return true -- ./compiler/lua54.can:176
end -- ./compiler/lua54.can:176
local tags -- ./compiler/lua54.can:180
local function lua(ast, forceTag, ...) -- ./compiler/lua54.can:182
if options["mapLines"] and ast["pos"] then -- ./compiler/lua54.can:183
lastInputPos = ast["pos"] -- ./compiler/lua54.can:184
end -- ./compiler/lua54.can:184
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua54.can:186
end -- ./compiler/lua54.can:186
local UNPACK = function(list, i, j) -- ./compiler/lua54.can:190
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua54.can:191
end -- ./compiler/lua54.can:191
local APPEND = function(t, toAppend) -- ./compiler/lua54.can:193
return "do" .. indent() .. "local " .. var("a") .. " = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(" .. var("a") .. ", 1, " .. var("a") .. ".n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua54.can:194
end -- ./compiler/lua54.can:194
local CONTINUE_START = function() -- ./compiler/lua54.can:196
return "do" .. indent() -- ./compiler/lua54.can:197
end -- ./compiler/lua54.can:197
local CONTINUE_STOP = function() -- ./compiler/lua54.can:199
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua54.can:200
end -- ./compiler/lua54.can:200
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua54.can:202
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua54.can:202
if noLocal == nil then noLocal = false end -- ./compiler/lua54.can:202
local vars = {} -- ./compiler/lua54.can:203
local values = {} -- ./compiler/lua54.can:204
for _, list in ipairs(destructured) do -- ./compiler/lua54.can:205
for _, v in ipairs(list) do -- ./compiler/lua54.can:206
local var, val -- ./compiler/lua54.can:207
if v["tag"] == "Id" or v["tag"] == "AttributeId" then -- ./compiler/lua54.can:208
var = v -- ./compiler/lua54.can:209
val = { -- ./compiler/lua54.can:210
["tag"] = "Index", -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "Id", -- ./compiler/lua54.can:210
list["id"] -- ./compiler/lua54.can:210
}, -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "String", -- ./compiler/lua54.can:210
v[1] -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
elseif v["tag"] == "Pair" then -- ./compiler/lua54.can:211
var = v[2] -- ./compiler/lua54.can:212
val = { -- ./compiler/lua54.can:213
["tag"] = "Index", -- ./compiler/lua54.can:213
{ -- ./compiler/lua54.can:213
["tag"] = "Id", -- ./compiler/lua54.can:213
list["id"] -- ./compiler/lua54.can:213
}, -- ./compiler/lua54.can:213
v[1] -- ./compiler/lua54.can:213
} -- ./compiler/lua54.can:213
else -- ./compiler/lua54.can:213
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua54.can:215
end -- ./compiler/lua54.can:215
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua54.can:217
val = { -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["rightOp"], -- ./compiler/lua54.can:218
var, -- ./compiler/lua54.can:218
{ -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["leftOp"], -- ./compiler/lua54.can:218
val, -- ./compiler/lua54.can:218
var -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
elseif destructured["rightOp"] then -- ./compiler/lua54.can:219
val = { -- ./compiler/lua54.can:220
["tag"] = "Op", -- ./compiler/lua54.can:220
destructured["rightOp"], -- ./compiler/lua54.can:220
var, -- ./compiler/lua54.can:220
val -- ./compiler/lua54.can:220
} -- ./compiler/lua54.can:220
elseif destructured["leftOp"] then -- ./compiler/lua54.can:221
val = { -- ./compiler/lua54.can:222
["tag"] = "Op", -- ./compiler/lua54.can:222
destructured["leftOp"], -- ./compiler/lua54.can:222
val, -- ./compiler/lua54.can:222
var -- ./compiler/lua54.can:222
} -- ./compiler/lua54.can:222
end -- ./compiler/lua54.can:222
table["insert"](vars, lua(var)) -- ./compiler/lua54.can:224
table["insert"](values, lua(val)) -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
if # vars > 0 then -- ./compiler/lua54.can:228
local decl = noLocal and "" or "local " -- ./compiler/lua54.can:229
if newlineAfter then -- ./compiler/lua54.can:230
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua54.can:231
else -- ./compiler/lua54.can:231
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua54.can:233
end -- ./compiler/lua54.can:233
else -- ./compiler/lua54.can:233
return "" -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
tags = setmetatable({ -- ./compiler/lua54.can:241
["Block"] = function(t) -- ./compiler/lua54.can:243
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua54.can:244
if hasPush and hasPush == t[# t] then -- ./compiler/lua54.can:245
hasPush["tag"] = "Return" -- ./compiler/lua54.can:246
hasPush = false -- ./compiler/lua54.can:247
end -- ./compiler/lua54.can:247
local r = push("scope", {}) -- ./compiler/lua54.can:249
if hasPush then -- ./compiler/lua54.can:250
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:251
end -- ./compiler/lua54.can:251
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:253
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua54.can:254
end -- ./compiler/lua54.can:254
if t[# t] then -- ./compiler/lua54.can:256
r = r .. (lua(t[# t])) -- ./compiler/lua54.can:257
end -- ./compiler/lua54.can:257
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua54.can:259
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua54.can:260
end -- ./compiler/lua54.can:260
return r .. pop("scope") -- ./compiler/lua54.can:262
end, -- ./compiler/lua54.can:262
["Do"] = function(t) -- ./compiler/lua54.can:268
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua54.can:269
end, -- ./compiler/lua54.can:269
["Set"] = function(t) -- ./compiler/lua54.can:272
local expr = t[# t] -- ./compiler/lua54.can:274
local vars, values = {}, {} -- ./compiler/lua54.can:275
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua54.can:276
for i, n in ipairs(t[1]) do -- ./compiler/lua54.can:277
if n["tag"] == "DestructuringId" then -- ./compiler/lua54.can:278
table["insert"](destructuringVars, n) -- ./compiler/lua54.can:279
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua54.can:280
else -- ./compiler/lua54.can:280
table["insert"](vars, n) -- ./compiler/lua54.can:282
table["insert"](values, expr[i]) -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
if # t == 2 or # t == 3 then -- ./compiler/lua54.can:287
local r = "" -- ./compiler/lua54.can:288
if # vars > 0 then -- ./compiler/lua54.can:289
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua54.can:290
end -- ./compiler/lua54.can:290
if # destructuringVars > 0 then -- ./compiler/lua54.can:292
local destructured = {} -- ./compiler/lua54.can:293
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:294
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:295
end -- ./compiler/lua54.can:295
return r -- ./compiler/lua54.can:297
elseif # t == 4 then -- ./compiler/lua54.can:298
if t[3] == "=" then -- ./compiler/lua54.can:299
local r = "" -- ./compiler/lua54.can:300
if # vars > 0 then -- ./compiler/lua54.can:301
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:302
t[2], -- ./compiler/lua54.can:302
vars[1], -- ./compiler/lua54.can:302
{ -- ./compiler/lua54.can:302
["tag"] = "Paren", -- ./compiler/lua54.can:302
values[1] -- ./compiler/lua54.can:302
} -- ./compiler/lua54.can:302
}, "Op")) -- ./compiler/lua54.can:302
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua54.can:303
r = r .. (", " .. lua({ -- ./compiler/lua54.can:304
t[2], -- ./compiler/lua54.can:304
vars[i], -- ./compiler/lua54.can:304
{ -- ./compiler/lua54.can:304
["tag"] = "Paren", -- ./compiler/lua54.can:304
values[i] -- ./compiler/lua54.can:304
} -- ./compiler/lua54.can:304
}, "Op")) -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
if # destructuringVars > 0 then -- ./compiler/lua54.can:307
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua54.can:308
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:309
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:310
end -- ./compiler/lua54.can:310
return r -- ./compiler/lua54.can:312
else -- ./compiler/lua54.can:312
local r = "" -- ./compiler/lua54.can:314
if # vars > 0 then -- ./compiler/lua54.can:315
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:316
t[3], -- ./compiler/lua54.can:316
{ -- ./compiler/lua54.can:316
["tag"] = "Paren", -- ./compiler/lua54.can:316
values[1] -- ./compiler/lua54.can:316
}, -- ./compiler/lua54.can:316
vars[1] -- ./compiler/lua54.can:316
}, "Op")) -- ./compiler/lua54.can:316
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua54.can:317
r = r .. (", " .. lua({ -- ./compiler/lua54.can:318
t[3], -- ./compiler/lua54.can:318
{ -- ./compiler/lua54.can:318
["tag"] = "Paren", -- ./compiler/lua54.can:318
values[i] -- ./compiler/lua54.can:318
}, -- ./compiler/lua54.can:318
vars[i] -- ./compiler/lua54.can:318
}, "Op")) -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
if # destructuringVars > 0 then -- ./compiler/lua54.can:321
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua54.can:322
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:323
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:324
end -- ./compiler/lua54.can:324
return r -- ./compiler/lua54.can:326
end -- ./compiler/lua54.can:326
else -- ./compiler/lua54.can:326
local r = "" -- ./compiler/lua54.can:329
if # vars > 0 then -- ./compiler/lua54.can:330
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:331
t[2], -- ./compiler/lua54.can:331
vars[1], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Op", -- ./compiler/lua54.can:331
t[4], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Paren", -- ./compiler/lua54.can:331
values[1] -- ./compiler/lua54.can:331
}, -- ./compiler/lua54.can:331
vars[1] -- ./compiler/lua54.can:331
} -- ./compiler/lua54.can:331
}, "Op")) -- ./compiler/lua54.can:331
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua54.can:332
r = r .. (", " .. lua({ -- ./compiler/lua54.can:333
t[2], -- ./compiler/lua54.can:333
vars[i], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Op", -- ./compiler/lua54.can:333
t[4], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Paren", -- ./compiler/lua54.can:333
values[i] -- ./compiler/lua54.can:333
}, -- ./compiler/lua54.can:333
vars[i] -- ./compiler/lua54.can:333
} -- ./compiler/lua54.can:333
}, "Op")) -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
if # destructuringVars > 0 then -- ./compiler/lua54.can:336
local destructured = { -- ./compiler/lua54.can:337
["rightOp"] = t[2], -- ./compiler/lua54.can:337
["leftOp"] = t[4] -- ./compiler/lua54.can:337
} -- ./compiler/lua54.can:337
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:338
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:339
end -- ./compiler/lua54.can:339
return r -- ./compiler/lua54.can:341
end -- ./compiler/lua54.can:341
end, -- ./compiler/lua54.can:341
["While"] = function(t) -- ./compiler/lua54.can:345
local r = "" -- ./compiler/lua54.can:346
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua54.can:347
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:348
if # lets > 0 then -- ./compiler/lua54.can:349
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:350
for _, l in ipairs(lets) do -- ./compiler/lua54.can:351
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua54.can:355
if # lets > 0 then -- ./compiler/lua54.can:356
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:357
end -- ./compiler/lua54.can:357
if hasContinue then -- ./compiler/lua54.can:359
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:360
end -- ./compiler/lua54.can:360
r = r .. (lua(t[2])) -- ./compiler/lua54.can:362
if hasContinue then -- ./compiler/lua54.can:363
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:364
end -- ./compiler/lua54.can:364
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:366
if # lets > 0 then -- ./compiler/lua54.can:367
for _, l in ipairs(lets) do -- ./compiler/lua54.can:368
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua54.can:369
end -- ./compiler/lua54.can:369
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua54.can:371
end -- ./compiler/lua54.can:371
return r -- ./compiler/lua54.can:373
end, -- ./compiler/lua54.can:373
["Repeat"] = function(t) -- ./compiler/lua54.can:376
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua54.can:377
local r = "repeat" .. indent() -- ./compiler/lua54.can:378
if hasContinue then -- ./compiler/lua54.can:379
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:380
end -- ./compiler/lua54.can:380
r = r .. (lua(t[1])) -- ./compiler/lua54.can:382
if hasContinue then -- ./compiler/lua54.can:383
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:384
end -- ./compiler/lua54.can:384
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua54.can:386
return r -- ./compiler/lua54.can:387
end, -- ./compiler/lua54.can:387
["If"] = function(t) -- ./compiler/lua54.can:390
local r = "" -- ./compiler/lua54.can:391
local toClose = 0 -- ./compiler/lua54.can:392
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:393
if # lets > 0 then -- ./compiler/lua54.can:394
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:395
toClose = toClose + (1) -- ./compiler/lua54.can:396
for _, l in ipairs(lets) do -- ./compiler/lua54.can:397
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua54.can:401
for i = 3, # t - 1, 2 do -- ./compiler/lua54.can:402
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua54.can:403
if # lets > 0 then -- ./compiler/lua54.can:404
r = r .. ("else" .. indent()) -- ./compiler/lua54.can:405
toClose = toClose + (1) -- ./compiler/lua54.can:406
for _, l in ipairs(lets) do -- ./compiler/lua54.can:407
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:408
end -- ./compiler/lua54.can:408
else -- ./compiler/lua54.can:408
r = r .. ("else") -- ./compiler/lua54.can:411
end -- ./compiler/lua54.can:411
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua54.can:413
end -- ./compiler/lua54.can:413
if # t % 2 == 1 then -- ./compiler/lua54.can:415
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua54.can:416
end -- ./compiler/lua54.can:416
r = r .. ("end") -- ./compiler/lua54.can:418
for i = 1, toClose do -- ./compiler/lua54.can:419
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:420
end -- ./compiler/lua54.can:420
return r -- ./compiler/lua54.can:422
end, -- ./compiler/lua54.can:422
["Fornum"] = function(t) -- ./compiler/lua54.can:425
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua54.can:426
if # t == 5 then -- ./compiler/lua54.can:427
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua54.can:428
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua54.can:429
if hasContinue then -- ./compiler/lua54.can:430
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:431
end -- ./compiler/lua54.can:431
r = r .. (lua(t[5])) -- ./compiler/lua54.can:433
if hasContinue then -- ./compiler/lua54.can:434
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:435
end -- ./compiler/lua54.can:435
return r .. unindent() .. "end" -- ./compiler/lua54.can:437
else -- ./compiler/lua54.can:437
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua54.can:439
r = r .. (" do" .. indent()) -- ./compiler/lua54.can:440
if hasContinue then -- ./compiler/lua54.can:441
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:442
end -- ./compiler/lua54.can:442
r = r .. (lua(t[4])) -- ./compiler/lua54.can:444
if hasContinue then -- ./compiler/lua54.can:445
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:446
end -- ./compiler/lua54.can:446
return r .. unindent() .. "end" -- ./compiler/lua54.can:448
end -- ./compiler/lua54.can:448
end, -- ./compiler/lua54.can:448
["Forin"] = function(t) -- ./compiler/lua54.can:452
local destructured = {} -- ./compiler/lua54.can:453
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua54.can:454
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua54.can:455
if hasContinue then -- ./compiler/lua54.can:456
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:457
end -- ./compiler/lua54.can:457
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua54.can:459
if hasContinue then -- ./compiler/lua54.can:460
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:461
end -- ./compiler/lua54.can:461
return r .. unindent() .. "end" -- ./compiler/lua54.can:463
end, -- ./compiler/lua54.can:463
["Local"] = function(t) -- ./compiler/lua54.can:466
local destructured = {} -- ./compiler/lua54.can:467
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:468
if t[2][1] then -- ./compiler/lua54.can:469
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:470
end -- ./compiler/lua54.can:470
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:472
end, -- ./compiler/lua54.can:472
["Let"] = function(t) -- ./compiler/lua54.can:475
local destructured = {} -- ./compiler/lua54.can:476
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:477
local r = "local " .. nameList -- ./compiler/lua54.can:478
if t[2][1] then -- ./compiler/lua54.can:479
if all(t[2], { -- ./compiler/lua54.can:480
"Nil", -- ./compiler/lua54.can:480
"Dots", -- ./compiler/lua54.can:480
"Boolean", -- ./compiler/lua54.can:480
"Number", -- ./compiler/lua54.can:480
"String" -- ./compiler/lua54.can:480
}) then -- ./compiler/lua54.can:480
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:481
else -- ./compiler/lua54.can:481
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:486
end, -- ./compiler/lua54.can:486
["Localrec"] = function(t) -- ./compiler/lua54.can:489
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua54.can:490
end, -- ./compiler/lua54.can:490
["Goto"] = function(t) -- ./compiler/lua54.can:493
return "goto " .. lua(t, "Id") -- ./compiler/lua54.can:494
end, -- ./compiler/lua54.can:494
["Label"] = function(t) -- ./compiler/lua54.can:497
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua54.can:498
end, -- ./compiler/lua54.can:498
["Return"] = function(t) -- ./compiler/lua54.can:501
local push = peek("push") -- ./compiler/lua54.can:502
if push then -- ./compiler/lua54.can:503
local r = "" -- ./compiler/lua54.can:504
for _, val in ipairs(t) do -- ./compiler/lua54.can:505
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua54.can:506
end -- ./compiler/lua54.can:506
return r .. "return " .. UNPACK(push) -- ./compiler/lua54.can:508
else -- ./compiler/lua54.can:508
return "return " .. lua(t, "_lhs") -- ./compiler/lua54.can:510
end -- ./compiler/lua54.can:510
end, -- ./compiler/lua54.can:510
["Push"] = function(t) -- ./compiler/lua54.can:514
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua54.can:515
r = "" -- ./compiler/lua54.can:516
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:517
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua54.can:518
end -- ./compiler/lua54.can:518
if t[# t] then -- ./compiler/lua54.can:520
if t[# t]["tag"] == "Call" then -- ./compiler/lua54.can:521
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua54.can:522
else -- ./compiler/lua54.can:522
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
return r -- ./compiler/lua54.can:527
end, -- ./compiler/lua54.can:527
["Break"] = function() -- ./compiler/lua54.can:530
return "break" -- ./compiler/lua54.can:531
end, -- ./compiler/lua54.can:531
["Continue"] = function() -- ./compiler/lua54.can:534
return "goto " .. var("continue") -- ./compiler/lua54.can:535
end, -- ./compiler/lua54.can:535
["Nil"] = function() -- ./compiler/lua54.can:542
return "nil" -- ./compiler/lua54.can:543
end, -- ./compiler/lua54.can:543
["Dots"] = function() -- ./compiler/lua54.can:546
local macroargs = peek("macroargs") -- ./compiler/lua54.can:547
if macroargs and not nomacro["variables"]["..."] and macroargs["..."] then -- ./compiler/lua54.can:548
nomacro["variables"]["..."] = true -- ./compiler/lua54.can:549
local r = lua(macroargs["..."], "_lhs") -- ./compiler/lua54.can:550
nomacro["variables"]["..."] = nil -- ./compiler/lua54.can:551
return r -- ./compiler/lua54.can:552
else -- ./compiler/lua54.can:552
return "..." -- ./compiler/lua54.can:554
end -- ./compiler/lua54.can:554
end, -- ./compiler/lua54.can:554
["Boolean"] = function(t) -- ./compiler/lua54.can:558
return tostring(t[1]) -- ./compiler/lua54.can:559
end, -- ./compiler/lua54.can:559
["Number"] = function(t) -- ./compiler/lua54.can:562
return tostring(t[1]) -- ./compiler/lua54.can:563
end, -- ./compiler/lua54.can:563
["String"] = function(t) -- ./compiler/lua54.can:566
return ("%q"):format(t[1]) -- ./compiler/lua54.can:567
end, -- ./compiler/lua54.can:567
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua54.can:570
local r = "(" -- ./compiler/lua54.can:571
local decl = {} -- ./compiler/lua54.can:572
if t[1][1] then -- ./compiler/lua54.can:573
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua54.can:574
local id = lua(t[1][1][1]) -- ./compiler/lua54.can:575
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:576
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua54.can:577
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:578
r = r .. (id) -- ./compiler/lua54.can:579
else -- ./compiler/lua54.can:579
r = r .. (lua(t[1][1])) -- ./compiler/lua54.can:581
end -- ./compiler/lua54.can:581
for i = 2, # t[1], 1 do -- ./compiler/lua54.can:583
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua54.can:584
local id = lua(t[1][i][1]) -- ./compiler/lua54.can:585
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:586
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua54.can:587
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:588
r = r .. (", " .. id) -- ./compiler/lua54.can:589
else -- ./compiler/lua54.can:589
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
r = r .. (")" .. indent()) -- ./compiler/lua54.can:595
for _, d in ipairs(decl) do -- ./compiler/lua54.can:596
r = r .. (d .. newline()) -- ./compiler/lua54.can:597
end -- ./compiler/lua54.can:597
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua54.can:599
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua54.can:600
end -- ./compiler/lua54.can:600
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua54.can:602
if hasPush then -- ./compiler/lua54.can:603
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:604
else -- ./compiler/lua54.can:604
push("push", false) -- ./compiler/lua54.can:606
end -- ./compiler/lua54.can:606
r = r .. (lua(t[2])) -- ./compiler/lua54.can:608
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua54.can:609
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:610
end -- ./compiler/lua54.can:610
pop("push") -- ./compiler/lua54.can:612
return r .. unindent() .. "end" -- ./compiler/lua54.can:613
end, -- ./compiler/lua54.can:613
["Function"] = function(t) -- ./compiler/lua54.can:615
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua54.can:616
end, -- ./compiler/lua54.can:616
["Pair"] = function(t) -- ./compiler/lua54.can:619
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua54.can:620
end, -- ./compiler/lua54.can:620
["Table"] = function(t) -- ./compiler/lua54.can:622
if # t == 0 then -- ./compiler/lua54.can:623
return "{}" -- ./compiler/lua54.can:624
elseif # t == 1 then -- ./compiler/lua54.can:625
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua54.can:626
else -- ./compiler/lua54.can:626
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua54.can:628
end -- ./compiler/lua54.can:628
end, -- ./compiler/lua54.can:628
["TableCompr"] = function(t) -- ./compiler/lua54.can:632
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua54.can:633
end, -- ./compiler/lua54.can:633
["Op"] = function(t) -- ./compiler/lua54.can:636
local r -- ./compiler/lua54.can:637
if # t == 2 then -- ./compiler/lua54.can:638
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:639
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua54.can:640
else -- ./compiler/lua54.can:640
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua54.can:642
end -- ./compiler/lua54.can:642
else -- ./compiler/lua54.can:642
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:645
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua54.can:646
else -- ./compiler/lua54.can:646
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
return r -- ./compiler/lua54.can:651
end, -- ./compiler/lua54.can:651
["Paren"] = function(t) -- ./compiler/lua54.can:654
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua54.can:655
end, -- ./compiler/lua54.can:655
["MethodStub"] = function(t) -- ./compiler/lua54.can:658
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:664
end, -- ./compiler/lua54.can:664
["SafeMethodStub"] = function(t) -- ./compiler/lua54.can:667
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:674
end, -- ./compiler/lua54.can:674
["LetExpr"] = function(t) -- ./compiler/lua54.can:681
return lua(t[1][1]) -- ./compiler/lua54.can:682
end, -- ./compiler/lua54.can:682
["_statexpr"] = function(t, stat) -- ./compiler/lua54.can:686
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua54.can:687
local r = "(function()" .. indent() -- ./compiler/lua54.can:688
if hasPush then -- ./compiler/lua54.can:689
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:690
else -- ./compiler/lua54.can:690
push("push", false) -- ./compiler/lua54.can:692
end -- ./compiler/lua54.can:692
r = r .. (lua(t, stat)) -- ./compiler/lua54.can:694
if hasPush then -- ./compiler/lua54.can:695
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:696
end -- ./compiler/lua54.can:696
pop("push") -- ./compiler/lua54.can:698
r = r .. (unindent() .. "end)()") -- ./compiler/lua54.can:699
return r -- ./compiler/lua54.can:700
end, -- ./compiler/lua54.can:700
["DoExpr"] = function(t) -- ./compiler/lua54.can:703
if t[# t]["tag"] == "Push" then -- ./compiler/lua54.can:704
t[# t]["tag"] = "Return" -- ./compiler/lua54.can:705
end -- ./compiler/lua54.can:705
return lua(t, "_statexpr", "Do") -- ./compiler/lua54.can:707
end, -- ./compiler/lua54.can:707
["WhileExpr"] = function(t) -- ./compiler/lua54.can:710
return lua(t, "_statexpr", "While") -- ./compiler/lua54.can:711
end, -- ./compiler/lua54.can:711
["RepeatExpr"] = function(t) -- ./compiler/lua54.can:714
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua54.can:715
end, -- ./compiler/lua54.can:715
["IfExpr"] = function(t) -- ./compiler/lua54.can:718
for i = 2, # t do -- ./compiler/lua54.can:719
local block = t[i] -- ./compiler/lua54.can:720
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua54.can:721
block[# block]["tag"] = "Return" -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
return lua(t, "_statexpr", "If") -- ./compiler/lua54.can:725
end, -- ./compiler/lua54.can:725
["FornumExpr"] = function(t) -- ./compiler/lua54.can:728
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua54.can:729
end, -- ./compiler/lua54.can:729
["ForinExpr"] = function(t) -- ./compiler/lua54.can:732
return lua(t, "_statexpr", "Forin") -- ./compiler/lua54.can:733
end, -- ./compiler/lua54.can:733
["Call"] = function(t) -- ./compiler/lua54.can:739
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:740
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:741
elseif t[1]["tag"] == "Id" and not nomacro["functions"][t[1][1]] and macros["functions"][t[1][1]] then -- ./compiler/lua54.can:742
local macro = macros["functions"][t[1][1]] -- ./compiler/lua54.can:743
local replacement = macro["replacement"] -- ./compiler/lua54.can:744
local r -- ./compiler/lua54.can:745
nomacro["functions"][t[1][1]] = true -- ./compiler/lua54.can:746
if type(replacement) == "function" then -- ./compiler/lua54.can:747
local args = {} -- ./compiler/lua54.can:748
for i = 2, # t do -- ./compiler/lua54.can:749
table["insert"](args, lua(t[i])) -- ./compiler/lua54.can:750
end -- ./compiler/lua54.can:750
r = replacement(unpack(args)) -- ./compiler/lua54.can:752
else -- ./compiler/lua54.can:752
local macroargs = util["merge"](peek("macroargs")) -- ./compiler/lua54.can:754
for i, arg in ipairs(macro["args"]) do -- ./compiler/lua54.can:755
if arg["tag"] == "Dots" then -- ./compiler/lua54.can:756
macroargs["..."] = (function() -- ./compiler/lua54.can:757
local self = {} -- ./compiler/lua54.can:757
for j = i + 1, # t do -- ./compiler/lua54.can:757
self[#self+1] = t[j] -- ./compiler/lua54.can:757
end -- ./compiler/lua54.can:757
return self -- ./compiler/lua54.can:757
end)() -- ./compiler/lua54.can:757
elseif arg["tag"] == "Id" then -- ./compiler/lua54.can:758
if t[i + 1] == nil then -- ./compiler/lua54.can:759
error(("bad argument #%s to macro %s (value expected)"):format(i, t[1][1])) -- ./compiler/lua54.can:760
end -- ./compiler/lua54.can:760
macroargs[arg[1]] = t[i + 1] -- ./compiler/lua54.can:762
else -- ./compiler/lua54.can:762
error(("unexpected argument type %s in macro %s"):format(arg["tag"], t[1][1])) -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
push("macroargs", macroargs) -- ./compiler/lua54.can:767
r = lua(replacement) -- ./compiler/lua54.can:768
pop("macroargs") -- ./compiler/lua54.can:769
end -- ./compiler/lua54.can:769
nomacro["functions"][t[1][1]] = nil -- ./compiler/lua54.can:771
return r -- ./compiler/lua54.can:772
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua54.can:773
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua54.can:774
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:775
else -- ./compiler/lua54.can:775
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:777
end -- ./compiler/lua54.can:777
else -- ./compiler/lua54.can:777
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:780
end -- ./compiler/lua54.can:780
end, -- ./compiler/lua54.can:780
["SafeCall"] = function(t) -- ./compiler/lua54.can:784
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:785
return lua(t, "SafeIndex") -- ./compiler/lua54.can:786
else -- ./compiler/lua54.can:786
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua54.can:788
end -- ./compiler/lua54.can:788
end, -- ./compiler/lua54.can:788
["_lhs"] = function(t, start, newlines) -- ./compiler/lua54.can:793
if start == nil then start = 1 end -- ./compiler/lua54.can:793
local r -- ./compiler/lua54.can:794
if t[start] then -- ./compiler/lua54.can:795
r = lua(t[start]) -- ./compiler/lua54.can:796
for i = start + 1, # t, 1 do -- ./compiler/lua54.can:797
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua54.can:798
end -- ./compiler/lua54.can:798
else -- ./compiler/lua54.can:798
r = "" -- ./compiler/lua54.can:801
end -- ./compiler/lua54.can:801
return r -- ./compiler/lua54.can:803
end, -- ./compiler/lua54.can:803
["Id"] = function(t) -- ./compiler/lua54.can:806
local r = t[1] -- ./compiler/lua54.can:807
local macroargs = peek("macroargs") -- ./compiler/lua54.can:808
if not nomacro["variables"][t[1]] then -- ./compiler/lua54.can:809
nomacro["variables"][t[1]] = true -- ./compiler/lua54.can:810
if macroargs and macroargs[t[1]] then -- ./compiler/lua54.can:811
r = lua(macroargs[t[1]]) -- ./compiler/lua54.can:812
elseif macros["variables"][t[1]] ~= nil then -- ./compiler/lua54.can:813
local macro = macros["variables"][t[1]] -- ./compiler/lua54.can:814
if type(macro) == "function" then -- ./compiler/lua54.can:815
r = macro() -- ./compiler/lua54.can:816
else -- ./compiler/lua54.can:816
r = lua(macro) -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
nomacro["variables"][t[1]] = nil -- ./compiler/lua54.can:821
end -- ./compiler/lua54.can:821
return r -- ./compiler/lua54.can:823
end, -- ./compiler/lua54.can:823
["AttributeId"] = function(t) -- ./compiler/lua54.can:826
if t[2] then -- ./compiler/lua54.can:827
return t[1] .. " <" .. t[2] .. ">" -- ./compiler/lua54.can:828
else -- ./compiler/lua54.can:828
return t[1] -- ./compiler/lua54.can:830
end -- ./compiler/lua54.can:830
end, -- ./compiler/lua54.can:830
["DestructuringId"] = function(t) -- ./compiler/lua54.can:834
if t["id"] then -- ./compiler/lua54.can:835
return t["id"] -- ./compiler/lua54.can:836
else -- ./compiler/lua54.can:836
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua54.can:838
local vars = { ["id"] = tmp() } -- ./compiler/lua54.can:839
for j = 1, # t, 1 do -- ./compiler/lua54.can:840
table["insert"](vars, t[j]) -- ./compiler/lua54.can:841
end -- ./compiler/lua54.can:841
table["insert"](d, vars) -- ./compiler/lua54.can:843
t["id"] = vars["id"] -- ./compiler/lua54.can:844
return vars["id"] -- ./compiler/lua54.can:845
end -- ./compiler/lua54.can:845
end, -- ./compiler/lua54.can:845
["Index"] = function(t) -- ./compiler/lua54.can:849
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:850
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:851
else -- ./compiler/lua54.can:851
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:853
end -- ./compiler/lua54.can:853
end, -- ./compiler/lua54.can:853
["SafeIndex"] = function(t) -- ./compiler/lua54.can:857
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:858
local l = {} -- ./compiler/lua54.can:859
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua54.can:860
table["insert"](l, 1, t) -- ./compiler/lua54.can:861
t = t[1] -- ./compiler/lua54.can:862
end -- ./compiler/lua54.can:862
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua54.can:864
for _, e in ipairs(l) do -- ./compiler/lua54.can:865
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua54.can:866
if e["tag"] == "SafeIndex" then -- ./compiler/lua54.can:867
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua54.can:868
else -- ./compiler/lua54.can:868
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua54.can:873
return r -- ./compiler/lua54.can:874
else -- ./compiler/lua54.can:874
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua54.can:876
end -- ./compiler/lua54.can:876
end, -- ./compiler/lua54.can:876
["_opid"] = { -- ./compiler/lua54.can:881
["add"] = "+", -- ./compiler/lua54.can:882
["sub"] = "-", -- ./compiler/lua54.can:882
["mul"] = "*", -- ./compiler/lua54.can:882
["div"] = "/", -- ./compiler/lua54.can:882
["idiv"] = "//", -- ./compiler/lua54.can:883
["mod"] = "%", -- ./compiler/lua54.can:883
["pow"] = "^", -- ./compiler/lua54.can:883
["concat"] = "..", -- ./compiler/lua54.can:883
["band"] = "&", -- ./compiler/lua54.can:884
["bor"] = "|", -- ./compiler/lua54.can:884
["bxor"] = "~", -- ./compiler/lua54.can:884
["shl"] = "<<", -- ./compiler/lua54.can:884
["shr"] = ">>", -- ./compiler/lua54.can:884
["eq"] = "==", -- ./compiler/lua54.can:885
["ne"] = "~=", -- ./compiler/lua54.can:885
["lt"] = "<", -- ./compiler/lua54.can:885
["gt"] = ">", -- ./compiler/lua54.can:885
["le"] = "<=", -- ./compiler/lua54.can:885
["ge"] = ">=", -- ./compiler/lua54.can:885
["and"] = "and", -- ./compiler/lua54.can:886
["or"] = "or", -- ./compiler/lua54.can:886
["unm"] = "-", -- ./compiler/lua54.can:886
["len"] = "#", -- ./compiler/lua54.can:886
["bnot"] = "~", -- ./compiler/lua54.can:886
["not"] = "not" -- ./compiler/lua54.can:886
} -- ./compiler/lua54.can:886
}, { ["__index"] = function(self, key) -- ./compiler/lua54.can:889
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua54.can:890
end }) -- ./compiler/lua54.can:890
targetName = "Lua 5.3" -- ./compiler/lua53.can:1
tags["AttributeId"] = function(t) -- ./compiler/lua53.can:4
if t[2] then -- ./compiler/lua53.can:5
error("target " .. targetName .. " does not support variable attributes") -- ./compiler/lua53.can:6
else -- ./compiler/lua53.can:6
return t[1] -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
targetName = "Lua 5.2" -- ./compiler/lua52.can:1
APPEND = function(t, toAppend) -- ./compiler/lua52.can:3
return "do" .. indent() .. "local " .. var("a") .. ", " .. var("p") .. " = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #" .. var("a") .. " do" .. indent() .. t .. "[" .. var("p") .. "] = " .. var("a") .. "[i]" .. newline() .. "" .. var("p") .. " = " .. var("p") .. " + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/lua52.can:4
end -- ./compiler/lua52.can:4
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/lua52.can:7
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/lua52.can:8
end -- ./compiler/lua52.can:8
tags["_opid"]["band"] = function(left, right) -- ./compiler/lua52.can:10
return "bit32.band(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:11
end -- ./compiler/lua52.can:11
tags["_opid"]["bor"] = function(left, right) -- ./compiler/lua52.can:13
return "bit32.bor(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:14
end -- ./compiler/lua52.can:14
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/lua52.can:16
return "bit32.bxor(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:17
end -- ./compiler/lua52.can:17
tags["_opid"]["shl"] = function(left, right) -- ./compiler/lua52.can:19
return "bit32.lshift(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:20
end -- ./compiler/lua52.can:20
tags["_opid"]["shr"] = function(left, right) -- ./compiler/lua52.can:22
return "bit32.rshift(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:23
end -- ./compiler/lua52.can:23
tags["_opid"]["bnot"] = function(right) -- ./compiler/lua52.can:25
return "bit32.bnot(" .. lua(right) .. ")" -- ./compiler/lua52.can:26
end -- ./compiler/lua52.can:26
local code = lua(ast) .. newline() -- ./compiler/lua54.can:896
return requireStr .. code -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
local lua54 = _() or lua54 -- ./compiler/lua54.can:902
return lua54 -- ./compiler/lua53.can:18
end -- ./compiler/lua53.can:18
local lua53 = _() or lua53 -- ./compiler/lua53.can:22
return lua53 -- ./compiler/lua52.can:35
end -- ./compiler/lua52.can:35
local lua52 = _() or lua52 -- ./compiler/lua52.can:39
package["loaded"]["compiler.lua52"] = lua52 or true -- ./compiler/lua52.can:40
local function _() -- ./compiler/lua52.can:43
local function _() -- ./compiler/lua52.can:45
local function _() -- ./compiler/lua52.can:47
local function _() -- ./compiler/lua52.can:49
local util = require("candran.util") -- ./compiler/lua54.can:1
local targetName = "Lua 5.4" -- ./compiler/lua54.can:3
local unpack = unpack or table["unpack"] -- ./compiler/lua54.can:5
return function(code, ast, options, macros) -- ./compiler/lua54.can:7
if macros == nil then macros = { -- ./compiler/lua54.can:7
["functions"] = {}, -- ./compiler/lua54.can:7
["variables"] = {} -- ./compiler/lua54.can:7
} end -- ./compiler/lua54.can:7
local lastInputPos = 1 -- ./compiler/lua54.can:9
local prevLinePos = 1 -- ./compiler/lua54.can:10
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua54.can:11
local lastLine = 1 -- ./compiler/lua54.can:12
local indentLevel = 0 -- ./compiler/lua54.can:15
local function newline() -- ./compiler/lua54.can:17
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua54.can:18
if options["mapLines"] then -- ./compiler/lua54.can:19
local sub = code:sub(lastInputPos) -- ./compiler/lua54.can:20
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua54.can:21
if source and line then -- ./compiler/lua54.can:23
lastSource = source -- ./compiler/lua54.can:24
lastLine = tonumber(line) -- ./compiler/lua54.can:25
else -- ./compiler/lua54.can:25
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua54.can:27
lastLine = lastLine + (1) -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
prevLinePos = lastInputPos -- ./compiler/lua54.can:32
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua54.can:34
end -- ./compiler/lua54.can:34
return r -- ./compiler/lua54.can:36
end -- ./compiler/lua54.can:36
local function indent() -- ./compiler/lua54.can:39
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:40
return newline() -- ./compiler/lua54.can:41
end -- ./compiler/lua54.can:41
local function unindent() -- ./compiler/lua54.can:44
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:45
return newline() -- ./compiler/lua54.can:46
end -- ./compiler/lua54.can:46
local states = { -- ./compiler/lua54.can:51
["push"] = {}, -- ./compiler/lua54.can:52
["destructuring"] = {}, -- ./compiler/lua54.can:53
["scope"] = {}, -- ./compiler/lua54.can:54
["macroargs"] = {} -- ./compiler/lua54.can:55
} -- ./compiler/lua54.can:55
local function push(name, state) -- ./compiler/lua54.can:58
table["insert"](states[name], state) -- ./compiler/lua54.can:59
return "" -- ./compiler/lua54.can:60
end -- ./compiler/lua54.can:60
local function pop(name) -- ./compiler/lua54.can:63
table["remove"](states[name]) -- ./compiler/lua54.can:64
return "" -- ./compiler/lua54.can:65
end -- ./compiler/lua54.can:65
local function set(name, state) -- ./compiler/lua54.can:68
states[name][# states[name]] = state -- ./compiler/lua54.can:69
return "" -- ./compiler/lua54.can:70
end -- ./compiler/lua54.can:70
local function peek(name) -- ./compiler/lua54.can:73
return states[name][# states[name]] -- ./compiler/lua54.can:74
end -- ./compiler/lua54.can:74
local function var(name) -- ./compiler/lua54.can:79
return options["variablePrefix"] .. name -- ./compiler/lua54.can:80
end -- ./compiler/lua54.can:80
local function tmp() -- ./compiler/lua54.can:84
local scope = peek("scope") -- ./compiler/lua54.can:85
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua54.can:86
table["insert"](scope, var) -- ./compiler/lua54.can:87
return var -- ./compiler/lua54.can:88
end -- ./compiler/lua54.can:88
local nomacro = { -- ./compiler/lua54.can:92
["variables"] = {}, -- ./compiler/lua54.can:92
["functions"] = {} -- ./compiler/lua54.can:92
} -- ./compiler/lua54.can:92
local required = {} -- ./compiler/lua54.can:95
local requireStr = "" -- ./compiler/lua54.can:96
local function addRequire(mod, name, field) -- ./compiler/lua54.can:98
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua54.can:99
if not required[req] then -- ./compiler/lua54.can:100
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua54.can:101
required[req] = true -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
local loop = { -- ./compiler/lua54.can:107
"While", -- ./compiler/lua54.can:107
"Repeat", -- ./compiler/lua54.can:107
"Fornum", -- ./compiler/lua54.can:107
"Forin", -- ./compiler/lua54.can:107
"WhileExpr", -- ./compiler/lua54.can:107
"RepeatExpr", -- ./compiler/lua54.can:107
"FornumExpr", -- ./compiler/lua54.can:107
"ForinExpr" -- ./compiler/lua54.can:107
} -- ./compiler/lua54.can:107
local func = { -- ./compiler/lua54.can:108
"Function", -- ./compiler/lua54.can:108
"TableCompr", -- ./compiler/lua54.can:108
"DoExpr", -- ./compiler/lua54.can:108
"WhileExpr", -- ./compiler/lua54.can:108
"RepeatExpr", -- ./compiler/lua54.can:108
"IfExpr", -- ./compiler/lua54.can:108
"FornumExpr", -- ./compiler/lua54.can:108
"ForinExpr" -- ./compiler/lua54.can:108
} -- ./compiler/lua54.can:108
local function any(list, tags, nofollow) -- ./compiler/lua54.can:112
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:112
local tagsCheck = {} -- ./compiler/lua54.can:113
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:114
tagsCheck[tag] = true -- ./compiler/lua54.can:115
end -- ./compiler/lua54.can:115
local nofollowCheck = {} -- ./compiler/lua54.can:117
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:118
nofollowCheck[tag] = true -- ./compiler/lua54.can:119
end -- ./compiler/lua54.can:119
for _, node in ipairs(list) do -- ./compiler/lua54.can:121
if type(node) == "table" then -- ./compiler/lua54.can:122
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:123
return node -- ./compiler/lua54.can:124
end -- ./compiler/lua54.can:124
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:126
local r = any(node, tags, nofollow) -- ./compiler/lua54.can:127
if r then -- ./compiler/lua54.can:128
return r -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
return nil -- ./compiler/lua54.can:132
end -- ./compiler/lua54.can:132
local function search(list, tags, nofollow) -- ./compiler/lua54.can:137
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:137
local tagsCheck = {} -- ./compiler/lua54.can:138
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:139
tagsCheck[tag] = true -- ./compiler/lua54.can:140
end -- ./compiler/lua54.can:140
local nofollowCheck = {} -- ./compiler/lua54.can:142
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:143
nofollowCheck[tag] = true -- ./compiler/lua54.can:144
end -- ./compiler/lua54.can:144
local found = {} -- ./compiler/lua54.can:146
for _, node in ipairs(list) do -- ./compiler/lua54.can:147
if type(node) == "table" then -- ./compiler/lua54.can:148
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:149
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua54.can:150
table["insert"](found, n) -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:154
table["insert"](found, node) -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
return found -- ./compiler/lua54.can:159
end -- ./compiler/lua54.can:159
local function all(list, tags) -- ./compiler/lua54.can:163
for _, node in ipairs(list) do -- ./compiler/lua54.can:164
local ok = false -- ./compiler/lua54.can:165
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:166
if node["tag"] == tag then -- ./compiler/lua54.can:167
ok = true -- ./compiler/lua54.can:168
break -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
if not ok then -- ./compiler/lua54.can:172
return false -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
return true -- ./compiler/lua54.can:176
end -- ./compiler/lua54.can:176
local tags -- ./compiler/lua54.can:180
local function lua(ast, forceTag, ...) -- ./compiler/lua54.can:182
if options["mapLines"] and ast["pos"] then -- ./compiler/lua54.can:183
lastInputPos = ast["pos"] -- ./compiler/lua54.can:184
end -- ./compiler/lua54.can:184
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua54.can:186
end -- ./compiler/lua54.can:186
local UNPACK = function(list, i, j) -- ./compiler/lua54.can:190
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua54.can:191
end -- ./compiler/lua54.can:191
local APPEND = function(t, toAppend) -- ./compiler/lua54.can:193
return "do" .. indent() .. "local " .. var("a") .. " = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(" .. var("a") .. ", 1, " .. var("a") .. ".n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua54.can:194
end -- ./compiler/lua54.can:194
local CONTINUE_START = function() -- ./compiler/lua54.can:196
return "do" .. indent() -- ./compiler/lua54.can:197
end -- ./compiler/lua54.can:197
local CONTINUE_STOP = function() -- ./compiler/lua54.can:199
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua54.can:200
end -- ./compiler/lua54.can:200
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua54.can:202
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua54.can:202
if noLocal == nil then noLocal = false end -- ./compiler/lua54.can:202
local vars = {} -- ./compiler/lua54.can:203
local values = {} -- ./compiler/lua54.can:204
for _, list in ipairs(destructured) do -- ./compiler/lua54.can:205
for _, v in ipairs(list) do -- ./compiler/lua54.can:206
local var, val -- ./compiler/lua54.can:207
if v["tag"] == "Id" or v["tag"] == "AttributeId" then -- ./compiler/lua54.can:208
var = v -- ./compiler/lua54.can:209
val = { -- ./compiler/lua54.can:210
["tag"] = "Index", -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "Id", -- ./compiler/lua54.can:210
list["id"] -- ./compiler/lua54.can:210
}, -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "String", -- ./compiler/lua54.can:210
v[1] -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
elseif v["tag"] == "Pair" then -- ./compiler/lua54.can:211
var = v[2] -- ./compiler/lua54.can:212
val = { -- ./compiler/lua54.can:213
["tag"] = "Index", -- ./compiler/lua54.can:213
{ -- ./compiler/lua54.can:213
["tag"] = "Id", -- ./compiler/lua54.can:213
list["id"] -- ./compiler/lua54.can:213
}, -- ./compiler/lua54.can:213
v[1] -- ./compiler/lua54.can:213
} -- ./compiler/lua54.can:213
else -- ./compiler/lua54.can:213
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua54.can:215
end -- ./compiler/lua54.can:215
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua54.can:217
val = { -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["rightOp"], -- ./compiler/lua54.can:218
var, -- ./compiler/lua54.can:218
{ -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["leftOp"], -- ./compiler/lua54.can:218
val, -- ./compiler/lua54.can:218
var -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
elseif destructured["rightOp"] then -- ./compiler/lua54.can:219
val = { -- ./compiler/lua54.can:220
["tag"] = "Op", -- ./compiler/lua54.can:220
destructured["rightOp"], -- ./compiler/lua54.can:220
var, -- ./compiler/lua54.can:220
val -- ./compiler/lua54.can:220
} -- ./compiler/lua54.can:220
elseif destructured["leftOp"] then -- ./compiler/lua54.can:221
val = { -- ./compiler/lua54.can:222
["tag"] = "Op", -- ./compiler/lua54.can:222
destructured["leftOp"], -- ./compiler/lua54.can:222
val, -- ./compiler/lua54.can:222
var -- ./compiler/lua54.can:222
} -- ./compiler/lua54.can:222
end -- ./compiler/lua54.can:222
table["insert"](vars, lua(var)) -- ./compiler/lua54.can:224
table["insert"](values, lua(val)) -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
if # vars > 0 then -- ./compiler/lua54.can:228
local decl = noLocal and "" or "local " -- ./compiler/lua54.can:229
if newlineAfter then -- ./compiler/lua54.can:230
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua54.can:231
else -- ./compiler/lua54.can:231
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua54.can:233
end -- ./compiler/lua54.can:233
else -- ./compiler/lua54.can:233
return "" -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
tags = setmetatable({ -- ./compiler/lua54.can:241
["Block"] = function(t) -- ./compiler/lua54.can:243
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua54.can:244
if hasPush and hasPush == t[# t] then -- ./compiler/lua54.can:245
hasPush["tag"] = "Return" -- ./compiler/lua54.can:246
hasPush = false -- ./compiler/lua54.can:247
end -- ./compiler/lua54.can:247
local r = push("scope", {}) -- ./compiler/lua54.can:249
if hasPush then -- ./compiler/lua54.can:250
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:251
end -- ./compiler/lua54.can:251
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:253
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua54.can:254
end -- ./compiler/lua54.can:254
if t[# t] then -- ./compiler/lua54.can:256
r = r .. (lua(t[# t])) -- ./compiler/lua54.can:257
end -- ./compiler/lua54.can:257
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua54.can:259
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua54.can:260
end -- ./compiler/lua54.can:260
return r .. pop("scope") -- ./compiler/lua54.can:262
end, -- ./compiler/lua54.can:262
["Do"] = function(t) -- ./compiler/lua54.can:268
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua54.can:269
end, -- ./compiler/lua54.can:269
["Set"] = function(t) -- ./compiler/lua54.can:272
local expr = t[# t] -- ./compiler/lua54.can:274
local vars, values = {}, {} -- ./compiler/lua54.can:275
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua54.can:276
for i, n in ipairs(t[1]) do -- ./compiler/lua54.can:277
if n["tag"] == "DestructuringId" then -- ./compiler/lua54.can:278
table["insert"](destructuringVars, n) -- ./compiler/lua54.can:279
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua54.can:280
else -- ./compiler/lua54.can:280
table["insert"](vars, n) -- ./compiler/lua54.can:282
table["insert"](values, expr[i]) -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
if # t == 2 or # t == 3 then -- ./compiler/lua54.can:287
local r = "" -- ./compiler/lua54.can:288
if # vars > 0 then -- ./compiler/lua54.can:289
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua54.can:290
end -- ./compiler/lua54.can:290
if # destructuringVars > 0 then -- ./compiler/lua54.can:292
local destructured = {} -- ./compiler/lua54.can:293
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:294
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:295
end -- ./compiler/lua54.can:295
return r -- ./compiler/lua54.can:297
elseif # t == 4 then -- ./compiler/lua54.can:298
if t[3] == "=" then -- ./compiler/lua54.can:299
local r = "" -- ./compiler/lua54.can:300
if # vars > 0 then -- ./compiler/lua54.can:301
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:302
t[2], -- ./compiler/lua54.can:302
vars[1], -- ./compiler/lua54.can:302
{ -- ./compiler/lua54.can:302
["tag"] = "Paren", -- ./compiler/lua54.can:302
values[1] -- ./compiler/lua54.can:302
} -- ./compiler/lua54.can:302
}, "Op")) -- ./compiler/lua54.can:302
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua54.can:303
r = r .. (", " .. lua({ -- ./compiler/lua54.can:304
t[2], -- ./compiler/lua54.can:304
vars[i], -- ./compiler/lua54.can:304
{ -- ./compiler/lua54.can:304
["tag"] = "Paren", -- ./compiler/lua54.can:304
values[i] -- ./compiler/lua54.can:304
} -- ./compiler/lua54.can:304
}, "Op")) -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
if # destructuringVars > 0 then -- ./compiler/lua54.can:307
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua54.can:308
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:309
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:310
end -- ./compiler/lua54.can:310
return r -- ./compiler/lua54.can:312
else -- ./compiler/lua54.can:312
local r = "" -- ./compiler/lua54.can:314
if # vars > 0 then -- ./compiler/lua54.can:315
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:316
t[3], -- ./compiler/lua54.can:316
{ -- ./compiler/lua54.can:316
["tag"] = "Paren", -- ./compiler/lua54.can:316
values[1] -- ./compiler/lua54.can:316
}, -- ./compiler/lua54.can:316
vars[1] -- ./compiler/lua54.can:316
}, "Op")) -- ./compiler/lua54.can:316
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua54.can:317
r = r .. (", " .. lua({ -- ./compiler/lua54.can:318
t[3], -- ./compiler/lua54.can:318
{ -- ./compiler/lua54.can:318
["tag"] = "Paren", -- ./compiler/lua54.can:318
values[i] -- ./compiler/lua54.can:318
}, -- ./compiler/lua54.can:318
vars[i] -- ./compiler/lua54.can:318
}, "Op")) -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
if # destructuringVars > 0 then -- ./compiler/lua54.can:321
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua54.can:322
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:323
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:324
end -- ./compiler/lua54.can:324
return r -- ./compiler/lua54.can:326
end -- ./compiler/lua54.can:326
else -- ./compiler/lua54.can:326
local r = "" -- ./compiler/lua54.can:329
if # vars > 0 then -- ./compiler/lua54.can:330
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:331
t[2], -- ./compiler/lua54.can:331
vars[1], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Op", -- ./compiler/lua54.can:331
t[4], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Paren", -- ./compiler/lua54.can:331
values[1] -- ./compiler/lua54.can:331
}, -- ./compiler/lua54.can:331
vars[1] -- ./compiler/lua54.can:331
} -- ./compiler/lua54.can:331
}, "Op")) -- ./compiler/lua54.can:331
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua54.can:332
r = r .. (", " .. lua({ -- ./compiler/lua54.can:333
t[2], -- ./compiler/lua54.can:333
vars[i], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Op", -- ./compiler/lua54.can:333
t[4], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Paren", -- ./compiler/lua54.can:333
values[i] -- ./compiler/lua54.can:333
}, -- ./compiler/lua54.can:333
vars[i] -- ./compiler/lua54.can:333
} -- ./compiler/lua54.can:333
}, "Op")) -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
if # destructuringVars > 0 then -- ./compiler/lua54.can:336
local destructured = { -- ./compiler/lua54.can:337
["rightOp"] = t[2], -- ./compiler/lua54.can:337
["leftOp"] = t[4] -- ./compiler/lua54.can:337
} -- ./compiler/lua54.can:337
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:338
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:339
end -- ./compiler/lua54.can:339
return r -- ./compiler/lua54.can:341
end -- ./compiler/lua54.can:341
end, -- ./compiler/lua54.can:341
["While"] = function(t) -- ./compiler/lua54.can:345
local r = "" -- ./compiler/lua54.can:346
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua54.can:347
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:348
if # lets > 0 then -- ./compiler/lua54.can:349
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:350
for _, l in ipairs(lets) do -- ./compiler/lua54.can:351
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua54.can:355
if # lets > 0 then -- ./compiler/lua54.can:356
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:357
end -- ./compiler/lua54.can:357
if hasContinue then -- ./compiler/lua54.can:359
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:360
end -- ./compiler/lua54.can:360
r = r .. (lua(t[2])) -- ./compiler/lua54.can:362
if hasContinue then -- ./compiler/lua54.can:363
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:364
end -- ./compiler/lua54.can:364
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:366
if # lets > 0 then -- ./compiler/lua54.can:367
for _, l in ipairs(lets) do -- ./compiler/lua54.can:368
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua54.can:369
end -- ./compiler/lua54.can:369
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua54.can:371
end -- ./compiler/lua54.can:371
return r -- ./compiler/lua54.can:373
end, -- ./compiler/lua54.can:373
["Repeat"] = function(t) -- ./compiler/lua54.can:376
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua54.can:377
local r = "repeat" .. indent() -- ./compiler/lua54.can:378
if hasContinue then -- ./compiler/lua54.can:379
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:380
end -- ./compiler/lua54.can:380
r = r .. (lua(t[1])) -- ./compiler/lua54.can:382
if hasContinue then -- ./compiler/lua54.can:383
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:384
end -- ./compiler/lua54.can:384
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua54.can:386
return r -- ./compiler/lua54.can:387
end, -- ./compiler/lua54.can:387
["If"] = function(t) -- ./compiler/lua54.can:390
local r = "" -- ./compiler/lua54.can:391
local toClose = 0 -- ./compiler/lua54.can:392
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:393
if # lets > 0 then -- ./compiler/lua54.can:394
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:395
toClose = toClose + (1) -- ./compiler/lua54.can:396
for _, l in ipairs(lets) do -- ./compiler/lua54.can:397
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua54.can:401
for i = 3, # t - 1, 2 do -- ./compiler/lua54.can:402
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua54.can:403
if # lets > 0 then -- ./compiler/lua54.can:404
r = r .. ("else" .. indent()) -- ./compiler/lua54.can:405
toClose = toClose + (1) -- ./compiler/lua54.can:406
for _, l in ipairs(lets) do -- ./compiler/lua54.can:407
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:408
end -- ./compiler/lua54.can:408
else -- ./compiler/lua54.can:408
r = r .. ("else") -- ./compiler/lua54.can:411
end -- ./compiler/lua54.can:411
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua54.can:413
end -- ./compiler/lua54.can:413
if # t % 2 == 1 then -- ./compiler/lua54.can:415
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua54.can:416
end -- ./compiler/lua54.can:416
r = r .. ("end") -- ./compiler/lua54.can:418
for i = 1, toClose do -- ./compiler/lua54.can:419
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:420
end -- ./compiler/lua54.can:420
return r -- ./compiler/lua54.can:422
end, -- ./compiler/lua54.can:422
["Fornum"] = function(t) -- ./compiler/lua54.can:425
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua54.can:426
if # t == 5 then -- ./compiler/lua54.can:427
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua54.can:428
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua54.can:429
if hasContinue then -- ./compiler/lua54.can:430
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:431
end -- ./compiler/lua54.can:431
r = r .. (lua(t[5])) -- ./compiler/lua54.can:433
if hasContinue then -- ./compiler/lua54.can:434
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:435
end -- ./compiler/lua54.can:435
return r .. unindent() .. "end" -- ./compiler/lua54.can:437
else -- ./compiler/lua54.can:437
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua54.can:439
r = r .. (" do" .. indent()) -- ./compiler/lua54.can:440
if hasContinue then -- ./compiler/lua54.can:441
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:442
end -- ./compiler/lua54.can:442
r = r .. (lua(t[4])) -- ./compiler/lua54.can:444
if hasContinue then -- ./compiler/lua54.can:445
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:446
end -- ./compiler/lua54.can:446
return r .. unindent() .. "end" -- ./compiler/lua54.can:448
end -- ./compiler/lua54.can:448
end, -- ./compiler/lua54.can:448
["Forin"] = function(t) -- ./compiler/lua54.can:452
local destructured = {} -- ./compiler/lua54.can:453
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua54.can:454
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua54.can:455
if hasContinue then -- ./compiler/lua54.can:456
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:457
end -- ./compiler/lua54.can:457
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua54.can:459
if hasContinue then -- ./compiler/lua54.can:460
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:461
end -- ./compiler/lua54.can:461
return r .. unindent() .. "end" -- ./compiler/lua54.can:463
end, -- ./compiler/lua54.can:463
["Local"] = function(t) -- ./compiler/lua54.can:466
local destructured = {} -- ./compiler/lua54.can:467
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:468
if t[2][1] then -- ./compiler/lua54.can:469
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:470
end -- ./compiler/lua54.can:470
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:472
end, -- ./compiler/lua54.can:472
["Let"] = function(t) -- ./compiler/lua54.can:475
local destructured = {} -- ./compiler/lua54.can:476
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:477
local r = "local " .. nameList -- ./compiler/lua54.can:478
if t[2][1] then -- ./compiler/lua54.can:479
if all(t[2], { -- ./compiler/lua54.can:480
"Nil", -- ./compiler/lua54.can:480
"Dots", -- ./compiler/lua54.can:480
"Boolean", -- ./compiler/lua54.can:480
"Number", -- ./compiler/lua54.can:480
"String" -- ./compiler/lua54.can:480
}) then -- ./compiler/lua54.can:480
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:481
else -- ./compiler/lua54.can:481
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:486
end, -- ./compiler/lua54.can:486
["Localrec"] = function(t) -- ./compiler/lua54.can:489
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua54.can:490
end, -- ./compiler/lua54.can:490
["Goto"] = function(t) -- ./compiler/lua54.can:493
return "goto " .. lua(t, "Id") -- ./compiler/lua54.can:494
end, -- ./compiler/lua54.can:494
["Label"] = function(t) -- ./compiler/lua54.can:497
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua54.can:498
end, -- ./compiler/lua54.can:498
["Return"] = function(t) -- ./compiler/lua54.can:501
local push = peek("push") -- ./compiler/lua54.can:502
if push then -- ./compiler/lua54.can:503
local r = "" -- ./compiler/lua54.can:504
for _, val in ipairs(t) do -- ./compiler/lua54.can:505
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua54.can:506
end -- ./compiler/lua54.can:506
return r .. "return " .. UNPACK(push) -- ./compiler/lua54.can:508
else -- ./compiler/lua54.can:508
return "return " .. lua(t, "_lhs") -- ./compiler/lua54.can:510
end -- ./compiler/lua54.can:510
end, -- ./compiler/lua54.can:510
["Push"] = function(t) -- ./compiler/lua54.can:514
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua54.can:515
r = "" -- ./compiler/lua54.can:516
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:517
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua54.can:518
end -- ./compiler/lua54.can:518
if t[# t] then -- ./compiler/lua54.can:520
if t[# t]["tag"] == "Call" then -- ./compiler/lua54.can:521
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua54.can:522
else -- ./compiler/lua54.can:522
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
return r -- ./compiler/lua54.can:527
end, -- ./compiler/lua54.can:527
["Break"] = function() -- ./compiler/lua54.can:530
return "break" -- ./compiler/lua54.can:531
end, -- ./compiler/lua54.can:531
["Continue"] = function() -- ./compiler/lua54.can:534
return "goto " .. var("continue") -- ./compiler/lua54.can:535
end, -- ./compiler/lua54.can:535
["Nil"] = function() -- ./compiler/lua54.can:542
return "nil" -- ./compiler/lua54.can:543
end, -- ./compiler/lua54.can:543
["Dots"] = function() -- ./compiler/lua54.can:546
local macroargs = peek("macroargs") -- ./compiler/lua54.can:547
if macroargs and not nomacro["variables"]["..."] and macroargs["..."] then -- ./compiler/lua54.can:548
nomacro["variables"]["..."] = true -- ./compiler/lua54.can:549
local r = lua(macroargs["..."], "_lhs") -- ./compiler/lua54.can:550
nomacro["variables"]["..."] = nil -- ./compiler/lua54.can:551
return r -- ./compiler/lua54.can:552
else -- ./compiler/lua54.can:552
return "..." -- ./compiler/lua54.can:554
end -- ./compiler/lua54.can:554
end, -- ./compiler/lua54.can:554
["Boolean"] = function(t) -- ./compiler/lua54.can:558
return tostring(t[1]) -- ./compiler/lua54.can:559
end, -- ./compiler/lua54.can:559
["Number"] = function(t) -- ./compiler/lua54.can:562
return tostring(t[1]) -- ./compiler/lua54.can:563
end, -- ./compiler/lua54.can:563
["String"] = function(t) -- ./compiler/lua54.can:566
return ("%q"):format(t[1]) -- ./compiler/lua54.can:567
end, -- ./compiler/lua54.can:567
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua54.can:570
local r = "(" -- ./compiler/lua54.can:571
local decl = {} -- ./compiler/lua54.can:572
if t[1][1] then -- ./compiler/lua54.can:573
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua54.can:574
local id = lua(t[1][1][1]) -- ./compiler/lua54.can:575
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:576
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua54.can:577
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:578
r = r .. (id) -- ./compiler/lua54.can:579
else -- ./compiler/lua54.can:579
r = r .. (lua(t[1][1])) -- ./compiler/lua54.can:581
end -- ./compiler/lua54.can:581
for i = 2, # t[1], 1 do -- ./compiler/lua54.can:583
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua54.can:584
local id = lua(t[1][i][1]) -- ./compiler/lua54.can:585
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:586
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua54.can:587
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:588
r = r .. (", " .. id) -- ./compiler/lua54.can:589
else -- ./compiler/lua54.can:589
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
r = r .. (")" .. indent()) -- ./compiler/lua54.can:595
for _, d in ipairs(decl) do -- ./compiler/lua54.can:596
r = r .. (d .. newline()) -- ./compiler/lua54.can:597
end -- ./compiler/lua54.can:597
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua54.can:599
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua54.can:600
end -- ./compiler/lua54.can:600
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua54.can:602
if hasPush then -- ./compiler/lua54.can:603
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:604
else -- ./compiler/lua54.can:604
push("push", false) -- ./compiler/lua54.can:606
end -- ./compiler/lua54.can:606
r = r .. (lua(t[2])) -- ./compiler/lua54.can:608
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua54.can:609
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:610
end -- ./compiler/lua54.can:610
pop("push") -- ./compiler/lua54.can:612
return r .. unindent() .. "end" -- ./compiler/lua54.can:613
end, -- ./compiler/lua54.can:613
["Function"] = function(t) -- ./compiler/lua54.can:615
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua54.can:616
end, -- ./compiler/lua54.can:616
["Pair"] = function(t) -- ./compiler/lua54.can:619
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua54.can:620
end, -- ./compiler/lua54.can:620
["Table"] = function(t) -- ./compiler/lua54.can:622
if # t == 0 then -- ./compiler/lua54.can:623
return "{}" -- ./compiler/lua54.can:624
elseif # t == 1 then -- ./compiler/lua54.can:625
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua54.can:626
else -- ./compiler/lua54.can:626
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua54.can:628
end -- ./compiler/lua54.can:628
end, -- ./compiler/lua54.can:628
["TableCompr"] = function(t) -- ./compiler/lua54.can:632
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua54.can:633
end, -- ./compiler/lua54.can:633
["Op"] = function(t) -- ./compiler/lua54.can:636
local r -- ./compiler/lua54.can:637
if # t == 2 then -- ./compiler/lua54.can:638
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:639
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua54.can:640
else -- ./compiler/lua54.can:640
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua54.can:642
end -- ./compiler/lua54.can:642
else -- ./compiler/lua54.can:642
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:645
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua54.can:646
else -- ./compiler/lua54.can:646
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
return r -- ./compiler/lua54.can:651
end, -- ./compiler/lua54.can:651
["Paren"] = function(t) -- ./compiler/lua54.can:654
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua54.can:655
end, -- ./compiler/lua54.can:655
["MethodStub"] = function(t) -- ./compiler/lua54.can:658
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:664
end, -- ./compiler/lua54.can:664
["SafeMethodStub"] = function(t) -- ./compiler/lua54.can:667
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:674
end, -- ./compiler/lua54.can:674
["LetExpr"] = function(t) -- ./compiler/lua54.can:681
return lua(t[1][1]) -- ./compiler/lua54.can:682
end, -- ./compiler/lua54.can:682
["_statexpr"] = function(t, stat) -- ./compiler/lua54.can:686
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua54.can:687
local r = "(function()" .. indent() -- ./compiler/lua54.can:688
if hasPush then -- ./compiler/lua54.can:689
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:690
else -- ./compiler/lua54.can:690
push("push", false) -- ./compiler/lua54.can:692
end -- ./compiler/lua54.can:692
r = r .. (lua(t, stat)) -- ./compiler/lua54.can:694
if hasPush then -- ./compiler/lua54.can:695
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:696
end -- ./compiler/lua54.can:696
pop("push") -- ./compiler/lua54.can:698
r = r .. (unindent() .. "end)()") -- ./compiler/lua54.can:699
return r -- ./compiler/lua54.can:700
end, -- ./compiler/lua54.can:700
["DoExpr"] = function(t) -- ./compiler/lua54.can:703
if t[# t]["tag"] == "Push" then -- ./compiler/lua54.can:704
t[# t]["tag"] = "Return" -- ./compiler/lua54.can:705
end -- ./compiler/lua54.can:705
return lua(t, "_statexpr", "Do") -- ./compiler/lua54.can:707
end, -- ./compiler/lua54.can:707
["WhileExpr"] = function(t) -- ./compiler/lua54.can:710
return lua(t, "_statexpr", "While") -- ./compiler/lua54.can:711
end, -- ./compiler/lua54.can:711
["RepeatExpr"] = function(t) -- ./compiler/lua54.can:714
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua54.can:715
end, -- ./compiler/lua54.can:715
["IfExpr"] = function(t) -- ./compiler/lua54.can:718
for i = 2, # t do -- ./compiler/lua54.can:719
local block = t[i] -- ./compiler/lua54.can:720
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua54.can:721
block[# block]["tag"] = "Return" -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
return lua(t, "_statexpr", "If") -- ./compiler/lua54.can:725
end, -- ./compiler/lua54.can:725
["FornumExpr"] = function(t) -- ./compiler/lua54.can:728
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua54.can:729
end, -- ./compiler/lua54.can:729
["ForinExpr"] = function(t) -- ./compiler/lua54.can:732
return lua(t, "_statexpr", "Forin") -- ./compiler/lua54.can:733
end, -- ./compiler/lua54.can:733
["Call"] = function(t) -- ./compiler/lua54.can:739
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:740
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:741
elseif t[1]["tag"] == "Id" and not nomacro["functions"][t[1][1]] and macros["functions"][t[1][1]] then -- ./compiler/lua54.can:742
local macro = macros["functions"][t[1][1]] -- ./compiler/lua54.can:743
local replacement = macro["replacement"] -- ./compiler/lua54.can:744
local r -- ./compiler/lua54.can:745
nomacro["functions"][t[1][1]] = true -- ./compiler/lua54.can:746
if type(replacement) == "function" then -- ./compiler/lua54.can:747
local args = {} -- ./compiler/lua54.can:748
for i = 2, # t do -- ./compiler/lua54.can:749
table["insert"](args, lua(t[i])) -- ./compiler/lua54.can:750
end -- ./compiler/lua54.can:750
r = replacement(unpack(args)) -- ./compiler/lua54.can:752
else -- ./compiler/lua54.can:752
local macroargs = util["merge"](peek("macroargs")) -- ./compiler/lua54.can:754
for i, arg in ipairs(macro["args"]) do -- ./compiler/lua54.can:755
if arg["tag"] == "Dots" then -- ./compiler/lua54.can:756
macroargs["..."] = (function() -- ./compiler/lua54.can:757
local self = {} -- ./compiler/lua54.can:757
for j = i + 1, # t do -- ./compiler/lua54.can:757
self[#self+1] = t[j] -- ./compiler/lua54.can:757
end -- ./compiler/lua54.can:757
return self -- ./compiler/lua54.can:757
end)() -- ./compiler/lua54.can:757
elseif arg["tag"] == "Id" then -- ./compiler/lua54.can:758
if t[i + 1] == nil then -- ./compiler/lua54.can:759
error(("bad argument #%s to macro %s (value expected)"):format(i, t[1][1])) -- ./compiler/lua54.can:760
end -- ./compiler/lua54.can:760
macroargs[arg[1]] = t[i + 1] -- ./compiler/lua54.can:762
else -- ./compiler/lua54.can:762
error(("unexpected argument type %s in macro %s"):format(arg["tag"], t[1][1])) -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
push("macroargs", macroargs) -- ./compiler/lua54.can:767
r = lua(replacement) -- ./compiler/lua54.can:768
pop("macroargs") -- ./compiler/lua54.can:769
end -- ./compiler/lua54.can:769
nomacro["functions"][t[1][1]] = nil -- ./compiler/lua54.can:771
return r -- ./compiler/lua54.can:772
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua54.can:773
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua54.can:774
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:775
else -- ./compiler/lua54.can:775
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:777
end -- ./compiler/lua54.can:777
else -- ./compiler/lua54.can:777
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:780
end -- ./compiler/lua54.can:780
end, -- ./compiler/lua54.can:780
["SafeCall"] = function(t) -- ./compiler/lua54.can:784
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:785
return lua(t, "SafeIndex") -- ./compiler/lua54.can:786
else -- ./compiler/lua54.can:786
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua54.can:788
end -- ./compiler/lua54.can:788
end, -- ./compiler/lua54.can:788
["_lhs"] = function(t, start, newlines) -- ./compiler/lua54.can:793
if start == nil then start = 1 end -- ./compiler/lua54.can:793
local r -- ./compiler/lua54.can:794
if t[start] then -- ./compiler/lua54.can:795
r = lua(t[start]) -- ./compiler/lua54.can:796
for i = start + 1, # t, 1 do -- ./compiler/lua54.can:797
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua54.can:798
end -- ./compiler/lua54.can:798
else -- ./compiler/lua54.can:798
r = "" -- ./compiler/lua54.can:801
end -- ./compiler/lua54.can:801
return r -- ./compiler/lua54.can:803
end, -- ./compiler/lua54.can:803
["Id"] = function(t) -- ./compiler/lua54.can:806
local r = t[1] -- ./compiler/lua54.can:807
local macroargs = peek("macroargs") -- ./compiler/lua54.can:808
if not nomacro["variables"][t[1]] then -- ./compiler/lua54.can:809
nomacro["variables"][t[1]] = true -- ./compiler/lua54.can:810
if macroargs and macroargs[t[1]] then -- ./compiler/lua54.can:811
r = lua(macroargs[t[1]]) -- ./compiler/lua54.can:812
elseif macros["variables"][t[1]] ~= nil then -- ./compiler/lua54.can:813
local macro = macros["variables"][t[1]] -- ./compiler/lua54.can:814
if type(macro) == "function" then -- ./compiler/lua54.can:815
r = macro() -- ./compiler/lua54.can:816
else -- ./compiler/lua54.can:816
r = lua(macro) -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
nomacro["variables"][t[1]] = nil -- ./compiler/lua54.can:821
end -- ./compiler/lua54.can:821
return r -- ./compiler/lua54.can:823
end, -- ./compiler/lua54.can:823
["AttributeId"] = function(t) -- ./compiler/lua54.can:826
if t[2] then -- ./compiler/lua54.can:827
return t[1] .. " <" .. t[2] .. ">" -- ./compiler/lua54.can:828
else -- ./compiler/lua54.can:828
return t[1] -- ./compiler/lua54.can:830
end -- ./compiler/lua54.can:830
end, -- ./compiler/lua54.can:830
["DestructuringId"] = function(t) -- ./compiler/lua54.can:834
if t["id"] then -- ./compiler/lua54.can:835
return t["id"] -- ./compiler/lua54.can:836
else -- ./compiler/lua54.can:836
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua54.can:838
local vars = { ["id"] = tmp() } -- ./compiler/lua54.can:839
for j = 1, # t, 1 do -- ./compiler/lua54.can:840
table["insert"](vars, t[j]) -- ./compiler/lua54.can:841
end -- ./compiler/lua54.can:841
table["insert"](d, vars) -- ./compiler/lua54.can:843
t["id"] = vars["id"] -- ./compiler/lua54.can:844
return vars["id"] -- ./compiler/lua54.can:845
end -- ./compiler/lua54.can:845
end, -- ./compiler/lua54.can:845
["Index"] = function(t) -- ./compiler/lua54.can:849
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:850
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:851
else -- ./compiler/lua54.can:851
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:853
end -- ./compiler/lua54.can:853
end, -- ./compiler/lua54.can:853
["SafeIndex"] = function(t) -- ./compiler/lua54.can:857
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:858
local l = {} -- ./compiler/lua54.can:859
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua54.can:860
table["insert"](l, 1, t) -- ./compiler/lua54.can:861
t = t[1] -- ./compiler/lua54.can:862
end -- ./compiler/lua54.can:862
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua54.can:864
for _, e in ipairs(l) do -- ./compiler/lua54.can:865
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua54.can:866
if e["tag"] == "SafeIndex" then -- ./compiler/lua54.can:867
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua54.can:868
else -- ./compiler/lua54.can:868
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua54.can:873
return r -- ./compiler/lua54.can:874
else -- ./compiler/lua54.can:874
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua54.can:876
end -- ./compiler/lua54.can:876
end, -- ./compiler/lua54.can:876
["_opid"] = { -- ./compiler/lua54.can:881
["add"] = "+", -- ./compiler/lua54.can:882
["sub"] = "-", -- ./compiler/lua54.can:882
["mul"] = "*", -- ./compiler/lua54.can:882
["div"] = "/", -- ./compiler/lua54.can:882
["idiv"] = "//", -- ./compiler/lua54.can:883
["mod"] = "%", -- ./compiler/lua54.can:883
["pow"] = "^", -- ./compiler/lua54.can:883
["concat"] = "..", -- ./compiler/lua54.can:883
["band"] = "&", -- ./compiler/lua54.can:884
["bor"] = "|", -- ./compiler/lua54.can:884
["bxor"] = "~", -- ./compiler/lua54.can:884
["shl"] = "<<", -- ./compiler/lua54.can:884
["shr"] = ">>", -- ./compiler/lua54.can:884
["eq"] = "==", -- ./compiler/lua54.can:885
["ne"] = "~=", -- ./compiler/lua54.can:885
["lt"] = "<", -- ./compiler/lua54.can:885
["gt"] = ">", -- ./compiler/lua54.can:885
["le"] = "<=", -- ./compiler/lua54.can:885
["ge"] = ">=", -- ./compiler/lua54.can:885
["and"] = "and", -- ./compiler/lua54.can:886
["or"] = "or", -- ./compiler/lua54.can:886
["unm"] = "-", -- ./compiler/lua54.can:886
["len"] = "#", -- ./compiler/lua54.can:886
["bnot"] = "~", -- ./compiler/lua54.can:886
["not"] = "not" -- ./compiler/lua54.can:886
} -- ./compiler/lua54.can:886
}, { ["__index"] = function(self, key) -- ./compiler/lua54.can:889
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua54.can:890
end }) -- ./compiler/lua54.can:890
targetName = "Lua 5.3" -- ./compiler/lua53.can:1
tags["AttributeId"] = function(t) -- ./compiler/lua53.can:4
if t[2] then -- ./compiler/lua53.can:5
error("target " .. targetName .. " does not support variable attributes") -- ./compiler/lua53.can:6
else -- ./compiler/lua53.can:6
return t[1] -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
targetName = "Lua 5.2" -- ./compiler/lua52.can:1
APPEND = function(t, toAppend) -- ./compiler/lua52.can:3
return "do" .. indent() .. "local " .. var("a") .. ", " .. var("p") .. " = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #" .. var("a") .. " do" .. indent() .. t .. "[" .. var("p") .. "] = " .. var("a") .. "[i]" .. newline() .. "" .. var("p") .. " = " .. var("p") .. " + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/lua52.can:4
end -- ./compiler/lua52.can:4
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/lua52.can:7
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/lua52.can:8
end -- ./compiler/lua52.can:8
tags["_opid"]["band"] = function(left, right) -- ./compiler/lua52.can:10
return "bit32.band(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:11
end -- ./compiler/lua52.can:11
tags["_opid"]["bor"] = function(left, right) -- ./compiler/lua52.can:13
return "bit32.bor(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:14
end -- ./compiler/lua52.can:14
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/lua52.can:16
return "bit32.bxor(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:17
end -- ./compiler/lua52.can:17
tags["_opid"]["shl"] = function(left, right) -- ./compiler/lua52.can:19
return "bit32.lshift(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:20
end -- ./compiler/lua52.can:20
tags["_opid"]["shr"] = function(left, right) -- ./compiler/lua52.can:22
return "bit32.rshift(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:23
end -- ./compiler/lua52.can:23
tags["_opid"]["bnot"] = function(right) -- ./compiler/lua52.can:25
return "bit32.bnot(" .. lua(right) .. ")" -- ./compiler/lua52.can:26
end -- ./compiler/lua52.can:26
targetName = "LuaJIT" -- ./compiler/luajit.can:1
UNPACK = function(list, i, j) -- ./compiler/luajit.can:3
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/luajit.can:4
end -- ./compiler/luajit.can:4
tags["_opid"]["band"] = function(left, right) -- ./compiler/luajit.can:7
addRequire("bit", "band", "band") -- ./compiler/luajit.can:8
return var("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:9
end -- ./compiler/luajit.can:9
tags["_opid"]["bor"] = function(left, right) -- ./compiler/luajit.can:11
addRequire("bit", "bor", "bor") -- ./compiler/luajit.can:12
return var("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:13
end -- ./compiler/luajit.can:13
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/luajit.can:15
addRequire("bit", "bxor", "bxor") -- ./compiler/luajit.can:16
return var("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:17
end -- ./compiler/luajit.can:17
tags["_opid"]["shl"] = function(left, right) -- ./compiler/luajit.can:19
addRequire("bit", "lshift", "lshift") -- ./compiler/luajit.can:20
return var("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:21
end -- ./compiler/luajit.can:21
tags["_opid"]["shr"] = function(left, right) -- ./compiler/luajit.can:23
addRequire("bit", "rshift", "rshift") -- ./compiler/luajit.can:24
return var("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:25
end -- ./compiler/luajit.can:25
tags["_opid"]["bnot"] = function(right) -- ./compiler/luajit.can:27
addRequire("bit", "bnot", "bnot") -- ./compiler/luajit.can:28
return var("bnot") .. "(" .. lua(right) .. ")" -- ./compiler/luajit.can:29
end -- ./compiler/luajit.can:29
local code = lua(ast) .. newline() -- ./compiler/lua54.can:896
return requireStr .. code -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
local lua54 = _() or lua54 -- ./compiler/lua54.can:902
return lua54 -- ./compiler/lua53.can:18
end -- ./compiler/lua53.can:18
local lua53 = _() or lua53 -- ./compiler/lua53.can:22
return lua53 -- ./compiler/lua52.can:35
end -- ./compiler/lua52.can:35
local lua52 = _() or lua52 -- ./compiler/lua52.can:39
return lua52 -- ./compiler/luajit.can:38
end -- ./compiler/luajit.can:38
local luajit = _() or luajit -- ./compiler/luajit.can:42
package["loaded"]["compiler.luajit"] = luajit or true -- ./compiler/luajit.can:43
local function _() -- ./compiler/luajit.can:46
local function _() -- ./compiler/luajit.can:48
local function _() -- ./compiler/luajit.can:50
local function _() -- ./compiler/luajit.can:52
local function _() -- ./compiler/luajit.can:54
local util = require("candran.util") -- ./compiler/lua54.can:1
local targetName = "Lua 5.4" -- ./compiler/lua54.can:3
local unpack = unpack or table["unpack"] -- ./compiler/lua54.can:5
return function(code, ast, options, macros) -- ./compiler/lua54.can:7
if macros == nil then macros = { -- ./compiler/lua54.can:7
["functions"] = {}, -- ./compiler/lua54.can:7
["variables"] = {} -- ./compiler/lua54.can:7
} end -- ./compiler/lua54.can:7
local lastInputPos = 1 -- ./compiler/lua54.can:9
local prevLinePos = 1 -- ./compiler/lua54.can:10
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua54.can:11
local lastLine = 1 -- ./compiler/lua54.can:12
local indentLevel = 0 -- ./compiler/lua54.can:15
local function newline() -- ./compiler/lua54.can:17
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua54.can:18
if options["mapLines"] then -- ./compiler/lua54.can:19
local sub = code:sub(lastInputPos) -- ./compiler/lua54.can:20
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua54.can:21
if source and line then -- ./compiler/lua54.can:23
lastSource = source -- ./compiler/lua54.can:24
lastLine = tonumber(line) -- ./compiler/lua54.can:25
else -- ./compiler/lua54.can:25
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua54.can:27
lastLine = lastLine + (1) -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
end -- ./compiler/lua54.can:28
prevLinePos = lastInputPos -- ./compiler/lua54.can:32
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua54.can:34
end -- ./compiler/lua54.can:34
return r -- ./compiler/lua54.can:36
end -- ./compiler/lua54.can:36
local function indent() -- ./compiler/lua54.can:39
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:40
return newline() -- ./compiler/lua54.can:41
end -- ./compiler/lua54.can:41
local function unindent() -- ./compiler/lua54.can:44
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:45
return newline() -- ./compiler/lua54.can:46
end -- ./compiler/lua54.can:46
local states = { -- ./compiler/lua54.can:51
["push"] = {}, -- ./compiler/lua54.can:52
["destructuring"] = {}, -- ./compiler/lua54.can:53
["scope"] = {}, -- ./compiler/lua54.can:54
["macroargs"] = {} -- ./compiler/lua54.can:55
} -- ./compiler/lua54.can:55
local function push(name, state) -- ./compiler/lua54.can:58
table["insert"](states[name], state) -- ./compiler/lua54.can:59
return "" -- ./compiler/lua54.can:60
end -- ./compiler/lua54.can:60
local function pop(name) -- ./compiler/lua54.can:63
table["remove"](states[name]) -- ./compiler/lua54.can:64
return "" -- ./compiler/lua54.can:65
end -- ./compiler/lua54.can:65
local function set(name, state) -- ./compiler/lua54.can:68
states[name][# states[name]] = state -- ./compiler/lua54.can:69
return "" -- ./compiler/lua54.can:70
end -- ./compiler/lua54.can:70
local function peek(name) -- ./compiler/lua54.can:73
return states[name][# states[name]] -- ./compiler/lua54.can:74
end -- ./compiler/lua54.can:74
local function var(name) -- ./compiler/lua54.can:79
return options["variablePrefix"] .. name -- ./compiler/lua54.can:80
end -- ./compiler/lua54.can:80
local function tmp() -- ./compiler/lua54.can:84
local scope = peek("scope") -- ./compiler/lua54.can:85
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua54.can:86
table["insert"](scope, var) -- ./compiler/lua54.can:87
return var -- ./compiler/lua54.can:88
end -- ./compiler/lua54.can:88
local nomacro = { -- ./compiler/lua54.can:92
["variables"] = {}, -- ./compiler/lua54.can:92
["functions"] = {} -- ./compiler/lua54.can:92
} -- ./compiler/lua54.can:92
local required = {} -- ./compiler/lua54.can:95
local requireStr = "" -- ./compiler/lua54.can:96
local function addRequire(mod, name, field) -- ./compiler/lua54.can:98
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua54.can:99
if not required[req] then -- ./compiler/lua54.can:100
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua54.can:101
required[req] = true -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
end -- ./compiler/lua54.can:102
local loop = { -- ./compiler/lua54.can:107
"While", -- ./compiler/lua54.can:107
"Repeat", -- ./compiler/lua54.can:107
"Fornum", -- ./compiler/lua54.can:107
"Forin", -- ./compiler/lua54.can:107
"WhileExpr", -- ./compiler/lua54.can:107
"RepeatExpr", -- ./compiler/lua54.can:107
"FornumExpr", -- ./compiler/lua54.can:107
"ForinExpr" -- ./compiler/lua54.can:107
} -- ./compiler/lua54.can:107
local func = { -- ./compiler/lua54.can:108
"Function", -- ./compiler/lua54.can:108
"TableCompr", -- ./compiler/lua54.can:108
"DoExpr", -- ./compiler/lua54.can:108
"WhileExpr", -- ./compiler/lua54.can:108
"RepeatExpr", -- ./compiler/lua54.can:108
"IfExpr", -- ./compiler/lua54.can:108
"FornumExpr", -- ./compiler/lua54.can:108
"ForinExpr" -- ./compiler/lua54.can:108
} -- ./compiler/lua54.can:108
local function any(list, tags, nofollow) -- ./compiler/lua54.can:112
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:112
local tagsCheck = {} -- ./compiler/lua54.can:113
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:114
tagsCheck[tag] = true -- ./compiler/lua54.can:115
end -- ./compiler/lua54.can:115
local nofollowCheck = {} -- ./compiler/lua54.can:117
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:118
nofollowCheck[tag] = true -- ./compiler/lua54.can:119
end -- ./compiler/lua54.can:119
for _, node in ipairs(list) do -- ./compiler/lua54.can:121
if type(node) == "table" then -- ./compiler/lua54.can:122
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:123
return node -- ./compiler/lua54.can:124
end -- ./compiler/lua54.can:124
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:126
local r = any(node, tags, nofollow) -- ./compiler/lua54.can:127
if r then -- ./compiler/lua54.can:128
return r -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
end -- ./compiler/lua54.can:128
return nil -- ./compiler/lua54.can:132
end -- ./compiler/lua54.can:132
local function search(list, tags, nofollow) -- ./compiler/lua54.can:137
if nofollow == nil then nofollow = {} end -- ./compiler/lua54.can:137
local tagsCheck = {} -- ./compiler/lua54.can:138
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:139
tagsCheck[tag] = true -- ./compiler/lua54.can:140
end -- ./compiler/lua54.can:140
local nofollowCheck = {} -- ./compiler/lua54.can:142
for _, tag in ipairs(nofollow) do -- ./compiler/lua54.can:143
nofollowCheck[tag] = true -- ./compiler/lua54.can:144
end -- ./compiler/lua54.can:144
local found = {} -- ./compiler/lua54.can:146
for _, node in ipairs(list) do -- ./compiler/lua54.can:147
if type(node) == "table" then -- ./compiler/lua54.can:148
if not nofollowCheck[node["tag"]] then -- ./compiler/lua54.can:149
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua54.can:150
table["insert"](found, n) -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
end -- ./compiler/lua54.can:151
if tagsCheck[node["tag"]] then -- ./compiler/lua54.can:154
table["insert"](found, node) -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
end -- ./compiler/lua54.can:155
return found -- ./compiler/lua54.can:159
end -- ./compiler/lua54.can:159
local function all(list, tags) -- ./compiler/lua54.can:163
for _, node in ipairs(list) do -- ./compiler/lua54.can:164
local ok = false -- ./compiler/lua54.can:165
for _, tag in ipairs(tags) do -- ./compiler/lua54.can:166
if node["tag"] == tag then -- ./compiler/lua54.can:167
ok = true -- ./compiler/lua54.can:168
break -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
end -- ./compiler/lua54.can:169
if not ok then -- ./compiler/lua54.can:172
return false -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
end -- ./compiler/lua54.can:173
return true -- ./compiler/lua54.can:176
end -- ./compiler/lua54.can:176
local tags -- ./compiler/lua54.can:180
local function lua(ast, forceTag, ...) -- ./compiler/lua54.can:182
if options["mapLines"] and ast["pos"] then -- ./compiler/lua54.can:183
lastInputPos = ast["pos"] -- ./compiler/lua54.can:184
end -- ./compiler/lua54.can:184
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua54.can:186
end -- ./compiler/lua54.can:186
local UNPACK = function(list, i, j) -- ./compiler/lua54.can:190
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua54.can:191
end -- ./compiler/lua54.can:191
local APPEND = function(t, toAppend) -- ./compiler/lua54.can:193
return "do" .. indent() .. "local " .. var("a") .. " = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(" .. var("a") .. ", 1, " .. var("a") .. ".n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua54.can:194
end -- ./compiler/lua54.can:194
local CONTINUE_START = function() -- ./compiler/lua54.can:196
return "do" .. indent() -- ./compiler/lua54.can:197
end -- ./compiler/lua54.can:197
local CONTINUE_STOP = function() -- ./compiler/lua54.can:199
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua54.can:200
end -- ./compiler/lua54.can:200
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua54.can:202
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua54.can:202
if noLocal == nil then noLocal = false end -- ./compiler/lua54.can:202
local vars = {} -- ./compiler/lua54.can:203
local values = {} -- ./compiler/lua54.can:204
for _, list in ipairs(destructured) do -- ./compiler/lua54.can:205
for _, v in ipairs(list) do -- ./compiler/lua54.can:206
local var, val -- ./compiler/lua54.can:207
if v["tag"] == "Id" or v["tag"] == "AttributeId" then -- ./compiler/lua54.can:208
var = v -- ./compiler/lua54.can:209
val = { -- ./compiler/lua54.can:210
["tag"] = "Index", -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "Id", -- ./compiler/lua54.can:210
list["id"] -- ./compiler/lua54.can:210
}, -- ./compiler/lua54.can:210
{ -- ./compiler/lua54.can:210
["tag"] = "String", -- ./compiler/lua54.can:210
v[1] -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
} -- ./compiler/lua54.can:210
elseif v["tag"] == "Pair" then -- ./compiler/lua54.can:211
var = v[2] -- ./compiler/lua54.can:212
val = { -- ./compiler/lua54.can:213
["tag"] = "Index", -- ./compiler/lua54.can:213
{ -- ./compiler/lua54.can:213
["tag"] = "Id", -- ./compiler/lua54.can:213
list["id"] -- ./compiler/lua54.can:213
}, -- ./compiler/lua54.can:213
v[1] -- ./compiler/lua54.can:213
} -- ./compiler/lua54.can:213
else -- ./compiler/lua54.can:213
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua54.can:215
end -- ./compiler/lua54.can:215
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua54.can:217
val = { -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["rightOp"], -- ./compiler/lua54.can:218
var, -- ./compiler/lua54.can:218
{ -- ./compiler/lua54.can:218
["tag"] = "Op", -- ./compiler/lua54.can:218
destructured["leftOp"], -- ./compiler/lua54.can:218
val, -- ./compiler/lua54.can:218
var -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
} -- ./compiler/lua54.can:218
elseif destructured["rightOp"] then -- ./compiler/lua54.can:219
val = { -- ./compiler/lua54.can:220
["tag"] = "Op", -- ./compiler/lua54.can:220
destructured["rightOp"], -- ./compiler/lua54.can:220
var, -- ./compiler/lua54.can:220
val -- ./compiler/lua54.can:220
} -- ./compiler/lua54.can:220
elseif destructured["leftOp"] then -- ./compiler/lua54.can:221
val = { -- ./compiler/lua54.can:222
["tag"] = "Op", -- ./compiler/lua54.can:222
destructured["leftOp"], -- ./compiler/lua54.can:222
val, -- ./compiler/lua54.can:222
var -- ./compiler/lua54.can:222
} -- ./compiler/lua54.can:222
end -- ./compiler/lua54.can:222
table["insert"](vars, lua(var)) -- ./compiler/lua54.can:224
table["insert"](values, lua(val)) -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
end -- ./compiler/lua54.can:225
if # vars > 0 then -- ./compiler/lua54.can:228
local decl = noLocal and "" or "local " -- ./compiler/lua54.can:229
if newlineAfter then -- ./compiler/lua54.can:230
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua54.can:231
else -- ./compiler/lua54.can:231
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua54.can:233
end -- ./compiler/lua54.can:233
else -- ./compiler/lua54.can:233
return "" -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
end -- ./compiler/lua54.can:236
tags = setmetatable({ -- ./compiler/lua54.can:241
["Block"] = function(t) -- ./compiler/lua54.can:243
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua54.can:244
if hasPush and hasPush == t[# t] then -- ./compiler/lua54.can:245
hasPush["tag"] = "Return" -- ./compiler/lua54.can:246
hasPush = false -- ./compiler/lua54.can:247
end -- ./compiler/lua54.can:247
local r = push("scope", {}) -- ./compiler/lua54.can:249
if hasPush then -- ./compiler/lua54.can:250
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:251
end -- ./compiler/lua54.can:251
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:253
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua54.can:254
end -- ./compiler/lua54.can:254
if t[# t] then -- ./compiler/lua54.can:256
r = r .. (lua(t[# t])) -- ./compiler/lua54.can:257
end -- ./compiler/lua54.can:257
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua54.can:259
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua54.can:260
end -- ./compiler/lua54.can:260
return r .. pop("scope") -- ./compiler/lua54.can:262
end, -- ./compiler/lua54.can:262
["Do"] = function(t) -- ./compiler/lua54.can:268
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua54.can:269
end, -- ./compiler/lua54.can:269
["Set"] = function(t) -- ./compiler/lua54.can:272
local expr = t[# t] -- ./compiler/lua54.can:274
local vars, values = {}, {} -- ./compiler/lua54.can:275
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua54.can:276
for i, n in ipairs(t[1]) do -- ./compiler/lua54.can:277
if n["tag"] == "DestructuringId" then -- ./compiler/lua54.can:278
table["insert"](destructuringVars, n) -- ./compiler/lua54.can:279
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua54.can:280
else -- ./compiler/lua54.can:280
table["insert"](vars, n) -- ./compiler/lua54.can:282
table["insert"](values, expr[i]) -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
end -- ./compiler/lua54.can:283
if # t == 2 or # t == 3 then -- ./compiler/lua54.can:287
local r = "" -- ./compiler/lua54.can:288
if # vars > 0 then -- ./compiler/lua54.can:289
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua54.can:290
end -- ./compiler/lua54.can:290
if # destructuringVars > 0 then -- ./compiler/lua54.can:292
local destructured = {} -- ./compiler/lua54.can:293
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:294
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:295
end -- ./compiler/lua54.can:295
return r -- ./compiler/lua54.can:297
elseif # t == 4 then -- ./compiler/lua54.can:298
if t[3] == "=" then -- ./compiler/lua54.can:299
local r = "" -- ./compiler/lua54.can:300
if # vars > 0 then -- ./compiler/lua54.can:301
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:302
t[2], -- ./compiler/lua54.can:302
vars[1], -- ./compiler/lua54.can:302
{ -- ./compiler/lua54.can:302
["tag"] = "Paren", -- ./compiler/lua54.can:302
values[1] -- ./compiler/lua54.can:302
} -- ./compiler/lua54.can:302
}, "Op")) -- ./compiler/lua54.can:302
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua54.can:303
r = r .. (", " .. lua({ -- ./compiler/lua54.can:304
t[2], -- ./compiler/lua54.can:304
vars[i], -- ./compiler/lua54.can:304
{ -- ./compiler/lua54.can:304
["tag"] = "Paren", -- ./compiler/lua54.can:304
values[i] -- ./compiler/lua54.can:304
} -- ./compiler/lua54.can:304
}, "Op")) -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
end -- ./compiler/lua54.can:304
if # destructuringVars > 0 then -- ./compiler/lua54.can:307
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua54.can:308
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:309
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:310
end -- ./compiler/lua54.can:310
return r -- ./compiler/lua54.can:312
else -- ./compiler/lua54.can:312
local r = "" -- ./compiler/lua54.can:314
if # vars > 0 then -- ./compiler/lua54.can:315
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:316
t[3], -- ./compiler/lua54.can:316
{ -- ./compiler/lua54.can:316
["tag"] = "Paren", -- ./compiler/lua54.can:316
values[1] -- ./compiler/lua54.can:316
}, -- ./compiler/lua54.can:316
vars[1] -- ./compiler/lua54.can:316
}, "Op")) -- ./compiler/lua54.can:316
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua54.can:317
r = r .. (", " .. lua({ -- ./compiler/lua54.can:318
t[3], -- ./compiler/lua54.can:318
{ -- ./compiler/lua54.can:318
["tag"] = "Paren", -- ./compiler/lua54.can:318
values[i] -- ./compiler/lua54.can:318
}, -- ./compiler/lua54.can:318
vars[i] -- ./compiler/lua54.can:318
}, "Op")) -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
end -- ./compiler/lua54.can:318
if # destructuringVars > 0 then -- ./compiler/lua54.can:321
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua54.can:322
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:323
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:324
end -- ./compiler/lua54.can:324
return r -- ./compiler/lua54.can:326
end -- ./compiler/lua54.can:326
else -- ./compiler/lua54.can:326
local r = "" -- ./compiler/lua54.can:329
if # vars > 0 then -- ./compiler/lua54.can:330
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua54.can:331
t[2], -- ./compiler/lua54.can:331
vars[1], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Op", -- ./compiler/lua54.can:331
t[4], -- ./compiler/lua54.can:331
{ -- ./compiler/lua54.can:331
["tag"] = "Paren", -- ./compiler/lua54.can:331
values[1] -- ./compiler/lua54.can:331
}, -- ./compiler/lua54.can:331
vars[1] -- ./compiler/lua54.can:331
} -- ./compiler/lua54.can:331
}, "Op")) -- ./compiler/lua54.can:331
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua54.can:332
r = r .. (", " .. lua({ -- ./compiler/lua54.can:333
t[2], -- ./compiler/lua54.can:333
vars[i], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Op", -- ./compiler/lua54.can:333
t[4], -- ./compiler/lua54.can:333
{ -- ./compiler/lua54.can:333
["tag"] = "Paren", -- ./compiler/lua54.can:333
values[i] -- ./compiler/lua54.can:333
}, -- ./compiler/lua54.can:333
vars[i] -- ./compiler/lua54.can:333
} -- ./compiler/lua54.can:333
}, "Op")) -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
end -- ./compiler/lua54.can:333
if # destructuringVars > 0 then -- ./compiler/lua54.can:336
local destructured = { -- ./compiler/lua54.can:337
["rightOp"] = t[2], -- ./compiler/lua54.can:337
["leftOp"] = t[4] -- ./compiler/lua54.can:337
} -- ./compiler/lua54.can:337
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua54.can:338
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua54.can:339
end -- ./compiler/lua54.can:339
return r -- ./compiler/lua54.can:341
end -- ./compiler/lua54.can:341
end, -- ./compiler/lua54.can:341
["While"] = function(t) -- ./compiler/lua54.can:345
local r = "" -- ./compiler/lua54.can:346
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua54.can:347
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:348
if # lets > 0 then -- ./compiler/lua54.can:349
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:350
for _, l in ipairs(lets) do -- ./compiler/lua54.can:351
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
end -- ./compiler/lua54.can:352
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua54.can:355
if # lets > 0 then -- ./compiler/lua54.can:356
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:357
end -- ./compiler/lua54.can:357
if hasContinue then -- ./compiler/lua54.can:359
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:360
end -- ./compiler/lua54.can:360
r = r .. (lua(t[2])) -- ./compiler/lua54.can:362
if hasContinue then -- ./compiler/lua54.can:363
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:364
end -- ./compiler/lua54.can:364
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:366
if # lets > 0 then -- ./compiler/lua54.can:367
for _, l in ipairs(lets) do -- ./compiler/lua54.can:368
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua54.can:369
end -- ./compiler/lua54.can:369
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua54.can:371
end -- ./compiler/lua54.can:371
return r -- ./compiler/lua54.can:373
end, -- ./compiler/lua54.can:373
["Repeat"] = function(t) -- ./compiler/lua54.can:376
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua54.can:377
local r = "repeat" .. indent() -- ./compiler/lua54.can:378
if hasContinue then -- ./compiler/lua54.can:379
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:380
end -- ./compiler/lua54.can:380
r = r .. (lua(t[1])) -- ./compiler/lua54.can:382
if hasContinue then -- ./compiler/lua54.can:383
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:384
end -- ./compiler/lua54.can:384
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua54.can:386
return r -- ./compiler/lua54.can:387
end, -- ./compiler/lua54.can:387
["If"] = function(t) -- ./compiler/lua54.can:390
local r = "" -- ./compiler/lua54.can:391
local toClose = 0 -- ./compiler/lua54.can:392
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua54.can:393
if # lets > 0 then -- ./compiler/lua54.can:394
r = r .. ("do" .. indent()) -- ./compiler/lua54.can:395
toClose = toClose + (1) -- ./compiler/lua54.can:396
for _, l in ipairs(lets) do -- ./compiler/lua54.can:397
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
end -- ./compiler/lua54.can:398
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua54.can:401
for i = 3, # t - 1, 2 do -- ./compiler/lua54.can:402
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua54.can:403
if # lets > 0 then -- ./compiler/lua54.can:404
r = r .. ("else" .. indent()) -- ./compiler/lua54.can:405
toClose = toClose + (1) -- ./compiler/lua54.can:406
for _, l in ipairs(lets) do -- ./compiler/lua54.can:407
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua54.can:408
end -- ./compiler/lua54.can:408
else -- ./compiler/lua54.can:408
r = r .. ("else") -- ./compiler/lua54.can:411
end -- ./compiler/lua54.can:411
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua54.can:413
end -- ./compiler/lua54.can:413
if # t % 2 == 1 then -- ./compiler/lua54.can:415
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua54.can:416
end -- ./compiler/lua54.can:416
r = r .. ("end") -- ./compiler/lua54.can:418
for i = 1, toClose do -- ./compiler/lua54.can:419
r = r .. (unindent() .. "end") -- ./compiler/lua54.can:420
end -- ./compiler/lua54.can:420
return r -- ./compiler/lua54.can:422
end, -- ./compiler/lua54.can:422
["Fornum"] = function(t) -- ./compiler/lua54.can:425
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua54.can:426
if # t == 5 then -- ./compiler/lua54.can:427
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua54.can:428
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua54.can:429
if hasContinue then -- ./compiler/lua54.can:430
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:431
end -- ./compiler/lua54.can:431
r = r .. (lua(t[5])) -- ./compiler/lua54.can:433
if hasContinue then -- ./compiler/lua54.can:434
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:435
end -- ./compiler/lua54.can:435
return r .. unindent() .. "end" -- ./compiler/lua54.can:437
else -- ./compiler/lua54.can:437
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua54.can:439
r = r .. (" do" .. indent()) -- ./compiler/lua54.can:440
if hasContinue then -- ./compiler/lua54.can:441
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:442
end -- ./compiler/lua54.can:442
r = r .. (lua(t[4])) -- ./compiler/lua54.can:444
if hasContinue then -- ./compiler/lua54.can:445
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:446
end -- ./compiler/lua54.can:446
return r .. unindent() .. "end" -- ./compiler/lua54.can:448
end -- ./compiler/lua54.can:448
end, -- ./compiler/lua54.can:448
["Forin"] = function(t) -- ./compiler/lua54.can:452
local destructured = {} -- ./compiler/lua54.can:453
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua54.can:454
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua54.can:455
if hasContinue then -- ./compiler/lua54.can:456
r = r .. (CONTINUE_START()) -- ./compiler/lua54.can:457
end -- ./compiler/lua54.can:457
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua54.can:459
if hasContinue then -- ./compiler/lua54.can:460
r = r .. (CONTINUE_STOP()) -- ./compiler/lua54.can:461
end -- ./compiler/lua54.can:461
return r .. unindent() .. "end" -- ./compiler/lua54.can:463
end, -- ./compiler/lua54.can:463
["Local"] = function(t) -- ./compiler/lua54.can:466
local destructured = {} -- ./compiler/lua54.can:467
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:468
if t[2][1] then -- ./compiler/lua54.can:469
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:470
end -- ./compiler/lua54.can:470
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:472
end, -- ./compiler/lua54.can:472
["Let"] = function(t) -- ./compiler/lua54.can:475
local destructured = {} -- ./compiler/lua54.can:476
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua54.can:477
local r = "local " .. nameList -- ./compiler/lua54.can:478
if t[2][1] then -- ./compiler/lua54.can:479
if all(t[2], { -- ./compiler/lua54.can:480
"Nil", -- ./compiler/lua54.can:480
"Dots", -- ./compiler/lua54.can:480
"Boolean", -- ./compiler/lua54.can:480
"Number", -- ./compiler/lua54.can:480
"String" -- ./compiler/lua54.can:480
}) then -- ./compiler/lua54.can:480
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:481
else -- ./compiler/lua54.can:481
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
end -- ./compiler/lua54.can:483
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua54.can:486
end, -- ./compiler/lua54.can:486
["Localrec"] = function(t) -- ./compiler/lua54.can:489
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua54.can:490
end, -- ./compiler/lua54.can:490
["Goto"] = function(t) -- ./compiler/lua54.can:493
return "goto " .. lua(t, "Id") -- ./compiler/lua54.can:494
end, -- ./compiler/lua54.can:494
["Label"] = function(t) -- ./compiler/lua54.can:497
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua54.can:498
end, -- ./compiler/lua54.can:498
["Return"] = function(t) -- ./compiler/lua54.can:501
local push = peek("push") -- ./compiler/lua54.can:502
if push then -- ./compiler/lua54.can:503
local r = "" -- ./compiler/lua54.can:504
for _, val in ipairs(t) do -- ./compiler/lua54.can:505
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua54.can:506
end -- ./compiler/lua54.can:506
return r .. "return " .. UNPACK(push) -- ./compiler/lua54.can:508
else -- ./compiler/lua54.can:508
return "return " .. lua(t, "_lhs") -- ./compiler/lua54.can:510
end -- ./compiler/lua54.can:510
end, -- ./compiler/lua54.can:510
["Push"] = function(t) -- ./compiler/lua54.can:514
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua54.can:515
r = "" -- ./compiler/lua54.can:516
for i = 1, # t - 1, 1 do -- ./compiler/lua54.can:517
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua54.can:518
end -- ./compiler/lua54.can:518
if t[# t] then -- ./compiler/lua54.can:520
if t[# t]["tag"] == "Call" then -- ./compiler/lua54.can:521
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua54.can:522
else -- ./compiler/lua54.can:522
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
end -- ./compiler/lua54.can:524
return r -- ./compiler/lua54.can:527
end, -- ./compiler/lua54.can:527
["Break"] = function() -- ./compiler/lua54.can:530
return "break" -- ./compiler/lua54.can:531
end, -- ./compiler/lua54.can:531
["Continue"] = function() -- ./compiler/lua54.can:534
return "goto " .. var("continue") -- ./compiler/lua54.can:535
end, -- ./compiler/lua54.can:535
["Nil"] = function() -- ./compiler/lua54.can:542
return "nil" -- ./compiler/lua54.can:543
end, -- ./compiler/lua54.can:543
["Dots"] = function() -- ./compiler/lua54.can:546
local macroargs = peek("macroargs") -- ./compiler/lua54.can:547
if macroargs and not nomacro["variables"]["..."] and macroargs["..."] then -- ./compiler/lua54.can:548
nomacro["variables"]["..."] = true -- ./compiler/lua54.can:549
local r = lua(macroargs["..."], "_lhs") -- ./compiler/lua54.can:550
nomacro["variables"]["..."] = nil -- ./compiler/lua54.can:551
return r -- ./compiler/lua54.can:552
else -- ./compiler/lua54.can:552
return "..." -- ./compiler/lua54.can:554
end -- ./compiler/lua54.can:554
end, -- ./compiler/lua54.can:554
["Boolean"] = function(t) -- ./compiler/lua54.can:558
return tostring(t[1]) -- ./compiler/lua54.can:559
end, -- ./compiler/lua54.can:559
["Number"] = function(t) -- ./compiler/lua54.can:562
return tostring(t[1]) -- ./compiler/lua54.can:563
end, -- ./compiler/lua54.can:563
["String"] = function(t) -- ./compiler/lua54.can:566
return ("%q"):format(t[1]) -- ./compiler/lua54.can:567
end, -- ./compiler/lua54.can:567
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua54.can:570
local r = "(" -- ./compiler/lua54.can:571
local decl = {} -- ./compiler/lua54.can:572
if t[1][1] then -- ./compiler/lua54.can:573
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua54.can:574
local id = lua(t[1][1][1]) -- ./compiler/lua54.can:575
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:576
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua54.can:577
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:578
r = r .. (id) -- ./compiler/lua54.can:579
else -- ./compiler/lua54.can:579
r = r .. (lua(t[1][1])) -- ./compiler/lua54.can:581
end -- ./compiler/lua54.can:581
for i = 2, # t[1], 1 do -- ./compiler/lua54.can:583
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua54.can:584
local id = lua(t[1][i][1]) -- ./compiler/lua54.can:585
indentLevel = indentLevel + (1) -- ./compiler/lua54.can:586
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua54.can:587
indentLevel = indentLevel - (1) -- ./compiler/lua54.can:588
r = r .. (", " .. id) -- ./compiler/lua54.can:589
else -- ./compiler/lua54.can:589
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
end -- ./compiler/lua54.can:591
r = r .. (")" .. indent()) -- ./compiler/lua54.can:595
for _, d in ipairs(decl) do -- ./compiler/lua54.can:596
r = r .. (d .. newline()) -- ./compiler/lua54.can:597
end -- ./compiler/lua54.can:597
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua54.can:599
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua54.can:600
end -- ./compiler/lua54.can:600
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua54.can:602
if hasPush then -- ./compiler/lua54.can:603
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:604
else -- ./compiler/lua54.can:604
push("push", false) -- ./compiler/lua54.can:606
end -- ./compiler/lua54.can:606
r = r .. (lua(t[2])) -- ./compiler/lua54.can:608
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua54.can:609
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:610
end -- ./compiler/lua54.can:610
pop("push") -- ./compiler/lua54.can:612
return r .. unindent() .. "end" -- ./compiler/lua54.can:613
end, -- ./compiler/lua54.can:613
["Function"] = function(t) -- ./compiler/lua54.can:615
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua54.can:616
end, -- ./compiler/lua54.can:616
["Pair"] = function(t) -- ./compiler/lua54.can:619
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua54.can:620
end, -- ./compiler/lua54.can:620
["Table"] = function(t) -- ./compiler/lua54.can:622
if # t == 0 then -- ./compiler/lua54.can:623
return "{}" -- ./compiler/lua54.can:624
elseif # t == 1 then -- ./compiler/lua54.can:625
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua54.can:626
else -- ./compiler/lua54.can:626
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua54.can:628
end -- ./compiler/lua54.can:628
end, -- ./compiler/lua54.can:628
["TableCompr"] = function(t) -- ./compiler/lua54.can:632
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua54.can:633
end, -- ./compiler/lua54.can:633
["Op"] = function(t) -- ./compiler/lua54.can:636
local r -- ./compiler/lua54.can:637
if # t == 2 then -- ./compiler/lua54.can:638
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:639
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua54.can:640
else -- ./compiler/lua54.can:640
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua54.can:642
end -- ./compiler/lua54.can:642
else -- ./compiler/lua54.can:642
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua54.can:645
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua54.can:646
else -- ./compiler/lua54.can:646
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
end -- ./compiler/lua54.can:648
return r -- ./compiler/lua54.can:651
end, -- ./compiler/lua54.can:651
["Paren"] = function(t) -- ./compiler/lua54.can:654
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua54.can:655
end, -- ./compiler/lua54.can:655
["MethodStub"] = function(t) -- ./compiler/lua54.can:658
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:664
end, -- ./compiler/lua54.can:664
["SafeMethodStub"] = function(t) -- ./compiler/lua54.can:667
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua54.can:674
end, -- ./compiler/lua54.can:674
["LetExpr"] = function(t) -- ./compiler/lua54.can:681
return lua(t[1][1]) -- ./compiler/lua54.can:682
end, -- ./compiler/lua54.can:682
["_statexpr"] = function(t, stat) -- ./compiler/lua54.can:686
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua54.can:687
local r = "(function()" .. indent() -- ./compiler/lua54.can:688
if hasPush then -- ./compiler/lua54.can:689
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua54.can:690
else -- ./compiler/lua54.can:690
push("push", false) -- ./compiler/lua54.can:692
end -- ./compiler/lua54.can:692
r = r .. (lua(t, stat)) -- ./compiler/lua54.can:694
if hasPush then -- ./compiler/lua54.can:695
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua54.can:696
end -- ./compiler/lua54.can:696
pop("push") -- ./compiler/lua54.can:698
r = r .. (unindent() .. "end)()") -- ./compiler/lua54.can:699
return r -- ./compiler/lua54.can:700
end, -- ./compiler/lua54.can:700
["DoExpr"] = function(t) -- ./compiler/lua54.can:703
if t[# t]["tag"] == "Push" then -- ./compiler/lua54.can:704
t[# t]["tag"] = "Return" -- ./compiler/lua54.can:705
end -- ./compiler/lua54.can:705
return lua(t, "_statexpr", "Do") -- ./compiler/lua54.can:707
end, -- ./compiler/lua54.can:707
["WhileExpr"] = function(t) -- ./compiler/lua54.can:710
return lua(t, "_statexpr", "While") -- ./compiler/lua54.can:711
end, -- ./compiler/lua54.can:711
["RepeatExpr"] = function(t) -- ./compiler/lua54.can:714
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua54.can:715
end, -- ./compiler/lua54.can:715
["IfExpr"] = function(t) -- ./compiler/lua54.can:718
for i = 2, # t do -- ./compiler/lua54.can:719
local block = t[i] -- ./compiler/lua54.can:720
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua54.can:721
block[# block]["tag"] = "Return" -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
end -- ./compiler/lua54.can:722
return lua(t, "_statexpr", "If") -- ./compiler/lua54.can:725
end, -- ./compiler/lua54.can:725
["FornumExpr"] = function(t) -- ./compiler/lua54.can:728
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua54.can:729
end, -- ./compiler/lua54.can:729
["ForinExpr"] = function(t) -- ./compiler/lua54.can:732
return lua(t, "_statexpr", "Forin") -- ./compiler/lua54.can:733
end, -- ./compiler/lua54.can:733
["Call"] = function(t) -- ./compiler/lua54.can:739
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:740
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:741
elseif t[1]["tag"] == "Id" and not nomacro["functions"][t[1][1]] and macros["functions"][t[1][1]] then -- ./compiler/lua54.can:742
local macro = macros["functions"][t[1][1]] -- ./compiler/lua54.can:743
local replacement = macro["replacement"] -- ./compiler/lua54.can:744
local r -- ./compiler/lua54.can:745
nomacro["functions"][t[1][1]] = true -- ./compiler/lua54.can:746
if type(replacement) == "function" then -- ./compiler/lua54.can:747
local args = {} -- ./compiler/lua54.can:748
for i = 2, # t do -- ./compiler/lua54.can:749
table["insert"](args, lua(t[i])) -- ./compiler/lua54.can:750
end -- ./compiler/lua54.can:750
r = replacement(unpack(args)) -- ./compiler/lua54.can:752
else -- ./compiler/lua54.can:752
local macroargs = util["merge"](peek("macroargs")) -- ./compiler/lua54.can:754
for i, arg in ipairs(macro["args"]) do -- ./compiler/lua54.can:755
if arg["tag"] == "Dots" then -- ./compiler/lua54.can:756
macroargs["..."] = (function() -- ./compiler/lua54.can:757
local self = {} -- ./compiler/lua54.can:757
for j = i + 1, # t do -- ./compiler/lua54.can:757
self[#self+1] = t[j] -- ./compiler/lua54.can:757
end -- ./compiler/lua54.can:757
return self -- ./compiler/lua54.can:757
end)() -- ./compiler/lua54.can:757
elseif arg["tag"] == "Id" then -- ./compiler/lua54.can:758
if t[i + 1] == nil then -- ./compiler/lua54.can:759
error(("bad argument #%s to macro %s (value expected)"):format(i, t[1][1])) -- ./compiler/lua54.can:760
end -- ./compiler/lua54.can:760
macroargs[arg[1]] = t[i + 1] -- ./compiler/lua54.can:762
else -- ./compiler/lua54.can:762
error(("unexpected argument type %s in macro %s"):format(arg["tag"], t[1][1])) -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
end -- ./compiler/lua54.can:764
push("macroargs", macroargs) -- ./compiler/lua54.can:767
r = lua(replacement) -- ./compiler/lua54.can:768
pop("macroargs") -- ./compiler/lua54.can:769
end -- ./compiler/lua54.can:769
nomacro["functions"][t[1][1]] = nil -- ./compiler/lua54.can:771
return r -- ./compiler/lua54.can:772
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua54.can:773
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua54.can:774
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:775
else -- ./compiler/lua54.can:775
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:777
end -- ./compiler/lua54.can:777
else -- ./compiler/lua54.can:777
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua54.can:780
end -- ./compiler/lua54.can:780
end, -- ./compiler/lua54.can:780
["SafeCall"] = function(t) -- ./compiler/lua54.can:784
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:785
return lua(t, "SafeIndex") -- ./compiler/lua54.can:786
else -- ./compiler/lua54.can:786
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua54.can:788
end -- ./compiler/lua54.can:788
end, -- ./compiler/lua54.can:788
["_lhs"] = function(t, start, newlines) -- ./compiler/lua54.can:793
if start == nil then start = 1 end -- ./compiler/lua54.can:793
local r -- ./compiler/lua54.can:794
if t[start] then -- ./compiler/lua54.can:795
r = lua(t[start]) -- ./compiler/lua54.can:796
for i = start + 1, # t, 1 do -- ./compiler/lua54.can:797
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua54.can:798
end -- ./compiler/lua54.can:798
else -- ./compiler/lua54.can:798
r = "" -- ./compiler/lua54.can:801
end -- ./compiler/lua54.can:801
return r -- ./compiler/lua54.can:803
end, -- ./compiler/lua54.can:803
["Id"] = function(t) -- ./compiler/lua54.can:806
local r = t[1] -- ./compiler/lua54.can:807
local macroargs = peek("macroargs") -- ./compiler/lua54.can:808
if not nomacro["variables"][t[1]] then -- ./compiler/lua54.can:809
nomacro["variables"][t[1]] = true -- ./compiler/lua54.can:810
if macroargs and macroargs[t[1]] then -- ./compiler/lua54.can:811
r = lua(macroargs[t[1]]) -- ./compiler/lua54.can:812
elseif macros["variables"][t[1]] ~= nil then -- ./compiler/lua54.can:813
local macro = macros["variables"][t[1]] -- ./compiler/lua54.can:814
if type(macro) == "function" then -- ./compiler/lua54.can:815
r = macro() -- ./compiler/lua54.can:816
else -- ./compiler/lua54.can:816
r = lua(macro) -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
end -- ./compiler/lua54.can:818
nomacro["variables"][t[1]] = nil -- ./compiler/lua54.can:821
end -- ./compiler/lua54.can:821
return r -- ./compiler/lua54.can:823
end, -- ./compiler/lua54.can:823
["AttributeId"] = function(t) -- ./compiler/lua54.can:826
if t[2] then -- ./compiler/lua54.can:827
return t[1] .. " <" .. t[2] .. ">" -- ./compiler/lua54.can:828
else -- ./compiler/lua54.can:828
return t[1] -- ./compiler/lua54.can:830
end -- ./compiler/lua54.can:830
end, -- ./compiler/lua54.can:830
["DestructuringId"] = function(t) -- ./compiler/lua54.can:834
if t["id"] then -- ./compiler/lua54.can:835
return t["id"] -- ./compiler/lua54.can:836
else -- ./compiler/lua54.can:836
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua54.can:838
local vars = { ["id"] = tmp() } -- ./compiler/lua54.can:839
for j = 1, # t, 1 do -- ./compiler/lua54.can:840
table["insert"](vars, t[j]) -- ./compiler/lua54.can:841
end -- ./compiler/lua54.can:841
table["insert"](d, vars) -- ./compiler/lua54.can:843
t["id"] = vars["id"] -- ./compiler/lua54.can:844
return vars["id"] -- ./compiler/lua54.can:845
end -- ./compiler/lua54.can:845
end, -- ./compiler/lua54.can:845
["Index"] = function(t) -- ./compiler/lua54.can:849
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua54.can:850
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:851
else -- ./compiler/lua54.can:851
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua54.can:853
end -- ./compiler/lua54.can:853
end, -- ./compiler/lua54.can:853
["SafeIndex"] = function(t) -- ./compiler/lua54.can:857
if t[1]["tag"] ~= "Id" then -- ./compiler/lua54.can:858
local l = {} -- ./compiler/lua54.can:859
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua54.can:860
table["insert"](l, 1, t) -- ./compiler/lua54.can:861
t = t[1] -- ./compiler/lua54.can:862
end -- ./compiler/lua54.can:862
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua54.can:864
for _, e in ipairs(l) do -- ./compiler/lua54.can:865
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua54.can:866
if e["tag"] == "SafeIndex" then -- ./compiler/lua54.can:867
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua54.can:868
else -- ./compiler/lua54.can:868
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
end -- ./compiler/lua54.can:870
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua54.can:873
return r -- ./compiler/lua54.can:874
else -- ./compiler/lua54.can:874
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua54.can:876
end -- ./compiler/lua54.can:876
end, -- ./compiler/lua54.can:876
["_opid"] = { -- ./compiler/lua54.can:881
["add"] = "+", -- ./compiler/lua54.can:882
["sub"] = "-", -- ./compiler/lua54.can:882
["mul"] = "*", -- ./compiler/lua54.can:882
["div"] = "/", -- ./compiler/lua54.can:882
["idiv"] = "//", -- ./compiler/lua54.can:883
["mod"] = "%", -- ./compiler/lua54.can:883
["pow"] = "^", -- ./compiler/lua54.can:883
["concat"] = "..", -- ./compiler/lua54.can:883
["band"] = "&", -- ./compiler/lua54.can:884
["bor"] = "|", -- ./compiler/lua54.can:884
["bxor"] = "~", -- ./compiler/lua54.can:884
["shl"] = "<<", -- ./compiler/lua54.can:884
["shr"] = ">>", -- ./compiler/lua54.can:884
["eq"] = "==", -- ./compiler/lua54.can:885
["ne"] = "~=", -- ./compiler/lua54.can:885
["lt"] = "<", -- ./compiler/lua54.can:885
["gt"] = ">", -- ./compiler/lua54.can:885
["le"] = "<=", -- ./compiler/lua54.can:885
["ge"] = ">=", -- ./compiler/lua54.can:885
["and"] = "and", -- ./compiler/lua54.can:886
["or"] = "or", -- ./compiler/lua54.can:886
["unm"] = "-", -- ./compiler/lua54.can:886
["len"] = "#", -- ./compiler/lua54.can:886
["bnot"] = "~", -- ./compiler/lua54.can:886
["not"] = "not" -- ./compiler/lua54.can:886
} -- ./compiler/lua54.can:886
}, { ["__index"] = function(self, key) -- ./compiler/lua54.can:889
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua54.can:890
end }) -- ./compiler/lua54.can:890
targetName = "Lua 5.3" -- ./compiler/lua53.can:1
tags["AttributeId"] = function(t) -- ./compiler/lua53.can:4
if t[2] then -- ./compiler/lua53.can:5
error("target " .. targetName .. " does not support variable attributes") -- ./compiler/lua53.can:6
else -- ./compiler/lua53.can:6
return t[1] -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
end -- ./compiler/lua53.can:8
targetName = "Lua 5.2" -- ./compiler/lua52.can:1
APPEND = function(t, toAppend) -- ./compiler/lua52.can:3
return "do" .. indent() .. "local " .. var("a") .. ", " .. var("p") .. " = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #" .. var("a") .. " do" .. indent() .. t .. "[" .. var("p") .. "] = " .. var("a") .. "[i]" .. newline() .. "" .. var("p") .. " = " .. var("p") .. " + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/lua52.can:4
end -- ./compiler/lua52.can:4
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/lua52.can:7
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/lua52.can:8
end -- ./compiler/lua52.can:8
tags["_opid"]["band"] = function(left, right) -- ./compiler/lua52.can:10
return "bit32.band(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:11
end -- ./compiler/lua52.can:11
tags["_opid"]["bor"] = function(left, right) -- ./compiler/lua52.can:13
return "bit32.bor(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:14
end -- ./compiler/lua52.can:14
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/lua52.can:16
return "bit32.bxor(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:17
end -- ./compiler/lua52.can:17
tags["_opid"]["shl"] = function(left, right) -- ./compiler/lua52.can:19
return "bit32.lshift(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:20
end -- ./compiler/lua52.can:20
tags["_opid"]["shr"] = function(left, right) -- ./compiler/lua52.can:22
return "bit32.rshift(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/lua52.can:23
end -- ./compiler/lua52.can:23
tags["_opid"]["bnot"] = function(right) -- ./compiler/lua52.can:25
return "bit32.bnot(" .. lua(right) .. ")" -- ./compiler/lua52.can:26
end -- ./compiler/lua52.can:26
targetName = "LuaJIT" -- ./compiler/luajit.can:1
UNPACK = function(list, i, j) -- ./compiler/luajit.can:3
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/luajit.can:4
end -- ./compiler/luajit.can:4
tags["_opid"]["band"] = function(left, right) -- ./compiler/luajit.can:7
addRequire("bit", "band", "band") -- ./compiler/luajit.can:8
return var("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:9
end -- ./compiler/luajit.can:9
tags["_opid"]["bor"] = function(left, right) -- ./compiler/luajit.can:11
addRequire("bit", "bor", "bor") -- ./compiler/luajit.can:12
return var("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:13
end -- ./compiler/luajit.can:13
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/luajit.can:15
addRequire("bit", "bxor", "bxor") -- ./compiler/luajit.can:16
return var("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:17
end -- ./compiler/luajit.can:17
tags["_opid"]["shl"] = function(left, right) -- ./compiler/luajit.can:19
addRequire("bit", "lshift", "lshift") -- ./compiler/luajit.can:20
return var("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:21
end -- ./compiler/luajit.can:21
tags["_opid"]["shr"] = function(left, right) -- ./compiler/luajit.can:23
addRequire("bit", "rshift", "rshift") -- ./compiler/luajit.can:24
return var("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:25
end -- ./compiler/luajit.can:25
tags["_opid"]["bnot"] = function(right) -- ./compiler/luajit.can:27
addRequire("bit", "bnot", "bnot") -- ./compiler/luajit.can:28
return var("bnot") .. "(" .. lua(right) .. ")" -- ./compiler/luajit.can:29
end -- ./compiler/luajit.can:29
targetName = "Lua 5.1" -- ./compiler/lua51.can:1
states["continue"] = {} -- ./compiler/lua51.can:3
CONTINUE_START = function() -- ./compiler/lua51.can:5
return "local " .. var("break") .. newline() .. "repeat" .. indent() .. push("continue", var("break")) -- ./compiler/lua51.can:6
end -- ./compiler/lua51.can:6
CONTINUE_STOP = function() -- ./compiler/lua51.can:8
return pop("continue") .. unindent() .. "until true" .. newline() .. "if " .. var("break") .. " then break end" -- ./compiler/lua51.can:9
end -- ./compiler/lua51.can:9
tags["Continue"] = function() -- ./compiler/lua51.can:12
return "break" -- ./compiler/lua51.can:13
end -- ./compiler/lua51.can:13
tags["Break"] = function() -- ./compiler/lua51.can:15
local inContinue = peek("continue") -- ./compiler/lua51.can:16
if inContinue then -- ./compiler/lua51.can:17
return inContinue .. " = true" .. newline() .. "break" -- ./compiler/lua51.can:18
else -- ./compiler/lua51.can:18
return "break" -- ./compiler/lua51.can:20
end -- ./compiler/lua51.can:20
end -- ./compiler/lua51.can:20
tags["Goto"] = function() -- ./compiler/lua51.can:25
error("target " .. targetName .. " does not support gotos") -- ./compiler/lua51.can:26
end -- ./compiler/lua51.can:26
tags["Label"] = function() -- ./compiler/lua51.can:28
error("target " .. targetName .. " does not support goto labels") -- ./compiler/lua51.can:29
end -- ./compiler/lua51.can:29
local code = lua(ast) .. newline() -- ./compiler/lua54.can:896
return requireStr .. code -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
end -- ./compiler/lua54.can:897
local lua54 = _() or lua54 -- ./compiler/lua54.can:902
return lua54 -- ./compiler/lua53.can:18
end -- ./compiler/lua53.can:18
local lua53 = _() or lua53 -- ./compiler/lua53.can:22
return lua53 -- ./compiler/lua52.can:35
end -- ./compiler/lua52.can:35
local lua52 = _() or lua52 -- ./compiler/lua52.can:39
return lua52 -- ./compiler/luajit.can:38
end -- ./compiler/luajit.can:38
local luajit = _() or luajit -- ./compiler/luajit.can:42
return luajit -- ./compiler/lua51.can:38
end -- ./compiler/lua51.can:38
local lua51 = _() or lua51 -- ./compiler/lua51.can:42
package["loaded"]["compiler.lua51"] = lua51 or true -- ./compiler/lua51.can:43
local function _() -- ./compiler/lua51.can:47
local scope = {} -- ./candran/can-parser/scope.lua:4
scope["lineno"] = function(s, i) -- ./candran/can-parser/scope.lua:6
if i == 1 then -- ./candran/can-parser/scope.lua:7
return 1, 1 -- ./candran/can-parser/scope.lua:7
end -- ./candran/can-parser/scope.lua:7
local l, lastline = 0, "" -- ./candran/can-parser/scope.lua:8
s = s:sub(1, i) .. "\
" -- ./candran/can-parser/scope.lua:9
for line in s:gmatch("[^\
]*[\
]") do -- ./candran/can-parser/scope.lua:10
l = l + 1 -- ./candran/can-parser/scope.lua:11
lastline = line -- ./candran/can-parser/scope.lua:12
end -- ./candran/can-parser/scope.lua:12
local c = lastline:len() - 1 -- ./candran/can-parser/scope.lua:14
return l, c ~= 0 and c or 1 -- ./candran/can-parser/scope.lua:15
end -- ./candran/can-parser/scope.lua:15
scope["new_scope"] = function(env) -- ./candran/can-parser/scope.lua:18
if not env["scope"] then -- ./candran/can-parser/scope.lua:19
env["scope"] = 0 -- ./candran/can-parser/scope.lua:20
else -- ./candran/can-parser/scope.lua:20
env["scope"] = env["scope"] + 1 -- ./candran/can-parser/scope.lua:22
end -- ./candran/can-parser/scope.lua:22
local scope = env["scope"] -- ./candran/can-parser/scope.lua:24
env["maxscope"] = scope -- ./candran/can-parser/scope.lua:25
env[scope] = {} -- ./candran/can-parser/scope.lua:26
env[scope]["label"] = {} -- ./candran/can-parser/scope.lua:27
env[scope]["local"] = {} -- ./candran/can-parser/scope.lua:28
env[scope]["goto"] = {} -- ./candran/can-parser/scope.lua:29
end -- ./candran/can-parser/scope.lua:29
scope["begin_scope"] = function(env) -- ./candran/can-parser/scope.lua:32
env["scope"] = env["scope"] + 1 -- ./candran/can-parser/scope.lua:33
end -- ./candran/can-parser/scope.lua:33
scope["end_scope"] = function(env) -- ./candran/can-parser/scope.lua:36
env["scope"] = env["scope"] - 1 -- ./candran/can-parser/scope.lua:37
end -- ./candran/can-parser/scope.lua:37
scope["new_function"] = function(env) -- ./candran/can-parser/scope.lua:40
if not env["fscope"] then -- ./candran/can-parser/scope.lua:41
env["fscope"] = 0 -- ./candran/can-parser/scope.lua:42
else -- ./candran/can-parser/scope.lua:42
env["fscope"] = env["fscope"] + 1 -- ./candran/can-parser/scope.lua:44
end -- ./candran/can-parser/scope.lua:44
local fscope = env["fscope"] -- ./candran/can-parser/scope.lua:46
env["function"][fscope] = {} -- ./candran/can-parser/scope.lua:47
end -- ./candran/can-parser/scope.lua:47
scope["begin_function"] = function(env) -- ./candran/can-parser/scope.lua:50
env["fscope"] = env["fscope"] + 1 -- ./candran/can-parser/scope.lua:51
end -- ./candran/can-parser/scope.lua:51
scope["end_function"] = function(env) -- ./candran/can-parser/scope.lua:54
env["fscope"] = env["fscope"] - 1 -- ./candran/can-parser/scope.lua:55
end -- ./candran/can-parser/scope.lua:55
scope["begin_loop"] = function(env) -- ./candran/can-parser/scope.lua:58
if not env["loop"] then -- ./candran/can-parser/scope.lua:59
env["loop"] = 1 -- ./candran/can-parser/scope.lua:60
else -- ./candran/can-parser/scope.lua:60
env["loop"] = env["loop"] + 1 -- ./candran/can-parser/scope.lua:62
end -- ./candran/can-parser/scope.lua:62
end -- ./candran/can-parser/scope.lua:62
scope["end_loop"] = function(env) -- ./candran/can-parser/scope.lua:66
env["loop"] = env["loop"] - 1 -- ./candran/can-parser/scope.lua:67
end -- ./candran/can-parser/scope.lua:67
scope["insideloop"] = function(env) -- ./candran/can-parser/scope.lua:70
return env["loop"] and env["loop"] > 0 -- ./candran/can-parser/scope.lua:71
end -- ./candran/can-parser/scope.lua:71
return scope -- ./candran/can-parser/scope.lua:74
end -- ./candran/can-parser/scope.lua:74
local scope = _() or scope -- ./candran/can-parser/scope.lua:78
package["loaded"]["candran.can-parser.scope"] = scope or true -- ./candran/can-parser/scope.lua:79
local function _() -- ./candran/can-parser/scope.lua:82
local scope = require("candran.can-parser.scope") -- ./candran/can-parser/validator.lua:4
local lineno = scope["lineno"] -- ./candran/can-parser/validator.lua:6
local new_scope, end_scope = scope["new_scope"], scope["end_scope"] -- ./candran/can-parser/validator.lua:7
local new_function, end_function = scope["new_function"], scope["end_function"] -- ./candran/can-parser/validator.lua:8
local begin_loop, end_loop = scope["begin_loop"], scope["end_loop"] -- ./candran/can-parser/validator.lua:9
local insideloop = scope["insideloop"] -- ./candran/can-parser/validator.lua:10
local function syntaxerror(errorinfo, pos, msg) -- ./candran/can-parser/validator.lua:13
local l, c = lineno(errorinfo["subject"], pos) -- ./candran/can-parser/validator.lua:14
local error_msg = "%s:%d:%d: syntax error, %s" -- ./candran/can-parser/validator.lua:15
return string["format"](error_msg, errorinfo["filename"], l, c, msg) -- ./candran/can-parser/validator.lua:16
end -- ./candran/can-parser/validator.lua:16
local function exist_label(env, scope, stm) -- ./candran/can-parser/validator.lua:19
local l = stm[1] -- ./candran/can-parser/validator.lua:20
for s = scope, 0, - 1 do -- ./candran/can-parser/validator.lua:21
if env[s]["label"][l] then -- ./candran/can-parser/validator.lua:22
return true -- ./candran/can-parser/validator.lua:22
end -- ./candran/can-parser/validator.lua:22
end -- ./candran/can-parser/validator.lua:22
return false -- ./candran/can-parser/validator.lua:24
end -- ./candran/can-parser/validator.lua:24
local function set_label(env, label, pos) -- ./candran/can-parser/validator.lua:27
local scope = env["scope"] -- ./candran/can-parser/validator.lua:28
local l = env[scope]["label"][label] -- ./candran/can-parser/validator.lua:29
if not l then -- ./candran/can-parser/validator.lua:30
env[scope]["label"][label] = { -- ./candran/can-parser/validator.lua:31
["name"] = label, -- ./candran/can-parser/validator.lua:31
["pos"] = pos -- ./candran/can-parser/validator.lua:31
} -- ./candran/can-parser/validator.lua:31
return true -- ./candran/can-parser/validator.lua:32
else -- ./candran/can-parser/validator.lua:32
local msg = "label '%s' already defined at line %d" -- ./candran/can-parser/validator.lua:34
local line = lineno(env["errorinfo"]["subject"], l["pos"]) -- ./candran/can-parser/validator.lua:35
msg = string["format"](msg, label, line) -- ./candran/can-parser/validator.lua:36
return nil, syntaxerror(env["errorinfo"], pos, msg) -- ./candran/can-parser/validator.lua:37
end -- ./candran/can-parser/validator.lua:37
end -- ./candran/can-parser/validator.lua:37
local function set_pending_goto(env, stm) -- ./candran/can-parser/validator.lua:41
local scope = env["scope"] -- ./candran/can-parser/validator.lua:42
table["insert"](env[scope]["goto"], stm) -- ./candran/can-parser/validator.lua:43
return true -- ./candran/can-parser/validator.lua:44
end -- ./candran/can-parser/validator.lua:44
local function verify_pending_gotos(env) -- ./candran/can-parser/validator.lua:47
for s = env["maxscope"], 0, - 1 do -- ./candran/can-parser/validator.lua:48
for k, v in ipairs(env[s]["goto"]) do -- ./candran/can-parser/validator.lua:49
if not exist_label(env, s, v) then -- ./candran/can-parser/validator.lua:50
local msg = "no visible label '%s' for <goto>" -- ./candran/can-parser/validator.lua:51
msg = string["format"](msg, v[1]) -- ./candran/can-parser/validator.lua:52
return nil, syntaxerror(env["errorinfo"], v["pos"], msg) -- ./candran/can-parser/validator.lua:53
end -- ./candran/can-parser/validator.lua:53
end -- ./candran/can-parser/validator.lua:53
end -- ./candran/can-parser/validator.lua:53
return true -- ./candran/can-parser/validator.lua:57
end -- ./candran/can-parser/validator.lua:57
local function set_vararg(env, is_vararg) -- ./candran/can-parser/validator.lua:60
env["function"][env["fscope"]]["is_vararg"] = is_vararg -- ./candran/can-parser/validator.lua:61
end -- ./candran/can-parser/validator.lua:61
local traverse_stm, traverse_exp, traverse_var -- ./candran/can-parser/validator.lua:64
local traverse_block, traverse_explist, traverse_varlist, traverse_parlist -- ./candran/can-parser/validator.lua:65
traverse_parlist = function(env, parlist) -- ./candran/can-parser/validator.lua:67
local len = # parlist -- ./candran/can-parser/validator.lua:68
local is_vararg = false -- ./candran/can-parser/validator.lua:69
if len > 0 and parlist[len]["tag"] == "Dots" then -- ./candran/can-parser/validator.lua:70
is_vararg = true -- ./candran/can-parser/validator.lua:71
end -- ./candran/can-parser/validator.lua:71
set_vararg(env, is_vararg) -- ./candran/can-parser/validator.lua:73
return true -- ./candran/can-parser/validator.lua:74
end -- ./candran/can-parser/validator.lua:74
local function traverse_function(env, exp) -- ./candran/can-parser/validator.lua:77
new_function(env) -- ./candran/can-parser/validator.lua:78
new_scope(env) -- ./candran/can-parser/validator.lua:79
local status, msg = traverse_parlist(env, exp[1]) -- ./candran/can-parser/validator.lua:80
if not status then -- ./candran/can-parser/validator.lua:81
return status, msg -- ./candran/can-parser/validator.lua:81
end -- ./candran/can-parser/validator.lua:81
status, msg = traverse_block(env, exp[2]) -- ./candran/can-parser/validator.lua:82
if not status then -- ./candran/can-parser/validator.lua:83
return status, msg -- ./candran/can-parser/validator.lua:83
end -- ./candran/can-parser/validator.lua:83
end_scope(env) -- ./candran/can-parser/validator.lua:84
end_function(env) -- ./candran/can-parser/validator.lua:85
return true -- ./candran/can-parser/validator.lua:86
end -- ./candran/can-parser/validator.lua:86
local function traverse_tablecompr(env, exp) -- ./candran/can-parser/validator.lua:89
new_function(env) -- ./candran/can-parser/validator.lua:90
new_scope(env) -- ./candran/can-parser/validator.lua:91
local status, msg = traverse_block(env, exp[1]) -- ./candran/can-parser/validator.lua:92
if not status then -- ./candran/can-parser/validator.lua:93
return status, msg -- ./candran/can-parser/validator.lua:93
end -- ./candran/can-parser/validator.lua:93
end_scope(env) -- ./candran/can-parser/validator.lua:94
end_function(env) -- ./candran/can-parser/validator.lua:95
return true -- ./candran/can-parser/validator.lua:96
end -- ./candran/can-parser/validator.lua:96
local function traverse_statexpr(env, exp) -- ./candran/can-parser/validator.lua:99
new_function(env) -- ./candran/can-parser/validator.lua:100
new_scope(env) -- ./candran/can-parser/validator.lua:101
exp["tag"] = exp["tag"]:gsub("Expr$", "") -- ./candran/can-parser/validator.lua:102
local status, msg = traverse_stm(env, exp) -- ./candran/can-parser/validator.lua:103
exp["tag"] = exp["tag"] .. "Expr" -- ./candran/can-parser/validator.lua:104
if not status then -- ./candran/can-parser/validator.lua:105
return status, msg -- ./candran/can-parser/validator.lua:105
end -- ./candran/can-parser/validator.lua:105
end_scope(env) -- ./candran/can-parser/validator.lua:106
end_function(env) -- ./candran/can-parser/validator.lua:107
return true -- ./candran/can-parser/validator.lua:108
end -- ./candran/can-parser/validator.lua:108
local function traverse_op(env, exp) -- ./candran/can-parser/validator.lua:111
local status, msg = traverse_exp(env, exp[2]) -- ./candran/can-parser/validator.lua:112
if not status then -- ./candran/can-parser/validator.lua:113
return status, msg -- ./candran/can-parser/validator.lua:113
end -- ./candran/can-parser/validator.lua:113
if exp[3] then -- ./candran/can-parser/validator.lua:114
status, msg = traverse_exp(env, exp[3]) -- ./candran/can-parser/validator.lua:115
if not status then -- ./candran/can-parser/validator.lua:116
return status, msg -- ./candran/can-parser/validator.lua:116
end -- ./candran/can-parser/validator.lua:116
end -- ./candran/can-parser/validator.lua:116
return true -- ./candran/can-parser/validator.lua:118
end -- ./candran/can-parser/validator.lua:118
local function traverse_paren(env, exp) -- ./candran/can-parser/validator.lua:121
local status, msg = traverse_exp(env, exp[1]) -- ./candran/can-parser/validator.lua:122
if not status then -- ./candran/can-parser/validator.lua:123
return status, msg -- ./candran/can-parser/validator.lua:123
end -- ./candran/can-parser/validator.lua:123
return true -- ./candran/can-parser/validator.lua:124
end -- ./candran/can-parser/validator.lua:124
local function traverse_table(env, fieldlist) -- ./candran/can-parser/validator.lua:127
for k, v in ipairs(fieldlist) do -- ./candran/can-parser/validator.lua:128
local tag = v["tag"] -- ./candran/can-parser/validator.lua:129
if tag == "Pair" then -- ./candran/can-parser/validator.lua:130
local status, msg = traverse_exp(env, v[1]) -- ./candran/can-parser/validator.lua:131
if not status then -- ./candran/can-parser/validator.lua:132
return status, msg -- ./candran/can-parser/validator.lua:132
end -- ./candran/can-parser/validator.lua:132
status, msg = traverse_exp(env, v[2]) -- ./candran/can-parser/validator.lua:133
if not status then -- ./candran/can-parser/validator.lua:134
return status, msg -- ./candran/can-parser/validator.lua:134
end -- ./candran/can-parser/validator.lua:134
else -- ./candran/can-parser/validator.lua:134
local status, msg = traverse_exp(env, v) -- ./candran/can-parser/validator.lua:136
if not status then -- ./candran/can-parser/validator.lua:137
return status, msg -- ./candran/can-parser/validator.lua:137
end -- ./candran/can-parser/validator.lua:137
end -- ./candran/can-parser/validator.lua:137
end -- ./candran/can-parser/validator.lua:137
return true -- ./candran/can-parser/validator.lua:140
end -- ./candran/can-parser/validator.lua:140
local function traverse_vararg(env, exp) -- ./candran/can-parser/validator.lua:143
if not env["function"][env["fscope"]]["is_vararg"] then -- ./candran/can-parser/validator.lua:144
local msg = "cannot use '...' outside a vararg function" -- ./candran/can-parser/validator.lua:145
return nil, syntaxerror(env["errorinfo"], exp["pos"], msg) -- ./candran/can-parser/validator.lua:146
end -- ./candran/can-parser/validator.lua:146
return true -- ./candran/can-parser/validator.lua:148
end -- ./candran/can-parser/validator.lua:148
local function traverse_call(env, call) -- ./candran/can-parser/validator.lua:151
local status, msg = traverse_exp(env, call[1]) -- ./candran/can-parser/validator.lua:152
if not status then -- ./candran/can-parser/validator.lua:153
return status, msg -- ./candran/can-parser/validator.lua:153
end -- ./candran/can-parser/validator.lua:153
for i = 2, # call do -- ./candran/can-parser/validator.lua:154
status, msg = traverse_exp(env, call[i]) -- ./candran/can-parser/validator.lua:155
if not status then -- ./candran/can-parser/validator.lua:156
return status, msg -- ./candran/can-parser/validator.lua:156
end -- ./candran/can-parser/validator.lua:156
end -- ./candran/can-parser/validator.lua:156
return true -- ./candran/can-parser/validator.lua:158
end -- ./candran/can-parser/validator.lua:158
local function traverse_assignment(env, stm) -- ./candran/can-parser/validator.lua:161
local status, msg = traverse_varlist(env, stm[1]) -- ./candran/can-parser/validator.lua:162
if not status then -- ./candran/can-parser/validator.lua:163
return status, msg -- ./candran/can-parser/validator.lua:163
end -- ./candran/can-parser/validator.lua:163
status, msg = traverse_explist(env, stm[# stm]) -- ./candran/can-parser/validator.lua:164
if not status then -- ./candran/can-parser/validator.lua:165
return status, msg -- ./candran/can-parser/validator.lua:165
end -- ./candran/can-parser/validator.lua:165
return true -- ./candran/can-parser/validator.lua:166
end -- ./candran/can-parser/validator.lua:166
local function traverse_break(env, stm) -- ./candran/can-parser/validator.lua:169
if not insideloop(env) then -- ./candran/can-parser/validator.lua:170
local msg = "<break> not inside a loop" -- ./candran/can-parser/validator.lua:171
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg) -- ./candran/can-parser/validator.lua:172
end -- ./candran/can-parser/validator.lua:172
return true -- ./candran/can-parser/validator.lua:174
end -- ./candran/can-parser/validator.lua:174
local function traverse_continue(env, stm) -- ./candran/can-parser/validator.lua:177
if not insideloop(env) then -- ./candran/can-parser/validator.lua:178
local msg = "<continue> not inside a loop" -- ./candran/can-parser/validator.lua:179
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg) -- ./candran/can-parser/validator.lua:180
end -- ./candran/can-parser/validator.lua:180
return true -- ./candran/can-parser/validator.lua:182
end -- ./candran/can-parser/validator.lua:182
local function traverse_push(env, stm) -- ./candran/can-parser/validator.lua:185
local status, msg = traverse_explist(env, stm) -- ./candran/can-parser/validator.lua:186
if not status then -- ./candran/can-parser/validator.lua:187
return status, msg -- ./candran/can-parser/validator.lua:187
end -- ./candran/can-parser/validator.lua:187
return true -- ./candran/can-parser/validator.lua:188
end -- ./candran/can-parser/validator.lua:188
local function traverse_forin(env, stm) -- ./candran/can-parser/validator.lua:191
begin_loop(env) -- ./candran/can-parser/validator.lua:192
new_scope(env) -- ./candran/can-parser/validator.lua:193
local status, msg = traverse_explist(env, stm[2]) -- ./candran/can-parser/validator.lua:194
if not status then -- ./candran/can-parser/validator.lua:195
return status, msg -- ./candran/can-parser/validator.lua:195
end -- ./candran/can-parser/validator.lua:195
status, msg = traverse_block(env, stm[3]) -- ./candran/can-parser/validator.lua:196
if not status then -- ./candran/can-parser/validator.lua:197
return status, msg -- ./candran/can-parser/validator.lua:197
end -- ./candran/can-parser/validator.lua:197
end_scope(env) -- ./candran/can-parser/validator.lua:198
end_loop(env) -- ./candran/can-parser/validator.lua:199
return true -- ./candran/can-parser/validator.lua:200
end -- ./candran/can-parser/validator.lua:200
local function traverse_fornum(env, stm) -- ./candran/can-parser/validator.lua:203
local status, msg -- ./candran/can-parser/validator.lua:204
begin_loop(env) -- ./candran/can-parser/validator.lua:205
new_scope(env) -- ./candran/can-parser/validator.lua:206
status, msg = traverse_exp(env, stm[2]) -- ./candran/can-parser/validator.lua:207
if not status then -- ./candran/can-parser/validator.lua:208
return status, msg -- ./candran/can-parser/validator.lua:208
end -- ./candran/can-parser/validator.lua:208
status, msg = traverse_exp(env, stm[3]) -- ./candran/can-parser/validator.lua:209
if not status then -- ./candran/can-parser/validator.lua:210
return status, msg -- ./candran/can-parser/validator.lua:210
end -- ./candran/can-parser/validator.lua:210
if stm[5] then -- ./candran/can-parser/validator.lua:211
status, msg = traverse_exp(env, stm[4]) -- ./candran/can-parser/validator.lua:212
if not status then -- ./candran/can-parser/validator.lua:213
return status, msg -- ./candran/can-parser/validator.lua:213
end -- ./candran/can-parser/validator.lua:213
status, msg = traverse_block(env, stm[5]) -- ./candran/can-parser/validator.lua:214
if not status then -- ./candran/can-parser/validator.lua:215
return status, msg -- ./candran/can-parser/validator.lua:215
end -- ./candran/can-parser/validator.lua:215
else -- ./candran/can-parser/validator.lua:215
status, msg = traverse_block(env, stm[4]) -- ./candran/can-parser/validator.lua:217
if not status then -- ./candran/can-parser/validator.lua:218
return status, msg -- ./candran/can-parser/validator.lua:218
end -- ./candran/can-parser/validator.lua:218
end -- ./candran/can-parser/validator.lua:218
end_scope(env) -- ./candran/can-parser/validator.lua:220
end_loop(env) -- ./candran/can-parser/validator.lua:221
return true -- ./candran/can-parser/validator.lua:222
end -- ./candran/can-parser/validator.lua:222
local function traverse_goto(env, stm) -- ./candran/can-parser/validator.lua:225
local status, msg = set_pending_goto(env, stm) -- ./candran/can-parser/validator.lua:226
if not status then -- ./candran/can-parser/validator.lua:227
return status, msg -- ./candran/can-parser/validator.lua:227
end -- ./candran/can-parser/validator.lua:227
return true -- ./candran/can-parser/validator.lua:228
end -- ./candran/can-parser/validator.lua:228
local function traverse_let(env, stm) -- ./candran/can-parser/validator.lua:231
local status, msg = traverse_explist(env, stm[2]) -- ./candran/can-parser/validator.lua:232
if not status then -- ./candran/can-parser/validator.lua:233
return status, msg -- ./candran/can-parser/validator.lua:233
end -- ./candran/can-parser/validator.lua:233
return true -- ./candran/can-parser/validator.lua:234
end -- ./candran/can-parser/validator.lua:234
local function traverse_letrec(env, stm) -- ./candran/can-parser/validator.lua:237
local status, msg = traverse_exp(env, stm[2][1]) -- ./candran/can-parser/validator.lua:238
if not status then -- ./candran/can-parser/validator.lua:239
return status, msg -- ./candran/can-parser/validator.lua:239
end -- ./candran/can-parser/validator.lua:239
return true -- ./candran/can-parser/validator.lua:240
end -- ./candran/can-parser/validator.lua:240
local function traverse_if(env, stm) -- ./candran/can-parser/validator.lua:243
local len = # stm -- ./candran/can-parser/validator.lua:244
if len % 2 == 0 then -- ./candran/can-parser/validator.lua:245
for i = 1, len, 2 do -- ./candran/can-parser/validator.lua:246
local status, msg = traverse_exp(env, stm[i]) -- ./candran/can-parser/validator.lua:247
if not status then -- ./candran/can-parser/validator.lua:248
return status, msg -- ./candran/can-parser/validator.lua:248
end -- ./candran/can-parser/validator.lua:248
status, msg = traverse_block(env, stm[i + 1]) -- ./candran/can-parser/validator.lua:249
if not status then -- ./candran/can-parser/validator.lua:250
return status, msg -- ./candran/can-parser/validator.lua:250
end -- ./candran/can-parser/validator.lua:250
end -- ./candran/can-parser/validator.lua:250
else -- ./candran/can-parser/validator.lua:250
for i = 1, len - 1, 2 do -- ./candran/can-parser/validator.lua:253
local status, msg = traverse_exp(env, stm[i]) -- ./candran/can-parser/validator.lua:254
if not status then -- ./candran/can-parser/validator.lua:255
return status, msg -- ./candran/can-parser/validator.lua:255
end -- ./candran/can-parser/validator.lua:255
status, msg = traverse_block(env, stm[i + 1]) -- ./candran/can-parser/validator.lua:256
if not status then -- ./candran/can-parser/validator.lua:257
return status, msg -- ./candran/can-parser/validator.lua:257
end -- ./candran/can-parser/validator.lua:257
end -- ./candran/can-parser/validator.lua:257
local status, msg = traverse_block(env, stm[len]) -- ./candran/can-parser/validator.lua:259
if not status then -- ./candran/can-parser/validator.lua:260
return status, msg -- ./candran/can-parser/validator.lua:260
end -- ./candran/can-parser/validator.lua:260
end -- ./candran/can-parser/validator.lua:260
return true -- ./candran/can-parser/validator.lua:262
end -- ./candran/can-parser/validator.lua:262
local function traverse_label(env, stm) -- ./candran/can-parser/validator.lua:265
local status, msg = set_label(env, stm[1], stm["pos"]) -- ./candran/can-parser/validator.lua:266
if not status then -- ./candran/can-parser/validator.lua:267
return status, msg -- ./candran/can-parser/validator.lua:267
end -- ./candran/can-parser/validator.lua:267
return true -- ./candran/can-parser/validator.lua:268
end -- ./candran/can-parser/validator.lua:268
local function traverse_repeat(env, stm) -- ./candran/can-parser/validator.lua:271
begin_loop(env) -- ./candran/can-parser/validator.lua:272
local status, msg = traverse_block(env, stm[1]) -- ./candran/can-parser/validator.lua:273
if not status then -- ./candran/can-parser/validator.lua:274
return status, msg -- ./candran/can-parser/validator.lua:274
end -- ./candran/can-parser/validator.lua:274
status, msg = traverse_exp(env, stm[2]) -- ./candran/can-parser/validator.lua:275
if not status then -- ./candran/can-parser/validator.lua:276
return status, msg -- ./candran/can-parser/validator.lua:276
end -- ./candran/can-parser/validator.lua:276
end_loop(env) -- ./candran/can-parser/validator.lua:277
return true -- ./candran/can-parser/validator.lua:278
end -- ./candran/can-parser/validator.lua:278
local function traverse_return(env, stm) -- ./candran/can-parser/validator.lua:281
local status, msg = traverse_explist(env, stm) -- ./candran/can-parser/validator.lua:282
if not status then -- ./candran/can-parser/validator.lua:283
return status, msg -- ./candran/can-parser/validator.lua:283
end -- ./candran/can-parser/validator.lua:283
return true -- ./candran/can-parser/validator.lua:284
end -- ./candran/can-parser/validator.lua:284
local function traverse_while(env, stm) -- ./candran/can-parser/validator.lua:287
begin_loop(env) -- ./candran/can-parser/validator.lua:288
local status, msg = traverse_exp(env, stm[1]) -- ./candran/can-parser/validator.lua:289
if not status then -- ./candran/can-parser/validator.lua:290
return status, msg -- ./candran/can-parser/validator.lua:290
end -- ./candran/can-parser/validator.lua:290
status, msg = traverse_block(env, stm[2]) -- ./candran/can-parser/validator.lua:291
if not status then -- ./candran/can-parser/validator.lua:292
return status, msg -- ./candran/can-parser/validator.lua:292
end -- ./candran/can-parser/validator.lua:292
end_loop(env) -- ./candran/can-parser/validator.lua:293
return true -- ./candran/can-parser/validator.lua:294
end -- ./candran/can-parser/validator.lua:294
traverse_var = function(env, var) -- ./candran/can-parser/validator.lua:297
local tag = var["tag"] -- ./candran/can-parser/validator.lua:298
if tag == "Id" then -- ./candran/can-parser/validator.lua:299
return true -- ./candran/can-parser/validator.lua:300
elseif tag == "Index" then -- ./candran/can-parser/validator.lua:301
local status, msg = traverse_exp(env, var[1]) -- ./candran/can-parser/validator.lua:302
if not status then -- ./candran/can-parser/validator.lua:303
return status, msg -- ./candran/can-parser/validator.lua:303
end -- ./candran/can-parser/validator.lua:303
status, msg = traverse_exp(env, var[2]) -- ./candran/can-parser/validator.lua:304
if not status then -- ./candran/can-parser/validator.lua:305
return status, msg -- ./candran/can-parser/validator.lua:305
end -- ./candran/can-parser/validator.lua:305
return true -- ./candran/can-parser/validator.lua:306
elseif tag == "DestructuringId" then -- ./candran/can-parser/validator.lua:307
return traverse_table(env, var) -- ./candran/can-parser/validator.lua:308
else -- ./candran/can-parser/validator.lua:308
error("expecting a variable, but got a " .. tag) -- ./candran/can-parser/validator.lua:310
end -- ./candran/can-parser/validator.lua:310
end -- ./candran/can-parser/validator.lua:310
traverse_varlist = function(env, varlist) -- ./candran/can-parser/validator.lua:314
for k, v in ipairs(varlist) do -- ./candran/can-parser/validator.lua:315
local status, msg = traverse_var(env, v) -- ./candran/can-parser/validator.lua:316
if not status then -- ./candran/can-parser/validator.lua:317
return status, msg -- ./candran/can-parser/validator.lua:317
end -- ./candran/can-parser/validator.lua:317
end -- ./candran/can-parser/validator.lua:317
return true -- ./candran/can-parser/validator.lua:319
end -- ./candran/can-parser/validator.lua:319
local function traverse_methodstub(env, var) -- ./candran/can-parser/validator.lua:322
local status, msg = traverse_exp(env, var[1]) -- ./candran/can-parser/validator.lua:323
if not status then -- ./candran/can-parser/validator.lua:324
return status, msg -- ./candran/can-parser/validator.lua:324
end -- ./candran/can-parser/validator.lua:324
status, msg = traverse_exp(env, var[2]) -- ./candran/can-parser/validator.lua:325
if not status then -- ./candran/can-parser/validator.lua:326
return status, msg -- ./candran/can-parser/validator.lua:326
end -- ./candran/can-parser/validator.lua:326
return true -- ./candran/can-parser/validator.lua:327
end -- ./candran/can-parser/validator.lua:327
local function traverse_safeindex(env, var) -- ./candran/can-parser/validator.lua:330
local status, msg = traverse_exp(env, var[1]) -- ./candran/can-parser/validator.lua:331
if not status then -- ./candran/can-parser/validator.lua:332
return status, msg -- ./candran/can-parser/validator.lua:332
end -- ./candran/can-parser/validator.lua:332
status, msg = traverse_exp(env, var[2]) -- ./candran/can-parser/validator.lua:333
if not status then -- ./candran/can-parser/validator.lua:334
return status, msg -- ./candran/can-parser/validator.lua:334
end -- ./candran/can-parser/validator.lua:334
return true -- ./candran/can-parser/validator.lua:335
end -- ./candran/can-parser/validator.lua:335
traverse_exp = function(env, exp) -- ./candran/can-parser/validator.lua:338
local tag = exp["tag"] -- ./candran/can-parser/validator.lua:339
if tag == "Nil" or tag == "Boolean" or tag == "Number" or tag == "String" then -- ./candran/can-parser/validator.lua:343
return true -- ./candran/can-parser/validator.lua:344
elseif tag == "Dots" then -- ./candran/can-parser/validator.lua:345
return traverse_vararg(env, exp) -- ./candran/can-parser/validator.lua:346
elseif tag == "Function" then -- ./candran/can-parser/validator.lua:347
return traverse_function(env, exp) -- ./candran/can-parser/validator.lua:348
elseif tag == "Table" then -- ./candran/can-parser/validator.lua:349
return traverse_table(env, exp) -- ./candran/can-parser/validator.lua:350
elseif tag == "Op" then -- ./candran/can-parser/validator.lua:351
return traverse_op(env, exp) -- ./candran/can-parser/validator.lua:352
elseif tag == "Paren" then -- ./candran/can-parser/validator.lua:353
return traverse_paren(env, exp) -- ./candran/can-parser/validator.lua:354
elseif tag == "Call" or tag == "SafeCall" then -- ./candran/can-parser/validator.lua:355
return traverse_call(env, exp) -- ./candran/can-parser/validator.lua:356
elseif tag == "Id" or tag == "Index" then -- ./candran/can-parser/validator.lua:358
return traverse_var(env, exp) -- ./candran/can-parser/validator.lua:359
elseif tag == "SafeIndex" then -- ./candran/can-parser/validator.lua:360
return traverse_safeindex(env, exp) -- ./candran/can-parser/validator.lua:361
elseif tag == "TableCompr" then -- ./candran/can-parser/validator.lua:362
return traverse_tablecompr(env, exp) -- ./candran/can-parser/validator.lua:363
elseif tag == "MethodStub" or tag == "SafeMethodStub" then -- ./candran/can-parser/validator.lua:364
return traverse_methodstub(env, exp) -- ./candran/can-parser/validator.lua:365
elseif tag:match("Expr$") then -- ./candran/can-parser/validator.lua:366
return traverse_statexpr(env, exp) -- ./candran/can-parser/validator.lua:367
else -- ./candran/can-parser/validator.lua:367
error("expecting an expression, but got a " .. tag) -- ./candran/can-parser/validator.lua:369
end -- ./candran/can-parser/validator.lua:369
end -- ./candran/can-parser/validator.lua:369
traverse_explist = function(env, explist) -- ./candran/can-parser/validator.lua:373
for k, v in ipairs(explist) do -- ./candran/can-parser/validator.lua:374
local status, msg = traverse_exp(env, v) -- ./candran/can-parser/validator.lua:375
if not status then -- ./candran/can-parser/validator.lua:376
return status, msg -- ./candran/can-parser/validator.lua:376
end -- ./candran/can-parser/validator.lua:376
end -- ./candran/can-parser/validator.lua:376
return true -- ./candran/can-parser/validator.lua:378
end -- ./candran/can-parser/validator.lua:378
traverse_stm = function(env, stm) -- ./candran/can-parser/validator.lua:381
local tag = stm["tag"] -- ./candran/can-parser/validator.lua:382
if tag == "Do" then -- ./candran/can-parser/validator.lua:383
return traverse_block(env, stm) -- ./candran/can-parser/validator.lua:384
elseif tag == "Set" then -- ./candran/can-parser/validator.lua:385
return traverse_assignment(env, stm) -- ./candran/can-parser/validator.lua:386
elseif tag == "While" then -- ./candran/can-parser/validator.lua:387
return traverse_while(env, stm) -- ./candran/can-parser/validator.lua:388
elseif tag == "Repeat" then -- ./candran/can-parser/validator.lua:389
return traverse_repeat(env, stm) -- ./candran/can-parser/validator.lua:390
elseif tag == "If" then -- ./candran/can-parser/validator.lua:391
return traverse_if(env, stm) -- ./candran/can-parser/validator.lua:392
elseif tag == "Fornum" then -- ./candran/can-parser/validator.lua:393
return traverse_fornum(env, stm) -- ./candran/can-parser/validator.lua:394
elseif tag == "Forin" then -- ./candran/can-parser/validator.lua:395
return traverse_forin(env, stm) -- ./candran/can-parser/validator.lua:396
elseif tag == "Local" or tag == "Let" then -- ./candran/can-parser/validator.lua:398
return traverse_let(env, stm) -- ./candran/can-parser/validator.lua:399
elseif tag == "Localrec" then -- ./candran/can-parser/validator.lua:400
return traverse_letrec(env, stm) -- ./candran/can-parser/validator.lua:401
elseif tag == "Goto" then -- ./candran/can-parser/validator.lua:402
return traverse_goto(env, stm) -- ./candran/can-parser/validator.lua:403
elseif tag == "Label" then -- ./candran/can-parser/validator.lua:404
return traverse_label(env, stm) -- ./candran/can-parser/validator.lua:405
elseif tag == "Return" then -- ./candran/can-parser/validator.lua:406
return traverse_return(env, stm) -- ./candran/can-parser/validator.lua:407
elseif tag == "Break" then -- ./candran/can-parser/validator.lua:408
return traverse_break(env, stm) -- ./candran/can-parser/validator.lua:409
elseif tag == "Call" then -- ./candran/can-parser/validator.lua:410
return traverse_call(env, stm) -- ./candran/can-parser/validator.lua:411
elseif tag == "Continue" then -- ./candran/can-parser/validator.lua:412
return traverse_continue(env, stm) -- ./candran/can-parser/validator.lua:413
elseif tag == "Push" then -- ./candran/can-parser/validator.lua:414
return traverse_push(env, stm) -- ./candran/can-parser/validator.lua:415
else -- ./candran/can-parser/validator.lua:415
error("expecting a statement, but got a " .. tag) -- ./candran/can-parser/validator.lua:417
end -- ./candran/can-parser/validator.lua:417
end -- ./candran/can-parser/validator.lua:417
traverse_block = function(env, block) -- ./candran/can-parser/validator.lua:421
local l = {} -- ./candran/can-parser/validator.lua:422
new_scope(env) -- ./candran/can-parser/validator.lua:423
for k, v in ipairs(block) do -- ./candran/can-parser/validator.lua:424
local status, msg = traverse_stm(env, v) -- ./candran/can-parser/validator.lua:425
if not status then -- ./candran/can-parser/validator.lua:426
return status, msg -- ./candran/can-parser/validator.lua:426
end -- ./candran/can-parser/validator.lua:426
end -- ./candran/can-parser/validator.lua:426
end_scope(env) -- ./candran/can-parser/validator.lua:428
return true -- ./candran/can-parser/validator.lua:429
end -- ./candran/can-parser/validator.lua:429
local function traverse(ast, errorinfo) -- ./candran/can-parser/validator.lua:433
assert(type(ast) == "table") -- ./candran/can-parser/validator.lua:434
assert(type(errorinfo) == "table") -- ./candran/can-parser/validator.lua:435
local env = { -- ./candran/can-parser/validator.lua:436
["errorinfo"] = errorinfo, -- ./candran/can-parser/validator.lua:436
["function"] = {} -- ./candran/can-parser/validator.lua:436
} -- ./candran/can-parser/validator.lua:436
new_function(env) -- ./candran/can-parser/validator.lua:437
set_vararg(env, true) -- ./candran/can-parser/validator.lua:438
local status, msg = traverse_block(env, ast) -- ./candran/can-parser/validator.lua:439
if not status then -- ./candran/can-parser/validator.lua:440
return status, msg -- ./candran/can-parser/validator.lua:440
end -- ./candran/can-parser/validator.lua:440
end_function(env) -- ./candran/can-parser/validator.lua:441
status, msg = verify_pending_gotos(env) -- ./candran/can-parser/validator.lua:442
if not status then -- ./candran/can-parser/validator.lua:443
return status, msg -- ./candran/can-parser/validator.lua:443
end -- ./candran/can-parser/validator.lua:443
return ast -- ./candran/can-parser/validator.lua:444
end -- ./candran/can-parser/validator.lua:444
return { -- ./candran/can-parser/validator.lua:447
["validate"] = traverse, -- ./candran/can-parser/validator.lua:447
["syntaxerror"] = syntaxerror -- ./candran/can-parser/validator.lua:447
} -- ./candran/can-parser/validator.lua:447
end -- ./candran/can-parser/validator.lua:447
local validator = _() or validator -- ./candran/can-parser/validator.lua:451
package["loaded"]["candran.can-parser.validator"] = validator or true -- ./candran/can-parser/validator.lua:452
local function _() -- ./candran/can-parser/validator.lua:455
local pp = {} -- ./candran/can-parser/pp.lua:4
local block2str, stm2str, exp2str, var2str -- ./candran/can-parser/pp.lua:6
local explist2str, varlist2str, parlist2str, fieldlist2str -- ./candran/can-parser/pp.lua:7
local function iscntrl(x) -- ./candran/can-parser/pp.lua:9
if (x >= 0 and x <= 31) or (x == 127) then -- ./candran/can-parser/pp.lua:10
return true -- ./candran/can-parser/pp.lua:10
end -- ./candran/can-parser/pp.lua:10
return false -- ./candran/can-parser/pp.lua:11
end -- ./candran/can-parser/pp.lua:11
local function isprint(x) -- ./candran/can-parser/pp.lua:14
return not iscntrl(x) -- ./candran/can-parser/pp.lua:15
end -- ./candran/can-parser/pp.lua:15
local function fixed_string(str) -- ./candran/can-parser/pp.lua:18
local new_str = "" -- ./candran/can-parser/pp.lua:19
for i = 1, string["len"](str) do -- ./candran/can-parser/pp.lua:20
char = string["byte"](str, i) -- ./candran/can-parser/pp.lua:21
if char == 34 then -- ./candran/can-parser/pp.lua:22
new_str = new_str .. string["format"]("\\\"") -- ./candran/can-parser/pp.lua:22
elseif char == 92 then -- ./candran/can-parser/pp.lua:23
new_str = new_str .. string["format"]("\\\\") -- ./candran/can-parser/pp.lua:23
elseif char == 7 then -- ./candran/can-parser/pp.lua:24
new_str = new_str .. string["format"]("\\a") -- ./candran/can-parser/pp.lua:24
elseif char == 8 then -- ./candran/can-parser/pp.lua:25
new_str = new_str .. string["format"]("\\b") -- ./candran/can-parser/pp.lua:25
elseif char == 12 then -- ./candran/can-parser/pp.lua:26
new_str = new_str .. string["format"]("\\f") -- ./candran/can-parser/pp.lua:26
elseif char == 10 then -- ./candran/can-parser/pp.lua:27
new_str = new_str .. string["format"]("\\n") -- ./candran/can-parser/pp.lua:27
elseif char == 13 then -- ./candran/can-parser/pp.lua:28
new_str = new_str .. string["format"]("\\r") -- ./candran/can-parser/pp.lua:28
elseif char == 9 then -- ./candran/can-parser/pp.lua:29
new_str = new_str .. string["format"]("\\t") -- ./candran/can-parser/pp.lua:29
elseif char == 11 then -- ./candran/can-parser/pp.lua:30
new_str = new_str .. string["format"]("\\v") -- ./candran/can-parser/pp.lua:30
else -- ./candran/can-parser/pp.lua:30
if isprint(char) then -- ./candran/can-parser/pp.lua:32
new_str = new_str .. string["format"]("%c", char) -- ./candran/can-parser/pp.lua:33
else -- ./candran/can-parser/pp.lua:33
new_str = new_str .. string["format"]("\\%03d", char) -- ./candran/can-parser/pp.lua:35
end -- ./candran/can-parser/pp.lua:35
end -- ./candran/can-parser/pp.lua:35
end -- ./candran/can-parser/pp.lua:35
return new_str -- ./candran/can-parser/pp.lua:39
end -- ./candran/can-parser/pp.lua:39
local function name2str(name) -- ./candran/can-parser/pp.lua:42
return string["format"]("\"%s\"", name) -- ./candran/can-parser/pp.lua:43
end -- ./candran/can-parser/pp.lua:43
local function boolean2str(b) -- ./candran/can-parser/pp.lua:46
return string["format"]("\"%s\"", tostring(b)) -- ./candran/can-parser/pp.lua:47
end -- ./candran/can-parser/pp.lua:47
local function number2str(n) -- ./candran/can-parser/pp.lua:50
return string["format"]("\"%s\"", tostring(n)) -- ./candran/can-parser/pp.lua:51
end -- ./candran/can-parser/pp.lua:51
local function string2str(s) -- ./candran/can-parser/pp.lua:54
return string["format"]("\"%s\"", fixed_string(s)) -- ./candran/can-parser/pp.lua:55
end -- ./candran/can-parser/pp.lua:55
var2str = function(var) -- ./candran/can-parser/pp.lua:58
local tag = var["tag"] -- ./candran/can-parser/pp.lua:59
local str = "`" .. tag -- ./candran/can-parser/pp.lua:60
if tag == "Id" then -- ./candran/can-parser/pp.lua:61
str = str .. " " .. name2str(var[1]) -- ./candran/can-parser/pp.lua:62
elseif tag == "Index" then -- ./candran/can-parser/pp.lua:63
str = str .. "{ " -- ./candran/can-parser/pp.lua:64
str = str .. exp2str(var[1]) .. ", " -- ./candran/can-parser/pp.lua:65
str = str .. exp2str(var[2]) -- ./candran/can-parser/pp.lua:66
str = str .. " }" -- ./candran/can-parser/pp.lua:67
else -- ./candran/can-parser/pp.lua:67
error("expecting a variable, but got a " .. tag) -- ./candran/can-parser/pp.lua:69
end -- ./candran/can-parser/pp.lua:69
return str -- ./candran/can-parser/pp.lua:71
end -- ./candran/can-parser/pp.lua:71
varlist2str = function(varlist) -- ./candran/can-parser/pp.lua:74
local l = {} -- ./candran/can-parser/pp.lua:75
for k, v in ipairs(varlist) do -- ./candran/can-parser/pp.lua:76
l[k] = var2str(v) -- ./candran/can-parser/pp.lua:77
end -- ./candran/can-parser/pp.lua:77
return "{ " .. table["concat"](l, ", ") .. " }" -- ./candran/can-parser/pp.lua:79
end -- ./candran/can-parser/pp.lua:79
parlist2str = function(parlist) -- ./candran/can-parser/pp.lua:82
local l = {} -- ./candran/can-parser/pp.lua:83
local len = # parlist -- ./candran/can-parser/pp.lua:84
local is_vararg = false -- ./candran/can-parser/pp.lua:85
if len > 0 and parlist[len]["tag"] == "Dots" then -- ./candran/can-parser/pp.lua:86
is_vararg = true -- ./candran/can-parser/pp.lua:87
len = len - 1 -- ./candran/can-parser/pp.lua:88
end -- ./candran/can-parser/pp.lua:88
local i = 1 -- ./candran/can-parser/pp.lua:90
while i <= len do -- ./candran/can-parser/pp.lua:91
l[i] = var2str(parlist[i]) -- ./candran/can-parser/pp.lua:92
i = i + 1 -- ./candran/can-parser/pp.lua:93
end -- ./candran/can-parser/pp.lua:93
if is_vararg then -- ./candran/can-parser/pp.lua:95
l[i] = "`" .. parlist[i]["tag"] -- ./candran/can-parser/pp.lua:96
end -- ./candran/can-parser/pp.lua:96
return "{ " .. table["concat"](l, ", ") .. " }" -- ./candran/can-parser/pp.lua:98
end -- ./candran/can-parser/pp.lua:98
fieldlist2str = function(fieldlist) -- ./candran/can-parser/pp.lua:101
local l = {} -- ./candran/can-parser/pp.lua:102
for k, v in ipairs(fieldlist) do -- ./candran/can-parser/pp.lua:103
local tag = v["tag"] -- ./candran/can-parser/pp.lua:104
if tag == "Pair" then -- ./candran/can-parser/pp.lua:105
l[k] = "`" .. tag .. "{ " -- ./candran/can-parser/pp.lua:106
l[k] = l[k] .. exp2str(v[1]) .. ", " .. exp2str(v[2]) -- ./candran/can-parser/pp.lua:107
l[k] = l[k] .. " }" -- ./candran/can-parser/pp.lua:108
else -- ./candran/can-parser/pp.lua:108
l[k] = exp2str(v) -- ./candran/can-parser/pp.lua:110
end -- ./candran/can-parser/pp.lua:110
end -- ./candran/can-parser/pp.lua:110
if # l > 0 then -- ./candran/can-parser/pp.lua:113
return "{ " .. table["concat"](l, ", ") .. " }" -- ./candran/can-parser/pp.lua:114
else -- ./candran/can-parser/pp.lua:114
return "" -- ./candran/can-parser/pp.lua:116
end -- ./candran/can-parser/pp.lua:116
end -- ./candran/can-parser/pp.lua:116
exp2str = function(exp) -- ./candran/can-parser/pp.lua:120
local tag = exp["tag"] -- ./candran/can-parser/pp.lua:121
local str = "`" .. tag -- ./candran/can-parser/pp.lua:122
if tag == "Nil" or tag == "Dots" then -- ./candran/can-parser/pp.lua:124
 -- ./candran/can-parser/pp.lua:125
elseif tag == "Boolean" then -- ./candran/can-parser/pp.lua:125
str = str .. " " .. boolean2str(exp[1]) -- ./candran/can-parser/pp.lua:126
elseif tag == "Number" then -- ./candran/can-parser/pp.lua:127
str = str .. " " .. number2str(exp[1]) -- ./candran/can-parser/pp.lua:128
elseif tag == "String" then -- ./candran/can-parser/pp.lua:129
str = str .. " " .. string2str(exp[1]) -- ./candran/can-parser/pp.lua:130
elseif tag == "Function" then -- ./candran/can-parser/pp.lua:131
str = str .. "{ " -- ./candran/can-parser/pp.lua:132
str = str .. parlist2str(exp[1]) .. ", " -- ./candran/can-parser/pp.lua:133
str = str .. block2str(exp[2]) -- ./candran/can-parser/pp.lua:134
str = str .. " }" -- ./candran/can-parser/pp.lua:135
elseif tag == "Table" then -- ./candran/can-parser/pp.lua:136
str = str .. fieldlist2str(exp) -- ./candran/can-parser/pp.lua:137
elseif tag == "Op" then -- ./candran/can-parser/pp.lua:138
str = str .. "{ " -- ./candran/can-parser/pp.lua:139
str = str .. name2str(exp[1]) .. ", " -- ./candran/can-parser/pp.lua:140
str = str .. exp2str(exp[2]) -- ./candran/can-parser/pp.lua:141
if exp[3] then -- ./candran/can-parser/pp.lua:142
str = str .. ", " .. exp2str(exp[3]) -- ./candran/can-parser/pp.lua:143
end -- ./candran/can-parser/pp.lua:143
str = str .. " }" -- ./candran/can-parser/pp.lua:145
elseif tag == "Paren" then -- ./candran/can-parser/pp.lua:146
str = str .. "{ " .. exp2str(exp[1]) .. " }" -- ./candran/can-parser/pp.lua:147
elseif tag == "Call" then -- ./candran/can-parser/pp.lua:148
str = str .. "{ " -- ./candran/can-parser/pp.lua:149
str = str .. exp2str(exp[1]) -- ./candran/can-parser/pp.lua:150
if exp[2] then -- ./candran/can-parser/pp.lua:151
for i = 2, # exp do -- ./candran/can-parser/pp.lua:152
str = str .. ", " .. exp2str(exp[i]) -- ./candran/can-parser/pp.lua:153
end -- ./candran/can-parser/pp.lua:153
end -- ./candran/can-parser/pp.lua:153
str = str .. " }" -- ./candran/can-parser/pp.lua:156
elseif tag == "Invoke" then -- ./candran/can-parser/pp.lua:157
str = str .. "{ " -- ./candran/can-parser/pp.lua:158
str = str .. exp2str(exp[1]) .. ", " -- ./candran/can-parser/pp.lua:159
str = str .. exp2str(exp[2]) -- ./candran/can-parser/pp.lua:160
if exp[3] then -- ./candran/can-parser/pp.lua:161
for i = 3, # exp do -- ./candran/can-parser/pp.lua:162
str = str .. ", " .. exp2str(exp[i]) -- ./candran/can-parser/pp.lua:163
end -- ./candran/can-parser/pp.lua:163
end -- ./candran/can-parser/pp.lua:163
str = str .. " }" -- ./candran/can-parser/pp.lua:166
elseif tag == "Id" or tag == "Index" then -- ./candran/can-parser/pp.lua:168
str = var2str(exp) -- ./candran/can-parser/pp.lua:169
else -- ./candran/can-parser/pp.lua:169
error("expecting an expression, but got a " .. tag) -- ./candran/can-parser/pp.lua:171
end -- ./candran/can-parser/pp.lua:171
return str -- ./candran/can-parser/pp.lua:173
end -- ./candran/can-parser/pp.lua:173
explist2str = function(explist) -- ./candran/can-parser/pp.lua:176
local l = {} -- ./candran/can-parser/pp.lua:177
for k, v in ipairs(explist) do -- ./candran/can-parser/pp.lua:178
l[k] = exp2str(v) -- ./candran/can-parser/pp.lua:179
end -- ./candran/can-parser/pp.lua:179
if # l > 0 then -- ./candran/can-parser/pp.lua:181
return "{ " .. table["concat"](l, ", ") .. " }" -- ./candran/can-parser/pp.lua:182
else -- ./candran/can-parser/pp.lua:182
return "" -- ./candran/can-parser/pp.lua:184
end -- ./candran/can-parser/pp.lua:184
end -- ./candran/can-parser/pp.lua:184
stm2str = function(stm) -- ./candran/can-parser/pp.lua:188
local tag = stm["tag"] -- ./candran/can-parser/pp.lua:189
local str = "`" .. tag -- ./candran/can-parser/pp.lua:190
if tag == "Do" then -- ./candran/can-parser/pp.lua:191
local l = {} -- ./candran/can-parser/pp.lua:192
for k, v in ipairs(stm) do -- ./candran/can-parser/pp.lua:193
l[k] = stm2str(v) -- ./candran/can-parser/pp.lua:194
end -- ./candran/can-parser/pp.lua:194
str = str .. "{ " .. table["concat"](l, ", ") .. " }" -- ./candran/can-parser/pp.lua:196
elseif tag == "Set" then -- ./candran/can-parser/pp.lua:197
str = str .. "{ " -- ./candran/can-parser/pp.lua:198
str = str .. varlist2str(stm[1]) .. ", " -- ./candran/can-parser/pp.lua:199
str = str .. explist2str(stm[2]) -- ./candran/can-parser/pp.lua:200
str = str .. " }" -- ./candran/can-parser/pp.lua:201
elseif tag == "While" then -- ./candran/can-parser/pp.lua:202
str = str .. "{ " -- ./candran/can-parser/pp.lua:203
str = str .. exp2str(stm[1]) .. ", " -- ./candran/can-parser/pp.lua:204
str = str .. block2str(stm[2]) -- ./candran/can-parser/pp.lua:205
str = str .. " }" -- ./candran/can-parser/pp.lua:206
elseif tag == "Repeat" then -- ./candran/can-parser/pp.lua:207
str = str .. "{ " -- ./candran/can-parser/pp.lua:208
str = str .. block2str(stm[1]) .. ", " -- ./candran/can-parser/pp.lua:209
str = str .. exp2str(stm[2]) -- ./candran/can-parser/pp.lua:210
str = str .. " }" -- ./candran/can-parser/pp.lua:211
elseif tag == "If" then -- ./candran/can-parser/pp.lua:212
str = str .. "{ " -- ./candran/can-parser/pp.lua:213
local len = # stm -- ./candran/can-parser/pp.lua:214
if len % 2 == 0 then -- ./candran/can-parser/pp.lua:215
local l = {} -- ./candran/can-parser/pp.lua:216
for i = 1, len - 2, 2 do -- ./candran/can-parser/pp.lua:217
str = str .. exp2str(stm[i]) .. ", " .. block2str(stm[i + 1]) .. ", " -- ./candran/can-parser/pp.lua:218
end -- ./candran/can-parser/pp.lua:218
str = str .. exp2str(stm[len - 1]) .. ", " .. block2str(stm[len]) -- ./candran/can-parser/pp.lua:220
else -- ./candran/can-parser/pp.lua:220
local l = {} -- ./candran/can-parser/pp.lua:222
for i = 1, len - 3, 2 do -- ./candran/can-parser/pp.lua:223
str = str .. exp2str(stm[i]) .. ", " .. block2str(stm[i + 1]) .. ", " -- ./candran/can-parser/pp.lua:224
end -- ./candran/can-parser/pp.lua:224
str = str .. exp2str(stm[len - 2]) .. ", " .. block2str(stm[len - 1]) .. ", " -- ./candran/can-parser/pp.lua:226
str = str .. block2str(stm[len]) -- ./candran/can-parser/pp.lua:227
end -- ./candran/can-parser/pp.lua:227
str = str .. " }" -- ./candran/can-parser/pp.lua:229
elseif tag == "Fornum" then -- ./candran/can-parser/pp.lua:230
str = str .. "{ " -- ./candran/can-parser/pp.lua:231
str = str .. var2str(stm[1]) .. ", " -- ./candran/can-parser/pp.lua:232
str = str .. exp2str(stm[2]) .. ", " -- ./candran/can-parser/pp.lua:233
str = str .. exp2str(stm[3]) .. ", " -- ./candran/can-parser/pp.lua:234
if stm[5] then -- ./candran/can-parser/pp.lua:235
str = str .. exp2str(stm[4]) .. ", " -- ./candran/can-parser/pp.lua:236
str = str .. block2str(stm[5]) -- ./candran/can-parser/pp.lua:237
else -- ./candran/can-parser/pp.lua:237
str = str .. block2str(stm[4]) -- ./candran/can-parser/pp.lua:239
end -- ./candran/can-parser/pp.lua:239
str = str .. " }" -- ./candran/can-parser/pp.lua:241
elseif tag == "Forin" then -- ./candran/can-parser/pp.lua:242
str = str .. "{ " -- ./candran/can-parser/pp.lua:243
str = str .. varlist2str(stm[1]) .. ", " -- ./candran/can-parser/pp.lua:244
str = str .. explist2str(stm[2]) .. ", " -- ./candran/can-parser/pp.lua:245
str = str .. block2str(stm[3]) -- ./candran/can-parser/pp.lua:246
str = str .. " }" -- ./candran/can-parser/pp.lua:247
elseif tag == "Local" then -- ./candran/can-parser/pp.lua:248
str = str .. "{ " -- ./candran/can-parser/pp.lua:249
str = str .. varlist2str(stm[1]) -- ./candran/can-parser/pp.lua:250
if # stm[2] > 0 then -- ./candran/can-parser/pp.lua:251
str = str .. ", " .. explist2str(stm[2]) -- ./candran/can-parser/pp.lua:252
else -- ./candran/can-parser/pp.lua:252
str = str .. ", " .. "{  }" -- ./candran/can-parser/pp.lua:254
end -- ./candran/can-parser/pp.lua:254
str = str .. " }" -- ./candran/can-parser/pp.lua:256
elseif tag == "Localrec" then -- ./candran/can-parser/pp.lua:257
str = str .. "{ " -- ./candran/can-parser/pp.lua:258
str = str .. "{ " .. var2str(stm[1][1]) .. " }, " -- ./candran/can-parser/pp.lua:259
str = str .. "{ " .. exp2str(stm[2][1]) .. " }" -- ./candran/can-parser/pp.lua:260
str = str .. " }" -- ./candran/can-parser/pp.lua:261
elseif tag == "Goto" or tag == "Label" then -- ./candran/can-parser/pp.lua:263
str = str .. "{ " .. name2str(stm[1]) .. " }" -- ./candran/can-parser/pp.lua:264
elseif tag == "Return" then -- ./candran/can-parser/pp.lua:265
str = str .. explist2str(stm) -- ./candran/can-parser/pp.lua:266
elseif tag == "Break" then -- ./candran/can-parser/pp.lua:267
 -- ./candran/can-parser/pp.lua:268
elseif tag == "Call" then -- ./candran/can-parser/pp.lua:268
str = str .. "{ " -- ./candran/can-parser/pp.lua:269
str = str .. exp2str(stm[1]) -- ./candran/can-parser/pp.lua:270
if stm[2] then -- ./candran/can-parser/pp.lua:271
for i = 2, # stm do -- ./candran/can-parser/pp.lua:272
str = str .. ", " .. exp2str(stm[i]) -- ./candran/can-parser/pp.lua:273
end -- ./candran/can-parser/pp.lua:273
end -- ./candran/can-parser/pp.lua:273
str = str .. " }" -- ./candran/can-parser/pp.lua:276
elseif tag == "Invoke" then -- ./candran/can-parser/pp.lua:277
str = str .. "{ " -- ./candran/can-parser/pp.lua:278
str = str .. exp2str(stm[1]) .. ", " -- ./candran/can-parser/pp.lua:279
str = str .. exp2str(stm[2]) -- ./candran/can-parser/pp.lua:280
if stm[3] then -- ./candran/can-parser/pp.lua:281
for i = 3, # stm do -- ./candran/can-parser/pp.lua:282
str = str .. ", " .. exp2str(stm[i]) -- ./candran/can-parser/pp.lua:283
end -- ./candran/can-parser/pp.lua:283
end -- ./candran/can-parser/pp.lua:283
str = str .. " }" -- ./candran/can-parser/pp.lua:286
else -- ./candran/can-parser/pp.lua:286
error("expecting a statement, but got a " .. tag) -- ./candran/can-parser/pp.lua:288
end -- ./candran/can-parser/pp.lua:288
return str -- ./candran/can-parser/pp.lua:290
end -- ./candran/can-parser/pp.lua:290
block2str = function(block) -- ./candran/can-parser/pp.lua:293
local l = {} -- ./candran/can-parser/pp.lua:294
for k, v in ipairs(block) do -- ./candran/can-parser/pp.lua:295
l[k] = stm2str(v) -- ./candran/can-parser/pp.lua:296
end -- ./candran/can-parser/pp.lua:296
return "{ " .. table["concat"](l, ", ") .. " }" -- ./candran/can-parser/pp.lua:298
end -- ./candran/can-parser/pp.lua:298
pp["tostring"] = function(t) -- ./candran/can-parser/pp.lua:301
assert(type(t) == "table") -- ./candran/can-parser/pp.lua:302
return block2str(t) -- ./candran/can-parser/pp.lua:303
end -- ./candran/can-parser/pp.lua:303
pp["print"] = function(t) -- ./candran/can-parser/pp.lua:306
assert(type(t) == "table") -- ./candran/can-parser/pp.lua:307
print(pp["tostring"](t)) -- ./candran/can-parser/pp.lua:308
end -- ./candran/can-parser/pp.lua:308
pp["dump"] = function(t, i) -- ./candran/can-parser/pp.lua:311
if i == nil then -- ./candran/can-parser/pp.lua:312
i = 0 -- ./candran/can-parser/pp.lua:312
end -- ./candran/can-parser/pp.lua:312
io["write"](string["format"]("{\
")) -- ./candran/can-parser/pp.lua:313
io["write"](string["format"]("%s[tag] = %s\
", string["rep"](" ", i + 2), t["tag"] or "nil")) -- ./candran/can-parser/pp.lua:314
io["write"](string["format"]("%s[pos] = %s\
", string["rep"](" ", i + 2), t["pos"] or "nil")) -- ./candran/can-parser/pp.lua:315
for k, v in ipairs(t) do -- ./candran/can-parser/pp.lua:316
io["write"](string["format"]("%s[%s] = ", string["rep"](" ", i + 2), tostring(k))) -- ./candran/can-parser/pp.lua:317
if type(v) == "table" then -- ./candran/can-parser/pp.lua:318
pp["dump"](v, i + 2) -- ./candran/can-parser/pp.lua:319
else -- ./candran/can-parser/pp.lua:319
io["write"](string["format"]("%s\
", tostring(v))) -- ./candran/can-parser/pp.lua:321
end -- ./candran/can-parser/pp.lua:321
end -- ./candran/can-parser/pp.lua:321
io["write"](string["format"]("%s}\
", string["rep"](" ", i))) -- ./candran/can-parser/pp.lua:324
end -- ./candran/can-parser/pp.lua:324
return pp -- ./candran/can-parser/pp.lua:327
end -- ./candran/can-parser/pp.lua:327
local pp = _() or pp -- ./candran/can-parser/pp.lua:331
package["loaded"]["candran.can-parser.pp"] = pp or true -- ./candran/can-parser/pp.lua:332
local function _() -- ./candran/can-parser/pp.lua:335
local lpeg = require("lpeglabel") -- ./candran/can-parser/parser.lua:72
lpeg["locale"](lpeg) -- ./candran/can-parser/parser.lua:74
local P, S, V = lpeg["P"], lpeg["S"], lpeg["V"] -- ./candran/can-parser/parser.lua:76
local C, Carg, Cb, Cc = lpeg["C"], lpeg["Carg"], lpeg["Cb"], lpeg["Cc"] -- ./candran/can-parser/parser.lua:77
local Cf, Cg, Cmt, Cp, Cs, Ct = lpeg["Cf"], lpeg["Cg"], lpeg["Cmt"], lpeg["Cp"], lpeg["Cs"], lpeg["Ct"] -- ./candran/can-parser/parser.lua:78
local Rec, T = lpeg["Rec"], lpeg["T"] -- ./candran/can-parser/parser.lua:79
local alpha, digit, alnum = lpeg["alpha"], lpeg["digit"], lpeg["alnum"] -- ./candran/can-parser/parser.lua:81
local xdigit = lpeg["xdigit"] -- ./candran/can-parser/parser.lua:82
local space = lpeg["space"] -- ./candran/can-parser/parser.lua:83
local labels = { -- ./candran/can-parser/parser.lua:88
{ -- ./candran/can-parser/parser.lua:89
"ErrExtra", -- ./candran/can-parser/parser.lua:89
"unexpected character(s), expected EOF" -- ./candran/can-parser/parser.lua:89
}, -- ./candran/can-parser/parser.lua:89
{ -- ./candran/can-parser/parser.lua:90
"ErrInvalidStat", -- ./candran/can-parser/parser.lua:90
"unexpected token, invalid start of statement" -- ./candran/can-parser/parser.lua:90
}, -- ./candran/can-parser/parser.lua:90
{ -- ./candran/can-parser/parser.lua:92
"ErrEndIf", -- ./candran/can-parser/parser.lua:92
"expected 'end' to close the if statement" -- ./candran/can-parser/parser.lua:92
}, -- ./candran/can-parser/parser.lua:92
{ -- ./candran/can-parser/parser.lua:93
"ErrExprIf", -- ./candran/can-parser/parser.lua:93
"expected a condition after 'if'" -- ./candran/can-parser/parser.lua:93
}, -- ./candran/can-parser/parser.lua:93
{ -- ./candran/can-parser/parser.lua:94
"ErrThenIf", -- ./candran/can-parser/parser.lua:94
"expected 'then' after the condition" -- ./candran/can-parser/parser.lua:94
}, -- ./candran/can-parser/parser.lua:94
{ -- ./candran/can-parser/parser.lua:95
"ErrExprEIf", -- ./candran/can-parser/parser.lua:95
"expected a condition after 'elseif'" -- ./candran/can-parser/parser.lua:95
}, -- ./candran/can-parser/parser.lua:95
{ -- ./candran/can-parser/parser.lua:96
"ErrThenEIf", -- ./candran/can-parser/parser.lua:96
"expected 'then' after the condition" -- ./candran/can-parser/parser.lua:96
}, -- ./candran/can-parser/parser.lua:96
{ -- ./candran/can-parser/parser.lua:98
"ErrEndDo", -- ./candran/can-parser/parser.lua:98
"expected 'end' to close the do block" -- ./candran/can-parser/parser.lua:98
}, -- ./candran/can-parser/parser.lua:98
{ -- ./candran/can-parser/parser.lua:99
"ErrExprWhile", -- ./candran/can-parser/parser.lua:99
"expected a condition after 'while'" -- ./candran/can-parser/parser.lua:99
}, -- ./candran/can-parser/parser.lua:99
{ -- ./candran/can-parser/parser.lua:100
"ErrDoWhile", -- ./candran/can-parser/parser.lua:100
"expected 'do' after the condition" -- ./candran/can-parser/parser.lua:100
}, -- ./candran/can-parser/parser.lua:100
{ -- ./candran/can-parser/parser.lua:101
"ErrEndWhile", -- ./candran/can-parser/parser.lua:101
"expected 'end' to close the while loop" -- ./candran/can-parser/parser.lua:101
}, -- ./candran/can-parser/parser.lua:101
{ -- ./candran/can-parser/parser.lua:102
"ErrUntilRep", -- ./candran/can-parser/parser.lua:102
"expected 'until' at the end of the repeat loop" -- ./candran/can-parser/parser.lua:102
}, -- ./candran/can-parser/parser.lua:102
{ -- ./candran/can-parser/parser.lua:103
"ErrExprRep", -- ./candran/can-parser/parser.lua:103
"expected a conditions after 'until'" -- ./candran/can-parser/parser.lua:103
}, -- ./candran/can-parser/parser.lua:103
{ -- ./candran/can-parser/parser.lua:105
"ErrForRange", -- ./candran/can-parser/parser.lua:105
"expected a numeric or generic range after 'for'" -- ./candran/can-parser/parser.lua:105
}, -- ./candran/can-parser/parser.lua:105
{ -- ./candran/can-parser/parser.lua:106
"ErrEndFor", -- ./candran/can-parser/parser.lua:106
"expected 'end' to close the for loop" -- ./candran/can-parser/parser.lua:106
}, -- ./candran/can-parser/parser.lua:106
{ -- ./candran/can-parser/parser.lua:107
"ErrExprFor1", -- ./candran/can-parser/parser.lua:107
"expected a starting expression for the numeric range" -- ./candran/can-parser/parser.lua:107
}, -- ./candran/can-parser/parser.lua:107
{ -- ./candran/can-parser/parser.lua:108
"ErrCommaFor", -- ./candran/can-parser/parser.lua:108
"expected ',' to split the start and end of the range" -- ./candran/can-parser/parser.lua:108
}, -- ./candran/can-parser/parser.lua:108
{ -- ./candran/can-parser/parser.lua:109
"ErrExprFor2", -- ./candran/can-parser/parser.lua:109
"expected an ending expression for the numeric range" -- ./candran/can-parser/parser.lua:109
}, -- ./candran/can-parser/parser.lua:109
{ -- ./candran/can-parser/parser.lua:110
"ErrExprFor3", -- ./candran/can-parser/parser.lua:110
"expected a step expression for the numeric range after ','" -- ./candran/can-parser/parser.lua:110
}, -- ./candran/can-parser/parser.lua:110
{ -- ./candran/can-parser/parser.lua:111
"ErrInFor", -- ./candran/can-parser/parser.lua:111
"expected '=' or 'in' after the variable(s)" -- ./candran/can-parser/parser.lua:111
}, -- ./candran/can-parser/parser.lua:111
{ -- ./candran/can-parser/parser.lua:112
"ErrEListFor", -- ./candran/can-parser/parser.lua:112
"expected one or more expressions after 'in'" -- ./candran/can-parser/parser.lua:112
}, -- ./candran/can-parser/parser.lua:112
{ -- ./candran/can-parser/parser.lua:113
"ErrDoFor", -- ./candran/can-parser/parser.lua:113
"expected 'do' after the range of the for loop" -- ./candran/can-parser/parser.lua:113
}, -- ./candran/can-parser/parser.lua:113
{ -- ./candran/can-parser/parser.lua:115
"ErrDefLocal", -- ./candran/can-parser/parser.lua:115
"expected a function definition or assignment after local" -- ./candran/can-parser/parser.lua:115
}, -- ./candran/can-parser/parser.lua:115
{ -- ./candran/can-parser/parser.lua:116
"ErrDefLet", -- ./candran/can-parser/parser.lua:116
"expected an assignment after let" -- ./candran/can-parser/parser.lua:116
}, -- ./candran/can-parser/parser.lua:116
{ -- ./candran/can-parser/parser.lua:117
"ErrDefClose", -- ./candran/can-parser/parser.lua:117
"expected an assignment after close" -- ./candran/can-parser/parser.lua:117
}, -- ./candran/can-parser/parser.lua:117
{ -- ./candran/can-parser/parser.lua:118
"ErrDefConst", -- ./candran/can-parser/parser.lua:118
"expected an assignment after const" -- ./candran/can-parser/parser.lua:118
}, -- ./candran/can-parser/parser.lua:118
{ -- ./candran/can-parser/parser.lua:119
"ErrNameLFunc", -- ./candran/can-parser/parser.lua:119
"expected a function name after 'function'" -- ./candran/can-parser/parser.lua:119
}, -- ./candran/can-parser/parser.lua:119
{ -- ./candran/can-parser/parser.lua:120
"ErrEListLAssign", -- ./candran/can-parser/parser.lua:120
"expected one or more expressions after '='" -- ./candran/can-parser/parser.lua:120
}, -- ./candran/can-parser/parser.lua:120
{ -- ./candran/can-parser/parser.lua:121
"ErrEListAssign", -- ./candran/can-parser/parser.lua:121
"expected one or more expressions after '='" -- ./candran/can-parser/parser.lua:121
}, -- ./candran/can-parser/parser.lua:121
{ -- ./candran/can-parser/parser.lua:123
"ErrFuncName", -- ./candran/can-parser/parser.lua:123
"expected a function name after 'function'" -- ./candran/can-parser/parser.lua:123
}, -- ./candran/can-parser/parser.lua:123
{ -- ./candran/can-parser/parser.lua:124
"ErrNameFunc1", -- ./candran/can-parser/parser.lua:124
"expected a function name after '.'" -- ./candran/can-parser/parser.lua:124
}, -- ./candran/can-parser/parser.lua:124
{ -- ./candran/can-parser/parser.lua:125
"ErrNameFunc2", -- ./candran/can-parser/parser.lua:125
"expected a method name after ':'" -- ./candran/can-parser/parser.lua:125
}, -- ./candran/can-parser/parser.lua:125
{ -- ./candran/can-parser/parser.lua:126
"ErrOParenPList", -- ./candran/can-parser/parser.lua:126
"expected '(' for the parameter list" -- ./candran/can-parser/parser.lua:126
}, -- ./candran/can-parser/parser.lua:126
{ -- ./candran/can-parser/parser.lua:127
"ErrCParenPList", -- ./candran/can-parser/parser.lua:127
"expected ')' to close the parameter list" -- ./candran/can-parser/parser.lua:127
}, -- ./candran/can-parser/parser.lua:127
{ -- ./candran/can-parser/parser.lua:128
"ErrEndFunc", -- ./candran/can-parser/parser.lua:128
"expected 'end' to close the function body" -- ./candran/can-parser/parser.lua:128
}, -- ./candran/can-parser/parser.lua:128
{ -- ./candran/can-parser/parser.lua:129
"ErrParList", -- ./candran/can-parser/parser.lua:129
"expected a variable name or '...' after ','" -- ./candran/can-parser/parser.lua:129
}, -- ./candran/can-parser/parser.lua:129
{ -- ./candran/can-parser/parser.lua:131
"ErrLabel", -- ./candran/can-parser/parser.lua:131
"expected a label name after '::'" -- ./candran/can-parser/parser.lua:131
}, -- ./candran/can-parser/parser.lua:131
{ -- ./candran/can-parser/parser.lua:132
"ErrCloseLabel", -- ./candran/can-parser/parser.lua:132
"expected '::' after the label" -- ./candran/can-parser/parser.lua:132
}, -- ./candran/can-parser/parser.lua:132
{ -- ./candran/can-parser/parser.lua:133
"ErrGoto", -- ./candran/can-parser/parser.lua:133
"expected a label after 'goto'" -- ./candran/can-parser/parser.lua:133
}, -- ./candran/can-parser/parser.lua:133
{ -- ./candran/can-parser/parser.lua:134
"ErrRetList", -- ./candran/can-parser/parser.lua:134
"expected an expression after ',' in the return statement" -- ./candran/can-parser/parser.lua:134
}, -- ./candran/can-parser/parser.lua:134
{ -- ./candran/can-parser/parser.lua:136
"ErrVarList", -- ./candran/can-parser/parser.lua:136
"expected a variable name after ','" -- ./candran/can-parser/parser.lua:136
}, -- ./candran/can-parser/parser.lua:136
{ -- ./candran/can-parser/parser.lua:137
"ErrExprList", -- ./candran/can-parser/parser.lua:137
"expected an expression after ','" -- ./candran/can-parser/parser.lua:137
}, -- ./candran/can-parser/parser.lua:137
{ -- ./candran/can-parser/parser.lua:139
"ErrOrExpr", -- ./candran/can-parser/parser.lua:139
"expected an expression after 'or'" -- ./candran/can-parser/parser.lua:139
}, -- ./candran/can-parser/parser.lua:139
{ -- ./candran/can-parser/parser.lua:140
"ErrAndExpr", -- ./candran/can-parser/parser.lua:140
"expected an expression after 'and'" -- ./candran/can-parser/parser.lua:140
}, -- ./candran/can-parser/parser.lua:140
{ -- ./candran/can-parser/parser.lua:141
"ErrRelExpr", -- ./candran/can-parser/parser.lua:141
"expected an expression after the relational operator" -- ./candran/can-parser/parser.lua:141
}, -- ./candran/can-parser/parser.lua:141
{ -- ./candran/can-parser/parser.lua:142
"ErrBOrExpr", -- ./candran/can-parser/parser.lua:142
"expected an expression after '|'" -- ./candran/can-parser/parser.lua:142
}, -- ./candran/can-parser/parser.lua:142
{ -- ./candran/can-parser/parser.lua:143
"ErrBXorExpr", -- ./candran/can-parser/parser.lua:143
"expected an expression after '~'" -- ./candran/can-parser/parser.lua:143
}, -- ./candran/can-parser/parser.lua:143
{ -- ./candran/can-parser/parser.lua:144
"ErrBAndExpr", -- ./candran/can-parser/parser.lua:144
"expected an expression after '&'" -- ./candran/can-parser/parser.lua:144
}, -- ./candran/can-parser/parser.lua:144
{ -- ./candran/can-parser/parser.lua:145
"ErrShiftExpr", -- ./candran/can-parser/parser.lua:145
"expected an expression after the bit shift" -- ./candran/can-parser/parser.lua:145
}, -- ./candran/can-parser/parser.lua:145
{ -- ./candran/can-parser/parser.lua:146
"ErrConcatExpr", -- ./candran/can-parser/parser.lua:146
"expected an expression after '..'" -- ./candran/can-parser/parser.lua:146
}, -- ./candran/can-parser/parser.lua:146
{ -- ./candran/can-parser/parser.lua:147
"ErrAddExpr", -- ./candran/can-parser/parser.lua:147
"expected an expression after the additive operator" -- ./candran/can-parser/parser.lua:147
}, -- ./candran/can-parser/parser.lua:147
{ -- ./candran/can-parser/parser.lua:148
"ErrMulExpr", -- ./candran/can-parser/parser.lua:148
"expected an expression after the multiplicative operator" -- ./candran/can-parser/parser.lua:148
}, -- ./candran/can-parser/parser.lua:148
{ -- ./candran/can-parser/parser.lua:149
"ErrUnaryExpr", -- ./candran/can-parser/parser.lua:149
"expected an expression after the unary operator" -- ./candran/can-parser/parser.lua:149
}, -- ./candran/can-parser/parser.lua:149
{ -- ./candran/can-parser/parser.lua:150
"ErrPowExpr", -- ./candran/can-parser/parser.lua:150
"expected an expression after '^'" -- ./candran/can-parser/parser.lua:150
}, -- ./candran/can-parser/parser.lua:150
{ -- ./candran/can-parser/parser.lua:152
"ErrExprParen", -- ./candran/can-parser/parser.lua:152
"expected an expression after '('" -- ./candran/can-parser/parser.lua:152
}, -- ./candran/can-parser/parser.lua:152
{ -- ./candran/can-parser/parser.lua:153
"ErrCParenExpr", -- ./candran/can-parser/parser.lua:153
"expected ')' to close the expression" -- ./candran/can-parser/parser.lua:153
}, -- ./candran/can-parser/parser.lua:153
{ -- ./candran/can-parser/parser.lua:154
"ErrNameIndex", -- ./candran/can-parser/parser.lua:154
"expected a field name after '.'" -- ./candran/can-parser/parser.lua:154
}, -- ./candran/can-parser/parser.lua:154
{ -- ./candran/can-parser/parser.lua:155
"ErrExprIndex", -- ./candran/can-parser/parser.lua:155
"expected an expression after '['" -- ./candran/can-parser/parser.lua:155
}, -- ./candran/can-parser/parser.lua:155
{ -- ./candran/can-parser/parser.lua:156
"ErrCBracketIndex", -- ./candran/can-parser/parser.lua:156
"expected ']' to close the indexing expression" -- ./candran/can-parser/parser.lua:156
}, -- ./candran/can-parser/parser.lua:156
{ -- ./candran/can-parser/parser.lua:157
"ErrNameMeth", -- ./candran/can-parser/parser.lua:157
"expected a method name after ':'" -- ./candran/can-parser/parser.lua:157
}, -- ./candran/can-parser/parser.lua:157
{ -- ./candran/can-parser/parser.lua:158
"ErrMethArgs", -- ./candran/can-parser/parser.lua:158
"expected some arguments for the method call (or '()')" -- ./candran/can-parser/parser.lua:158
}, -- ./candran/can-parser/parser.lua:158
{ -- ./candran/can-parser/parser.lua:160
"ErrArgList", -- ./candran/can-parser/parser.lua:160
"expected an expression after ',' in the argument list" -- ./candran/can-parser/parser.lua:160
}, -- ./candran/can-parser/parser.lua:160
{ -- ./candran/can-parser/parser.lua:161
"ErrCParenArgs", -- ./candran/can-parser/parser.lua:161
"expected ')' to close the argument list" -- ./candran/can-parser/parser.lua:161
}, -- ./candran/can-parser/parser.lua:161
{ -- ./candran/can-parser/parser.lua:163
"ErrCBraceTable", -- ./candran/can-parser/parser.lua:163
"expected '}' to close the table constructor" -- ./candran/can-parser/parser.lua:163
}, -- ./candran/can-parser/parser.lua:163
{ -- ./candran/can-parser/parser.lua:164
"ErrEqField", -- ./candran/can-parser/parser.lua:164
"expected '=' after the table key" -- ./candran/can-parser/parser.lua:164
}, -- ./candran/can-parser/parser.lua:164
{ -- ./candran/can-parser/parser.lua:165
"ErrExprField", -- ./candran/can-parser/parser.lua:165
"expected an expression after '='" -- ./candran/can-parser/parser.lua:165
}, -- ./candran/can-parser/parser.lua:165
{ -- ./candran/can-parser/parser.lua:166
"ErrExprFKey", -- ./candran/can-parser/parser.lua:166
"expected an expression after '[' for the table key" -- ./candran/can-parser/parser.lua:166
}, -- ./candran/can-parser/parser.lua:166
{ -- ./candran/can-parser/parser.lua:167
"ErrCBracketFKey", -- ./candran/can-parser/parser.lua:167
"expected ']' to close the table key" -- ./candran/can-parser/parser.lua:167
}, -- ./candran/can-parser/parser.lua:167
{ -- ./candran/can-parser/parser.lua:169
"ErrCBraceDestructuring", -- ./candran/can-parser/parser.lua:169
"expected '}' to close the destructuring variable list" -- ./candran/can-parser/parser.lua:169
}, -- ./candran/can-parser/parser.lua:169
{ -- ./candran/can-parser/parser.lua:170
"ErrDestructuringEqField", -- ./candran/can-parser/parser.lua:170
"expected '=' after the table key in destructuring variable list" -- ./candran/can-parser/parser.lua:170
}, -- ./candran/can-parser/parser.lua:170
{ -- ./candran/can-parser/parser.lua:171
"ErrDestructuringExprField", -- ./candran/can-parser/parser.lua:171
"expected an identifier after '=' in destructuring variable list" -- ./candran/can-parser/parser.lua:171
}, -- ./candran/can-parser/parser.lua:171
{ -- ./candran/can-parser/parser.lua:173
"ErrCBracketTableCompr", -- ./candran/can-parser/parser.lua:173
"expected ']' to close the table comprehension" -- ./candran/can-parser/parser.lua:173
}, -- ./candran/can-parser/parser.lua:173
{ -- ./candran/can-parser/parser.lua:175
"ErrDigitHex", -- ./candran/can-parser/parser.lua:175
"expected one or more hexadecimal digits after '0x'" -- ./candran/can-parser/parser.lua:175
}, -- ./candran/can-parser/parser.lua:175
{ -- ./candran/can-parser/parser.lua:176
"ErrDigitDeci", -- ./candran/can-parser/parser.lua:176
"expected one or more digits after the decimal point" -- ./candran/can-parser/parser.lua:176
}, -- ./candran/can-parser/parser.lua:176
{ -- ./candran/can-parser/parser.lua:177
"ErrDigitExpo", -- ./candran/can-parser/parser.lua:177
"expected one or more digits for the exponent" -- ./candran/can-parser/parser.lua:177
}, -- ./candran/can-parser/parser.lua:177
{ -- ./candran/can-parser/parser.lua:179
"ErrQuote", -- ./candran/can-parser/parser.lua:179
"unclosed string" -- ./candran/can-parser/parser.lua:179
}, -- ./candran/can-parser/parser.lua:179
{ -- ./candran/can-parser/parser.lua:180
"ErrHexEsc", -- ./candran/can-parser/parser.lua:180
"expected exactly two hexadecimal digits after '\\x'" -- ./candran/can-parser/parser.lua:180
}, -- ./candran/can-parser/parser.lua:180
{ -- ./candran/can-parser/parser.lua:181
"ErrOBraceUEsc", -- ./candran/can-parser/parser.lua:181
"expected '{' after '\\u'" -- ./candran/can-parser/parser.lua:181
}, -- ./candran/can-parser/parser.lua:181
{ -- ./candran/can-parser/parser.lua:182
"ErrDigitUEsc", -- ./candran/can-parser/parser.lua:182
"expected one or more hexadecimal digits for the UTF-8 code point" -- ./candran/can-parser/parser.lua:182
}, -- ./candran/can-parser/parser.lua:182
{ -- ./candran/can-parser/parser.lua:183
"ErrCBraceUEsc", -- ./candran/can-parser/parser.lua:183
"expected '}' after the code point" -- ./candran/can-parser/parser.lua:183
}, -- ./candran/can-parser/parser.lua:183
{ -- ./candran/can-parser/parser.lua:184
"ErrEscSeq", -- ./candran/can-parser/parser.lua:184
"invalid escape sequence" -- ./candran/can-parser/parser.lua:184
}, -- ./candran/can-parser/parser.lua:184
{ -- ./candran/can-parser/parser.lua:185
"ErrCloseLStr", -- ./candran/can-parser/parser.lua:185
"unclosed long string" -- ./candran/can-parser/parser.lua:185
}, -- ./candran/can-parser/parser.lua:185
{ -- ./candran/can-parser/parser.lua:187
"ErrUnknownAttribute", -- ./candran/can-parser/parser.lua:187
"unknown variable attribute" -- ./candran/can-parser/parser.lua:187
}, -- ./candran/can-parser/parser.lua:187
{ -- ./candran/can-parser/parser.lua:188
"ErrCBracketAttribute", -- ./candran/can-parser/parser.lua:188
"expected '>' to close the variable attribute" -- ./candran/can-parser/parser.lua:188
} -- ./candran/can-parser/parser.lua:188
} -- ./candran/can-parser/parser.lua:188
local function throw(label) -- ./candran/can-parser/parser.lua:191
label = "Err" .. label -- ./candran/can-parser/parser.lua:192
for i, labelinfo in ipairs(labels) do -- ./candran/can-parser/parser.lua:193
if labelinfo[1] == label then -- ./candran/can-parser/parser.lua:194
return T(i) -- ./candran/can-parser/parser.lua:195
end -- ./candran/can-parser/parser.lua:195
end -- ./candran/can-parser/parser.lua:195
error("Label not found: " .. label) -- ./candran/can-parser/parser.lua:199
end -- ./candran/can-parser/parser.lua:199
local function expect(patt, label) -- ./candran/can-parser/parser.lua:202
return patt + throw(label) -- ./candran/can-parser/parser.lua:203
end -- ./candran/can-parser/parser.lua:203
local function token(patt) -- ./candran/can-parser/parser.lua:209
return patt * V("Skip") -- ./candran/can-parser/parser.lua:210
end -- ./candran/can-parser/parser.lua:210
local function sym(str) -- ./candran/can-parser/parser.lua:213
return token(P(str)) -- ./candran/can-parser/parser.lua:214
end -- ./candran/can-parser/parser.lua:214
local function kw(str) -- ./candran/can-parser/parser.lua:217
return token(P(str) * - V("IdRest")) -- ./candran/can-parser/parser.lua:218
end -- ./candran/can-parser/parser.lua:218
local function tagC(tag, patt) -- ./candran/can-parser/parser.lua:221
return Ct(Cg(Cp(), "pos") * Cg(Cc(tag), "tag") * patt) -- ./candran/can-parser/parser.lua:222
end -- ./candran/can-parser/parser.lua:222
local function unaryOp(op, e) -- ./candran/can-parser/parser.lua:225
return { -- ./candran/can-parser/parser.lua:226
["tag"] = "Op", -- ./candran/can-parser/parser.lua:226
["pos"] = e["pos"], -- ./candran/can-parser/parser.lua:226
[1] = op, -- ./candran/can-parser/parser.lua:226
[2] = e -- ./candran/can-parser/parser.lua:226
} -- ./candran/can-parser/parser.lua:226
end -- ./candran/can-parser/parser.lua:226
local function binaryOp(e1, op, e2) -- ./candran/can-parser/parser.lua:229
if not op then -- ./candran/can-parser/parser.lua:230
return e1 -- ./candran/can-parser/parser.lua:231
else -- ./candran/can-parser/parser.lua:231
return { -- ./candran/can-parser/parser.lua:233
["tag"] = "Op", -- ./candran/can-parser/parser.lua:233
["pos"] = e1["pos"], -- ./candran/can-parser/parser.lua:233
[1] = op, -- ./candran/can-parser/parser.lua:233
[2] = e1, -- ./candran/can-parser/parser.lua:233
[3] = e2 -- ./candran/can-parser/parser.lua:233
} -- ./candran/can-parser/parser.lua:233
end -- ./candran/can-parser/parser.lua:233
end -- ./candran/can-parser/parser.lua:233
local function sepBy(patt, sep, label) -- ./candran/can-parser/parser.lua:237
if label then -- ./candran/can-parser/parser.lua:238
return patt * Cg(sep * expect(patt, label)) ^ 0 -- ./candran/can-parser/parser.lua:239
else -- ./candran/can-parser/parser.lua:239
return patt * Cg(sep * patt) ^ 0 -- ./candran/can-parser/parser.lua:241
end -- ./candran/can-parser/parser.lua:241
end -- ./candran/can-parser/parser.lua:241
local function chainOp(patt, sep, label) -- ./candran/can-parser/parser.lua:245
return Cf(sepBy(patt, sep, label), binaryOp) -- ./candran/can-parser/parser.lua:246
end -- ./candran/can-parser/parser.lua:246
local function commaSep(patt, label) -- ./candran/can-parser/parser.lua:249
return sepBy(patt, sym(","), label) -- ./candran/can-parser/parser.lua:250
end -- ./candran/can-parser/parser.lua:250
local function tagDo(block) -- ./candran/can-parser/parser.lua:253
block["tag"] = "Do" -- ./candran/can-parser/parser.lua:254
return block -- ./candran/can-parser/parser.lua:255
end -- ./candran/can-parser/parser.lua:255
local function fixFuncStat(func) -- ./candran/can-parser/parser.lua:258
if func[1]["is_method"] then -- ./candran/can-parser/parser.lua:259
table["insert"](func[2][1], 1, { -- ./candran/can-parser/parser.lua:259
["tag"] = "Id", -- ./candran/can-parser/parser.lua:259
[1] = "self" -- ./candran/can-parser/parser.lua:259
}) -- ./candran/can-parser/parser.lua:259
end -- ./candran/can-parser/parser.lua:259
func[1] = { func[1] } -- ./candran/can-parser/parser.lua:260
func[2] = { func[2] } -- ./candran/can-parser/parser.lua:261
return func -- ./candran/can-parser/parser.lua:262
end -- ./candran/can-parser/parser.lua:262
local function addDots(params, dots) -- ./candran/can-parser/parser.lua:265
if dots then -- ./candran/can-parser/parser.lua:266
table["insert"](params, dots) -- ./candran/can-parser/parser.lua:266
end -- ./candran/can-parser/parser.lua:266
return params -- ./candran/can-parser/parser.lua:267
end -- ./candran/can-parser/parser.lua:267
local function insertIndex(t, index) -- ./candran/can-parser/parser.lua:270
return { -- ./candran/can-parser/parser.lua:271
["tag"] = "Index", -- ./candran/can-parser/parser.lua:271
["pos"] = t["pos"], -- ./candran/can-parser/parser.lua:271
[1] = t, -- ./candran/can-parser/parser.lua:271
[2] = index -- ./candran/can-parser/parser.lua:271
} -- ./candran/can-parser/parser.lua:271
end -- ./candran/can-parser/parser.lua:271
local function markMethod(t, method) -- ./candran/can-parser/parser.lua:274
if method then -- ./candran/can-parser/parser.lua:275
return { -- ./candran/can-parser/parser.lua:276
["tag"] = "Index", -- ./candran/can-parser/parser.lua:276
["pos"] = t["pos"], -- ./candran/can-parser/parser.lua:276
["is_method"] = true, -- ./candran/can-parser/parser.lua:276
[1] = t, -- ./candran/can-parser/parser.lua:276
[2] = method -- ./candran/can-parser/parser.lua:276
} -- ./candran/can-parser/parser.lua:276
end -- ./candran/can-parser/parser.lua:276
return t -- ./candran/can-parser/parser.lua:278
end -- ./candran/can-parser/parser.lua:278
local function makeSuffixedExpr(t1, t2) -- ./candran/can-parser/parser.lua:281
if t2["tag"] == "Call" or t2["tag"] == "SafeCall" then -- ./candran/can-parser/parser.lua:282
local t = { -- ./candran/can-parser/parser.lua:283
["tag"] = t2["tag"], -- ./candran/can-parser/parser.lua:283
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:283
[1] = t1 -- ./candran/can-parser/parser.lua:283
} -- ./candran/can-parser/parser.lua:283
for k, v in ipairs(t2) do -- ./candran/can-parser/parser.lua:284
table["insert"](t, v) -- ./candran/can-parser/parser.lua:285
end -- ./candran/can-parser/parser.lua:285
return t -- ./candran/can-parser/parser.lua:287
elseif t2["tag"] == "MethodStub" or t2["tag"] == "SafeMethodStub" then -- ./candran/can-parser/parser.lua:288
return { -- ./candran/can-parser/parser.lua:289
["tag"] = t2["tag"], -- ./candran/can-parser/parser.lua:289
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:289
[1] = t1, -- ./candran/can-parser/parser.lua:289
[2] = t2[1] -- ./candran/can-parser/parser.lua:289
} -- ./candran/can-parser/parser.lua:289
elseif t2["tag"] == "SafeDotIndex" or t2["tag"] == "SafeArrayIndex" then -- ./candran/can-parser/parser.lua:290
return { -- ./candran/can-parser/parser.lua:291
["tag"] = "SafeIndex", -- ./candran/can-parser/parser.lua:291
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:291
[1] = t1, -- ./candran/can-parser/parser.lua:291
[2] = t2[1] -- ./candran/can-parser/parser.lua:291
} -- ./candran/can-parser/parser.lua:291
elseif t2["tag"] == "DotIndex" or t2["tag"] == "ArrayIndex" then -- ./candran/can-parser/parser.lua:292
return { -- ./candran/can-parser/parser.lua:293
["tag"] = "Index", -- ./candran/can-parser/parser.lua:293
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:293
[1] = t1, -- ./candran/can-parser/parser.lua:293
[2] = t2[1] -- ./candran/can-parser/parser.lua:293
} -- ./candran/can-parser/parser.lua:293
else -- ./candran/can-parser/parser.lua:293
error("unexpected tag in suffixed expression") -- ./candran/can-parser/parser.lua:295
end -- ./candran/can-parser/parser.lua:295
end -- ./candran/can-parser/parser.lua:295
local function fixShortFunc(t) -- ./candran/can-parser/parser.lua:299
if t[1] == ":" then -- ./candran/can-parser/parser.lua:300
table["insert"](t[2], 1, { -- ./candran/can-parser/parser.lua:301
["tag"] = "Id", -- ./candran/can-parser/parser.lua:301
"self" -- ./candran/can-parser/parser.lua:301
}) -- ./candran/can-parser/parser.lua:301
table["remove"](t, 1) -- ./candran/can-parser/parser.lua:302
t["is_method"] = true -- ./candran/can-parser/parser.lua:303
end -- ./candran/can-parser/parser.lua:303
t["is_short"] = true -- ./candran/can-parser/parser.lua:305
return t -- ./candran/can-parser/parser.lua:306
end -- ./candran/can-parser/parser.lua:306
local function markImplicit(t) -- ./candran/can-parser/parser.lua:309
t["implicit"] = true -- ./candran/can-parser/parser.lua:310
return t -- ./candran/can-parser/parser.lua:311
end -- ./candran/can-parser/parser.lua:311
local function statToExpr(t) -- ./candran/can-parser/parser.lua:314
t["tag"] = t["tag"] .. "Expr" -- ./candran/can-parser/parser.lua:315
return t -- ./candran/can-parser/parser.lua:316
end -- ./candran/can-parser/parser.lua:316
local function fixStructure(t) -- ./candran/can-parser/parser.lua:319
local i = 1 -- ./candran/can-parser/parser.lua:320
while i <= # t do -- ./candran/can-parser/parser.lua:321
if type(t[i]) == "table" then -- ./candran/can-parser/parser.lua:322
fixStructure(t[i]) -- ./candran/can-parser/parser.lua:323
for j = # t[i], 1, - 1 do -- ./candran/can-parser/parser.lua:324
local stat = t[i][j] -- ./candran/can-parser/parser.lua:325
if type(stat) == "table" and stat["move_up_block"] and stat["move_up_block"] > 0 then -- ./candran/can-parser/parser.lua:326
table["remove"](t[i], j) -- ./candran/can-parser/parser.lua:327
table["insert"](t, i + 1, stat) -- ./candran/can-parser/parser.lua:328
if t["tag"] == "Block" or t["tag"] == "Do" then -- ./candran/can-parser/parser.lua:329
stat["move_up_block"] = stat["move_up_block"] - 1 -- ./candran/can-parser/parser.lua:330
end -- ./candran/can-parser/parser.lua:330
end -- ./candran/can-parser/parser.lua:330
end -- ./candran/can-parser/parser.lua:330
end -- ./candran/can-parser/parser.lua:330
i = i + 1 -- ./candran/can-parser/parser.lua:335
end -- ./candran/can-parser/parser.lua:335
return t -- ./candran/can-parser/parser.lua:337
end -- ./candran/can-parser/parser.lua:337
local function searchEndRec(block, isRecCall) -- ./candran/can-parser/parser.lua:340
for i, stat in ipairs(block) do -- ./candran/can-parser/parser.lua:341
if stat["tag"] == "Set" or stat["tag"] == "Push" or stat["tag"] == "Return" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./candran/can-parser/parser.lua:343
local exprlist -- ./candran/can-parser/parser.lua:344
if stat["tag"] == "Set" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./candran/can-parser/parser.lua:346
exprlist = stat[# stat] -- ./candran/can-parser/parser.lua:347
elseif stat["tag"] == "Push" or stat["tag"] == "Return" then -- ./candran/can-parser/parser.lua:348
exprlist = stat -- ./candran/can-parser/parser.lua:349
end -- ./candran/can-parser/parser.lua:349
local last = exprlist[# exprlist] -- ./candran/can-parser/parser.lua:352
if last["tag"] == "Function" and last["is_short"] and not last["is_method"] and # last[1] == 1 then -- ./candran/can-parser/parser.lua:356
local p = i -- ./candran/can-parser/parser.lua:357
for j, fstat in ipairs(last[2]) do -- ./candran/can-parser/parser.lua:358
p = i + j -- ./candran/can-parser/parser.lua:359
table["insert"](block, p, fstat) -- ./candran/can-parser/parser.lua:360
if stat["move_up_block"] then -- ./candran/can-parser/parser.lua:362
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + stat["move_up_block"] -- ./candran/can-parser/parser.lua:363
end -- ./candran/can-parser/parser.lua:363
if block["is_singlestatblock"] then -- ./candran/can-parser/parser.lua:366
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + 1 -- ./candran/can-parser/parser.lua:367
end -- ./candran/can-parser/parser.lua:367
end -- ./candran/can-parser/parser.lua:367
exprlist[# exprlist] = last[1] -- ./candran/can-parser/parser.lua:371
exprlist[# exprlist]["tag"] = "Paren" -- ./candran/can-parser/parser.lua:372
if not isRecCall then -- ./candran/can-parser/parser.lua:374
for j = p + 1, # block, 1 do -- ./candran/can-parser/parser.lua:375
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./candran/can-parser/parser.lua:376
end -- ./candran/can-parser/parser.lua:376
end -- ./candran/can-parser/parser.lua:376
return block, i -- ./candran/can-parser/parser.lua:380
elseif last["tag"]:match("Expr$") then -- ./candran/can-parser/parser.lua:383
local r = searchEndRec({ last }) -- ./candran/can-parser/parser.lua:384
if r then -- ./candran/can-parser/parser.lua:385
for j = 2, # r, 1 do -- ./candran/can-parser/parser.lua:386
table["insert"](block, i + j - 1, r[j]) -- ./candran/can-parser/parser.lua:387
end -- ./candran/can-parser/parser.lua:387
return block, i -- ./candran/can-parser/parser.lua:389
end -- ./candran/can-parser/parser.lua:389
elseif last["tag"] == "Function" then -- ./candran/can-parser/parser.lua:391
local r = searchEndRec(last[2]) -- ./candran/can-parser/parser.lua:392
if r then -- ./candran/can-parser/parser.lua:393
return block, i -- ./candran/can-parser/parser.lua:394
end -- ./candran/can-parser/parser.lua:394
end -- ./candran/can-parser/parser.lua:394
elseif stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Do") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./candran/can-parser/parser.lua:399
local blocks -- ./candran/can-parser/parser.lua:400
if stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./candran/can-parser/parser.lua:402
blocks = stat -- ./candran/can-parser/parser.lua:403
elseif stat["tag"]:match("^Do") then -- ./candran/can-parser/parser.lua:404
blocks = { stat } -- ./candran/can-parser/parser.lua:405
end -- ./candran/can-parser/parser.lua:405
for _, iblock in ipairs(blocks) do -- ./candran/can-parser/parser.lua:408
if iblock["tag"] == "Block" then -- ./candran/can-parser/parser.lua:409
local oldLen = # iblock -- ./candran/can-parser/parser.lua:410
local newiBlock, newEnd = searchEndRec(iblock, true) -- ./candran/can-parser/parser.lua:411
if newiBlock then -- ./candran/can-parser/parser.lua:412
local p = i -- ./candran/can-parser/parser.lua:413
for j = newEnd + (# iblock - oldLen) + 1, # iblock, 1 do -- ./candran/can-parser/parser.lua:414
p = p + 1 -- ./candran/can-parser/parser.lua:415
table["insert"](block, p, iblock[j]) -- ./candran/can-parser/parser.lua:416
iblock[j] = nil -- ./candran/can-parser/parser.lua:417
end -- ./candran/can-parser/parser.lua:417
if not isRecCall then -- ./candran/can-parser/parser.lua:420
for j = p + 1, # block, 1 do -- ./candran/can-parser/parser.lua:421
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./candran/can-parser/parser.lua:422
end -- ./candran/can-parser/parser.lua:422
end -- ./candran/can-parser/parser.lua:422
return block, i -- ./candran/can-parser/parser.lua:426
end -- ./candran/can-parser/parser.lua:426
end -- ./candran/can-parser/parser.lua:426
end -- ./candran/can-parser/parser.lua:426
end -- ./candran/can-parser/parser.lua:426
end -- ./candran/can-parser/parser.lua:426
return nil -- ./candran/can-parser/parser.lua:432
end -- ./candran/can-parser/parser.lua:432
local function searchEnd(s, p, t) -- ./candran/can-parser/parser.lua:435
local r = searchEndRec(fixStructure(t)) -- ./candran/can-parser/parser.lua:436
if not r then -- ./candran/can-parser/parser.lua:437
return false -- ./candran/can-parser/parser.lua:438
end -- ./candran/can-parser/parser.lua:438
return true, r -- ./candran/can-parser/parser.lua:440
end -- ./candran/can-parser/parser.lua:440
local function expectBlockOrSingleStatWithStartEnd(start, startLabel, stopLabel, canFollow) -- ./candran/can-parser/parser.lua:443
if canFollow then -- ./candran/can-parser/parser.lua:444
return (- start * V("SingleStatBlock") * canFollow ^ - 1) + (expect(start, startLabel) * ((V("Block") * (canFollow + kw("end"))) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./candran/can-parser/parser.lua:447
else -- ./candran/can-parser/parser.lua:447
return (- start * V("SingleStatBlock")) + (expect(start, startLabel) * ((V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./candran/can-parser/parser.lua:451
end -- ./candran/can-parser/parser.lua:451
end -- ./candran/can-parser/parser.lua:451
local function expectBlockWithEnd(label) -- ./candran/can-parser/parser.lua:455
return (V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(label)) -- ./candran/can-parser/parser.lua:457
end -- ./candran/can-parser/parser.lua:457
local function maybeBlockWithEnd() -- ./candran/can-parser/parser.lua:460
return (V("BlockNoErr") * kw("end")) + Cmt(V("BlockNoErr"), searchEnd) -- ./candran/can-parser/parser.lua:462
end -- ./candran/can-parser/parser.lua:462
local function maybe(patt) -- ./candran/can-parser/parser.lua:465
return # patt / 0 * patt -- ./candran/can-parser/parser.lua:466
end -- ./candran/can-parser/parser.lua:466
local function setAttribute(attribute) -- ./candran/can-parser/parser.lua:469
return function(assign) -- ./candran/can-parser/parser.lua:470
assign[1]["tag"] = "AttributeNameList" -- ./candran/can-parser/parser.lua:471
for _, id in ipairs(assign[1]) do -- ./candran/can-parser/parser.lua:472
if id["tag"] == "Id" then -- ./candran/can-parser/parser.lua:473
id["tag"] = "AttributeId" -- ./candran/can-parser/parser.lua:474
id[2] = attribute -- ./candran/can-parser/parser.lua:475
elseif id["tag"] == "DestructuringId" then -- ./candran/can-parser/parser.lua:476
for _, did in ipairs(id) do -- ./candran/can-parser/parser.lua:477
did["tag"] = "AttributeId" -- ./candran/can-parser/parser.lua:478
did[2] = attribute -- ./candran/can-parser/parser.lua:479
end -- ./candran/can-parser/parser.lua:479
end -- ./candran/can-parser/parser.lua:479
end -- ./candran/can-parser/parser.lua:479
return assign -- ./candran/can-parser/parser.lua:483
end -- ./candran/can-parser/parser.lua:483
end -- ./candran/can-parser/parser.lua:483
local stacks = { ["lexpr"] = {} } -- ./candran/can-parser/parser.lua:488
local function push(f) -- ./candran/can-parser/parser.lua:490
return Cmt(P(""), function() -- ./candran/can-parser/parser.lua:491
table["insert"](stacks[f], true) -- ./candran/can-parser/parser.lua:492
return true -- ./candran/can-parser/parser.lua:493
end) -- ./candran/can-parser/parser.lua:493
end -- ./candran/can-parser/parser.lua:493
local function pop(f) -- ./candran/can-parser/parser.lua:496
return Cmt(P(""), function() -- ./candran/can-parser/parser.lua:497
table["remove"](stacks[f]) -- ./candran/can-parser/parser.lua:498
return true -- ./candran/can-parser/parser.lua:499
end) -- ./candran/can-parser/parser.lua:499
end -- ./candran/can-parser/parser.lua:499
local function when(f) -- ./candran/can-parser/parser.lua:502
return Cmt(P(""), function() -- ./candran/can-parser/parser.lua:503
return # stacks[f] > 0 -- ./candran/can-parser/parser.lua:504
end) -- ./candran/can-parser/parser.lua:504
end -- ./candran/can-parser/parser.lua:504
local function set(f, patt) -- ./candran/can-parser/parser.lua:507
return push(f) * patt * pop(f) -- ./candran/can-parser/parser.lua:508
end -- ./candran/can-parser/parser.lua:508
local G = { -- ./candran/can-parser/parser.lua:512
V("Lua"), -- ./candran/can-parser/parser.lua:512
["Lua"] = (V("Shebang") ^ - 1 * V("Skip") * V("Block") * expect(P(- 1), "Extra")) / fixStructure, -- ./candran/can-parser/parser.lua:513
["Shebang"] = P("#!") * (P(1) - P("\
")) ^ 0, -- ./candran/can-parser/parser.lua:514
["Block"] = tagC("Block", (V("Stat") + - V("BlockEnd") * throw("InvalidStat")) ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./candran/can-parser/parser.lua:516
["Stat"] = V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat") + V("LocalStat") + V("FuncStat") + V("BreakStat") + V("LabelStat") + V("GoToStat") + V("LetStat") + V("ConstStat") + V("CloseStat") + V("FuncCall") + V("Assignment") + V("ContinueStat") + V("PushStat") + sym(";"), -- ./candran/can-parser/parser.lua:522
["BlockEnd"] = P("return") + "end" + "elseif" + "else" + "until" + "]" + - 1 + V("ImplicitPushStat") + V("Assignment"), -- ./candran/can-parser/parser.lua:523
["SingleStatBlock"] = tagC("Block", V("Stat") + V("RetStat") + V("ImplicitPushStat")) / function(t) -- ./candran/can-parser/parser.lua:525
t["is_singlestatblock"] = true -- ./candran/can-parser/parser.lua:525
return t -- ./candran/can-parser/parser.lua:525
end, -- ./candran/can-parser/parser.lua:525
["BlockNoErr"] = tagC("Block", V("Stat") ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./candran/can-parser/parser.lua:526
["IfStat"] = tagC("If", V("IfPart")), -- ./candran/can-parser/parser.lua:528
["IfPart"] = kw("if") * set("lexpr", expect(V("Expr"), "ExprIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./candran/can-parser/parser.lua:529
["ElseIfPart"] = kw("elseif") * set("lexpr", expect(V("Expr"), "ExprEIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenEIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./candran/can-parser/parser.lua:530
["ElsePart"] = kw("else") * expectBlockWithEnd("EndIf"), -- ./candran/can-parser/parser.lua:531
["DoStat"] = kw("do") * expectBlockWithEnd("EndDo") / tagDo, -- ./candran/can-parser/parser.lua:533
["WhileStat"] = tagC("While", kw("while") * set("lexpr", expect(V("Expr"), "ExprWhile")) * V("WhileBody")), -- ./candran/can-parser/parser.lua:534
["WhileBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoWhile", "EndWhile"), -- ./candran/can-parser/parser.lua:535
["RepeatStat"] = tagC("Repeat", kw("repeat") * V("Block") * expect(kw("until"), "UntilRep") * expect(V("Expr"), "ExprRep")), -- ./candran/can-parser/parser.lua:536
["ForStat"] = kw("for") * expect(V("ForNum") + V("ForIn"), "ForRange"), -- ./candran/can-parser/parser.lua:538
["ForNum"] = tagC("Fornum", V("Id") * sym("=") * V("NumRange") * V("ForBody")), -- ./candran/can-parser/parser.lua:539
["NumRange"] = expect(V("Expr"), "ExprFor1") * expect(sym(","), "CommaFor") * expect(V("Expr"), "ExprFor2") * (sym(",") * expect(V("Expr"), "ExprFor3")) ^ - 1, -- ./candran/can-parser/parser.lua:541
["ForIn"] = tagC("Forin", V("DestructuringNameList") * expect(kw("in"), "InFor") * expect(V("ExprList"), "EListFor") * V("ForBody")), -- ./candran/can-parser/parser.lua:542
["ForBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoFor", "EndFor"), -- ./candran/can-parser/parser.lua:543
["LocalStat"] = kw("local") * expect(V("LocalFunc") + V("LocalAssign"), "DefLocal"), -- ./candran/can-parser/parser.lua:545
["LocalFunc"] = tagC("Localrec", kw("function") * expect(V("Id"), "NameLFunc") * V("FuncBody")) / fixFuncStat, -- ./candran/can-parser/parser.lua:546
["LocalAssign"] = tagC("Local", V("AttributeNameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Local", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./candran/can-parser/parser.lua:548
["LetStat"] = kw("let") * expect(V("LetAssign"), "DefLet"), -- ./candran/can-parser/parser.lua:550
["LetAssign"] = tagC("Let", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Let", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./candran/can-parser/parser.lua:552
["ConstStat"] = kw("const") * expect(V("AttributeAssign") / setAttribute("const"), "DefConst"), -- ./candran/can-parser/parser.lua:554
["CloseStat"] = kw("close") * expect(V("AttributeAssign") / setAttribute("close"), "DefClose"), -- ./candran/can-parser/parser.lua:555
["AttributeAssign"] = tagC("Local", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Local", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./candran/can-parser/parser.lua:557
["Assignment"] = tagC("Set", (V("VarList") + V("DestructuringNameList")) * V("BinOp") ^ - 1 * (P("=") / "=") * ((V("BinOp") - P("-")) + # (P("-") * V("Space")) * V("BinOp")) ^ - 1 * V("Skip") * expect(V("ExprList"), "EListAssign")), -- ./candran/can-parser/parser.lua:559
["FuncStat"] = tagC("Set", kw("function") * expect(V("FuncName"), "FuncName") * V("FuncBody")) / fixFuncStat, -- ./candran/can-parser/parser.lua:561
["FuncName"] = Cf(V("Id") * (sym(".") * expect(V("StrId"), "NameFunc1")) ^ 0, insertIndex) * (sym(":") * expect(V("StrId"), "NameFunc2")) ^ - 1 / markMethod, -- ./candran/can-parser/parser.lua:563
["FuncBody"] = tagC("Function", V("FuncParams") * expectBlockWithEnd("EndFunc")), -- ./candran/can-parser/parser.lua:564
["FuncParams"] = expect(sym("("), "OParenPList") * V("ParList") * expect(sym(")"), "CParenPList"), -- ./candran/can-parser/parser.lua:565
["ParList"] = V("NamedParList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()), -- ./candran/can-parser/parser.lua:568
["ShortFuncDef"] = tagC("Function", V("ShortFuncParams") * maybeBlockWithEnd()) / fixShortFunc, -- ./candran/can-parser/parser.lua:570
["ShortFuncParams"] = (sym(":") / ":") ^ - 1 * sym("(") * V("ParList") * sym(")"), -- ./candran/can-parser/parser.lua:571
["NamedParList"] = tagC("NamedParList", commaSep(V("NamedPar"))), -- ./candran/can-parser/parser.lua:573
["NamedPar"] = tagC("ParPair", V("ParKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Id"), -- ./candran/can-parser/parser.lua:575
["ParKey"] = V("Id") * # ("=" * - P("=")), -- ./candran/can-parser/parser.lua:576
["LabelStat"] = tagC("Label", sym("::") * expect(V("Name"), "Label") * expect(sym("::"), "CloseLabel")), -- ./candran/can-parser/parser.lua:578
["GoToStat"] = tagC("Goto", kw("goto") * expect(V("Name"), "Goto")), -- ./candran/can-parser/parser.lua:579
["BreakStat"] = tagC("Break", kw("break")), -- ./candran/can-parser/parser.lua:580
["ContinueStat"] = tagC("Continue", kw("continue")), -- ./candran/can-parser/parser.lua:581
["RetStat"] = tagC("Return", kw("return") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./candran/can-parser/parser.lua:582
["PushStat"] = tagC("Push", kw("push") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./candran/can-parser/parser.lua:584
["ImplicitPushStat"] = tagC("Push", commaSep(V("Expr"), "RetList")) / markImplicit, -- ./candran/can-parser/parser.lua:585
["NameList"] = tagC("NameList", commaSep(V("Id"))), -- ./candran/can-parser/parser.lua:587
["DestructuringNameList"] = tagC("NameList", commaSep(V("DestructuringId"))), -- ./candran/can-parser/parser.lua:588
["AttributeNameList"] = tagC("AttributeNameList", commaSep(V("AttributeId"))), -- ./candran/can-parser/parser.lua:589
["VarList"] = tagC("VarList", commaSep(V("VarExpr"))), -- ./candran/can-parser/parser.lua:590
["ExprList"] = tagC("ExpList", commaSep(V("Expr"), "ExprList")), -- ./candran/can-parser/parser.lua:591
["DestructuringId"] = tagC("DestructuringId", sym("{") * V("DestructuringIdFieldList") * expect(sym("}"), "CBraceDestructuring")) + V("Id"), -- ./candran/can-parser/parser.lua:593
["DestructuringIdFieldList"] = sepBy(V("DestructuringIdField"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./candran/can-parser/parser.lua:594
["DestructuringIdField"] = tagC("Pair", V("FieldKey") * expect(sym("="), "DestructuringEqField") * expect(V("Id"), "DestructuringExprField")) + V("Id"), -- ./candran/can-parser/parser.lua:596
["Expr"] = V("OrExpr"), -- ./candran/can-parser/parser.lua:598
["OrExpr"] = chainOp(V("AndExpr"), V("OrOp"), "OrExpr"), -- ./candran/can-parser/parser.lua:599
["AndExpr"] = chainOp(V("RelExpr"), V("AndOp"), "AndExpr"), -- ./candran/can-parser/parser.lua:600
["RelExpr"] = chainOp(V("BOrExpr"), V("RelOp"), "RelExpr"), -- ./candran/can-parser/parser.lua:601
["BOrExpr"] = chainOp(V("BXorExpr"), V("BOrOp"), "BOrExpr"), -- ./candran/can-parser/parser.lua:602
["BXorExpr"] = chainOp(V("BAndExpr"), V("BXorOp"), "BXorExpr"), -- ./candran/can-parser/parser.lua:603
["BAndExpr"] = chainOp(V("ShiftExpr"), V("BAndOp"), "BAndExpr"), -- ./candran/can-parser/parser.lua:604
["ShiftExpr"] = chainOp(V("ConcatExpr"), V("ShiftOp"), "ShiftExpr"), -- ./candran/can-parser/parser.lua:605
["ConcatExpr"] = V("AddExpr") * (V("ConcatOp") * expect(V("ConcatExpr"), "ConcatExpr")) ^ - 1 / binaryOp, -- ./candran/can-parser/parser.lua:606
["AddExpr"] = chainOp(V("MulExpr"), V("AddOp"), "AddExpr"), -- ./candran/can-parser/parser.lua:607
["MulExpr"] = chainOp(V("UnaryExpr"), V("MulOp"), "MulExpr"), -- ./candran/can-parser/parser.lua:608
["UnaryExpr"] = V("UnaryOp") * expect(V("UnaryExpr"), "UnaryExpr") / unaryOp + V("PowExpr"), -- ./candran/can-parser/parser.lua:610
["PowExpr"] = V("SimpleExpr") * (V("PowOp") * expect(V("UnaryExpr"), "PowExpr")) ^ - 1 / binaryOp, -- ./candran/can-parser/parser.lua:611
["SimpleExpr"] = tagC("Number", V("Number")) + tagC("Nil", kw("nil")) + tagC("Boolean", kw("false") * Cc(false)) + tagC("Boolean", kw("true") * Cc(true)) + tagC("Dots", sym("...")) + V("FuncDef") + (when("lexpr") * tagC("LetExpr", maybe(V("DestructuringNameList")) * sym("=") * - sym("=") * expect(V("ExprList"), "EListLAssign"))) + V("ShortFuncDef") + V("SuffixedExpr") + V("StatExpr"), -- ./candran/can-parser/parser.lua:621
["StatExpr"] = (V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat")) / statToExpr, -- ./candran/can-parser/parser.lua:623
["FuncCall"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./candran/can-parser/parser.lua:625
return exp["tag"] == "Call" or exp["tag"] == "SafeCall", exp -- ./candran/can-parser/parser.lua:625
end), -- ./candran/can-parser/parser.lua:625
["VarExpr"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./candran/can-parser/parser.lua:626
return exp["tag"] == "Id" or exp["tag"] == "Index", exp -- ./candran/can-parser/parser.lua:626
end), -- ./candran/can-parser/parser.lua:626
["SuffixedExpr"] = Cf(V("PrimaryExpr") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr") * - V("Call") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr"), makeSuffixedExpr), -- ./candran/can-parser/parser.lua:630
["PrimaryExpr"] = V("SelfId") * (V("SelfCall") + V("SelfIndex")) + V("Id") + tagC("Paren", sym("(") * expect(V("Expr"), "ExprParen") * expect(sym(")"), "CParenExpr")), -- ./candran/can-parser/parser.lua:633
["NoCallPrimaryExpr"] = tagC("String", V("String")) + V("Table") + V("TableCompr"), -- ./candran/can-parser/parser.lua:634
["Index"] = tagC("DotIndex", sym("." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("ArrayIndex", sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")) + tagC("SafeDotIndex", sym("?." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("SafeArrayIndex", sym("?[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")), -- ./candran/can-parser/parser.lua:638
["MethodStub"] = tagC("MethodStub", sym(":" * - P(":")) * expect(V("StrId"), "NameMeth")) + tagC("SafeMethodStub", sym("?:" * - P(":")) * expect(V("StrId"), "NameMeth")), -- ./candran/can-parser/parser.lua:640
["Call"] = tagC("Call", V("FuncArgs")) + tagC("SafeCall", P("?") * V("FuncArgs")), -- ./candran/can-parser/parser.lua:642
["SelfCall"] = tagC("MethodStub", V("StrId")) * V("Call"), -- ./candran/can-parser/parser.lua:643
["SelfIndex"] = tagC("DotIndex", V("StrId")), -- ./candran/can-parser/parser.lua:644
["FuncDef"] = (kw("function") * V("FuncBody")), -- ./candran/can-parser/parser.lua:646
["FuncArgs"] = sym("(") * commaSep(V("Expr"), "ArgList") ^ - 1 * expect(sym(")"), "CParenArgs") + V("Table") + tagC("String", V("String")), -- ./candran/can-parser/parser.lua:649
["Table"] = tagC("Table", sym("{") * V("FieldList") ^ - 1 * expect(sym("}"), "CBraceTable")), -- ./candran/can-parser/parser.lua:651
["FieldList"] = sepBy(V("Field"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./candran/can-parser/parser.lua:652
["Field"] = tagC("Pair", V("FieldKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Expr"), -- ./candran/can-parser/parser.lua:654
["FieldKey"] = sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprFKey") * expect(sym("]"), "CBracketFKey") + V("StrId") * # ("=" * - P("=")), -- ./candran/can-parser/parser.lua:656
["FieldSep"] = sym(",") + sym(";"), -- ./candran/can-parser/parser.lua:657
["TableCompr"] = tagC("TableCompr", sym("[") * V("Block") * expect(sym("]"), "CBracketTableCompr")), -- ./candran/can-parser/parser.lua:659
["SelfId"] = tagC("Id", sym("@") / "self"), -- ./candran/can-parser/parser.lua:661
["Id"] = tagC("Id", V("Name")) + V("SelfId"), -- ./candran/can-parser/parser.lua:662
["AttributeSelfId"] = tagC("AttributeId", sym("@") / "self" * V("Attribute") ^ - 1), -- ./candran/can-parser/parser.lua:663
["AttributeId"] = tagC("AttributeId", V("Name") * V("Attribute") ^ - 1) + V("AttributeSelfId"), -- ./candran/can-parser/parser.lua:664
["StrId"] = tagC("String", V("Name")), -- ./candran/can-parser/parser.lua:665
["Attribute"] = sym("<") * expect(kw("const") / "const" + kw("close") / "close", "UnknownAttribute") * expect(sym(">"), "CBracketAttribute"), -- ./candran/can-parser/parser.lua:667
["Skip"] = (V("Space") + V("Comment")) ^ 0, -- ./candran/can-parser/parser.lua:670
["Space"] = space ^ 1, -- ./candran/can-parser/parser.lua:671
["Comment"] = P("--") * V("LongStr") / function() -- ./candran/can-parser/parser.lua:672
return  -- ./candran/can-parser/parser.lua:672
end + P("--") * (P(1) - P("\
")) ^ 0, -- ./candran/can-parser/parser.lua:673
["Name"] = token(- V("Reserved") * C(V("Ident"))), -- ./candran/can-parser/parser.lua:675
["Reserved"] = V("Keywords") * - V("IdRest"), -- ./candran/can-parser/parser.lua:676
["Keywords"] = P("and") + "break" + "do" + "elseif" + "else" + "end" + "false" + "for" + "function" + "goto" + "if" + "in" + "local" + "nil" + "not" + "or" + "repeat" + "return" + "then" + "true" + "until" + "while", -- ./candran/can-parser/parser.lua:680
["Ident"] = V("IdStart") * V("IdRest") ^ 0, -- ./candran/can-parser/parser.lua:681
["IdStart"] = alpha + P("_"), -- ./candran/can-parser/parser.lua:682
["IdRest"] = alnum + P("_"), -- ./candran/can-parser/parser.lua:683
["Number"] = token(C(V("Hex") + V("Float") + V("Int"))), -- ./candran/can-parser/parser.lua:685
["Hex"] = (P("0x") + "0X") * ((xdigit ^ 0 * V("DeciHex")) + (expect(xdigit ^ 1, "DigitHex") * V("DeciHex") ^ - 1)) * V("ExpoHex") ^ - 1, -- ./candran/can-parser/parser.lua:686
["Float"] = V("Decimal") * V("Expo") ^ - 1 + V("Int") * V("Expo"), -- ./candran/can-parser/parser.lua:688
["Decimal"] = digit ^ 1 * "." * digit ^ 0 + P(".") * - P(".") * expect(digit ^ 1, "DigitDeci"), -- ./candran/can-parser/parser.lua:690
["DeciHex"] = P(".") * xdigit ^ 0, -- ./candran/can-parser/parser.lua:691
["Expo"] = S("eE") * S("+-") ^ - 1 * expect(digit ^ 1, "DigitExpo"), -- ./candran/can-parser/parser.lua:692
["ExpoHex"] = S("pP") * S("+-") ^ - 1 * expect(xdigit ^ 1, "DigitExpo"), -- ./candran/can-parser/parser.lua:693
["Int"] = digit ^ 1, -- ./candran/can-parser/parser.lua:694
["String"] = token(V("ShortStr") + V("LongStr")), -- ./candran/can-parser/parser.lua:696
["ShortStr"] = P("\"") * Cs((V("EscSeq") + (P(1) - S("\"\
"))) ^ 0) * expect(P("\""), "Quote") + P("'") * Cs((V("EscSeq") + (P(1) - S("'\
"))) ^ 0) * expect(P("'"), "Quote"), -- ./candran/can-parser/parser.lua:698
["EscSeq"] = P("\\") / "" * (P("a") / "\7" + P("b") / "\8" + P("f") / "\12" + P("n") / "\
" + P("r") / "\13" + P("t") / "\9" + P("v") / "\11" + P("\
") / "\
" + P("\13") / "\
" + P("\\") / "\\" + P("\"") / "\"" + P("'") / "'" + P("z") * space ^ 0 / "" + digit * digit ^ - 2 / tonumber / string["char"] + P("x") * expect(C(xdigit * xdigit), "HexEsc") * Cc(16) / tonumber / string["char"] + P("u") * expect("{", "OBraceUEsc") * expect(C(xdigit ^ 1), "DigitUEsc") * Cc(16) * expect("}", "CBraceUEsc") / tonumber / (utf8 and utf8["char"] or string["char"]) + throw("EscSeq")), -- ./candran/can-parser/parser.lua:728
["LongStr"] = V("Open") * C((P(1) - V("CloseEq")) ^ 0) * expect(V("Close"), "CloseLStr") / function(s, eqs) -- ./candran/can-parser/parser.lua:731
return s -- ./candran/can-parser/parser.lua:731
end, -- ./candran/can-parser/parser.lua:731
["Open"] = "[" * Cg(V("Equals"), "openEq") * "[" * P("\
") ^ - 1, -- ./candran/can-parser/parser.lua:732
["Close"] = "]" * C(V("Equals")) * "]", -- ./candran/can-parser/parser.lua:733
["Equals"] = P("=") ^ 0, -- ./candran/can-parser/parser.lua:734
["CloseEq"] = Cmt(V("Close") * Cb("openEq"), function(s, i, closeEq, openEq) -- ./candran/can-parser/parser.lua:735
return # openEq == # closeEq -- ./candran/can-parser/parser.lua:735
end), -- ./candran/can-parser/parser.lua:735
["OrOp"] = kw("or") / "or", -- ./candran/can-parser/parser.lua:737
["AndOp"] = kw("and") / "and", -- ./candran/can-parser/parser.lua:738
["RelOp"] = sym("~=") / "ne" + sym("==") / "eq" + sym("<=") / "le" + sym(">=") / "ge" + sym("<") / "lt" + sym(">") / "gt", -- ./candran/can-parser/parser.lua:744
["BOrOp"] = sym("|") / "bor", -- ./candran/can-parser/parser.lua:745
["BXorOp"] = sym("~" * - P("=")) / "bxor", -- ./candran/can-parser/parser.lua:746
["BAndOp"] = sym("&") / "band", -- ./candran/can-parser/parser.lua:747
["ShiftOp"] = sym("<<") / "shl" + sym(">>") / "shr", -- ./candran/can-parser/parser.lua:749
["ConcatOp"] = sym("..") / "concat", -- ./candran/can-parser/parser.lua:750
["AddOp"] = sym("+") / "add" + sym("-") / "sub", -- ./candran/can-parser/parser.lua:752
["MulOp"] = sym("*") / "mul" + sym("//") / "idiv" + sym("/") / "div" + sym("%") / "mod", -- ./candran/can-parser/parser.lua:756
["UnaryOp"] = kw("not") / "not" + sym("-") / "unm" + sym("#") / "len" + sym("~") / "bnot", -- ./candran/can-parser/parser.lua:760
["PowOp"] = sym("^") / "pow", -- ./candran/can-parser/parser.lua:761
["BinOp"] = V("OrOp") + V("AndOp") + V("BOrOp") + V("BXorOp") + V("BAndOp") + V("ShiftOp") + V("ConcatOp") + V("AddOp") + V("MulOp") + V("PowOp") -- ./candran/can-parser/parser.lua:762
} -- ./candran/can-parser/parser.lua:762
local macroidentifier = { -- ./candran/can-parser/parser.lua:766
expect(V("MacroIdentifier"), "InvalidStat") * expect(P(- 1), "Extra"), -- ./candran/can-parser/parser.lua:767
["MacroIdentifier"] = tagC("MacroFunction", V("Id") * sym("(") * V("MacroFunctionArgs") * expect(sym(")"), "CParenPList")) + V("Id"), -- ./candran/can-parser/parser.lua:770
["MacroFunctionArgs"] = V("NameList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()) -- ./candran/can-parser/parser.lua:774
} -- ./candran/can-parser/parser.lua:774
for k, v in pairs(G) do -- ./candran/can-parser/parser.lua:777
if macroidentifier[k] == nil then -- ./candran/can-parser/parser.lua:777
macroidentifier[k] = v -- ./candran/can-parser/parser.lua:777
end -- ./candran/can-parser/parser.lua:777
end -- ./candran/can-parser/parser.lua:777
local parser = {} -- ./candran/can-parser/parser.lua:779
local validator = require("candran.can-parser.validator") -- ./candran/can-parser/parser.lua:781
local validate = validator["validate"] -- ./candran/can-parser/parser.lua:782
local syntaxerror = validator["syntaxerror"] -- ./candran/can-parser/parser.lua:783
parser["parse"] = function(subject, filename) -- ./candran/can-parser/parser.lua:785
local errorinfo = { -- ./candran/can-parser/parser.lua:786
["subject"] = subject, -- ./candran/can-parser/parser.lua:786
["filename"] = filename -- ./candran/can-parser/parser.lua:786
} -- ./candran/can-parser/parser.lua:786
lpeg["setmaxstack"](1000) -- ./candran/can-parser/parser.lua:787
local ast, label, errpos = lpeg["match"](G, subject, nil, errorinfo) -- ./candran/can-parser/parser.lua:788
if not ast then -- ./candran/can-parser/parser.lua:789
local errmsg = labels[label][2] -- ./candran/can-parser/parser.lua:790
return ast, syntaxerror(errorinfo, errpos, errmsg) -- ./candran/can-parser/parser.lua:791
end -- ./candran/can-parser/parser.lua:791
return validate(ast, errorinfo) -- ./candran/can-parser/parser.lua:793
end -- ./candran/can-parser/parser.lua:793
parser["parsemacroidentifier"] = function(subject, filename) -- ./candran/can-parser/parser.lua:796
local errorinfo = { -- ./candran/can-parser/parser.lua:797
["subject"] = subject, -- ./candran/can-parser/parser.lua:797
["filename"] = filename -- ./candran/can-parser/parser.lua:797
} -- ./candran/can-parser/parser.lua:797
lpeg["setmaxstack"](1000) -- ./candran/can-parser/parser.lua:798
local ast, label, errpos = lpeg["match"](macroidentifier, subject, nil, errorinfo) -- ./candran/can-parser/parser.lua:799
if not ast then -- ./candran/can-parser/parser.lua:800
local errmsg = labels[label][2] -- ./candran/can-parser/parser.lua:801
return ast, syntaxerror(errorinfo, errpos, errmsg) -- ./candran/can-parser/parser.lua:802
end -- ./candran/can-parser/parser.lua:802
return ast -- ./candran/can-parser/parser.lua:804
end -- ./candran/can-parser/parser.lua:804
return parser -- ./candran/can-parser/parser.lua:807
end -- ./candran/can-parser/parser.lua:807
local parser = _() or parser -- ./candran/can-parser/parser.lua:811
package["loaded"]["candran.can-parser.parser"] = parser or true -- ./candran/can-parser/parser.lua:812
local unpack = unpack or table["unpack"] -- candran.can:16
local candran = { ["VERSION"] = "0.14.0" } -- candran.can:19
package["loaded"]["candran"] = candran -- candran.can:21
candran["default"] = { -- candran.can:24
["target"] = "lua54", -- candran.can:25
["indentation"] = "", -- candran.can:26
["newline"] = "\
", -- candran.can:27
["variablePrefix"] = "__CAN_", -- candran.can:28
["mapLines"] = true, -- candran.can:29
["chunkname"] = "nil", -- candran.can:30
["rewriteErrors"] = true, -- candran.can:31
["noBuiltInMacros"] = false -- candran.can:32
} -- candran.can:32
if _VERSION == "Lua 5.1" then -- candran.can:36
if package["loaded"]["jit"] then -- candran.can:37
candran["default"]["target"] = "luajit" -- candran.can:38
else -- candran.can:38
candran["default"]["target"] = "lua51" -- candran.can:40
end -- candran.can:40
elseif _VERSION == "Lua 5.2" then -- candran.can:42
candran["default"]["target"] = "lua52" -- candran.can:43
elseif _VERSION == "Lua 5.3" then -- candran.can:44
candran["default"]["target"] = "lua53" -- candran.can:45
end -- candran.can:45
candran["preprocess"] = function(input, options) -- candran.can:55
if options == nil then options = {} end -- candran.can:55
options = util["merge"](candran["default"], options) -- candran.can:56
local macros = { -- candran.can:57
["functions"] = {}, -- candran.can:58
["variables"] = {} -- candran.can:59
} -- candran.can:59
local preprocessor = "" -- candran.can:63
local i = 0 -- candran.can:64
local inLongString = false -- candran.can:65
local inComment = false -- candran.can:66
for line in (input .. "\
"):gmatch("(.-\
)") do -- candran.can:67
i = i + (1) -- candran.can:68
if inComment then -- candran.can:70
inComment = not line:match("%]%]") -- candran.can:71
elseif inLongString then -- candran.can:72
inLongString = not line:match("%]%]") -- candran.can:73
else -- candran.can:73
if line:match("[^%-]%[%[") then -- candran.can:75
inLongString = true -- candran.can:76
elseif line:match("%-%-%[%[") then -- candran.can:77
inComment = true -- candran.can:78
end -- candran.can:78
end -- candran.can:78
if not inComment and not inLongString and line:match("^%s*#") and not line:match("^#!") then -- candran.can:81
preprocessor = preprocessor .. (line:gsub("^%s*#", "")) -- candran.can:82
else -- candran.can:82
local l = line:sub(1, - 2) -- candran.can:84
if not inLongString and options["mapLines"] and not l:match("%-%- (.-)%:(%d+)$") then -- candran.can:85
preprocessor = preprocessor .. (("write(%q)"):format(l .. " -- " .. options["chunkname"] .. ":" .. i) .. "\
") -- candran.can:86
else -- candran.can:86
preprocessor = preprocessor .. (("write(%q)"):format(line:sub(1, - 2)) .. "\
") -- candran.can:88
end -- candran.can:88
end -- candran.can:88
end -- candran.can:88
preprocessor = preprocessor .. ("return output") -- candran.can:92
local env = util["merge"](_G, options) -- candran.can:95
env["candran"] = candran -- candran.can:97
env["output"] = "" -- candran.can:99
env["import"] = function(modpath, margs) -- candran.can:106
if margs == nil then margs = {} end -- candran.can:106
local filepath = assert(util["search"](modpath, { -- candran.can:107
"can", -- candran.can:107
"lua" -- candran.can:107
}), "No module named \"" .. modpath .. "\"") -- candran.can:107
local f = io["open"](filepath) -- candran.can:110
if not f then -- candran.can:111
error("can't open the module file to import") -- candran.can:111
end -- candran.can:111
margs = util["merge"](options, { -- candran.can:113
["chunkname"] = filepath, -- candran.can:113
["loadLocal"] = true, -- candran.can:113
["loadPackage"] = true -- candran.can:113
}, margs) -- candran.can:113
local modcontent, modmacros = assert(candran["preprocess"](f:read("*a"), margs)) -- candran.can:114
macros = util["recmerge"](macros, modmacros) -- candran.can:115
f:close() -- candran.can:116
local modname = modpath:match("[^%.]+$") -- candran.can:119
env["write"]("-- MODULE " .. modpath .. " --\
" .. "local function _()\
" .. modcontent .. "\
" .. "end\
" .. (margs["loadLocal"] and ("local %s = _() or %s\
"):format(modname, modname) or "") .. (margs["loadPackage"] and ("package.loaded[%q] = %s or true\
"):format(modpath, margs["loadLocal"] and modname or "_()") or "") .. "-- END OF MODULE " .. modpath .. " --") -- candran.can:128
end -- candran.can:128
env["include"] = function(file) -- candran.can:133
local f = io["open"](file) -- candran.can:134
if not f then -- candran.can:135
error("can't open the file " .. file .. " to include") -- candran.can:135
end -- candran.can:135
env["write"](f:read("*a")) -- candran.can:136
f:close() -- candran.can:137
end -- candran.can:137
env["write"] = function(...) -- candran.can:141
env["output"] = env["output"] .. (table["concat"]({ ... }, "\9") .. "\
") -- candran.can:142
end -- candran.can:142
env["placeholder"] = function(name) -- candran.can:146
if env[name] then -- candran.can:147
env["write"](env[name]) -- candran.can:148
end -- candran.can:148
end -- candran.can:148
env["define"] = function(identifier, replacement) -- candran.can:151
local iast, ierr = parser["parsemacroidentifier"](identifier, options["chunkname"]) -- candran.can:153
if not iast then -- candran.can:154
return error(("in macro identifier: %s"):format(tostring(ierr))) -- candran.can:155
end -- candran.can:155
if type(replacement) == "string" then -- candran.can:158
local rast, rerr = parser["parse"](replacement, options["chunkname"]) -- candran.can:159
if not rast then -- candran.can:160
return error(("in macro replacement: %s"):format(tostring(rerr))) -- candran.can:161
end -- candran.can:161
if # rast == 1 and rast[1]["tag"] == "Push" and rast[1]["implicit"] then -- candran.can:164
rast = rast[1][1] -- candran.can:165
end -- candran.can:165
replacement = rast -- candran.can:167
elseif type(replacement) ~= "function" then -- candran.can:168
error("bad argument #2 to 'define' (string or function expected)") -- candran.can:169
end -- candran.can:169
if iast["tag"] == "MacroFunction" then -- candran.can:172
macros["functions"][iast[1][1]] = { -- candran.can:173
["args"] = iast[2], -- candran.can:173
["replacement"] = replacement -- candran.can:173
} -- candran.can:173
elseif iast["tag"] == "Id" then -- candran.can:174
macros["variables"][iast[1]] = replacement -- candran.can:175
else -- candran.can:175
error(("invalid macro type %s"):format(tostring(iast["tag"]))) -- candran.can:177
end -- candran.can:177
end -- candran.can:177
if not options["noBuiltInMacros"] then -- candran.can:182
env["define"]("__STR__(x)", function(x) -- candran.can:183
return ("%q"):format(x) -- candran.can:183
end) -- candran.can:183
local s = require("candran.serpent") -- candran.can:184
env["define"]("__CONSTEXPR__(expr)", function(expr) -- candran.can:185
return s["block"](assert(candran["load"](expr))(), { ["fatal"] = true }) -- candran.can:186
end) -- candran.can:186
end -- candran.can:186
local preprocess, err = candran["compile"](preprocessor, options) -- candran.can:191
if not preprocess then -- candran.can:192
return nil, "in preprocessor: " .. err -- candran.can:193
end -- candran.can:193
preprocess, err = util["load"](preprocessor, "candran preprocessor", env) -- candran.can:196
if not preprocess then -- candran.can:197
return nil, "in preprocessor: " .. err -- candran.can:198
end -- candran.can:198
local success, output = pcall(preprocess) -- candran.can:202
if not success then -- candran.can:203
return nil, "in preprocessor: " .. output -- candran.can:204
end -- candran.can:204
return output, macros -- candran.can:207
end -- candran.can:207
candran["compile"] = function(input, options, macros) -- candran.can:217
if options == nil then options = {} end -- candran.can:217
options = util["merge"](candran["default"], options) -- candran.can:218
local ast, errmsg = parser["parse"](input, options["chunkname"]) -- candran.can:220
if not ast then -- candran.can:222
return nil, errmsg -- candran.can:223
end -- candran.can:223
return require("compiler." .. options["target"])(input, ast, options, macros) -- candran.can:226
end -- candran.can:226
candran["make"] = function(code, options) -- candran.can:235
local r, err = candran["preprocess"](code, options) -- candran.can:236
if r then -- candran.can:237
r, err = candran["compile"](r, options, err) -- candran.can:238
if r then -- candran.can:239
return r -- candran.can:240
end -- candran.can:240
end -- candran.can:240
return r, err -- candran.can:243
end -- candran.can:243
local errorRewritingActive = false -- candran.can:246
local codeCache = {} -- candran.can:247
candran["loadfile"] = function(filepath, env, options) -- candran.can:250
local f, err = io["open"](filepath) -- candran.can:251
if not f then -- candran.can:252
return nil, ("cannot open %s"):format(tostring(err)) -- candran.can:253
end -- candran.can:253
local content = f:read("*a") -- candran.can:255
f:close() -- candran.can:256
return candran["load"](content, filepath, env, options) -- candran.can:258
end -- candran.can:258
candran["load"] = function(chunk, chunkname, env, options) -- candran.can:263
if options == nil then options = {} end -- candran.can:263
options = util["merge"]({ ["chunkname"] = tostring(chunkname or chunk) }, options) -- candran.can:264
local code, err = candran["make"](chunk, options) -- candran.can:266
if not code then -- candran.can:267
return code, err -- candran.can:268
end -- candran.can:268
codeCache[options["chunkname"]] = code -- candran.can:271
local f -- candran.can:272
f, err = util["load"](code, ("=%s(%s)"):format(options["chunkname"], "compiled candran"), env) -- candran.can:273
if f == nil then -- candran.can:278
return f, "candran unexpectedly generated invalid code: " .. err -- candran.can:279
end -- candran.can:279
if options["rewriteErrors"] == false then -- candran.can:282
return f -- candran.can:283
else -- candran.can:283
return function(...) -- candran.can:285
if not errorRewritingActive then -- candran.can:286
errorRewritingActive = true -- candran.can:287
local t = { xpcall(f, candran["messageHandler"], ...) } -- candran.can:288
errorRewritingActive = false -- candran.can:289
if t[1] == false then -- candran.can:290
error(t[2], 0) -- candran.can:291
end -- candran.can:291
return unpack(t, 2) -- candran.can:293
else -- candran.can:293
return f(...) -- candran.can:295
end -- candran.can:295
end -- candran.can:295
end -- candran.can:295
end -- candran.can:295
candran["dofile"] = function(filename, options) -- candran.can:303
local f, err = candran["loadfile"](filename, nil, options) -- candran.can:304
if f == nil then -- candran.can:306
error(err) -- candran.can:307
else -- candran.can:307
return f() -- candran.can:309
end -- candran.can:309
end -- candran.can:309
candran["messageHandler"] = function(message, noTraceback) -- candran.can:315
if not noTraceback and not message:match("\
stack traceback:\
") then -- candran.can:316
message = debug["traceback"](message, 2) -- candran.can:317
end -- candran.can:317
return message:gsub("(\
?%s*)([^\
]-)%:(%d+)%:", function(indentation, source, line) -- candran.can:319
line = tonumber(line) -- candran.can:320
local originalFile -- candran.can:322
local strName = source:match("^(.-)%(compiled candran%)$") -- candran.can:323
if strName then -- candran.can:324
if codeCache[strName] then -- candran.can:325
originalFile = codeCache[strName] -- candran.can:326
source = strName -- candran.can:327
end -- candran.can:327
else -- candran.can:327
do -- candran.can:330
local fi -- candran.can:330
fi = io["open"](source, "r") -- candran.can:330
if fi then -- candran.can:330
originalFile = fi:read("*a") -- candran.can:331
fi:close() -- candran.can:332
end -- candran.can:332
end -- candran.can:332
end -- candran.can:332
if originalFile then -- candran.can:336
local i = 0 -- candran.can:337
for l in (originalFile .. "\
"):gmatch("([^\
]*)\
") do -- candran.can:338
i = i + 1 -- candran.can:339
if i == line then -- candran.can:340
local extSource, lineMap = l:match(".*%-%- (.-)%:(%d+)$") -- candran.can:341
if lineMap then -- candran.can:342
if extSource ~= source then -- candran.can:343
return indentation .. extSource .. ":" .. lineMap .. "(" .. extSource .. ":" .. line .. "):" -- candran.can:344
else -- candran.can:344
return indentation .. extSource .. ":" .. lineMap .. "(" .. line .. "):" -- candran.can:346
end -- candran.can:346
end -- candran.can:346
break -- candran.can:349
end -- candran.can:349
end -- candran.can:349
end -- candran.can:349
end) -- candran.can:349
end -- candran.can:349
candran["searcher"] = function(modpath) -- candran.can:357
local filepath = util["search"](modpath, { "can" }) -- candran.can:358
if not filepath then -- candran.can:359
if _VERSION == "Lua 5.4" then -- candran.can:360
return "no candran file in package.path" -- candran.can:361
else -- candran.can:361
return "\
\9no candran file in package.path" -- candran.can:363
end -- candran.can:363
end -- candran.can:363
return function(modpath) -- candran.can:366
local r, s = candran["loadfile"](filepath) -- candran.can:367
if r then -- candran.can:368
return r(modpath, filepath) -- candran.can:369
else -- candran.can:369
error(("error loading candran module '%s' from file '%s':\
\9%s"):format(modpath, filepath, tostring(s)), 0) -- candran.can:371
end -- candran.can:371
end, filepath -- candran.can:373
end -- candran.can:373
candran["setup"] = function() -- candran.can:377
local searchers = (function() -- candran.can:378
if _VERSION == "Lua 5.1" then -- candran.can:378
return package["loaders"] -- candran.can:379
else -- candran.can:379
return package["searchers"] -- candran.can:381
end -- candran.can:381
end)() -- candran.can:381
for _, s in ipairs(searchers) do -- candran.can:384
if s == candran["searcher"] then -- candran.can:385
return candran -- candran.can:386
end -- candran.can:386
end -- candran.can:386
table["insert"](searchers, 1, candran["searcher"]) -- candran.can:390
return candran -- candran.can:391
end -- candran.can:391
return candran -- candran.can:394
