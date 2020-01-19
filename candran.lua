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
util["merge"] = function(...) -- ./candran/util.can:30
local r = {} -- ./candran/util.can:31
for _, t in ipairs({ ... }) do -- ./candran/util.can:32
for k, v in pairs(t) do -- ./candran/util.can:33
r[k] = v -- ./candran/util.can:34
end -- ./candran/util.can:34
end -- ./candran/util.can:34
return r -- ./candran/util.can:37
end -- ./candran/util.can:37
return util -- ./candran/util.can:40
end -- ./candran/util.can:40
local util = _() or util -- ./candran/util.can:44
package["loaded"]["candran.util"] = util or true -- ./candran/util.can:45
local function _() -- ./candran/util.can:48
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
local function _() -- ./candran/cmdline.lua:135
local targetName = "Lua 5.3" -- ./compiler/lua53.can:1
return function(code, ast, options) -- ./compiler/lua53.can:3
local lastInputPos = 1 -- ./compiler/lua53.can:5
local prevLinePos = 1 -- ./compiler/lua53.can:6
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua53.can:7
local lastLine = 1 -- ./compiler/lua53.can:8
local indentLevel = 0 -- ./compiler/lua53.can:11
local function newline() -- ./compiler/lua53.can:13
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua53.can:14
if options["mapLines"] then -- ./compiler/lua53.can:15
local sub = code:sub(lastInputPos) -- ./compiler/lua53.can:16
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua53.can:17
if source and line then -- ./compiler/lua53.can:19
lastSource = source -- ./compiler/lua53.can:20
lastLine = tonumber(line) -- ./compiler/lua53.can:21
else -- ./compiler/lua53.can:21
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua53.can:23
lastLine = lastLine + (1) -- ./compiler/lua53.can:24
end -- ./compiler/lua53.can:24
end -- ./compiler/lua53.can:24
prevLinePos = lastInputPos -- ./compiler/lua53.can:28
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua53.can:30
end -- ./compiler/lua53.can:30
return r -- ./compiler/lua53.can:32
end -- ./compiler/lua53.can:32
local function indent() -- ./compiler/lua53.can:35
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:36
return newline() -- ./compiler/lua53.can:37
end -- ./compiler/lua53.can:37
local function unindent() -- ./compiler/lua53.can:40
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:41
return newline() -- ./compiler/lua53.can:42
end -- ./compiler/lua53.can:42
local states = { -- ./compiler/lua53.can:47
["push"] = {}, -- ./compiler/lua53.can:48
["destructuring"] = {}, -- ./compiler/lua53.can:49
["scope"] = {} -- ./compiler/lua53.can:50
} -- ./compiler/lua53.can:50
local function push(name, state) -- ./compiler/lua53.can:53
table["insert"](states[name], state) -- ./compiler/lua53.can:54
return "" -- ./compiler/lua53.can:55
end -- ./compiler/lua53.can:55
local function pop(name) -- ./compiler/lua53.can:58
table["remove"](states[name]) -- ./compiler/lua53.can:59
return "" -- ./compiler/lua53.can:60
end -- ./compiler/lua53.can:60
local function set(name, state) -- ./compiler/lua53.can:63
states[name][# states[name]] = state -- ./compiler/lua53.can:64
return "" -- ./compiler/lua53.can:65
end -- ./compiler/lua53.can:65
local function peek(name) -- ./compiler/lua53.can:68
return states[name][# states[name]] -- ./compiler/lua53.can:69
end -- ./compiler/lua53.can:69
local function var(name) -- ./compiler/lua53.can:74
return options["variablePrefix"] .. name -- ./compiler/lua53.can:75
end -- ./compiler/lua53.can:75
local function tmp() -- ./compiler/lua53.can:79
local scope = peek("scope") -- ./compiler/lua53.can:80
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua53.can:81
table["insert"](scope, var) -- ./compiler/lua53.can:82
return var -- ./compiler/lua53.can:83
end -- ./compiler/lua53.can:83
local required = {} -- ./compiler/lua53.can:87
local requireStr = "" -- ./compiler/lua53.can:88
local function addRequire(mod, name, field) -- ./compiler/lua53.can:90
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua53.can:91
if not required[req] then -- ./compiler/lua53.can:92
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua53.can:93
required[req] = true -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
local loop = { -- ./compiler/lua53.can:99
"While", -- ./compiler/lua53.can:99
"Repeat", -- ./compiler/lua53.can:99
"Fornum", -- ./compiler/lua53.can:99
"Forin", -- ./compiler/lua53.can:99
"WhileExpr", -- ./compiler/lua53.can:99
"RepeatExpr", -- ./compiler/lua53.can:99
"FornumExpr", -- ./compiler/lua53.can:99
"ForinExpr" -- ./compiler/lua53.can:99
} -- ./compiler/lua53.can:99
local func = { -- ./compiler/lua53.can:100
"Function", -- ./compiler/lua53.can:100
"TableCompr", -- ./compiler/lua53.can:100
"DoExpr", -- ./compiler/lua53.can:100
"WhileExpr", -- ./compiler/lua53.can:100
"RepeatExpr", -- ./compiler/lua53.can:100
"IfExpr", -- ./compiler/lua53.can:100
"FornumExpr", -- ./compiler/lua53.can:100
"ForinExpr" -- ./compiler/lua53.can:100
} -- ./compiler/lua53.can:100
local function any(list, tags, nofollow) -- ./compiler/lua53.can:104
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:104
local tagsCheck = {} -- ./compiler/lua53.can:105
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:106
tagsCheck[tag] = true -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
local nofollowCheck = {} -- ./compiler/lua53.can:109
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:110
nofollowCheck[tag] = true -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
for _, node in ipairs(list) do -- ./compiler/lua53.can:113
if type(node) == "table" then -- ./compiler/lua53.can:114
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:115
return node -- ./compiler/lua53.can:116
end -- ./compiler/lua53.can:116
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:118
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:119
if r then -- ./compiler/lua53.can:120
return r -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
return nil -- ./compiler/lua53.can:124
end -- ./compiler/lua53.can:124
local function search(list, tags, nofollow) -- ./compiler/lua53.can:129
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:129
local tagsCheck = {} -- ./compiler/lua53.can:130
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:131
tagsCheck[tag] = true -- ./compiler/lua53.can:132
end -- ./compiler/lua53.can:132
local nofollowCheck = {} -- ./compiler/lua53.can:134
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:135
nofollowCheck[tag] = true -- ./compiler/lua53.can:136
end -- ./compiler/lua53.can:136
local found = {} -- ./compiler/lua53.can:138
for _, node in ipairs(list) do -- ./compiler/lua53.can:139
if type(node) == "table" then -- ./compiler/lua53.can:140
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:141
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua53.can:142
table["insert"](found, n) -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:146
table["insert"](found, node) -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
return found -- ./compiler/lua53.can:151
end -- ./compiler/lua53.can:151
local function all(list, tags) -- ./compiler/lua53.can:155
for _, node in ipairs(list) do -- ./compiler/lua53.can:156
local ok = false -- ./compiler/lua53.can:157
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:158
if node["tag"] == tag then -- ./compiler/lua53.can:159
ok = true -- ./compiler/lua53.can:160
break -- ./compiler/lua53.can:161
end -- ./compiler/lua53.can:161
end -- ./compiler/lua53.can:161
if not ok then -- ./compiler/lua53.can:164
return false -- ./compiler/lua53.can:165
end -- ./compiler/lua53.can:165
end -- ./compiler/lua53.can:165
return true -- ./compiler/lua53.can:168
end -- ./compiler/lua53.can:168
local tags -- ./compiler/lua53.can:172
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:174
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:175
lastInputPos = ast["pos"] -- ./compiler/lua53.can:176
end -- ./compiler/lua53.can:176
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:178
end -- ./compiler/lua53.can:178
local UNPACK = function(list, i, j) -- ./compiler/lua53.can:182
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:183
end -- ./compiler/lua53.can:183
local APPEND = function(t, toAppend) -- ./compiler/lua53.can:185
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local CONTINUE_START = function() -- ./compiler/lua53.can:188
return "do" .. indent() -- ./compiler/lua53.can:189
end -- ./compiler/lua53.can:189
local CONTINUE_STOP = function() -- ./compiler/lua53.can:191
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:192
end -- ./compiler/lua53.can:192
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua53.can:194
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua53.can:194
if noLocal == nil then noLocal = false end -- ./compiler/lua53.can:194
local vars = {} -- ./compiler/lua53.can:195
local values = {} -- ./compiler/lua53.can:196
for _, list in ipairs(destructured) do -- ./compiler/lua53.can:197
for _, v in ipairs(list) do -- ./compiler/lua53.can:198
local var, val -- ./compiler/lua53.can:199
if v["tag"] == "Id" then -- ./compiler/lua53.can:200
var = v -- ./compiler/lua53.can:201
val = { -- ./compiler/lua53.can:202
["tag"] = "Index", -- ./compiler/lua53.can:202
{ -- ./compiler/lua53.can:202
["tag"] = "Id", -- ./compiler/lua53.can:202
list["id"] -- ./compiler/lua53.can:202
}, -- ./compiler/lua53.can:202
{ -- ./compiler/lua53.can:202
["tag"] = "String", -- ./compiler/lua53.can:202
v[1] -- ./compiler/lua53.can:202
} -- ./compiler/lua53.can:202
} -- ./compiler/lua53.can:202
elseif v["tag"] == "Pair" then -- ./compiler/lua53.can:203
var = v[2] -- ./compiler/lua53.can:204
val = { -- ./compiler/lua53.can:205
["tag"] = "Index", -- ./compiler/lua53.can:205
{ -- ./compiler/lua53.can:205
["tag"] = "Id", -- ./compiler/lua53.can:205
list["id"] -- ./compiler/lua53.can:205
}, -- ./compiler/lua53.can:205
v[1] -- ./compiler/lua53.can:205
} -- ./compiler/lua53.can:205
else -- ./compiler/lua53.can:205
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua53.can:207
end -- ./compiler/lua53.can:207
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua53.can:209
val = { -- ./compiler/lua53.can:210
["tag"] = "Op", -- ./compiler/lua53.can:210
destructured["rightOp"], -- ./compiler/lua53.can:210
var, -- ./compiler/lua53.can:210
{ -- ./compiler/lua53.can:210
["tag"] = "Op", -- ./compiler/lua53.can:210
destructured["leftOp"], -- ./compiler/lua53.can:210
val, -- ./compiler/lua53.can:210
var -- ./compiler/lua53.can:210
} -- ./compiler/lua53.can:210
} -- ./compiler/lua53.can:210
elseif destructured["rightOp"] then -- ./compiler/lua53.can:211
val = { -- ./compiler/lua53.can:212
["tag"] = "Op", -- ./compiler/lua53.can:212
destructured["rightOp"], -- ./compiler/lua53.can:212
var, -- ./compiler/lua53.can:212
val -- ./compiler/lua53.can:212
} -- ./compiler/lua53.can:212
elseif destructured["leftOp"] then -- ./compiler/lua53.can:213
val = { -- ./compiler/lua53.can:214
["tag"] = "Op", -- ./compiler/lua53.can:214
destructured["leftOp"], -- ./compiler/lua53.can:214
val, -- ./compiler/lua53.can:214
var -- ./compiler/lua53.can:214
} -- ./compiler/lua53.can:214
end -- ./compiler/lua53.can:214
table["insert"](vars, lua(var)) -- ./compiler/lua53.can:216
table["insert"](values, lua(val)) -- ./compiler/lua53.can:217
end -- ./compiler/lua53.can:217
end -- ./compiler/lua53.can:217
if # vars > 0 then -- ./compiler/lua53.can:220
local decl = noLocal and "" or "local " -- ./compiler/lua53.can:221
if newlineAfter then -- ./compiler/lua53.can:222
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua53.can:223
else -- ./compiler/lua53.can:223
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua53.can:225
end -- ./compiler/lua53.can:225
else -- ./compiler/lua53.can:225
return "" -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
tags = setmetatable({ -- ./compiler/lua53.can:233
["Block"] = function(t) -- ./compiler/lua53.can:235
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua53.can:236
if hasPush and hasPush == t[# t] then -- ./compiler/lua53.can:237
hasPush["tag"] = "Return" -- ./compiler/lua53.can:238
hasPush = false -- ./compiler/lua53.can:239
end -- ./compiler/lua53.can:239
local r = push("scope", {}) -- ./compiler/lua53.can:241
if hasPush then -- ./compiler/lua53.can:242
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:243
end -- ./compiler/lua53.can:243
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:245
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
if t[# t] then -- ./compiler/lua53.can:248
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:249
end -- ./compiler/lua53.can:249
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua53.can:251
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:252
end -- ./compiler/lua53.can:252
return r .. pop("scope") -- ./compiler/lua53.can:254
end, -- ./compiler/lua53.can:254
["Do"] = function(t) -- ./compiler/lua53.can:260
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:261
end, -- ./compiler/lua53.can:261
["Set"] = function(t) -- ./compiler/lua53.can:264
local expr = t[# t] -- ./compiler/lua53.can:266
local vars, values = {}, {} -- ./compiler/lua53.can:267
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua53.can:268
for i, n in ipairs(t[1]) do -- ./compiler/lua53.can:269
if n["tag"] == "DestructuringId" then -- ./compiler/lua53.can:270
table["insert"](destructuringVars, n) -- ./compiler/lua53.can:271
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua53.can:272
else -- ./compiler/lua53.can:272
table["insert"](vars, n) -- ./compiler/lua53.can:274
table["insert"](values, expr[i]) -- ./compiler/lua53.can:275
end -- ./compiler/lua53.can:275
end -- ./compiler/lua53.can:275
if # t == 2 or # t == 3 then -- ./compiler/lua53.can:279
local r = "" -- ./compiler/lua53.can:280
if # vars > 0 then -- ./compiler/lua53.can:281
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua53.can:282
end -- ./compiler/lua53.can:282
if # destructuringVars > 0 then -- ./compiler/lua53.can:284
local destructured = {} -- ./compiler/lua53.can:285
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:286
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:287
end -- ./compiler/lua53.can:287
return r -- ./compiler/lua53.can:289
elseif # t == 4 then -- ./compiler/lua53.can:290
if t[3] == "=" then -- ./compiler/lua53.can:291
local r = "" -- ./compiler/lua53.can:292
if # vars > 0 then -- ./compiler/lua53.can:293
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:294
t[2], -- ./compiler/lua53.can:294
vars[1], -- ./compiler/lua53.can:294
{ -- ./compiler/lua53.can:294
["tag"] = "Paren", -- ./compiler/lua53.can:294
values[1] -- ./compiler/lua53.can:294
} -- ./compiler/lua53.can:294
}, "Op")) -- ./compiler/lua53.can:294
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua53.can:295
r = r .. (", " .. lua({ -- ./compiler/lua53.can:296
t[2], -- ./compiler/lua53.can:296
vars[i], -- ./compiler/lua53.can:296
{ -- ./compiler/lua53.can:296
["tag"] = "Paren", -- ./compiler/lua53.can:296
values[i] -- ./compiler/lua53.can:296
} -- ./compiler/lua53.can:296
}, "Op")) -- ./compiler/lua53.can:296
end -- ./compiler/lua53.can:296
end -- ./compiler/lua53.can:296
if # destructuringVars > 0 then -- ./compiler/lua53.can:299
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua53.can:300
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:301
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:302
end -- ./compiler/lua53.can:302
return r -- ./compiler/lua53.can:304
else -- ./compiler/lua53.can:304
local r = "" -- ./compiler/lua53.can:306
if # vars > 0 then -- ./compiler/lua53.can:307
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:308
t[3], -- ./compiler/lua53.can:308
{ -- ./compiler/lua53.can:308
["tag"] = "Paren", -- ./compiler/lua53.can:308
values[1] -- ./compiler/lua53.can:308
}, -- ./compiler/lua53.can:308
vars[1] -- ./compiler/lua53.can:308
}, "Op")) -- ./compiler/lua53.can:308
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:309
r = r .. (", " .. lua({ -- ./compiler/lua53.can:310
t[3], -- ./compiler/lua53.can:310
{ -- ./compiler/lua53.can:310
["tag"] = "Paren", -- ./compiler/lua53.can:310
values[i] -- ./compiler/lua53.can:310
}, -- ./compiler/lua53.can:310
vars[i] -- ./compiler/lua53.can:310
}, "Op")) -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
if # destructuringVars > 0 then -- ./compiler/lua53.can:313
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua53.can:314
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:315
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:316
end -- ./compiler/lua53.can:316
return r -- ./compiler/lua53.can:318
end -- ./compiler/lua53.can:318
else -- ./compiler/lua53.can:318
local r = "" -- ./compiler/lua53.can:321
if # vars > 0 then -- ./compiler/lua53.can:322
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:323
t[2], -- ./compiler/lua53.can:323
vars[1], -- ./compiler/lua53.can:323
{ -- ./compiler/lua53.can:323
["tag"] = "Op", -- ./compiler/lua53.can:323
t[4], -- ./compiler/lua53.can:323
{ -- ./compiler/lua53.can:323
["tag"] = "Paren", -- ./compiler/lua53.can:323
values[1] -- ./compiler/lua53.can:323
}, -- ./compiler/lua53.can:323
vars[1] -- ./compiler/lua53.can:323
} -- ./compiler/lua53.can:323
}, "Op")) -- ./compiler/lua53.can:323
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:324
r = r .. (", " .. lua({ -- ./compiler/lua53.can:325
t[2], -- ./compiler/lua53.can:325
vars[i], -- ./compiler/lua53.can:325
{ -- ./compiler/lua53.can:325
["tag"] = "Op", -- ./compiler/lua53.can:325
t[4], -- ./compiler/lua53.can:325
{ -- ./compiler/lua53.can:325
["tag"] = "Paren", -- ./compiler/lua53.can:325
values[i] -- ./compiler/lua53.can:325
}, -- ./compiler/lua53.can:325
vars[i] -- ./compiler/lua53.can:325
} -- ./compiler/lua53.can:325
}, "Op")) -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
if # destructuringVars > 0 then -- ./compiler/lua53.can:328
local destructured = { -- ./compiler/lua53.can:329
["rightOp"] = t[2], -- ./compiler/lua53.can:329
["leftOp"] = t[4] -- ./compiler/lua53.can:329
} -- ./compiler/lua53.can:329
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:330
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:331
end -- ./compiler/lua53.can:331
return r -- ./compiler/lua53.can:333
end -- ./compiler/lua53.can:333
end, -- ./compiler/lua53.can:333
["While"] = function(t) -- ./compiler/lua53.can:337
local r = "" -- ./compiler/lua53.can:338
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:339
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:340
if # lets > 0 then -- ./compiler/lua53.can:341
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:342
for _, l in ipairs(lets) do -- ./compiler/lua53.can:343
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:344
end -- ./compiler/lua53.can:344
end -- ./compiler/lua53.can:344
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua53.can:347
if # lets > 0 then -- ./compiler/lua53.can:348
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:349
end -- ./compiler/lua53.can:349
if hasContinue then -- ./compiler/lua53.can:351
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:352
end -- ./compiler/lua53.can:352
r = r .. (lua(t[2])) -- ./compiler/lua53.can:354
if hasContinue then -- ./compiler/lua53.can:355
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:356
end -- ./compiler/lua53.can:356
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:358
if # lets > 0 then -- ./compiler/lua53.can:359
for _, l in ipairs(lets) do -- ./compiler/lua53.can:360
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua53.can:361
end -- ./compiler/lua53.can:361
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua53.can:363
end -- ./compiler/lua53.can:363
return r -- ./compiler/lua53.can:365
end, -- ./compiler/lua53.can:365
["Repeat"] = function(t) -- ./compiler/lua53.can:368
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:369
local r = "repeat" .. indent() -- ./compiler/lua53.can:370
if hasContinue then -- ./compiler/lua53.can:371
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:372
end -- ./compiler/lua53.can:372
r = r .. (lua(t[1])) -- ./compiler/lua53.can:374
if hasContinue then -- ./compiler/lua53.can:375
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:376
end -- ./compiler/lua53.can:376
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:378
return r -- ./compiler/lua53.can:379
end, -- ./compiler/lua53.can:379
["If"] = function(t) -- ./compiler/lua53.can:382
local r = "" -- ./compiler/lua53.can:383
local toClose = 0 -- ./compiler/lua53.can:384
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:385
if # lets > 0 then -- ./compiler/lua53.can:386
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:387
toClose = toClose + (1) -- ./compiler/lua53.can:388
for _, l in ipairs(lets) do -- ./compiler/lua53.can:389
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:390
end -- ./compiler/lua53.can:390
end -- ./compiler/lua53.can:390
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua53.can:393
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:394
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua53.can:395
if # lets > 0 then -- ./compiler/lua53.can:396
r = r .. ("else" .. indent()) -- ./compiler/lua53.can:397
toClose = toClose + (1) -- ./compiler/lua53.can:398
for _, l in ipairs(lets) do -- ./compiler/lua53.can:399
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:400
end -- ./compiler/lua53.can:400
else -- ./compiler/lua53.can:400
r = r .. ("else") -- ./compiler/lua53.can:403
end -- ./compiler/lua53.can:403
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:405
end -- ./compiler/lua53.can:405
if # t % 2 == 1 then -- ./compiler/lua53.can:407
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:408
end -- ./compiler/lua53.can:408
r = r .. ("end") -- ./compiler/lua53.can:410
for i = 1, toClose do -- ./compiler/lua53.can:411
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:412
end -- ./compiler/lua53.can:412
return r -- ./compiler/lua53.can:414
end, -- ./compiler/lua53.can:414
["Fornum"] = function(t) -- ./compiler/lua53.can:417
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:418
if # t == 5 then -- ./compiler/lua53.can:419
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:420
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:421
if hasContinue then -- ./compiler/lua53.can:422
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:423
end -- ./compiler/lua53.can:423
r = r .. (lua(t[5])) -- ./compiler/lua53.can:425
if hasContinue then -- ./compiler/lua53.can:426
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:427
end -- ./compiler/lua53.can:427
return r .. unindent() .. "end" -- ./compiler/lua53.can:429
else -- ./compiler/lua53.can:429
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:431
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:432
if hasContinue then -- ./compiler/lua53.can:433
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:434
end -- ./compiler/lua53.can:434
r = r .. (lua(t[4])) -- ./compiler/lua53.can:436
if hasContinue then -- ./compiler/lua53.can:437
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:438
end -- ./compiler/lua53.can:438
return r .. unindent() .. "end" -- ./compiler/lua53.can:440
end -- ./compiler/lua53.can:440
end, -- ./compiler/lua53.can:440
["Forin"] = function(t) -- ./compiler/lua53.can:444
local destructured = {} -- ./compiler/lua53.can:445
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:446
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:447
if hasContinue then -- ./compiler/lua53.can:448
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:449
end -- ./compiler/lua53.can:449
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua53.can:451
if hasContinue then -- ./compiler/lua53.can:452
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:453
end -- ./compiler/lua53.can:453
return r .. unindent() .. "end" -- ./compiler/lua53.can:455
end, -- ./compiler/lua53.can:455
["Local"] = function(t) -- ./compiler/lua53.can:458
local destructured = {} -- ./compiler/lua53.can:459
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua53.can:460
if t[2][1] then -- ./compiler/lua53.can:461
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:462
end -- ./compiler/lua53.can:462
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua53.can:464
end, -- ./compiler/lua53.can:464
["Let"] = function(t) -- ./compiler/lua53.can:467
local destructured = {} -- ./compiler/lua53.can:468
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua53.can:469
local r = "local " .. nameList -- ./compiler/lua53.can:470
if t[2][1] then -- ./compiler/lua53.can:471
if all(t[2], { -- ./compiler/lua53.can:472
"Nil", -- ./compiler/lua53.can:472
"Dots", -- ./compiler/lua53.can:472
"Boolean", -- ./compiler/lua53.can:472
"Number", -- ./compiler/lua53.can:472
"String" -- ./compiler/lua53.can:472
}) then -- ./compiler/lua53.can:472
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:473
else -- ./compiler/lua53.can:473
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:475
end -- ./compiler/lua53.can:475
end -- ./compiler/lua53.can:475
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua53.can:478
end, -- ./compiler/lua53.can:478
["Localrec"] = function(t) -- ./compiler/lua53.can:481
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:482
end, -- ./compiler/lua53.can:482
["Goto"] = function(t) -- ./compiler/lua53.can:485
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:486
end, -- ./compiler/lua53.can:486
["Label"] = function(t) -- ./compiler/lua53.can:489
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:490
end, -- ./compiler/lua53.can:490
["Return"] = function(t) -- ./compiler/lua53.can:493
local push = peek("push") -- ./compiler/lua53.can:494
if push then -- ./compiler/lua53.can:495
local r = "" -- ./compiler/lua53.can:496
for _, val in ipairs(t) do -- ./compiler/lua53.can:497
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:498
end -- ./compiler/lua53.can:498
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:500
else -- ./compiler/lua53.can:500
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:502
end -- ./compiler/lua53.can:502
end, -- ./compiler/lua53.can:502
["Push"] = function(t) -- ./compiler/lua53.can:506
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:507
r = "" -- ./compiler/lua53.can:508
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:509
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:510
end -- ./compiler/lua53.can:510
if t[# t] then -- ./compiler/lua53.can:512
if t[# t]["tag"] == "Call" then -- ./compiler/lua53.can:513
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:514
else -- ./compiler/lua53.can:514
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:516
end -- ./compiler/lua53.can:516
end -- ./compiler/lua53.can:516
return r -- ./compiler/lua53.can:519
end, -- ./compiler/lua53.can:519
["Break"] = function() -- ./compiler/lua53.can:522
return "break" -- ./compiler/lua53.can:523
end, -- ./compiler/lua53.can:523
["Continue"] = function() -- ./compiler/lua53.can:526
return "goto " .. var("continue") -- ./compiler/lua53.can:527
end, -- ./compiler/lua53.can:527
["Nil"] = function() -- ./compiler/lua53.can:534
return "nil" -- ./compiler/lua53.can:535
end, -- ./compiler/lua53.can:535
["Dots"] = function() -- ./compiler/lua53.can:538
return "..." -- ./compiler/lua53.can:539
end, -- ./compiler/lua53.can:539
["Boolean"] = function(t) -- ./compiler/lua53.can:542
return tostring(t[1]) -- ./compiler/lua53.can:543
end, -- ./compiler/lua53.can:543
["Number"] = function(t) -- ./compiler/lua53.can:546
return tostring(t[1]) -- ./compiler/lua53.can:547
end, -- ./compiler/lua53.can:547
["String"] = function(t) -- ./compiler/lua53.can:550
return ("%q"):format(t[1]) -- ./compiler/lua53.can:551
end, -- ./compiler/lua53.can:551
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:554
local r = "(" -- ./compiler/lua53.can:555
local decl = {} -- ./compiler/lua53.can:556
if t[1][1] then -- ./compiler/lua53.can:557
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:558
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:559
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:560
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:561
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:562
r = r .. (id) -- ./compiler/lua53.can:563
else -- ./compiler/lua53.can:563
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:565
end -- ./compiler/lua53.can:565
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:567
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:568
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:569
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:570
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:571
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:572
r = r .. (", " .. id) -- ./compiler/lua53.can:573
else -- ./compiler/lua53.can:573
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
r = r .. (")" .. indent()) -- ./compiler/lua53.can:579
for _, d in ipairs(decl) do -- ./compiler/lua53.can:580
r = r .. (d .. newline()) -- ./compiler/lua53.can:581
end -- ./compiler/lua53.can:581
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua53.can:583
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:584
end -- ./compiler/lua53.can:584
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:586
if hasPush then -- ./compiler/lua53.can:587
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:588
else -- ./compiler/lua53.can:588
push("push", false) -- ./compiler/lua53.can:590
end -- ./compiler/lua53.can:590
r = r .. (lua(t[2])) -- ./compiler/lua53.can:592
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua53.can:593
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:594
end -- ./compiler/lua53.can:594
pop("push") -- ./compiler/lua53.can:596
return r .. unindent() .. "end" -- ./compiler/lua53.can:597
end, -- ./compiler/lua53.can:597
["Function"] = function(t) -- ./compiler/lua53.can:599
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:600
end, -- ./compiler/lua53.can:600
["Pair"] = function(t) -- ./compiler/lua53.can:603
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:604
end, -- ./compiler/lua53.can:604
["Table"] = function(t) -- ./compiler/lua53.can:606
if # t == 0 then -- ./compiler/lua53.can:607
return "{}" -- ./compiler/lua53.can:608
elseif # t == 1 then -- ./compiler/lua53.can:609
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:610
else -- ./compiler/lua53.can:610
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:612
end -- ./compiler/lua53.can:612
end, -- ./compiler/lua53.can:612
["TableCompr"] = function(t) -- ./compiler/lua53.can:616
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:617
end, -- ./compiler/lua53.can:617
["Op"] = function(t) -- ./compiler/lua53.can:620
local r -- ./compiler/lua53.can:621
if # t == 2 then -- ./compiler/lua53.can:622
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:623
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:624
else -- ./compiler/lua53.can:624
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:626
end -- ./compiler/lua53.can:626
else -- ./compiler/lua53.can:626
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:629
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:630
else -- ./compiler/lua53.can:630
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
return r -- ./compiler/lua53.can:635
end, -- ./compiler/lua53.can:635
["Paren"] = function(t) -- ./compiler/lua53.can:638
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:639
end, -- ./compiler/lua53.can:639
["MethodStub"] = function(t) -- ./compiler/lua53.can:642
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:648
end, -- ./compiler/lua53.can:648
["SafeMethodStub"] = function(t) -- ./compiler/lua53.can:651
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:658
end, -- ./compiler/lua53.can:658
["LetExpr"] = function(t) -- ./compiler/lua53.can:665
return lua(t[1][1]) -- ./compiler/lua53.can:666
end, -- ./compiler/lua53.can:666
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:670
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:671
local r = "(function()" .. indent() -- ./compiler/lua53.can:672
if hasPush then -- ./compiler/lua53.can:673
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:674
else -- ./compiler/lua53.can:674
push("push", false) -- ./compiler/lua53.can:676
end -- ./compiler/lua53.can:676
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:678
if hasPush then -- ./compiler/lua53.can:679
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:680
end -- ./compiler/lua53.can:680
pop("push") -- ./compiler/lua53.can:682
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:683
return r -- ./compiler/lua53.can:684
end, -- ./compiler/lua53.can:684
["DoExpr"] = function(t) -- ./compiler/lua53.can:687
if t[# t]["tag"] == "Push" then -- ./compiler/lua53.can:688
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:689
end -- ./compiler/lua53.can:689
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:691
end, -- ./compiler/lua53.can:691
["WhileExpr"] = function(t) -- ./compiler/lua53.can:694
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:695
end, -- ./compiler/lua53.can:695
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:698
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:699
end, -- ./compiler/lua53.can:699
["IfExpr"] = function(t) -- ./compiler/lua53.can:702
for i = 2, # t do -- ./compiler/lua53.can:703
local block = t[i] -- ./compiler/lua53.can:704
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:705
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:706
end -- ./compiler/lua53.can:706
end -- ./compiler/lua53.can:706
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:709
end, -- ./compiler/lua53.can:709
["FornumExpr"] = function(t) -- ./compiler/lua53.can:712
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:713
end, -- ./compiler/lua53.can:713
["ForinExpr"] = function(t) -- ./compiler/lua53.can:716
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:717
end, -- ./compiler/lua53.can:717
["Call"] = function(t) -- ./compiler/lua53.can:723
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:724
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:725
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua53.can:726
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua53.can:727
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:728
else -- ./compiler/lua53.can:728
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:730
end -- ./compiler/lua53.can:730
else -- ./compiler/lua53.can:730
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:733
end -- ./compiler/lua53.can:733
end, -- ./compiler/lua53.can:733
["SafeCall"] = function(t) -- ./compiler/lua53.can:737
if t[1]["tag"] ~= "Id" then -- ./compiler/lua53.can:738
return lua(t, "SafeIndex") -- ./compiler/lua53.can:739
else -- ./compiler/lua53.can:739
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua53.can:741
end -- ./compiler/lua53.can:741
end, -- ./compiler/lua53.can:741
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:746
if start == nil then start = 1 end -- ./compiler/lua53.can:746
local r -- ./compiler/lua53.can:747
if t[start] then -- ./compiler/lua53.can:748
r = lua(t[start]) -- ./compiler/lua53.can:749
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:750
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:751
end -- ./compiler/lua53.can:751
else -- ./compiler/lua53.can:751
r = "" -- ./compiler/lua53.can:754
end -- ./compiler/lua53.can:754
return r -- ./compiler/lua53.can:756
end, -- ./compiler/lua53.can:756
["Id"] = function(t) -- ./compiler/lua53.can:759
return t[1] -- ./compiler/lua53.can:760
end, -- ./compiler/lua53.can:760
["DestructuringId"] = function(t) -- ./compiler/lua53.can:763
if t["id"] then -- ./compiler/lua53.can:764
return t["id"] -- ./compiler/lua53.can:765
else -- ./compiler/lua53.can:765
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua53.can:767
local vars = { ["id"] = tmp() } -- ./compiler/lua53.can:768
for j = 1, # t, 1 do -- ./compiler/lua53.can:769
table["insert"](vars, t[j]) -- ./compiler/lua53.can:770
end -- ./compiler/lua53.can:770
table["insert"](d, vars) -- ./compiler/lua53.can:772
t["id"] = vars["id"] -- ./compiler/lua53.can:773
return vars["id"] -- ./compiler/lua53.can:774
end -- ./compiler/lua53.can:774
end, -- ./compiler/lua53.can:774
["Index"] = function(t) -- ./compiler/lua53.can:778
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:779
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:780
else -- ./compiler/lua53.can:780
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:782
end -- ./compiler/lua53.can:782
end, -- ./compiler/lua53.can:782
["SafeIndex"] = function(t) -- ./compiler/lua53.can:786
if t[1]["tag"] ~= "Id" then -- ./compiler/lua53.can:787
local l = {} -- ./compiler/lua53.can:788
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:789
table["insert"](l, 1, t) -- ./compiler/lua53.can:790
t = t[1] -- ./compiler/lua53.can:791
end -- ./compiler/lua53.can:791
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua53.can:793
for _, e in ipairs(l) do -- ./compiler/lua53.can:794
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua53.can:795
if e["tag"] == "SafeIndex" then -- ./compiler/lua53.can:796
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua53.can:797
else -- ./compiler/lua53.can:797
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua53.can:799
end -- ./compiler/lua53.can:799
end -- ./compiler/lua53.can:799
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua53.can:802
return r -- ./compiler/lua53.can:803
else -- ./compiler/lua53.can:803
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua53.can:805
end -- ./compiler/lua53.can:805
end, -- ./compiler/lua53.can:805
["_opid"] = { -- ./compiler/lua53.can:810
["add"] = "+", -- ./compiler/lua53.can:811
["sub"] = "-", -- ./compiler/lua53.can:811
["mul"] = "*", -- ./compiler/lua53.can:811
["div"] = "/", -- ./compiler/lua53.can:811
["idiv"] = "//", -- ./compiler/lua53.can:812
["mod"] = "%", -- ./compiler/lua53.can:812
["pow"] = "^", -- ./compiler/lua53.can:812
["concat"] = "..", -- ./compiler/lua53.can:812
["band"] = "&", -- ./compiler/lua53.can:813
["bor"] = "|", -- ./compiler/lua53.can:813
["bxor"] = "~", -- ./compiler/lua53.can:813
["shl"] = "<<", -- ./compiler/lua53.can:813
["shr"] = ">>", -- ./compiler/lua53.can:813
["eq"] = "==", -- ./compiler/lua53.can:814
["ne"] = "~=", -- ./compiler/lua53.can:814
["lt"] = "<", -- ./compiler/lua53.can:814
["gt"] = ">", -- ./compiler/lua53.can:814
["le"] = "<=", -- ./compiler/lua53.can:814
["ge"] = ">=", -- ./compiler/lua53.can:814
["and"] = "and", -- ./compiler/lua53.can:815
["or"] = "or", -- ./compiler/lua53.can:815
["unm"] = "-", -- ./compiler/lua53.can:815
["len"] = "#", -- ./compiler/lua53.can:815
["bnot"] = "~", -- ./compiler/lua53.can:815
["not"] = "not" -- ./compiler/lua53.can:815
} -- ./compiler/lua53.can:815
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:818
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua53.can:819
end }) -- ./compiler/lua53.can:819
local code = lua(ast) .. newline() -- ./compiler/lua53.can:825
return requireStr .. code -- ./compiler/lua53.can:826
end -- ./compiler/lua53.can:826
end -- ./compiler/lua53.can:826
local lua53 = _() or lua53 -- ./compiler/lua53.can:831
package["loaded"]["compiler.lua53"] = lua53 or true -- ./compiler/lua53.can:832
local function _() -- ./compiler/lua53.can:835
local function _() -- ./compiler/lua53.can:837
local targetName = "Lua 5.3" -- ./compiler/lua53.can:1
return function(code, ast, options) -- ./compiler/lua53.can:3
local lastInputPos = 1 -- ./compiler/lua53.can:5
local prevLinePos = 1 -- ./compiler/lua53.can:6
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua53.can:7
local lastLine = 1 -- ./compiler/lua53.can:8
local indentLevel = 0 -- ./compiler/lua53.can:11
local function newline() -- ./compiler/lua53.can:13
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua53.can:14
if options["mapLines"] then -- ./compiler/lua53.can:15
local sub = code:sub(lastInputPos) -- ./compiler/lua53.can:16
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua53.can:17
if source and line then -- ./compiler/lua53.can:19
lastSource = source -- ./compiler/lua53.can:20
lastLine = tonumber(line) -- ./compiler/lua53.can:21
else -- ./compiler/lua53.can:21
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua53.can:23
lastLine = lastLine + (1) -- ./compiler/lua53.can:24
end -- ./compiler/lua53.can:24
end -- ./compiler/lua53.can:24
prevLinePos = lastInputPos -- ./compiler/lua53.can:28
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua53.can:30
end -- ./compiler/lua53.can:30
return r -- ./compiler/lua53.can:32
end -- ./compiler/lua53.can:32
local function indent() -- ./compiler/lua53.can:35
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:36
return newline() -- ./compiler/lua53.can:37
end -- ./compiler/lua53.can:37
local function unindent() -- ./compiler/lua53.can:40
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:41
return newline() -- ./compiler/lua53.can:42
end -- ./compiler/lua53.can:42
local states = { -- ./compiler/lua53.can:47
["push"] = {}, -- ./compiler/lua53.can:48
["destructuring"] = {}, -- ./compiler/lua53.can:49
["scope"] = {} -- ./compiler/lua53.can:50
} -- ./compiler/lua53.can:50
local function push(name, state) -- ./compiler/lua53.can:53
table["insert"](states[name], state) -- ./compiler/lua53.can:54
return "" -- ./compiler/lua53.can:55
end -- ./compiler/lua53.can:55
local function pop(name) -- ./compiler/lua53.can:58
table["remove"](states[name]) -- ./compiler/lua53.can:59
return "" -- ./compiler/lua53.can:60
end -- ./compiler/lua53.can:60
local function set(name, state) -- ./compiler/lua53.can:63
states[name][# states[name]] = state -- ./compiler/lua53.can:64
return "" -- ./compiler/lua53.can:65
end -- ./compiler/lua53.can:65
local function peek(name) -- ./compiler/lua53.can:68
return states[name][# states[name]] -- ./compiler/lua53.can:69
end -- ./compiler/lua53.can:69
local function var(name) -- ./compiler/lua53.can:74
return options["variablePrefix"] .. name -- ./compiler/lua53.can:75
end -- ./compiler/lua53.can:75
local function tmp() -- ./compiler/lua53.can:79
local scope = peek("scope") -- ./compiler/lua53.can:80
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua53.can:81
table["insert"](scope, var) -- ./compiler/lua53.can:82
return var -- ./compiler/lua53.can:83
end -- ./compiler/lua53.can:83
local required = {} -- ./compiler/lua53.can:87
local requireStr = "" -- ./compiler/lua53.can:88
local function addRequire(mod, name, field) -- ./compiler/lua53.can:90
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua53.can:91
if not required[req] then -- ./compiler/lua53.can:92
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua53.can:93
required[req] = true -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
local loop = { -- ./compiler/lua53.can:99
"While", -- ./compiler/lua53.can:99
"Repeat", -- ./compiler/lua53.can:99
"Fornum", -- ./compiler/lua53.can:99
"Forin", -- ./compiler/lua53.can:99
"WhileExpr", -- ./compiler/lua53.can:99
"RepeatExpr", -- ./compiler/lua53.can:99
"FornumExpr", -- ./compiler/lua53.can:99
"ForinExpr" -- ./compiler/lua53.can:99
} -- ./compiler/lua53.can:99
local func = { -- ./compiler/lua53.can:100
"Function", -- ./compiler/lua53.can:100
"TableCompr", -- ./compiler/lua53.can:100
"DoExpr", -- ./compiler/lua53.can:100
"WhileExpr", -- ./compiler/lua53.can:100
"RepeatExpr", -- ./compiler/lua53.can:100
"IfExpr", -- ./compiler/lua53.can:100
"FornumExpr", -- ./compiler/lua53.can:100
"ForinExpr" -- ./compiler/lua53.can:100
} -- ./compiler/lua53.can:100
local function any(list, tags, nofollow) -- ./compiler/lua53.can:104
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:104
local tagsCheck = {} -- ./compiler/lua53.can:105
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:106
tagsCheck[tag] = true -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
local nofollowCheck = {} -- ./compiler/lua53.can:109
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:110
nofollowCheck[tag] = true -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
for _, node in ipairs(list) do -- ./compiler/lua53.can:113
if type(node) == "table" then -- ./compiler/lua53.can:114
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:115
return node -- ./compiler/lua53.can:116
end -- ./compiler/lua53.can:116
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:118
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:119
if r then -- ./compiler/lua53.can:120
return r -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
return nil -- ./compiler/lua53.can:124
end -- ./compiler/lua53.can:124
local function search(list, tags, nofollow) -- ./compiler/lua53.can:129
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:129
local tagsCheck = {} -- ./compiler/lua53.can:130
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:131
tagsCheck[tag] = true -- ./compiler/lua53.can:132
end -- ./compiler/lua53.can:132
local nofollowCheck = {} -- ./compiler/lua53.can:134
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:135
nofollowCheck[tag] = true -- ./compiler/lua53.can:136
end -- ./compiler/lua53.can:136
local found = {} -- ./compiler/lua53.can:138
for _, node in ipairs(list) do -- ./compiler/lua53.can:139
if type(node) == "table" then -- ./compiler/lua53.can:140
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:141
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua53.can:142
table["insert"](found, n) -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:146
table["insert"](found, node) -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
return found -- ./compiler/lua53.can:151
end -- ./compiler/lua53.can:151
local function all(list, tags) -- ./compiler/lua53.can:155
for _, node in ipairs(list) do -- ./compiler/lua53.can:156
local ok = false -- ./compiler/lua53.can:157
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:158
if node["tag"] == tag then -- ./compiler/lua53.can:159
ok = true -- ./compiler/lua53.can:160
break -- ./compiler/lua53.can:161
end -- ./compiler/lua53.can:161
end -- ./compiler/lua53.can:161
if not ok then -- ./compiler/lua53.can:164
return false -- ./compiler/lua53.can:165
end -- ./compiler/lua53.can:165
end -- ./compiler/lua53.can:165
return true -- ./compiler/lua53.can:168
end -- ./compiler/lua53.can:168
local tags -- ./compiler/lua53.can:172
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:174
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:175
lastInputPos = ast["pos"] -- ./compiler/lua53.can:176
end -- ./compiler/lua53.can:176
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:178
end -- ./compiler/lua53.can:178
local UNPACK = function(list, i, j) -- ./compiler/lua53.can:182
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:183
end -- ./compiler/lua53.can:183
local APPEND = function(t, toAppend) -- ./compiler/lua53.can:185
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local CONTINUE_START = function() -- ./compiler/lua53.can:188
return "do" .. indent() -- ./compiler/lua53.can:189
end -- ./compiler/lua53.can:189
local CONTINUE_STOP = function() -- ./compiler/lua53.can:191
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:192
end -- ./compiler/lua53.can:192
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua53.can:194
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua53.can:194
if noLocal == nil then noLocal = false end -- ./compiler/lua53.can:194
local vars = {} -- ./compiler/lua53.can:195
local values = {} -- ./compiler/lua53.can:196
for _, list in ipairs(destructured) do -- ./compiler/lua53.can:197
for _, v in ipairs(list) do -- ./compiler/lua53.can:198
local var, val -- ./compiler/lua53.can:199
if v["tag"] == "Id" then -- ./compiler/lua53.can:200
var = v -- ./compiler/lua53.can:201
val = { -- ./compiler/lua53.can:202
["tag"] = "Index", -- ./compiler/lua53.can:202
{ -- ./compiler/lua53.can:202
["tag"] = "Id", -- ./compiler/lua53.can:202
list["id"] -- ./compiler/lua53.can:202
}, -- ./compiler/lua53.can:202
{ -- ./compiler/lua53.can:202
["tag"] = "String", -- ./compiler/lua53.can:202
v[1] -- ./compiler/lua53.can:202
} -- ./compiler/lua53.can:202
} -- ./compiler/lua53.can:202
elseif v["tag"] == "Pair" then -- ./compiler/lua53.can:203
var = v[2] -- ./compiler/lua53.can:204
val = { -- ./compiler/lua53.can:205
["tag"] = "Index", -- ./compiler/lua53.can:205
{ -- ./compiler/lua53.can:205
["tag"] = "Id", -- ./compiler/lua53.can:205
list["id"] -- ./compiler/lua53.can:205
}, -- ./compiler/lua53.can:205
v[1] -- ./compiler/lua53.can:205
} -- ./compiler/lua53.can:205
else -- ./compiler/lua53.can:205
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua53.can:207
end -- ./compiler/lua53.can:207
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua53.can:209
val = { -- ./compiler/lua53.can:210
["tag"] = "Op", -- ./compiler/lua53.can:210
destructured["rightOp"], -- ./compiler/lua53.can:210
var, -- ./compiler/lua53.can:210
{ -- ./compiler/lua53.can:210
["tag"] = "Op", -- ./compiler/lua53.can:210
destructured["leftOp"], -- ./compiler/lua53.can:210
val, -- ./compiler/lua53.can:210
var -- ./compiler/lua53.can:210
} -- ./compiler/lua53.can:210
} -- ./compiler/lua53.can:210
elseif destructured["rightOp"] then -- ./compiler/lua53.can:211
val = { -- ./compiler/lua53.can:212
["tag"] = "Op", -- ./compiler/lua53.can:212
destructured["rightOp"], -- ./compiler/lua53.can:212
var, -- ./compiler/lua53.can:212
val -- ./compiler/lua53.can:212
} -- ./compiler/lua53.can:212
elseif destructured["leftOp"] then -- ./compiler/lua53.can:213
val = { -- ./compiler/lua53.can:214
["tag"] = "Op", -- ./compiler/lua53.can:214
destructured["leftOp"], -- ./compiler/lua53.can:214
val, -- ./compiler/lua53.can:214
var -- ./compiler/lua53.can:214
} -- ./compiler/lua53.can:214
end -- ./compiler/lua53.can:214
table["insert"](vars, lua(var)) -- ./compiler/lua53.can:216
table["insert"](values, lua(val)) -- ./compiler/lua53.can:217
end -- ./compiler/lua53.can:217
end -- ./compiler/lua53.can:217
if # vars > 0 then -- ./compiler/lua53.can:220
local decl = noLocal and "" or "local " -- ./compiler/lua53.can:221
if newlineAfter then -- ./compiler/lua53.can:222
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua53.can:223
else -- ./compiler/lua53.can:223
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua53.can:225
end -- ./compiler/lua53.can:225
else -- ./compiler/lua53.can:225
return "" -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
tags = setmetatable({ -- ./compiler/lua53.can:233
["Block"] = function(t) -- ./compiler/lua53.can:235
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua53.can:236
if hasPush and hasPush == t[# t] then -- ./compiler/lua53.can:237
hasPush["tag"] = "Return" -- ./compiler/lua53.can:238
hasPush = false -- ./compiler/lua53.can:239
end -- ./compiler/lua53.can:239
local r = push("scope", {}) -- ./compiler/lua53.can:241
if hasPush then -- ./compiler/lua53.can:242
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:243
end -- ./compiler/lua53.can:243
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:245
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
if t[# t] then -- ./compiler/lua53.can:248
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:249
end -- ./compiler/lua53.can:249
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua53.can:251
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:252
end -- ./compiler/lua53.can:252
return r .. pop("scope") -- ./compiler/lua53.can:254
end, -- ./compiler/lua53.can:254
["Do"] = function(t) -- ./compiler/lua53.can:260
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:261
end, -- ./compiler/lua53.can:261
["Set"] = function(t) -- ./compiler/lua53.can:264
local expr = t[# t] -- ./compiler/lua53.can:266
local vars, values = {}, {} -- ./compiler/lua53.can:267
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua53.can:268
for i, n in ipairs(t[1]) do -- ./compiler/lua53.can:269
if n["tag"] == "DestructuringId" then -- ./compiler/lua53.can:270
table["insert"](destructuringVars, n) -- ./compiler/lua53.can:271
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua53.can:272
else -- ./compiler/lua53.can:272
table["insert"](vars, n) -- ./compiler/lua53.can:274
table["insert"](values, expr[i]) -- ./compiler/lua53.can:275
end -- ./compiler/lua53.can:275
end -- ./compiler/lua53.can:275
if # t == 2 or # t == 3 then -- ./compiler/lua53.can:279
local r = "" -- ./compiler/lua53.can:280
if # vars > 0 then -- ./compiler/lua53.can:281
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua53.can:282
end -- ./compiler/lua53.can:282
if # destructuringVars > 0 then -- ./compiler/lua53.can:284
local destructured = {} -- ./compiler/lua53.can:285
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:286
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:287
end -- ./compiler/lua53.can:287
return r -- ./compiler/lua53.can:289
elseif # t == 4 then -- ./compiler/lua53.can:290
if t[3] == "=" then -- ./compiler/lua53.can:291
local r = "" -- ./compiler/lua53.can:292
if # vars > 0 then -- ./compiler/lua53.can:293
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:294
t[2], -- ./compiler/lua53.can:294
vars[1], -- ./compiler/lua53.can:294
{ -- ./compiler/lua53.can:294
["tag"] = "Paren", -- ./compiler/lua53.can:294
values[1] -- ./compiler/lua53.can:294
} -- ./compiler/lua53.can:294
}, "Op")) -- ./compiler/lua53.can:294
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua53.can:295
r = r .. (", " .. lua({ -- ./compiler/lua53.can:296
t[2], -- ./compiler/lua53.can:296
vars[i], -- ./compiler/lua53.can:296
{ -- ./compiler/lua53.can:296
["tag"] = "Paren", -- ./compiler/lua53.can:296
values[i] -- ./compiler/lua53.can:296
} -- ./compiler/lua53.can:296
}, "Op")) -- ./compiler/lua53.can:296
end -- ./compiler/lua53.can:296
end -- ./compiler/lua53.can:296
if # destructuringVars > 0 then -- ./compiler/lua53.can:299
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua53.can:300
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:301
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:302
end -- ./compiler/lua53.can:302
return r -- ./compiler/lua53.can:304
else -- ./compiler/lua53.can:304
local r = "" -- ./compiler/lua53.can:306
if # vars > 0 then -- ./compiler/lua53.can:307
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:308
t[3], -- ./compiler/lua53.can:308
{ -- ./compiler/lua53.can:308
["tag"] = "Paren", -- ./compiler/lua53.can:308
values[1] -- ./compiler/lua53.can:308
}, -- ./compiler/lua53.can:308
vars[1] -- ./compiler/lua53.can:308
}, "Op")) -- ./compiler/lua53.can:308
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:309
r = r .. (", " .. lua({ -- ./compiler/lua53.can:310
t[3], -- ./compiler/lua53.can:310
{ -- ./compiler/lua53.can:310
["tag"] = "Paren", -- ./compiler/lua53.can:310
values[i] -- ./compiler/lua53.can:310
}, -- ./compiler/lua53.can:310
vars[i] -- ./compiler/lua53.can:310
}, "Op")) -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
if # destructuringVars > 0 then -- ./compiler/lua53.can:313
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua53.can:314
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:315
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:316
end -- ./compiler/lua53.can:316
return r -- ./compiler/lua53.can:318
end -- ./compiler/lua53.can:318
else -- ./compiler/lua53.can:318
local r = "" -- ./compiler/lua53.can:321
if # vars > 0 then -- ./compiler/lua53.can:322
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:323
t[2], -- ./compiler/lua53.can:323
vars[1], -- ./compiler/lua53.can:323
{ -- ./compiler/lua53.can:323
["tag"] = "Op", -- ./compiler/lua53.can:323
t[4], -- ./compiler/lua53.can:323
{ -- ./compiler/lua53.can:323
["tag"] = "Paren", -- ./compiler/lua53.can:323
values[1] -- ./compiler/lua53.can:323
}, -- ./compiler/lua53.can:323
vars[1] -- ./compiler/lua53.can:323
} -- ./compiler/lua53.can:323
}, "Op")) -- ./compiler/lua53.can:323
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:324
r = r .. (", " .. lua({ -- ./compiler/lua53.can:325
t[2], -- ./compiler/lua53.can:325
vars[i], -- ./compiler/lua53.can:325
{ -- ./compiler/lua53.can:325
["tag"] = "Op", -- ./compiler/lua53.can:325
t[4], -- ./compiler/lua53.can:325
{ -- ./compiler/lua53.can:325
["tag"] = "Paren", -- ./compiler/lua53.can:325
values[i] -- ./compiler/lua53.can:325
}, -- ./compiler/lua53.can:325
vars[i] -- ./compiler/lua53.can:325
} -- ./compiler/lua53.can:325
}, "Op")) -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
if # destructuringVars > 0 then -- ./compiler/lua53.can:328
local destructured = { -- ./compiler/lua53.can:329
["rightOp"] = t[2], -- ./compiler/lua53.can:329
["leftOp"] = t[4] -- ./compiler/lua53.can:329
} -- ./compiler/lua53.can:329
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:330
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:331
end -- ./compiler/lua53.can:331
return r -- ./compiler/lua53.can:333
end -- ./compiler/lua53.can:333
end, -- ./compiler/lua53.can:333
["While"] = function(t) -- ./compiler/lua53.can:337
local r = "" -- ./compiler/lua53.can:338
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:339
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:340
if # lets > 0 then -- ./compiler/lua53.can:341
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:342
for _, l in ipairs(lets) do -- ./compiler/lua53.can:343
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:344
end -- ./compiler/lua53.can:344
end -- ./compiler/lua53.can:344
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua53.can:347
if # lets > 0 then -- ./compiler/lua53.can:348
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:349
end -- ./compiler/lua53.can:349
if hasContinue then -- ./compiler/lua53.can:351
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:352
end -- ./compiler/lua53.can:352
r = r .. (lua(t[2])) -- ./compiler/lua53.can:354
if hasContinue then -- ./compiler/lua53.can:355
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:356
end -- ./compiler/lua53.can:356
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:358
if # lets > 0 then -- ./compiler/lua53.can:359
for _, l in ipairs(lets) do -- ./compiler/lua53.can:360
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua53.can:361
end -- ./compiler/lua53.can:361
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua53.can:363
end -- ./compiler/lua53.can:363
return r -- ./compiler/lua53.can:365
end, -- ./compiler/lua53.can:365
["Repeat"] = function(t) -- ./compiler/lua53.can:368
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:369
local r = "repeat" .. indent() -- ./compiler/lua53.can:370
if hasContinue then -- ./compiler/lua53.can:371
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:372
end -- ./compiler/lua53.can:372
r = r .. (lua(t[1])) -- ./compiler/lua53.can:374
if hasContinue then -- ./compiler/lua53.can:375
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:376
end -- ./compiler/lua53.can:376
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:378
return r -- ./compiler/lua53.can:379
end, -- ./compiler/lua53.can:379
["If"] = function(t) -- ./compiler/lua53.can:382
local r = "" -- ./compiler/lua53.can:383
local toClose = 0 -- ./compiler/lua53.can:384
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:385
if # lets > 0 then -- ./compiler/lua53.can:386
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:387
toClose = toClose + (1) -- ./compiler/lua53.can:388
for _, l in ipairs(lets) do -- ./compiler/lua53.can:389
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:390
end -- ./compiler/lua53.can:390
end -- ./compiler/lua53.can:390
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua53.can:393
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:394
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua53.can:395
if # lets > 0 then -- ./compiler/lua53.can:396
r = r .. ("else" .. indent()) -- ./compiler/lua53.can:397
toClose = toClose + (1) -- ./compiler/lua53.can:398
for _, l in ipairs(lets) do -- ./compiler/lua53.can:399
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:400
end -- ./compiler/lua53.can:400
else -- ./compiler/lua53.can:400
r = r .. ("else") -- ./compiler/lua53.can:403
end -- ./compiler/lua53.can:403
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:405
end -- ./compiler/lua53.can:405
if # t % 2 == 1 then -- ./compiler/lua53.can:407
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:408
end -- ./compiler/lua53.can:408
r = r .. ("end") -- ./compiler/lua53.can:410
for i = 1, toClose do -- ./compiler/lua53.can:411
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:412
end -- ./compiler/lua53.can:412
return r -- ./compiler/lua53.can:414
end, -- ./compiler/lua53.can:414
["Fornum"] = function(t) -- ./compiler/lua53.can:417
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:418
if # t == 5 then -- ./compiler/lua53.can:419
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:420
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:421
if hasContinue then -- ./compiler/lua53.can:422
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:423
end -- ./compiler/lua53.can:423
r = r .. (lua(t[5])) -- ./compiler/lua53.can:425
if hasContinue then -- ./compiler/lua53.can:426
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:427
end -- ./compiler/lua53.can:427
return r .. unindent() .. "end" -- ./compiler/lua53.can:429
else -- ./compiler/lua53.can:429
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:431
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:432
if hasContinue then -- ./compiler/lua53.can:433
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:434
end -- ./compiler/lua53.can:434
r = r .. (lua(t[4])) -- ./compiler/lua53.can:436
if hasContinue then -- ./compiler/lua53.can:437
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:438
end -- ./compiler/lua53.can:438
return r .. unindent() .. "end" -- ./compiler/lua53.can:440
end -- ./compiler/lua53.can:440
end, -- ./compiler/lua53.can:440
["Forin"] = function(t) -- ./compiler/lua53.can:444
local destructured = {} -- ./compiler/lua53.can:445
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:446
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:447
if hasContinue then -- ./compiler/lua53.can:448
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:449
end -- ./compiler/lua53.can:449
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua53.can:451
if hasContinue then -- ./compiler/lua53.can:452
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:453
end -- ./compiler/lua53.can:453
return r .. unindent() .. "end" -- ./compiler/lua53.can:455
end, -- ./compiler/lua53.can:455
["Local"] = function(t) -- ./compiler/lua53.can:458
local destructured = {} -- ./compiler/lua53.can:459
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua53.can:460
if t[2][1] then -- ./compiler/lua53.can:461
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:462
end -- ./compiler/lua53.can:462
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua53.can:464
end, -- ./compiler/lua53.can:464
["Let"] = function(t) -- ./compiler/lua53.can:467
local destructured = {} -- ./compiler/lua53.can:468
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua53.can:469
local r = "local " .. nameList -- ./compiler/lua53.can:470
if t[2][1] then -- ./compiler/lua53.can:471
if all(t[2], { -- ./compiler/lua53.can:472
"Nil", -- ./compiler/lua53.can:472
"Dots", -- ./compiler/lua53.can:472
"Boolean", -- ./compiler/lua53.can:472
"Number", -- ./compiler/lua53.can:472
"String" -- ./compiler/lua53.can:472
}) then -- ./compiler/lua53.can:472
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:473
else -- ./compiler/lua53.can:473
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:475
end -- ./compiler/lua53.can:475
end -- ./compiler/lua53.can:475
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua53.can:478
end, -- ./compiler/lua53.can:478
["Localrec"] = function(t) -- ./compiler/lua53.can:481
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:482
end, -- ./compiler/lua53.can:482
["Goto"] = function(t) -- ./compiler/lua53.can:485
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:486
end, -- ./compiler/lua53.can:486
["Label"] = function(t) -- ./compiler/lua53.can:489
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:490
end, -- ./compiler/lua53.can:490
["Return"] = function(t) -- ./compiler/lua53.can:493
local push = peek("push") -- ./compiler/lua53.can:494
if push then -- ./compiler/lua53.can:495
local r = "" -- ./compiler/lua53.can:496
for _, val in ipairs(t) do -- ./compiler/lua53.can:497
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:498
end -- ./compiler/lua53.can:498
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:500
else -- ./compiler/lua53.can:500
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:502
end -- ./compiler/lua53.can:502
end, -- ./compiler/lua53.can:502
["Push"] = function(t) -- ./compiler/lua53.can:506
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:507
r = "" -- ./compiler/lua53.can:508
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:509
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:510
end -- ./compiler/lua53.can:510
if t[# t] then -- ./compiler/lua53.can:512
if t[# t]["tag"] == "Call" then -- ./compiler/lua53.can:513
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:514
else -- ./compiler/lua53.can:514
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:516
end -- ./compiler/lua53.can:516
end -- ./compiler/lua53.can:516
return r -- ./compiler/lua53.can:519
end, -- ./compiler/lua53.can:519
["Break"] = function() -- ./compiler/lua53.can:522
return "break" -- ./compiler/lua53.can:523
end, -- ./compiler/lua53.can:523
["Continue"] = function() -- ./compiler/lua53.can:526
return "goto " .. var("continue") -- ./compiler/lua53.can:527
end, -- ./compiler/lua53.can:527
["Nil"] = function() -- ./compiler/lua53.can:534
return "nil" -- ./compiler/lua53.can:535
end, -- ./compiler/lua53.can:535
["Dots"] = function() -- ./compiler/lua53.can:538
return "..." -- ./compiler/lua53.can:539
end, -- ./compiler/lua53.can:539
["Boolean"] = function(t) -- ./compiler/lua53.can:542
return tostring(t[1]) -- ./compiler/lua53.can:543
end, -- ./compiler/lua53.can:543
["Number"] = function(t) -- ./compiler/lua53.can:546
return tostring(t[1]) -- ./compiler/lua53.can:547
end, -- ./compiler/lua53.can:547
["String"] = function(t) -- ./compiler/lua53.can:550
return ("%q"):format(t[1]) -- ./compiler/lua53.can:551
end, -- ./compiler/lua53.can:551
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:554
local r = "(" -- ./compiler/lua53.can:555
local decl = {} -- ./compiler/lua53.can:556
if t[1][1] then -- ./compiler/lua53.can:557
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:558
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:559
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:560
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:561
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:562
r = r .. (id) -- ./compiler/lua53.can:563
else -- ./compiler/lua53.can:563
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:565
end -- ./compiler/lua53.can:565
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:567
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:568
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:569
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:570
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:571
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:572
r = r .. (", " .. id) -- ./compiler/lua53.can:573
else -- ./compiler/lua53.can:573
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
r = r .. (")" .. indent()) -- ./compiler/lua53.can:579
for _, d in ipairs(decl) do -- ./compiler/lua53.can:580
r = r .. (d .. newline()) -- ./compiler/lua53.can:581
end -- ./compiler/lua53.can:581
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua53.can:583
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:584
end -- ./compiler/lua53.can:584
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:586
if hasPush then -- ./compiler/lua53.can:587
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:588
else -- ./compiler/lua53.can:588
push("push", false) -- ./compiler/lua53.can:590
end -- ./compiler/lua53.can:590
r = r .. (lua(t[2])) -- ./compiler/lua53.can:592
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua53.can:593
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:594
end -- ./compiler/lua53.can:594
pop("push") -- ./compiler/lua53.can:596
return r .. unindent() .. "end" -- ./compiler/lua53.can:597
end, -- ./compiler/lua53.can:597
["Function"] = function(t) -- ./compiler/lua53.can:599
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:600
end, -- ./compiler/lua53.can:600
["Pair"] = function(t) -- ./compiler/lua53.can:603
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:604
end, -- ./compiler/lua53.can:604
["Table"] = function(t) -- ./compiler/lua53.can:606
if # t == 0 then -- ./compiler/lua53.can:607
return "{}" -- ./compiler/lua53.can:608
elseif # t == 1 then -- ./compiler/lua53.can:609
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:610
else -- ./compiler/lua53.can:610
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:612
end -- ./compiler/lua53.can:612
end, -- ./compiler/lua53.can:612
["TableCompr"] = function(t) -- ./compiler/lua53.can:616
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:617
end, -- ./compiler/lua53.can:617
["Op"] = function(t) -- ./compiler/lua53.can:620
local r -- ./compiler/lua53.can:621
if # t == 2 then -- ./compiler/lua53.can:622
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:623
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:624
else -- ./compiler/lua53.can:624
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:626
end -- ./compiler/lua53.can:626
else -- ./compiler/lua53.can:626
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:629
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:630
else -- ./compiler/lua53.can:630
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
return r -- ./compiler/lua53.can:635
end, -- ./compiler/lua53.can:635
["Paren"] = function(t) -- ./compiler/lua53.can:638
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:639
end, -- ./compiler/lua53.can:639
["MethodStub"] = function(t) -- ./compiler/lua53.can:642
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:648
end, -- ./compiler/lua53.can:648
["SafeMethodStub"] = function(t) -- ./compiler/lua53.can:651
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:658
end, -- ./compiler/lua53.can:658
["LetExpr"] = function(t) -- ./compiler/lua53.can:665
return lua(t[1][1]) -- ./compiler/lua53.can:666
end, -- ./compiler/lua53.can:666
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:670
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:671
local r = "(function()" .. indent() -- ./compiler/lua53.can:672
if hasPush then -- ./compiler/lua53.can:673
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:674
else -- ./compiler/lua53.can:674
push("push", false) -- ./compiler/lua53.can:676
end -- ./compiler/lua53.can:676
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:678
if hasPush then -- ./compiler/lua53.can:679
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:680
end -- ./compiler/lua53.can:680
pop("push") -- ./compiler/lua53.can:682
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:683
return r -- ./compiler/lua53.can:684
end, -- ./compiler/lua53.can:684
["DoExpr"] = function(t) -- ./compiler/lua53.can:687
if t[# t]["tag"] == "Push" then -- ./compiler/lua53.can:688
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:689
end -- ./compiler/lua53.can:689
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:691
end, -- ./compiler/lua53.can:691
["WhileExpr"] = function(t) -- ./compiler/lua53.can:694
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:695
end, -- ./compiler/lua53.can:695
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:698
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:699
end, -- ./compiler/lua53.can:699
["IfExpr"] = function(t) -- ./compiler/lua53.can:702
for i = 2, # t do -- ./compiler/lua53.can:703
local block = t[i] -- ./compiler/lua53.can:704
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:705
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:706
end -- ./compiler/lua53.can:706
end -- ./compiler/lua53.can:706
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:709
end, -- ./compiler/lua53.can:709
["FornumExpr"] = function(t) -- ./compiler/lua53.can:712
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:713
end, -- ./compiler/lua53.can:713
["ForinExpr"] = function(t) -- ./compiler/lua53.can:716
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:717
end, -- ./compiler/lua53.can:717
["Call"] = function(t) -- ./compiler/lua53.can:723
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:724
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:725
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua53.can:726
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua53.can:727
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:728
else -- ./compiler/lua53.can:728
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:730
end -- ./compiler/lua53.can:730
else -- ./compiler/lua53.can:730
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:733
end -- ./compiler/lua53.can:733
end, -- ./compiler/lua53.can:733
["SafeCall"] = function(t) -- ./compiler/lua53.can:737
if t[1]["tag"] ~= "Id" then -- ./compiler/lua53.can:738
return lua(t, "SafeIndex") -- ./compiler/lua53.can:739
else -- ./compiler/lua53.can:739
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua53.can:741
end -- ./compiler/lua53.can:741
end, -- ./compiler/lua53.can:741
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:746
if start == nil then start = 1 end -- ./compiler/lua53.can:746
local r -- ./compiler/lua53.can:747
if t[start] then -- ./compiler/lua53.can:748
r = lua(t[start]) -- ./compiler/lua53.can:749
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:750
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:751
end -- ./compiler/lua53.can:751
else -- ./compiler/lua53.can:751
r = "" -- ./compiler/lua53.can:754
end -- ./compiler/lua53.can:754
return r -- ./compiler/lua53.can:756
end, -- ./compiler/lua53.can:756
["Id"] = function(t) -- ./compiler/lua53.can:759
return t[1] -- ./compiler/lua53.can:760
end, -- ./compiler/lua53.can:760
["DestructuringId"] = function(t) -- ./compiler/lua53.can:763
if t["id"] then -- ./compiler/lua53.can:764
return t["id"] -- ./compiler/lua53.can:765
else -- ./compiler/lua53.can:765
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua53.can:767
local vars = { ["id"] = tmp() } -- ./compiler/lua53.can:768
for j = 1, # t, 1 do -- ./compiler/lua53.can:769
table["insert"](vars, t[j]) -- ./compiler/lua53.can:770
end -- ./compiler/lua53.can:770
table["insert"](d, vars) -- ./compiler/lua53.can:772
t["id"] = vars["id"] -- ./compiler/lua53.can:773
return vars["id"] -- ./compiler/lua53.can:774
end -- ./compiler/lua53.can:774
end, -- ./compiler/lua53.can:774
["Index"] = function(t) -- ./compiler/lua53.can:778
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:779
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:780
else -- ./compiler/lua53.can:780
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:782
end -- ./compiler/lua53.can:782
end, -- ./compiler/lua53.can:782
["SafeIndex"] = function(t) -- ./compiler/lua53.can:786
if t[1]["tag"] ~= "Id" then -- ./compiler/lua53.can:787
local l = {} -- ./compiler/lua53.can:788
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:789
table["insert"](l, 1, t) -- ./compiler/lua53.can:790
t = t[1] -- ./compiler/lua53.can:791
end -- ./compiler/lua53.can:791
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua53.can:793
for _, e in ipairs(l) do -- ./compiler/lua53.can:794
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua53.can:795
if e["tag"] == "SafeIndex" then -- ./compiler/lua53.can:796
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua53.can:797
else -- ./compiler/lua53.can:797
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua53.can:799
end -- ./compiler/lua53.can:799
end -- ./compiler/lua53.can:799
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua53.can:802
return r -- ./compiler/lua53.can:803
else -- ./compiler/lua53.can:803
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua53.can:805
end -- ./compiler/lua53.can:805
end, -- ./compiler/lua53.can:805
["_opid"] = { -- ./compiler/lua53.can:810
["add"] = "+", -- ./compiler/lua53.can:811
["sub"] = "-", -- ./compiler/lua53.can:811
["mul"] = "*", -- ./compiler/lua53.can:811
["div"] = "/", -- ./compiler/lua53.can:811
["idiv"] = "//", -- ./compiler/lua53.can:812
["mod"] = "%", -- ./compiler/lua53.can:812
["pow"] = "^", -- ./compiler/lua53.can:812
["concat"] = "..", -- ./compiler/lua53.can:812
["band"] = "&", -- ./compiler/lua53.can:813
["bor"] = "|", -- ./compiler/lua53.can:813
["bxor"] = "~", -- ./compiler/lua53.can:813
["shl"] = "<<", -- ./compiler/lua53.can:813
["shr"] = ">>", -- ./compiler/lua53.can:813
["eq"] = "==", -- ./compiler/lua53.can:814
["ne"] = "~=", -- ./compiler/lua53.can:814
["lt"] = "<", -- ./compiler/lua53.can:814
["gt"] = ">", -- ./compiler/lua53.can:814
["le"] = "<=", -- ./compiler/lua53.can:814
["ge"] = ">=", -- ./compiler/lua53.can:814
["and"] = "and", -- ./compiler/lua53.can:815
["or"] = "or", -- ./compiler/lua53.can:815
["unm"] = "-", -- ./compiler/lua53.can:815
["len"] = "#", -- ./compiler/lua53.can:815
["bnot"] = "~", -- ./compiler/lua53.can:815
["not"] = "not" -- ./compiler/lua53.can:815
} -- ./compiler/lua53.can:815
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:818
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua53.can:819
end }) -- ./compiler/lua53.can:819
targetName = "LuaJIT" -- ./compiler/luajit.can:1
UNPACK = function(list, i, j) -- ./compiler/luajit.can:3
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/luajit.can:4
end -- ./compiler/luajit.can:4
APPEND = function(t, toAppend) -- ./compiler/luajit.can:6
return "do" .. indent() .. "local a, p = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #a do" .. indent() .. t .. "[p] = a[i]" .. newline() .. "p = p + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/luajit.can:7
end -- ./compiler/luajit.can:7
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/luajit.can:10
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/luajit.can:11
end -- ./compiler/luajit.can:11
tags["_opid"]["band"] = function(left, right) -- ./compiler/luajit.can:13
addRequire("bit", "band", "band") -- ./compiler/luajit.can:14
return var("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:15
end -- ./compiler/luajit.can:15
tags["_opid"]["bor"] = function(left, right) -- ./compiler/luajit.can:17
addRequire("bit", "bor", "bor") -- ./compiler/luajit.can:18
return var("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:19
end -- ./compiler/luajit.can:19
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/luajit.can:21
addRequire("bit", "bxor", "bxor") -- ./compiler/luajit.can:22
return var("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:23
end -- ./compiler/luajit.can:23
tags["_opid"]["shl"] = function(left, right) -- ./compiler/luajit.can:25
addRequire("bit", "lshift", "lshift") -- ./compiler/luajit.can:26
return var("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:27
end -- ./compiler/luajit.can:27
tags["_opid"]["shr"] = function(left, right) -- ./compiler/luajit.can:29
addRequire("bit", "rshift", "rshift") -- ./compiler/luajit.can:30
return var("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:31
end -- ./compiler/luajit.can:31
tags["_opid"]["bnot"] = function(right) -- ./compiler/luajit.can:33
addRequire("bit", "bnot", "bnot") -- ./compiler/luajit.can:34
return var("bnot") .. "(" .. lua(right) .. ")" -- ./compiler/luajit.can:35
end -- ./compiler/luajit.can:35
local code = lua(ast) .. newline() -- ./compiler/lua53.can:825
return requireStr .. code -- ./compiler/lua53.can:826
end -- ./compiler/lua53.can:826
end -- ./compiler/lua53.can:826
local lua53 = _() or lua53 -- ./compiler/lua53.can:831
return lua53 -- ./compiler/luajit.can:44
end -- ./compiler/luajit.can:44
local luajit = _() or luajit -- ./compiler/luajit.can:48
package["loaded"]["compiler.luajit"] = luajit or true -- ./compiler/luajit.can:49
local function _() -- ./compiler/luajit.can:52
local function _() -- ./compiler/luajit.can:54
local function _() -- ./compiler/luajit.can:56
local targetName = "Lua 5.3" -- ./compiler/lua53.can:1
return function(code, ast, options) -- ./compiler/lua53.can:3
local lastInputPos = 1 -- ./compiler/lua53.can:5
local prevLinePos = 1 -- ./compiler/lua53.can:6
local lastSource = options["chunkname"] or "nil" -- ./compiler/lua53.can:7
local lastLine = 1 -- ./compiler/lua53.can:8
local indentLevel = 0 -- ./compiler/lua53.can:11
local function newline() -- ./compiler/lua53.can:13
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua53.can:14
if options["mapLines"] then -- ./compiler/lua53.can:15
local sub = code:sub(lastInputPos) -- ./compiler/lua53.can:16
local source, line = sub:sub(1, sub:find("\
")):match(".*%-%- (.-)%:(%d+)\
") -- ./compiler/lua53.can:17
if source and line then -- ./compiler/lua53.can:19
lastSource = source -- ./compiler/lua53.can:20
lastLine = tonumber(line) -- ./compiler/lua53.can:21
else -- ./compiler/lua53.can:21
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua53.can:23
lastLine = lastLine + (1) -- ./compiler/lua53.can:24
end -- ./compiler/lua53.can:24
end -- ./compiler/lua53.can:24
prevLinePos = lastInputPos -- ./compiler/lua53.can:28
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua53.can:30
end -- ./compiler/lua53.can:30
return r -- ./compiler/lua53.can:32
end -- ./compiler/lua53.can:32
local function indent() -- ./compiler/lua53.can:35
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:36
return newline() -- ./compiler/lua53.can:37
end -- ./compiler/lua53.can:37
local function unindent() -- ./compiler/lua53.can:40
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:41
return newline() -- ./compiler/lua53.can:42
end -- ./compiler/lua53.can:42
local states = { -- ./compiler/lua53.can:47
["push"] = {}, -- ./compiler/lua53.can:48
["destructuring"] = {}, -- ./compiler/lua53.can:49
["scope"] = {} -- ./compiler/lua53.can:50
} -- ./compiler/lua53.can:50
local function push(name, state) -- ./compiler/lua53.can:53
table["insert"](states[name], state) -- ./compiler/lua53.can:54
return "" -- ./compiler/lua53.can:55
end -- ./compiler/lua53.can:55
local function pop(name) -- ./compiler/lua53.can:58
table["remove"](states[name]) -- ./compiler/lua53.can:59
return "" -- ./compiler/lua53.can:60
end -- ./compiler/lua53.can:60
local function set(name, state) -- ./compiler/lua53.can:63
states[name][# states[name]] = state -- ./compiler/lua53.can:64
return "" -- ./compiler/lua53.can:65
end -- ./compiler/lua53.can:65
local function peek(name) -- ./compiler/lua53.can:68
return states[name][# states[name]] -- ./compiler/lua53.can:69
end -- ./compiler/lua53.can:69
local function var(name) -- ./compiler/lua53.can:74
return options["variablePrefix"] .. name -- ./compiler/lua53.can:75
end -- ./compiler/lua53.can:75
local function tmp() -- ./compiler/lua53.can:79
local scope = peek("scope") -- ./compiler/lua53.can:80
local var = ("%s_%s"):format(options["variablePrefix"], # scope) -- ./compiler/lua53.can:81
table["insert"](scope, var) -- ./compiler/lua53.can:82
return var -- ./compiler/lua53.can:83
end -- ./compiler/lua53.can:83
local required = {} -- ./compiler/lua53.can:87
local requireStr = "" -- ./compiler/lua53.can:88
local function addRequire(mod, name, field) -- ./compiler/lua53.can:90
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua53.can:91
if not required[req] then -- ./compiler/lua53.can:92
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua53.can:93
required[req] = true -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
local loop = { -- ./compiler/lua53.can:99
"While", -- ./compiler/lua53.can:99
"Repeat", -- ./compiler/lua53.can:99
"Fornum", -- ./compiler/lua53.can:99
"Forin", -- ./compiler/lua53.can:99
"WhileExpr", -- ./compiler/lua53.can:99
"RepeatExpr", -- ./compiler/lua53.can:99
"FornumExpr", -- ./compiler/lua53.can:99
"ForinExpr" -- ./compiler/lua53.can:99
} -- ./compiler/lua53.can:99
local func = { -- ./compiler/lua53.can:100
"Function", -- ./compiler/lua53.can:100
"TableCompr", -- ./compiler/lua53.can:100
"DoExpr", -- ./compiler/lua53.can:100
"WhileExpr", -- ./compiler/lua53.can:100
"RepeatExpr", -- ./compiler/lua53.can:100
"IfExpr", -- ./compiler/lua53.can:100
"FornumExpr", -- ./compiler/lua53.can:100
"ForinExpr" -- ./compiler/lua53.can:100
} -- ./compiler/lua53.can:100
local function any(list, tags, nofollow) -- ./compiler/lua53.can:104
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:104
local tagsCheck = {} -- ./compiler/lua53.can:105
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:106
tagsCheck[tag] = true -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
local nofollowCheck = {} -- ./compiler/lua53.can:109
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:110
nofollowCheck[tag] = true -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
for _, node in ipairs(list) do -- ./compiler/lua53.can:113
if type(node) == "table" then -- ./compiler/lua53.can:114
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:115
return node -- ./compiler/lua53.can:116
end -- ./compiler/lua53.can:116
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:118
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:119
if r then -- ./compiler/lua53.can:120
return r -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
return nil -- ./compiler/lua53.can:124
end -- ./compiler/lua53.can:124
local function search(list, tags, nofollow) -- ./compiler/lua53.can:129
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:129
local tagsCheck = {} -- ./compiler/lua53.can:130
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:131
tagsCheck[tag] = true -- ./compiler/lua53.can:132
end -- ./compiler/lua53.can:132
local nofollowCheck = {} -- ./compiler/lua53.can:134
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:135
nofollowCheck[tag] = true -- ./compiler/lua53.can:136
end -- ./compiler/lua53.can:136
local found = {} -- ./compiler/lua53.can:138
for _, node in ipairs(list) do -- ./compiler/lua53.can:139
if type(node) == "table" then -- ./compiler/lua53.can:140
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:141
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua53.can:142
table["insert"](found, n) -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:146
table["insert"](found, node) -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
end -- ./compiler/lua53.can:147
return found -- ./compiler/lua53.can:151
end -- ./compiler/lua53.can:151
local function all(list, tags) -- ./compiler/lua53.can:155
for _, node in ipairs(list) do -- ./compiler/lua53.can:156
local ok = false -- ./compiler/lua53.can:157
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:158
if node["tag"] == tag then -- ./compiler/lua53.can:159
ok = true -- ./compiler/lua53.can:160
break -- ./compiler/lua53.can:161
end -- ./compiler/lua53.can:161
end -- ./compiler/lua53.can:161
if not ok then -- ./compiler/lua53.can:164
return false -- ./compiler/lua53.can:165
end -- ./compiler/lua53.can:165
end -- ./compiler/lua53.can:165
return true -- ./compiler/lua53.can:168
end -- ./compiler/lua53.can:168
local tags -- ./compiler/lua53.can:172
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:174
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:175
lastInputPos = ast["pos"] -- ./compiler/lua53.can:176
end -- ./compiler/lua53.can:176
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:178
end -- ./compiler/lua53.can:178
local UNPACK = function(list, i, j) -- ./compiler/lua53.can:182
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:183
end -- ./compiler/lua53.can:183
local APPEND = function(t, toAppend) -- ./compiler/lua53.can:185
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local CONTINUE_START = function() -- ./compiler/lua53.can:188
return "do" .. indent() -- ./compiler/lua53.can:189
end -- ./compiler/lua53.can:189
local CONTINUE_STOP = function() -- ./compiler/lua53.can:191
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:192
end -- ./compiler/lua53.can:192
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- ./compiler/lua53.can:194
if newlineAfter == nil then newlineAfter = false end -- ./compiler/lua53.can:194
if noLocal == nil then noLocal = false end -- ./compiler/lua53.can:194
local vars = {} -- ./compiler/lua53.can:195
local values = {} -- ./compiler/lua53.can:196
for _, list in ipairs(destructured) do -- ./compiler/lua53.can:197
for _, v in ipairs(list) do -- ./compiler/lua53.can:198
local var, val -- ./compiler/lua53.can:199
if v["tag"] == "Id" then -- ./compiler/lua53.can:200
var = v -- ./compiler/lua53.can:201
val = { -- ./compiler/lua53.can:202
["tag"] = "Index", -- ./compiler/lua53.can:202
{ -- ./compiler/lua53.can:202
["tag"] = "Id", -- ./compiler/lua53.can:202
list["id"] -- ./compiler/lua53.can:202
}, -- ./compiler/lua53.can:202
{ -- ./compiler/lua53.can:202
["tag"] = "String", -- ./compiler/lua53.can:202
v[1] -- ./compiler/lua53.can:202
} -- ./compiler/lua53.can:202
} -- ./compiler/lua53.can:202
elseif v["tag"] == "Pair" then -- ./compiler/lua53.can:203
var = v[2] -- ./compiler/lua53.can:204
val = { -- ./compiler/lua53.can:205
["tag"] = "Index", -- ./compiler/lua53.can:205
{ -- ./compiler/lua53.can:205
["tag"] = "Id", -- ./compiler/lua53.can:205
list["id"] -- ./compiler/lua53.can:205
}, -- ./compiler/lua53.can:205
v[1] -- ./compiler/lua53.can:205
} -- ./compiler/lua53.can:205
else -- ./compiler/lua53.can:205
error("unknown destructuring element type: " .. tostring(v["tag"])) -- ./compiler/lua53.can:207
end -- ./compiler/lua53.can:207
if destructured["rightOp"] and destructured["leftOp"] then -- ./compiler/lua53.can:209
val = { -- ./compiler/lua53.can:210
["tag"] = "Op", -- ./compiler/lua53.can:210
destructured["rightOp"], -- ./compiler/lua53.can:210
var, -- ./compiler/lua53.can:210
{ -- ./compiler/lua53.can:210
["tag"] = "Op", -- ./compiler/lua53.can:210
destructured["leftOp"], -- ./compiler/lua53.can:210
val, -- ./compiler/lua53.can:210
var -- ./compiler/lua53.can:210
} -- ./compiler/lua53.can:210
} -- ./compiler/lua53.can:210
elseif destructured["rightOp"] then -- ./compiler/lua53.can:211
val = { -- ./compiler/lua53.can:212
["tag"] = "Op", -- ./compiler/lua53.can:212
destructured["rightOp"], -- ./compiler/lua53.can:212
var, -- ./compiler/lua53.can:212
val -- ./compiler/lua53.can:212
} -- ./compiler/lua53.can:212
elseif destructured["leftOp"] then -- ./compiler/lua53.can:213
val = { -- ./compiler/lua53.can:214
["tag"] = "Op", -- ./compiler/lua53.can:214
destructured["leftOp"], -- ./compiler/lua53.can:214
val, -- ./compiler/lua53.can:214
var -- ./compiler/lua53.can:214
} -- ./compiler/lua53.can:214
end -- ./compiler/lua53.can:214
table["insert"](vars, lua(var)) -- ./compiler/lua53.can:216
table["insert"](values, lua(val)) -- ./compiler/lua53.can:217
end -- ./compiler/lua53.can:217
end -- ./compiler/lua53.can:217
if # vars > 0 then -- ./compiler/lua53.can:220
local decl = noLocal and "" or "local " -- ./compiler/lua53.can:221
if newlineAfter then -- ./compiler/lua53.can:222
return decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") .. newline() -- ./compiler/lua53.can:223
else -- ./compiler/lua53.can:223
return newline() .. decl .. table["concat"](vars, ", ") .. " = " .. table["concat"](values, ", ") -- ./compiler/lua53.can:225
end -- ./compiler/lua53.can:225
else -- ./compiler/lua53.can:225
return "" -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
tags = setmetatable({ -- ./compiler/lua53.can:233
["Block"] = function(t) -- ./compiler/lua53.can:235
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- ./compiler/lua53.can:236
if hasPush and hasPush == t[# t] then -- ./compiler/lua53.can:237
hasPush["tag"] = "Return" -- ./compiler/lua53.can:238
hasPush = false -- ./compiler/lua53.can:239
end -- ./compiler/lua53.can:239
local r = push("scope", {}) -- ./compiler/lua53.can:241
if hasPush then -- ./compiler/lua53.can:242
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:243
end -- ./compiler/lua53.can:243
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:245
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
if t[# t] then -- ./compiler/lua53.can:248
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:249
end -- ./compiler/lua53.can:249
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- ./compiler/lua53.can:251
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:252
end -- ./compiler/lua53.can:252
return r .. pop("scope") -- ./compiler/lua53.can:254
end, -- ./compiler/lua53.can:254
["Do"] = function(t) -- ./compiler/lua53.can:260
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:261
end, -- ./compiler/lua53.can:261
["Set"] = function(t) -- ./compiler/lua53.can:264
local expr = t[# t] -- ./compiler/lua53.can:266
local vars, values = {}, {} -- ./compiler/lua53.can:267
local destructuringVars, destructuringValues = {}, {} -- ./compiler/lua53.can:268
for i, n in ipairs(t[1]) do -- ./compiler/lua53.can:269
if n["tag"] == "DestructuringId" then -- ./compiler/lua53.can:270
table["insert"](destructuringVars, n) -- ./compiler/lua53.can:271
table["insert"](destructuringValues, expr[i]) -- ./compiler/lua53.can:272
else -- ./compiler/lua53.can:272
table["insert"](vars, n) -- ./compiler/lua53.can:274
table["insert"](values, expr[i]) -- ./compiler/lua53.can:275
end -- ./compiler/lua53.can:275
end -- ./compiler/lua53.can:275
if # t == 2 or # t == 3 then -- ./compiler/lua53.can:279
local r = "" -- ./compiler/lua53.can:280
if # vars > 0 then -- ./compiler/lua53.can:281
r = lua(vars, "_lhs") .. " = " .. lua(values, "_lhs") -- ./compiler/lua53.can:282
end -- ./compiler/lua53.can:282
if # destructuringVars > 0 then -- ./compiler/lua53.can:284
local destructured = {} -- ./compiler/lua53.can:285
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:286
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:287
end -- ./compiler/lua53.can:287
return r -- ./compiler/lua53.can:289
elseif # t == 4 then -- ./compiler/lua53.can:290
if t[3] == "=" then -- ./compiler/lua53.can:291
local r = "" -- ./compiler/lua53.can:292
if # vars > 0 then -- ./compiler/lua53.can:293
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:294
t[2], -- ./compiler/lua53.can:294
vars[1], -- ./compiler/lua53.can:294
{ -- ./compiler/lua53.can:294
["tag"] = "Paren", -- ./compiler/lua53.can:294
values[1] -- ./compiler/lua53.can:294
} -- ./compiler/lua53.can:294
}, "Op")) -- ./compiler/lua53.can:294
for i = 2, math["min"](# t[4], # vars), 1 do -- ./compiler/lua53.can:295
r = r .. (", " .. lua({ -- ./compiler/lua53.can:296
t[2], -- ./compiler/lua53.can:296
vars[i], -- ./compiler/lua53.can:296
{ -- ./compiler/lua53.can:296
["tag"] = "Paren", -- ./compiler/lua53.can:296
values[i] -- ./compiler/lua53.can:296
} -- ./compiler/lua53.can:296
}, "Op")) -- ./compiler/lua53.can:296
end -- ./compiler/lua53.can:296
end -- ./compiler/lua53.can:296
if # destructuringVars > 0 then -- ./compiler/lua53.can:299
local destructured = { ["rightOp"] = t[2] } -- ./compiler/lua53.can:300
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:301
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:302
end -- ./compiler/lua53.can:302
return r -- ./compiler/lua53.can:304
else -- ./compiler/lua53.can:304
local r = "" -- ./compiler/lua53.can:306
if # vars > 0 then -- ./compiler/lua53.can:307
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:308
t[3], -- ./compiler/lua53.can:308
{ -- ./compiler/lua53.can:308
["tag"] = "Paren", -- ./compiler/lua53.can:308
values[1] -- ./compiler/lua53.can:308
}, -- ./compiler/lua53.can:308
vars[1] -- ./compiler/lua53.can:308
}, "Op")) -- ./compiler/lua53.can:308
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:309
r = r .. (", " .. lua({ -- ./compiler/lua53.can:310
t[3], -- ./compiler/lua53.can:310
{ -- ./compiler/lua53.can:310
["tag"] = "Paren", -- ./compiler/lua53.can:310
values[i] -- ./compiler/lua53.can:310
}, -- ./compiler/lua53.can:310
vars[i] -- ./compiler/lua53.can:310
}, "Op")) -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
if # destructuringVars > 0 then -- ./compiler/lua53.can:313
local destructured = { ["leftOp"] = t[3] } -- ./compiler/lua53.can:314
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:315
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:316
end -- ./compiler/lua53.can:316
return r -- ./compiler/lua53.can:318
end -- ./compiler/lua53.can:318
else -- ./compiler/lua53.can:318
local r = "" -- ./compiler/lua53.can:321
if # vars > 0 then -- ./compiler/lua53.can:322
r = r .. (lua(vars, "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:323
t[2], -- ./compiler/lua53.can:323
vars[1], -- ./compiler/lua53.can:323
{ -- ./compiler/lua53.can:323
["tag"] = "Op", -- ./compiler/lua53.can:323
t[4], -- ./compiler/lua53.can:323
{ -- ./compiler/lua53.can:323
["tag"] = "Paren", -- ./compiler/lua53.can:323
values[1] -- ./compiler/lua53.can:323
}, -- ./compiler/lua53.can:323
vars[1] -- ./compiler/lua53.can:323
} -- ./compiler/lua53.can:323
}, "Op")) -- ./compiler/lua53.can:323
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:324
r = r .. (", " .. lua({ -- ./compiler/lua53.can:325
t[2], -- ./compiler/lua53.can:325
vars[i], -- ./compiler/lua53.can:325
{ -- ./compiler/lua53.can:325
["tag"] = "Op", -- ./compiler/lua53.can:325
t[4], -- ./compiler/lua53.can:325
{ -- ./compiler/lua53.can:325
["tag"] = "Paren", -- ./compiler/lua53.can:325
values[i] -- ./compiler/lua53.can:325
}, -- ./compiler/lua53.can:325
vars[i] -- ./compiler/lua53.can:325
} -- ./compiler/lua53.can:325
}, "Op")) -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
if # destructuringVars > 0 then -- ./compiler/lua53.can:328
local destructured = { -- ./compiler/lua53.can:329
["rightOp"] = t[2], -- ./compiler/lua53.can:329
["leftOp"] = t[4] -- ./compiler/lua53.can:329
} -- ./compiler/lua53.can:329
r = r .. ("local " .. push("destructuring", destructured) .. lua(destructuringVars, "_lhs") .. pop("destructuring") .. " = " .. lua(destructuringValues, "_lhs")) -- ./compiler/lua53.can:330
return r .. DESTRUCTURING_ASSIGN(destructured, nil, true) -- ./compiler/lua53.can:331
end -- ./compiler/lua53.can:331
return r -- ./compiler/lua53.can:333
end -- ./compiler/lua53.can:333
end, -- ./compiler/lua53.can:333
["While"] = function(t) -- ./compiler/lua53.can:337
local r = "" -- ./compiler/lua53.can:338
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:339
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:340
if # lets > 0 then -- ./compiler/lua53.can:341
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:342
for _, l in ipairs(lets) do -- ./compiler/lua53.can:343
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:344
end -- ./compiler/lua53.can:344
end -- ./compiler/lua53.can:344
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua53.can:347
if # lets > 0 then -- ./compiler/lua53.can:348
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:349
end -- ./compiler/lua53.can:349
if hasContinue then -- ./compiler/lua53.can:351
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:352
end -- ./compiler/lua53.can:352
r = r .. (lua(t[2])) -- ./compiler/lua53.can:354
if hasContinue then -- ./compiler/lua53.can:355
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:356
end -- ./compiler/lua53.can:356
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:358
if # lets > 0 then -- ./compiler/lua53.can:359
for _, l in ipairs(lets) do -- ./compiler/lua53.can:360
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua53.can:361
end -- ./compiler/lua53.can:361
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua53.can:363
end -- ./compiler/lua53.can:363
return r -- ./compiler/lua53.can:365
end, -- ./compiler/lua53.can:365
["Repeat"] = function(t) -- ./compiler/lua53.can:368
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:369
local r = "repeat" .. indent() -- ./compiler/lua53.can:370
if hasContinue then -- ./compiler/lua53.can:371
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:372
end -- ./compiler/lua53.can:372
r = r .. (lua(t[1])) -- ./compiler/lua53.can:374
if hasContinue then -- ./compiler/lua53.can:375
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:376
end -- ./compiler/lua53.can:376
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:378
return r -- ./compiler/lua53.can:379
end, -- ./compiler/lua53.can:379
["If"] = function(t) -- ./compiler/lua53.can:382
local r = "" -- ./compiler/lua53.can:383
local toClose = 0 -- ./compiler/lua53.can:384
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:385
if # lets > 0 then -- ./compiler/lua53.can:386
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:387
toClose = toClose + (1) -- ./compiler/lua53.can:388
for _, l in ipairs(lets) do -- ./compiler/lua53.can:389
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:390
end -- ./compiler/lua53.can:390
end -- ./compiler/lua53.can:390
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua53.can:393
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:394
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua53.can:395
if # lets > 0 then -- ./compiler/lua53.can:396
r = r .. ("else" .. indent()) -- ./compiler/lua53.can:397
toClose = toClose + (1) -- ./compiler/lua53.can:398
for _, l in ipairs(lets) do -- ./compiler/lua53.can:399
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:400
end -- ./compiler/lua53.can:400
else -- ./compiler/lua53.can:400
r = r .. ("else") -- ./compiler/lua53.can:403
end -- ./compiler/lua53.can:403
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:405
end -- ./compiler/lua53.can:405
if # t % 2 == 1 then -- ./compiler/lua53.can:407
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:408
end -- ./compiler/lua53.can:408
r = r .. ("end") -- ./compiler/lua53.can:410
for i = 1, toClose do -- ./compiler/lua53.can:411
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:412
end -- ./compiler/lua53.can:412
return r -- ./compiler/lua53.can:414
end, -- ./compiler/lua53.can:414
["Fornum"] = function(t) -- ./compiler/lua53.can:417
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:418
if # t == 5 then -- ./compiler/lua53.can:419
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:420
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:421
if hasContinue then -- ./compiler/lua53.can:422
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:423
end -- ./compiler/lua53.can:423
r = r .. (lua(t[5])) -- ./compiler/lua53.can:425
if hasContinue then -- ./compiler/lua53.can:426
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:427
end -- ./compiler/lua53.can:427
return r .. unindent() .. "end" -- ./compiler/lua53.can:429
else -- ./compiler/lua53.can:429
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:431
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:432
if hasContinue then -- ./compiler/lua53.can:433
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:434
end -- ./compiler/lua53.can:434
r = r .. (lua(t[4])) -- ./compiler/lua53.can:436
if hasContinue then -- ./compiler/lua53.can:437
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:438
end -- ./compiler/lua53.can:438
return r .. unindent() .. "end" -- ./compiler/lua53.can:440
end -- ./compiler/lua53.can:440
end, -- ./compiler/lua53.can:440
["Forin"] = function(t) -- ./compiler/lua53.can:444
local destructured = {} -- ./compiler/lua53.can:445
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:446
local r = "for " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:447
if hasContinue then -- ./compiler/lua53.can:448
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:449
end -- ./compiler/lua53.can:449
r = r .. (DESTRUCTURING_ASSIGN(destructured, true) .. lua(t[3])) -- ./compiler/lua53.can:451
if hasContinue then -- ./compiler/lua53.can:452
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:453
end -- ./compiler/lua53.can:453
return r .. unindent() .. "end" -- ./compiler/lua53.can:455
end, -- ./compiler/lua53.can:455
["Local"] = function(t) -- ./compiler/lua53.can:458
local destructured = {} -- ./compiler/lua53.can:459
local r = "local " .. push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua53.can:460
if t[2][1] then -- ./compiler/lua53.can:461
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:462
end -- ./compiler/lua53.can:462
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua53.can:464
end, -- ./compiler/lua53.can:464
["Let"] = function(t) -- ./compiler/lua53.can:467
local destructured = {} -- ./compiler/lua53.can:468
local nameList = push("destructuring", destructured) .. lua(t[1], "_lhs") .. pop("destructuring") -- ./compiler/lua53.can:469
local r = "local " .. nameList -- ./compiler/lua53.can:470
if t[2][1] then -- ./compiler/lua53.can:471
if all(t[2], { -- ./compiler/lua53.can:472
"Nil", -- ./compiler/lua53.can:472
"Dots", -- ./compiler/lua53.can:472
"Boolean", -- ./compiler/lua53.can:472
"Number", -- ./compiler/lua53.can:472
"String" -- ./compiler/lua53.can:472
}) then -- ./compiler/lua53.can:472
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:473
else -- ./compiler/lua53.can:473
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:475
end -- ./compiler/lua53.can:475
end -- ./compiler/lua53.can:475
return r .. DESTRUCTURING_ASSIGN(destructured) -- ./compiler/lua53.can:478
end, -- ./compiler/lua53.can:478
["Localrec"] = function(t) -- ./compiler/lua53.can:481
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:482
end, -- ./compiler/lua53.can:482
["Goto"] = function(t) -- ./compiler/lua53.can:485
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:486
end, -- ./compiler/lua53.can:486
["Label"] = function(t) -- ./compiler/lua53.can:489
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:490
end, -- ./compiler/lua53.can:490
["Return"] = function(t) -- ./compiler/lua53.can:493
local push = peek("push") -- ./compiler/lua53.can:494
if push then -- ./compiler/lua53.can:495
local r = "" -- ./compiler/lua53.can:496
for _, val in ipairs(t) do -- ./compiler/lua53.can:497
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:498
end -- ./compiler/lua53.can:498
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:500
else -- ./compiler/lua53.can:500
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:502
end -- ./compiler/lua53.can:502
end, -- ./compiler/lua53.can:502
["Push"] = function(t) -- ./compiler/lua53.can:506
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:507
r = "" -- ./compiler/lua53.can:508
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:509
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:510
end -- ./compiler/lua53.can:510
if t[# t] then -- ./compiler/lua53.can:512
if t[# t]["tag"] == "Call" then -- ./compiler/lua53.can:513
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:514
else -- ./compiler/lua53.can:514
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:516
end -- ./compiler/lua53.can:516
end -- ./compiler/lua53.can:516
return r -- ./compiler/lua53.can:519
end, -- ./compiler/lua53.can:519
["Break"] = function() -- ./compiler/lua53.can:522
return "break" -- ./compiler/lua53.can:523
end, -- ./compiler/lua53.can:523
["Continue"] = function() -- ./compiler/lua53.can:526
return "goto " .. var("continue") -- ./compiler/lua53.can:527
end, -- ./compiler/lua53.can:527
["Nil"] = function() -- ./compiler/lua53.can:534
return "nil" -- ./compiler/lua53.can:535
end, -- ./compiler/lua53.can:535
["Dots"] = function() -- ./compiler/lua53.can:538
return "..." -- ./compiler/lua53.can:539
end, -- ./compiler/lua53.can:539
["Boolean"] = function(t) -- ./compiler/lua53.can:542
return tostring(t[1]) -- ./compiler/lua53.can:543
end, -- ./compiler/lua53.can:543
["Number"] = function(t) -- ./compiler/lua53.can:546
return tostring(t[1]) -- ./compiler/lua53.can:547
end, -- ./compiler/lua53.can:547
["String"] = function(t) -- ./compiler/lua53.can:550
return ("%q"):format(t[1]) -- ./compiler/lua53.can:551
end, -- ./compiler/lua53.can:551
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:554
local r = "(" -- ./compiler/lua53.can:555
local decl = {} -- ./compiler/lua53.can:556
if t[1][1] then -- ./compiler/lua53.can:557
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:558
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:559
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:560
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:561
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:562
r = r .. (id) -- ./compiler/lua53.can:563
else -- ./compiler/lua53.can:563
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:565
end -- ./compiler/lua53.can:565
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:567
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:568
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:569
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:570
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:571
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:572
r = r .. (", " .. id) -- ./compiler/lua53.can:573
else -- ./compiler/lua53.can:573
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
end -- ./compiler/lua53.can:575
r = r .. (")" .. indent()) -- ./compiler/lua53.can:579
for _, d in ipairs(decl) do -- ./compiler/lua53.can:580
r = r .. (d .. newline()) -- ./compiler/lua53.can:581
end -- ./compiler/lua53.can:581
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- ./compiler/lua53.can:583
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:584
end -- ./compiler/lua53.can:584
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:586
if hasPush then -- ./compiler/lua53.can:587
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:588
else -- ./compiler/lua53.can:588
push("push", false) -- ./compiler/lua53.can:590
end -- ./compiler/lua53.can:590
r = r .. (lua(t[2])) -- ./compiler/lua53.can:592
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- ./compiler/lua53.can:593
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:594
end -- ./compiler/lua53.can:594
pop("push") -- ./compiler/lua53.can:596
return r .. unindent() .. "end" -- ./compiler/lua53.can:597
end, -- ./compiler/lua53.can:597
["Function"] = function(t) -- ./compiler/lua53.can:599
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:600
end, -- ./compiler/lua53.can:600
["Pair"] = function(t) -- ./compiler/lua53.can:603
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:604
end, -- ./compiler/lua53.can:604
["Table"] = function(t) -- ./compiler/lua53.can:606
if # t == 0 then -- ./compiler/lua53.can:607
return "{}" -- ./compiler/lua53.can:608
elseif # t == 1 then -- ./compiler/lua53.can:609
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:610
else -- ./compiler/lua53.can:610
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:612
end -- ./compiler/lua53.can:612
end, -- ./compiler/lua53.can:612
["TableCompr"] = function(t) -- ./compiler/lua53.can:616
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:617
end, -- ./compiler/lua53.can:617
["Op"] = function(t) -- ./compiler/lua53.can:620
local r -- ./compiler/lua53.can:621
if # t == 2 then -- ./compiler/lua53.can:622
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:623
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:624
else -- ./compiler/lua53.can:624
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:626
end -- ./compiler/lua53.can:626
else -- ./compiler/lua53.can:626
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:629
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:630
else -- ./compiler/lua53.can:630
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
return r -- ./compiler/lua53.can:635
end, -- ./compiler/lua53.can:635
["Paren"] = function(t) -- ./compiler/lua53.can:638
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:639
end, -- ./compiler/lua53.can:639
["MethodStub"] = function(t) -- ./compiler/lua53.can:642
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:648
end, -- ./compiler/lua53.can:648
["SafeMethodStub"] = function(t) -- ./compiler/lua53.can:651
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:658
end, -- ./compiler/lua53.can:658
["LetExpr"] = function(t) -- ./compiler/lua53.can:665
return lua(t[1][1]) -- ./compiler/lua53.can:666
end, -- ./compiler/lua53.can:666
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:670
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:671
local r = "(function()" .. indent() -- ./compiler/lua53.can:672
if hasPush then -- ./compiler/lua53.can:673
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:674
else -- ./compiler/lua53.can:674
push("push", false) -- ./compiler/lua53.can:676
end -- ./compiler/lua53.can:676
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:678
if hasPush then -- ./compiler/lua53.can:679
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:680
end -- ./compiler/lua53.can:680
pop("push") -- ./compiler/lua53.can:682
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:683
return r -- ./compiler/lua53.can:684
end, -- ./compiler/lua53.can:684
["DoExpr"] = function(t) -- ./compiler/lua53.can:687
if t[# t]["tag"] == "Push" then -- ./compiler/lua53.can:688
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:689
end -- ./compiler/lua53.can:689
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:691
end, -- ./compiler/lua53.can:691
["WhileExpr"] = function(t) -- ./compiler/lua53.can:694
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:695
end, -- ./compiler/lua53.can:695
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:698
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:699
end, -- ./compiler/lua53.can:699
["IfExpr"] = function(t) -- ./compiler/lua53.can:702
for i = 2, # t do -- ./compiler/lua53.can:703
local block = t[i] -- ./compiler/lua53.can:704
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:705
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:706
end -- ./compiler/lua53.can:706
end -- ./compiler/lua53.can:706
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:709
end, -- ./compiler/lua53.can:709
["FornumExpr"] = function(t) -- ./compiler/lua53.can:712
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:713
end, -- ./compiler/lua53.can:713
["ForinExpr"] = function(t) -- ./compiler/lua53.can:716
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:717
end, -- ./compiler/lua53.can:717
["Call"] = function(t) -- ./compiler/lua53.can:723
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:724
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:725
elseif t[1]["tag"] == "MethodStub" then -- ./compiler/lua53.can:726
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua53.can:727
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:728
else -- ./compiler/lua53.can:728
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:730
end -- ./compiler/lua53.can:730
else -- ./compiler/lua53.can:730
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:733
end -- ./compiler/lua53.can:733
end, -- ./compiler/lua53.can:733
["SafeCall"] = function(t) -- ./compiler/lua53.can:737
if t[1]["tag"] ~= "Id" then -- ./compiler/lua53.can:738
return lua(t, "SafeIndex") -- ./compiler/lua53.can:739
else -- ./compiler/lua53.can:739
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua53.can:741
end -- ./compiler/lua53.can:741
end, -- ./compiler/lua53.can:741
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:746
if start == nil then start = 1 end -- ./compiler/lua53.can:746
local r -- ./compiler/lua53.can:747
if t[start] then -- ./compiler/lua53.can:748
r = lua(t[start]) -- ./compiler/lua53.can:749
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:750
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:751
end -- ./compiler/lua53.can:751
else -- ./compiler/lua53.can:751
r = "" -- ./compiler/lua53.can:754
end -- ./compiler/lua53.can:754
return r -- ./compiler/lua53.can:756
end, -- ./compiler/lua53.can:756
["Id"] = function(t) -- ./compiler/lua53.can:759
return t[1] -- ./compiler/lua53.can:760
end, -- ./compiler/lua53.can:760
["DestructuringId"] = function(t) -- ./compiler/lua53.can:763
if t["id"] then -- ./compiler/lua53.can:764
return t["id"] -- ./compiler/lua53.can:765
else -- ./compiler/lua53.can:765
local d = assert(peek("destructuring"), "DestructuringId not in a destructurable assignement") -- ./compiler/lua53.can:767
local vars = { ["id"] = tmp() } -- ./compiler/lua53.can:768
for j = 1, # t, 1 do -- ./compiler/lua53.can:769
table["insert"](vars, t[j]) -- ./compiler/lua53.can:770
end -- ./compiler/lua53.can:770
table["insert"](d, vars) -- ./compiler/lua53.can:772
t["id"] = vars["id"] -- ./compiler/lua53.can:773
return vars["id"] -- ./compiler/lua53.can:774
end -- ./compiler/lua53.can:774
end, -- ./compiler/lua53.can:774
["Index"] = function(t) -- ./compiler/lua53.can:778
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:779
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:780
else -- ./compiler/lua53.can:780
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:782
end -- ./compiler/lua53.can:782
end, -- ./compiler/lua53.can:782
["SafeIndex"] = function(t) -- ./compiler/lua53.can:786
if t[1]["tag"] ~= "Id" then -- ./compiler/lua53.can:787
local l = {} -- ./compiler/lua53.can:788
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:789
table["insert"](l, 1, t) -- ./compiler/lua53.can:790
t = t[1] -- ./compiler/lua53.can:791
end -- ./compiler/lua53.can:791
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- ./compiler/lua53.can:793
for _, e in ipairs(l) do -- ./compiler/lua53.can:794
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua53.can:795
if e["tag"] == "SafeIndex" then -- ./compiler/lua53.can:796
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua53.can:797
else -- ./compiler/lua53.can:797
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua53.can:799
end -- ./compiler/lua53.can:799
end -- ./compiler/lua53.can:799
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua53.can:802
return r -- ./compiler/lua53.can:803
else -- ./compiler/lua53.can:803
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua53.can:805
end -- ./compiler/lua53.can:805
end, -- ./compiler/lua53.can:805
["_opid"] = { -- ./compiler/lua53.can:810
["add"] = "+", -- ./compiler/lua53.can:811
["sub"] = "-", -- ./compiler/lua53.can:811
["mul"] = "*", -- ./compiler/lua53.can:811
["div"] = "/", -- ./compiler/lua53.can:811
["idiv"] = "//", -- ./compiler/lua53.can:812
["mod"] = "%", -- ./compiler/lua53.can:812
["pow"] = "^", -- ./compiler/lua53.can:812
["concat"] = "..", -- ./compiler/lua53.can:812
["band"] = "&", -- ./compiler/lua53.can:813
["bor"] = "|", -- ./compiler/lua53.can:813
["bxor"] = "~", -- ./compiler/lua53.can:813
["shl"] = "<<", -- ./compiler/lua53.can:813
["shr"] = ">>", -- ./compiler/lua53.can:813
["eq"] = "==", -- ./compiler/lua53.can:814
["ne"] = "~=", -- ./compiler/lua53.can:814
["lt"] = "<", -- ./compiler/lua53.can:814
["gt"] = ">", -- ./compiler/lua53.can:814
["le"] = "<=", -- ./compiler/lua53.can:814
["ge"] = ">=", -- ./compiler/lua53.can:814
["and"] = "and", -- ./compiler/lua53.can:815
["or"] = "or", -- ./compiler/lua53.can:815
["unm"] = "-", -- ./compiler/lua53.can:815
["len"] = "#", -- ./compiler/lua53.can:815
["bnot"] = "~", -- ./compiler/lua53.can:815
["not"] = "not" -- ./compiler/lua53.can:815
} -- ./compiler/lua53.can:815
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:818
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua53.can:819
end }) -- ./compiler/lua53.can:819
targetName = "LuaJIT" -- ./compiler/luajit.can:1
UNPACK = function(list, i, j) -- ./compiler/luajit.can:3
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/luajit.can:4
end -- ./compiler/luajit.can:4
APPEND = function(t, toAppend) -- ./compiler/luajit.can:6
return "do" .. indent() .. "local a, p = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #a do" .. indent() .. t .. "[p] = a[i]" .. newline() .. "p = p + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/luajit.can:7
end -- ./compiler/luajit.can:7
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/luajit.can:10
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/luajit.can:11
end -- ./compiler/luajit.can:11
tags["_opid"]["band"] = function(left, right) -- ./compiler/luajit.can:13
addRequire("bit", "band", "band") -- ./compiler/luajit.can:14
return var("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:15
end -- ./compiler/luajit.can:15
tags["_opid"]["bor"] = function(left, right) -- ./compiler/luajit.can:17
addRequire("bit", "bor", "bor") -- ./compiler/luajit.can:18
return var("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:19
end -- ./compiler/luajit.can:19
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/luajit.can:21
addRequire("bit", "bxor", "bxor") -- ./compiler/luajit.can:22
return var("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:23
end -- ./compiler/luajit.can:23
tags["_opid"]["shl"] = function(left, right) -- ./compiler/luajit.can:25
addRequire("bit", "lshift", "lshift") -- ./compiler/luajit.can:26
return var("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:27
end -- ./compiler/luajit.can:27
tags["_opid"]["shr"] = function(left, right) -- ./compiler/luajit.can:29
addRequire("bit", "rshift", "rshift") -- ./compiler/luajit.can:30
return var("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:31
end -- ./compiler/luajit.can:31
tags["_opid"]["bnot"] = function(right) -- ./compiler/luajit.can:33
addRequire("bit", "bnot", "bnot") -- ./compiler/luajit.can:34
return var("bnot") .. "(" .. lua(right) .. ")" -- ./compiler/luajit.can:35
end -- ./compiler/luajit.can:35
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
tags["Goto"] = nil -- ./compiler/lua51.can:25
tags["Label"] = nil -- ./compiler/lua51.can:26
local code = lua(ast) .. newline() -- ./compiler/lua53.can:825
return requireStr .. code -- ./compiler/lua53.can:826
end -- ./compiler/lua53.can:826
end -- ./compiler/lua53.can:826
local lua53 = _() or lua53 -- ./compiler/lua53.can:831
return lua53 -- ./compiler/luajit.can:44
end -- ./compiler/luajit.can:44
local luajit = _() or luajit -- ./compiler/luajit.can:48
return luajit -- ./compiler/lua51.can:32
end -- ./compiler/lua51.can:32
local lua51 = _() or lua51 -- ./compiler/lua51.can:36
package["loaded"]["compiler.lua51"] = lua51 or true -- ./compiler/lua51.can:37
local function _() -- ./compiler/lua51.can:41
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
"expected a function definition or assignment after let" -- ./candran/can-parser/parser.lua:116
}, -- ./candran/can-parser/parser.lua:116
{ -- ./candran/can-parser/parser.lua:117
"ErrNameLFunc", -- ./candran/can-parser/parser.lua:117
"expected a function name after 'function'" -- ./candran/can-parser/parser.lua:117
}, -- ./candran/can-parser/parser.lua:117
{ -- ./candran/can-parser/parser.lua:118
"ErrEListLAssign", -- ./candran/can-parser/parser.lua:118
"expected one or more expressions after '='" -- ./candran/can-parser/parser.lua:118
}, -- ./candran/can-parser/parser.lua:118
{ -- ./candran/can-parser/parser.lua:119
"ErrEListAssign", -- ./candran/can-parser/parser.lua:119
"expected one or more expressions after '='" -- ./candran/can-parser/parser.lua:119
}, -- ./candran/can-parser/parser.lua:119
{ -- ./candran/can-parser/parser.lua:121
"ErrFuncName", -- ./candran/can-parser/parser.lua:121
"expected a function name after 'function'" -- ./candran/can-parser/parser.lua:121
}, -- ./candran/can-parser/parser.lua:121
{ -- ./candran/can-parser/parser.lua:122
"ErrNameFunc1", -- ./candran/can-parser/parser.lua:122
"expected a function name after '.'" -- ./candran/can-parser/parser.lua:122
}, -- ./candran/can-parser/parser.lua:122
{ -- ./candran/can-parser/parser.lua:123
"ErrNameFunc2", -- ./candran/can-parser/parser.lua:123
"expected a method name after ':'" -- ./candran/can-parser/parser.lua:123
}, -- ./candran/can-parser/parser.lua:123
{ -- ./candran/can-parser/parser.lua:124
"ErrOParenPList", -- ./candran/can-parser/parser.lua:124
"expected '(' for the parameter list" -- ./candran/can-parser/parser.lua:124
}, -- ./candran/can-parser/parser.lua:124
{ -- ./candran/can-parser/parser.lua:125
"ErrCParenPList", -- ./candran/can-parser/parser.lua:125
"expected ')' to close the parameter list" -- ./candran/can-parser/parser.lua:125
}, -- ./candran/can-parser/parser.lua:125
{ -- ./candran/can-parser/parser.lua:126
"ErrEndFunc", -- ./candran/can-parser/parser.lua:126
"expected 'end' to close the function body" -- ./candran/can-parser/parser.lua:126
}, -- ./candran/can-parser/parser.lua:126
{ -- ./candran/can-parser/parser.lua:127
"ErrParList", -- ./candran/can-parser/parser.lua:127
"expected a variable name or '...' after ','" -- ./candran/can-parser/parser.lua:127
}, -- ./candran/can-parser/parser.lua:127
{ -- ./candran/can-parser/parser.lua:129
"ErrLabel", -- ./candran/can-parser/parser.lua:129
"expected a label name after '::'" -- ./candran/can-parser/parser.lua:129
}, -- ./candran/can-parser/parser.lua:129
{ -- ./candran/can-parser/parser.lua:130
"ErrCloseLabel", -- ./candran/can-parser/parser.lua:130
"expected '::' after the label" -- ./candran/can-parser/parser.lua:130
}, -- ./candran/can-parser/parser.lua:130
{ -- ./candran/can-parser/parser.lua:131
"ErrGoto", -- ./candran/can-parser/parser.lua:131
"expected a label after 'goto'" -- ./candran/can-parser/parser.lua:131
}, -- ./candran/can-parser/parser.lua:131
{ -- ./candran/can-parser/parser.lua:132
"ErrRetList", -- ./candran/can-parser/parser.lua:132
"expected an expression after ',' in the return statement" -- ./candran/can-parser/parser.lua:132
}, -- ./candran/can-parser/parser.lua:132
{ -- ./candran/can-parser/parser.lua:134
"ErrVarList", -- ./candran/can-parser/parser.lua:134
"expected a variable name after ','" -- ./candran/can-parser/parser.lua:134
}, -- ./candran/can-parser/parser.lua:134
{ -- ./candran/can-parser/parser.lua:135
"ErrExprList", -- ./candran/can-parser/parser.lua:135
"expected an expression after ','" -- ./candran/can-parser/parser.lua:135
}, -- ./candran/can-parser/parser.lua:135
{ -- ./candran/can-parser/parser.lua:137
"ErrOrExpr", -- ./candran/can-parser/parser.lua:137
"expected an expression after 'or'" -- ./candran/can-parser/parser.lua:137
}, -- ./candran/can-parser/parser.lua:137
{ -- ./candran/can-parser/parser.lua:138
"ErrAndExpr", -- ./candran/can-parser/parser.lua:138
"expected an expression after 'and'" -- ./candran/can-parser/parser.lua:138
}, -- ./candran/can-parser/parser.lua:138
{ -- ./candran/can-parser/parser.lua:139
"ErrRelExpr", -- ./candran/can-parser/parser.lua:139
"expected an expression after the relational operator" -- ./candran/can-parser/parser.lua:139
}, -- ./candran/can-parser/parser.lua:139
{ -- ./candran/can-parser/parser.lua:140
"ErrBOrExpr", -- ./candran/can-parser/parser.lua:140
"expected an expression after '|'" -- ./candran/can-parser/parser.lua:140
}, -- ./candran/can-parser/parser.lua:140
{ -- ./candran/can-parser/parser.lua:141
"ErrBXorExpr", -- ./candran/can-parser/parser.lua:141
"expected an expression after '~'" -- ./candran/can-parser/parser.lua:141
}, -- ./candran/can-parser/parser.lua:141
{ -- ./candran/can-parser/parser.lua:142
"ErrBAndExpr", -- ./candran/can-parser/parser.lua:142
"expected an expression after '&'" -- ./candran/can-parser/parser.lua:142
}, -- ./candran/can-parser/parser.lua:142
{ -- ./candran/can-parser/parser.lua:143
"ErrShiftExpr", -- ./candran/can-parser/parser.lua:143
"expected an expression after the bit shift" -- ./candran/can-parser/parser.lua:143
}, -- ./candran/can-parser/parser.lua:143
{ -- ./candran/can-parser/parser.lua:144
"ErrConcatExpr", -- ./candran/can-parser/parser.lua:144
"expected an expression after '..'" -- ./candran/can-parser/parser.lua:144
}, -- ./candran/can-parser/parser.lua:144
{ -- ./candran/can-parser/parser.lua:145
"ErrAddExpr", -- ./candran/can-parser/parser.lua:145
"expected an expression after the additive operator" -- ./candran/can-parser/parser.lua:145
}, -- ./candran/can-parser/parser.lua:145
{ -- ./candran/can-parser/parser.lua:146
"ErrMulExpr", -- ./candran/can-parser/parser.lua:146
"expected an expression after the multiplicative operator" -- ./candran/can-parser/parser.lua:146
}, -- ./candran/can-parser/parser.lua:146
{ -- ./candran/can-parser/parser.lua:147
"ErrUnaryExpr", -- ./candran/can-parser/parser.lua:147
"expected an expression after the unary operator" -- ./candran/can-parser/parser.lua:147
}, -- ./candran/can-parser/parser.lua:147
{ -- ./candran/can-parser/parser.lua:148
"ErrPowExpr", -- ./candran/can-parser/parser.lua:148
"expected an expression after '^'" -- ./candran/can-parser/parser.lua:148
}, -- ./candran/can-parser/parser.lua:148
{ -- ./candran/can-parser/parser.lua:150
"ErrExprParen", -- ./candran/can-parser/parser.lua:150
"expected an expression after '('" -- ./candran/can-parser/parser.lua:150
}, -- ./candran/can-parser/parser.lua:150
{ -- ./candran/can-parser/parser.lua:151
"ErrCParenExpr", -- ./candran/can-parser/parser.lua:151
"expected ')' to close the expression" -- ./candran/can-parser/parser.lua:151
}, -- ./candran/can-parser/parser.lua:151
{ -- ./candran/can-parser/parser.lua:152
"ErrNameIndex", -- ./candran/can-parser/parser.lua:152
"expected a field name after '.'" -- ./candran/can-parser/parser.lua:152
}, -- ./candran/can-parser/parser.lua:152
{ -- ./candran/can-parser/parser.lua:153
"ErrExprIndex", -- ./candran/can-parser/parser.lua:153
"expected an expression after '['" -- ./candran/can-parser/parser.lua:153
}, -- ./candran/can-parser/parser.lua:153
{ -- ./candran/can-parser/parser.lua:154
"ErrCBracketIndex", -- ./candran/can-parser/parser.lua:154
"expected ']' to close the indexing expression" -- ./candran/can-parser/parser.lua:154
}, -- ./candran/can-parser/parser.lua:154
{ -- ./candran/can-parser/parser.lua:155
"ErrNameMeth", -- ./candran/can-parser/parser.lua:155
"expected a method name after ':'" -- ./candran/can-parser/parser.lua:155
}, -- ./candran/can-parser/parser.lua:155
{ -- ./candran/can-parser/parser.lua:156
"ErrMethArgs", -- ./candran/can-parser/parser.lua:156
"expected some arguments for the method call (or '()')" -- ./candran/can-parser/parser.lua:156
}, -- ./candran/can-parser/parser.lua:156
{ -- ./candran/can-parser/parser.lua:158
"ErrArgList", -- ./candran/can-parser/parser.lua:158
"expected an expression after ',' in the argument list" -- ./candran/can-parser/parser.lua:158
}, -- ./candran/can-parser/parser.lua:158
{ -- ./candran/can-parser/parser.lua:159
"ErrCParenArgs", -- ./candran/can-parser/parser.lua:159
"expected ')' to close the argument list" -- ./candran/can-parser/parser.lua:159
}, -- ./candran/can-parser/parser.lua:159
{ -- ./candran/can-parser/parser.lua:161
"ErrCBraceTable", -- ./candran/can-parser/parser.lua:161
"expected '}' to close the table constructor" -- ./candran/can-parser/parser.lua:161
}, -- ./candran/can-parser/parser.lua:161
{ -- ./candran/can-parser/parser.lua:162
"ErrEqField", -- ./candran/can-parser/parser.lua:162
"expected '=' after the table key" -- ./candran/can-parser/parser.lua:162
}, -- ./candran/can-parser/parser.lua:162
{ -- ./candran/can-parser/parser.lua:163
"ErrExprField", -- ./candran/can-parser/parser.lua:163
"expected an expression after '='" -- ./candran/can-parser/parser.lua:163
}, -- ./candran/can-parser/parser.lua:163
{ -- ./candran/can-parser/parser.lua:164
"ErrExprFKey", -- ./candran/can-parser/parser.lua:164
"expected an expression after '[' for the table key" -- ./candran/can-parser/parser.lua:164
}, -- ./candran/can-parser/parser.lua:164
{ -- ./candran/can-parser/parser.lua:165
"ErrCBracketFKey", -- ./candran/can-parser/parser.lua:165
"expected ']' to close the table key" -- ./candran/can-parser/parser.lua:165
}, -- ./candran/can-parser/parser.lua:165
{ -- ./candran/can-parser/parser.lua:167
"ErrCBraceDestructuring", -- ./candran/can-parser/parser.lua:167
"expected '}' to close the destructuring variable list" -- ./candran/can-parser/parser.lua:167
}, -- ./candran/can-parser/parser.lua:167
{ -- ./candran/can-parser/parser.lua:168
"ErrDestructuringEqField", -- ./candran/can-parser/parser.lua:168
"expected '=' after the table key in destructuring variable list" -- ./candran/can-parser/parser.lua:168
}, -- ./candran/can-parser/parser.lua:168
{ -- ./candran/can-parser/parser.lua:169
"ErrDestructuringExprField", -- ./candran/can-parser/parser.lua:169
"expected an identifier after '=' in destructuring variable list" -- ./candran/can-parser/parser.lua:169
}, -- ./candran/can-parser/parser.lua:169
{ -- ./candran/can-parser/parser.lua:171
"ErrCBracketTableCompr", -- ./candran/can-parser/parser.lua:171
"expected ']' to close the table comprehension" -- ./candran/can-parser/parser.lua:171
}, -- ./candran/can-parser/parser.lua:171
{ -- ./candran/can-parser/parser.lua:173
"ErrDigitHex", -- ./candran/can-parser/parser.lua:173
"expected one or more hexadecimal digits after '0x'" -- ./candran/can-parser/parser.lua:173
}, -- ./candran/can-parser/parser.lua:173
{ -- ./candran/can-parser/parser.lua:174
"ErrDigitDeci", -- ./candran/can-parser/parser.lua:174
"expected one or more digits after the decimal point" -- ./candran/can-parser/parser.lua:174
}, -- ./candran/can-parser/parser.lua:174
{ -- ./candran/can-parser/parser.lua:175
"ErrDigitExpo", -- ./candran/can-parser/parser.lua:175
"expected one or more digits for the exponent" -- ./candran/can-parser/parser.lua:175
}, -- ./candran/can-parser/parser.lua:175
{ -- ./candran/can-parser/parser.lua:177
"ErrQuote", -- ./candran/can-parser/parser.lua:177
"unclosed string" -- ./candran/can-parser/parser.lua:177
}, -- ./candran/can-parser/parser.lua:177
{ -- ./candran/can-parser/parser.lua:178
"ErrHexEsc", -- ./candran/can-parser/parser.lua:178
"expected exactly two hexadecimal digits after '\\x'" -- ./candran/can-parser/parser.lua:178
}, -- ./candran/can-parser/parser.lua:178
{ -- ./candran/can-parser/parser.lua:179
"ErrOBraceUEsc", -- ./candran/can-parser/parser.lua:179
"expected '{' after '\\u'" -- ./candran/can-parser/parser.lua:179
}, -- ./candran/can-parser/parser.lua:179
{ -- ./candran/can-parser/parser.lua:180
"ErrDigitUEsc", -- ./candran/can-parser/parser.lua:180
"expected one or more hexadecimal digits for the UTF-8 code point" -- ./candran/can-parser/parser.lua:180
}, -- ./candran/can-parser/parser.lua:180
{ -- ./candran/can-parser/parser.lua:181
"ErrCBraceUEsc", -- ./candran/can-parser/parser.lua:181
"expected '}' after the code point" -- ./candran/can-parser/parser.lua:181
}, -- ./candran/can-parser/parser.lua:181
{ -- ./candran/can-parser/parser.lua:182
"ErrEscSeq", -- ./candran/can-parser/parser.lua:182
"invalid escape sequence" -- ./candran/can-parser/parser.lua:182
}, -- ./candran/can-parser/parser.lua:182
{ -- ./candran/can-parser/parser.lua:183
"ErrCloseLStr", -- ./candran/can-parser/parser.lua:183
"unclosed long string" -- ./candran/can-parser/parser.lua:183
} -- ./candran/can-parser/parser.lua:183
} -- ./candran/can-parser/parser.lua:183
local function throw(label) -- ./candran/can-parser/parser.lua:186
label = "Err" .. label -- ./candran/can-parser/parser.lua:187
for i, labelinfo in ipairs(labels) do -- ./candran/can-parser/parser.lua:188
if labelinfo[1] == label then -- ./candran/can-parser/parser.lua:189
return T(i) -- ./candran/can-parser/parser.lua:190
end -- ./candran/can-parser/parser.lua:190
end -- ./candran/can-parser/parser.lua:190
error("Label not found: " .. label) -- ./candran/can-parser/parser.lua:194
end -- ./candran/can-parser/parser.lua:194
local function expect(patt, label) -- ./candran/can-parser/parser.lua:197
return patt + throw(label) -- ./candran/can-parser/parser.lua:198
end -- ./candran/can-parser/parser.lua:198
local function token(patt) -- ./candran/can-parser/parser.lua:204
return patt * V("Skip") -- ./candran/can-parser/parser.lua:205
end -- ./candran/can-parser/parser.lua:205
local function sym(str) -- ./candran/can-parser/parser.lua:208
return token(P(str)) -- ./candran/can-parser/parser.lua:209
end -- ./candran/can-parser/parser.lua:209
local function kw(str) -- ./candran/can-parser/parser.lua:212
return token(P(str) * - V("IdRest")) -- ./candran/can-parser/parser.lua:213
end -- ./candran/can-parser/parser.lua:213
local function tagC(tag, patt) -- ./candran/can-parser/parser.lua:216
return Ct(Cg(Cp(), "pos") * Cg(Cc(tag), "tag") * patt) -- ./candran/can-parser/parser.lua:217
end -- ./candran/can-parser/parser.lua:217
local function unaryOp(op, e) -- ./candran/can-parser/parser.lua:220
return { -- ./candran/can-parser/parser.lua:221
["tag"] = "Op", -- ./candran/can-parser/parser.lua:221
["pos"] = e["pos"], -- ./candran/can-parser/parser.lua:221
[1] = op, -- ./candran/can-parser/parser.lua:221
[2] = e -- ./candran/can-parser/parser.lua:221
} -- ./candran/can-parser/parser.lua:221
end -- ./candran/can-parser/parser.lua:221
local function binaryOp(e1, op, e2) -- ./candran/can-parser/parser.lua:224
if not op then -- ./candran/can-parser/parser.lua:225
return e1 -- ./candran/can-parser/parser.lua:226
else -- ./candran/can-parser/parser.lua:226
return { -- ./candran/can-parser/parser.lua:228
["tag"] = "Op", -- ./candran/can-parser/parser.lua:228
["pos"] = e1["pos"], -- ./candran/can-parser/parser.lua:228
[1] = op, -- ./candran/can-parser/parser.lua:228
[2] = e1, -- ./candran/can-parser/parser.lua:228
[3] = e2 -- ./candran/can-parser/parser.lua:228
} -- ./candran/can-parser/parser.lua:228
end -- ./candran/can-parser/parser.lua:228
end -- ./candran/can-parser/parser.lua:228
local function sepBy(patt, sep, label) -- ./candran/can-parser/parser.lua:232
if label then -- ./candran/can-parser/parser.lua:233
return patt * Cg(sep * expect(patt, label)) ^ 0 -- ./candran/can-parser/parser.lua:234
else -- ./candran/can-parser/parser.lua:234
return patt * Cg(sep * patt) ^ 0 -- ./candran/can-parser/parser.lua:236
end -- ./candran/can-parser/parser.lua:236
end -- ./candran/can-parser/parser.lua:236
local function chainOp(patt, sep, label) -- ./candran/can-parser/parser.lua:240
return Cf(sepBy(patt, sep, label), binaryOp) -- ./candran/can-parser/parser.lua:241
end -- ./candran/can-parser/parser.lua:241
local function commaSep(patt, label) -- ./candran/can-parser/parser.lua:244
return sepBy(patt, sym(","), label) -- ./candran/can-parser/parser.lua:245
end -- ./candran/can-parser/parser.lua:245
local function tagDo(block) -- ./candran/can-parser/parser.lua:248
block["tag"] = "Do" -- ./candran/can-parser/parser.lua:249
return block -- ./candran/can-parser/parser.lua:250
end -- ./candran/can-parser/parser.lua:250
local function fixFuncStat(func) -- ./candran/can-parser/parser.lua:253
if func[1]["is_method"] then -- ./candran/can-parser/parser.lua:254
table["insert"](func[2][1], 1, { -- ./candran/can-parser/parser.lua:254
["tag"] = "Id", -- ./candran/can-parser/parser.lua:254
[1] = "self" -- ./candran/can-parser/parser.lua:254
}) -- ./candran/can-parser/parser.lua:254
end -- ./candran/can-parser/parser.lua:254
func[1] = { func[1] } -- ./candran/can-parser/parser.lua:255
func[2] = { func[2] } -- ./candran/can-parser/parser.lua:256
return func -- ./candran/can-parser/parser.lua:257
end -- ./candran/can-parser/parser.lua:257
local function addDots(params, dots) -- ./candran/can-parser/parser.lua:260
if dots then -- ./candran/can-parser/parser.lua:261
table["insert"](params, dots) -- ./candran/can-parser/parser.lua:261
end -- ./candran/can-parser/parser.lua:261
return params -- ./candran/can-parser/parser.lua:262
end -- ./candran/can-parser/parser.lua:262
local function insertIndex(t, index) -- ./candran/can-parser/parser.lua:265
return { -- ./candran/can-parser/parser.lua:266
["tag"] = "Index", -- ./candran/can-parser/parser.lua:266
["pos"] = t["pos"], -- ./candran/can-parser/parser.lua:266
[1] = t, -- ./candran/can-parser/parser.lua:266
[2] = index -- ./candran/can-parser/parser.lua:266
} -- ./candran/can-parser/parser.lua:266
end -- ./candran/can-parser/parser.lua:266
local function markMethod(t, method) -- ./candran/can-parser/parser.lua:269
if method then -- ./candran/can-parser/parser.lua:270
return { -- ./candran/can-parser/parser.lua:271
["tag"] = "Index", -- ./candran/can-parser/parser.lua:271
["pos"] = t["pos"], -- ./candran/can-parser/parser.lua:271
["is_method"] = true, -- ./candran/can-parser/parser.lua:271
[1] = t, -- ./candran/can-parser/parser.lua:271
[2] = method -- ./candran/can-parser/parser.lua:271
} -- ./candran/can-parser/parser.lua:271
end -- ./candran/can-parser/parser.lua:271
return t -- ./candran/can-parser/parser.lua:273
end -- ./candran/can-parser/parser.lua:273
local function makeSuffixedExpr(t1, t2) -- ./candran/can-parser/parser.lua:276
if t2["tag"] == "Call" or t2["tag"] == "SafeCall" then -- ./candran/can-parser/parser.lua:277
local t = { -- ./candran/can-parser/parser.lua:278
["tag"] = t2["tag"], -- ./candran/can-parser/parser.lua:278
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:278
[1] = t1 -- ./candran/can-parser/parser.lua:278
} -- ./candran/can-parser/parser.lua:278
for k, v in ipairs(t2) do -- ./candran/can-parser/parser.lua:279
table["insert"](t, v) -- ./candran/can-parser/parser.lua:280
end -- ./candran/can-parser/parser.lua:280
return t -- ./candran/can-parser/parser.lua:282
elseif t2["tag"] == "MethodStub" or t2["tag"] == "SafeMethodStub" then -- ./candran/can-parser/parser.lua:283
return { -- ./candran/can-parser/parser.lua:284
["tag"] = t2["tag"], -- ./candran/can-parser/parser.lua:284
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:284
[1] = t1, -- ./candran/can-parser/parser.lua:284
[2] = t2[1] -- ./candran/can-parser/parser.lua:284
} -- ./candran/can-parser/parser.lua:284
elseif t2["tag"] == "SafeDotIndex" or t2["tag"] == "SafeArrayIndex" then -- ./candran/can-parser/parser.lua:285
return { -- ./candran/can-parser/parser.lua:286
["tag"] = "SafeIndex", -- ./candran/can-parser/parser.lua:286
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:286
[1] = t1, -- ./candran/can-parser/parser.lua:286
[2] = t2[1] -- ./candran/can-parser/parser.lua:286
} -- ./candran/can-parser/parser.lua:286
elseif t2["tag"] == "DotIndex" or t2["tag"] == "ArrayIndex" then -- ./candran/can-parser/parser.lua:287
return { -- ./candran/can-parser/parser.lua:288
["tag"] = "Index", -- ./candran/can-parser/parser.lua:288
["pos"] = t1["pos"], -- ./candran/can-parser/parser.lua:288
[1] = t1, -- ./candran/can-parser/parser.lua:288
[2] = t2[1] -- ./candran/can-parser/parser.lua:288
} -- ./candran/can-parser/parser.lua:288
else -- ./candran/can-parser/parser.lua:288
error("unexpected tag in suffixed expression") -- ./candran/can-parser/parser.lua:290
end -- ./candran/can-parser/parser.lua:290
end -- ./candran/can-parser/parser.lua:290
local function fixShortFunc(t) -- ./candran/can-parser/parser.lua:294
if t[1] == ":" then -- ./candran/can-parser/parser.lua:295
table["insert"](t[2], 1, { -- ./candran/can-parser/parser.lua:296
["tag"] = "Id", -- ./candran/can-parser/parser.lua:296
"self" -- ./candran/can-parser/parser.lua:296
}) -- ./candran/can-parser/parser.lua:296
table["remove"](t, 1) -- ./candran/can-parser/parser.lua:297
t["is_method"] = true -- ./candran/can-parser/parser.lua:298
end -- ./candran/can-parser/parser.lua:298
t["is_short"] = true -- ./candran/can-parser/parser.lua:300
return t -- ./candran/can-parser/parser.lua:301
end -- ./candran/can-parser/parser.lua:301
local function statToExpr(t) -- ./candran/can-parser/parser.lua:304
t["tag"] = t["tag"] .. "Expr" -- ./candran/can-parser/parser.lua:305
return t -- ./candran/can-parser/parser.lua:306
end -- ./candran/can-parser/parser.lua:306
local function fixStructure(t) -- ./candran/can-parser/parser.lua:309
local i = 1 -- ./candran/can-parser/parser.lua:310
while i <= # t do -- ./candran/can-parser/parser.lua:311
if type(t[i]) == "table" then -- ./candran/can-parser/parser.lua:312
fixStructure(t[i]) -- ./candran/can-parser/parser.lua:313
for j = # t[i], 1, - 1 do -- ./candran/can-parser/parser.lua:314
local stat = t[i][j] -- ./candran/can-parser/parser.lua:315
if type(stat) == "table" and stat["move_up_block"] and stat["move_up_block"] > 0 then -- ./candran/can-parser/parser.lua:316
table["remove"](t[i], j) -- ./candran/can-parser/parser.lua:317
table["insert"](t, i + 1, stat) -- ./candran/can-parser/parser.lua:318
if t["tag"] == "Block" or t["tag"] == "Do" then -- ./candran/can-parser/parser.lua:319
stat["move_up_block"] = stat["move_up_block"] - 1 -- ./candran/can-parser/parser.lua:320
end -- ./candran/can-parser/parser.lua:320
end -- ./candran/can-parser/parser.lua:320
end -- ./candran/can-parser/parser.lua:320
end -- ./candran/can-parser/parser.lua:320
i = i + 1 -- ./candran/can-parser/parser.lua:325
end -- ./candran/can-parser/parser.lua:325
return t -- ./candran/can-parser/parser.lua:327
end -- ./candran/can-parser/parser.lua:327
local function searchEndRec(block, isRecCall) -- ./candran/can-parser/parser.lua:330
for i, stat in ipairs(block) do -- ./candran/can-parser/parser.lua:331
if stat["tag"] == "Set" or stat["tag"] == "Push" or stat["tag"] == "Return" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./candran/can-parser/parser.lua:333
local exprlist -- ./candran/can-parser/parser.lua:334
if stat["tag"] == "Set" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./candran/can-parser/parser.lua:336
exprlist = stat[# stat] -- ./candran/can-parser/parser.lua:337
elseif stat["tag"] == "Push" or stat["tag"] == "Return" then -- ./candran/can-parser/parser.lua:338
exprlist = stat -- ./candran/can-parser/parser.lua:339
end -- ./candran/can-parser/parser.lua:339
local last = exprlist[# exprlist] -- ./candran/can-parser/parser.lua:342
if last["tag"] == "Function" and last["is_short"] and not last["is_method"] and # last[1] == 1 then -- ./candran/can-parser/parser.lua:346
local p = i -- ./candran/can-parser/parser.lua:347
for j, fstat in ipairs(last[2]) do -- ./candran/can-parser/parser.lua:348
p = i + j -- ./candran/can-parser/parser.lua:349
table["insert"](block, p, fstat) -- ./candran/can-parser/parser.lua:350
if stat["move_up_block"] then -- ./candran/can-parser/parser.lua:352
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + stat["move_up_block"] -- ./candran/can-parser/parser.lua:353
end -- ./candran/can-parser/parser.lua:353
if block["is_singlestatblock"] then -- ./candran/can-parser/parser.lua:356
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + 1 -- ./candran/can-parser/parser.lua:357
end -- ./candran/can-parser/parser.lua:357
end -- ./candran/can-parser/parser.lua:357
exprlist[# exprlist] = last[1] -- ./candran/can-parser/parser.lua:361
exprlist[# exprlist]["tag"] = "Paren" -- ./candran/can-parser/parser.lua:362
if not isRecCall then -- ./candran/can-parser/parser.lua:364
for j = p + 1, # block, 1 do -- ./candran/can-parser/parser.lua:365
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./candran/can-parser/parser.lua:366
end -- ./candran/can-parser/parser.lua:366
end -- ./candran/can-parser/parser.lua:366
return block, i -- ./candran/can-parser/parser.lua:370
elseif last["tag"]:match("Expr$") then -- ./candran/can-parser/parser.lua:373
local r = searchEndRec({ last }) -- ./candran/can-parser/parser.lua:374
if r then -- ./candran/can-parser/parser.lua:375
for j = 2, # r, 1 do -- ./candran/can-parser/parser.lua:376
table["insert"](block, i + j - 1, r[j]) -- ./candran/can-parser/parser.lua:377
end -- ./candran/can-parser/parser.lua:377
return block, i -- ./candran/can-parser/parser.lua:379
end -- ./candran/can-parser/parser.lua:379
elseif last["tag"] == "Function" then -- ./candran/can-parser/parser.lua:381
local r = searchEndRec(last[2]) -- ./candran/can-parser/parser.lua:382
if r then -- ./candran/can-parser/parser.lua:383
return block, i -- ./candran/can-parser/parser.lua:384
end -- ./candran/can-parser/parser.lua:384
end -- ./candran/can-parser/parser.lua:384
elseif stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Do") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./candran/can-parser/parser.lua:389
local blocks -- ./candran/can-parser/parser.lua:390
if stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./candran/can-parser/parser.lua:392
blocks = stat -- ./candran/can-parser/parser.lua:393
elseif stat["tag"]:match("^Do") then -- ./candran/can-parser/parser.lua:394
blocks = { stat } -- ./candran/can-parser/parser.lua:395
end -- ./candran/can-parser/parser.lua:395
for _, iblock in ipairs(blocks) do -- ./candran/can-parser/parser.lua:398
if iblock["tag"] == "Block" then -- ./candran/can-parser/parser.lua:399
local oldLen = # iblock -- ./candran/can-parser/parser.lua:400
local newiBlock, newEnd = searchEndRec(iblock, true) -- ./candran/can-parser/parser.lua:401
if newiBlock then -- ./candran/can-parser/parser.lua:402
local p = i -- ./candran/can-parser/parser.lua:403
for j = newEnd + (# iblock - oldLen) + 1, # iblock, 1 do -- ./candran/can-parser/parser.lua:404
p = p + 1 -- ./candran/can-parser/parser.lua:405
table["insert"](block, p, iblock[j]) -- ./candran/can-parser/parser.lua:406
iblock[j] = nil -- ./candran/can-parser/parser.lua:407
end -- ./candran/can-parser/parser.lua:407
if not isRecCall then -- ./candran/can-parser/parser.lua:410
for j = p + 1, # block, 1 do -- ./candran/can-parser/parser.lua:411
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./candran/can-parser/parser.lua:412
end -- ./candran/can-parser/parser.lua:412
end -- ./candran/can-parser/parser.lua:412
return block, i -- ./candran/can-parser/parser.lua:416
end -- ./candran/can-parser/parser.lua:416
end -- ./candran/can-parser/parser.lua:416
end -- ./candran/can-parser/parser.lua:416
end -- ./candran/can-parser/parser.lua:416
end -- ./candran/can-parser/parser.lua:416
return nil -- ./candran/can-parser/parser.lua:422
end -- ./candran/can-parser/parser.lua:422
local function searchEnd(s, p, t) -- ./candran/can-parser/parser.lua:425
local r = searchEndRec(fixStructure(t)) -- ./candran/can-parser/parser.lua:426
if not r then -- ./candran/can-parser/parser.lua:427
return false -- ./candran/can-parser/parser.lua:428
end -- ./candran/can-parser/parser.lua:428
return true, r -- ./candran/can-parser/parser.lua:430
end -- ./candran/can-parser/parser.lua:430
local function expectBlockOrSingleStatWithStartEnd(start, startLabel, stopLabel, canFollow) -- ./candran/can-parser/parser.lua:433
if canFollow then -- ./candran/can-parser/parser.lua:434
return (- start * V("SingleStatBlock") * canFollow ^ - 1) + (expect(start, startLabel) * ((V("Block") * (canFollow + kw("end"))) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./candran/can-parser/parser.lua:437
else -- ./candran/can-parser/parser.lua:437
return (- start * V("SingleStatBlock")) + (expect(start, startLabel) * ((V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./candran/can-parser/parser.lua:441
end -- ./candran/can-parser/parser.lua:441
end -- ./candran/can-parser/parser.lua:441
local function expectBlockWithEnd(label) -- ./candran/can-parser/parser.lua:445
return (V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(label)) -- ./candran/can-parser/parser.lua:447
end -- ./candran/can-parser/parser.lua:447
local function maybeBlockWithEnd() -- ./candran/can-parser/parser.lua:450
return (V("BlockNoErr") * kw("end")) + Cmt(V("BlockNoErr"), searchEnd) -- ./candran/can-parser/parser.lua:452
end -- ./candran/can-parser/parser.lua:452
local function maybe(patt) -- ./candran/can-parser/parser.lua:455
return # patt / 0 * patt -- ./candran/can-parser/parser.lua:456
end -- ./candran/can-parser/parser.lua:456
local stacks = { ["lexpr"] = {} } -- ./candran/can-parser/parser.lua:460
local function push(f) -- ./candran/can-parser/parser.lua:462
return Cmt(P(""), function() -- ./candran/can-parser/parser.lua:463
table["insert"](stacks[f], true) -- ./candran/can-parser/parser.lua:464
return true -- ./candran/can-parser/parser.lua:465
end) -- ./candran/can-parser/parser.lua:465
end -- ./candran/can-parser/parser.lua:465
local function pop(f) -- ./candran/can-parser/parser.lua:468
return Cmt(P(""), function() -- ./candran/can-parser/parser.lua:469
table["remove"](stacks[f]) -- ./candran/can-parser/parser.lua:470
return true -- ./candran/can-parser/parser.lua:471
end) -- ./candran/can-parser/parser.lua:471
end -- ./candran/can-parser/parser.lua:471
local function when(f) -- ./candran/can-parser/parser.lua:474
return Cmt(P(""), function() -- ./candran/can-parser/parser.lua:475
return # stacks[f] > 0 -- ./candran/can-parser/parser.lua:476
end) -- ./candran/can-parser/parser.lua:476
end -- ./candran/can-parser/parser.lua:476
local function set(f, patt) -- ./candran/can-parser/parser.lua:479
return push(f) * patt * pop(f) -- ./candran/can-parser/parser.lua:480
end -- ./candran/can-parser/parser.lua:480
local G = { -- ./candran/can-parser/parser.lua:484
V("Lua"), -- ./candran/can-parser/parser.lua:484
["Lua"] = (V("Shebang") ^ - 1 * V("Skip") * V("Block") * expect(P(- 1), "Extra")) / fixStructure, -- ./candran/can-parser/parser.lua:485
["Shebang"] = P("#!") * (P(1) - P("\
")) ^ 0, -- ./candran/can-parser/parser.lua:486
["Block"] = tagC("Block", (V("Stat") + - V("BlockEnd") * throw("InvalidStat")) ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./candran/can-parser/parser.lua:488
["Stat"] = V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat") + V("LocalStat") + V("FuncStat") + V("BreakStat") + V("LabelStat") + V("GoToStat") + V("LetStat") + V("FuncCall") + V("Assignment") + V("ContinueStat") + V("PushStat") + sym(";"), -- ./candran/can-parser/parser.lua:494
["BlockEnd"] = P("return") + "end" + "elseif" + "else" + "until" + "]" + - 1 + V("ImplicitPushStat") + V("Assignment"), -- ./candran/can-parser/parser.lua:495
["SingleStatBlock"] = tagC("Block", V("Stat") + V("RetStat") + V("ImplicitPushStat")) / function(t) -- ./candran/can-parser/parser.lua:497
t["is_singlestatblock"] = true -- ./candran/can-parser/parser.lua:497
return t -- ./candran/can-parser/parser.lua:497
end, -- ./candran/can-parser/parser.lua:497
["BlockNoErr"] = tagC("Block", V("Stat") ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./candran/can-parser/parser.lua:498
["IfStat"] = tagC("If", V("IfPart")), -- ./candran/can-parser/parser.lua:500
["IfPart"] = kw("if") * set("lexpr", expect(V("Expr"), "ExprIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./candran/can-parser/parser.lua:501
["ElseIfPart"] = kw("elseif") * set("lexpr", expect(V("Expr"), "ExprEIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenEIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./candran/can-parser/parser.lua:502
["ElsePart"] = kw("else") * expectBlockWithEnd("EndIf"), -- ./candran/can-parser/parser.lua:503
["DoStat"] = kw("do") * expectBlockWithEnd("EndDo") / tagDo, -- ./candran/can-parser/parser.lua:505
["WhileStat"] = tagC("While", kw("while") * set("lexpr", expect(V("Expr"), "ExprWhile")) * V("WhileBody")), -- ./candran/can-parser/parser.lua:506
["WhileBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoWhile", "EndWhile"), -- ./candran/can-parser/parser.lua:507
["RepeatStat"] = tagC("Repeat", kw("repeat") * V("Block") * expect(kw("until"), "UntilRep") * expect(V("Expr"), "ExprRep")), -- ./candran/can-parser/parser.lua:508
["ForStat"] = kw("for") * expect(V("ForNum") + V("ForIn"), "ForRange"), -- ./candran/can-parser/parser.lua:510
["ForNum"] = tagC("Fornum", V("Id") * sym("=") * V("NumRange") * V("ForBody")), -- ./candran/can-parser/parser.lua:511
["NumRange"] = expect(V("Expr"), "ExprFor1") * expect(sym(","), "CommaFor") * expect(V("Expr"), "ExprFor2") * (sym(",") * expect(V("Expr"), "ExprFor3")) ^ - 1, -- ./candran/can-parser/parser.lua:513
["ForIn"] = tagC("Forin", V("DestructuringNameList") * expect(kw("in"), "InFor") * expect(V("ExprList"), "EListFor") * V("ForBody")), -- ./candran/can-parser/parser.lua:514
["ForBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoFor", "EndFor"), -- ./candran/can-parser/parser.lua:515
["LocalStat"] = kw("local") * expect(V("LocalFunc") + V("LocalAssign"), "DefLocal"), -- ./candran/can-parser/parser.lua:517
["LocalFunc"] = tagC("Localrec", kw("function") * expect(V("Id"), "NameLFunc") * V("FuncBody")) / fixFuncStat, -- ./candran/can-parser/parser.lua:518
["LocalAssign"] = tagC("Local", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Local", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./candran/can-parser/parser.lua:520
["LetStat"] = kw("let") * expect(V("LetAssign"), "DefLet"), -- ./candran/can-parser/parser.lua:522
["LetAssign"] = tagC("Let", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Let", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./candran/can-parser/parser.lua:524
["Assignment"] = tagC("Set", (V("VarList") + V("DestructuringNameList")) * V("BinOp") ^ - 1 * (P("=") / "=") * ((V("BinOp") - P("-")) + # (P("-") * V("Space")) * V("BinOp")) ^ - 1 * V("Skip") * expect(V("ExprList"), "EListAssign")), -- ./candran/can-parser/parser.lua:526
["FuncStat"] = tagC("Set", kw("function") * expect(V("FuncName"), "FuncName") * V("FuncBody")) / fixFuncStat, -- ./candran/can-parser/parser.lua:528
["FuncName"] = Cf(V("Id") * (sym(".") * expect(V("StrId"), "NameFunc1")) ^ 0, insertIndex) * (sym(":") * expect(V("StrId"), "NameFunc2")) ^ - 1 / markMethod, -- ./candran/can-parser/parser.lua:530
["FuncBody"] = tagC("Function", V("FuncParams") * expectBlockWithEnd("EndFunc")), -- ./candran/can-parser/parser.lua:531
["FuncParams"] = expect(sym("("), "OParenPList") * V("ParList") * expect(sym(")"), "CParenPList"), -- ./candran/can-parser/parser.lua:532
["ParList"] = V("NamedParList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()), -- ./candran/can-parser/parser.lua:535
["ShortFuncDef"] = tagC("Function", V("ShortFuncParams") * maybeBlockWithEnd()) / fixShortFunc, -- ./candran/can-parser/parser.lua:537
["ShortFuncParams"] = (sym(":") / ":") ^ - 1 * sym("(") * V("ParList") * sym(")"), -- ./candran/can-parser/parser.lua:538
["NamedParList"] = tagC("NamedParList", commaSep(V("NamedPar"))), -- ./candran/can-parser/parser.lua:540
["NamedPar"] = tagC("ParPair", V("ParKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Id"), -- ./candran/can-parser/parser.lua:542
["ParKey"] = V("Id") * # ("=" * - P("=")), -- ./candran/can-parser/parser.lua:543
["LabelStat"] = tagC("Label", sym("::") * expect(V("Name"), "Label") * expect(sym("::"), "CloseLabel")), -- ./candran/can-parser/parser.lua:545
["GoToStat"] = tagC("Goto", kw("goto") * expect(V("Name"), "Goto")), -- ./candran/can-parser/parser.lua:546
["BreakStat"] = tagC("Break", kw("break")), -- ./candran/can-parser/parser.lua:547
["ContinueStat"] = tagC("Continue", kw("continue")), -- ./candran/can-parser/parser.lua:548
["RetStat"] = tagC("Return", kw("return") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./candran/can-parser/parser.lua:549
["PushStat"] = tagC("Push", kw("push") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./candran/can-parser/parser.lua:551
["ImplicitPushStat"] = tagC("Push", commaSep(V("Expr"), "RetList")), -- ./candran/can-parser/parser.lua:552
["NameList"] = tagC("NameList", commaSep(V("Id"))), -- ./candran/can-parser/parser.lua:554
["DestructuringNameList"] = tagC("NameList", commaSep(V("DestructuringId"))), -- ./candran/can-parser/parser.lua:555
["VarList"] = tagC("VarList", commaSep(V("VarExpr"))), -- ./candran/can-parser/parser.lua:556
["ExprList"] = tagC("ExpList", commaSep(V("Expr"), "ExprList")), -- ./candran/can-parser/parser.lua:557
["DestructuringId"] = tagC("DestructuringId", sym("{") * V("DestructuringIdFieldList") * expect(sym("}"), "CBraceDestructuring")) + V("Id"), -- ./candran/can-parser/parser.lua:559
["DestructuringIdFieldList"] = sepBy(V("DestructuringIdField"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./candran/can-parser/parser.lua:560
["DestructuringIdField"] = tagC("Pair", V("FieldKey") * expect(sym("="), "DestructuringEqField") * expect(V("Id"), "DestructuringExprField")) + V("Id"), -- ./candran/can-parser/parser.lua:562
["Expr"] = V("OrExpr"), -- ./candran/can-parser/parser.lua:564
["OrExpr"] = chainOp(V("AndExpr"), V("OrOp"), "OrExpr"), -- ./candran/can-parser/parser.lua:565
["AndExpr"] = chainOp(V("RelExpr"), V("AndOp"), "AndExpr"), -- ./candran/can-parser/parser.lua:566
["RelExpr"] = chainOp(V("BOrExpr"), V("RelOp"), "RelExpr"), -- ./candran/can-parser/parser.lua:567
["BOrExpr"] = chainOp(V("BXorExpr"), V("BOrOp"), "BOrExpr"), -- ./candran/can-parser/parser.lua:568
["BXorExpr"] = chainOp(V("BAndExpr"), V("BXorOp"), "BXorExpr"), -- ./candran/can-parser/parser.lua:569
["BAndExpr"] = chainOp(V("ShiftExpr"), V("BAndOp"), "BAndExpr"), -- ./candran/can-parser/parser.lua:570
["ShiftExpr"] = chainOp(V("ConcatExpr"), V("ShiftOp"), "ShiftExpr"), -- ./candran/can-parser/parser.lua:571
["ConcatExpr"] = V("AddExpr") * (V("ConcatOp") * expect(V("ConcatExpr"), "ConcatExpr")) ^ - 1 / binaryOp, -- ./candran/can-parser/parser.lua:572
["AddExpr"] = chainOp(V("MulExpr"), V("AddOp"), "AddExpr"), -- ./candran/can-parser/parser.lua:573
["MulExpr"] = chainOp(V("UnaryExpr"), V("MulOp"), "MulExpr"), -- ./candran/can-parser/parser.lua:574
["UnaryExpr"] = V("UnaryOp") * expect(V("UnaryExpr"), "UnaryExpr") / unaryOp + V("PowExpr"), -- ./candran/can-parser/parser.lua:576
["PowExpr"] = V("SimpleExpr") * (V("PowOp") * expect(V("UnaryExpr"), "PowExpr")) ^ - 1 / binaryOp, -- ./candran/can-parser/parser.lua:577
["SimpleExpr"] = tagC("Number", V("Number")) + tagC("Nil", kw("nil")) + tagC("Boolean", kw("false") * Cc(false)) + tagC("Boolean", kw("true") * Cc(true)) + tagC("Dots", sym("...")) + V("FuncDef") + (when("lexpr") * tagC("LetExpr", maybe(V("DestructuringNameList")) * sym("=") * - sym("=") * expect(V("ExprList"), "EListLAssign"))) + V("ShortFuncDef") + V("SuffixedExpr") + V("StatExpr"), -- ./candran/can-parser/parser.lua:587
["StatExpr"] = (V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat")) / statToExpr, -- ./candran/can-parser/parser.lua:589
["FuncCall"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./candran/can-parser/parser.lua:591
return exp["tag"] == "Call" or exp["tag"] == "SafeCall", exp -- ./candran/can-parser/parser.lua:591
end), -- ./candran/can-parser/parser.lua:591
["VarExpr"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./candran/can-parser/parser.lua:592
return exp["tag"] == "Id" or exp["tag"] == "Index", exp -- ./candran/can-parser/parser.lua:592
end), -- ./candran/can-parser/parser.lua:592
["SuffixedExpr"] = Cf(V("PrimaryExpr") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr") * - V("Call") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr"), makeSuffixedExpr), -- ./candran/can-parser/parser.lua:596
["PrimaryExpr"] = V("SelfId") * (V("SelfCall") + V("SelfIndex")) + V("Id") + tagC("Paren", sym("(") * expect(V("Expr"), "ExprParen") * expect(sym(")"), "CParenExpr")), -- ./candran/can-parser/parser.lua:599
["NoCallPrimaryExpr"] = tagC("String", V("String")) + V("Table") + V("TableCompr"), -- ./candran/can-parser/parser.lua:600
["Index"] = tagC("DotIndex", sym("." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("ArrayIndex", sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")) + tagC("SafeDotIndex", sym("?." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("SafeArrayIndex", sym("?[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")), -- ./candran/can-parser/parser.lua:604
["MethodStub"] = tagC("MethodStub", sym(":" * - P(":")) * expect(V("StrId"), "NameMeth")) + tagC("SafeMethodStub", sym("?:" * - P(":")) * expect(V("StrId"), "NameMeth")), -- ./candran/can-parser/parser.lua:606
["Call"] = tagC("Call", V("FuncArgs")) + tagC("SafeCall", P("?") * V("FuncArgs")), -- ./candran/can-parser/parser.lua:608
["SelfCall"] = tagC("MethodStub", V("StrId")) * V("Call"), -- ./candran/can-parser/parser.lua:609
["SelfIndex"] = tagC("DotIndex", V("StrId")), -- ./candran/can-parser/parser.lua:610
["FuncDef"] = (kw("function") * V("FuncBody")), -- ./candran/can-parser/parser.lua:612
["FuncArgs"] = sym("(") * commaSep(V("Expr"), "ArgList") ^ - 1 * expect(sym(")"), "CParenArgs") + V("Table") + tagC("String", V("String")), -- ./candran/can-parser/parser.lua:615
["Table"] = tagC("Table", sym("{") * V("FieldList") ^ - 1 * expect(sym("}"), "CBraceTable")), -- ./candran/can-parser/parser.lua:617
["FieldList"] = sepBy(V("Field"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./candran/can-parser/parser.lua:618
["Field"] = tagC("Pair", V("FieldKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Expr"), -- ./candran/can-parser/parser.lua:620
["FieldKey"] = sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprFKey") * expect(sym("]"), "CBracketFKey") + V("StrId") * # ("=" * - P("=")), -- ./candran/can-parser/parser.lua:622
["FieldSep"] = sym(",") + sym(";"), -- ./candran/can-parser/parser.lua:623
["TableCompr"] = tagC("TableCompr", sym("[") * V("Block") * expect(sym("]"), "CBracketTableCompr")), -- ./candran/can-parser/parser.lua:625
["SelfId"] = tagC("Id", sym("@") / "self"), -- ./candran/can-parser/parser.lua:627
["Id"] = tagC("Id", V("Name")) + V("SelfId"), -- ./candran/can-parser/parser.lua:628
["StrId"] = tagC("String", V("Name")), -- ./candran/can-parser/parser.lua:629
["Skip"] = (V("Space") + V("Comment")) ^ 0, -- ./candran/can-parser/parser.lua:632
["Space"] = space ^ 1, -- ./candran/can-parser/parser.lua:633
["Comment"] = P("--") * V("LongStr") / function() -- ./candran/can-parser/parser.lua:634
return  -- ./candran/can-parser/parser.lua:634
end + P("--") * (P(1) - P("\
")) ^ 0, -- ./candran/can-parser/parser.lua:635
["Name"] = token(- V("Reserved") * C(V("Ident"))), -- ./candran/can-parser/parser.lua:637
["Reserved"] = V("Keywords") * - V("IdRest"), -- ./candran/can-parser/parser.lua:638
["Keywords"] = P("and") + "break" + "do" + "elseif" + "else" + "end" + "false" + "for" + "function" + "goto" + "if" + "in" + "local" + "nil" + "not" + "or" + "repeat" + "return" + "then" + "true" + "until" + "while", -- ./candran/can-parser/parser.lua:642
["Ident"] = V("IdStart") * V("IdRest") ^ 0, -- ./candran/can-parser/parser.lua:643
["IdStart"] = alpha + P("_"), -- ./candran/can-parser/parser.lua:644
["IdRest"] = alnum + P("_"), -- ./candran/can-parser/parser.lua:645
["Number"] = token(C(V("Hex") + V("Float") + V("Int"))), -- ./candran/can-parser/parser.lua:647
["Hex"] = (P("0x") + "0X") * ((xdigit ^ 0 * V("DeciHex")) + (expect(xdigit ^ 1, "DigitHex") * V("DeciHex") ^ - 1)) * V("ExpoHex") ^ - 1, -- ./candran/can-parser/parser.lua:648
["Float"] = V("Decimal") * V("Expo") ^ - 1 + V("Int") * V("Expo"), -- ./candran/can-parser/parser.lua:650
["Decimal"] = digit ^ 1 * "." * digit ^ 0 + P(".") * - P(".") * expect(digit ^ 1, "DigitDeci"), -- ./candran/can-parser/parser.lua:652
["DeciHex"] = P(".") * xdigit ^ 0, -- ./candran/can-parser/parser.lua:653
["Expo"] = S("eE") * S("+-") ^ - 1 * expect(digit ^ 1, "DigitExpo"), -- ./candran/can-parser/parser.lua:654
["ExpoHex"] = S("pP") * S("+-") ^ - 1 * expect(xdigit ^ 1, "DigitExpo"), -- ./candran/can-parser/parser.lua:655
["Int"] = digit ^ 1, -- ./candran/can-parser/parser.lua:656
["String"] = token(V("ShortStr") + V("LongStr")), -- ./candran/can-parser/parser.lua:658
["ShortStr"] = P("\"") * Cs((V("EscSeq") + (P(1) - S("\"\
"))) ^ 0) * expect(P("\""), "Quote") + P("'") * Cs((V("EscSeq") + (P(1) - S("'\
"))) ^ 0) * expect(P("'"), "Quote"), -- ./candran/can-parser/parser.lua:660
["EscSeq"] = P("\\") / "" * (P("a") / "\7" + P("b") / "\8" + P("f") / "\12" + P("n") / "\
" + P("r") / "\13" + P("t") / "\9" + P("v") / "\11" + P("\
") / "\
" + P("\13") / "\
" + P("\\") / "\\" + P("\"") / "\"" + P("'") / "'" + P("z") * space ^ 0 / "" + digit * digit ^ - 2 / tonumber / string["char"] + P("x") * expect(C(xdigit * xdigit), "HexEsc") * Cc(16) / tonumber / string["char"] + P("u") * expect("{", "OBraceUEsc") * expect(C(xdigit ^ 1), "DigitUEsc") * Cc(16) * expect("}", "CBraceUEsc") / tonumber / (utf8 and utf8["char"] or string["char"]) + throw("EscSeq")), -- ./candran/can-parser/parser.lua:690
["LongStr"] = V("Open") * C((P(1) - V("CloseEq")) ^ 0) * expect(V("Close"), "CloseLStr") / function(s, eqs) -- ./candran/can-parser/parser.lua:693
return s -- ./candran/can-parser/parser.lua:693
end, -- ./candran/can-parser/parser.lua:693
["Open"] = "[" * Cg(V("Equals"), "openEq") * "[" * P("\
") ^ - 1, -- ./candran/can-parser/parser.lua:694
["Close"] = "]" * C(V("Equals")) * "]", -- ./candran/can-parser/parser.lua:695
["Equals"] = P("=") ^ 0, -- ./candran/can-parser/parser.lua:696
["CloseEq"] = Cmt(V("Close") * Cb("openEq"), function(s, i, closeEq, openEq) -- ./candran/can-parser/parser.lua:697
return # openEq == # closeEq -- ./candran/can-parser/parser.lua:697
end), -- ./candran/can-parser/parser.lua:697
["OrOp"] = kw("or") / "or", -- ./candran/can-parser/parser.lua:699
["AndOp"] = kw("and") / "and", -- ./candran/can-parser/parser.lua:700
["RelOp"] = sym("~=") / "ne" + sym("==") / "eq" + sym("<=") / "le" + sym(">=") / "ge" + sym("<") / "lt" + sym(">") / "gt", -- ./candran/can-parser/parser.lua:706
["BOrOp"] = sym("|") / "bor", -- ./candran/can-parser/parser.lua:707
["BXorOp"] = sym("~" * - P("=")) / "bxor", -- ./candran/can-parser/parser.lua:708
["BAndOp"] = sym("&") / "band", -- ./candran/can-parser/parser.lua:709
["ShiftOp"] = sym("<<") / "shl" + sym(">>") / "shr", -- ./candran/can-parser/parser.lua:711
["ConcatOp"] = sym("..") / "concat", -- ./candran/can-parser/parser.lua:712
["AddOp"] = sym("+") / "add" + sym("-") / "sub", -- ./candran/can-parser/parser.lua:714
["MulOp"] = sym("*") / "mul" + sym("//") / "idiv" + sym("/") / "div" + sym("%") / "mod", -- ./candran/can-parser/parser.lua:718
["UnaryOp"] = kw("not") / "not" + sym("-") / "unm" + sym("#") / "len" + sym("~") / "bnot", -- ./candran/can-parser/parser.lua:722
["PowOp"] = sym("^") / "pow", -- ./candran/can-parser/parser.lua:723
["BinOp"] = V("OrOp") + V("AndOp") + V("BOrOp") + V("BXorOp") + V("BAndOp") + V("ShiftOp") + V("ConcatOp") + V("AddOp") + V("MulOp") + V("PowOp") -- ./candran/can-parser/parser.lua:724
} -- ./candran/can-parser/parser.lua:724
local parser = {} -- ./candran/can-parser/parser.lua:727
local validator = require("candran.can-parser.validator") -- ./candran/can-parser/parser.lua:729
local validate = validator["validate"] -- ./candran/can-parser/parser.lua:730
local syntaxerror = validator["syntaxerror"] -- ./candran/can-parser/parser.lua:731
parser["parse"] = function(subject, filename) -- ./candran/can-parser/parser.lua:733
local errorinfo = { -- ./candran/can-parser/parser.lua:734
["subject"] = subject, -- ./candran/can-parser/parser.lua:734
["filename"] = filename -- ./candran/can-parser/parser.lua:734
} -- ./candran/can-parser/parser.lua:734
lpeg["setmaxstack"](1000) -- ./candran/can-parser/parser.lua:735
local ast, label, errpos = lpeg["match"](G, subject, nil, errorinfo) -- ./candran/can-parser/parser.lua:736
if not ast then -- ./candran/can-parser/parser.lua:737
local errmsg = labels[label][2] -- ./candran/can-parser/parser.lua:738
return ast, syntaxerror(errorinfo, errpos, errmsg) -- ./candran/can-parser/parser.lua:739
end -- ./candran/can-parser/parser.lua:739
return validate(ast, errorinfo) -- ./candran/can-parser/parser.lua:741
end -- ./candran/can-parser/parser.lua:741
return parser -- ./candran/can-parser/parser.lua:744
end -- ./candran/can-parser/parser.lua:744
local parser = _() or parser -- ./candran/can-parser/parser.lua:748
package["loaded"]["candran.can-parser.parser"] = parser or true -- ./candran/can-parser/parser.lua:749
local candran = { ["VERSION"] = "0.11.0" } -- candran.can:14
candran["default"] = { -- candran.can:18
["target"] = "lua53", -- candran.can:19
["indentation"] = "", -- candran.can:20
["newline"] = "\
", -- candran.can:21
["variablePrefix"] = "__CAN_", -- candran.can:22
["mapLines"] = true, -- candran.can:23
["chunkname"] = "nil", -- candran.can:24
["rewriteErrors"] = true -- candran.can:25
} -- candran.can:25
if _VERSION == "Lua 5.1" then -- candran.can:29
if package["loaded"]["jit"] then -- candran.can:30
candran["default"]["target"] = "luajit" -- candran.can:31
else -- candran.can:31
candran["default"]["target"] = "lua51" -- candran.can:33
end -- candran.can:33
end -- candran.can:33
candran["preprocess"] = function(input, options) -- candran.can:41
if options == nil then options = {} end -- candran.can:41
options = util["merge"](candran["default"], options) -- candran.can:42
local preprocessor = "" -- candran.can:45
local i = 0 -- candran.can:46
local inLongString = false -- candran.can:47
local inComment = false -- candran.can:48
for line in (input .. "\
"):gmatch("(.-\
)") do -- candran.can:49
i = i + (1) -- candran.can:50
if inComment then -- candran.can:52
inComment = not line:match("%]%]") -- candran.can:53
elseif inLongString then -- candran.can:54
inLongString = not line:match("%]%]") -- candran.can:55
else -- candran.can:55
if line:match("[^%-]%[%[") then -- candran.can:57
inLongString = true -- candran.can:58
elseif line:match("%-%-%[%[") then -- candran.can:59
inComment = true -- candran.can:60
end -- candran.can:60
end -- candran.can:60
if not inComment and not inLongString and line:match("^%s*#") and not line:match("^#!") then -- candran.can:63
preprocessor = preprocessor .. (line:gsub("^%s*#", "")) -- candran.can:64
else -- candran.can:64
local l = line:sub(1, - 2) -- candran.can:66
if not inLongString and options["mapLines"] and not l:match("%-%- (.-)%:(%d+)$") then -- candran.can:67
preprocessor = preprocessor .. (("write(%q)"):format(l .. " -- " .. options["chunkname"] .. ":" .. i) .. "\
") -- candran.can:68
else -- candran.can:68
preprocessor = preprocessor .. (("write(%q)"):format(line:sub(1, - 2)) .. "\
") -- candran.can:70
end -- candran.can:70
end -- candran.can:70
end -- candran.can:70
preprocessor = preprocessor .. ("return output") -- candran.can:74
local env = util["merge"](_G, options) -- candran.can:77
env["candran"] = candran -- candran.can:79
env["output"] = "" -- candran.can:81
env["import"] = function(modpath, margs) -- candran.can:88
if margs == nil then margs = {} end -- candran.can:88
local filepath = assert(util["search"](modpath, { -- candran.can:89
"can", -- candran.can:89
"lua" -- candran.can:89
}), "No module named \"" .. modpath .. "\"") -- candran.can:89
local f = io["open"](filepath) -- candran.can:92
if not f then -- candran.can:93
error("Can't open the module file to import") -- candran.can:93
end -- candran.can:93
margs = util["merge"](options, { -- candran.can:95
["chunkname"] = filepath, -- candran.can:95
["loadLocal"] = true, -- candran.can:95
["loadPackage"] = true -- candran.can:95
}, margs) -- candran.can:95
local modcontent = candran["preprocess"](f:read("*a"), margs) -- candran.can:96
f:close() -- candran.can:97
local modname = modpath:match("[^%.]+$") -- candran.can:100
env["write"]("-- MODULE " .. modpath .. " --\
" .. "local function _()\
" .. modcontent .. "\
" .. "end\
" .. (margs["loadLocal"] and ("local %s = _() or %s\
"):format(modname, modname) or "") .. (margs["loadPackage"] and ("package.loaded[%q] = %s or true\
"):format(modpath, margs["loadLocal"] and modname or "_()") or "") .. "-- END OF MODULE " .. modpath .. " --") -- candran.can:109
end -- candran.can:109
env["include"] = function(file) -- candran.can:114
local f = io["open"](file) -- candran.can:115
if not f then -- candran.can:116
error("Can't open the file " .. file .. " to include") -- candran.can:116
end -- candran.can:116
env["write"](f:read("*a")) -- candran.can:117
f:close() -- candran.can:118
end -- candran.can:118
env["write"] = function(...) -- candran.can:122
env["output"] = env["output"] .. (table["concat"]({ ... }, "\9") .. "\
") -- candran.can:123
end -- candran.can:123
env["placeholder"] = function(name) -- candran.can:127
if env[name] then -- candran.can:128
env["write"](env[name]) -- candran.can:129
end -- candran.can:129
end -- candran.can:129
local preprocess, err = util["load"](candran["compile"](preprocessor, args), "candran preprocessor", env) -- candran.can:134
if not preprocess then -- candran.can:135
error("Error while creating Candran preprocessor: " .. err) -- candran.can:135
end -- candran.can:135
local success, output = pcall(preprocess) -- candran.can:138
if not success then -- candran.can:139
error("Error while preprocessing file: " .. output) -- candran.can:139
end -- candran.can:139
return output -- candran.can:141
end -- candran.can:141
candran["compile"] = function(input, options) -- candran.can:148
if options == nil then options = {} end -- candran.can:148
options = util["merge"](candran["default"], options) -- candran.can:149
local ast, errmsg = parser["parse"](input, options["chunkname"]) -- candran.can:151
if not ast then -- candran.can:153
error("Compiler: error while parsing file: " .. errmsg) -- candran.can:154
end -- candran.can:154
return require("compiler." .. options["target"])(input, ast, options) -- candran.can:157
end -- candran.can:157
candran["make"] = function(code, options) -- candran.can:164
return candran["compile"](candran["preprocess"](code, options), options) -- candran.can:165
end -- candran.can:165
local errorRewritingActive = false -- candran.can:168
local codeCache = {} -- candran.can:169
candran["loadfile"] = function(filepath, env, options) -- candran.can:172
local f, err = io["open"](filepath) -- candran.can:173
if not f then -- candran.can:174
error("can't open the file: " .. err) -- candran.can:174
end -- candran.can:174
local content = f:read("*a") -- candran.can:175
f:close() -- candran.can:176
return candran["load"](content, filepath, env, options) -- candran.can:178
end -- candran.can:178
candran["load"] = function(chunk, chunkname, env, options) -- candran.can:183
if options == nil then options = {} end -- candran.can:183
options = util["merge"]({ ["chunkname"] = tostring(chunkname or chunk) }, options) -- candran.can:184
codeCache[options["chunkname"]] = candran["make"](chunk, options) -- candran.can:186
local f, err = util["load"](codeCache[options["chunkname"]], options["chunkname"], env) -- candran.can:187
if f == nil then -- candran.can:192
return f, "Candran unexpectedly generated invalid code: " .. err -- candran.can:193
end -- candran.can:193
if options["rewriteErrors"] == false then -- candran.can:196
return f -- candran.can:197
else -- candran.can:197
return function(...) -- candran.can:199
local params = { ... } -- candran.can:200
if not errorRewritingActive then -- candran.can:201
errorRewritingActive = true -- candran.can:202
local t = { xpcall(function() -- candran.can:203
return f(unpack(params)) -- candran.can:203
end, candran["messageHandler"]) } -- candran.can:203
errorRewritingActive = false -- candran.can:204
if t[1] == false then -- candran.can:205
error(t[2], 0) -- candran.can:206
end -- candran.can:206
return unpack(t, 2) -- candran.can:208
else -- candran.can:208
return f(...) -- candran.can:210
end -- candran.can:210
end -- candran.can:210
end -- candran.can:210
end -- candran.can:210
candran["dofile"] = function(filename, options) -- candran.can:218
local f, err = candran["loadfile"](filename, nil, options) -- candran.can:219
if f == nil then -- candran.can:221
error(err) -- candran.can:222
else -- candran.can:222
return f() -- candran.can:224
end -- candran.can:224
end -- candran.can:224
candran["messageHandler"] = function(message) -- candran.can:230
return debug["traceback"](message, 2):gsub("(\
?%s*)([^\
]-)%:(%d+)%:", function(indentation, source, line) -- candran.can:231
line = tonumber(line) -- candran.can:232
local originalFile -- candran.can:234
local strName = source:match("%[string \"(.-)\"%]") -- candran.can:235
if strName then -- candran.can:236
if codeCache[strName] then -- candran.can:237
originalFile = codeCache[strName] -- candran.can:238
source = strName -- candran.can:239
end -- candran.can:239
else -- candran.can:239
local fi = io["open"](source, "r") -- candran.can:242
if fi then -- candran.can:243
originalFile = fi:read("*a") -- candran.can:244
fi:close() -- candran.can:245
end -- candran.can:245
end -- candran.can:245
if originalFile then -- candran.can:249
local i = 0 -- candran.can:250
for l in originalFile:gmatch("([^\
]*)\
") do -- candran.can:251
i = i + 1 -- candran.can:252
if i == line then -- candran.can:253
local extSource, lineMap = l:match(".*%-%- (.-)%:(%d+)$") -- candran.can:254
if lineMap then -- candran.can:255
if extSource ~= source then -- candran.can:256
return indentation .. extSource .. ":" .. lineMap .. "(" .. extSource .. ":" .. line .. "):" -- candran.can:257
else -- candran.can:257
return indentation .. extSource .. ":" .. lineMap .. "(" .. line .. "):" -- candran.can:259
end -- candran.can:259
end -- candran.can:259
break -- candran.can:262
end -- candran.can:262
end -- candran.can:262
end -- candran.can:262
end) -- candran.can:262
end -- candran.can:262
candran["searcher"] = function(modpath) -- candran.can:270
local filepath = util["search"](modpath, { "can" }) -- candran.can:271
if not filepath then -- candran.can:272
return "\
\9no candran file in package.path" -- candran.can:273
end -- candran.can:273
return candran["loadfile"](filepath) -- candran.can:275
end -- candran.can:275
candran["setup"] = function() -- candran.can:279
if _VERSION == "Lua 5.1" then -- candran.can:280
table["insert"](package["loaders"], 2, candran["searcher"]) -- candran.can:281
else -- candran.can:281
table["insert"](package["searchers"], 2, candran["searcher"]) -- candran.can:283
end -- candran.can:283
return candran -- candran.can:285
end -- candran.can:285
return candran -- candran.can:288
