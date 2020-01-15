local function _() -- candran.can:2
local util = {} -- ./lib/util.can:1
util["search"] = function(modpath, exts) -- ./lib/util.can:3
if exts == nil then exts = {} end -- ./lib/util.can:3
for _, ext in ipairs(exts) do -- ./lib/util.can:4
for path in package["path"]:gmatch("[^;]+") do -- ./lib/util.can:5
local fpath = path:gsub("%.lua", "." .. ext):gsub("%?", (modpath:gsub("%.", "/"))) -- ./lib/util.can:6
local f = io["open"](fpath) -- ./lib/util.can:7
if f then -- ./lib/util.can:8
f:close() -- ./lib/util.can:9
return fpath -- ./lib/util.can:10
end -- ./lib/util.can:10
end -- ./lib/util.can:10
end -- ./lib/util.can:10
end -- ./lib/util.can:10
util["load"] = function(str, name, env) -- ./lib/util.can:16
if _VERSION == "Lua 5.1" then -- ./lib/util.can:17
local fn, err = loadstring(str, name) -- ./lib/util.can:18
if not fn then -- ./lib/util.can:19
return fn, err -- ./lib/util.can:19
end -- ./lib/util.can:19
return env ~= nil and setfenv(fn, env) or fn -- ./lib/util.can:20
else -- ./lib/util.can:20
if env then -- ./lib/util.can:22
return load(str, name, nil, env) -- ./lib/util.can:23
else -- ./lib/util.can:23
return load(str, name) -- ./lib/util.can:25
end -- ./lib/util.can:25
end -- ./lib/util.can:25
end -- ./lib/util.can:25
util["merge"] = function(...) -- ./lib/util.can:30
local r = {} -- ./lib/util.can:31
for _, t in ipairs({ ... }) do -- ./lib/util.can:32
for k, v in pairs(t) do -- ./lib/util.can:33
r[k] = v -- ./lib/util.can:34
end -- ./lib/util.can:34
end -- ./lib/util.can:34
return r -- ./lib/util.can:37
end -- ./lib/util.can:37
return util -- ./lib/util.can:40
end -- ./lib/util.can:40
local util = _() or util -- ./lib/util.can:44
package["loaded"]["lib.util"] = util or true -- ./lib/util.can:45
local function _() -- ./lib/util.can:48
local ipairs, pairs, setfenv, tonumber, loadstring, type = ipairs, pairs, setfenv, tonumber, loadstring, type -- ./lib/cmdline.lua:5
local tinsert, tconcat = table["insert"], table["concat"] -- ./lib/cmdline.lua:6
local function commonerror(msg) -- ./lib/cmdline.lua:8
return nil, ("[cmdline]: " .. msg) -- ./lib/cmdline.lua:9
end -- ./lib/cmdline.lua:9
local function argerror(msg, numarg) -- ./lib/cmdline.lua:12
msg = msg and (": " .. msg) or "" -- ./lib/cmdline.lua:13
return nil, ("[cmdline]: bad argument #" .. numarg .. msg) -- ./lib/cmdline.lua:14
end -- ./lib/cmdline.lua:14
local function iderror(numarg) -- ./lib/cmdline.lua:17
return argerror("ID not valid", numarg) -- ./lib/cmdline.lua:18
end -- ./lib/cmdline.lua:18
local function idcheck(id) -- ./lib/cmdline.lua:21
return id:match("^[%a_][%w_]*$") and true -- ./lib/cmdline.lua:22
end -- ./lib/cmdline.lua:22
return function(t_in, options, params) -- ./lib/cmdline.lua:73
local t_out = {} -- ./lib/cmdline.lua:74
for i, v in ipairs(t_in) do -- ./lib/cmdline.lua:75
local prefix, command = v:sub(1, 1), v:sub(2) -- ./lib/cmdline.lua:76
if prefix == "$" then -- ./lib/cmdline.lua:77
tinsert(t_out, command) -- ./lib/cmdline.lua:78
elseif prefix == "-" then -- ./lib/cmdline.lua:79
for id in command:gmatch("[^,;]+") do -- ./lib/cmdline.lua:80
if not idcheck(id) then -- ./lib/cmdline.lua:81
return iderror(i) -- ./lib/cmdline.lua:81
end -- ./lib/cmdline.lua:81
t_out[id] = true -- ./lib/cmdline.lua:82
end -- ./lib/cmdline.lua:82
elseif prefix == "!" then -- ./lib/cmdline.lua:84
local f, err = loadstring(command) -- ./lib/cmdline.lua:85
if not f then -- ./lib/cmdline.lua:86
return argerror(err, i) -- ./lib/cmdline.lua:86
end -- ./lib/cmdline.lua:86
setfenv(f, t_out)() -- ./lib/cmdline.lua:87
elseif v:find("=") then -- ./lib/cmdline.lua:88
local ids, val = v:match("^([^=]+)%=(.*)") -- no space around = -- ./lib/cmdline.lua:89
if not ids then -- ./lib/cmdline.lua:90
return argerror("invalid assignment syntax", i) -- ./lib/cmdline.lua:90
end -- ./lib/cmdline.lua:90
if val == "false" then -- ./lib/cmdline.lua:91
val = false -- ./lib/cmdline.lua:92
elseif val == "true" then -- ./lib/cmdline.lua:93
val = true -- ./lib/cmdline.lua:94
else -- ./lib/cmdline.lua:94
val = val:sub(1, 1) == "$" and val:sub(2) or tonumber(val) or val -- ./lib/cmdline.lua:96
end -- ./lib/cmdline.lua:96
for id in ids:gmatch("[^,;]+") do -- ./lib/cmdline.lua:98
if not idcheck(id) then -- ./lib/cmdline.lua:99
return iderror(i) -- ./lib/cmdline.lua:99
end -- ./lib/cmdline.lua:99
t_out[id] = val -- ./lib/cmdline.lua:100
end -- ./lib/cmdline.lua:100
else -- ./lib/cmdline.lua:100
tinsert(t_out, v) -- ./lib/cmdline.lua:103
end -- ./lib/cmdline.lua:103
end -- ./lib/cmdline.lua:103
if options then -- ./lib/cmdline.lua:106
local lookup, unknown = {}, {} -- ./lib/cmdline.lua:107
for _, v in ipairs(options) do -- ./lib/cmdline.lua:108
lookup[v] = true -- ./lib/cmdline.lua:108
end -- ./lib/cmdline.lua:108
for k, _ in pairs(t_out) do -- ./lib/cmdline.lua:109
if lookup[k] == nil and type(k) == "string" then -- ./lib/cmdline.lua:110
tinsert(unknown, k) -- ./lib/cmdline.lua:110
end -- ./lib/cmdline.lua:110
end -- ./lib/cmdline.lua:110
if # unknown > 0 then -- ./lib/cmdline.lua:112
return commonerror("unknown options: " .. tconcat(unknown, ", ")) -- ./lib/cmdline.lua:113
end -- ./lib/cmdline.lua:113
end -- ./lib/cmdline.lua:113
if params then -- ./lib/cmdline.lua:116
local missing = {} -- ./lib/cmdline.lua:117
for _, v in ipairs(params) do -- ./lib/cmdline.lua:118
if t_out[v] == nil then -- ./lib/cmdline.lua:119
tinsert(missing, v) -- ./lib/cmdline.lua:119
end -- ./lib/cmdline.lua:119
end -- ./lib/cmdline.lua:119
if # missing > 0 then -- ./lib/cmdline.lua:121
return commonerror("missing parameters: " .. tconcat(missing, ", ")) -- ./lib/cmdline.lua:122
end -- ./lib/cmdline.lua:122
end -- ./lib/cmdline.lua:122
return t_out -- ./lib/cmdline.lua:125
end -- ./lib/cmdline.lua:125
end -- ./lib/cmdline.lua:125
local cmdline = _() or cmdline -- ./lib/cmdline.lua:130
package["loaded"]["lib.cmdline"] = cmdline or true -- ./lib/cmdline.lua:131
local function _() -- ./lib/cmdline.lua:135
local targetName = "Lua 5.3" -- ./compiler/lua53.can:1
return function(code, ast, options) -- ./compiler/lua53.can:3
local lastInputPos = 1 -- last token position in the input code -- ./compiler/lua53.can:5
local prevLinePos = 1 -- last token position in the previous line of code in the input code -- ./compiler/lua53.can:6
local lastSource = options["chunkname"] or "nil" -- last found code source name (from the original file) -- ./compiler/lua53.can:7
local lastLine = 1 -- last found line number (from the original file) -- ./compiler/lua53.can:8
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
["push"] = {}, -- push stack variable names -- ./compiler/lua53.can:48
["destructuring"] = {}, -- list of variable that need to be assigned from a destructure {id = "parent variable", "field1", "field2"...} -- ./compiler/lua53.can:49
["scope"] = {} -- list of variables defined in the current scope -- ./compiler/lua53.can:50
} -- list of variables defined in the current scope -- ./compiler/lua53.can:50
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
local required = {} -- { ["full require expression"] = true, ... } -- ./compiler/lua53.can:87
local requireStr = "" -- ./compiler/lua53.can:88
local function addRequire(mod, name, field) -- ./compiler/lua53.can:90
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua53.can:91
if not required[req] then -- ./compiler/lua53.can:92
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua53.can:93
required[req] = true -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
local loop = { -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"While", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Repeat", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Fornum", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Forin", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"WhileExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"RepeatExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"FornumExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"ForinExpr" -- loops tags (can contain continue) -- ./compiler/lua53.can:99
} -- loops tags (can contain continue) -- ./compiler/lua53.can:99
local func = { -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"Function", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"TableCompr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"DoExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"WhileExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"RepeatExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"IfExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"FornumExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"ForinExpr" -- function scope tags (can contain push) -- ./compiler/lua53.can:100
} -- function scope tags (can contain push) -- ./compiler/lua53.can:100
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
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:182
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:183
end -- ./compiler/lua53.can:183
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:185
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:188
return "do" .. indent() -- ./compiler/lua53.can:189
end -- ./compiler/lua53.can:189
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:191
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:192
end -- ./compiler/lua53.can:192
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
if newlineAfter == nil then newlineAfter = false end -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
if noLocal == nil then noLocal = false end -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
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
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:236
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:237
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
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:251
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
local toClose = 0 -- blocks that need to be closed at the end of the if -- ./compiler/lua53.can:384
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
if all(t[2], { -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Nil", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Dots", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Boolean", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Number", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"String" -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
}) then -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
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
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:583
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:584
end -- ./compiler/lua53.can:584
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:586
if hasPush then -- ./compiler/lua53.can:587
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:588
else -- ./compiler/lua53.can:588
push("push", false) -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:590
end -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:590
r = r .. (lua(t[2])) -- ./compiler/lua53.can:592
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:593
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
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:676
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:676
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:678
if hasPush then -- ./compiler/lua53.can:679
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:680
end -- ./compiler/lua53.can:680
pop("push") -- ./compiler/lua53.can:682
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:683
return r -- ./compiler/lua53.can:684
end, -- ./compiler/lua53.can:684
["DoExpr"] = function(t) -- ./compiler/lua53.can:687
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:688
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
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:703
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
elseif t[1]["tag"] == "MethodStub" then -- method call -- ./compiler/lua53.can:726
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
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:738
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
if t["id"] then -- destructing already done before, use parent variable as id -- ./compiler/lua53.can:764
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
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:787
local l = {} -- list of immediately chained safeindex, from deepest to nearest (to simply generated code) -- ./compiler/lua53.can:788
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:789
table["insert"](l, 1, t) -- ./compiler/lua53.can:790
t = t[1] -- ./compiler/lua53.can:791
end -- ./compiler/lua53.can:791
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- base expr -- ./compiler/lua53.can:793
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
local lastInputPos = 1 -- last token position in the input code -- ./compiler/lua53.can:5
local prevLinePos = 1 -- last token position in the previous line of code in the input code -- ./compiler/lua53.can:6
local lastSource = options["chunkname"] or "nil" -- last found code source name (from the original file) -- ./compiler/lua53.can:7
local lastLine = 1 -- last found line number (from the original file) -- ./compiler/lua53.can:8
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
["push"] = {}, -- push stack variable names -- ./compiler/lua53.can:48
["destructuring"] = {}, -- list of variable that need to be assigned from a destructure {id = "parent variable", "field1", "field2"...} -- ./compiler/lua53.can:49
["scope"] = {} -- list of variables defined in the current scope -- ./compiler/lua53.can:50
} -- list of variables defined in the current scope -- ./compiler/lua53.can:50
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
local required = {} -- { ["full require expression"] = true, ... } -- ./compiler/lua53.can:87
local requireStr = "" -- ./compiler/lua53.can:88
local function addRequire(mod, name, field) -- ./compiler/lua53.can:90
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua53.can:91
if not required[req] then -- ./compiler/lua53.can:92
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua53.can:93
required[req] = true -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
local loop = { -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"While", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Repeat", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Fornum", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Forin", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"WhileExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"RepeatExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"FornumExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"ForinExpr" -- loops tags (can contain continue) -- ./compiler/lua53.can:99
} -- loops tags (can contain continue) -- ./compiler/lua53.can:99
local func = { -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"Function", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"TableCompr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"DoExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"WhileExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"RepeatExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"IfExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"FornumExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"ForinExpr" -- function scope tags (can contain push) -- ./compiler/lua53.can:100
} -- function scope tags (can contain push) -- ./compiler/lua53.can:100
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
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:182
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:183
end -- ./compiler/lua53.can:183
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:185
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:188
return "do" .. indent() -- ./compiler/lua53.can:189
end -- ./compiler/lua53.can:189
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:191
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:192
end -- ./compiler/lua53.can:192
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
if newlineAfter == nil then newlineAfter = false end -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
if noLocal == nil then noLocal = false end -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
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
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:236
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:237
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
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:251
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
local toClose = 0 -- blocks that need to be closed at the end of the if -- ./compiler/lua53.can:384
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
if all(t[2], { -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Nil", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Dots", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Boolean", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Number", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"String" -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
}) then -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
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
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:583
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:584
end -- ./compiler/lua53.can:584
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:586
if hasPush then -- ./compiler/lua53.can:587
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:588
else -- ./compiler/lua53.can:588
push("push", false) -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:590
end -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:590
r = r .. (lua(t[2])) -- ./compiler/lua53.can:592
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:593
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
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:676
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:676
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:678
if hasPush then -- ./compiler/lua53.can:679
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:680
end -- ./compiler/lua53.can:680
pop("push") -- ./compiler/lua53.can:682
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:683
return r -- ./compiler/lua53.can:684
end, -- ./compiler/lua53.can:684
["DoExpr"] = function(t) -- ./compiler/lua53.can:687
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:688
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
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:703
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
elseif t[1]["tag"] == "MethodStub" then -- method call -- ./compiler/lua53.can:726
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
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:738
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
if t["id"] then -- destructing already done before, use parent variable as id -- ./compiler/lua53.can:764
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
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:787
local l = {} -- list of immediately chained safeindex, from deepest to nearest (to simply generated code) -- ./compiler/lua53.can:788
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:789
table["insert"](l, 1, t) -- ./compiler/lua53.can:790
t = t[1] -- ./compiler/lua53.can:791
end -- ./compiler/lua53.can:791
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- base expr -- ./compiler/lua53.can:793
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
local lastInputPos = 1 -- last token position in the input code -- ./compiler/lua53.can:5
local prevLinePos = 1 -- last token position in the previous line of code in the input code -- ./compiler/lua53.can:6
local lastSource = options["chunkname"] or "nil" -- last found code source name (from the original file) -- ./compiler/lua53.can:7
local lastLine = 1 -- last found line number (from the original file) -- ./compiler/lua53.can:8
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
["push"] = {}, -- push stack variable names -- ./compiler/lua53.can:48
["destructuring"] = {}, -- list of variable that need to be assigned from a destructure {id = "parent variable", "field1", "field2"...} -- ./compiler/lua53.can:49
["scope"] = {} -- list of variables defined in the current scope -- ./compiler/lua53.can:50
} -- list of variables defined in the current scope -- ./compiler/lua53.can:50
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
local required = {} -- { ["full require expression"] = true, ... } -- ./compiler/lua53.can:87
local requireStr = "" -- ./compiler/lua53.can:88
local function addRequire(mod, name, field) -- ./compiler/lua53.can:90
local req = ("require(%q)%s"):format(mod, field and "." .. field or "") -- ./compiler/lua53.can:91
if not required[req] then -- ./compiler/lua53.can:92
requireStr = requireStr .. (("local %s = %s%s"):format(var(name), req, options["newline"])) -- ./compiler/lua53.can:93
required[req] = true -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
end -- ./compiler/lua53.can:94
local loop = { -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"While", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Repeat", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Fornum", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"Forin", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"WhileExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"RepeatExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"FornumExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:99
"ForinExpr" -- loops tags (can contain continue) -- ./compiler/lua53.can:99
} -- loops tags (can contain continue) -- ./compiler/lua53.can:99
local func = { -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"Function", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"TableCompr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"DoExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"WhileExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"RepeatExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"IfExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"FornumExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:100
"ForinExpr" -- function scope tags (can contain push) -- ./compiler/lua53.can:100
} -- function scope tags (can contain push) -- ./compiler/lua53.can:100
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
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:182
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:183
end -- ./compiler/lua53.can:183
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:185
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:188
return "do" .. indent() -- ./compiler/lua53.can:189
end -- ./compiler/lua53.can:189
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:191
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:192
end -- ./compiler/lua53.can:192
local DESTRUCTURING_ASSIGN = function(destructured, newlineAfter, noLocal) -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
if newlineAfter == nil then newlineAfter = false end -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
if noLocal == nil then noLocal = false end -- to define values from a destructuring assignement -- ./compiler/lua53.can:194
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
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:236
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:237
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
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:251
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
local toClose = 0 -- blocks that need to be closed at the end of the if -- ./compiler/lua53.can:384
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
if all(t[2], { -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Nil", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Dots", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Boolean", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"Number", -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
"String" -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
}) then -- predeclaration doesn't matter here -- ./compiler/lua53.can:472
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
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:583
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:584
end -- ./compiler/lua53.can:584
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:586
if hasPush then -- ./compiler/lua53.can:587
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:588
else -- ./compiler/lua53.can:588
push("push", false) -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:590
end -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:590
r = r .. (lua(t[2])) -- ./compiler/lua53.can:592
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:593
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
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:676
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:676
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:678
if hasPush then -- ./compiler/lua53.can:679
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:680
end -- ./compiler/lua53.can:680
pop("push") -- ./compiler/lua53.can:682
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:683
return r -- ./compiler/lua53.can:684
end, -- ./compiler/lua53.can:684
["DoExpr"] = function(t) -- ./compiler/lua53.can:687
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:688
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
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:703
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
elseif t[1]["tag"] == "MethodStub" then -- method call -- ./compiler/lua53.can:726
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
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:738
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
if t["id"] then -- destructing already done before, use parent variable as id -- ./compiler/lua53.can:764
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
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:787
local l = {} -- list of immediately chained safeindex, from deepest to nearest (to simply generated code) -- ./compiler/lua53.can:788
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:789
table["insert"](l, 1, t) -- ./compiler/lua53.can:790
t = t[1] -- ./compiler/lua53.can:791
end -- ./compiler/lua53.can:791
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- base expr -- ./compiler/lua53.can:793
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
states["continue"] = {} -- when in a loop that use continue -- ./compiler/lua51.can:3
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
local scope = {} -- ./lib/lua-parser/scope.lua:4
scope["lineno"] = function(s, i) -- ./lib/lua-parser/scope.lua:6
if i == 1 then -- ./lib/lua-parser/scope.lua:7
return 1, 1 -- ./lib/lua-parser/scope.lua:7
end -- ./lib/lua-parser/scope.lua:7
local l, lastline = 0, "" -- ./lib/lua-parser/scope.lua:8
s = s:sub(1, i) .. "\
" -- ./lib/lua-parser/scope.lua:9
for line in s:gmatch("[^\
]*[\
]") do -- ./lib/lua-parser/scope.lua:10
l = l + 1 -- ./lib/lua-parser/scope.lua:11
lastline = line -- ./lib/lua-parser/scope.lua:12
end -- ./lib/lua-parser/scope.lua:12
local c = lastline:len() - 1 -- ./lib/lua-parser/scope.lua:14
return l, c ~= 0 and c or 1 -- ./lib/lua-parser/scope.lua:15
end -- ./lib/lua-parser/scope.lua:15
scope["new_scope"] = function(env) -- ./lib/lua-parser/scope.lua:18
if not env["scope"] then -- ./lib/lua-parser/scope.lua:19
env["scope"] = 0 -- ./lib/lua-parser/scope.lua:20
else -- ./lib/lua-parser/scope.lua:20
env["scope"] = env["scope"] + 1 -- ./lib/lua-parser/scope.lua:22
end -- ./lib/lua-parser/scope.lua:22
local scope = env["scope"] -- ./lib/lua-parser/scope.lua:24
env["maxscope"] = scope -- ./lib/lua-parser/scope.lua:25
env[scope] = {} -- ./lib/lua-parser/scope.lua:26
env[scope]["label"] = {} -- ./lib/lua-parser/scope.lua:27
env[scope]["local"] = {} -- ./lib/lua-parser/scope.lua:28
env[scope]["goto"] = {} -- ./lib/lua-parser/scope.lua:29
end -- ./lib/lua-parser/scope.lua:29
scope["begin_scope"] = function(env) -- ./lib/lua-parser/scope.lua:32
env["scope"] = env["scope"] + 1 -- ./lib/lua-parser/scope.lua:33
end -- ./lib/lua-parser/scope.lua:33
scope["end_scope"] = function(env) -- ./lib/lua-parser/scope.lua:36
env["scope"] = env["scope"] - 1 -- ./lib/lua-parser/scope.lua:37
end -- ./lib/lua-parser/scope.lua:37
scope["new_function"] = function(env) -- ./lib/lua-parser/scope.lua:40
if not env["fscope"] then -- ./lib/lua-parser/scope.lua:41
env["fscope"] = 0 -- ./lib/lua-parser/scope.lua:42
else -- ./lib/lua-parser/scope.lua:42
env["fscope"] = env["fscope"] + 1 -- ./lib/lua-parser/scope.lua:44
end -- ./lib/lua-parser/scope.lua:44
local fscope = env["fscope"] -- ./lib/lua-parser/scope.lua:46
env["function"][fscope] = {} -- ./lib/lua-parser/scope.lua:47
end -- ./lib/lua-parser/scope.lua:47
scope["begin_function"] = function(env) -- ./lib/lua-parser/scope.lua:50
env["fscope"] = env["fscope"] + 1 -- ./lib/lua-parser/scope.lua:51
end -- ./lib/lua-parser/scope.lua:51
scope["end_function"] = function(env) -- ./lib/lua-parser/scope.lua:54
env["fscope"] = env["fscope"] - 1 -- ./lib/lua-parser/scope.lua:55
end -- ./lib/lua-parser/scope.lua:55
scope["begin_loop"] = function(env) -- ./lib/lua-parser/scope.lua:58
if not env["loop"] then -- ./lib/lua-parser/scope.lua:59
env["loop"] = 1 -- ./lib/lua-parser/scope.lua:60
else -- ./lib/lua-parser/scope.lua:60
env["loop"] = env["loop"] + 1 -- ./lib/lua-parser/scope.lua:62
end -- ./lib/lua-parser/scope.lua:62
end -- ./lib/lua-parser/scope.lua:62
scope["end_loop"] = function(env) -- ./lib/lua-parser/scope.lua:66
env["loop"] = env["loop"] - 1 -- ./lib/lua-parser/scope.lua:67
end -- ./lib/lua-parser/scope.lua:67
scope["insideloop"] = function(env) -- ./lib/lua-parser/scope.lua:70
return env["loop"] and env["loop"] > 0 -- ./lib/lua-parser/scope.lua:71
end -- ./lib/lua-parser/scope.lua:71
return scope -- ./lib/lua-parser/scope.lua:74
end -- ./lib/lua-parser/scope.lua:74
local scope = _() or scope -- ./lib/lua-parser/scope.lua:78
package["loaded"]["lib.lua-parser.scope"] = scope or true -- ./lib/lua-parser/scope.lua:79
local function _() -- ./lib/lua-parser/scope.lua:82
local scope = require("lib.lua-parser.scope") -- ./lib/lua-parser/validator.lua:4
local lineno = scope["lineno"] -- ./lib/lua-parser/validator.lua:6
local new_scope, end_scope = scope["new_scope"], scope["end_scope"] -- ./lib/lua-parser/validator.lua:7
local new_function, end_function = scope["new_function"], scope["end_function"] -- ./lib/lua-parser/validator.lua:8
local begin_loop, end_loop = scope["begin_loop"], scope["end_loop"] -- ./lib/lua-parser/validator.lua:9
local insideloop = scope["insideloop"] -- ./lib/lua-parser/validator.lua:10
local function syntaxerror(errorinfo, pos, msg) -- ./lib/lua-parser/validator.lua:13
local l, c = lineno(errorinfo["subject"], pos) -- ./lib/lua-parser/validator.lua:14
local error_msg = "%s:%d:%d: syntax error, %s" -- ./lib/lua-parser/validator.lua:15
return string["format"](error_msg, errorinfo["filename"], l, c, msg) -- ./lib/lua-parser/validator.lua:16
end -- ./lib/lua-parser/validator.lua:16
local function exist_label(env, scope, stm) -- ./lib/lua-parser/validator.lua:19
local l = stm[1] -- ./lib/lua-parser/validator.lua:20
for s = scope, 0, - 1 do -- ./lib/lua-parser/validator.lua:21
if env[s]["label"][l] then -- ./lib/lua-parser/validator.lua:22
return true -- ./lib/lua-parser/validator.lua:22
end -- ./lib/lua-parser/validator.lua:22
end -- ./lib/lua-parser/validator.lua:22
return false -- ./lib/lua-parser/validator.lua:24
end -- ./lib/lua-parser/validator.lua:24
local function set_label(env, label, pos) -- ./lib/lua-parser/validator.lua:27
local scope = env["scope"] -- ./lib/lua-parser/validator.lua:28
local l = env[scope]["label"][label] -- ./lib/lua-parser/validator.lua:29
if not l then -- ./lib/lua-parser/validator.lua:30
env[scope]["label"][label] = { -- ./lib/lua-parser/validator.lua:31
["name"] = label, -- ./lib/lua-parser/validator.lua:31
["pos"] = pos -- ./lib/lua-parser/validator.lua:31
} -- ./lib/lua-parser/validator.lua:31
return true -- ./lib/lua-parser/validator.lua:32
else -- ./lib/lua-parser/validator.lua:32
local msg = "label '%s' already defined at line %d" -- ./lib/lua-parser/validator.lua:34
local line = lineno(env["errorinfo"]["subject"], l["pos"]) -- ./lib/lua-parser/validator.lua:35
msg = string["format"](msg, label, line) -- ./lib/lua-parser/validator.lua:36
return nil, syntaxerror(env["errorinfo"], pos, msg) -- ./lib/lua-parser/validator.lua:37
end -- ./lib/lua-parser/validator.lua:37
end -- ./lib/lua-parser/validator.lua:37
local function set_pending_goto(env, stm) -- ./lib/lua-parser/validator.lua:41
local scope = env["scope"] -- ./lib/lua-parser/validator.lua:42
table["insert"](env[scope]["goto"], stm) -- ./lib/lua-parser/validator.lua:43
return true -- ./lib/lua-parser/validator.lua:44
end -- ./lib/lua-parser/validator.lua:44
local function verify_pending_gotos(env) -- ./lib/lua-parser/validator.lua:47
for s = env["maxscope"], 0, - 1 do -- ./lib/lua-parser/validator.lua:48
for k, v in ipairs(env[s]["goto"]) do -- ./lib/lua-parser/validator.lua:49
if not exist_label(env, s, v) then -- ./lib/lua-parser/validator.lua:50
local msg = "no visible label '%s' for <goto>" -- ./lib/lua-parser/validator.lua:51
msg = string["format"](msg, v[1]) -- ./lib/lua-parser/validator.lua:52
return nil, syntaxerror(env["errorinfo"], v["pos"], msg) -- ./lib/lua-parser/validator.lua:53
end -- ./lib/lua-parser/validator.lua:53
end -- ./lib/lua-parser/validator.lua:53
end -- ./lib/lua-parser/validator.lua:53
return true -- ./lib/lua-parser/validator.lua:57
end -- ./lib/lua-parser/validator.lua:57
local function set_vararg(env, is_vararg) -- ./lib/lua-parser/validator.lua:60
env["function"][env["fscope"]]["is_vararg"] = is_vararg -- ./lib/lua-parser/validator.lua:61
end -- ./lib/lua-parser/validator.lua:61
local traverse_stm, traverse_exp, traverse_var -- ./lib/lua-parser/validator.lua:64
local traverse_block, traverse_explist, traverse_varlist, traverse_parlist -- ./lib/lua-parser/validator.lua:65
traverse_parlist = function(env, parlist) -- ./lib/lua-parser/validator.lua:67
local len = # parlist -- ./lib/lua-parser/validator.lua:68
local is_vararg = false -- ./lib/lua-parser/validator.lua:69
if len > 0 and parlist[len]["tag"] == "Dots" then -- ./lib/lua-parser/validator.lua:70
is_vararg = true -- ./lib/lua-parser/validator.lua:71
end -- ./lib/lua-parser/validator.lua:71
set_vararg(env, is_vararg) -- ./lib/lua-parser/validator.lua:73
return true -- ./lib/lua-parser/validator.lua:74
end -- ./lib/lua-parser/validator.lua:74
local function traverse_function(env, exp) -- ./lib/lua-parser/validator.lua:77
new_function(env) -- ./lib/lua-parser/validator.lua:78
new_scope(env) -- ./lib/lua-parser/validator.lua:79
local status, msg = traverse_parlist(env, exp[1]) -- ./lib/lua-parser/validator.lua:80
if not status then -- ./lib/lua-parser/validator.lua:81
return status, msg -- ./lib/lua-parser/validator.lua:81
end -- ./lib/lua-parser/validator.lua:81
status, msg = traverse_block(env, exp[2]) -- ./lib/lua-parser/validator.lua:82
if not status then -- ./lib/lua-parser/validator.lua:83
return status, msg -- ./lib/lua-parser/validator.lua:83
end -- ./lib/lua-parser/validator.lua:83
end_scope(env) -- ./lib/lua-parser/validator.lua:84
end_function(env) -- ./lib/lua-parser/validator.lua:85
return true -- ./lib/lua-parser/validator.lua:86
end -- ./lib/lua-parser/validator.lua:86
local function traverse_tablecompr(env, exp) -- ./lib/lua-parser/validator.lua:89
new_function(env) -- ./lib/lua-parser/validator.lua:90
new_scope(env) -- ./lib/lua-parser/validator.lua:91
local status, msg = traverse_block(env, exp[1]) -- ./lib/lua-parser/validator.lua:92
if not status then -- ./lib/lua-parser/validator.lua:93
return status, msg -- ./lib/lua-parser/validator.lua:93
end -- ./lib/lua-parser/validator.lua:93
end_scope(env) -- ./lib/lua-parser/validator.lua:94
end_function(env) -- ./lib/lua-parser/validator.lua:95
return true -- ./lib/lua-parser/validator.lua:96
end -- ./lib/lua-parser/validator.lua:96
local function traverse_statexpr(env, exp) -- ./lib/lua-parser/validator.lua:99
new_function(env) -- ./lib/lua-parser/validator.lua:100
new_scope(env) -- ./lib/lua-parser/validator.lua:101
exp["tag"] = exp["tag"]:gsub("Expr$", "") -- ./lib/lua-parser/validator.lua:102
local status, msg = traverse_stm(env, exp) -- ./lib/lua-parser/validator.lua:103
exp["tag"] = exp["tag"] .. "Expr" -- ./lib/lua-parser/validator.lua:104
if not status then -- ./lib/lua-parser/validator.lua:105
return status, msg -- ./lib/lua-parser/validator.lua:105
end -- ./lib/lua-parser/validator.lua:105
end_scope(env) -- ./lib/lua-parser/validator.lua:106
end_function(env) -- ./lib/lua-parser/validator.lua:107
return true -- ./lib/lua-parser/validator.lua:108
end -- ./lib/lua-parser/validator.lua:108
local function traverse_op(env, exp) -- ./lib/lua-parser/validator.lua:111
local status, msg = traverse_exp(env, exp[2]) -- ./lib/lua-parser/validator.lua:112
if not status then -- ./lib/lua-parser/validator.lua:113
return status, msg -- ./lib/lua-parser/validator.lua:113
end -- ./lib/lua-parser/validator.lua:113
if exp[3] then -- ./lib/lua-parser/validator.lua:114
status, msg = traverse_exp(env, exp[3]) -- ./lib/lua-parser/validator.lua:115
if not status then -- ./lib/lua-parser/validator.lua:116
return status, msg -- ./lib/lua-parser/validator.lua:116
end -- ./lib/lua-parser/validator.lua:116
end -- ./lib/lua-parser/validator.lua:116
return true -- ./lib/lua-parser/validator.lua:118
end -- ./lib/lua-parser/validator.lua:118
local function traverse_paren(env, exp) -- ./lib/lua-parser/validator.lua:121
local status, msg = traverse_exp(env, exp[1]) -- ./lib/lua-parser/validator.lua:122
if not status then -- ./lib/lua-parser/validator.lua:123
return status, msg -- ./lib/lua-parser/validator.lua:123
end -- ./lib/lua-parser/validator.lua:123
return true -- ./lib/lua-parser/validator.lua:124
end -- ./lib/lua-parser/validator.lua:124
local function traverse_table(env, fieldlist) -- ./lib/lua-parser/validator.lua:127
for k, v in ipairs(fieldlist) do -- ./lib/lua-parser/validator.lua:128
local tag = v["tag"] -- ./lib/lua-parser/validator.lua:129
if tag == "Pair" then -- ./lib/lua-parser/validator.lua:130
local status, msg = traverse_exp(env, v[1]) -- ./lib/lua-parser/validator.lua:131
if not status then -- ./lib/lua-parser/validator.lua:132
return status, msg -- ./lib/lua-parser/validator.lua:132
end -- ./lib/lua-parser/validator.lua:132
status, msg = traverse_exp(env, v[2]) -- ./lib/lua-parser/validator.lua:133
if not status then -- ./lib/lua-parser/validator.lua:134
return status, msg -- ./lib/lua-parser/validator.lua:134
end -- ./lib/lua-parser/validator.lua:134
else -- ./lib/lua-parser/validator.lua:134
local status, msg = traverse_exp(env, v) -- ./lib/lua-parser/validator.lua:136
if not status then -- ./lib/lua-parser/validator.lua:137
return status, msg -- ./lib/lua-parser/validator.lua:137
end -- ./lib/lua-parser/validator.lua:137
end -- ./lib/lua-parser/validator.lua:137
end -- ./lib/lua-parser/validator.lua:137
return true -- ./lib/lua-parser/validator.lua:140
end -- ./lib/lua-parser/validator.lua:140
local function traverse_vararg(env, exp) -- ./lib/lua-parser/validator.lua:143
if not env["function"][env["fscope"]]["is_vararg"] then -- ./lib/lua-parser/validator.lua:144
local msg = "cannot use '...' outside a vararg function" -- ./lib/lua-parser/validator.lua:145
return nil, syntaxerror(env["errorinfo"], exp["pos"], msg) -- ./lib/lua-parser/validator.lua:146
end -- ./lib/lua-parser/validator.lua:146
return true -- ./lib/lua-parser/validator.lua:148
end -- ./lib/lua-parser/validator.lua:148
local function traverse_call(env, call) -- ./lib/lua-parser/validator.lua:151
local status, msg = traverse_exp(env, call[1]) -- ./lib/lua-parser/validator.lua:152
if not status then -- ./lib/lua-parser/validator.lua:153
return status, msg -- ./lib/lua-parser/validator.lua:153
end -- ./lib/lua-parser/validator.lua:153
for i = 2, # call do -- ./lib/lua-parser/validator.lua:154
status, msg = traverse_exp(env, call[i]) -- ./lib/lua-parser/validator.lua:155
if not status then -- ./lib/lua-parser/validator.lua:156
return status, msg -- ./lib/lua-parser/validator.lua:156
end -- ./lib/lua-parser/validator.lua:156
end -- ./lib/lua-parser/validator.lua:156
return true -- ./lib/lua-parser/validator.lua:158
end -- ./lib/lua-parser/validator.lua:158
local function traverse_assignment(env, stm) -- ./lib/lua-parser/validator.lua:161
local status, msg = traverse_varlist(env, stm[1]) -- ./lib/lua-parser/validator.lua:162
if not status then -- ./lib/lua-parser/validator.lua:163
return status, msg -- ./lib/lua-parser/validator.lua:163
end -- ./lib/lua-parser/validator.lua:163
status, msg = traverse_explist(env, stm[# stm]) -- ./lib/lua-parser/validator.lua:164
if not status then -- ./lib/lua-parser/validator.lua:165
return status, msg -- ./lib/lua-parser/validator.lua:165
end -- ./lib/lua-parser/validator.lua:165
return true -- ./lib/lua-parser/validator.lua:166
end -- ./lib/lua-parser/validator.lua:166
local function traverse_break(env, stm) -- ./lib/lua-parser/validator.lua:169
if not insideloop(env) then -- ./lib/lua-parser/validator.lua:170
local msg = "<break> not inside a loop" -- ./lib/lua-parser/validator.lua:171
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg) -- ./lib/lua-parser/validator.lua:172
end -- ./lib/lua-parser/validator.lua:172
return true -- ./lib/lua-parser/validator.lua:174
end -- ./lib/lua-parser/validator.lua:174
local function traverse_continue(env, stm) -- ./lib/lua-parser/validator.lua:177
if not insideloop(env) then -- ./lib/lua-parser/validator.lua:178
local msg = "<continue> not inside a loop" -- ./lib/lua-parser/validator.lua:179
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg) -- ./lib/lua-parser/validator.lua:180
end -- ./lib/lua-parser/validator.lua:180
return true -- ./lib/lua-parser/validator.lua:182
end -- ./lib/lua-parser/validator.lua:182
local function traverse_push(env, stm) -- ./lib/lua-parser/validator.lua:185
local status, msg = traverse_explist(env, stm) -- ./lib/lua-parser/validator.lua:186
if not status then -- ./lib/lua-parser/validator.lua:187
return status, msg -- ./lib/lua-parser/validator.lua:187
end -- ./lib/lua-parser/validator.lua:187
return true -- ./lib/lua-parser/validator.lua:188
end -- ./lib/lua-parser/validator.lua:188
local function traverse_forin(env, stm) -- ./lib/lua-parser/validator.lua:191
begin_loop(env) -- ./lib/lua-parser/validator.lua:192
new_scope(env) -- ./lib/lua-parser/validator.lua:193
local status, msg = traverse_explist(env, stm[2]) -- ./lib/lua-parser/validator.lua:194
if not status then -- ./lib/lua-parser/validator.lua:195
return status, msg -- ./lib/lua-parser/validator.lua:195
end -- ./lib/lua-parser/validator.lua:195
status, msg = traverse_block(env, stm[3]) -- ./lib/lua-parser/validator.lua:196
if not status then -- ./lib/lua-parser/validator.lua:197
return status, msg -- ./lib/lua-parser/validator.lua:197
end -- ./lib/lua-parser/validator.lua:197
end_scope(env) -- ./lib/lua-parser/validator.lua:198
end_loop(env) -- ./lib/lua-parser/validator.lua:199
return true -- ./lib/lua-parser/validator.lua:200
end -- ./lib/lua-parser/validator.lua:200
local function traverse_fornum(env, stm) -- ./lib/lua-parser/validator.lua:203
local status, msg -- ./lib/lua-parser/validator.lua:204
begin_loop(env) -- ./lib/lua-parser/validator.lua:205
new_scope(env) -- ./lib/lua-parser/validator.lua:206
status, msg = traverse_exp(env, stm[2]) -- ./lib/lua-parser/validator.lua:207
if not status then -- ./lib/lua-parser/validator.lua:208
return status, msg -- ./lib/lua-parser/validator.lua:208
end -- ./lib/lua-parser/validator.lua:208
status, msg = traverse_exp(env, stm[3]) -- ./lib/lua-parser/validator.lua:209
if not status then -- ./lib/lua-parser/validator.lua:210
return status, msg -- ./lib/lua-parser/validator.lua:210
end -- ./lib/lua-parser/validator.lua:210
if stm[5] then -- ./lib/lua-parser/validator.lua:211
status, msg = traverse_exp(env, stm[4]) -- ./lib/lua-parser/validator.lua:212
if not status then -- ./lib/lua-parser/validator.lua:213
return status, msg -- ./lib/lua-parser/validator.lua:213
end -- ./lib/lua-parser/validator.lua:213
status, msg = traverse_block(env, stm[5]) -- ./lib/lua-parser/validator.lua:214
if not status then -- ./lib/lua-parser/validator.lua:215
return status, msg -- ./lib/lua-parser/validator.lua:215
end -- ./lib/lua-parser/validator.lua:215
else -- ./lib/lua-parser/validator.lua:215
status, msg = traverse_block(env, stm[4]) -- ./lib/lua-parser/validator.lua:217
if not status then -- ./lib/lua-parser/validator.lua:218
return status, msg -- ./lib/lua-parser/validator.lua:218
end -- ./lib/lua-parser/validator.lua:218
end -- ./lib/lua-parser/validator.lua:218
end_scope(env) -- ./lib/lua-parser/validator.lua:220
end_loop(env) -- ./lib/lua-parser/validator.lua:221
return true -- ./lib/lua-parser/validator.lua:222
end -- ./lib/lua-parser/validator.lua:222
local function traverse_goto(env, stm) -- ./lib/lua-parser/validator.lua:225
local status, msg = set_pending_goto(env, stm) -- ./lib/lua-parser/validator.lua:226
if not status then -- ./lib/lua-parser/validator.lua:227
return status, msg -- ./lib/lua-parser/validator.lua:227
end -- ./lib/lua-parser/validator.lua:227
return true -- ./lib/lua-parser/validator.lua:228
end -- ./lib/lua-parser/validator.lua:228
local function traverse_let(env, stm) -- ./lib/lua-parser/validator.lua:231
local status, msg = traverse_explist(env, stm[2]) -- ./lib/lua-parser/validator.lua:232
if not status then -- ./lib/lua-parser/validator.lua:233
return status, msg -- ./lib/lua-parser/validator.lua:233
end -- ./lib/lua-parser/validator.lua:233
return true -- ./lib/lua-parser/validator.lua:234
end -- ./lib/lua-parser/validator.lua:234
local function traverse_letrec(env, stm) -- ./lib/lua-parser/validator.lua:237
local status, msg = traverse_exp(env, stm[2][1]) -- ./lib/lua-parser/validator.lua:238
if not status then -- ./lib/lua-parser/validator.lua:239
return status, msg -- ./lib/lua-parser/validator.lua:239
end -- ./lib/lua-parser/validator.lua:239
return true -- ./lib/lua-parser/validator.lua:240
end -- ./lib/lua-parser/validator.lua:240
local function traverse_if(env, stm) -- ./lib/lua-parser/validator.lua:243
local len = # stm -- ./lib/lua-parser/validator.lua:244
if len % 2 == 0 then -- ./lib/lua-parser/validator.lua:245
for i = 1, len, 2 do -- ./lib/lua-parser/validator.lua:246
local status, msg = traverse_exp(env, stm[i]) -- ./lib/lua-parser/validator.lua:247
if not status then -- ./lib/lua-parser/validator.lua:248
return status, msg -- ./lib/lua-parser/validator.lua:248
end -- ./lib/lua-parser/validator.lua:248
status, msg = traverse_block(env, stm[i + 1]) -- ./lib/lua-parser/validator.lua:249
if not status then -- ./lib/lua-parser/validator.lua:250
return status, msg -- ./lib/lua-parser/validator.lua:250
end -- ./lib/lua-parser/validator.lua:250
end -- ./lib/lua-parser/validator.lua:250
else -- ./lib/lua-parser/validator.lua:250
for i = 1, len - 1, 2 do -- ./lib/lua-parser/validator.lua:253
local status, msg = traverse_exp(env, stm[i]) -- ./lib/lua-parser/validator.lua:254
if not status then -- ./lib/lua-parser/validator.lua:255
return status, msg -- ./lib/lua-parser/validator.lua:255
end -- ./lib/lua-parser/validator.lua:255
status, msg = traverse_block(env, stm[i + 1]) -- ./lib/lua-parser/validator.lua:256
if not status then -- ./lib/lua-parser/validator.lua:257
return status, msg -- ./lib/lua-parser/validator.lua:257
end -- ./lib/lua-parser/validator.lua:257
end -- ./lib/lua-parser/validator.lua:257
local status, msg = traverse_block(env, stm[len]) -- ./lib/lua-parser/validator.lua:259
if not status then -- ./lib/lua-parser/validator.lua:260
return status, msg -- ./lib/lua-parser/validator.lua:260
end -- ./lib/lua-parser/validator.lua:260
end -- ./lib/lua-parser/validator.lua:260
return true -- ./lib/lua-parser/validator.lua:262
end -- ./lib/lua-parser/validator.lua:262
local function traverse_label(env, stm) -- ./lib/lua-parser/validator.lua:265
local status, msg = set_label(env, stm[1], stm["pos"]) -- ./lib/lua-parser/validator.lua:266
if not status then -- ./lib/lua-parser/validator.lua:267
return status, msg -- ./lib/lua-parser/validator.lua:267
end -- ./lib/lua-parser/validator.lua:267
return true -- ./lib/lua-parser/validator.lua:268
end -- ./lib/lua-parser/validator.lua:268
local function traverse_repeat(env, stm) -- ./lib/lua-parser/validator.lua:271
begin_loop(env) -- ./lib/lua-parser/validator.lua:272
local status, msg = traverse_block(env, stm[1]) -- ./lib/lua-parser/validator.lua:273
if not status then -- ./lib/lua-parser/validator.lua:274
return status, msg -- ./lib/lua-parser/validator.lua:274
end -- ./lib/lua-parser/validator.lua:274
status, msg = traverse_exp(env, stm[2]) -- ./lib/lua-parser/validator.lua:275
if not status then -- ./lib/lua-parser/validator.lua:276
return status, msg -- ./lib/lua-parser/validator.lua:276
end -- ./lib/lua-parser/validator.lua:276
end_loop(env) -- ./lib/lua-parser/validator.lua:277
return true -- ./lib/lua-parser/validator.lua:278
end -- ./lib/lua-parser/validator.lua:278
local function traverse_return(env, stm) -- ./lib/lua-parser/validator.lua:281
local status, msg = traverse_explist(env, stm) -- ./lib/lua-parser/validator.lua:282
if not status then -- ./lib/lua-parser/validator.lua:283
return status, msg -- ./lib/lua-parser/validator.lua:283
end -- ./lib/lua-parser/validator.lua:283
return true -- ./lib/lua-parser/validator.lua:284
end -- ./lib/lua-parser/validator.lua:284
local function traverse_while(env, stm) -- ./lib/lua-parser/validator.lua:287
begin_loop(env) -- ./lib/lua-parser/validator.lua:288
local status, msg = traverse_exp(env, stm[1]) -- ./lib/lua-parser/validator.lua:289
if not status then -- ./lib/lua-parser/validator.lua:290
return status, msg -- ./lib/lua-parser/validator.lua:290
end -- ./lib/lua-parser/validator.lua:290
status, msg = traverse_block(env, stm[2]) -- ./lib/lua-parser/validator.lua:291
if not status then -- ./lib/lua-parser/validator.lua:292
return status, msg -- ./lib/lua-parser/validator.lua:292
end -- ./lib/lua-parser/validator.lua:292
end_loop(env) -- ./lib/lua-parser/validator.lua:293
return true -- ./lib/lua-parser/validator.lua:294
end -- ./lib/lua-parser/validator.lua:294
traverse_var = function(env, var) -- ./lib/lua-parser/validator.lua:297
local tag = var["tag"] -- ./lib/lua-parser/validator.lua:298
if tag == "Id" then -- `Id{ <string> } -- ./lib/lua-parser/validator.lua:299
return true -- ./lib/lua-parser/validator.lua:300
elseif tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/validator.lua:301
local status, msg = traverse_exp(env, var[1]) -- ./lib/lua-parser/validator.lua:302
if not status then -- ./lib/lua-parser/validator.lua:303
return status, msg -- ./lib/lua-parser/validator.lua:303
end -- ./lib/lua-parser/validator.lua:303
status, msg = traverse_exp(env, var[2]) -- ./lib/lua-parser/validator.lua:304
if not status then -- ./lib/lua-parser/validator.lua:305
return status, msg -- ./lib/lua-parser/validator.lua:305
end -- ./lib/lua-parser/validator.lua:305
return true -- ./lib/lua-parser/validator.lua:306
elseif tag == "DestructuringId" then -- ./lib/lua-parser/validator.lua:307
return traverse_table(env, var) -- ./lib/lua-parser/validator.lua:308
else -- ./lib/lua-parser/validator.lua:308
error("expecting a variable, but got a " .. tag) -- ./lib/lua-parser/validator.lua:310
end -- ./lib/lua-parser/validator.lua:310
end -- ./lib/lua-parser/validator.lua:310
traverse_varlist = function(env, varlist) -- ./lib/lua-parser/validator.lua:314
for k, v in ipairs(varlist) do -- ./lib/lua-parser/validator.lua:315
local status, msg = traverse_var(env, v) -- ./lib/lua-parser/validator.lua:316
if not status then -- ./lib/lua-parser/validator.lua:317
return status, msg -- ./lib/lua-parser/validator.lua:317
end -- ./lib/lua-parser/validator.lua:317
end -- ./lib/lua-parser/validator.lua:317
return true -- ./lib/lua-parser/validator.lua:319
end -- ./lib/lua-parser/validator.lua:319
local function traverse_methodstub(env, var) -- ./lib/lua-parser/validator.lua:322
local status, msg = traverse_exp(env, var[1]) -- ./lib/lua-parser/validator.lua:323
if not status then -- ./lib/lua-parser/validator.lua:324
return status, msg -- ./lib/lua-parser/validator.lua:324
end -- ./lib/lua-parser/validator.lua:324
status, msg = traverse_exp(env, var[2]) -- ./lib/lua-parser/validator.lua:325
if not status then -- ./lib/lua-parser/validator.lua:326
return status, msg -- ./lib/lua-parser/validator.lua:326
end -- ./lib/lua-parser/validator.lua:326
return true -- ./lib/lua-parser/validator.lua:327
end -- ./lib/lua-parser/validator.lua:327
local function traverse_safeindex(env, var) -- ./lib/lua-parser/validator.lua:330
local status, msg = traverse_exp(env, var[1]) -- ./lib/lua-parser/validator.lua:331
if not status then -- ./lib/lua-parser/validator.lua:332
return status, msg -- ./lib/lua-parser/validator.lua:332
end -- ./lib/lua-parser/validator.lua:332
status, msg = traverse_exp(env, var[2]) -- ./lib/lua-parser/validator.lua:333
if not status then -- ./lib/lua-parser/validator.lua:334
return status, msg -- ./lib/lua-parser/validator.lua:334
end -- ./lib/lua-parser/validator.lua:334
return true -- ./lib/lua-parser/validator.lua:335
end -- ./lib/lua-parser/validator.lua:335
traverse_exp = function(env, exp) -- ./lib/lua-parser/validator.lua:338
local tag = exp["tag"] -- ./lib/lua-parser/validator.lua:339
if tag == "Nil" or tag == "Boolean" or tag == "Number" or tag == "String" then -- `String{ <string> } -- ./lib/lua-parser/validator.lua:343
return true -- ./lib/lua-parser/validator.lua:344
elseif tag == "Dots" then -- ./lib/lua-parser/validator.lua:345
return traverse_vararg(env, exp) -- ./lib/lua-parser/validator.lua:346
elseif tag == "Function" then -- `Function{ { `Id{ <string> }* `Dots? } block } -- ./lib/lua-parser/validator.lua:347
return traverse_function(env, exp) -- ./lib/lua-parser/validator.lua:348
elseif tag == "Table" then -- `Table{ ( `Pair{ expr expr } | expr )* } -- ./lib/lua-parser/validator.lua:349
return traverse_table(env, exp) -- ./lib/lua-parser/validator.lua:350
elseif tag == "Op" then -- `Op{ opid expr expr? } -- ./lib/lua-parser/validator.lua:351
return traverse_op(env, exp) -- ./lib/lua-parser/validator.lua:352
elseif tag == "Paren" then -- `Paren{ expr } -- ./lib/lua-parser/validator.lua:353
return traverse_paren(env, exp) -- ./lib/lua-parser/validator.lua:354
elseif tag == "Call" or tag == "SafeCall" then -- `(Safe)Call{ expr expr* } -- ./lib/lua-parser/validator.lua:355
return traverse_call(env, exp) -- ./lib/lua-parser/validator.lua:356
elseif tag == "Id" or tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/validator.lua:358
return traverse_var(env, exp) -- ./lib/lua-parser/validator.lua:359
elseif tag == "SafeIndex" then -- `SafeIndex{ expr expr } -- ./lib/lua-parser/validator.lua:360
return traverse_safeindex(env, exp) -- ./lib/lua-parser/validator.lua:361
elseif tag == "TableCompr" then -- `TableCompr{ block } -- ./lib/lua-parser/validator.lua:362
return traverse_tablecompr(env, exp) -- ./lib/lua-parser/validator.lua:363
elseif tag == "MethodStub" or tag == "SafeMethodStub" then -- `(Safe)MethodStub{ expr expr } -- ./lib/lua-parser/validator.lua:364
return traverse_methodstub(env, exp) -- ./lib/lua-parser/validator.lua:365
elseif tag:match("Expr$") then -- `StatExpr{ ... } -- ./lib/lua-parser/validator.lua:366
return traverse_statexpr(env, exp) -- ./lib/lua-parser/validator.lua:367
else -- ./lib/lua-parser/validator.lua:367
error("expecting an expression, but got a " .. tag) -- ./lib/lua-parser/validator.lua:369
end -- ./lib/lua-parser/validator.lua:369
end -- ./lib/lua-parser/validator.lua:369
traverse_explist = function(env, explist) -- ./lib/lua-parser/validator.lua:373
for k, v in ipairs(explist) do -- ./lib/lua-parser/validator.lua:374
local status, msg = traverse_exp(env, v) -- ./lib/lua-parser/validator.lua:375
if not status then -- ./lib/lua-parser/validator.lua:376
return status, msg -- ./lib/lua-parser/validator.lua:376
end -- ./lib/lua-parser/validator.lua:376
end -- ./lib/lua-parser/validator.lua:376
return true -- ./lib/lua-parser/validator.lua:378
end -- ./lib/lua-parser/validator.lua:378
traverse_stm = function(env, stm) -- ./lib/lua-parser/validator.lua:381
local tag = stm["tag"] -- ./lib/lua-parser/validator.lua:382
if tag == "Do" then -- `Do{ stat* } -- ./lib/lua-parser/validator.lua:383
return traverse_block(env, stm) -- ./lib/lua-parser/validator.lua:384
elseif tag == "Set" then -- `Set{ {lhs+} (opid? = opid?)? {expr+} } -- ./lib/lua-parser/validator.lua:385
return traverse_assignment(env, stm) -- ./lib/lua-parser/validator.lua:386
elseif tag == "While" then -- `While{ expr block } -- ./lib/lua-parser/validator.lua:387
return traverse_while(env, stm) -- ./lib/lua-parser/validator.lua:388
elseif tag == "Repeat" then -- `Repeat{ block expr } -- ./lib/lua-parser/validator.lua:389
return traverse_repeat(env, stm) -- ./lib/lua-parser/validator.lua:390
elseif tag == "If" then -- `If{ (expr block)+ block? } -- ./lib/lua-parser/validator.lua:391
return traverse_if(env, stm) -- ./lib/lua-parser/validator.lua:392
elseif tag == "Fornum" then -- `Fornum{ ident expr expr expr? block } -- ./lib/lua-parser/validator.lua:393
return traverse_fornum(env, stm) -- ./lib/lua-parser/validator.lua:394
elseif tag == "Forin" then -- `Forin{ {ident+} {expr+} block } -- ./lib/lua-parser/validator.lua:395
return traverse_forin(env, stm) -- ./lib/lua-parser/validator.lua:396
elseif tag == "Local" or tag == "Let" then -- `Let{ {ident+} {expr+}? } -- ./lib/lua-parser/validator.lua:398
return traverse_let(env, stm) -- ./lib/lua-parser/validator.lua:399
elseif tag == "Localrec" then -- `Localrec{ ident expr } -- ./lib/lua-parser/validator.lua:400
return traverse_letrec(env, stm) -- ./lib/lua-parser/validator.lua:401
elseif tag == "Goto" then -- `Goto{ <string> } -- ./lib/lua-parser/validator.lua:402
return traverse_goto(env, stm) -- ./lib/lua-parser/validator.lua:403
elseif tag == "Label" then -- `Label{ <string> } -- ./lib/lua-parser/validator.lua:404
return traverse_label(env, stm) -- ./lib/lua-parser/validator.lua:405
elseif tag == "Return" then -- `Return{ <expr>* } -- ./lib/lua-parser/validator.lua:406
return traverse_return(env, stm) -- ./lib/lua-parser/validator.lua:407
elseif tag == "Break" then -- ./lib/lua-parser/validator.lua:408
return traverse_break(env, stm) -- ./lib/lua-parser/validator.lua:409
elseif tag == "Call" then -- `Call{ expr expr* } -- ./lib/lua-parser/validator.lua:410
return traverse_call(env, stm) -- ./lib/lua-parser/validator.lua:411
elseif tag == "Continue" then -- ./lib/lua-parser/validator.lua:412
return traverse_continue(env, stm) -- ./lib/lua-parser/validator.lua:413
elseif tag == "Push" then -- `Push{ <expr>* } -- ./lib/lua-parser/validator.lua:414
return traverse_push(env, stm) -- ./lib/lua-parser/validator.lua:415
else -- ./lib/lua-parser/validator.lua:415
error("expecting a statement, but got a " .. tag) -- ./lib/lua-parser/validator.lua:417
end -- ./lib/lua-parser/validator.lua:417
end -- ./lib/lua-parser/validator.lua:417
traverse_block = function(env, block) -- ./lib/lua-parser/validator.lua:421
local l = {} -- ./lib/lua-parser/validator.lua:422
new_scope(env) -- ./lib/lua-parser/validator.lua:423
for k, v in ipairs(block) do -- ./lib/lua-parser/validator.lua:424
local status, msg = traverse_stm(env, v) -- ./lib/lua-parser/validator.lua:425
if not status then -- ./lib/lua-parser/validator.lua:426
return status, msg -- ./lib/lua-parser/validator.lua:426
end -- ./lib/lua-parser/validator.lua:426
end -- ./lib/lua-parser/validator.lua:426
end_scope(env) -- ./lib/lua-parser/validator.lua:428
return true -- ./lib/lua-parser/validator.lua:429
end -- ./lib/lua-parser/validator.lua:429
local function traverse(ast, errorinfo) -- ./lib/lua-parser/validator.lua:433
assert(type(ast) == "table") -- ./lib/lua-parser/validator.lua:434
assert(type(errorinfo) == "table") -- ./lib/lua-parser/validator.lua:435
local env = { -- ./lib/lua-parser/validator.lua:436
["errorinfo"] = errorinfo, -- ./lib/lua-parser/validator.lua:436
["function"] = {} -- ./lib/lua-parser/validator.lua:436
} -- ./lib/lua-parser/validator.lua:436
new_function(env) -- ./lib/lua-parser/validator.lua:437
set_vararg(env, true) -- ./lib/lua-parser/validator.lua:438
local status, msg = traverse_block(env, ast) -- ./lib/lua-parser/validator.lua:439
if not status then -- ./lib/lua-parser/validator.lua:440
return status, msg -- ./lib/lua-parser/validator.lua:440
end -- ./lib/lua-parser/validator.lua:440
end_function(env) -- ./lib/lua-parser/validator.lua:441
status, msg = verify_pending_gotos(env) -- ./lib/lua-parser/validator.lua:442
if not status then -- ./lib/lua-parser/validator.lua:443
return status, msg -- ./lib/lua-parser/validator.lua:443
end -- ./lib/lua-parser/validator.lua:443
return ast -- ./lib/lua-parser/validator.lua:444
end -- ./lib/lua-parser/validator.lua:444
return { -- ./lib/lua-parser/validator.lua:447
["validate"] = traverse, -- ./lib/lua-parser/validator.lua:447
["syntaxerror"] = syntaxerror -- ./lib/lua-parser/validator.lua:447
} -- ./lib/lua-parser/validator.lua:447
end -- ./lib/lua-parser/validator.lua:447
local validator = _() or validator -- ./lib/lua-parser/validator.lua:451
package["loaded"]["lib.lua-parser.validator"] = validator or true -- ./lib/lua-parser/validator.lua:452
local function _() -- ./lib/lua-parser/validator.lua:455
local pp = {} -- ./lib/lua-parser/pp.lua:4
local block2str, stm2str, exp2str, var2str -- ./lib/lua-parser/pp.lua:6
local explist2str, varlist2str, parlist2str, fieldlist2str -- ./lib/lua-parser/pp.lua:7
local function iscntrl(x) -- ./lib/lua-parser/pp.lua:9
if (x >= 0 and x <= 31) or (x == 127) then -- ./lib/lua-parser/pp.lua:10
return true -- ./lib/lua-parser/pp.lua:10
end -- ./lib/lua-parser/pp.lua:10
return false -- ./lib/lua-parser/pp.lua:11
end -- ./lib/lua-parser/pp.lua:11
local function isprint(x) -- ./lib/lua-parser/pp.lua:14
return not iscntrl(x) -- ./lib/lua-parser/pp.lua:15
end -- ./lib/lua-parser/pp.lua:15
local function fixed_string(str) -- ./lib/lua-parser/pp.lua:18
local new_str = "" -- ./lib/lua-parser/pp.lua:19
for i = 1, string["len"](str) do -- ./lib/lua-parser/pp.lua:20
char = string["byte"](str, i) -- ./lib/lua-parser/pp.lua:21
if char == 34 then -- ./lib/lua-parser/pp.lua:22
new_str = new_str .. string["format"]("\\\"") -- ./lib/lua-parser/pp.lua:22
elseif char == 92 then -- ./lib/lua-parser/pp.lua:23
new_str = new_str .. string["format"]("\\\\") -- ./lib/lua-parser/pp.lua:23
elseif char == 7 then -- ./lib/lua-parser/pp.lua:24
new_str = new_str .. string["format"]("\\a") -- ./lib/lua-parser/pp.lua:24
elseif char == 8 then -- ./lib/lua-parser/pp.lua:25
new_str = new_str .. string["format"]("\\b") -- ./lib/lua-parser/pp.lua:25
elseif char == 12 then -- ./lib/lua-parser/pp.lua:26
new_str = new_str .. string["format"]("\\f") -- ./lib/lua-parser/pp.lua:26
elseif char == 10 then -- ./lib/lua-parser/pp.lua:27
new_str = new_str .. string["format"]("\\n") -- ./lib/lua-parser/pp.lua:27
elseif char == 13 then -- ./lib/lua-parser/pp.lua:28
new_str = new_str .. string["format"]("\\r") -- ./lib/lua-parser/pp.lua:28
elseif char == 9 then -- ./lib/lua-parser/pp.lua:29
new_str = new_str .. string["format"]("\\t") -- ./lib/lua-parser/pp.lua:29
elseif char == 11 then -- ./lib/lua-parser/pp.lua:30
new_str = new_str .. string["format"]("\\v") -- ./lib/lua-parser/pp.lua:30
else -- ./lib/lua-parser/pp.lua:30
if isprint(char) then -- ./lib/lua-parser/pp.lua:32
new_str = new_str .. string["format"]("%c", char) -- ./lib/lua-parser/pp.lua:33
else -- ./lib/lua-parser/pp.lua:33
new_str = new_str .. string["format"]("\\%03d", char) -- ./lib/lua-parser/pp.lua:35
end -- ./lib/lua-parser/pp.lua:35
end -- ./lib/lua-parser/pp.lua:35
end -- ./lib/lua-parser/pp.lua:35
return new_str -- ./lib/lua-parser/pp.lua:39
end -- ./lib/lua-parser/pp.lua:39
local function name2str(name) -- ./lib/lua-parser/pp.lua:42
return string["format"]("\"%s\"", name) -- ./lib/lua-parser/pp.lua:43
end -- ./lib/lua-parser/pp.lua:43
local function boolean2str(b) -- ./lib/lua-parser/pp.lua:46
return string["format"]("\"%s\"", tostring(b)) -- ./lib/lua-parser/pp.lua:47
end -- ./lib/lua-parser/pp.lua:47
local function number2str(n) -- ./lib/lua-parser/pp.lua:50
return string["format"]("\"%s\"", tostring(n)) -- ./lib/lua-parser/pp.lua:51
end -- ./lib/lua-parser/pp.lua:51
local function string2str(s) -- ./lib/lua-parser/pp.lua:54
return string["format"]("\"%s\"", fixed_string(s)) -- ./lib/lua-parser/pp.lua:55
end -- ./lib/lua-parser/pp.lua:55
var2str = function(var) -- ./lib/lua-parser/pp.lua:58
local tag = var["tag"] -- ./lib/lua-parser/pp.lua:59
local str = "`" .. tag -- ./lib/lua-parser/pp.lua:60
if tag == "Id" then -- `Id{ <string> } -- ./lib/lua-parser/pp.lua:61
str = str .. " " .. name2str(var[1]) -- ./lib/lua-parser/pp.lua:62
elseif tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/pp.lua:63
str = str .. "{ " -- ./lib/lua-parser/pp.lua:64
str = str .. exp2str(var[1]) .. ", " -- ./lib/lua-parser/pp.lua:65
str = str .. exp2str(var[2]) -- ./lib/lua-parser/pp.lua:66
str = str .. " }" -- ./lib/lua-parser/pp.lua:67
else -- ./lib/lua-parser/pp.lua:67
error("expecting a variable, but got a " .. tag) -- ./lib/lua-parser/pp.lua:69
end -- ./lib/lua-parser/pp.lua:69
return str -- ./lib/lua-parser/pp.lua:71
end -- ./lib/lua-parser/pp.lua:71
varlist2str = function(varlist) -- ./lib/lua-parser/pp.lua:74
local l = {} -- ./lib/lua-parser/pp.lua:75
for k, v in ipairs(varlist) do -- ./lib/lua-parser/pp.lua:76
l[k] = var2str(v) -- ./lib/lua-parser/pp.lua:77
end -- ./lib/lua-parser/pp.lua:77
return "{ " .. table["concat"](l, ", ") .. " }" -- ./lib/lua-parser/pp.lua:79
end -- ./lib/lua-parser/pp.lua:79
parlist2str = function(parlist) -- ./lib/lua-parser/pp.lua:82
local l = {} -- ./lib/lua-parser/pp.lua:83
local len = # parlist -- ./lib/lua-parser/pp.lua:84
local is_vararg = false -- ./lib/lua-parser/pp.lua:85
if len > 0 and parlist[len]["tag"] == "Dots" then -- ./lib/lua-parser/pp.lua:86
is_vararg = true -- ./lib/lua-parser/pp.lua:87
len = len - 1 -- ./lib/lua-parser/pp.lua:88
end -- ./lib/lua-parser/pp.lua:88
local i = 1 -- ./lib/lua-parser/pp.lua:90
while i <= len do -- ./lib/lua-parser/pp.lua:91
l[i] = var2str(parlist[i]) -- ./lib/lua-parser/pp.lua:92
i = i + 1 -- ./lib/lua-parser/pp.lua:93
end -- ./lib/lua-parser/pp.lua:93
if is_vararg then -- ./lib/lua-parser/pp.lua:95
l[i] = "`" .. parlist[i]["tag"] -- ./lib/lua-parser/pp.lua:96
end -- ./lib/lua-parser/pp.lua:96
return "{ " .. table["concat"](l, ", ") .. " }" -- ./lib/lua-parser/pp.lua:98
end -- ./lib/lua-parser/pp.lua:98
fieldlist2str = function(fieldlist) -- ./lib/lua-parser/pp.lua:101
local l = {} -- ./lib/lua-parser/pp.lua:102
for k, v in ipairs(fieldlist) do -- ./lib/lua-parser/pp.lua:103
local tag = v["tag"] -- ./lib/lua-parser/pp.lua:104
if tag == "Pair" then -- `Pair{ expr expr } -- ./lib/lua-parser/pp.lua:105
l[k] = "`" .. tag .. "{ " -- ./lib/lua-parser/pp.lua:106
l[k] = l[k] .. exp2str(v[1]) .. ", " .. exp2str(v[2]) -- ./lib/lua-parser/pp.lua:107
l[k] = l[k] .. " }" -- ./lib/lua-parser/pp.lua:108
else -- ./lib/lua-parser/pp.lua:108
l[k] = exp2str(v) -- ./lib/lua-parser/pp.lua:110
end -- ./lib/lua-parser/pp.lua:110
end -- ./lib/lua-parser/pp.lua:110
if # l > 0 then -- ./lib/lua-parser/pp.lua:113
return "{ " .. table["concat"](l, ", ") .. " }" -- ./lib/lua-parser/pp.lua:114
else -- ./lib/lua-parser/pp.lua:114
return "" -- ./lib/lua-parser/pp.lua:116
end -- ./lib/lua-parser/pp.lua:116
end -- ./lib/lua-parser/pp.lua:116
exp2str = function(exp) -- ./lib/lua-parser/pp.lua:120
local tag = exp["tag"] -- ./lib/lua-parser/pp.lua:121
local str = "`" .. tag -- ./lib/lua-parser/pp.lua:122
if tag == "Nil" or tag == "Dots" then -- ./lib/lua-parser/pp.lua:124
 -- `Boolean{ <boolean> } -- ./lib/lua-parser/pp.lua:125
elseif tag == "Boolean" then -- `Boolean{ <boolean> } -- ./lib/lua-parser/pp.lua:125
str = str .. " " .. boolean2str(exp[1]) -- ./lib/lua-parser/pp.lua:126
elseif tag == "Number" then -- `Number{ <number> } -- ./lib/lua-parser/pp.lua:127
str = str .. " " .. number2str(exp[1]) -- ./lib/lua-parser/pp.lua:128
elseif tag == "String" then -- `String{ <string> } -- ./lib/lua-parser/pp.lua:129
str = str .. " " .. string2str(exp[1]) -- ./lib/lua-parser/pp.lua:130
elseif tag == "Function" then -- `Function{ { `Id{ <string> }* `Dots? } block } -- ./lib/lua-parser/pp.lua:131
str = str .. "{ " -- ./lib/lua-parser/pp.lua:132
str = str .. parlist2str(exp[1]) .. ", " -- ./lib/lua-parser/pp.lua:133
str = str .. block2str(exp[2]) -- ./lib/lua-parser/pp.lua:134
str = str .. " }" -- ./lib/lua-parser/pp.lua:135
elseif tag == "Table" then -- `Table{ ( `Pair{ expr expr } | expr )* } -- ./lib/lua-parser/pp.lua:136
str = str .. fieldlist2str(exp) -- ./lib/lua-parser/pp.lua:137
elseif tag == "Op" then -- `Op{ opid expr expr? } -- ./lib/lua-parser/pp.lua:138
str = str .. "{ " -- ./lib/lua-parser/pp.lua:139
str = str .. name2str(exp[1]) .. ", " -- ./lib/lua-parser/pp.lua:140
str = str .. exp2str(exp[2]) -- ./lib/lua-parser/pp.lua:141
if exp[3] then -- ./lib/lua-parser/pp.lua:142
str = str .. ", " .. exp2str(exp[3]) -- ./lib/lua-parser/pp.lua:143
end -- ./lib/lua-parser/pp.lua:143
str = str .. " }" -- ./lib/lua-parser/pp.lua:145
elseif tag == "Paren" then -- `Paren{ expr } -- ./lib/lua-parser/pp.lua:146
str = str .. "{ " .. exp2str(exp[1]) .. " }" -- ./lib/lua-parser/pp.lua:147
elseif tag == "Call" then -- `Call{ expr expr* } -- ./lib/lua-parser/pp.lua:148
str = str .. "{ " -- ./lib/lua-parser/pp.lua:149
str = str .. exp2str(exp[1]) -- ./lib/lua-parser/pp.lua:150
if exp[2] then -- ./lib/lua-parser/pp.lua:151
for i = 2, # exp do -- ./lib/lua-parser/pp.lua:152
str = str .. ", " .. exp2str(exp[i]) -- ./lib/lua-parser/pp.lua:153
end -- ./lib/lua-parser/pp.lua:153
end -- ./lib/lua-parser/pp.lua:153
str = str .. " }" -- ./lib/lua-parser/pp.lua:156
elseif tag == "Invoke" then -- `Invoke{ expr `String{ <string> } expr* } -- ./lib/lua-parser/pp.lua:157
str = str .. "{ " -- ./lib/lua-parser/pp.lua:158
str = str .. exp2str(exp[1]) .. ", " -- ./lib/lua-parser/pp.lua:159
str = str .. exp2str(exp[2]) -- ./lib/lua-parser/pp.lua:160
if exp[3] then -- ./lib/lua-parser/pp.lua:161
for i = 3, # exp do -- ./lib/lua-parser/pp.lua:162
str = str .. ", " .. exp2str(exp[i]) -- ./lib/lua-parser/pp.lua:163
end -- ./lib/lua-parser/pp.lua:163
end -- ./lib/lua-parser/pp.lua:163
str = str .. " }" -- ./lib/lua-parser/pp.lua:166
elseif tag == "Id" or tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/pp.lua:168
str = var2str(exp) -- ./lib/lua-parser/pp.lua:169
else -- ./lib/lua-parser/pp.lua:169
error("expecting an expression, but got a " .. tag) -- ./lib/lua-parser/pp.lua:171
end -- ./lib/lua-parser/pp.lua:171
return str -- ./lib/lua-parser/pp.lua:173
end -- ./lib/lua-parser/pp.lua:173
explist2str = function(explist) -- ./lib/lua-parser/pp.lua:176
local l = {} -- ./lib/lua-parser/pp.lua:177
for k, v in ipairs(explist) do -- ./lib/lua-parser/pp.lua:178
l[k] = exp2str(v) -- ./lib/lua-parser/pp.lua:179
end -- ./lib/lua-parser/pp.lua:179
if # l > 0 then -- ./lib/lua-parser/pp.lua:181
return "{ " .. table["concat"](l, ", ") .. " }" -- ./lib/lua-parser/pp.lua:182
else -- ./lib/lua-parser/pp.lua:182
return "" -- ./lib/lua-parser/pp.lua:184
end -- ./lib/lua-parser/pp.lua:184
end -- ./lib/lua-parser/pp.lua:184
stm2str = function(stm) -- ./lib/lua-parser/pp.lua:188
local tag = stm["tag"] -- ./lib/lua-parser/pp.lua:189
local str = "`" .. tag -- ./lib/lua-parser/pp.lua:190
if tag == "Do" then -- `Do{ stat* } -- ./lib/lua-parser/pp.lua:191
local l = {} -- ./lib/lua-parser/pp.lua:192
for k, v in ipairs(stm) do -- ./lib/lua-parser/pp.lua:193
l[k] = stm2str(v) -- ./lib/lua-parser/pp.lua:194
end -- ./lib/lua-parser/pp.lua:194
str = str .. "{ " .. table["concat"](l, ", ") .. " }" -- ./lib/lua-parser/pp.lua:196
elseif tag == "Set" then -- `Set{ {lhs+} {expr+} } -- ./lib/lua-parser/pp.lua:197
str = str .. "{ " -- ./lib/lua-parser/pp.lua:198
str = str .. varlist2str(stm[1]) .. ", " -- ./lib/lua-parser/pp.lua:199
str = str .. explist2str(stm[2]) -- ./lib/lua-parser/pp.lua:200
str = str .. " }" -- ./lib/lua-parser/pp.lua:201
elseif tag == "While" then -- `While{ expr block } -- ./lib/lua-parser/pp.lua:202
str = str .. "{ " -- ./lib/lua-parser/pp.lua:203
str = str .. exp2str(stm[1]) .. ", " -- ./lib/lua-parser/pp.lua:204
str = str .. block2str(stm[2]) -- ./lib/lua-parser/pp.lua:205
str = str .. " }" -- ./lib/lua-parser/pp.lua:206
elseif tag == "Repeat" then -- `Repeat{ block expr } -- ./lib/lua-parser/pp.lua:207
str = str .. "{ " -- ./lib/lua-parser/pp.lua:208
str = str .. block2str(stm[1]) .. ", " -- ./lib/lua-parser/pp.lua:209
str = str .. exp2str(stm[2]) -- ./lib/lua-parser/pp.lua:210
str = str .. " }" -- ./lib/lua-parser/pp.lua:211
elseif tag == "If" then -- `If{ (expr block)+ block? } -- ./lib/lua-parser/pp.lua:212
str = str .. "{ " -- ./lib/lua-parser/pp.lua:213
local len = # stm -- ./lib/lua-parser/pp.lua:214
if len % 2 == 0 then -- ./lib/lua-parser/pp.lua:215
local l = {} -- ./lib/lua-parser/pp.lua:216
for i = 1, len - 2, 2 do -- ./lib/lua-parser/pp.lua:217
str = str .. exp2str(stm[i]) .. ", " .. block2str(stm[i + 1]) .. ", " -- ./lib/lua-parser/pp.lua:218
end -- ./lib/lua-parser/pp.lua:218
str = str .. exp2str(stm[len - 1]) .. ", " .. block2str(stm[len]) -- ./lib/lua-parser/pp.lua:220
else -- ./lib/lua-parser/pp.lua:220
local l = {} -- ./lib/lua-parser/pp.lua:222
for i = 1, len - 3, 2 do -- ./lib/lua-parser/pp.lua:223
str = str .. exp2str(stm[i]) .. ", " .. block2str(stm[i + 1]) .. ", " -- ./lib/lua-parser/pp.lua:224
end -- ./lib/lua-parser/pp.lua:224
str = str .. exp2str(stm[len - 2]) .. ", " .. block2str(stm[len - 1]) .. ", " -- ./lib/lua-parser/pp.lua:226
str = str .. block2str(stm[len]) -- ./lib/lua-parser/pp.lua:227
end -- ./lib/lua-parser/pp.lua:227
str = str .. " }" -- ./lib/lua-parser/pp.lua:229
elseif tag == "Fornum" then -- `Fornum{ ident expr expr expr? block } -- ./lib/lua-parser/pp.lua:230
str = str .. "{ " -- ./lib/lua-parser/pp.lua:231
str = str .. var2str(stm[1]) .. ", " -- ./lib/lua-parser/pp.lua:232
str = str .. exp2str(stm[2]) .. ", " -- ./lib/lua-parser/pp.lua:233
str = str .. exp2str(stm[3]) .. ", " -- ./lib/lua-parser/pp.lua:234
if stm[5] then -- ./lib/lua-parser/pp.lua:235
str = str .. exp2str(stm[4]) .. ", " -- ./lib/lua-parser/pp.lua:236
str = str .. block2str(stm[5]) -- ./lib/lua-parser/pp.lua:237
else -- ./lib/lua-parser/pp.lua:237
str = str .. block2str(stm[4]) -- ./lib/lua-parser/pp.lua:239
end -- ./lib/lua-parser/pp.lua:239
str = str .. " }" -- ./lib/lua-parser/pp.lua:241
elseif tag == "Forin" then -- `Forin{ {ident+} {expr+} block } -- ./lib/lua-parser/pp.lua:242
str = str .. "{ " -- ./lib/lua-parser/pp.lua:243
str = str .. varlist2str(stm[1]) .. ", " -- ./lib/lua-parser/pp.lua:244
str = str .. explist2str(stm[2]) .. ", " -- ./lib/lua-parser/pp.lua:245
str = str .. block2str(stm[3]) -- ./lib/lua-parser/pp.lua:246
str = str .. " }" -- ./lib/lua-parser/pp.lua:247
elseif tag == "Local" then -- `Local{ {ident+} {expr+}? } -- ./lib/lua-parser/pp.lua:248
str = str .. "{ " -- ./lib/lua-parser/pp.lua:249
str = str .. varlist2str(stm[1]) -- ./lib/lua-parser/pp.lua:250
if # stm[2] > 0 then -- ./lib/lua-parser/pp.lua:251
str = str .. ", " .. explist2str(stm[2]) -- ./lib/lua-parser/pp.lua:252
else -- ./lib/lua-parser/pp.lua:252
str = str .. ", " .. "{  }" -- ./lib/lua-parser/pp.lua:254
end -- ./lib/lua-parser/pp.lua:254
str = str .. " }" -- ./lib/lua-parser/pp.lua:256
elseif tag == "Localrec" then -- `Localrec{ ident expr } -- ./lib/lua-parser/pp.lua:257
str = str .. "{ " -- ./lib/lua-parser/pp.lua:258
str = str .. "{ " .. var2str(stm[1][1]) .. " }, " -- ./lib/lua-parser/pp.lua:259
str = str .. "{ " .. exp2str(stm[2][1]) .. " }" -- ./lib/lua-parser/pp.lua:260
str = str .. " }" -- ./lib/lua-parser/pp.lua:261
elseif tag == "Goto" or tag == "Label" then -- `Label{ <string> } -- ./lib/lua-parser/pp.lua:263
str = str .. "{ " .. name2str(stm[1]) .. " }" -- ./lib/lua-parser/pp.lua:264
elseif tag == "Return" then -- `Return{ <expr>* } -- ./lib/lua-parser/pp.lua:265
str = str .. explist2str(stm) -- ./lib/lua-parser/pp.lua:266
elseif tag == "Break" then -- ./lib/lua-parser/pp.lua:267
 -- `Call{ expr expr* } -- ./lib/lua-parser/pp.lua:268
elseif tag == "Call" then -- `Call{ expr expr* } -- ./lib/lua-parser/pp.lua:268
str = str .. "{ " -- ./lib/lua-parser/pp.lua:269
str = str .. exp2str(stm[1]) -- ./lib/lua-parser/pp.lua:270
if stm[2] then -- ./lib/lua-parser/pp.lua:271
for i = 2, # stm do -- ./lib/lua-parser/pp.lua:272
str = str .. ", " .. exp2str(stm[i]) -- ./lib/lua-parser/pp.lua:273
end -- ./lib/lua-parser/pp.lua:273
end -- ./lib/lua-parser/pp.lua:273
str = str .. " }" -- ./lib/lua-parser/pp.lua:276
elseif tag == "Invoke" then -- `Invoke{ expr `String{ <string> } expr* } -- ./lib/lua-parser/pp.lua:277
str = str .. "{ " -- ./lib/lua-parser/pp.lua:278
str = str .. exp2str(stm[1]) .. ", " -- ./lib/lua-parser/pp.lua:279
str = str .. exp2str(stm[2]) -- ./lib/lua-parser/pp.lua:280
if stm[3] then -- ./lib/lua-parser/pp.lua:281
for i = 3, # stm do -- ./lib/lua-parser/pp.lua:282
str = str .. ", " .. exp2str(stm[i]) -- ./lib/lua-parser/pp.lua:283
end -- ./lib/lua-parser/pp.lua:283
end -- ./lib/lua-parser/pp.lua:283
str = str .. " }" -- ./lib/lua-parser/pp.lua:286
else -- ./lib/lua-parser/pp.lua:286
error("expecting a statement, but got a " .. tag) -- ./lib/lua-parser/pp.lua:288
end -- ./lib/lua-parser/pp.lua:288
return str -- ./lib/lua-parser/pp.lua:290
end -- ./lib/lua-parser/pp.lua:290
block2str = function(block) -- ./lib/lua-parser/pp.lua:293
local l = {} -- ./lib/lua-parser/pp.lua:294
for k, v in ipairs(block) do -- ./lib/lua-parser/pp.lua:295
l[k] = stm2str(v) -- ./lib/lua-parser/pp.lua:296
end -- ./lib/lua-parser/pp.lua:296
return "{ " .. table["concat"](l, ", ") .. " }" -- ./lib/lua-parser/pp.lua:298
end -- ./lib/lua-parser/pp.lua:298
pp["tostring"] = function(t) -- ./lib/lua-parser/pp.lua:301
assert(type(t) == "table") -- ./lib/lua-parser/pp.lua:302
return block2str(t) -- ./lib/lua-parser/pp.lua:303
end -- ./lib/lua-parser/pp.lua:303
pp["print"] = function(t) -- ./lib/lua-parser/pp.lua:306
assert(type(t) == "table") -- ./lib/lua-parser/pp.lua:307
print(pp["tostring"](t)) -- ./lib/lua-parser/pp.lua:308
end -- ./lib/lua-parser/pp.lua:308
pp["dump"] = function(t, i) -- ./lib/lua-parser/pp.lua:311
if i == nil then -- ./lib/lua-parser/pp.lua:312
i = 0 -- ./lib/lua-parser/pp.lua:312
end -- ./lib/lua-parser/pp.lua:312
io["write"](string["format"]("{\
")) -- ./lib/lua-parser/pp.lua:313
io["write"](string["format"]("%s[tag] = %s\
", string["rep"](" ", i + 2), t["tag"] or "nil")) -- ./lib/lua-parser/pp.lua:314
io["write"](string["format"]("%s[pos] = %s\
", string["rep"](" ", i + 2), t["pos"] or "nil")) -- ./lib/lua-parser/pp.lua:315
for k, v in ipairs(t) do -- ./lib/lua-parser/pp.lua:316
io["write"](string["format"]("%s[%s] = ", string["rep"](" ", i + 2), tostring(k))) -- ./lib/lua-parser/pp.lua:317
if type(v) == "table" then -- ./lib/lua-parser/pp.lua:318
pp["dump"](v, i + 2) -- ./lib/lua-parser/pp.lua:319
else -- ./lib/lua-parser/pp.lua:319
io["write"](string["format"]("%s\
", tostring(v))) -- ./lib/lua-parser/pp.lua:321
end -- ./lib/lua-parser/pp.lua:321
end -- ./lib/lua-parser/pp.lua:321
io["write"](string["format"]("%s}\
", string["rep"](" ", i))) -- ./lib/lua-parser/pp.lua:324
end -- ./lib/lua-parser/pp.lua:324
return pp -- ./lib/lua-parser/pp.lua:327
end -- ./lib/lua-parser/pp.lua:327
local pp = _() or pp -- ./lib/lua-parser/pp.lua:331
package["loaded"]["lib.lua-parser.pp"] = pp or true -- ./lib/lua-parser/pp.lua:332
local function _() -- ./lib/lua-parser/pp.lua:335
local lpeg = require("lpeglabel") -- ./lib/lua-parser/parser.lua:72
lpeg["locale"](lpeg) -- ./lib/lua-parser/parser.lua:74
local P, S, V = lpeg["P"], lpeg["S"], lpeg["V"] -- ./lib/lua-parser/parser.lua:76
local C, Carg, Cb, Cc = lpeg["C"], lpeg["Carg"], lpeg["Cb"], lpeg["Cc"] -- ./lib/lua-parser/parser.lua:77
local Cf, Cg, Cmt, Cp, Cs, Ct = lpeg["Cf"], lpeg["Cg"], lpeg["Cmt"], lpeg["Cp"], lpeg["Cs"], lpeg["Ct"] -- ./lib/lua-parser/parser.lua:78
local Rec, T = lpeg["Rec"], lpeg["T"] -- ./lib/lua-parser/parser.lua:79
local alpha, digit, alnum = lpeg["alpha"], lpeg["digit"], lpeg["alnum"] -- ./lib/lua-parser/parser.lua:81
local xdigit = lpeg["xdigit"] -- ./lib/lua-parser/parser.lua:82
local space = lpeg["space"] -- ./lib/lua-parser/parser.lua:83
local labels = { -- ./lib/lua-parser/parser.lua:88
{ -- ./lib/lua-parser/parser.lua:89
"ErrExtra", -- ./lib/lua-parser/parser.lua:89
"unexpected character(s), expected EOF" -- ./lib/lua-parser/parser.lua:89
}, -- ./lib/lua-parser/parser.lua:89
{ -- ./lib/lua-parser/parser.lua:90
"ErrInvalidStat", -- ./lib/lua-parser/parser.lua:90
"unexpected token, invalid start of statement" -- ./lib/lua-parser/parser.lua:90
}, -- ./lib/lua-parser/parser.lua:90
{ -- ./lib/lua-parser/parser.lua:92
"ErrEndIf", -- ./lib/lua-parser/parser.lua:92
"expected 'end' to close the if statement" -- ./lib/lua-parser/parser.lua:92
}, -- ./lib/lua-parser/parser.lua:92
{ -- ./lib/lua-parser/parser.lua:93
"ErrExprIf", -- ./lib/lua-parser/parser.lua:93
"expected a condition after 'if'" -- ./lib/lua-parser/parser.lua:93
}, -- ./lib/lua-parser/parser.lua:93
{ -- ./lib/lua-parser/parser.lua:94
"ErrThenIf", -- ./lib/lua-parser/parser.lua:94
"expected 'then' after the condition" -- ./lib/lua-parser/parser.lua:94
}, -- ./lib/lua-parser/parser.lua:94
{ -- ./lib/lua-parser/parser.lua:95
"ErrExprEIf", -- ./lib/lua-parser/parser.lua:95
"expected a condition after 'elseif'" -- ./lib/lua-parser/parser.lua:95
}, -- ./lib/lua-parser/parser.lua:95
{ -- ./lib/lua-parser/parser.lua:96
"ErrThenEIf", -- ./lib/lua-parser/parser.lua:96
"expected 'then' after the condition" -- ./lib/lua-parser/parser.lua:96
}, -- ./lib/lua-parser/parser.lua:96
{ -- ./lib/lua-parser/parser.lua:98
"ErrEndDo", -- ./lib/lua-parser/parser.lua:98
"expected 'end' to close the do block" -- ./lib/lua-parser/parser.lua:98
}, -- ./lib/lua-parser/parser.lua:98
{ -- ./lib/lua-parser/parser.lua:99
"ErrExprWhile", -- ./lib/lua-parser/parser.lua:99
"expected a condition after 'while'" -- ./lib/lua-parser/parser.lua:99
}, -- ./lib/lua-parser/parser.lua:99
{ -- ./lib/lua-parser/parser.lua:100
"ErrDoWhile", -- ./lib/lua-parser/parser.lua:100
"expected 'do' after the condition" -- ./lib/lua-parser/parser.lua:100
}, -- ./lib/lua-parser/parser.lua:100
{ -- ./lib/lua-parser/parser.lua:101
"ErrEndWhile", -- ./lib/lua-parser/parser.lua:101
"expected 'end' to close the while loop" -- ./lib/lua-parser/parser.lua:101
}, -- ./lib/lua-parser/parser.lua:101
{ -- ./lib/lua-parser/parser.lua:102
"ErrUntilRep", -- ./lib/lua-parser/parser.lua:102
"expected 'until' at the end of the repeat loop" -- ./lib/lua-parser/parser.lua:102
}, -- ./lib/lua-parser/parser.lua:102
{ -- ./lib/lua-parser/parser.lua:103
"ErrExprRep", -- ./lib/lua-parser/parser.lua:103
"expected a conditions after 'until'" -- ./lib/lua-parser/parser.lua:103
}, -- ./lib/lua-parser/parser.lua:103
{ -- ./lib/lua-parser/parser.lua:105
"ErrForRange", -- ./lib/lua-parser/parser.lua:105
"expected a numeric or generic range after 'for'" -- ./lib/lua-parser/parser.lua:105
}, -- ./lib/lua-parser/parser.lua:105
{ -- ./lib/lua-parser/parser.lua:106
"ErrEndFor", -- ./lib/lua-parser/parser.lua:106
"expected 'end' to close the for loop" -- ./lib/lua-parser/parser.lua:106
}, -- ./lib/lua-parser/parser.lua:106
{ -- ./lib/lua-parser/parser.lua:107
"ErrExprFor1", -- ./lib/lua-parser/parser.lua:107
"expected a starting expression for the numeric range" -- ./lib/lua-parser/parser.lua:107
}, -- ./lib/lua-parser/parser.lua:107
{ -- ./lib/lua-parser/parser.lua:108
"ErrCommaFor", -- ./lib/lua-parser/parser.lua:108
"expected ',' to split the start and end of the range" -- ./lib/lua-parser/parser.lua:108
}, -- ./lib/lua-parser/parser.lua:108
{ -- ./lib/lua-parser/parser.lua:109
"ErrExprFor2", -- ./lib/lua-parser/parser.lua:109
"expected an ending expression for the numeric range" -- ./lib/lua-parser/parser.lua:109
}, -- ./lib/lua-parser/parser.lua:109
{ -- ./lib/lua-parser/parser.lua:110
"ErrExprFor3", -- ./lib/lua-parser/parser.lua:110
"expected a step expression for the numeric range after ','" -- ./lib/lua-parser/parser.lua:110
}, -- ./lib/lua-parser/parser.lua:110
{ -- ./lib/lua-parser/parser.lua:111
"ErrInFor", -- ./lib/lua-parser/parser.lua:111
"expected '=' or 'in' after the variable(s)" -- ./lib/lua-parser/parser.lua:111
}, -- ./lib/lua-parser/parser.lua:111
{ -- ./lib/lua-parser/parser.lua:112
"ErrEListFor", -- ./lib/lua-parser/parser.lua:112
"expected one or more expressions after 'in'" -- ./lib/lua-parser/parser.lua:112
}, -- ./lib/lua-parser/parser.lua:112
{ -- ./lib/lua-parser/parser.lua:113
"ErrDoFor", -- ./lib/lua-parser/parser.lua:113
"expected 'do' after the range of the for loop" -- ./lib/lua-parser/parser.lua:113
}, -- ./lib/lua-parser/parser.lua:113
{ -- ./lib/lua-parser/parser.lua:115
"ErrDefLocal", -- ./lib/lua-parser/parser.lua:115
"expected a function definition or assignment after local" -- ./lib/lua-parser/parser.lua:115
}, -- ./lib/lua-parser/parser.lua:115
{ -- ./lib/lua-parser/parser.lua:116
"ErrDefLet", -- ./lib/lua-parser/parser.lua:116
"expected a function definition or assignment after let" -- ./lib/lua-parser/parser.lua:116
}, -- ./lib/lua-parser/parser.lua:116
{ -- ./lib/lua-parser/parser.lua:117
"ErrNameLFunc", -- ./lib/lua-parser/parser.lua:117
"expected a function name after 'function'" -- ./lib/lua-parser/parser.lua:117
}, -- ./lib/lua-parser/parser.lua:117
{ -- ./lib/lua-parser/parser.lua:118
"ErrEListLAssign", -- ./lib/lua-parser/parser.lua:118
"expected one or more expressions after '='" -- ./lib/lua-parser/parser.lua:118
}, -- ./lib/lua-parser/parser.lua:118
{ -- ./lib/lua-parser/parser.lua:119
"ErrEListAssign", -- ./lib/lua-parser/parser.lua:119
"expected one or more expressions after '='" -- ./lib/lua-parser/parser.lua:119
}, -- ./lib/lua-parser/parser.lua:119
{ -- ./lib/lua-parser/parser.lua:121
"ErrFuncName", -- ./lib/lua-parser/parser.lua:121
"expected a function name after 'function'" -- ./lib/lua-parser/parser.lua:121
}, -- ./lib/lua-parser/parser.lua:121
{ -- ./lib/lua-parser/parser.lua:122
"ErrNameFunc1", -- ./lib/lua-parser/parser.lua:122
"expected a function name after '.'" -- ./lib/lua-parser/parser.lua:122
}, -- ./lib/lua-parser/parser.lua:122
{ -- ./lib/lua-parser/parser.lua:123
"ErrNameFunc2", -- ./lib/lua-parser/parser.lua:123
"expected a method name after ':'" -- ./lib/lua-parser/parser.lua:123
}, -- ./lib/lua-parser/parser.lua:123
{ -- ./lib/lua-parser/parser.lua:124
"ErrOParenPList", -- ./lib/lua-parser/parser.lua:124
"expected '(' for the parameter list" -- ./lib/lua-parser/parser.lua:124
}, -- ./lib/lua-parser/parser.lua:124
{ -- ./lib/lua-parser/parser.lua:125
"ErrCParenPList", -- ./lib/lua-parser/parser.lua:125
"expected ')' to close the parameter list" -- ./lib/lua-parser/parser.lua:125
}, -- ./lib/lua-parser/parser.lua:125
{ -- ./lib/lua-parser/parser.lua:126
"ErrEndFunc", -- ./lib/lua-parser/parser.lua:126
"expected 'end' to close the function body" -- ./lib/lua-parser/parser.lua:126
}, -- ./lib/lua-parser/parser.lua:126
{ -- ./lib/lua-parser/parser.lua:127
"ErrParList", -- ./lib/lua-parser/parser.lua:127
"expected a variable name or '...' after ','" -- ./lib/lua-parser/parser.lua:127
}, -- ./lib/lua-parser/parser.lua:127
{ -- ./lib/lua-parser/parser.lua:129
"ErrLabel", -- ./lib/lua-parser/parser.lua:129
"expected a label name after '::'" -- ./lib/lua-parser/parser.lua:129
}, -- ./lib/lua-parser/parser.lua:129
{ -- ./lib/lua-parser/parser.lua:130
"ErrCloseLabel", -- ./lib/lua-parser/parser.lua:130
"expected '::' after the label" -- ./lib/lua-parser/parser.lua:130
}, -- ./lib/lua-parser/parser.lua:130
{ -- ./lib/lua-parser/parser.lua:131
"ErrGoto", -- ./lib/lua-parser/parser.lua:131
"expected a label after 'goto'" -- ./lib/lua-parser/parser.lua:131
}, -- ./lib/lua-parser/parser.lua:131
{ -- ./lib/lua-parser/parser.lua:132
"ErrRetList", -- ./lib/lua-parser/parser.lua:132
"expected an expression after ',' in the return statement" -- ./lib/lua-parser/parser.lua:132
}, -- ./lib/lua-parser/parser.lua:132
{ -- ./lib/lua-parser/parser.lua:134
"ErrVarList", -- ./lib/lua-parser/parser.lua:134
"expected a variable name after ','" -- ./lib/lua-parser/parser.lua:134
}, -- ./lib/lua-parser/parser.lua:134
{ -- ./lib/lua-parser/parser.lua:135
"ErrExprList", -- ./lib/lua-parser/parser.lua:135
"expected an expression after ','" -- ./lib/lua-parser/parser.lua:135
}, -- ./lib/lua-parser/parser.lua:135
{ -- ./lib/lua-parser/parser.lua:137
"ErrOrExpr", -- ./lib/lua-parser/parser.lua:137
"expected an expression after 'or'" -- ./lib/lua-parser/parser.lua:137
}, -- ./lib/lua-parser/parser.lua:137
{ -- ./lib/lua-parser/parser.lua:138
"ErrAndExpr", -- ./lib/lua-parser/parser.lua:138
"expected an expression after 'and'" -- ./lib/lua-parser/parser.lua:138
}, -- ./lib/lua-parser/parser.lua:138
{ -- ./lib/lua-parser/parser.lua:139
"ErrRelExpr", -- ./lib/lua-parser/parser.lua:139
"expected an expression after the relational operator" -- ./lib/lua-parser/parser.lua:139
}, -- ./lib/lua-parser/parser.lua:139
{ -- ./lib/lua-parser/parser.lua:140
"ErrBOrExpr", -- ./lib/lua-parser/parser.lua:140
"expected an expression after '|'" -- ./lib/lua-parser/parser.lua:140
}, -- ./lib/lua-parser/parser.lua:140
{ -- ./lib/lua-parser/parser.lua:141
"ErrBXorExpr", -- ./lib/lua-parser/parser.lua:141
"expected an expression after '~'" -- ./lib/lua-parser/parser.lua:141
}, -- ./lib/lua-parser/parser.lua:141
{ -- ./lib/lua-parser/parser.lua:142
"ErrBAndExpr", -- ./lib/lua-parser/parser.lua:142
"expected an expression after '&'" -- ./lib/lua-parser/parser.lua:142
}, -- ./lib/lua-parser/parser.lua:142
{ -- ./lib/lua-parser/parser.lua:143
"ErrShiftExpr", -- ./lib/lua-parser/parser.lua:143
"expected an expression after the bit shift" -- ./lib/lua-parser/parser.lua:143
}, -- ./lib/lua-parser/parser.lua:143
{ -- ./lib/lua-parser/parser.lua:144
"ErrConcatExpr", -- ./lib/lua-parser/parser.lua:144
"expected an expression after '..'" -- ./lib/lua-parser/parser.lua:144
}, -- ./lib/lua-parser/parser.lua:144
{ -- ./lib/lua-parser/parser.lua:145
"ErrAddExpr", -- ./lib/lua-parser/parser.lua:145
"expected an expression after the additive operator" -- ./lib/lua-parser/parser.lua:145
}, -- ./lib/lua-parser/parser.lua:145
{ -- ./lib/lua-parser/parser.lua:146
"ErrMulExpr", -- ./lib/lua-parser/parser.lua:146
"expected an expression after the multiplicative operator" -- ./lib/lua-parser/parser.lua:146
}, -- ./lib/lua-parser/parser.lua:146
{ -- ./lib/lua-parser/parser.lua:147
"ErrUnaryExpr", -- ./lib/lua-parser/parser.lua:147
"expected an expression after the unary operator" -- ./lib/lua-parser/parser.lua:147
}, -- ./lib/lua-parser/parser.lua:147
{ -- ./lib/lua-parser/parser.lua:148
"ErrPowExpr", -- ./lib/lua-parser/parser.lua:148
"expected an expression after '^'" -- ./lib/lua-parser/parser.lua:148
}, -- ./lib/lua-parser/parser.lua:148
{ -- ./lib/lua-parser/parser.lua:150
"ErrExprParen", -- ./lib/lua-parser/parser.lua:150
"expected an expression after '('" -- ./lib/lua-parser/parser.lua:150
}, -- ./lib/lua-parser/parser.lua:150
{ -- ./lib/lua-parser/parser.lua:151
"ErrCParenExpr", -- ./lib/lua-parser/parser.lua:151
"expected ')' to close the expression" -- ./lib/lua-parser/parser.lua:151
}, -- ./lib/lua-parser/parser.lua:151
{ -- ./lib/lua-parser/parser.lua:152
"ErrNameIndex", -- ./lib/lua-parser/parser.lua:152
"expected a field name after '.'" -- ./lib/lua-parser/parser.lua:152
}, -- ./lib/lua-parser/parser.lua:152
{ -- ./lib/lua-parser/parser.lua:153
"ErrExprIndex", -- ./lib/lua-parser/parser.lua:153
"expected an expression after '['" -- ./lib/lua-parser/parser.lua:153
}, -- ./lib/lua-parser/parser.lua:153
{ -- ./lib/lua-parser/parser.lua:154
"ErrCBracketIndex", -- ./lib/lua-parser/parser.lua:154
"expected ']' to close the indexing expression" -- ./lib/lua-parser/parser.lua:154
}, -- ./lib/lua-parser/parser.lua:154
{ -- ./lib/lua-parser/parser.lua:155
"ErrNameMeth", -- ./lib/lua-parser/parser.lua:155
"expected a method name after ':'" -- ./lib/lua-parser/parser.lua:155
}, -- ./lib/lua-parser/parser.lua:155
{ -- ./lib/lua-parser/parser.lua:156
"ErrMethArgs", -- ./lib/lua-parser/parser.lua:156
"expected some arguments for the method call (or '()')" -- ./lib/lua-parser/parser.lua:156
}, -- ./lib/lua-parser/parser.lua:156
{ -- ./lib/lua-parser/parser.lua:158
"ErrArgList", -- ./lib/lua-parser/parser.lua:158
"expected an expression after ',' in the argument list" -- ./lib/lua-parser/parser.lua:158
}, -- ./lib/lua-parser/parser.lua:158
{ -- ./lib/lua-parser/parser.lua:159
"ErrCParenArgs", -- ./lib/lua-parser/parser.lua:159
"expected ')' to close the argument list" -- ./lib/lua-parser/parser.lua:159
}, -- ./lib/lua-parser/parser.lua:159
{ -- ./lib/lua-parser/parser.lua:161
"ErrCBraceTable", -- ./lib/lua-parser/parser.lua:161
"expected '}' to close the table constructor" -- ./lib/lua-parser/parser.lua:161
}, -- ./lib/lua-parser/parser.lua:161
{ -- ./lib/lua-parser/parser.lua:162
"ErrEqField", -- ./lib/lua-parser/parser.lua:162
"expected '=' after the table key" -- ./lib/lua-parser/parser.lua:162
}, -- ./lib/lua-parser/parser.lua:162
{ -- ./lib/lua-parser/parser.lua:163
"ErrExprField", -- ./lib/lua-parser/parser.lua:163
"expected an expression after '='" -- ./lib/lua-parser/parser.lua:163
}, -- ./lib/lua-parser/parser.lua:163
{ -- ./lib/lua-parser/parser.lua:164
"ErrExprFKey", -- ./lib/lua-parser/parser.lua:164
"expected an expression after '[' for the table key" -- ./lib/lua-parser/parser.lua:164
}, -- ./lib/lua-parser/parser.lua:164
{ -- ./lib/lua-parser/parser.lua:165
"ErrCBracketFKey", -- ./lib/lua-parser/parser.lua:165
"expected ']' to close the table key" -- ./lib/lua-parser/parser.lua:165
}, -- ./lib/lua-parser/parser.lua:165
{ -- ./lib/lua-parser/parser.lua:167
"ErrCBraceDestructuring", -- ./lib/lua-parser/parser.lua:167
"expected '}' to close the destructuring variable list" -- ./lib/lua-parser/parser.lua:167
}, -- ./lib/lua-parser/parser.lua:167
{ -- ./lib/lua-parser/parser.lua:168
"ErrDestructuringEqField", -- ./lib/lua-parser/parser.lua:168
"expected '=' after the table key in destructuring variable list" -- ./lib/lua-parser/parser.lua:168
}, -- ./lib/lua-parser/parser.lua:168
{ -- ./lib/lua-parser/parser.lua:169
"ErrDestructuringExprField", -- ./lib/lua-parser/parser.lua:169
"expected an identifier after '=' in destructuring variable list" -- ./lib/lua-parser/parser.lua:169
}, -- ./lib/lua-parser/parser.lua:169
{ -- ./lib/lua-parser/parser.lua:171
"ErrCBracketTableCompr", -- ./lib/lua-parser/parser.lua:171
"expected ']' to close the table comprehension" -- ./lib/lua-parser/parser.lua:171
}, -- ./lib/lua-parser/parser.lua:171
{ -- ./lib/lua-parser/parser.lua:173
"ErrDigitHex", -- ./lib/lua-parser/parser.lua:173
"expected one or more hexadecimal digits after '0x'" -- ./lib/lua-parser/parser.lua:173
}, -- ./lib/lua-parser/parser.lua:173
{ -- ./lib/lua-parser/parser.lua:174
"ErrDigitDeci", -- ./lib/lua-parser/parser.lua:174
"expected one or more digits after the decimal point" -- ./lib/lua-parser/parser.lua:174
}, -- ./lib/lua-parser/parser.lua:174
{ -- ./lib/lua-parser/parser.lua:175
"ErrDigitExpo", -- ./lib/lua-parser/parser.lua:175
"expected one or more digits for the exponent" -- ./lib/lua-parser/parser.lua:175
}, -- ./lib/lua-parser/parser.lua:175
{ -- ./lib/lua-parser/parser.lua:177
"ErrQuote", -- ./lib/lua-parser/parser.lua:177
"unclosed string" -- ./lib/lua-parser/parser.lua:177
}, -- ./lib/lua-parser/parser.lua:177
{ -- ./lib/lua-parser/parser.lua:178
"ErrHexEsc", -- ./lib/lua-parser/parser.lua:178
"expected exactly two hexadecimal digits after '\\x'" -- ./lib/lua-parser/parser.lua:178
}, -- ./lib/lua-parser/parser.lua:178
{ -- ./lib/lua-parser/parser.lua:179
"ErrOBraceUEsc", -- ./lib/lua-parser/parser.lua:179
"expected '{' after '\\u'" -- ./lib/lua-parser/parser.lua:179
}, -- ./lib/lua-parser/parser.lua:179
{ -- ./lib/lua-parser/parser.lua:180
"ErrDigitUEsc", -- ./lib/lua-parser/parser.lua:180
"expected one or more hexadecimal digits for the UTF-8 code point" -- ./lib/lua-parser/parser.lua:180
}, -- ./lib/lua-parser/parser.lua:180
{ -- ./lib/lua-parser/parser.lua:181
"ErrCBraceUEsc", -- ./lib/lua-parser/parser.lua:181
"expected '}' after the code point" -- ./lib/lua-parser/parser.lua:181
}, -- ./lib/lua-parser/parser.lua:181
{ -- ./lib/lua-parser/parser.lua:182
"ErrEscSeq", -- ./lib/lua-parser/parser.lua:182
"invalid escape sequence" -- ./lib/lua-parser/parser.lua:182
}, -- ./lib/lua-parser/parser.lua:182
{ -- ./lib/lua-parser/parser.lua:183
"ErrCloseLStr", -- ./lib/lua-parser/parser.lua:183
"unclosed long string" -- ./lib/lua-parser/parser.lua:183
} -- ./lib/lua-parser/parser.lua:183
} -- ./lib/lua-parser/parser.lua:183
local function throw(label) -- ./lib/lua-parser/parser.lua:186
label = "Err" .. label -- ./lib/lua-parser/parser.lua:187
for i, labelinfo in ipairs(labels) do -- ./lib/lua-parser/parser.lua:188
if labelinfo[1] == label then -- ./lib/lua-parser/parser.lua:189
return T(i) -- ./lib/lua-parser/parser.lua:190
end -- ./lib/lua-parser/parser.lua:190
end -- ./lib/lua-parser/parser.lua:190
error("Label not found: " .. label) -- ./lib/lua-parser/parser.lua:194
end -- ./lib/lua-parser/parser.lua:194
local function expect(patt, label) -- ./lib/lua-parser/parser.lua:197
return patt + throw(label) -- ./lib/lua-parser/parser.lua:198
end -- ./lib/lua-parser/parser.lua:198
local function token(patt) -- ./lib/lua-parser/parser.lua:204
return patt * V("Skip") -- ./lib/lua-parser/parser.lua:205
end -- ./lib/lua-parser/parser.lua:205
local function sym(str) -- ./lib/lua-parser/parser.lua:208
return token(P(str)) -- ./lib/lua-parser/parser.lua:209
end -- ./lib/lua-parser/parser.lua:209
local function kw(str) -- ./lib/lua-parser/parser.lua:212
return token(P(str) * - V("IdRest")) -- ./lib/lua-parser/parser.lua:213
end -- ./lib/lua-parser/parser.lua:213
local function tagC(tag, patt) -- ./lib/lua-parser/parser.lua:216
return Ct(Cg(Cp(), "pos") * Cg(Cc(tag), "tag") * patt) -- ./lib/lua-parser/parser.lua:217
end -- ./lib/lua-parser/parser.lua:217
local function unaryOp(op, e) -- ./lib/lua-parser/parser.lua:220
return { -- ./lib/lua-parser/parser.lua:221
["tag"] = "Op", -- ./lib/lua-parser/parser.lua:221
["pos"] = e["pos"], -- ./lib/lua-parser/parser.lua:221
[1] = op, -- ./lib/lua-parser/parser.lua:221
[2] = e -- ./lib/lua-parser/parser.lua:221
} -- ./lib/lua-parser/parser.lua:221
end -- ./lib/lua-parser/parser.lua:221
local function binaryOp(e1, op, e2) -- ./lib/lua-parser/parser.lua:224
if not op then -- ./lib/lua-parser/parser.lua:225
return e1 -- ./lib/lua-parser/parser.lua:226
else -- ./lib/lua-parser/parser.lua:226
return { -- ./lib/lua-parser/parser.lua:228
["tag"] = "Op", -- ./lib/lua-parser/parser.lua:228
["pos"] = e1["pos"], -- ./lib/lua-parser/parser.lua:228
[1] = op, -- ./lib/lua-parser/parser.lua:228
[2] = e1, -- ./lib/lua-parser/parser.lua:228
[3] = e2 -- ./lib/lua-parser/parser.lua:228
} -- ./lib/lua-parser/parser.lua:228
end -- ./lib/lua-parser/parser.lua:228
end -- ./lib/lua-parser/parser.lua:228
local function sepBy(patt, sep, label) -- ./lib/lua-parser/parser.lua:232
if label then -- ./lib/lua-parser/parser.lua:233
return patt * Cg(sep * expect(patt, label)) ^ 0 -- ./lib/lua-parser/parser.lua:234
else -- ./lib/lua-parser/parser.lua:234
return patt * Cg(sep * patt) ^ 0 -- ./lib/lua-parser/parser.lua:236
end -- ./lib/lua-parser/parser.lua:236
end -- ./lib/lua-parser/parser.lua:236
local function chainOp(patt, sep, label) -- ./lib/lua-parser/parser.lua:240
return Cf(sepBy(patt, sep, label), binaryOp) -- ./lib/lua-parser/parser.lua:241
end -- ./lib/lua-parser/parser.lua:241
local function commaSep(patt, label) -- ./lib/lua-parser/parser.lua:244
return sepBy(patt, sym(","), label) -- ./lib/lua-parser/parser.lua:245
end -- ./lib/lua-parser/parser.lua:245
local function tagDo(block) -- ./lib/lua-parser/parser.lua:248
block["tag"] = "Do" -- ./lib/lua-parser/parser.lua:249
return block -- ./lib/lua-parser/parser.lua:250
end -- ./lib/lua-parser/parser.lua:250
local function fixFuncStat(func) -- ./lib/lua-parser/parser.lua:253
if func[1]["is_method"] then -- ./lib/lua-parser/parser.lua:254
table["insert"](func[2][1], 1, { -- ./lib/lua-parser/parser.lua:254
["tag"] = "Id", -- ./lib/lua-parser/parser.lua:254
[1] = "self" -- ./lib/lua-parser/parser.lua:254
}) -- ./lib/lua-parser/parser.lua:254
end -- ./lib/lua-parser/parser.lua:254
func[1] = { func[1] } -- ./lib/lua-parser/parser.lua:255
func[2] = { func[2] } -- ./lib/lua-parser/parser.lua:256
return func -- ./lib/lua-parser/parser.lua:257
end -- ./lib/lua-parser/parser.lua:257
local function addDots(params, dots) -- ./lib/lua-parser/parser.lua:260
if dots then -- ./lib/lua-parser/parser.lua:261
table["insert"](params, dots) -- ./lib/lua-parser/parser.lua:261
end -- ./lib/lua-parser/parser.lua:261
return params -- ./lib/lua-parser/parser.lua:262
end -- ./lib/lua-parser/parser.lua:262
local function insertIndex(t, index) -- ./lib/lua-parser/parser.lua:265
return { -- ./lib/lua-parser/parser.lua:266
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:266
["pos"] = t["pos"], -- ./lib/lua-parser/parser.lua:266
[1] = t, -- ./lib/lua-parser/parser.lua:266
[2] = index -- ./lib/lua-parser/parser.lua:266
} -- ./lib/lua-parser/parser.lua:266
end -- ./lib/lua-parser/parser.lua:266
local function markMethod(t, method) -- ./lib/lua-parser/parser.lua:269
if method then -- ./lib/lua-parser/parser.lua:270
return { -- ./lib/lua-parser/parser.lua:271
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:271
["pos"] = t["pos"], -- ./lib/lua-parser/parser.lua:271
["is_method"] = true, -- ./lib/lua-parser/parser.lua:271
[1] = t, -- ./lib/lua-parser/parser.lua:271
[2] = method -- ./lib/lua-parser/parser.lua:271
} -- ./lib/lua-parser/parser.lua:271
end -- ./lib/lua-parser/parser.lua:271
return t -- ./lib/lua-parser/parser.lua:273
end -- ./lib/lua-parser/parser.lua:273
local function makeSuffixedExpr(t1, t2) -- ./lib/lua-parser/parser.lua:276
if t2["tag"] == "Call" or t2["tag"] == "SafeCall" then -- ./lib/lua-parser/parser.lua:277
local t = { -- ./lib/lua-parser/parser.lua:278
["tag"] = t2["tag"], -- ./lib/lua-parser/parser.lua:278
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:278
[1] = t1 -- ./lib/lua-parser/parser.lua:278
} -- ./lib/lua-parser/parser.lua:278
for k, v in ipairs(t2) do -- ./lib/lua-parser/parser.lua:279
table["insert"](t, v) -- ./lib/lua-parser/parser.lua:280
end -- ./lib/lua-parser/parser.lua:280
return t -- ./lib/lua-parser/parser.lua:282
elseif t2["tag"] == "MethodStub" or t2["tag"] == "SafeMethodStub" then -- ./lib/lua-parser/parser.lua:283
return { -- ./lib/lua-parser/parser.lua:284
["tag"] = t2["tag"], -- ./lib/lua-parser/parser.lua:284
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:284
[1] = t1, -- ./lib/lua-parser/parser.lua:284
[2] = t2[1] -- ./lib/lua-parser/parser.lua:284
} -- ./lib/lua-parser/parser.lua:284
elseif t2["tag"] == "SafeDotIndex" or t2["tag"] == "SafeArrayIndex" then -- ./lib/lua-parser/parser.lua:285
return { -- ./lib/lua-parser/parser.lua:286
["tag"] = "SafeIndex", -- ./lib/lua-parser/parser.lua:286
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:286
[1] = t1, -- ./lib/lua-parser/parser.lua:286
[2] = t2[1] -- ./lib/lua-parser/parser.lua:286
} -- ./lib/lua-parser/parser.lua:286
elseif t2["tag"] == "DotIndex" or t2["tag"] == "ArrayIndex" then -- ./lib/lua-parser/parser.lua:287
return { -- ./lib/lua-parser/parser.lua:288
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:288
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:288
[1] = t1, -- ./lib/lua-parser/parser.lua:288
[2] = t2[1] -- ./lib/lua-parser/parser.lua:288
} -- ./lib/lua-parser/parser.lua:288
else -- ./lib/lua-parser/parser.lua:288
error("unexpected tag in suffixed expression") -- ./lib/lua-parser/parser.lua:290
end -- ./lib/lua-parser/parser.lua:290
end -- ./lib/lua-parser/parser.lua:290
local function fixShortFunc(t) -- ./lib/lua-parser/parser.lua:294
if t[1] == ":" then -- self method -- ./lib/lua-parser/parser.lua:295
table["insert"](t[2], 1, { -- ./lib/lua-parser/parser.lua:296
["tag"] = "Id", -- ./lib/lua-parser/parser.lua:296
"self" -- ./lib/lua-parser/parser.lua:296
}) -- ./lib/lua-parser/parser.lua:296
table["remove"](t, 1) -- ./lib/lua-parser/parser.lua:297
t["is_method"] = true -- ./lib/lua-parser/parser.lua:298
end -- ./lib/lua-parser/parser.lua:298
t["is_short"] = true -- ./lib/lua-parser/parser.lua:300
return t -- ./lib/lua-parser/parser.lua:301
end -- ./lib/lua-parser/parser.lua:301
local function statToExpr(t) -- tag a StatExpr -- ./lib/lua-parser/parser.lua:304
t["tag"] = t["tag"] .. "Expr" -- ./lib/lua-parser/parser.lua:305
return t -- ./lib/lua-parser/parser.lua:306
end -- ./lib/lua-parser/parser.lua:306
local function fixStructure(t) -- fix the AST structure if needed -- ./lib/lua-parser/parser.lua:309
local i = 1 -- ./lib/lua-parser/parser.lua:310
while i <= # t do -- ./lib/lua-parser/parser.lua:311
if type(t[i]) == "table" then -- ./lib/lua-parser/parser.lua:312
fixStructure(t[i]) -- ./lib/lua-parser/parser.lua:313
for j = # t[i], 1, - 1 do -- ./lib/lua-parser/parser.lua:314
local stat = t[i][j] -- ./lib/lua-parser/parser.lua:315
if type(stat) == "table" and stat["move_up_block"] and stat["move_up_block"] > 0 then -- ./lib/lua-parser/parser.lua:316
table["remove"](t[i], j) -- ./lib/lua-parser/parser.lua:317
table["insert"](t, i + 1, stat) -- ./lib/lua-parser/parser.lua:318
if t["tag"] == "Block" or t["tag"] == "Do" then -- ./lib/lua-parser/parser.lua:319
stat["move_up_block"] = stat["move_up_block"] - 1 -- ./lib/lua-parser/parser.lua:320
end -- ./lib/lua-parser/parser.lua:320
end -- ./lib/lua-parser/parser.lua:320
end -- ./lib/lua-parser/parser.lua:320
end -- ./lib/lua-parser/parser.lua:320
i = i + 1 -- ./lib/lua-parser/parser.lua:325
end -- ./lib/lua-parser/parser.lua:325
return t -- ./lib/lua-parser/parser.lua:327
end -- ./lib/lua-parser/parser.lua:327
local function searchEndRec(block, isRecCall) -- recursively search potential "end" keyword wrongly consumed by a short anonymous function on stat end (yeah, too late to change the syntax to something easier to parse) -- ./lib/lua-parser/parser.lua:330
for i, stat in ipairs(block) do -- ./lib/lua-parser/parser.lua:331
if stat["tag"] == "Set" or stat["tag"] == "Push" or stat["tag"] == "Return" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./lib/lua-parser/parser.lua:333
local exprlist -- ./lib/lua-parser/parser.lua:334
if stat["tag"] == "Set" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./lib/lua-parser/parser.lua:336
exprlist = stat[# stat] -- ./lib/lua-parser/parser.lua:337
elseif stat["tag"] == "Push" or stat["tag"] == "Return" then -- ./lib/lua-parser/parser.lua:338
exprlist = stat -- ./lib/lua-parser/parser.lua:339
end -- ./lib/lua-parser/parser.lua:339
local last = exprlist[# exprlist] -- last value in ExprList -- ./lib/lua-parser/parser.lua:342
if last["tag"] == "Function" and last["is_short"] and not last["is_method"] and # last[1] == 1 then -- ./lib/lua-parser/parser.lua:346
local p = i -- ./lib/lua-parser/parser.lua:347
for j, fstat in ipairs(last[2]) do -- ./lib/lua-parser/parser.lua:348
p = i + j -- ./lib/lua-parser/parser.lua:349
table["insert"](block, p, fstat) -- copy stats from func body to block -- ./lib/lua-parser/parser.lua:350
if stat["move_up_block"] then -- extracted stats inherit move_up_block from statement -- ./lib/lua-parser/parser.lua:352
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + stat["move_up_block"] -- ./lib/lua-parser/parser.lua:353
end -- ./lib/lua-parser/parser.lua:353
if block["is_singlestatblock"] then -- if it's a single stat block, mark them to move them outside of the block -- ./lib/lua-parser/parser.lua:356
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:357
end -- ./lib/lua-parser/parser.lua:357
end -- ./lib/lua-parser/parser.lua:357
exprlist[# exprlist] = last[1] -- replace func with paren and expressions -- ./lib/lua-parser/parser.lua:361
exprlist[# exprlist]["tag"] = "Paren" -- ./lib/lua-parser/parser.lua:362
if not isRecCall then -- if superfluous statements won't be moved in a next recursion, let fixStructure handle things -- ./lib/lua-parser/parser.lua:364
for j = p + 1, # block, 1 do -- ./lib/lua-parser/parser.lua:365
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:366
end -- ./lib/lua-parser/parser.lua:366
end -- ./lib/lua-parser/parser.lua:366
return block, i -- ./lib/lua-parser/parser.lua:370
elseif last["tag"]:match("Expr$") then -- ./lib/lua-parser/parser.lua:373
local r = searchEndRec({ last }) -- ./lib/lua-parser/parser.lua:374
if r then -- ./lib/lua-parser/parser.lua:375
for j = 2, # r, 1 do -- ./lib/lua-parser/parser.lua:376
table["insert"](block, i + j - 1, r[j]) -- move back superflous statements from our new table to our real block -- ./lib/lua-parser/parser.lua:377
end -- move back superflous statements from our new table to our real block -- ./lib/lua-parser/parser.lua:377
return block, i -- ./lib/lua-parser/parser.lua:379
end -- ./lib/lua-parser/parser.lua:379
elseif last["tag"] == "Function" then -- ./lib/lua-parser/parser.lua:381
local r = searchEndRec(last[2]) -- ./lib/lua-parser/parser.lua:382
if r then -- ./lib/lua-parser/parser.lua:383
return block, i -- ./lib/lua-parser/parser.lua:384
end -- ./lib/lua-parser/parser.lua:384
end -- ./lib/lua-parser/parser.lua:384
elseif stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Do") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./lib/lua-parser/parser.lua:389
local blocks -- ./lib/lua-parser/parser.lua:390
if stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./lib/lua-parser/parser.lua:392
blocks = stat -- ./lib/lua-parser/parser.lua:393
elseif stat["tag"]:match("^Do") then -- ./lib/lua-parser/parser.lua:394
blocks = { stat } -- ./lib/lua-parser/parser.lua:395
end -- ./lib/lua-parser/parser.lua:395
for _, iblock in ipairs(blocks) do -- ./lib/lua-parser/parser.lua:398
if iblock["tag"] == "Block" then -- blocks -- ./lib/lua-parser/parser.lua:399
local oldLen = # iblock -- ./lib/lua-parser/parser.lua:400
local newiBlock, newEnd = searchEndRec(iblock, true) -- ./lib/lua-parser/parser.lua:401
if newiBlock then -- if end in the block -- ./lib/lua-parser/parser.lua:402
local p = i -- ./lib/lua-parser/parser.lua:403
for j = newEnd + (# iblock - oldLen) + 1, # iblock, 1 do -- move all statements after the newely added statements to the parent block -- ./lib/lua-parser/parser.lua:404
p = p + 1 -- ./lib/lua-parser/parser.lua:405
table["insert"](block, p, iblock[j]) -- ./lib/lua-parser/parser.lua:406
iblock[j] = nil -- ./lib/lua-parser/parser.lua:407
end -- ./lib/lua-parser/parser.lua:407
if not isRecCall then -- if superfluous statements won't be moved in a next recursion, let fixStructure handle things -- ./lib/lua-parser/parser.lua:410
for j = p + 1, # block, 1 do -- ./lib/lua-parser/parser.lua:411
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
return block, i -- ./lib/lua-parser/parser.lua:416
end -- ./lib/lua-parser/parser.lua:416
end -- ./lib/lua-parser/parser.lua:416
end -- ./lib/lua-parser/parser.lua:416
end -- ./lib/lua-parser/parser.lua:416
end -- ./lib/lua-parser/parser.lua:416
return nil -- ./lib/lua-parser/parser.lua:422
end -- ./lib/lua-parser/parser.lua:422
local function searchEnd(s, p, t) -- match time capture which try to restructure the AST to free an "end" for us -- ./lib/lua-parser/parser.lua:425
local r = searchEndRec(fixStructure(t)) -- ./lib/lua-parser/parser.lua:426
if not r then -- ./lib/lua-parser/parser.lua:427
return false -- ./lib/lua-parser/parser.lua:428
end -- ./lib/lua-parser/parser.lua:428
return true, r -- ./lib/lua-parser/parser.lua:430
end -- ./lib/lua-parser/parser.lua:430
local function expectBlockOrSingleStatWithStartEnd(start, startLabel, stopLabel, canFollow) -- will try a SingleStat if start doesn't match -- ./lib/lua-parser/parser.lua:433
if canFollow then -- ./lib/lua-parser/parser.lua:434
return (- start * V("SingleStatBlock") * canFollow ^ - 1) + (expect(start, startLabel) * ((V("Block") * (canFollow + kw("end"))) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./lib/lua-parser/parser.lua:437
else -- ./lib/lua-parser/parser.lua:437
return (- start * V("SingleStatBlock")) + (expect(start, startLabel) * ((V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./lib/lua-parser/parser.lua:441
end -- ./lib/lua-parser/parser.lua:441
end -- ./lib/lua-parser/parser.lua:441
local function expectBlockWithEnd(label) -- can't work *optionnaly* with SingleStat unfortunatly -- ./lib/lua-parser/parser.lua:445
return (V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(label)) -- ./lib/lua-parser/parser.lua:447
end -- ./lib/lua-parser/parser.lua:447
local function maybeBlockWithEnd() -- same as above but don't error if it doesn't match -- ./lib/lua-parser/parser.lua:450
return (V("BlockNoErr") * kw("end")) + Cmt(V("BlockNoErr"), searchEnd) -- ./lib/lua-parser/parser.lua:452
end -- ./lib/lua-parser/parser.lua:452
local stacks = { ["lexpr"] = {} } -- ./lib/lua-parser/parser.lua:456
local function push(f) -- ./lib/lua-parser/parser.lua:458
return Cmt(P(""), function() -- ./lib/lua-parser/parser.lua:459
table["insert"](stacks[f], true) -- ./lib/lua-parser/parser.lua:460
return true -- ./lib/lua-parser/parser.lua:461
end) -- ./lib/lua-parser/parser.lua:461
end -- ./lib/lua-parser/parser.lua:461
local function pop(f) -- ./lib/lua-parser/parser.lua:464
return Cmt(P(""), function() -- ./lib/lua-parser/parser.lua:465
table["remove"](stacks[f]) -- ./lib/lua-parser/parser.lua:466
return true -- ./lib/lua-parser/parser.lua:467
end) -- ./lib/lua-parser/parser.lua:467
end -- ./lib/lua-parser/parser.lua:467
local function when(f) -- ./lib/lua-parser/parser.lua:470
return Cmt(P(""), function() -- ./lib/lua-parser/parser.lua:471
return # stacks[f] > 0 -- ./lib/lua-parser/parser.lua:472
end) -- ./lib/lua-parser/parser.lua:472
end -- ./lib/lua-parser/parser.lua:472
local function set(f, patt) -- patt *must* succeed (or throw an error) to preserve stack integrity -- ./lib/lua-parser/parser.lua:475
return push(f) * patt * pop(f) -- ./lib/lua-parser/parser.lua:476
end -- ./lib/lua-parser/parser.lua:476
local G = { -- ./lib/lua-parser/parser.lua:480
V("Lua"), -- ./lib/lua-parser/parser.lua:480
["Lua"] = (V("Shebang") ^ - 1 * V("Skip") * V("Block") * expect(P(- 1), "Extra")) / fixStructure, -- ./lib/lua-parser/parser.lua:481
["Shebang"] = P("#!") * (P(1) - P("\
")) ^ 0, -- ./lib/lua-parser/parser.lua:482
["Block"] = tagC("Block", (V("Stat") + - V("BlockEnd") * throw("InvalidStat")) ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./lib/lua-parser/parser.lua:484
["Stat"] = V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat") + V("LocalStat") + V("FuncStat") + V("BreakStat") + V("LabelStat") + V("GoToStat") + V("LetStat") + V("FuncCall") + V("Assignment") + V("ContinueStat") + V("PushStat") + sym(";"), -- ./lib/lua-parser/parser.lua:490
["BlockEnd"] = P("return") + "end" + "elseif" + "else" + "until" + "]" + - 1 + V("ImplicitPushStat") + V("Assignment"), -- ./lib/lua-parser/parser.lua:491
["SingleStatBlock"] = tagC("Block", V("Stat") + V("RetStat") + V("ImplicitPushStat")) / function(t) -- ./lib/lua-parser/parser.lua:493
t["is_singlestatblock"] = true -- ./lib/lua-parser/parser.lua:493
return t -- ./lib/lua-parser/parser.lua:493
end, -- ./lib/lua-parser/parser.lua:493
["BlockNoErr"] = tagC("Block", V("Stat") ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- used to check if something a valid block without throwing an error -- ./lib/lua-parser/parser.lua:494
["IfStat"] = tagC("If", V("IfPart")), -- ./lib/lua-parser/parser.lua:496
["IfPart"] = kw("if") * set("lexpr", expect(V("Expr"), "ExprIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./lib/lua-parser/parser.lua:497
["ElseIfPart"] = kw("elseif") * set("lexpr", expect(V("Expr"), "ExprEIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenEIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./lib/lua-parser/parser.lua:498
["ElsePart"] = kw("else") * expectBlockWithEnd("EndIf"), -- ./lib/lua-parser/parser.lua:499
["DoStat"] = kw("do") * expectBlockWithEnd("EndDo") / tagDo, -- ./lib/lua-parser/parser.lua:501
["WhileStat"] = tagC("While", kw("while") * set("lexpr", expect(V("Expr"), "ExprWhile")) * V("WhileBody")), -- ./lib/lua-parser/parser.lua:502
["WhileBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoWhile", "EndWhile"), -- ./lib/lua-parser/parser.lua:503
["RepeatStat"] = tagC("Repeat", kw("repeat") * V("Block") * expect(kw("until"), "UntilRep") * expect(V("Expr"), "ExprRep")), -- ./lib/lua-parser/parser.lua:504
["ForStat"] = kw("for") * expect(V("ForNum") + V("ForIn"), "ForRange"), -- ./lib/lua-parser/parser.lua:506
["ForNum"] = tagC("Fornum", V("Id") * sym("=") * V("NumRange") * V("ForBody")), -- ./lib/lua-parser/parser.lua:507
["NumRange"] = expect(V("Expr"), "ExprFor1") * expect(sym(","), "CommaFor") * expect(V("Expr"), "ExprFor2") * (sym(",") * expect(V("Expr"), "ExprFor3")) ^ - 1, -- ./lib/lua-parser/parser.lua:509
["ForIn"] = tagC("Forin", V("DestructuringNameList") * expect(kw("in"), "InFor") * expect(V("ExprList"), "EListFor") * V("ForBody")), -- ./lib/lua-parser/parser.lua:510
["ForBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoFor", "EndFor"), -- ./lib/lua-parser/parser.lua:511
["LocalStat"] = kw("local") * expect(V("LocalFunc") + V("LocalAssign"), "DefLocal"), -- ./lib/lua-parser/parser.lua:513
["LocalFunc"] = tagC("Localrec", kw("function") * expect(V("Id"), "NameLFunc") * V("FuncBody")) / fixFuncStat, -- ./lib/lua-parser/parser.lua:514
["LocalAssign"] = tagC("Local", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Local", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./lib/lua-parser/parser.lua:516
["LetStat"] = kw("let") * expect(V("LetAssign"), "DefLet"), -- ./lib/lua-parser/parser.lua:518
["LetAssign"] = tagC("Let", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))) + tagC("Let", V("DestructuringNameList") * sym("=") * expect(V("ExprList"), "EListLAssign")), -- ./lib/lua-parser/parser.lua:520
["Assignment"] = tagC("Set", (V("VarList") + V("DestructuringNameList")) * V("BinOp") ^ - 1 * (P("=") / "=") * ((V("BinOp") - P("-")) + # (P("-") * V("Space")) * V("BinOp")) ^ - 1 * V("Skip") * expect(V("ExprList"), "EListAssign")), -- ./lib/lua-parser/parser.lua:522
["FuncStat"] = tagC("Set", kw("function") * expect(V("FuncName"), "FuncName") * V("FuncBody")) / fixFuncStat, -- ./lib/lua-parser/parser.lua:524
["FuncName"] = Cf(V("Id") * (sym(".") * expect(V("StrId"), "NameFunc1")) ^ 0, insertIndex) * (sym(":") * expect(V("StrId"), "NameFunc2")) ^ - 1 / markMethod, -- ./lib/lua-parser/parser.lua:526
["FuncBody"] = tagC("Function", V("FuncParams") * expectBlockWithEnd("EndFunc")), -- ./lib/lua-parser/parser.lua:527
["FuncParams"] = expect(sym("("), "OParenPList") * V("ParList") * expect(sym(")"), "CParenPList"), -- ./lib/lua-parser/parser.lua:528
["ParList"] = V("NamedParList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()), -- Cc({}) generates a bug since the {} would be shared across parses -- ./lib/lua-parser/parser.lua:531
["ShortFuncDef"] = tagC("Function", V("ShortFuncParams") * maybeBlockWithEnd()) / fixShortFunc, -- ./lib/lua-parser/parser.lua:533
["ShortFuncParams"] = (sym(":") / ":") ^ - 1 * sym("(") * V("ParList") * sym(")"), -- ./lib/lua-parser/parser.lua:534
["NamedParList"] = tagC("NamedParList", commaSep(V("NamedPar"))), -- ./lib/lua-parser/parser.lua:536
["NamedPar"] = tagC("ParPair", V("ParKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Id"), -- ./lib/lua-parser/parser.lua:538
["ParKey"] = V("Id") * # ("=" * - P("=")), -- ./lib/lua-parser/parser.lua:539
["LabelStat"] = tagC("Label", sym("::") * expect(V("Name"), "Label") * expect(sym("::"), "CloseLabel")), -- ./lib/lua-parser/parser.lua:541
["GoToStat"] = tagC("Goto", kw("goto") * expect(V("Name"), "Goto")), -- ./lib/lua-parser/parser.lua:542
["BreakStat"] = tagC("Break", kw("break")), -- ./lib/lua-parser/parser.lua:543
["ContinueStat"] = tagC("Continue", kw("continue")), -- ./lib/lua-parser/parser.lua:544
["RetStat"] = tagC("Return", kw("return") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./lib/lua-parser/parser.lua:545
["PushStat"] = tagC("Push", kw("push") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./lib/lua-parser/parser.lua:547
["ImplicitPushStat"] = tagC("Push", commaSep(V("Expr"), "RetList")), -- ./lib/lua-parser/parser.lua:548
["NameList"] = tagC("NameList", commaSep(V("Id"))), -- ./lib/lua-parser/parser.lua:550
["DestructuringNameList"] = tagC("NameList", commaSep(V("DestructuringId"))), -- ./lib/lua-parser/parser.lua:551
["VarList"] = tagC("VarList", commaSep(V("VarExpr"))), -- ./lib/lua-parser/parser.lua:552
["ExprList"] = tagC("ExpList", commaSep(V("Expr"), "ExprList")), -- ./lib/lua-parser/parser.lua:553
["DestructuringId"] = tagC("DestructuringId", sym("{") * V("DestructuringIdFieldList") * expect(sym("}"), "CBraceDestructuring")) + V("Id"), -- ./lib/lua-parser/parser.lua:555
["DestructuringIdFieldList"] = sepBy(V("DestructuringIdField"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./lib/lua-parser/parser.lua:556
["DestructuringIdField"] = tagC("Pair", V("FieldKey") * expect(sym("="), "DestructuringEqField") * expect(V("Id"), "DestructuringExprField")) + V("Id"), -- ./lib/lua-parser/parser.lua:558
["Expr"] = V("OrExpr"), -- ./lib/lua-parser/parser.lua:560
["OrExpr"] = chainOp(V("AndExpr"), V("OrOp"), "OrExpr"), -- ./lib/lua-parser/parser.lua:561
["AndExpr"] = chainOp(V("RelExpr"), V("AndOp"), "AndExpr"), -- ./lib/lua-parser/parser.lua:562
["RelExpr"] = chainOp(V("BOrExpr"), V("RelOp"), "RelExpr"), -- ./lib/lua-parser/parser.lua:563
["BOrExpr"] = chainOp(V("BXorExpr"), V("BOrOp"), "BOrExpr"), -- ./lib/lua-parser/parser.lua:564
["BXorExpr"] = chainOp(V("BAndExpr"), V("BXorOp"), "BXorExpr"), -- ./lib/lua-parser/parser.lua:565
["BAndExpr"] = chainOp(V("ShiftExpr"), V("BAndOp"), "BAndExpr"), -- ./lib/lua-parser/parser.lua:566
["ShiftExpr"] = chainOp(V("ConcatExpr"), V("ShiftOp"), "ShiftExpr"), -- ./lib/lua-parser/parser.lua:567
["ConcatExpr"] = V("AddExpr") * (V("ConcatOp") * expect(V("ConcatExpr"), "ConcatExpr")) ^ - 1 / binaryOp, -- ./lib/lua-parser/parser.lua:568
["AddExpr"] = chainOp(V("MulExpr"), V("AddOp"), "AddExpr"), -- ./lib/lua-parser/parser.lua:569
["MulExpr"] = chainOp(V("UnaryExpr"), V("MulOp"), "MulExpr"), -- ./lib/lua-parser/parser.lua:570
["UnaryExpr"] = V("UnaryOp") * expect(V("UnaryExpr"), "UnaryExpr") / unaryOp + V("PowExpr"), -- ./lib/lua-parser/parser.lua:572
["PowExpr"] = V("SimpleExpr") * (V("PowOp") * expect(V("UnaryExpr"), "PowExpr")) ^ - 1 / binaryOp, -- ./lib/lua-parser/parser.lua:573
["SimpleExpr"] = tagC("Number", V("Number")) + tagC("Nil", kw("nil")) + tagC("Boolean", kw("false") * Cc(false)) + tagC("Boolean", kw("true") * Cc(true)) + tagC("Dots", sym("...")) + V("FuncDef") + (when("lexpr") * tagC("LetExpr", V("DestructuringNameList") * sym("=") * - sym("=") * expect(V("ExprList"), "EListLAssign"))) + V("ShortFuncDef") + V("SuffixedExpr") + V("StatExpr"), -- ./lib/lua-parser/parser.lua:583
["StatExpr"] = (V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat")) / statToExpr, -- ./lib/lua-parser/parser.lua:585
["FuncCall"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./lib/lua-parser/parser.lua:587
return exp["tag"] == "Call" or exp["tag"] == "SafeCall", exp -- ./lib/lua-parser/parser.lua:587
end), -- ./lib/lua-parser/parser.lua:587
["VarExpr"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./lib/lua-parser/parser.lua:588
return exp["tag"] == "Id" or exp["tag"] == "Index", exp -- ./lib/lua-parser/parser.lua:588
end), -- ./lib/lua-parser/parser.lua:588
["SuffixedExpr"] = Cf(V("PrimaryExpr") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr") * - V("Call") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr"), makeSuffixedExpr), -- ./lib/lua-parser/parser.lua:592
["PrimaryExpr"] = V("SelfId") * (V("SelfCall") + V("SelfIndex")) + V("Id") + tagC("Paren", sym("(") * expect(V("Expr"), "ExprParen") * expect(sym(")"), "CParenExpr")), -- ./lib/lua-parser/parser.lua:595
["NoCallPrimaryExpr"] = tagC("String", V("String")) + V("Table") + V("TableCompr"), -- ./lib/lua-parser/parser.lua:596
["Index"] = tagC("DotIndex", sym("." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("ArrayIndex", sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")) + tagC("SafeDotIndex", sym("?." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("SafeArrayIndex", sym("?[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")), -- ./lib/lua-parser/parser.lua:600
["MethodStub"] = tagC("MethodStub", sym(":" * - P(":")) * expect(V("StrId"), "NameMeth")) + tagC("SafeMethodStub", sym("?:" * - P(":")) * expect(V("StrId"), "NameMeth")), -- ./lib/lua-parser/parser.lua:602
["Call"] = tagC("Call", V("FuncArgs")) + tagC("SafeCall", P("?") * V("FuncArgs")), -- ./lib/lua-parser/parser.lua:604
["SelfCall"] = tagC("MethodStub", V("StrId")) * V("Call"), -- ./lib/lua-parser/parser.lua:605
["SelfIndex"] = tagC("DotIndex", V("StrId")), -- ./lib/lua-parser/parser.lua:606
["FuncDef"] = (kw("function") * V("FuncBody")), -- ./lib/lua-parser/parser.lua:608
["FuncArgs"] = sym("(") * commaSep(V("Expr"), "ArgList") ^ - 1 * expect(sym(")"), "CParenArgs") + V("Table") + tagC("String", V("String")), -- ./lib/lua-parser/parser.lua:611
["Table"] = tagC("Table", sym("{") * V("FieldList") ^ - 1 * expect(sym("}"), "CBraceTable")), -- ./lib/lua-parser/parser.lua:613
["FieldList"] = sepBy(V("Field"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./lib/lua-parser/parser.lua:614
["Field"] = tagC("Pair", V("FieldKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Expr"), -- ./lib/lua-parser/parser.lua:616
["FieldKey"] = sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprFKey") * expect(sym("]"), "CBracketFKey") + V("StrId") * # ("=" * - P("=")), -- ./lib/lua-parser/parser.lua:618
["FieldSep"] = sym(",") + sym(";"), -- ./lib/lua-parser/parser.lua:619
["TableCompr"] = tagC("TableCompr", sym("[") * V("Block") * expect(sym("]"), "CBracketTableCompr")), -- ./lib/lua-parser/parser.lua:621
["SelfId"] = tagC("Id", sym("@") / "self"), -- ./lib/lua-parser/parser.lua:623
["Id"] = tagC("Id", V("Name")) + V("SelfId"), -- ./lib/lua-parser/parser.lua:624
["StrId"] = tagC("String", V("Name")), -- ./lib/lua-parser/parser.lua:625
["Skip"] = (V("Space") + V("Comment")) ^ 0, -- ./lib/lua-parser/parser.lua:628
["Space"] = space ^ 1, -- ./lib/lua-parser/parser.lua:629
["Comment"] = P("--") * V("LongStr") / function() -- ./lib/lua-parser/parser.lua:630
return  -- ./lib/lua-parser/parser.lua:630
end + P("--") * (P(1) - P("\
")) ^ 0, -- ./lib/lua-parser/parser.lua:631
["Name"] = token(- V("Reserved") * C(V("Ident"))), -- ./lib/lua-parser/parser.lua:633
["Reserved"] = V("Keywords") * - V("IdRest"), -- ./lib/lua-parser/parser.lua:634
["Keywords"] = P("and") + "break" + "do" + "elseif" + "else" + "end" + "false" + "for" + "function" + "goto" + "if" + "in" + "local" + "nil" + "not" + "or" + "repeat" + "return" + "then" + "true" + "until" + "while", -- ./lib/lua-parser/parser.lua:638
["Ident"] = V("IdStart") * V("IdRest") ^ 0, -- ./lib/lua-parser/parser.lua:639
["IdStart"] = alpha + P("_"), -- ./lib/lua-parser/parser.lua:640
["IdRest"] = alnum + P("_"), -- ./lib/lua-parser/parser.lua:641
["Number"] = token(C(V("Hex") + V("Float") + V("Int"))), -- ./lib/lua-parser/parser.lua:643
["Hex"] = (P("0x") + "0X") * ((xdigit ^ 0 * V("DeciHex")) + (expect(xdigit ^ 1, "DigitHex") * V("DeciHex") ^ - 1)) * V("ExpoHex") ^ - 1, -- ./lib/lua-parser/parser.lua:644
["Float"] = V("Decimal") * V("Expo") ^ - 1 + V("Int") * V("Expo"), -- ./lib/lua-parser/parser.lua:646
["Decimal"] = digit ^ 1 * "." * digit ^ 0 + P(".") * - P(".") * expect(digit ^ 1, "DigitDeci"), -- ./lib/lua-parser/parser.lua:648
["DeciHex"] = P(".") * xdigit ^ 0, -- ./lib/lua-parser/parser.lua:649
["Expo"] = S("eE") * S("+-") ^ - 1 * expect(digit ^ 1, "DigitExpo"), -- ./lib/lua-parser/parser.lua:650
["ExpoHex"] = S("pP") * S("+-") ^ - 1 * expect(xdigit ^ 1, "DigitExpo"), -- ./lib/lua-parser/parser.lua:651
["Int"] = digit ^ 1, -- ./lib/lua-parser/parser.lua:652
["String"] = token(V("ShortStr") + V("LongStr")), -- ./lib/lua-parser/parser.lua:654
["ShortStr"] = P("\"") * Cs((V("EscSeq") + (P(1) - S("\"\
"))) ^ 0) * expect(P("\""), "Quote") + P("'") * Cs((V("EscSeq") + (P(1) - S("'\
"))) ^ 0) * expect(P("'"), "Quote"), -- ./lib/lua-parser/parser.lua:656
["EscSeq"] = P("\\") / "" * (P("a") / "\7" + P("b") / "\8" + P("f") / "\12" + P("n") / "\
" + P("r") / "\13" + P("t") / "\9" + P("v") / "\11" + P("\
") / "\
" + P("\13") / "\
" + P("\\") / "\\" + P("\"") / "\"" + P("'") / "'" + P("z") * space ^ 0 / "" + digit * digit ^ - 2 / tonumber / string["char"] + P("x") * expect(C(xdigit * xdigit), "HexEsc") * Cc(16) / tonumber / string["char"] + P("u") * expect("{", "OBraceUEsc") * expect(C(xdigit ^ 1), "DigitUEsc") * Cc(16) * expect("}", "CBraceUEsc") / tonumber / (utf8 and utf8["char"] or string["char"]) + throw("EscSeq")), -- ./lib/lua-parser/parser.lua:686
["LongStr"] = V("Open") * C((P(1) - V("CloseEq")) ^ 0) * expect(V("Close"), "CloseLStr") / function(s, eqs) -- ./lib/lua-parser/parser.lua:689
return s -- ./lib/lua-parser/parser.lua:689
end, -- ./lib/lua-parser/parser.lua:689
["Open"] = "[" * Cg(V("Equals"), "openEq") * "[" * P("\
") ^ - 1, -- ./lib/lua-parser/parser.lua:690
["Close"] = "]" * C(V("Equals")) * "]", -- ./lib/lua-parser/parser.lua:691
["Equals"] = P("=") ^ 0, -- ./lib/lua-parser/parser.lua:692
["CloseEq"] = Cmt(V("Close") * Cb("openEq"), function(s, i, closeEq, openEq) -- ./lib/lua-parser/parser.lua:693
return # openEq == # closeEq -- ./lib/lua-parser/parser.lua:693
end), -- ./lib/lua-parser/parser.lua:693
["OrOp"] = kw("or") / "or", -- ./lib/lua-parser/parser.lua:695
["AndOp"] = kw("and") / "and", -- ./lib/lua-parser/parser.lua:696
["RelOp"] = sym("~=") / "ne" + sym("==") / "eq" + sym("<=") / "le" + sym(">=") / "ge" + sym("<") / "lt" + sym(">") / "gt", -- ./lib/lua-parser/parser.lua:702
["BOrOp"] = sym("|") / "bor", -- ./lib/lua-parser/parser.lua:703
["BXorOp"] = sym("~" * - P("=")) / "bxor", -- ./lib/lua-parser/parser.lua:704
["BAndOp"] = sym("&") / "band", -- ./lib/lua-parser/parser.lua:705
["ShiftOp"] = sym("<<") / "shl" + sym(">>") / "shr", -- ./lib/lua-parser/parser.lua:707
["ConcatOp"] = sym("..") / "concat", -- ./lib/lua-parser/parser.lua:708
["AddOp"] = sym("+") / "add" + sym("-") / "sub", -- ./lib/lua-parser/parser.lua:710
["MulOp"] = sym("*") / "mul" + sym("//") / "idiv" + sym("/") / "div" + sym("%") / "mod", -- ./lib/lua-parser/parser.lua:714
["UnaryOp"] = kw("not") / "not" + sym("-") / "unm" + sym("#") / "len" + sym("~") / "bnot", -- ./lib/lua-parser/parser.lua:718
["PowOp"] = sym("^") / "pow", -- ./lib/lua-parser/parser.lua:719
["BinOp"] = V("OrOp") + V("AndOp") + V("BOrOp") + V("BXorOp") + V("BAndOp") + V("ShiftOp") + V("ConcatOp") + V("AddOp") + V("MulOp") + V("PowOp") -- ./lib/lua-parser/parser.lua:720
} -- ./lib/lua-parser/parser.lua:720
local parser = {} -- ./lib/lua-parser/parser.lua:723
local validator = require("lib.lua-parser.validator") -- ./lib/lua-parser/parser.lua:725
local validate = validator["validate"] -- ./lib/lua-parser/parser.lua:726
local syntaxerror = validator["syntaxerror"] -- ./lib/lua-parser/parser.lua:727
parser["parse"] = function(subject, filename) -- ./lib/lua-parser/parser.lua:729
local errorinfo = { -- ./lib/lua-parser/parser.lua:730
["subject"] = subject, -- ./lib/lua-parser/parser.lua:730
["filename"] = filename -- ./lib/lua-parser/parser.lua:730
} -- ./lib/lua-parser/parser.lua:730
lpeg["setmaxstack"](1000) -- ./lib/lua-parser/parser.lua:731
local ast, label, errpos = lpeg["match"](G, subject, nil, errorinfo) -- ./lib/lua-parser/parser.lua:732
if not ast then -- ./lib/lua-parser/parser.lua:733
local errmsg = labels[label][2] -- ./lib/lua-parser/parser.lua:734
return ast, syntaxerror(errorinfo, errpos, errmsg) -- ./lib/lua-parser/parser.lua:735
end -- ./lib/lua-parser/parser.lua:735
return validate(ast, errorinfo) -- ./lib/lua-parser/parser.lua:737
end -- ./lib/lua-parser/parser.lua:737
return parser -- ./lib/lua-parser/parser.lua:740
end -- ./lib/lua-parser/parser.lua:740
local parser = _() or parser -- ./lib/lua-parser/parser.lua:744
package["loaded"]["lib.lua-parser.parser"] = parser or true -- ./lib/lua-parser/parser.lua:745
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
if not inComment and not inLongString and line:match("^%s*#") and not line:match("^#!") then -- exclude shebang -- candran.can:63
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
