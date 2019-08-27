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
")):match("%-%- (.-)%:(%d+)\
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
local required = {} -- { ["module"] = true, ... } -- ./compiler/lua53.can:46
local requireStr = "" -- ./compiler/lua53.can:47
local function addRequire(mod, name, field) -- ./compiler/lua53.can:49
if not required[mod] then -- ./compiler/lua53.can:50
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"]) -- ./compiler/lua53.can:51
required[mod] = true -- ./compiler/lua53.can:52
end -- ./compiler/lua53.can:52
end -- ./compiler/lua53.can:52
local function var(name) -- ./compiler/lua53.can:58
return options["variablePrefix"] .. name -- ./compiler/lua53.can:59
end -- ./compiler/lua53.can:59
local loop = { -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"While", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Repeat", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Fornum", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Forin", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"WhileExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"RepeatExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"FornumExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"ForinExpr" -- loops tags (can contain continue) -- ./compiler/lua53.can:63
} -- loops tags (can contain continue) -- ./compiler/lua53.can:63
local func = { -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"Function", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"TableCompr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"DoExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"WhileExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"RepeatExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"IfExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"FornumExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"ForinExpr" -- function scope tags (can contain push) -- ./compiler/lua53.can:64
} -- function scope tags (can contain push) -- ./compiler/lua53.can:64
local function any(list, tags, nofollow) -- ./compiler/lua53.can:68
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:68
local tagsCheck = {} -- ./compiler/lua53.can:69
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:70
tagsCheck[tag] = true -- ./compiler/lua53.can:71
end -- ./compiler/lua53.can:71
local nofollowCheck = {} -- ./compiler/lua53.can:73
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:74
nofollowCheck[tag] = true -- ./compiler/lua53.can:75
end -- ./compiler/lua53.can:75
for _, node in ipairs(list) do -- ./compiler/lua53.can:77
if type(node) == "table" then -- ./compiler/lua53.can:78
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:79
return node -- ./compiler/lua53.can:80
end -- ./compiler/lua53.can:80
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:82
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:83
if r then -- ./compiler/lua53.can:84
return r -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
return nil -- ./compiler/lua53.can:88
end -- ./compiler/lua53.can:88
local function search(list, tags, nofollow) -- ./compiler/lua53.can:93
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:93
local tagsCheck = {} -- ./compiler/lua53.can:94
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:95
tagsCheck[tag] = true -- ./compiler/lua53.can:96
end -- ./compiler/lua53.can:96
local nofollowCheck = {} -- ./compiler/lua53.can:98
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:99
nofollowCheck[tag] = true -- ./compiler/lua53.can:100
end -- ./compiler/lua53.can:100
local found = {} -- ./compiler/lua53.can:102
for _, node in ipairs(list) do -- ./compiler/lua53.can:103
if type(node) == "table" then -- ./compiler/lua53.can:104
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:105
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua53.can:106
table["insert"](found, n) -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:110
table["insert"](found, node) -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
return found -- ./compiler/lua53.can:115
end -- ./compiler/lua53.can:115
local function all(list, tags) -- ./compiler/lua53.can:119
for _, node in ipairs(list) do -- ./compiler/lua53.can:120
local ok = false -- ./compiler/lua53.can:121
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:122
if node["tag"] == tag then -- ./compiler/lua53.can:123
ok = true -- ./compiler/lua53.can:124
break -- ./compiler/lua53.can:125
end -- ./compiler/lua53.can:125
end -- ./compiler/lua53.can:125
if not ok then -- ./compiler/lua53.can:128
return false -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
return true -- ./compiler/lua53.can:132
end -- ./compiler/lua53.can:132
local states = { ["push"] = {} } -- push stack variable names -- ./compiler/lua53.can:138
local function push(name, state) -- ./compiler/lua53.can:141
table["insert"](states[name], state) -- ./compiler/lua53.can:142
return "" -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
local function pop(name) -- ./compiler/lua53.can:146
table["remove"](states[name]) -- ./compiler/lua53.can:147
return "" -- ./compiler/lua53.can:148
end -- ./compiler/lua53.can:148
local function peek(name) -- ./compiler/lua53.can:151
return states[name][# states[name]] -- ./compiler/lua53.can:152
end -- ./compiler/lua53.can:152
local tags -- ./compiler/lua53.can:156
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:158
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:159
lastInputPos = ast["pos"] -- ./compiler/lua53.can:160
end -- ./compiler/lua53.can:160
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:162
end -- ./compiler/lua53.can:162
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:166
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:167
end -- ./compiler/lua53.can:167
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:169
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:170
end -- ./compiler/lua53.can:170
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:172
return "do" .. indent() -- ./compiler/lua53.can:173
end -- ./compiler/lua53.can:173
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:175
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:176
end -- ./compiler/lua53.can:176
tags = setmetatable({ -- ./compiler/lua53.can:180
["Block"] = function(t) -- ./compiler/lua53.can:182
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:183
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:184
hasPush["tag"] = "Return" -- ./compiler/lua53.can:185
hasPush = false -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local r = "" -- ./compiler/lua53.can:188
if hasPush then -- ./compiler/lua53.can:189
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:190
end -- ./compiler/lua53.can:190
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:192
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:193
end -- ./compiler/lua53.can:193
if t[# t] then -- ./compiler/lua53.can:195
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:196
end -- ./compiler/lua53.can:196
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:198
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:199
end -- ./compiler/lua53.can:199
return r -- ./compiler/lua53.can:201
end, -- ./compiler/lua53.can:201
["Do"] = function(t) -- ./compiler/lua53.can:207
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:208
end, -- ./compiler/lua53.can:208
["Set"] = function(t) -- ./compiler/lua53.can:211
if # t == 2 then -- ./compiler/lua53.can:212
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs") -- ./compiler/lua53.can:213
elseif # t == 3 then -- ./compiler/lua53.can:214
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs") -- ./compiler/lua53.can:215
elseif # t == 4 then -- ./compiler/lua53.can:216
if t[3] == "=" then -- ./compiler/lua53.can:217
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:218
t[2], -- ./compiler/lua53.can:218
t[1][1], -- ./compiler/lua53.can:218
{ -- ./compiler/lua53.can:218
["tag"] = "Paren", -- ./compiler/lua53.can:218
t[4][1] -- ./compiler/lua53.can:218
} -- ./compiler/lua53.can:218
}, "Op") -- ./compiler/lua53.can:218
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:219
r = r .. (", " .. lua({ -- ./compiler/lua53.can:220
t[2], -- ./compiler/lua53.can:220
t[1][i], -- ./compiler/lua53.can:220
{ -- ./compiler/lua53.can:220
["tag"] = "Paren", -- ./compiler/lua53.can:220
t[4][i] -- ./compiler/lua53.can:220
} -- ./compiler/lua53.can:220
}, "Op")) -- ./compiler/lua53.can:220
end -- ./compiler/lua53.can:220
return r -- ./compiler/lua53.can:222
else -- ./compiler/lua53.can:222
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:224
t[3], -- ./compiler/lua53.can:224
{ -- ./compiler/lua53.can:224
["tag"] = "Paren", -- ./compiler/lua53.can:224
t[4][1] -- ./compiler/lua53.can:224
}, -- ./compiler/lua53.can:224
t[1][1] -- ./compiler/lua53.can:224
}, "Op") -- ./compiler/lua53.can:224
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:225
r = r .. (", " .. lua({ -- ./compiler/lua53.can:226
t[3], -- ./compiler/lua53.can:226
{ -- ./compiler/lua53.can:226
["tag"] = "Paren", -- ./compiler/lua53.can:226
t[4][i] -- ./compiler/lua53.can:226
}, -- ./compiler/lua53.can:226
t[1][i] -- ./compiler/lua53.can:226
}, "Op")) -- ./compiler/lua53.can:226
end -- ./compiler/lua53.can:226
return r -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
else -- ./compiler/lua53.can:228
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:231
t[2], -- ./compiler/lua53.can:231
t[1][1], -- ./compiler/lua53.can:231
{ -- ./compiler/lua53.can:231
["tag"] = "Op", -- ./compiler/lua53.can:231
t[4], -- ./compiler/lua53.can:231
{ -- ./compiler/lua53.can:231
["tag"] = "Paren", -- ./compiler/lua53.can:231
t[5][1] -- ./compiler/lua53.can:231
}, -- ./compiler/lua53.can:231
t[1][1] -- ./compiler/lua53.can:231
} -- ./compiler/lua53.can:231
}, "Op") -- ./compiler/lua53.can:231
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:232
r = r .. (", " .. lua({ -- ./compiler/lua53.can:233
t[2], -- ./compiler/lua53.can:233
t[1][i], -- ./compiler/lua53.can:233
{ -- ./compiler/lua53.can:233
["tag"] = "Op", -- ./compiler/lua53.can:233
t[4], -- ./compiler/lua53.can:233
{ -- ./compiler/lua53.can:233
["tag"] = "Paren", -- ./compiler/lua53.can:233
t[5][i] -- ./compiler/lua53.can:233
}, -- ./compiler/lua53.can:233
t[1][i] -- ./compiler/lua53.can:233
} -- ./compiler/lua53.can:233
}, "Op")) -- ./compiler/lua53.can:233
end -- ./compiler/lua53.can:233
return r -- ./compiler/lua53.can:235
end -- ./compiler/lua53.can:235
end, -- ./compiler/lua53.can:235
["While"] = function(t) -- ./compiler/lua53.can:239
local r = "" -- ./compiler/lua53.can:240
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:241
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:242
if # lets > 0 then -- ./compiler/lua53.can:243
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:244
for _, l in ipairs(lets) do -- ./compiler/lua53.can:245
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua53.can:249
if # lets > 0 then -- ./compiler/lua53.can:250
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:251
end -- ./compiler/lua53.can:251
if hasContinue then -- ./compiler/lua53.can:253
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:254
end -- ./compiler/lua53.can:254
r = r .. (lua(t[2])) -- ./compiler/lua53.can:256
if hasContinue then -- ./compiler/lua53.can:257
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:258
end -- ./compiler/lua53.can:258
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:260
if # lets > 0 then -- ./compiler/lua53.can:261
for _, l in ipairs(lets) do -- ./compiler/lua53.can:262
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua53.can:263
end -- ./compiler/lua53.can:263
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua53.can:265
end -- ./compiler/lua53.can:265
return r -- ./compiler/lua53.can:267
end, -- ./compiler/lua53.can:267
["Repeat"] = function(t) -- ./compiler/lua53.can:270
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:271
local r = "repeat" .. indent() -- ./compiler/lua53.can:272
if hasContinue then -- ./compiler/lua53.can:273
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:274
end -- ./compiler/lua53.can:274
r = r .. (lua(t[1])) -- ./compiler/lua53.can:276
if hasContinue then -- ./compiler/lua53.can:277
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:278
end -- ./compiler/lua53.can:278
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:280
return r -- ./compiler/lua53.can:281
end, -- ./compiler/lua53.can:281
["If"] = function(t) -- ./compiler/lua53.can:284
local r = "" -- ./compiler/lua53.can:285
local toClose = 0 -- blocks that need to be closed at the end of the if -- ./compiler/lua53.can:286
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:287
if # lets > 0 then -- ./compiler/lua53.can:288
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:289
toClose = toClose + (1) -- ./compiler/lua53.can:290
for _, l in ipairs(lets) do -- ./compiler/lua53.can:291
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:292
end -- ./compiler/lua53.can:292
end -- ./compiler/lua53.can:292
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua53.can:295
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:296
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua53.can:297
if # lets > 0 then -- ./compiler/lua53.can:298
r = r .. ("else" .. indent()) -- ./compiler/lua53.can:299
toClose = toClose + (1) -- ./compiler/lua53.can:300
for _, l in ipairs(lets) do -- ./compiler/lua53.can:301
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:302
end -- ./compiler/lua53.can:302
else -- ./compiler/lua53.can:302
r = r .. ("else") -- ./compiler/lua53.can:305
end -- ./compiler/lua53.can:305
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:307
end -- ./compiler/lua53.can:307
if # t % 2 == 1 then -- ./compiler/lua53.can:309
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
r = r .. ("end") -- ./compiler/lua53.can:312
for i = 1, toClose do -- ./compiler/lua53.can:313
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:314
end -- ./compiler/lua53.can:314
return r -- ./compiler/lua53.can:316
end, -- ./compiler/lua53.can:316
["Fornum"] = function(t) -- ./compiler/lua53.can:319
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:320
if # t == 5 then -- ./compiler/lua53.can:321
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:322
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:323
if hasContinue then -- ./compiler/lua53.can:324
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
r = r .. (lua(t[5])) -- ./compiler/lua53.can:327
if hasContinue then -- ./compiler/lua53.can:328
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:329
end -- ./compiler/lua53.can:329
return r .. unindent() .. "end" -- ./compiler/lua53.can:331
else -- ./compiler/lua53.can:331
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:333
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:334
if hasContinue then -- ./compiler/lua53.can:335
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:336
end -- ./compiler/lua53.can:336
r = r .. (lua(t[4])) -- ./compiler/lua53.can:338
if hasContinue then -- ./compiler/lua53.can:339
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:340
end -- ./compiler/lua53.can:340
return r .. unindent() .. "end" -- ./compiler/lua53.can:342
end -- ./compiler/lua53.can:342
end, -- ./compiler/lua53.can:342
["Forin"] = function(t) -- ./compiler/lua53.can:346
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:347
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:348
if hasContinue then -- ./compiler/lua53.can:349
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:350
end -- ./compiler/lua53.can:350
r = r .. (lua(t[3])) -- ./compiler/lua53.can:352
if hasContinue then -- ./compiler/lua53.can:353
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:354
end -- ./compiler/lua53.can:354
return r .. unindent() .. "end" -- ./compiler/lua53.can:356
end, -- ./compiler/lua53.can:356
["Local"] = function(t) -- ./compiler/lua53.can:359
local r = "local " .. lua(t[1], "_lhs") -- ./compiler/lua53.can:360
if t[2][1] then -- ./compiler/lua53.can:361
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:362
end -- ./compiler/lua53.can:362
return r -- ./compiler/lua53.can:364
end, -- ./compiler/lua53.can:364
["Let"] = function(t) -- ./compiler/lua53.can:367
local nameList = lua(t[1], "_lhs") -- ./compiler/lua53.can:368
local r = "local " .. nameList -- ./compiler/lua53.can:369
if t[2][1] then -- ./compiler/lua53.can:370
if all(t[2], { -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Nil", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Dots", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Boolean", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Number", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"String" -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
}) then -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:372
else -- ./compiler/lua53.can:372
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:374
end -- ./compiler/lua53.can:374
end -- ./compiler/lua53.can:374
return r -- ./compiler/lua53.can:377
end, -- ./compiler/lua53.can:377
["Localrec"] = function(t) -- ./compiler/lua53.can:380
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:381
end, -- ./compiler/lua53.can:381
["Goto"] = function(t) -- ./compiler/lua53.can:384
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:385
end, -- ./compiler/lua53.can:385
["Label"] = function(t) -- ./compiler/lua53.can:388
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:389
end, -- ./compiler/lua53.can:389
["Return"] = function(t) -- ./compiler/lua53.can:392
local push = peek("push") -- ./compiler/lua53.can:393
if push then -- ./compiler/lua53.can:394
local r = "" -- ./compiler/lua53.can:395
for _, val in ipairs(t) do -- ./compiler/lua53.can:396
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:397
end -- ./compiler/lua53.can:397
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:399
else -- ./compiler/lua53.can:399
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:401
end -- ./compiler/lua53.can:401
end, -- ./compiler/lua53.can:401
["Push"] = function(t) -- ./compiler/lua53.can:405
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:406
r = "" -- ./compiler/lua53.can:407
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:408
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:409
end -- ./compiler/lua53.can:409
if t[# t] then -- ./compiler/lua53.can:411
if t[# t]["tag"] == "Call" then -- ./compiler/lua53.can:412
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:413
else -- ./compiler/lua53.can:413
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:415
end -- ./compiler/lua53.can:415
end -- ./compiler/lua53.can:415
return r -- ./compiler/lua53.can:418
end, -- ./compiler/lua53.can:418
["Break"] = function() -- ./compiler/lua53.can:421
return "break" -- ./compiler/lua53.can:422
end, -- ./compiler/lua53.can:422
["Continue"] = function() -- ./compiler/lua53.can:425
return "goto " .. var("continue") -- ./compiler/lua53.can:426
end, -- ./compiler/lua53.can:426
["Nil"] = function() -- ./compiler/lua53.can:433
return "nil" -- ./compiler/lua53.can:434
end, -- ./compiler/lua53.can:434
["Dots"] = function() -- ./compiler/lua53.can:437
return "..." -- ./compiler/lua53.can:438
end, -- ./compiler/lua53.can:438
["Boolean"] = function(t) -- ./compiler/lua53.can:441
return tostring(t[1]) -- ./compiler/lua53.can:442
end, -- ./compiler/lua53.can:442
["Number"] = function(t) -- ./compiler/lua53.can:445
return tostring(t[1]) -- ./compiler/lua53.can:446
end, -- ./compiler/lua53.can:446
["String"] = function(t) -- ./compiler/lua53.can:449
return ("%q"):format(t[1]) -- ./compiler/lua53.can:450
end, -- ./compiler/lua53.can:450
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:453
local r = "(" -- ./compiler/lua53.can:454
local decl = {} -- ./compiler/lua53.can:455
if t[1][1] then -- ./compiler/lua53.can:456
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:457
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:458
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:459
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:460
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:461
r = r .. (id) -- ./compiler/lua53.can:462
else -- ./compiler/lua53.can:462
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:464
end -- ./compiler/lua53.can:464
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:466
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:467
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:468
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:469
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:470
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:471
r = r .. (", " .. id) -- ./compiler/lua53.can:472
else -- ./compiler/lua53.can:472
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
r = r .. (")" .. indent()) -- ./compiler/lua53.can:478
for _, d in ipairs(decl) do -- ./compiler/lua53.can:479
r = r .. (d .. newline()) -- ./compiler/lua53.can:480
end -- ./compiler/lua53.can:480
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:482
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:483
end -- ./compiler/lua53.can:483
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:485
if hasPush then -- ./compiler/lua53.can:486
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:487
else -- ./compiler/lua53.can:487
push("push", false) -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:489
end -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:489
r = r .. (lua(t[2])) -- ./compiler/lua53.can:491
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:492
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
pop("push") -- ./compiler/lua53.can:495
return r .. unindent() .. "end" -- ./compiler/lua53.can:496
end, -- ./compiler/lua53.can:496
["Function"] = function(t) -- ./compiler/lua53.can:498
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:499
end, -- ./compiler/lua53.can:499
["Pair"] = function(t) -- ./compiler/lua53.can:502
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:503
end, -- ./compiler/lua53.can:503
["Table"] = function(t) -- ./compiler/lua53.can:505
if # t == 0 then -- ./compiler/lua53.can:506
return "{}" -- ./compiler/lua53.can:507
elseif # t == 1 then -- ./compiler/lua53.can:508
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:509
else -- ./compiler/lua53.can:509
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:511
end -- ./compiler/lua53.can:511
end, -- ./compiler/lua53.can:511
["TableCompr"] = function(t) -- ./compiler/lua53.can:515
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:516
end, -- ./compiler/lua53.can:516
["Op"] = function(t) -- ./compiler/lua53.can:519
local r -- ./compiler/lua53.can:520
if # t == 2 then -- ./compiler/lua53.can:521
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:522
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:523
else -- ./compiler/lua53.can:523
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:525
end -- ./compiler/lua53.can:525
else -- ./compiler/lua53.can:525
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:528
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:529
else -- ./compiler/lua53.can:529
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:531
end -- ./compiler/lua53.can:531
end -- ./compiler/lua53.can:531
return r -- ./compiler/lua53.can:534
end, -- ./compiler/lua53.can:534
["Paren"] = function(t) -- ./compiler/lua53.can:537
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:538
end, -- ./compiler/lua53.can:538
["MethodStub"] = function(t) -- ./compiler/lua53.can:541
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:547
end, -- ./compiler/lua53.can:547
["SafeMethodStub"] = function(t) -- ./compiler/lua53.can:550
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:557
end, -- ./compiler/lua53.can:557
["LetExpr"] = function(t) -- ./compiler/lua53.can:564
return lua(t[1][1]) -- ./compiler/lua53.can:565
end, -- ./compiler/lua53.can:565
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:569
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:570
local r = "(function()" .. indent() -- ./compiler/lua53.can:571
if hasPush then -- ./compiler/lua53.can:572
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:573
else -- ./compiler/lua53.can:573
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:575
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:575
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:577
if hasPush then -- ./compiler/lua53.can:578
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:579
end -- ./compiler/lua53.can:579
pop("push") -- ./compiler/lua53.can:581
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:582
return r -- ./compiler/lua53.can:583
end, -- ./compiler/lua53.can:583
["DoExpr"] = function(t) -- ./compiler/lua53.can:586
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:587
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:588
end -- ./compiler/lua53.can:588
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:590
end, -- ./compiler/lua53.can:590
["WhileExpr"] = function(t) -- ./compiler/lua53.can:593
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:594
end, -- ./compiler/lua53.can:594
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:597
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:598
end, -- ./compiler/lua53.can:598
["IfExpr"] = function(t) -- ./compiler/lua53.can:601
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:602
local block = t[i] -- ./compiler/lua53.can:603
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:604
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:605
end -- ./compiler/lua53.can:605
end -- ./compiler/lua53.can:605
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:608
end, -- ./compiler/lua53.can:608
["FornumExpr"] = function(t) -- ./compiler/lua53.can:611
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:612
end, -- ./compiler/lua53.can:612
["ForinExpr"] = function(t) -- ./compiler/lua53.can:615
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:616
end, -- ./compiler/lua53.can:616
["Call"] = function(t) -- ./compiler/lua53.can:622
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:623
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:624
elseif t[1]["tag"] == "MethodStub" then -- method call -- ./compiler/lua53.can:625
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua53.can:626
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:627
else -- ./compiler/lua53.can:627
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:629
end -- ./compiler/lua53.can:629
else -- ./compiler/lua53.can:629
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
end, -- ./compiler/lua53.can:632
["SafeCall"] = function(t) -- ./compiler/lua53.can:636
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:637
return lua(t, "SafeIndex") -- ./compiler/lua53.can:638
else -- ./compiler/lua53.can:638
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua53.can:640
end -- ./compiler/lua53.can:640
end, -- ./compiler/lua53.can:640
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:645
if start == nil then start = 1 end -- ./compiler/lua53.can:645
local r -- ./compiler/lua53.can:646
if t[start] then -- ./compiler/lua53.can:647
r = lua(t[start]) -- ./compiler/lua53.can:648
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:649
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:650
end -- ./compiler/lua53.can:650
else -- ./compiler/lua53.can:650
r = "" -- ./compiler/lua53.can:653
end -- ./compiler/lua53.can:653
return r -- ./compiler/lua53.can:655
end, -- ./compiler/lua53.can:655
["Id"] = function(t) -- ./compiler/lua53.can:658
return t[1] -- ./compiler/lua53.can:659
end, -- ./compiler/lua53.can:659
["Index"] = function(t) -- ./compiler/lua53.can:662
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:663
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:664
else -- ./compiler/lua53.can:664
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:666
end -- ./compiler/lua53.can:666
end, -- ./compiler/lua53.can:666
["SafeIndex"] = function(t) -- ./compiler/lua53.can:670
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:671
local l = {} -- list of immediately chained safeindex, from deepest to nearest (to simply generated code) -- ./compiler/lua53.can:672
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:673
table["insert"](l, 1, t) -- ./compiler/lua53.can:674
t = t[1] -- ./compiler/lua53.can:675
end -- ./compiler/lua53.can:675
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- base expr -- ./compiler/lua53.can:677
for _, e in ipairs(l) do -- ./compiler/lua53.can:678
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua53.can:679
if e["tag"] == "SafeIndex" then -- ./compiler/lua53.can:680
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua53.can:681
else -- ./compiler/lua53.can:681
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua53.can:683
end -- ./compiler/lua53.can:683
end -- ./compiler/lua53.can:683
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua53.can:686
return r -- ./compiler/lua53.can:687
else -- ./compiler/lua53.can:687
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua53.can:689
end -- ./compiler/lua53.can:689
end, -- ./compiler/lua53.can:689
["_opid"] = { -- ./compiler/lua53.can:694
["add"] = "+", -- ./compiler/lua53.can:695
["sub"] = "-", -- ./compiler/lua53.can:695
["mul"] = "*", -- ./compiler/lua53.can:695
["div"] = "/", -- ./compiler/lua53.can:695
["idiv"] = "//", -- ./compiler/lua53.can:696
["mod"] = "%", -- ./compiler/lua53.can:696
["pow"] = "^", -- ./compiler/lua53.can:696
["concat"] = "..", -- ./compiler/lua53.can:696
["band"] = "&", -- ./compiler/lua53.can:697
["bor"] = "|", -- ./compiler/lua53.can:697
["bxor"] = "~", -- ./compiler/lua53.can:697
["shl"] = "<<", -- ./compiler/lua53.can:697
["shr"] = ">>", -- ./compiler/lua53.can:697
["eq"] = "==", -- ./compiler/lua53.can:698
["ne"] = "~=", -- ./compiler/lua53.can:698
["lt"] = "<", -- ./compiler/lua53.can:698
["gt"] = ">", -- ./compiler/lua53.can:698
["le"] = "<=", -- ./compiler/lua53.can:698
["ge"] = ">=", -- ./compiler/lua53.can:698
["and"] = "and", -- ./compiler/lua53.can:699
["or"] = "or", -- ./compiler/lua53.can:699
["unm"] = "-", -- ./compiler/lua53.can:699
["len"] = "#", -- ./compiler/lua53.can:699
["bnot"] = "~", -- ./compiler/lua53.can:699
["not"] = "not" -- ./compiler/lua53.can:699
} -- ./compiler/lua53.can:699
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:702
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua53.can:703
end }) -- ./compiler/lua53.can:703
local code = lua(ast) .. newline() -- ./compiler/lua53.can:709
return requireStr .. code -- ./compiler/lua53.can:710
end -- ./compiler/lua53.can:710
end -- ./compiler/lua53.can:710
local lua53 = _() or lua53 -- ./compiler/lua53.can:715
package["loaded"]["compiler.lua53"] = lua53 or true -- ./compiler/lua53.can:716
local function _() -- ./compiler/lua53.can:719
local function _() -- ./compiler/lua53.can:721
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
")):match("%-%- (.-)%:(%d+)\
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
local required = {} -- { ["module"] = true, ... } -- ./compiler/lua53.can:46
local requireStr = "" -- ./compiler/lua53.can:47
local function addRequire(mod, name, field) -- ./compiler/lua53.can:49
if not required[mod] then -- ./compiler/lua53.can:50
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"]) -- ./compiler/lua53.can:51
required[mod] = true -- ./compiler/lua53.can:52
end -- ./compiler/lua53.can:52
end -- ./compiler/lua53.can:52
local function var(name) -- ./compiler/lua53.can:58
return options["variablePrefix"] .. name -- ./compiler/lua53.can:59
end -- ./compiler/lua53.can:59
local loop = { -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"While", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Repeat", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Fornum", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Forin", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"WhileExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"RepeatExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"FornumExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"ForinExpr" -- loops tags (can contain continue) -- ./compiler/lua53.can:63
} -- loops tags (can contain continue) -- ./compiler/lua53.can:63
local func = { -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"Function", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"TableCompr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"DoExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"WhileExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"RepeatExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"IfExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"FornumExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"ForinExpr" -- function scope tags (can contain push) -- ./compiler/lua53.can:64
} -- function scope tags (can contain push) -- ./compiler/lua53.can:64
local function any(list, tags, nofollow) -- ./compiler/lua53.can:68
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:68
local tagsCheck = {} -- ./compiler/lua53.can:69
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:70
tagsCheck[tag] = true -- ./compiler/lua53.can:71
end -- ./compiler/lua53.can:71
local nofollowCheck = {} -- ./compiler/lua53.can:73
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:74
nofollowCheck[tag] = true -- ./compiler/lua53.can:75
end -- ./compiler/lua53.can:75
for _, node in ipairs(list) do -- ./compiler/lua53.can:77
if type(node) == "table" then -- ./compiler/lua53.can:78
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:79
return node -- ./compiler/lua53.can:80
end -- ./compiler/lua53.can:80
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:82
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:83
if r then -- ./compiler/lua53.can:84
return r -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
return nil -- ./compiler/lua53.can:88
end -- ./compiler/lua53.can:88
local function search(list, tags, nofollow) -- ./compiler/lua53.can:93
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:93
local tagsCheck = {} -- ./compiler/lua53.can:94
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:95
tagsCheck[tag] = true -- ./compiler/lua53.can:96
end -- ./compiler/lua53.can:96
local nofollowCheck = {} -- ./compiler/lua53.can:98
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:99
nofollowCheck[tag] = true -- ./compiler/lua53.can:100
end -- ./compiler/lua53.can:100
local found = {} -- ./compiler/lua53.can:102
for _, node in ipairs(list) do -- ./compiler/lua53.can:103
if type(node) == "table" then -- ./compiler/lua53.can:104
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:105
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua53.can:106
table["insert"](found, n) -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:110
table["insert"](found, node) -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
return found -- ./compiler/lua53.can:115
end -- ./compiler/lua53.can:115
local function all(list, tags) -- ./compiler/lua53.can:119
for _, node in ipairs(list) do -- ./compiler/lua53.can:120
local ok = false -- ./compiler/lua53.can:121
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:122
if node["tag"] == tag then -- ./compiler/lua53.can:123
ok = true -- ./compiler/lua53.can:124
break -- ./compiler/lua53.can:125
end -- ./compiler/lua53.can:125
end -- ./compiler/lua53.can:125
if not ok then -- ./compiler/lua53.can:128
return false -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
return true -- ./compiler/lua53.can:132
end -- ./compiler/lua53.can:132
local states = { ["push"] = {} } -- push stack variable names -- ./compiler/lua53.can:138
local function push(name, state) -- ./compiler/lua53.can:141
table["insert"](states[name], state) -- ./compiler/lua53.can:142
return "" -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
local function pop(name) -- ./compiler/lua53.can:146
table["remove"](states[name]) -- ./compiler/lua53.can:147
return "" -- ./compiler/lua53.can:148
end -- ./compiler/lua53.can:148
local function peek(name) -- ./compiler/lua53.can:151
return states[name][# states[name]] -- ./compiler/lua53.can:152
end -- ./compiler/lua53.can:152
local tags -- ./compiler/lua53.can:156
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:158
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:159
lastInputPos = ast["pos"] -- ./compiler/lua53.can:160
end -- ./compiler/lua53.can:160
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:162
end -- ./compiler/lua53.can:162
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:166
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:167
end -- ./compiler/lua53.can:167
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:169
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:170
end -- ./compiler/lua53.can:170
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:172
return "do" .. indent() -- ./compiler/lua53.can:173
end -- ./compiler/lua53.can:173
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:175
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:176
end -- ./compiler/lua53.can:176
tags = setmetatable({ -- ./compiler/lua53.can:180
["Block"] = function(t) -- ./compiler/lua53.can:182
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:183
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:184
hasPush["tag"] = "Return" -- ./compiler/lua53.can:185
hasPush = false -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local r = "" -- ./compiler/lua53.can:188
if hasPush then -- ./compiler/lua53.can:189
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:190
end -- ./compiler/lua53.can:190
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:192
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:193
end -- ./compiler/lua53.can:193
if t[# t] then -- ./compiler/lua53.can:195
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:196
end -- ./compiler/lua53.can:196
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:198
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:199
end -- ./compiler/lua53.can:199
return r -- ./compiler/lua53.can:201
end, -- ./compiler/lua53.can:201
["Do"] = function(t) -- ./compiler/lua53.can:207
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:208
end, -- ./compiler/lua53.can:208
["Set"] = function(t) -- ./compiler/lua53.can:211
if # t == 2 then -- ./compiler/lua53.can:212
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs") -- ./compiler/lua53.can:213
elseif # t == 3 then -- ./compiler/lua53.can:214
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs") -- ./compiler/lua53.can:215
elseif # t == 4 then -- ./compiler/lua53.can:216
if t[3] == "=" then -- ./compiler/lua53.can:217
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:218
t[2], -- ./compiler/lua53.can:218
t[1][1], -- ./compiler/lua53.can:218
{ -- ./compiler/lua53.can:218
["tag"] = "Paren", -- ./compiler/lua53.can:218
t[4][1] -- ./compiler/lua53.can:218
} -- ./compiler/lua53.can:218
}, "Op") -- ./compiler/lua53.can:218
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:219
r = r .. (", " .. lua({ -- ./compiler/lua53.can:220
t[2], -- ./compiler/lua53.can:220
t[1][i], -- ./compiler/lua53.can:220
{ -- ./compiler/lua53.can:220
["tag"] = "Paren", -- ./compiler/lua53.can:220
t[4][i] -- ./compiler/lua53.can:220
} -- ./compiler/lua53.can:220
}, "Op")) -- ./compiler/lua53.can:220
end -- ./compiler/lua53.can:220
return r -- ./compiler/lua53.can:222
else -- ./compiler/lua53.can:222
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:224
t[3], -- ./compiler/lua53.can:224
{ -- ./compiler/lua53.can:224
["tag"] = "Paren", -- ./compiler/lua53.can:224
t[4][1] -- ./compiler/lua53.can:224
}, -- ./compiler/lua53.can:224
t[1][1] -- ./compiler/lua53.can:224
}, "Op") -- ./compiler/lua53.can:224
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:225
r = r .. (", " .. lua({ -- ./compiler/lua53.can:226
t[3], -- ./compiler/lua53.can:226
{ -- ./compiler/lua53.can:226
["tag"] = "Paren", -- ./compiler/lua53.can:226
t[4][i] -- ./compiler/lua53.can:226
}, -- ./compiler/lua53.can:226
t[1][i] -- ./compiler/lua53.can:226
}, "Op")) -- ./compiler/lua53.can:226
end -- ./compiler/lua53.can:226
return r -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
else -- ./compiler/lua53.can:228
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:231
t[2], -- ./compiler/lua53.can:231
t[1][1], -- ./compiler/lua53.can:231
{ -- ./compiler/lua53.can:231
["tag"] = "Op", -- ./compiler/lua53.can:231
t[4], -- ./compiler/lua53.can:231
{ -- ./compiler/lua53.can:231
["tag"] = "Paren", -- ./compiler/lua53.can:231
t[5][1] -- ./compiler/lua53.can:231
}, -- ./compiler/lua53.can:231
t[1][1] -- ./compiler/lua53.can:231
} -- ./compiler/lua53.can:231
}, "Op") -- ./compiler/lua53.can:231
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:232
r = r .. (", " .. lua({ -- ./compiler/lua53.can:233
t[2], -- ./compiler/lua53.can:233
t[1][i], -- ./compiler/lua53.can:233
{ -- ./compiler/lua53.can:233
["tag"] = "Op", -- ./compiler/lua53.can:233
t[4], -- ./compiler/lua53.can:233
{ -- ./compiler/lua53.can:233
["tag"] = "Paren", -- ./compiler/lua53.can:233
t[5][i] -- ./compiler/lua53.can:233
}, -- ./compiler/lua53.can:233
t[1][i] -- ./compiler/lua53.can:233
} -- ./compiler/lua53.can:233
}, "Op")) -- ./compiler/lua53.can:233
end -- ./compiler/lua53.can:233
return r -- ./compiler/lua53.can:235
end -- ./compiler/lua53.can:235
end, -- ./compiler/lua53.can:235
["While"] = function(t) -- ./compiler/lua53.can:239
local r = "" -- ./compiler/lua53.can:240
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:241
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:242
if # lets > 0 then -- ./compiler/lua53.can:243
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:244
for _, l in ipairs(lets) do -- ./compiler/lua53.can:245
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua53.can:249
if # lets > 0 then -- ./compiler/lua53.can:250
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:251
end -- ./compiler/lua53.can:251
if hasContinue then -- ./compiler/lua53.can:253
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:254
end -- ./compiler/lua53.can:254
r = r .. (lua(t[2])) -- ./compiler/lua53.can:256
if hasContinue then -- ./compiler/lua53.can:257
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:258
end -- ./compiler/lua53.can:258
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:260
if # lets > 0 then -- ./compiler/lua53.can:261
for _, l in ipairs(lets) do -- ./compiler/lua53.can:262
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua53.can:263
end -- ./compiler/lua53.can:263
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua53.can:265
end -- ./compiler/lua53.can:265
return r -- ./compiler/lua53.can:267
end, -- ./compiler/lua53.can:267
["Repeat"] = function(t) -- ./compiler/lua53.can:270
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:271
local r = "repeat" .. indent() -- ./compiler/lua53.can:272
if hasContinue then -- ./compiler/lua53.can:273
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:274
end -- ./compiler/lua53.can:274
r = r .. (lua(t[1])) -- ./compiler/lua53.can:276
if hasContinue then -- ./compiler/lua53.can:277
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:278
end -- ./compiler/lua53.can:278
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:280
return r -- ./compiler/lua53.can:281
end, -- ./compiler/lua53.can:281
["If"] = function(t) -- ./compiler/lua53.can:284
local r = "" -- ./compiler/lua53.can:285
local toClose = 0 -- blocks that need to be closed at the end of the if -- ./compiler/lua53.can:286
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:287
if # lets > 0 then -- ./compiler/lua53.can:288
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:289
toClose = toClose + (1) -- ./compiler/lua53.can:290
for _, l in ipairs(lets) do -- ./compiler/lua53.can:291
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:292
end -- ./compiler/lua53.can:292
end -- ./compiler/lua53.can:292
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua53.can:295
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:296
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua53.can:297
if # lets > 0 then -- ./compiler/lua53.can:298
r = r .. ("else" .. indent()) -- ./compiler/lua53.can:299
toClose = toClose + (1) -- ./compiler/lua53.can:300
for _, l in ipairs(lets) do -- ./compiler/lua53.can:301
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:302
end -- ./compiler/lua53.can:302
else -- ./compiler/lua53.can:302
r = r .. ("else") -- ./compiler/lua53.can:305
end -- ./compiler/lua53.can:305
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:307
end -- ./compiler/lua53.can:307
if # t % 2 == 1 then -- ./compiler/lua53.can:309
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
r = r .. ("end") -- ./compiler/lua53.can:312
for i = 1, toClose do -- ./compiler/lua53.can:313
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:314
end -- ./compiler/lua53.can:314
return r -- ./compiler/lua53.can:316
end, -- ./compiler/lua53.can:316
["Fornum"] = function(t) -- ./compiler/lua53.can:319
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:320
if # t == 5 then -- ./compiler/lua53.can:321
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:322
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:323
if hasContinue then -- ./compiler/lua53.can:324
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
r = r .. (lua(t[5])) -- ./compiler/lua53.can:327
if hasContinue then -- ./compiler/lua53.can:328
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:329
end -- ./compiler/lua53.can:329
return r .. unindent() .. "end" -- ./compiler/lua53.can:331
else -- ./compiler/lua53.can:331
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:333
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:334
if hasContinue then -- ./compiler/lua53.can:335
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:336
end -- ./compiler/lua53.can:336
r = r .. (lua(t[4])) -- ./compiler/lua53.can:338
if hasContinue then -- ./compiler/lua53.can:339
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:340
end -- ./compiler/lua53.can:340
return r .. unindent() .. "end" -- ./compiler/lua53.can:342
end -- ./compiler/lua53.can:342
end, -- ./compiler/lua53.can:342
["Forin"] = function(t) -- ./compiler/lua53.can:346
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:347
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:348
if hasContinue then -- ./compiler/lua53.can:349
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:350
end -- ./compiler/lua53.can:350
r = r .. (lua(t[3])) -- ./compiler/lua53.can:352
if hasContinue then -- ./compiler/lua53.can:353
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:354
end -- ./compiler/lua53.can:354
return r .. unindent() .. "end" -- ./compiler/lua53.can:356
end, -- ./compiler/lua53.can:356
["Local"] = function(t) -- ./compiler/lua53.can:359
local r = "local " .. lua(t[1], "_lhs") -- ./compiler/lua53.can:360
if t[2][1] then -- ./compiler/lua53.can:361
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:362
end -- ./compiler/lua53.can:362
return r -- ./compiler/lua53.can:364
end, -- ./compiler/lua53.can:364
["Let"] = function(t) -- ./compiler/lua53.can:367
local nameList = lua(t[1], "_lhs") -- ./compiler/lua53.can:368
local r = "local " .. nameList -- ./compiler/lua53.can:369
if t[2][1] then -- ./compiler/lua53.can:370
if all(t[2], { -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Nil", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Dots", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Boolean", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Number", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"String" -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
}) then -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:372
else -- ./compiler/lua53.can:372
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:374
end -- ./compiler/lua53.can:374
end -- ./compiler/lua53.can:374
return r -- ./compiler/lua53.can:377
end, -- ./compiler/lua53.can:377
["Localrec"] = function(t) -- ./compiler/lua53.can:380
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:381
end, -- ./compiler/lua53.can:381
["Goto"] = function(t) -- ./compiler/lua53.can:384
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:385
end, -- ./compiler/lua53.can:385
["Label"] = function(t) -- ./compiler/lua53.can:388
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:389
end, -- ./compiler/lua53.can:389
["Return"] = function(t) -- ./compiler/lua53.can:392
local push = peek("push") -- ./compiler/lua53.can:393
if push then -- ./compiler/lua53.can:394
local r = "" -- ./compiler/lua53.can:395
for _, val in ipairs(t) do -- ./compiler/lua53.can:396
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:397
end -- ./compiler/lua53.can:397
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:399
else -- ./compiler/lua53.can:399
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:401
end -- ./compiler/lua53.can:401
end, -- ./compiler/lua53.can:401
["Push"] = function(t) -- ./compiler/lua53.can:405
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:406
r = "" -- ./compiler/lua53.can:407
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:408
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:409
end -- ./compiler/lua53.can:409
if t[# t] then -- ./compiler/lua53.can:411
if t[# t]["tag"] == "Call" then -- ./compiler/lua53.can:412
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:413
else -- ./compiler/lua53.can:413
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:415
end -- ./compiler/lua53.can:415
end -- ./compiler/lua53.can:415
return r -- ./compiler/lua53.can:418
end, -- ./compiler/lua53.can:418
["Break"] = function() -- ./compiler/lua53.can:421
return "break" -- ./compiler/lua53.can:422
end, -- ./compiler/lua53.can:422
["Continue"] = function() -- ./compiler/lua53.can:425
return "goto " .. var("continue") -- ./compiler/lua53.can:426
end, -- ./compiler/lua53.can:426
["Nil"] = function() -- ./compiler/lua53.can:433
return "nil" -- ./compiler/lua53.can:434
end, -- ./compiler/lua53.can:434
["Dots"] = function() -- ./compiler/lua53.can:437
return "..." -- ./compiler/lua53.can:438
end, -- ./compiler/lua53.can:438
["Boolean"] = function(t) -- ./compiler/lua53.can:441
return tostring(t[1]) -- ./compiler/lua53.can:442
end, -- ./compiler/lua53.can:442
["Number"] = function(t) -- ./compiler/lua53.can:445
return tostring(t[1]) -- ./compiler/lua53.can:446
end, -- ./compiler/lua53.can:446
["String"] = function(t) -- ./compiler/lua53.can:449
return ("%q"):format(t[1]) -- ./compiler/lua53.can:450
end, -- ./compiler/lua53.can:450
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:453
local r = "(" -- ./compiler/lua53.can:454
local decl = {} -- ./compiler/lua53.can:455
if t[1][1] then -- ./compiler/lua53.can:456
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:457
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:458
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:459
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:460
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:461
r = r .. (id) -- ./compiler/lua53.can:462
else -- ./compiler/lua53.can:462
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:464
end -- ./compiler/lua53.can:464
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:466
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:467
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:468
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:469
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:470
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:471
r = r .. (", " .. id) -- ./compiler/lua53.can:472
else -- ./compiler/lua53.can:472
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
r = r .. (")" .. indent()) -- ./compiler/lua53.can:478
for _, d in ipairs(decl) do -- ./compiler/lua53.can:479
r = r .. (d .. newline()) -- ./compiler/lua53.can:480
end -- ./compiler/lua53.can:480
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:482
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:483
end -- ./compiler/lua53.can:483
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:485
if hasPush then -- ./compiler/lua53.can:486
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:487
else -- ./compiler/lua53.can:487
push("push", false) -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:489
end -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:489
r = r .. (lua(t[2])) -- ./compiler/lua53.can:491
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:492
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
pop("push") -- ./compiler/lua53.can:495
return r .. unindent() .. "end" -- ./compiler/lua53.can:496
end, -- ./compiler/lua53.can:496
["Function"] = function(t) -- ./compiler/lua53.can:498
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:499
end, -- ./compiler/lua53.can:499
["Pair"] = function(t) -- ./compiler/lua53.can:502
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:503
end, -- ./compiler/lua53.can:503
["Table"] = function(t) -- ./compiler/lua53.can:505
if # t == 0 then -- ./compiler/lua53.can:506
return "{}" -- ./compiler/lua53.can:507
elseif # t == 1 then -- ./compiler/lua53.can:508
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:509
else -- ./compiler/lua53.can:509
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:511
end -- ./compiler/lua53.can:511
end, -- ./compiler/lua53.can:511
["TableCompr"] = function(t) -- ./compiler/lua53.can:515
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:516
end, -- ./compiler/lua53.can:516
["Op"] = function(t) -- ./compiler/lua53.can:519
local r -- ./compiler/lua53.can:520
if # t == 2 then -- ./compiler/lua53.can:521
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:522
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:523
else -- ./compiler/lua53.can:523
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:525
end -- ./compiler/lua53.can:525
else -- ./compiler/lua53.can:525
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:528
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:529
else -- ./compiler/lua53.can:529
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:531
end -- ./compiler/lua53.can:531
end -- ./compiler/lua53.can:531
return r -- ./compiler/lua53.can:534
end, -- ./compiler/lua53.can:534
["Paren"] = function(t) -- ./compiler/lua53.can:537
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:538
end, -- ./compiler/lua53.can:538
["MethodStub"] = function(t) -- ./compiler/lua53.can:541
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:547
end, -- ./compiler/lua53.can:547
["SafeMethodStub"] = function(t) -- ./compiler/lua53.can:550
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:557
end, -- ./compiler/lua53.can:557
["LetExpr"] = function(t) -- ./compiler/lua53.can:564
return lua(t[1][1]) -- ./compiler/lua53.can:565
end, -- ./compiler/lua53.can:565
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:569
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:570
local r = "(function()" .. indent() -- ./compiler/lua53.can:571
if hasPush then -- ./compiler/lua53.can:572
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:573
else -- ./compiler/lua53.can:573
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:575
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:575
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:577
if hasPush then -- ./compiler/lua53.can:578
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:579
end -- ./compiler/lua53.can:579
pop("push") -- ./compiler/lua53.can:581
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:582
return r -- ./compiler/lua53.can:583
end, -- ./compiler/lua53.can:583
["DoExpr"] = function(t) -- ./compiler/lua53.can:586
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:587
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:588
end -- ./compiler/lua53.can:588
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:590
end, -- ./compiler/lua53.can:590
["WhileExpr"] = function(t) -- ./compiler/lua53.can:593
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:594
end, -- ./compiler/lua53.can:594
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:597
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:598
end, -- ./compiler/lua53.can:598
["IfExpr"] = function(t) -- ./compiler/lua53.can:601
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:602
local block = t[i] -- ./compiler/lua53.can:603
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:604
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:605
end -- ./compiler/lua53.can:605
end -- ./compiler/lua53.can:605
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:608
end, -- ./compiler/lua53.can:608
["FornumExpr"] = function(t) -- ./compiler/lua53.can:611
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:612
end, -- ./compiler/lua53.can:612
["ForinExpr"] = function(t) -- ./compiler/lua53.can:615
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:616
end, -- ./compiler/lua53.can:616
["Call"] = function(t) -- ./compiler/lua53.can:622
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:623
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:624
elseif t[1]["tag"] == "MethodStub" then -- method call -- ./compiler/lua53.can:625
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua53.can:626
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:627
else -- ./compiler/lua53.can:627
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:629
end -- ./compiler/lua53.can:629
else -- ./compiler/lua53.can:629
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
end, -- ./compiler/lua53.can:632
["SafeCall"] = function(t) -- ./compiler/lua53.can:636
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:637
return lua(t, "SafeIndex") -- ./compiler/lua53.can:638
else -- ./compiler/lua53.can:638
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua53.can:640
end -- ./compiler/lua53.can:640
end, -- ./compiler/lua53.can:640
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:645
if start == nil then start = 1 end -- ./compiler/lua53.can:645
local r -- ./compiler/lua53.can:646
if t[start] then -- ./compiler/lua53.can:647
r = lua(t[start]) -- ./compiler/lua53.can:648
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:649
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:650
end -- ./compiler/lua53.can:650
else -- ./compiler/lua53.can:650
r = "" -- ./compiler/lua53.can:653
end -- ./compiler/lua53.can:653
return r -- ./compiler/lua53.can:655
end, -- ./compiler/lua53.can:655
["Id"] = function(t) -- ./compiler/lua53.can:658
return t[1] -- ./compiler/lua53.can:659
end, -- ./compiler/lua53.can:659
["Index"] = function(t) -- ./compiler/lua53.can:662
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:663
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:664
else -- ./compiler/lua53.can:664
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:666
end -- ./compiler/lua53.can:666
end, -- ./compiler/lua53.can:666
["SafeIndex"] = function(t) -- ./compiler/lua53.can:670
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:671
local l = {} -- list of immediately chained safeindex, from deepest to nearest (to simply generated code) -- ./compiler/lua53.can:672
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:673
table["insert"](l, 1, t) -- ./compiler/lua53.can:674
t = t[1] -- ./compiler/lua53.can:675
end -- ./compiler/lua53.can:675
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- base expr -- ./compiler/lua53.can:677
for _, e in ipairs(l) do -- ./compiler/lua53.can:678
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua53.can:679
if e["tag"] == "SafeIndex" then -- ./compiler/lua53.can:680
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua53.can:681
else -- ./compiler/lua53.can:681
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua53.can:683
end -- ./compiler/lua53.can:683
end -- ./compiler/lua53.can:683
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua53.can:686
return r -- ./compiler/lua53.can:687
else -- ./compiler/lua53.can:687
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua53.can:689
end -- ./compiler/lua53.can:689
end, -- ./compiler/lua53.can:689
["_opid"] = { -- ./compiler/lua53.can:694
["add"] = "+", -- ./compiler/lua53.can:695
["sub"] = "-", -- ./compiler/lua53.can:695
["mul"] = "*", -- ./compiler/lua53.can:695
["div"] = "/", -- ./compiler/lua53.can:695
["idiv"] = "//", -- ./compiler/lua53.can:696
["mod"] = "%", -- ./compiler/lua53.can:696
["pow"] = "^", -- ./compiler/lua53.can:696
["concat"] = "..", -- ./compiler/lua53.can:696
["band"] = "&", -- ./compiler/lua53.can:697
["bor"] = "|", -- ./compiler/lua53.can:697
["bxor"] = "~", -- ./compiler/lua53.can:697
["shl"] = "<<", -- ./compiler/lua53.can:697
["shr"] = ">>", -- ./compiler/lua53.can:697
["eq"] = "==", -- ./compiler/lua53.can:698
["ne"] = "~=", -- ./compiler/lua53.can:698
["lt"] = "<", -- ./compiler/lua53.can:698
["gt"] = ">", -- ./compiler/lua53.can:698
["le"] = "<=", -- ./compiler/lua53.can:698
["ge"] = ">=", -- ./compiler/lua53.can:698
["and"] = "and", -- ./compiler/lua53.can:699
["or"] = "or", -- ./compiler/lua53.can:699
["unm"] = "-", -- ./compiler/lua53.can:699
["len"] = "#", -- ./compiler/lua53.can:699
["bnot"] = "~", -- ./compiler/lua53.can:699
["not"] = "not" -- ./compiler/lua53.can:699
} -- ./compiler/lua53.can:699
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:702
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua53.can:703
end }) -- ./compiler/lua53.can:703
targetName = "luajit" -- ./compiler/luajit.can:1
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
local code = lua(ast) .. newline() -- ./compiler/lua53.can:709
return requireStr .. code -- ./compiler/lua53.can:710
end -- ./compiler/lua53.can:710
end -- ./compiler/lua53.can:710
local lua53 = _() or lua53 -- ./compiler/lua53.can:715
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
")):match("%-%- (.-)%:(%d+)\
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
local required = {} -- { ["module"] = true, ... } -- ./compiler/lua53.can:46
local requireStr = "" -- ./compiler/lua53.can:47
local function addRequire(mod, name, field) -- ./compiler/lua53.can:49
if not required[mod] then -- ./compiler/lua53.can:50
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"]) -- ./compiler/lua53.can:51
required[mod] = true -- ./compiler/lua53.can:52
end -- ./compiler/lua53.can:52
end -- ./compiler/lua53.can:52
local function var(name) -- ./compiler/lua53.can:58
return options["variablePrefix"] .. name -- ./compiler/lua53.can:59
end -- ./compiler/lua53.can:59
local loop = { -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"While", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Repeat", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Fornum", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"Forin", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"WhileExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"RepeatExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"FornumExpr", -- loops tags (can contain continue) -- ./compiler/lua53.can:63
"ForinExpr" -- loops tags (can contain continue) -- ./compiler/lua53.can:63
} -- loops tags (can contain continue) -- ./compiler/lua53.can:63
local func = { -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"Function", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"TableCompr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"DoExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"WhileExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"RepeatExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"IfExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"FornumExpr", -- function scope tags (can contain push) -- ./compiler/lua53.can:64
"ForinExpr" -- function scope tags (can contain push) -- ./compiler/lua53.can:64
} -- function scope tags (can contain push) -- ./compiler/lua53.can:64
local function any(list, tags, nofollow) -- ./compiler/lua53.can:68
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:68
local tagsCheck = {} -- ./compiler/lua53.can:69
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:70
tagsCheck[tag] = true -- ./compiler/lua53.can:71
end -- ./compiler/lua53.can:71
local nofollowCheck = {} -- ./compiler/lua53.can:73
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:74
nofollowCheck[tag] = true -- ./compiler/lua53.can:75
end -- ./compiler/lua53.can:75
for _, node in ipairs(list) do -- ./compiler/lua53.can:77
if type(node) == "table" then -- ./compiler/lua53.can:78
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:79
return node -- ./compiler/lua53.can:80
end -- ./compiler/lua53.can:80
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:82
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:83
if r then -- ./compiler/lua53.can:84
return r -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
end -- ./compiler/lua53.can:84
return nil -- ./compiler/lua53.can:88
end -- ./compiler/lua53.can:88
local function search(list, tags, nofollow) -- ./compiler/lua53.can:93
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:93
local tagsCheck = {} -- ./compiler/lua53.can:94
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:95
tagsCheck[tag] = true -- ./compiler/lua53.can:96
end -- ./compiler/lua53.can:96
local nofollowCheck = {} -- ./compiler/lua53.can:98
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:99
nofollowCheck[tag] = true -- ./compiler/lua53.can:100
end -- ./compiler/lua53.can:100
local found = {} -- ./compiler/lua53.can:102
for _, node in ipairs(list) do -- ./compiler/lua53.can:103
if type(node) == "table" then -- ./compiler/lua53.can:104
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:105
for _, n in ipairs(search(node, tags, nofollow)) do -- ./compiler/lua53.can:106
table["insert"](found, n) -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
end -- ./compiler/lua53.can:107
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:110
table["insert"](found, node) -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
end -- ./compiler/lua53.can:111
return found -- ./compiler/lua53.can:115
end -- ./compiler/lua53.can:115
local function all(list, tags) -- ./compiler/lua53.can:119
for _, node in ipairs(list) do -- ./compiler/lua53.can:120
local ok = false -- ./compiler/lua53.can:121
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:122
if node["tag"] == tag then -- ./compiler/lua53.can:123
ok = true -- ./compiler/lua53.can:124
break -- ./compiler/lua53.can:125
end -- ./compiler/lua53.can:125
end -- ./compiler/lua53.can:125
if not ok then -- ./compiler/lua53.can:128
return false -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
return true -- ./compiler/lua53.can:132
end -- ./compiler/lua53.can:132
local states = { ["push"] = {} } -- push stack variable names -- ./compiler/lua53.can:138
local function push(name, state) -- ./compiler/lua53.can:141
table["insert"](states[name], state) -- ./compiler/lua53.can:142
return "" -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
local function pop(name) -- ./compiler/lua53.can:146
table["remove"](states[name]) -- ./compiler/lua53.can:147
return "" -- ./compiler/lua53.can:148
end -- ./compiler/lua53.can:148
local function peek(name) -- ./compiler/lua53.can:151
return states[name][# states[name]] -- ./compiler/lua53.can:152
end -- ./compiler/lua53.can:152
local tags -- ./compiler/lua53.can:156
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:158
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:159
lastInputPos = ast["pos"] -- ./compiler/lua53.can:160
end -- ./compiler/lua53.can:160
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:162
end -- ./compiler/lua53.can:162
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:166
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:167
end -- ./compiler/lua53.can:167
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:169
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:170
end -- ./compiler/lua53.can:170
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:172
return "do" .. indent() -- ./compiler/lua53.can:173
end -- ./compiler/lua53.can:173
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:175
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:176
end -- ./compiler/lua53.can:176
tags = setmetatable({ -- ./compiler/lua53.can:180
["Block"] = function(t) -- ./compiler/lua53.can:182
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:183
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:184
hasPush["tag"] = "Return" -- ./compiler/lua53.can:185
hasPush = false -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
local r = "" -- ./compiler/lua53.can:188
if hasPush then -- ./compiler/lua53.can:189
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:190
end -- ./compiler/lua53.can:190
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:192
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:193
end -- ./compiler/lua53.can:193
if t[# t] then -- ./compiler/lua53.can:195
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:196
end -- ./compiler/lua53.can:196
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:198
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:199
end -- ./compiler/lua53.can:199
return r -- ./compiler/lua53.can:201
end, -- ./compiler/lua53.can:201
["Do"] = function(t) -- ./compiler/lua53.can:207
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:208
end, -- ./compiler/lua53.can:208
["Set"] = function(t) -- ./compiler/lua53.can:211
if # t == 2 then -- ./compiler/lua53.can:212
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs") -- ./compiler/lua53.can:213
elseif # t == 3 then -- ./compiler/lua53.can:214
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs") -- ./compiler/lua53.can:215
elseif # t == 4 then -- ./compiler/lua53.can:216
if t[3] == "=" then -- ./compiler/lua53.can:217
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:218
t[2], -- ./compiler/lua53.can:218
t[1][1], -- ./compiler/lua53.can:218
{ -- ./compiler/lua53.can:218
["tag"] = "Paren", -- ./compiler/lua53.can:218
t[4][1] -- ./compiler/lua53.can:218
} -- ./compiler/lua53.can:218
}, "Op") -- ./compiler/lua53.can:218
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:219
r = r .. (", " .. lua({ -- ./compiler/lua53.can:220
t[2], -- ./compiler/lua53.can:220
t[1][i], -- ./compiler/lua53.can:220
{ -- ./compiler/lua53.can:220
["tag"] = "Paren", -- ./compiler/lua53.can:220
t[4][i] -- ./compiler/lua53.can:220
} -- ./compiler/lua53.can:220
}, "Op")) -- ./compiler/lua53.can:220
end -- ./compiler/lua53.can:220
return r -- ./compiler/lua53.can:222
else -- ./compiler/lua53.can:222
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:224
t[3], -- ./compiler/lua53.can:224
{ -- ./compiler/lua53.can:224
["tag"] = "Paren", -- ./compiler/lua53.can:224
t[4][1] -- ./compiler/lua53.can:224
}, -- ./compiler/lua53.can:224
t[1][1] -- ./compiler/lua53.can:224
}, "Op") -- ./compiler/lua53.can:224
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:225
r = r .. (", " .. lua({ -- ./compiler/lua53.can:226
t[3], -- ./compiler/lua53.can:226
{ -- ./compiler/lua53.can:226
["tag"] = "Paren", -- ./compiler/lua53.can:226
t[4][i] -- ./compiler/lua53.can:226
}, -- ./compiler/lua53.can:226
t[1][i] -- ./compiler/lua53.can:226
}, "Op")) -- ./compiler/lua53.can:226
end -- ./compiler/lua53.can:226
return r -- ./compiler/lua53.can:228
end -- ./compiler/lua53.can:228
else -- ./compiler/lua53.can:228
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:231
t[2], -- ./compiler/lua53.can:231
t[1][1], -- ./compiler/lua53.can:231
{ -- ./compiler/lua53.can:231
["tag"] = "Op", -- ./compiler/lua53.can:231
t[4], -- ./compiler/lua53.can:231
{ -- ./compiler/lua53.can:231
["tag"] = "Paren", -- ./compiler/lua53.can:231
t[5][1] -- ./compiler/lua53.can:231
}, -- ./compiler/lua53.can:231
t[1][1] -- ./compiler/lua53.can:231
} -- ./compiler/lua53.can:231
}, "Op") -- ./compiler/lua53.can:231
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:232
r = r .. (", " .. lua({ -- ./compiler/lua53.can:233
t[2], -- ./compiler/lua53.can:233
t[1][i], -- ./compiler/lua53.can:233
{ -- ./compiler/lua53.can:233
["tag"] = "Op", -- ./compiler/lua53.can:233
t[4], -- ./compiler/lua53.can:233
{ -- ./compiler/lua53.can:233
["tag"] = "Paren", -- ./compiler/lua53.can:233
t[5][i] -- ./compiler/lua53.can:233
}, -- ./compiler/lua53.can:233
t[1][i] -- ./compiler/lua53.can:233
} -- ./compiler/lua53.can:233
}, "Op")) -- ./compiler/lua53.can:233
end -- ./compiler/lua53.can:233
return r -- ./compiler/lua53.can:235
end -- ./compiler/lua53.can:235
end, -- ./compiler/lua53.can:235
["While"] = function(t) -- ./compiler/lua53.can:239
local r = "" -- ./compiler/lua53.can:240
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:241
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:242
if # lets > 0 then -- ./compiler/lua53.can:243
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:244
for _, l in ipairs(lets) do -- ./compiler/lua53.can:245
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
end -- ./compiler/lua53.can:246
r = r .. ("while " .. lua(t[1]) .. " do" .. indent()) -- ./compiler/lua53.can:249
if # lets > 0 then -- ./compiler/lua53.can:250
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:251
end -- ./compiler/lua53.can:251
if hasContinue then -- ./compiler/lua53.can:253
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:254
end -- ./compiler/lua53.can:254
r = r .. (lua(t[2])) -- ./compiler/lua53.can:256
if hasContinue then -- ./compiler/lua53.can:257
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:258
end -- ./compiler/lua53.can:258
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:260
if # lets > 0 then -- ./compiler/lua53.can:261
for _, l in ipairs(lets) do -- ./compiler/lua53.can:262
r = r .. (newline() .. lua(l, "Set")) -- ./compiler/lua53.can:263
end -- ./compiler/lua53.can:263
r = r .. (unindent() .. "end" .. unindent() .. "end") -- ./compiler/lua53.can:265
end -- ./compiler/lua53.can:265
return r -- ./compiler/lua53.can:267
end, -- ./compiler/lua53.can:267
["Repeat"] = function(t) -- ./compiler/lua53.can:270
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:271
local r = "repeat" .. indent() -- ./compiler/lua53.can:272
if hasContinue then -- ./compiler/lua53.can:273
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:274
end -- ./compiler/lua53.can:274
r = r .. (lua(t[1])) -- ./compiler/lua53.can:276
if hasContinue then -- ./compiler/lua53.can:277
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:278
end -- ./compiler/lua53.can:278
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:280
return r -- ./compiler/lua53.can:281
end, -- ./compiler/lua53.can:281
["If"] = function(t) -- ./compiler/lua53.can:284
local r = "" -- ./compiler/lua53.can:285
local toClose = 0 -- blocks that need to be closed at the end of the if -- ./compiler/lua53.can:286
local lets = search({ t[1] }, { "LetExpr" }) -- ./compiler/lua53.can:287
if # lets > 0 then -- ./compiler/lua53.can:288
r = r .. ("do" .. indent()) -- ./compiler/lua53.can:289
toClose = toClose + (1) -- ./compiler/lua53.can:290
for _, l in ipairs(lets) do -- ./compiler/lua53.can:291
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:292
end -- ./compiler/lua53.can:292
end -- ./compiler/lua53.can:292
r = r .. ("if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()) -- ./compiler/lua53.can:295
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:296
lets = search({ t[i] }, { "LetExpr" }) -- ./compiler/lua53.can:297
if # lets > 0 then -- ./compiler/lua53.can:298
r = r .. ("else" .. indent()) -- ./compiler/lua53.can:299
toClose = toClose + (1) -- ./compiler/lua53.can:300
for _, l in ipairs(lets) do -- ./compiler/lua53.can:301
r = r .. (lua(l, "Let") .. newline()) -- ./compiler/lua53.can:302
end -- ./compiler/lua53.can:302
else -- ./compiler/lua53.can:302
r = r .. ("else") -- ./compiler/lua53.can:305
end -- ./compiler/lua53.can:305
r = r .. ("if " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:307
end -- ./compiler/lua53.can:307
if # t % 2 == 1 then -- ./compiler/lua53.can:309
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:310
end -- ./compiler/lua53.can:310
r = r .. ("end") -- ./compiler/lua53.can:312
for i = 1, toClose do -- ./compiler/lua53.can:313
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:314
end -- ./compiler/lua53.can:314
return r -- ./compiler/lua53.can:316
end, -- ./compiler/lua53.can:316
["Fornum"] = function(t) -- ./compiler/lua53.can:319
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:320
if # t == 5 then -- ./compiler/lua53.can:321
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:322
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:323
if hasContinue then -- ./compiler/lua53.can:324
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:325
end -- ./compiler/lua53.can:325
r = r .. (lua(t[5])) -- ./compiler/lua53.can:327
if hasContinue then -- ./compiler/lua53.can:328
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:329
end -- ./compiler/lua53.can:329
return r .. unindent() .. "end" -- ./compiler/lua53.can:331
else -- ./compiler/lua53.can:331
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:333
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:334
if hasContinue then -- ./compiler/lua53.can:335
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:336
end -- ./compiler/lua53.can:336
r = r .. (lua(t[4])) -- ./compiler/lua53.can:338
if hasContinue then -- ./compiler/lua53.can:339
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:340
end -- ./compiler/lua53.can:340
return r .. unindent() .. "end" -- ./compiler/lua53.can:342
end -- ./compiler/lua53.can:342
end, -- ./compiler/lua53.can:342
["Forin"] = function(t) -- ./compiler/lua53.can:346
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:347
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:348
if hasContinue then -- ./compiler/lua53.can:349
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:350
end -- ./compiler/lua53.can:350
r = r .. (lua(t[3])) -- ./compiler/lua53.can:352
if hasContinue then -- ./compiler/lua53.can:353
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:354
end -- ./compiler/lua53.can:354
return r .. unindent() .. "end" -- ./compiler/lua53.can:356
end, -- ./compiler/lua53.can:356
["Local"] = function(t) -- ./compiler/lua53.can:359
local r = "local " .. lua(t[1], "_lhs") -- ./compiler/lua53.can:360
if t[2][1] then -- ./compiler/lua53.can:361
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:362
end -- ./compiler/lua53.can:362
return r -- ./compiler/lua53.can:364
end, -- ./compiler/lua53.can:364
["Let"] = function(t) -- ./compiler/lua53.can:367
local nameList = lua(t[1], "_lhs") -- ./compiler/lua53.can:368
local r = "local " .. nameList -- ./compiler/lua53.can:369
if t[2][1] then -- ./compiler/lua53.can:370
if all(t[2], { -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Nil", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Dots", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Boolean", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"Number", -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
"String" -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
}) then -- predeclaration doesn't matter here -- ./compiler/lua53.can:371
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:372
else -- ./compiler/lua53.can:372
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:374
end -- ./compiler/lua53.can:374
end -- ./compiler/lua53.can:374
return r -- ./compiler/lua53.can:377
end, -- ./compiler/lua53.can:377
["Localrec"] = function(t) -- ./compiler/lua53.can:380
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:381
end, -- ./compiler/lua53.can:381
["Goto"] = function(t) -- ./compiler/lua53.can:384
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:385
end, -- ./compiler/lua53.can:385
["Label"] = function(t) -- ./compiler/lua53.can:388
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:389
end, -- ./compiler/lua53.can:389
["Return"] = function(t) -- ./compiler/lua53.can:392
local push = peek("push") -- ./compiler/lua53.can:393
if push then -- ./compiler/lua53.can:394
local r = "" -- ./compiler/lua53.can:395
for _, val in ipairs(t) do -- ./compiler/lua53.can:396
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:397
end -- ./compiler/lua53.can:397
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:399
else -- ./compiler/lua53.can:399
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:401
end -- ./compiler/lua53.can:401
end, -- ./compiler/lua53.can:401
["Push"] = function(t) -- ./compiler/lua53.can:405
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:406
r = "" -- ./compiler/lua53.can:407
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:408
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:409
end -- ./compiler/lua53.can:409
if t[# t] then -- ./compiler/lua53.can:411
if t[# t]["tag"] == "Call" then -- ./compiler/lua53.can:412
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:413
else -- ./compiler/lua53.can:413
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:415
end -- ./compiler/lua53.can:415
end -- ./compiler/lua53.can:415
return r -- ./compiler/lua53.can:418
end, -- ./compiler/lua53.can:418
["Break"] = function() -- ./compiler/lua53.can:421
return "break" -- ./compiler/lua53.can:422
end, -- ./compiler/lua53.can:422
["Continue"] = function() -- ./compiler/lua53.can:425
return "goto " .. var("continue") -- ./compiler/lua53.can:426
end, -- ./compiler/lua53.can:426
["Nil"] = function() -- ./compiler/lua53.can:433
return "nil" -- ./compiler/lua53.can:434
end, -- ./compiler/lua53.can:434
["Dots"] = function() -- ./compiler/lua53.can:437
return "..." -- ./compiler/lua53.can:438
end, -- ./compiler/lua53.can:438
["Boolean"] = function(t) -- ./compiler/lua53.can:441
return tostring(t[1]) -- ./compiler/lua53.can:442
end, -- ./compiler/lua53.can:442
["Number"] = function(t) -- ./compiler/lua53.can:445
return tostring(t[1]) -- ./compiler/lua53.can:446
end, -- ./compiler/lua53.can:446
["String"] = function(t) -- ./compiler/lua53.can:449
return ("%q"):format(t[1]) -- ./compiler/lua53.can:450
end, -- ./compiler/lua53.can:450
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:453
local r = "(" -- ./compiler/lua53.can:454
local decl = {} -- ./compiler/lua53.can:455
if t[1][1] then -- ./compiler/lua53.can:456
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:457
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:458
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:459
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:460
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:461
r = r .. (id) -- ./compiler/lua53.can:462
else -- ./compiler/lua53.can:462
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:464
end -- ./compiler/lua53.can:464
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:466
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:467
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:468
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:469
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:470
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:471
r = r .. (", " .. id) -- ./compiler/lua53.can:472
else -- ./compiler/lua53.can:472
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
end -- ./compiler/lua53.can:474
r = r .. (")" .. indent()) -- ./compiler/lua53.can:478
for _, d in ipairs(decl) do -- ./compiler/lua53.can:479
r = r .. (d .. newline()) -- ./compiler/lua53.can:480
end -- ./compiler/lua53.can:480
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:482
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:483
end -- ./compiler/lua53.can:483
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:485
if hasPush then -- ./compiler/lua53.can:486
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:487
else -- ./compiler/lua53.can:487
push("push", false) -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:489
end -- no push here (make sure higher push doesn't affect us) -- ./compiler/lua53.can:489
r = r .. (lua(t[2])) -- ./compiler/lua53.can:491
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:492
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
pop("push") -- ./compiler/lua53.can:495
return r .. unindent() .. "end" -- ./compiler/lua53.can:496
end, -- ./compiler/lua53.can:496
["Function"] = function(t) -- ./compiler/lua53.can:498
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:499
end, -- ./compiler/lua53.can:499
["Pair"] = function(t) -- ./compiler/lua53.can:502
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:503
end, -- ./compiler/lua53.can:503
["Table"] = function(t) -- ./compiler/lua53.can:505
if # t == 0 then -- ./compiler/lua53.can:506
return "{}" -- ./compiler/lua53.can:507
elseif # t == 1 then -- ./compiler/lua53.can:508
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:509
else -- ./compiler/lua53.can:509
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:511
end -- ./compiler/lua53.can:511
end, -- ./compiler/lua53.can:511
["TableCompr"] = function(t) -- ./compiler/lua53.can:515
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:516
end, -- ./compiler/lua53.can:516
["Op"] = function(t) -- ./compiler/lua53.can:519
local r -- ./compiler/lua53.can:520
if # t == 2 then -- ./compiler/lua53.can:521
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:522
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:523
else -- ./compiler/lua53.can:523
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:525
end -- ./compiler/lua53.can:525
else -- ./compiler/lua53.can:525
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:528
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:529
else -- ./compiler/lua53.can:529
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:531
end -- ./compiler/lua53.can:531
end -- ./compiler/lua53.can:531
return r -- ./compiler/lua53.can:534
end, -- ./compiler/lua53.can:534
["Paren"] = function(t) -- ./compiler/lua53.can:537
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:538
end, -- ./compiler/lua53.can:538
["MethodStub"] = function(t) -- ./compiler/lua53.can:541
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:547
end, -- ./compiler/lua53.can:547
["SafeMethodStub"] = function(t) -- ./compiler/lua53.can:550
return "(function()" .. indent() .. "local " .. var("object") .. " = " .. lua(t[1]) .. newline() .. "if " .. var("object") .. " == nil then return nil end" .. newline() .. "local " .. var("method") .. " = " .. var("object") .. "." .. lua(t[2], "Id") .. newline() .. "if " .. var("method") .. " == nil then return nil end" .. newline() .. "return function(...) return " .. var("method") .. "(" .. var("object") .. ", ...) end" .. unindent() .. "end)()" -- ./compiler/lua53.can:557
end, -- ./compiler/lua53.can:557
["LetExpr"] = function(t) -- ./compiler/lua53.can:564
return lua(t[1][1]) -- ./compiler/lua53.can:565
end, -- ./compiler/lua53.can:565
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:569
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:570
local r = "(function()" .. indent() -- ./compiler/lua53.can:571
if hasPush then -- ./compiler/lua53.can:572
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:573
else -- ./compiler/lua53.can:573
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:575
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:575
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:577
if hasPush then -- ./compiler/lua53.can:578
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:579
end -- ./compiler/lua53.can:579
pop("push") -- ./compiler/lua53.can:581
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:582
return r -- ./compiler/lua53.can:583
end, -- ./compiler/lua53.can:583
["DoExpr"] = function(t) -- ./compiler/lua53.can:586
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:587
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:588
end -- ./compiler/lua53.can:588
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:590
end, -- ./compiler/lua53.can:590
["WhileExpr"] = function(t) -- ./compiler/lua53.can:593
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:594
end, -- ./compiler/lua53.can:594
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:597
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:598
end, -- ./compiler/lua53.can:598
["IfExpr"] = function(t) -- ./compiler/lua53.can:601
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:602
local block = t[i] -- ./compiler/lua53.can:603
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:604
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:605
end -- ./compiler/lua53.can:605
end -- ./compiler/lua53.can:605
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:608
end, -- ./compiler/lua53.can:608
["FornumExpr"] = function(t) -- ./compiler/lua53.can:611
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:612
end, -- ./compiler/lua53.can:612
["ForinExpr"] = function(t) -- ./compiler/lua53.can:615
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:616
end, -- ./compiler/lua53.can:616
["Call"] = function(t) -- ./compiler/lua53.can:622
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:623
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:624
elseif t[1]["tag"] == "MethodStub" then -- method call -- ./compiler/lua53.can:625
if t[1][1]["tag"] == "String" or t[1][1]["tag"] == "Table" then -- ./compiler/lua53.can:626
return "(" .. lua(t[1][1]) .. "):" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:627
else -- ./compiler/lua53.can:627
return lua(t[1][1]) .. ":" .. lua(t[1][2], "Id") .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:629
end -- ./compiler/lua53.can:629
else -- ./compiler/lua53.can:629
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:632
end -- ./compiler/lua53.can:632
end, -- ./compiler/lua53.can:632
["SafeCall"] = function(t) -- ./compiler/lua53.can:636
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:637
return lua(t, "SafeIndex") -- ./compiler/lua53.can:638
else -- ./compiler/lua53.can:638
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ") or nil)" -- ./compiler/lua53.can:640
end -- ./compiler/lua53.can:640
end, -- ./compiler/lua53.can:640
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:645
if start == nil then start = 1 end -- ./compiler/lua53.can:645
local r -- ./compiler/lua53.can:646
if t[start] then -- ./compiler/lua53.can:647
r = lua(t[start]) -- ./compiler/lua53.can:648
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:649
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:650
end -- ./compiler/lua53.can:650
else -- ./compiler/lua53.can:650
r = "" -- ./compiler/lua53.can:653
end -- ./compiler/lua53.can:653
return r -- ./compiler/lua53.can:655
end, -- ./compiler/lua53.can:655
["Id"] = function(t) -- ./compiler/lua53.can:658
return t[1] -- ./compiler/lua53.can:659
end, -- ./compiler/lua53.can:659
["Index"] = function(t) -- ./compiler/lua53.can:662
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:663
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:664
else -- ./compiler/lua53.can:664
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:666
end -- ./compiler/lua53.can:666
end, -- ./compiler/lua53.can:666
["SafeIndex"] = function(t) -- ./compiler/lua53.can:670
if t[1]["tag"] ~= "Id" then -- side effect possible, only evaluate each expr once (or already in a safe context) -- ./compiler/lua53.can:671
local l = {} -- list of immediately chained safeindex, from deepest to nearest (to simply generated code) -- ./compiler/lua53.can:672
while t["tag"] == "SafeIndex" or t["tag"] == "SafeCall" do -- ./compiler/lua53.can:673
table["insert"](l, 1, t) -- ./compiler/lua53.can:674
t = t[1] -- ./compiler/lua53.can:675
end -- ./compiler/lua53.can:675
local r = "(function()" .. indent() .. "local " .. var("safe") .. " = " .. lua(l[1][1]) .. newline() -- base expr -- ./compiler/lua53.can:677
for _, e in ipairs(l) do -- ./compiler/lua53.can:678
r = r .. ("if " .. var("safe") .. " == nil then return nil end" .. newline()) -- ./compiler/lua53.can:679
if e["tag"] == "SafeIndex" then -- ./compiler/lua53.can:680
r = r .. (var("safe") .. " = " .. var("safe") .. "[" .. lua(e[2]) .. "]" .. newline()) -- ./compiler/lua53.can:681
else -- ./compiler/lua53.can:681
r = r .. (var("safe") .. " = " .. var("safe") .. "(" .. lua(e, "_lhs", 2) .. ")" .. newline()) -- ./compiler/lua53.can:683
end -- ./compiler/lua53.can:683
end -- ./compiler/lua53.can:683
r = r .. ("return " .. var("safe") .. unindent() .. "end)()") -- ./compiler/lua53.can:686
return r -- ./compiler/lua53.can:687
else -- ./compiler/lua53.can:687
return "(" .. lua(t[1]) .. " ~= nil and " .. lua(t[1]) .. "[" .. lua(t[2]) .. "] or nil)" -- ./compiler/lua53.can:689
end -- ./compiler/lua53.can:689
end, -- ./compiler/lua53.can:689
["_opid"] = { -- ./compiler/lua53.can:694
["add"] = "+", -- ./compiler/lua53.can:695
["sub"] = "-", -- ./compiler/lua53.can:695
["mul"] = "*", -- ./compiler/lua53.can:695
["div"] = "/", -- ./compiler/lua53.can:695
["idiv"] = "//", -- ./compiler/lua53.can:696
["mod"] = "%", -- ./compiler/lua53.can:696
["pow"] = "^", -- ./compiler/lua53.can:696
["concat"] = "..", -- ./compiler/lua53.can:696
["band"] = "&", -- ./compiler/lua53.can:697
["bor"] = "|", -- ./compiler/lua53.can:697
["bxor"] = "~", -- ./compiler/lua53.can:697
["shl"] = "<<", -- ./compiler/lua53.can:697
["shr"] = ">>", -- ./compiler/lua53.can:697
["eq"] = "==", -- ./compiler/lua53.can:698
["ne"] = "~=", -- ./compiler/lua53.can:698
["lt"] = "<", -- ./compiler/lua53.can:698
["gt"] = ">", -- ./compiler/lua53.can:698
["le"] = "<=", -- ./compiler/lua53.can:698
["ge"] = ">=", -- ./compiler/lua53.can:698
["and"] = "and", -- ./compiler/lua53.can:699
["or"] = "or", -- ./compiler/lua53.can:699
["unm"] = "-", -- ./compiler/lua53.can:699
["len"] = "#", -- ./compiler/lua53.can:699
["bnot"] = "~", -- ./compiler/lua53.can:699
["not"] = "not" -- ./compiler/lua53.can:699
} -- ./compiler/lua53.can:699
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:702
error("don't know how to compile a " .. tostring(key) .. " to " .. targetName) -- ./compiler/lua53.can:703
end }) -- ./compiler/lua53.can:703
targetName = "luajit" -- ./compiler/luajit.can:1
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
local code = lua(ast) .. newline() -- ./compiler/lua53.can:709
return requireStr .. code -- ./compiler/lua53.can:710
end -- ./compiler/lua53.can:710
end -- ./compiler/lua53.can:710
local lua53 = _() or lua53 -- ./compiler/lua53.can:715
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
else -- ./lib/lua-parser/validator.lua:306
error("expecting a variable, but got a " .. tag) -- ./lib/lua-parser/validator.lua:308
end -- ./lib/lua-parser/validator.lua:308
end -- ./lib/lua-parser/validator.lua:308
traverse_varlist = function(env, varlist) -- ./lib/lua-parser/validator.lua:312
for k, v in ipairs(varlist) do -- ./lib/lua-parser/validator.lua:313
local status, msg = traverse_var(env, v) -- ./lib/lua-parser/validator.lua:314
if not status then -- ./lib/lua-parser/validator.lua:315
return status, msg -- ./lib/lua-parser/validator.lua:315
end -- ./lib/lua-parser/validator.lua:315
end -- ./lib/lua-parser/validator.lua:315
return true -- ./lib/lua-parser/validator.lua:317
end -- ./lib/lua-parser/validator.lua:317
local function traverse_methodstub(env, var) -- ./lib/lua-parser/validator.lua:320
local status, msg = traverse_exp(env, var[1]) -- ./lib/lua-parser/validator.lua:321
if not status then -- ./lib/lua-parser/validator.lua:322
return status, msg -- ./lib/lua-parser/validator.lua:322
end -- ./lib/lua-parser/validator.lua:322
status, msg = traverse_exp(env, var[2]) -- ./lib/lua-parser/validator.lua:323
if not status then -- ./lib/lua-parser/validator.lua:324
return status, msg -- ./lib/lua-parser/validator.lua:324
end -- ./lib/lua-parser/validator.lua:324
return true -- ./lib/lua-parser/validator.lua:325
end -- ./lib/lua-parser/validator.lua:325
local function traverse_safeindex(env, var) -- ./lib/lua-parser/validator.lua:328
local status, msg = traverse_exp(env, var[1]) -- ./lib/lua-parser/validator.lua:329
if not status then -- ./lib/lua-parser/validator.lua:330
return status, msg -- ./lib/lua-parser/validator.lua:330
end -- ./lib/lua-parser/validator.lua:330
status, msg = traverse_exp(env, var[2]) -- ./lib/lua-parser/validator.lua:331
if not status then -- ./lib/lua-parser/validator.lua:332
return status, msg -- ./lib/lua-parser/validator.lua:332
end -- ./lib/lua-parser/validator.lua:332
return true -- ./lib/lua-parser/validator.lua:333
end -- ./lib/lua-parser/validator.lua:333
traverse_exp = function(env, exp) -- ./lib/lua-parser/validator.lua:336
local tag = exp["tag"] -- ./lib/lua-parser/validator.lua:337
if tag == "Nil" or tag == "Boolean" or tag == "Number" or tag == "String" then -- `String{ <string> } -- ./lib/lua-parser/validator.lua:341
return true -- ./lib/lua-parser/validator.lua:342
elseif tag == "Dots" then -- ./lib/lua-parser/validator.lua:343
return traverse_vararg(env, exp) -- ./lib/lua-parser/validator.lua:344
elseif tag == "Function" then -- `Function{ { `Id{ <string> }* `Dots? } block } -- ./lib/lua-parser/validator.lua:345
return traverse_function(env, exp) -- ./lib/lua-parser/validator.lua:346
elseif tag == "Table" then -- `Table{ ( `Pair{ expr expr } | expr )* } -- ./lib/lua-parser/validator.lua:347
return traverse_table(env, exp) -- ./lib/lua-parser/validator.lua:348
elseif tag == "Op" then -- `Op{ opid expr expr? } -- ./lib/lua-parser/validator.lua:349
return traverse_op(env, exp) -- ./lib/lua-parser/validator.lua:350
elseif tag == "Paren" then -- `Paren{ expr } -- ./lib/lua-parser/validator.lua:351
return traverse_paren(env, exp) -- ./lib/lua-parser/validator.lua:352
elseif tag == "Call" or tag == "SafeCall" then -- `(Safe)Call{ expr expr* } -- ./lib/lua-parser/validator.lua:353
return traverse_call(env, exp) -- ./lib/lua-parser/validator.lua:354
elseif tag == "Id" or tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/validator.lua:356
return traverse_var(env, exp) -- ./lib/lua-parser/validator.lua:357
elseif tag == "SafeIndex" then -- `SafeIndex{ expr expr } -- ./lib/lua-parser/validator.lua:358
return traverse_safeindex(env, exp) -- ./lib/lua-parser/validator.lua:359
elseif tag == "TableCompr" then -- `TableCompr{ block } -- ./lib/lua-parser/validator.lua:360
return traverse_tablecompr(env, exp) -- ./lib/lua-parser/validator.lua:361
elseif tag == "MethodStub" or tag == "SafeMethodStub" then -- `(Safe)MethodStub{ expr expr } -- ./lib/lua-parser/validator.lua:362
return traverse_methodstub(env, exp) -- ./lib/lua-parser/validator.lua:363
elseif tag:match("Expr$") then -- `StatExpr{ ... } -- ./lib/lua-parser/validator.lua:364
return traverse_statexpr(env, exp) -- ./lib/lua-parser/validator.lua:365
else -- ./lib/lua-parser/validator.lua:365
error("expecting an expression, but got a " .. tag) -- ./lib/lua-parser/validator.lua:367
end -- ./lib/lua-parser/validator.lua:367
end -- ./lib/lua-parser/validator.lua:367
traverse_explist = function(env, explist) -- ./lib/lua-parser/validator.lua:371
for k, v in ipairs(explist) do -- ./lib/lua-parser/validator.lua:372
local status, msg = traverse_exp(env, v) -- ./lib/lua-parser/validator.lua:373
if not status then -- ./lib/lua-parser/validator.lua:374
return status, msg -- ./lib/lua-parser/validator.lua:374
end -- ./lib/lua-parser/validator.lua:374
end -- ./lib/lua-parser/validator.lua:374
return true -- ./lib/lua-parser/validator.lua:376
end -- ./lib/lua-parser/validator.lua:376
traverse_stm = function(env, stm) -- ./lib/lua-parser/validator.lua:379
local tag = stm["tag"] -- ./lib/lua-parser/validator.lua:380
if tag == "Do" then -- `Do{ stat* } -- ./lib/lua-parser/validator.lua:381
return traverse_block(env, stm) -- ./lib/lua-parser/validator.lua:382
elseif tag == "Set" then -- `Set{ {lhs+} (opid? = opid?)? {expr+} } -- ./lib/lua-parser/validator.lua:383
return traverse_assignment(env, stm) -- ./lib/lua-parser/validator.lua:384
elseif tag == "While" then -- `While{ expr block } -- ./lib/lua-parser/validator.lua:385
return traverse_while(env, stm) -- ./lib/lua-parser/validator.lua:386
elseif tag == "Repeat" then -- `Repeat{ block expr } -- ./lib/lua-parser/validator.lua:387
return traverse_repeat(env, stm) -- ./lib/lua-parser/validator.lua:388
elseif tag == "If" then -- `If{ (expr block)+ block? } -- ./lib/lua-parser/validator.lua:389
return traverse_if(env, stm) -- ./lib/lua-parser/validator.lua:390
elseif tag == "Fornum" then -- `Fornum{ ident expr expr expr? block } -- ./lib/lua-parser/validator.lua:391
return traverse_fornum(env, stm) -- ./lib/lua-parser/validator.lua:392
elseif tag == "Forin" then -- `Forin{ {ident+} {expr+} block } -- ./lib/lua-parser/validator.lua:393
return traverse_forin(env, stm) -- ./lib/lua-parser/validator.lua:394
elseif tag == "Local" or tag == "Let" then -- `Let{ {ident+} {expr+}? } -- ./lib/lua-parser/validator.lua:396
return traverse_let(env, stm) -- ./lib/lua-parser/validator.lua:397
elseif tag == "Localrec" then -- `Localrec{ ident expr } -- ./lib/lua-parser/validator.lua:398
return traverse_letrec(env, stm) -- ./lib/lua-parser/validator.lua:399
elseif tag == "Goto" then -- `Goto{ <string> } -- ./lib/lua-parser/validator.lua:400
return traverse_goto(env, stm) -- ./lib/lua-parser/validator.lua:401
elseif tag == "Label" then -- `Label{ <string> } -- ./lib/lua-parser/validator.lua:402
return traverse_label(env, stm) -- ./lib/lua-parser/validator.lua:403
elseif tag == "Return" then -- `Return{ <expr>* } -- ./lib/lua-parser/validator.lua:404
return traverse_return(env, stm) -- ./lib/lua-parser/validator.lua:405
elseif tag == "Break" then -- ./lib/lua-parser/validator.lua:406
return traverse_break(env, stm) -- ./lib/lua-parser/validator.lua:407
elseif tag == "Call" then -- `Call{ expr expr* } -- ./lib/lua-parser/validator.lua:408
return traverse_call(env, stm) -- ./lib/lua-parser/validator.lua:409
elseif tag == "Continue" then -- ./lib/lua-parser/validator.lua:410
return traverse_continue(env, stm) -- ./lib/lua-parser/validator.lua:411
elseif tag == "Push" then -- `Push{ <expr>* } -- ./lib/lua-parser/validator.lua:412
return traverse_push(env, stm) -- ./lib/lua-parser/validator.lua:413
else -- ./lib/lua-parser/validator.lua:413
error("expecting a statement, but got a " .. tag) -- ./lib/lua-parser/validator.lua:415
end -- ./lib/lua-parser/validator.lua:415
end -- ./lib/lua-parser/validator.lua:415
traverse_block = function(env, block) -- ./lib/lua-parser/validator.lua:419
local l = {} -- ./lib/lua-parser/validator.lua:420
new_scope(env) -- ./lib/lua-parser/validator.lua:421
for k, v in ipairs(block) do -- ./lib/lua-parser/validator.lua:422
local status, msg = traverse_stm(env, v) -- ./lib/lua-parser/validator.lua:423
if not status then -- ./lib/lua-parser/validator.lua:424
return status, msg -- ./lib/lua-parser/validator.lua:424
end -- ./lib/lua-parser/validator.lua:424
end -- ./lib/lua-parser/validator.lua:424
end_scope(env) -- ./lib/lua-parser/validator.lua:426
return true -- ./lib/lua-parser/validator.lua:427
end -- ./lib/lua-parser/validator.lua:427
local function traverse(ast, errorinfo) -- ./lib/lua-parser/validator.lua:431
assert(type(ast) == "table") -- ./lib/lua-parser/validator.lua:432
assert(type(errorinfo) == "table") -- ./lib/lua-parser/validator.lua:433
local env = { -- ./lib/lua-parser/validator.lua:434
["errorinfo"] = errorinfo, -- ./lib/lua-parser/validator.lua:434
["function"] = {} -- ./lib/lua-parser/validator.lua:434
} -- ./lib/lua-parser/validator.lua:434
new_function(env) -- ./lib/lua-parser/validator.lua:435
set_vararg(env, true) -- ./lib/lua-parser/validator.lua:436
local status, msg = traverse_block(env, ast) -- ./lib/lua-parser/validator.lua:437
if not status then -- ./lib/lua-parser/validator.lua:438
return status, msg -- ./lib/lua-parser/validator.lua:438
end -- ./lib/lua-parser/validator.lua:438
end_function(env) -- ./lib/lua-parser/validator.lua:439
status, msg = verify_pending_gotos(env) -- ./lib/lua-parser/validator.lua:440
if not status then -- ./lib/lua-parser/validator.lua:441
return status, msg -- ./lib/lua-parser/validator.lua:441
end -- ./lib/lua-parser/validator.lua:441
return ast -- ./lib/lua-parser/validator.lua:442
end -- ./lib/lua-parser/validator.lua:442
return { -- ./lib/lua-parser/validator.lua:445
["validate"] = traverse, -- ./lib/lua-parser/validator.lua:445
["syntaxerror"] = syntaxerror -- ./lib/lua-parser/validator.lua:445
} -- ./lib/lua-parser/validator.lua:445
end -- ./lib/lua-parser/validator.lua:445
local validator = _() or validator -- ./lib/lua-parser/validator.lua:449
package["loaded"]["lib.lua-parser.validator"] = validator or true -- ./lib/lua-parser/validator.lua:450
local function _() -- ./lib/lua-parser/validator.lua:453
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
"ErrCBracketTableCompr", -- ./lib/lua-parser/parser.lua:167
"expected ']' to close the table comprehension" -- ./lib/lua-parser/parser.lua:167
}, -- ./lib/lua-parser/parser.lua:167
{ -- ./lib/lua-parser/parser.lua:169
"ErrDigitHex", -- ./lib/lua-parser/parser.lua:169
"expected one or more hexadecimal digits after '0x'" -- ./lib/lua-parser/parser.lua:169
}, -- ./lib/lua-parser/parser.lua:169
{ -- ./lib/lua-parser/parser.lua:170
"ErrDigitDeci", -- ./lib/lua-parser/parser.lua:170
"expected one or more digits after the decimal point" -- ./lib/lua-parser/parser.lua:170
}, -- ./lib/lua-parser/parser.lua:170
{ -- ./lib/lua-parser/parser.lua:171
"ErrDigitExpo", -- ./lib/lua-parser/parser.lua:171
"expected one or more digits for the exponent" -- ./lib/lua-parser/parser.lua:171
}, -- ./lib/lua-parser/parser.lua:171
{ -- ./lib/lua-parser/parser.lua:173
"ErrQuote", -- ./lib/lua-parser/parser.lua:173
"unclosed string" -- ./lib/lua-parser/parser.lua:173
}, -- ./lib/lua-parser/parser.lua:173
{ -- ./lib/lua-parser/parser.lua:174
"ErrHexEsc", -- ./lib/lua-parser/parser.lua:174
"expected exactly two hexadecimal digits after '\\x'" -- ./lib/lua-parser/parser.lua:174
}, -- ./lib/lua-parser/parser.lua:174
{ -- ./lib/lua-parser/parser.lua:175
"ErrOBraceUEsc", -- ./lib/lua-parser/parser.lua:175
"expected '{' after '\\u'" -- ./lib/lua-parser/parser.lua:175
}, -- ./lib/lua-parser/parser.lua:175
{ -- ./lib/lua-parser/parser.lua:176
"ErrDigitUEsc", -- ./lib/lua-parser/parser.lua:176
"expected one or more hexadecimal digits for the UTF-8 code point" -- ./lib/lua-parser/parser.lua:176
}, -- ./lib/lua-parser/parser.lua:176
{ -- ./lib/lua-parser/parser.lua:177
"ErrCBraceUEsc", -- ./lib/lua-parser/parser.lua:177
"expected '}' after the code point" -- ./lib/lua-parser/parser.lua:177
}, -- ./lib/lua-parser/parser.lua:177
{ -- ./lib/lua-parser/parser.lua:178
"ErrEscSeq", -- ./lib/lua-parser/parser.lua:178
"invalid escape sequence" -- ./lib/lua-parser/parser.lua:178
}, -- ./lib/lua-parser/parser.lua:178
{ -- ./lib/lua-parser/parser.lua:179
"ErrCloseLStr", -- ./lib/lua-parser/parser.lua:179
"unclosed long string" -- ./lib/lua-parser/parser.lua:179
} -- ./lib/lua-parser/parser.lua:179
} -- ./lib/lua-parser/parser.lua:179
local function throw(label) -- ./lib/lua-parser/parser.lua:182
label = "Err" .. label -- ./lib/lua-parser/parser.lua:183
for i, labelinfo in ipairs(labels) do -- ./lib/lua-parser/parser.lua:184
if labelinfo[1] == label then -- ./lib/lua-parser/parser.lua:185
return T(i) -- ./lib/lua-parser/parser.lua:186
end -- ./lib/lua-parser/parser.lua:186
end -- ./lib/lua-parser/parser.lua:186
error("Label not found: " .. label) -- ./lib/lua-parser/parser.lua:190
end -- ./lib/lua-parser/parser.lua:190
local function expect(patt, label) -- ./lib/lua-parser/parser.lua:193
return patt + throw(label) -- ./lib/lua-parser/parser.lua:194
end -- ./lib/lua-parser/parser.lua:194
local function token(patt) -- ./lib/lua-parser/parser.lua:200
return patt * V("Skip") -- ./lib/lua-parser/parser.lua:201
end -- ./lib/lua-parser/parser.lua:201
local function sym(str) -- ./lib/lua-parser/parser.lua:204
return token(P(str)) -- ./lib/lua-parser/parser.lua:205
end -- ./lib/lua-parser/parser.lua:205
local function kw(str) -- ./lib/lua-parser/parser.lua:208
return token(P(str) * - V("IdRest")) -- ./lib/lua-parser/parser.lua:209
end -- ./lib/lua-parser/parser.lua:209
local function tagC(tag, patt) -- ./lib/lua-parser/parser.lua:212
return Ct(Cg(Cp(), "pos") * Cg(Cc(tag), "tag") * patt) -- ./lib/lua-parser/parser.lua:213
end -- ./lib/lua-parser/parser.lua:213
local function unaryOp(op, e) -- ./lib/lua-parser/parser.lua:216
return { -- ./lib/lua-parser/parser.lua:217
["tag"] = "Op", -- ./lib/lua-parser/parser.lua:217
["pos"] = e["pos"], -- ./lib/lua-parser/parser.lua:217
[1] = op, -- ./lib/lua-parser/parser.lua:217
[2] = e -- ./lib/lua-parser/parser.lua:217
} -- ./lib/lua-parser/parser.lua:217
end -- ./lib/lua-parser/parser.lua:217
local function binaryOp(e1, op, e2) -- ./lib/lua-parser/parser.lua:220
if not op then -- ./lib/lua-parser/parser.lua:221
return e1 -- ./lib/lua-parser/parser.lua:222
else -- ./lib/lua-parser/parser.lua:222
return { -- ./lib/lua-parser/parser.lua:224
["tag"] = "Op", -- ./lib/lua-parser/parser.lua:224
["pos"] = e1["pos"], -- ./lib/lua-parser/parser.lua:224
[1] = op, -- ./lib/lua-parser/parser.lua:224
[2] = e1, -- ./lib/lua-parser/parser.lua:224
[3] = e2 -- ./lib/lua-parser/parser.lua:224
} -- ./lib/lua-parser/parser.lua:224
end -- ./lib/lua-parser/parser.lua:224
end -- ./lib/lua-parser/parser.lua:224
local function sepBy(patt, sep, label) -- ./lib/lua-parser/parser.lua:228
if label then -- ./lib/lua-parser/parser.lua:229
return patt * Cg(sep * expect(patt, label)) ^ 0 -- ./lib/lua-parser/parser.lua:230
else -- ./lib/lua-parser/parser.lua:230
return patt * Cg(sep * patt) ^ 0 -- ./lib/lua-parser/parser.lua:232
end -- ./lib/lua-parser/parser.lua:232
end -- ./lib/lua-parser/parser.lua:232
local function chainOp(patt, sep, label) -- ./lib/lua-parser/parser.lua:236
return Cf(sepBy(patt, sep, label), binaryOp) -- ./lib/lua-parser/parser.lua:237
end -- ./lib/lua-parser/parser.lua:237
local function commaSep(patt, label) -- ./lib/lua-parser/parser.lua:240
return sepBy(patt, sym(","), label) -- ./lib/lua-parser/parser.lua:241
end -- ./lib/lua-parser/parser.lua:241
local function tagDo(block) -- ./lib/lua-parser/parser.lua:244
block["tag"] = "Do" -- ./lib/lua-parser/parser.lua:245
return block -- ./lib/lua-parser/parser.lua:246
end -- ./lib/lua-parser/parser.lua:246
local function fixFuncStat(func) -- ./lib/lua-parser/parser.lua:249
if func[1]["is_method"] then -- ./lib/lua-parser/parser.lua:250
table["insert"](func[2][1], 1, { -- ./lib/lua-parser/parser.lua:250
["tag"] = "Id", -- ./lib/lua-parser/parser.lua:250
[1] = "self" -- ./lib/lua-parser/parser.lua:250
}) -- ./lib/lua-parser/parser.lua:250
end -- ./lib/lua-parser/parser.lua:250
func[1] = { func[1] } -- ./lib/lua-parser/parser.lua:251
func[2] = { func[2] } -- ./lib/lua-parser/parser.lua:252
return func -- ./lib/lua-parser/parser.lua:253
end -- ./lib/lua-parser/parser.lua:253
local function addDots(params, dots) -- ./lib/lua-parser/parser.lua:256
if dots then -- ./lib/lua-parser/parser.lua:257
table["insert"](params, dots) -- ./lib/lua-parser/parser.lua:257
end -- ./lib/lua-parser/parser.lua:257
return params -- ./lib/lua-parser/parser.lua:258
end -- ./lib/lua-parser/parser.lua:258
local function insertIndex(t, index) -- ./lib/lua-parser/parser.lua:261
return { -- ./lib/lua-parser/parser.lua:262
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:262
["pos"] = t["pos"], -- ./lib/lua-parser/parser.lua:262
[1] = t, -- ./lib/lua-parser/parser.lua:262
[2] = index -- ./lib/lua-parser/parser.lua:262
} -- ./lib/lua-parser/parser.lua:262
end -- ./lib/lua-parser/parser.lua:262
local function markMethod(t, method) -- ./lib/lua-parser/parser.lua:265
if method then -- ./lib/lua-parser/parser.lua:266
return { -- ./lib/lua-parser/parser.lua:267
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:267
["pos"] = t["pos"], -- ./lib/lua-parser/parser.lua:267
["is_method"] = true, -- ./lib/lua-parser/parser.lua:267
[1] = t, -- ./lib/lua-parser/parser.lua:267
[2] = method -- ./lib/lua-parser/parser.lua:267
} -- ./lib/lua-parser/parser.lua:267
end -- ./lib/lua-parser/parser.lua:267
return t -- ./lib/lua-parser/parser.lua:269
end -- ./lib/lua-parser/parser.lua:269
local function makeSuffixedExpr(t1, t2) -- ./lib/lua-parser/parser.lua:272
if t2["tag"] == "Call" or t2["tag"] == "SafeCall" then -- ./lib/lua-parser/parser.lua:273
local t = { -- ./lib/lua-parser/parser.lua:274
["tag"] = t2["tag"], -- ./lib/lua-parser/parser.lua:274
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:274
[1] = t1 -- ./lib/lua-parser/parser.lua:274
} -- ./lib/lua-parser/parser.lua:274
for k, v in ipairs(t2) do -- ./lib/lua-parser/parser.lua:275
table["insert"](t, v) -- ./lib/lua-parser/parser.lua:276
end -- ./lib/lua-parser/parser.lua:276
return t -- ./lib/lua-parser/parser.lua:278
elseif t2["tag"] == "MethodStub" or t2["tag"] == "SafeMethodStub" then -- ./lib/lua-parser/parser.lua:279
return { -- ./lib/lua-parser/parser.lua:280
["tag"] = t2["tag"], -- ./lib/lua-parser/parser.lua:280
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:280
[1] = t1, -- ./lib/lua-parser/parser.lua:280
[2] = t2[1] -- ./lib/lua-parser/parser.lua:280
} -- ./lib/lua-parser/parser.lua:280
elseif t2["tag"] == "SafeDotIndex" or t2["tag"] == "SafeArrayIndex" then -- ./lib/lua-parser/parser.lua:281
return { -- ./lib/lua-parser/parser.lua:282
["tag"] = "SafeIndex", -- ./lib/lua-parser/parser.lua:282
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:282
[1] = t1, -- ./lib/lua-parser/parser.lua:282
[2] = t2[1] -- ./lib/lua-parser/parser.lua:282
} -- ./lib/lua-parser/parser.lua:282
elseif t2["tag"] == "DotIndex" or t2["tag"] == "ArrayIndex" then -- ./lib/lua-parser/parser.lua:283
return { -- ./lib/lua-parser/parser.lua:284
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:284
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:284
[1] = t1, -- ./lib/lua-parser/parser.lua:284
[2] = t2[1] -- ./lib/lua-parser/parser.lua:284
} -- ./lib/lua-parser/parser.lua:284
else -- ./lib/lua-parser/parser.lua:284
error("unexpected tag in suffixed expression") -- ./lib/lua-parser/parser.lua:286
end -- ./lib/lua-parser/parser.lua:286
end -- ./lib/lua-parser/parser.lua:286
local function fixShortFunc(t) -- ./lib/lua-parser/parser.lua:290
if t[1] == ":" then -- self method -- ./lib/lua-parser/parser.lua:291
table["insert"](t[2], 1, { -- ./lib/lua-parser/parser.lua:292
["tag"] = "Id", -- ./lib/lua-parser/parser.lua:292
"self" -- ./lib/lua-parser/parser.lua:292
}) -- ./lib/lua-parser/parser.lua:292
table["remove"](t, 1) -- ./lib/lua-parser/parser.lua:293
t["is_method"] = true -- ./lib/lua-parser/parser.lua:294
end -- ./lib/lua-parser/parser.lua:294
t["is_short"] = true -- ./lib/lua-parser/parser.lua:296
return t -- ./lib/lua-parser/parser.lua:297
end -- ./lib/lua-parser/parser.lua:297
local function statToExpr(t) -- tag a StatExpr -- ./lib/lua-parser/parser.lua:300
t["tag"] = t["tag"] .. "Expr" -- ./lib/lua-parser/parser.lua:301
return t -- ./lib/lua-parser/parser.lua:302
end -- ./lib/lua-parser/parser.lua:302
local function fixStructure(t) -- fix the AST structure if needed -- ./lib/lua-parser/parser.lua:305
local i = 1 -- ./lib/lua-parser/parser.lua:306
while i <= # t do -- ./lib/lua-parser/parser.lua:307
if type(t[i]) == "table" then -- ./lib/lua-parser/parser.lua:308
fixStructure(t[i]) -- ./lib/lua-parser/parser.lua:309
for j = # t[i], 1, - 1 do -- ./lib/lua-parser/parser.lua:310
local stat = t[i][j] -- ./lib/lua-parser/parser.lua:311
if type(stat) == "table" and stat["move_up_block"] and stat["move_up_block"] > 0 then -- ./lib/lua-parser/parser.lua:312
table["remove"](t[i], j) -- ./lib/lua-parser/parser.lua:313
table["insert"](t, i + 1, stat) -- ./lib/lua-parser/parser.lua:314
if t["tag"] == "Block" or t["tag"] == "Do" then -- ./lib/lua-parser/parser.lua:315
stat["move_up_block"] = stat["move_up_block"] - 1 -- ./lib/lua-parser/parser.lua:316
end -- ./lib/lua-parser/parser.lua:316
end -- ./lib/lua-parser/parser.lua:316
end -- ./lib/lua-parser/parser.lua:316
end -- ./lib/lua-parser/parser.lua:316
i = i + 1 -- ./lib/lua-parser/parser.lua:321
end -- ./lib/lua-parser/parser.lua:321
return t -- ./lib/lua-parser/parser.lua:323
end -- ./lib/lua-parser/parser.lua:323
local function searchEndRec(block, isRecCall) -- recursively search potential "end" keyword wrongly consumed by a short anonymous function on stat end (yeah, too late to change the syntax to something easier to parse) -- ./lib/lua-parser/parser.lua:326
for i, stat in ipairs(block) do -- ./lib/lua-parser/parser.lua:327
if stat["tag"] == "Set" or stat["tag"] == "Push" or stat["tag"] == "Return" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./lib/lua-parser/parser.lua:329
local exprlist -- ./lib/lua-parser/parser.lua:330
if stat["tag"] == "Set" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./lib/lua-parser/parser.lua:332
exprlist = stat[# stat] -- ./lib/lua-parser/parser.lua:333
elseif stat["tag"] == "Push" or stat["tag"] == "Return" then -- ./lib/lua-parser/parser.lua:334
exprlist = stat -- ./lib/lua-parser/parser.lua:335
end -- ./lib/lua-parser/parser.lua:335
local last = exprlist[# exprlist] -- last value in ExprList -- ./lib/lua-parser/parser.lua:338
if last["tag"] == "Function" and last["is_short"] and not last["is_method"] and # last[1] == 1 then -- ./lib/lua-parser/parser.lua:342
local p = i -- ./lib/lua-parser/parser.lua:343
for j, fstat in ipairs(last[2]) do -- ./lib/lua-parser/parser.lua:344
p = i + j -- ./lib/lua-parser/parser.lua:345
table["insert"](block, p, fstat) -- copy stats from func body to block -- ./lib/lua-parser/parser.lua:346
if stat["move_up_block"] then -- extracted stats inherit move_up_block from statement -- ./lib/lua-parser/parser.lua:348
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + stat["move_up_block"] -- ./lib/lua-parser/parser.lua:349
end -- ./lib/lua-parser/parser.lua:349
if block["is_singlestatblock"] then -- if it's a single stat block, mark them to move them outside of the block -- ./lib/lua-parser/parser.lua:352
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:353
end -- ./lib/lua-parser/parser.lua:353
end -- ./lib/lua-parser/parser.lua:353
exprlist[# exprlist] = last[1] -- replace func with paren and expressions -- ./lib/lua-parser/parser.lua:357
exprlist[# exprlist]["tag"] = "Paren" -- ./lib/lua-parser/parser.lua:358
if not isRecCall then -- if superfluous statements won't be moved in a next recursion, let fixStructure handle things -- ./lib/lua-parser/parser.lua:360
for j = p + 1, # block, 1 do -- ./lib/lua-parser/parser.lua:361
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:362
end -- ./lib/lua-parser/parser.lua:362
end -- ./lib/lua-parser/parser.lua:362
return block, i -- ./lib/lua-parser/parser.lua:366
elseif last["tag"]:match("Expr$") then -- ./lib/lua-parser/parser.lua:369
local r = searchEndRec({ last }) -- ./lib/lua-parser/parser.lua:370
if r then -- ./lib/lua-parser/parser.lua:371
for j = 2, # r, 1 do -- ./lib/lua-parser/parser.lua:372
table["insert"](block, i + j - 1, r[j]) -- move back superflous statements from our new table to our real block -- ./lib/lua-parser/parser.lua:373
end -- move back superflous statements from our new table to our real block -- ./lib/lua-parser/parser.lua:373
return block, i -- ./lib/lua-parser/parser.lua:375
end -- ./lib/lua-parser/parser.lua:375
elseif last["tag"] == "Function" then -- ./lib/lua-parser/parser.lua:377
local r = searchEndRec(last[2]) -- ./lib/lua-parser/parser.lua:378
if r then -- ./lib/lua-parser/parser.lua:379
return block, i -- ./lib/lua-parser/parser.lua:380
end -- ./lib/lua-parser/parser.lua:380
end -- ./lib/lua-parser/parser.lua:380
elseif stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Do") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./lib/lua-parser/parser.lua:385
local blocks -- ./lib/lua-parser/parser.lua:386
if stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./lib/lua-parser/parser.lua:388
blocks = stat -- ./lib/lua-parser/parser.lua:389
elseif stat["tag"]:match("^Do") then -- ./lib/lua-parser/parser.lua:390
blocks = { stat } -- ./lib/lua-parser/parser.lua:391
end -- ./lib/lua-parser/parser.lua:391
for _, iblock in ipairs(blocks) do -- ./lib/lua-parser/parser.lua:394
if iblock["tag"] == "Block" then -- blocks -- ./lib/lua-parser/parser.lua:395
local oldLen = # iblock -- ./lib/lua-parser/parser.lua:396
local newiBlock, newEnd = searchEndRec(iblock, true) -- ./lib/lua-parser/parser.lua:397
if newiBlock then -- if end in the block -- ./lib/lua-parser/parser.lua:398
local p = i -- ./lib/lua-parser/parser.lua:399
for j = newEnd + (# iblock - oldLen) + 1, # iblock, 1 do -- move all statements after the newely added statements to the parent block -- ./lib/lua-parser/parser.lua:400
p = p + 1 -- ./lib/lua-parser/parser.lua:401
table["insert"](block, p, iblock[j]) -- ./lib/lua-parser/parser.lua:402
iblock[j] = nil -- ./lib/lua-parser/parser.lua:403
end -- ./lib/lua-parser/parser.lua:403
if not isRecCall then -- if superfluous statements won't be moved in a next recursion, let fixStructure handle things -- ./lib/lua-parser/parser.lua:406
for j = p + 1, # block, 1 do -- ./lib/lua-parser/parser.lua:407
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:408
end -- ./lib/lua-parser/parser.lua:408
end -- ./lib/lua-parser/parser.lua:408
return block, i -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
return nil -- ./lib/lua-parser/parser.lua:418
end -- ./lib/lua-parser/parser.lua:418
local function searchEnd(s, p, t) -- match time capture which try to restructure the AST to free an "end" for us -- ./lib/lua-parser/parser.lua:421
local r = searchEndRec(fixStructure(t)) -- ./lib/lua-parser/parser.lua:422
if not r then -- ./lib/lua-parser/parser.lua:423
return false -- ./lib/lua-parser/parser.lua:424
end -- ./lib/lua-parser/parser.lua:424
return true, r -- ./lib/lua-parser/parser.lua:426
end -- ./lib/lua-parser/parser.lua:426
local function expectBlockOrSingleStatWithStartEnd(start, startLabel, stopLabel, canFollow) -- will try a SingleStat if start doesn't match -- ./lib/lua-parser/parser.lua:429
if canFollow then -- ./lib/lua-parser/parser.lua:430
return (- start * V("SingleStatBlock") * canFollow ^ - 1) + (expect(start, startLabel) * ((V("Block") * (canFollow + kw("end"))) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./lib/lua-parser/parser.lua:433
else -- ./lib/lua-parser/parser.lua:433
return (- start * V("SingleStatBlock")) + (expect(start, startLabel) * ((V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./lib/lua-parser/parser.lua:437
end -- ./lib/lua-parser/parser.lua:437
end -- ./lib/lua-parser/parser.lua:437
local function expectBlockWithEnd(label) -- can't work *optionnaly* with SingleStat unfortunatly -- ./lib/lua-parser/parser.lua:441
return (V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(label)) -- ./lib/lua-parser/parser.lua:443
end -- ./lib/lua-parser/parser.lua:443
local function maybeBlockWithEnd() -- same as above but don't error if it doesn't match -- ./lib/lua-parser/parser.lua:446
return (V("BlockNoErr") * kw("end")) + Cmt(V("BlockNoErr"), searchEnd) -- ./lib/lua-parser/parser.lua:448
end -- ./lib/lua-parser/parser.lua:448
local stacks = { ["lexpr"] = {} } -- ./lib/lua-parser/parser.lua:452
local function push(f) -- ./lib/lua-parser/parser.lua:454
return Cmt(P(""), function() -- ./lib/lua-parser/parser.lua:455
table["insert"](stacks[f], true) -- ./lib/lua-parser/parser.lua:456
return true -- ./lib/lua-parser/parser.lua:457
end) -- ./lib/lua-parser/parser.lua:457
end -- ./lib/lua-parser/parser.lua:457
local function pop(f) -- ./lib/lua-parser/parser.lua:460
return Cmt(P(""), function() -- ./lib/lua-parser/parser.lua:461
table["remove"](stacks[f]) -- ./lib/lua-parser/parser.lua:462
return true -- ./lib/lua-parser/parser.lua:463
end) -- ./lib/lua-parser/parser.lua:463
end -- ./lib/lua-parser/parser.lua:463
local function when(f) -- ./lib/lua-parser/parser.lua:466
return Cmt(P(""), function() -- ./lib/lua-parser/parser.lua:467
return # stacks[f] > 0 -- ./lib/lua-parser/parser.lua:468
end) -- ./lib/lua-parser/parser.lua:468
end -- ./lib/lua-parser/parser.lua:468
local function set(f, patt) -- patt *must* succeed (or throw an error) to preserve stack integrity -- ./lib/lua-parser/parser.lua:471
return push(f) * patt * pop(f) -- ./lib/lua-parser/parser.lua:472
end -- ./lib/lua-parser/parser.lua:472
local G = { -- ./lib/lua-parser/parser.lua:476
V("Lua"), -- ./lib/lua-parser/parser.lua:476
["Lua"] = (V("Shebang") ^ - 1 * V("Skip") * V("Block") * expect(P(- 1), "Extra")) / fixStructure, -- ./lib/lua-parser/parser.lua:477
["Shebang"] = P("#!") * (P(1) - P("\
")) ^ 0, -- ./lib/lua-parser/parser.lua:478
["Block"] = tagC("Block", (V("Stat") + - V("BlockEnd") * throw("InvalidStat")) ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./lib/lua-parser/parser.lua:480
["Stat"] = V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat") + V("LocalStat") + V("FuncStat") + V("BreakStat") + V("LabelStat") + V("GoToStat") + V("FuncCall") + V("Assignment") + V("LetStat") + V("ContinueStat") + V("PushStat") + sym(";"), -- ./lib/lua-parser/parser.lua:485
["BlockEnd"] = P("return") + "end" + "elseif" + "else" + "until" + "]" + - 1 + V("ImplicitPushStat") + V("Assignment"), -- ./lib/lua-parser/parser.lua:486
["SingleStatBlock"] = tagC("Block", V("Stat") + V("RetStat") + V("ImplicitPushStat")) / function(t) -- ./lib/lua-parser/parser.lua:488
t["is_singlestatblock"] = true -- ./lib/lua-parser/parser.lua:488
return t -- ./lib/lua-parser/parser.lua:488
end, -- ./lib/lua-parser/parser.lua:488
["BlockNoErr"] = tagC("Block", V("Stat") ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- used to check if something a valid block without throwing an error -- ./lib/lua-parser/parser.lua:489
["IfStat"] = tagC("If", V("IfPart")), -- ./lib/lua-parser/parser.lua:491
["IfPart"] = kw("if") * set("lexpr", expect(V("Expr"), "ExprIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./lib/lua-parser/parser.lua:492
["ElseIfPart"] = kw("elseif") * set("lexpr", expect(V("Expr"), "ExprEIf")) * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenEIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./lib/lua-parser/parser.lua:493
["ElsePart"] = kw("else") * expectBlockWithEnd("EndIf"), -- ./lib/lua-parser/parser.lua:494
["DoStat"] = kw("do") * expectBlockWithEnd("EndDo") / tagDo, -- ./lib/lua-parser/parser.lua:496
["WhileStat"] = tagC("While", kw("while") * set("lexpr", expect(V("Expr"), "ExprWhile")) * V("WhileBody")), -- ./lib/lua-parser/parser.lua:497
["WhileBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoWhile", "EndWhile"), -- ./lib/lua-parser/parser.lua:498
["RepeatStat"] = tagC("Repeat", kw("repeat") * V("Block") * expect(kw("until"), "UntilRep") * expect(V("Expr"), "ExprRep")), -- ./lib/lua-parser/parser.lua:499
["ForStat"] = kw("for") * expect(V("ForNum") + V("ForIn"), "ForRange"), -- ./lib/lua-parser/parser.lua:501
["ForNum"] = tagC("Fornum", V("Id") * sym("=") * V("NumRange") * V("ForBody")), -- ./lib/lua-parser/parser.lua:502
["NumRange"] = expect(V("Expr"), "ExprFor1") * expect(sym(","), "CommaFor") * expect(V("Expr"), "ExprFor2") * (sym(",") * expect(V("Expr"), "ExprFor3")) ^ - 1, -- ./lib/lua-parser/parser.lua:504
["ForIn"] = tagC("Forin", V("NameList") * expect(kw("in"), "InFor") * expect(V("ExprList"), "EListFor") * V("ForBody")), -- ./lib/lua-parser/parser.lua:505
["ForBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoFor", "EndFor"), -- ./lib/lua-parser/parser.lua:506
["LocalStat"] = kw("local") * expect(V("LocalFunc") + V("LocalAssign"), "DefLocal"), -- ./lib/lua-parser/parser.lua:508
["LocalFunc"] = tagC("Localrec", kw("function") * expect(V("Id"), "NameLFunc") * V("FuncBody")) / fixFuncStat, -- ./lib/lua-parser/parser.lua:509
["LocalAssign"] = tagC("Local", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))), -- ./lib/lua-parser/parser.lua:510
["LetStat"] = kw("let") * expect(V("LetAssign"), "DefLet"), -- ./lib/lua-parser/parser.lua:512
["LetAssign"] = tagC("Let", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))), -- ./lib/lua-parser/parser.lua:513
["Assignment"] = tagC("Set", V("VarList") * V("BinOp") ^ - 1 * (P("=") / "=") * ((V("BinOp") - P("-")) + # (P("-") * V("Space")) * V("BinOp")) ^ - 1 * V("Skip") * expect(V("ExprList"), "EListAssign")), -- ./lib/lua-parser/parser.lua:515
["FuncStat"] = tagC("Set", kw("function") * expect(V("FuncName"), "FuncName") * V("FuncBody")) / fixFuncStat, -- ./lib/lua-parser/parser.lua:517
["FuncName"] = Cf(V("Id") * (sym(".") * expect(V("StrId"), "NameFunc1")) ^ 0, insertIndex) * (sym(":") * expect(V("StrId"), "NameFunc2")) ^ - 1 / markMethod, -- ./lib/lua-parser/parser.lua:519
["FuncBody"] = tagC("Function", V("FuncParams") * expectBlockWithEnd("EndFunc")), -- ./lib/lua-parser/parser.lua:520
["FuncParams"] = expect(sym("("), "OParenPList") * V("ParList") * expect(sym(")"), "CParenPList"), -- ./lib/lua-parser/parser.lua:521
["ParList"] = V("NamedParList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()), -- Cc({}) generates a bug since the {} would be shared across parses -- ./lib/lua-parser/parser.lua:524
["ShortFuncDef"] = tagC("Function", V("ShortFuncParams") * maybeBlockWithEnd()) / fixShortFunc, -- ./lib/lua-parser/parser.lua:526
["ShortFuncParams"] = (sym(":") / ":") ^ - 1 * sym("(") * V("ParList") * sym(")"), -- ./lib/lua-parser/parser.lua:527
["NamedParList"] = tagC("NamedParList", commaSep(V("NamedPar"))), -- ./lib/lua-parser/parser.lua:529
["NamedPar"] = tagC("ParPair", V("ParKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Id"), -- ./lib/lua-parser/parser.lua:531
["ParKey"] = V("Id") * # ("=" * - P("=")), -- ./lib/lua-parser/parser.lua:532
["LabelStat"] = tagC("Label", sym("::") * expect(V("Name"), "Label") * expect(sym("::"), "CloseLabel")), -- ./lib/lua-parser/parser.lua:534
["GoToStat"] = tagC("Goto", kw("goto") * expect(V("Name"), "Goto")), -- ./lib/lua-parser/parser.lua:535
["BreakStat"] = tagC("Break", kw("break")), -- ./lib/lua-parser/parser.lua:536
["ContinueStat"] = tagC("Continue", kw("continue")), -- ./lib/lua-parser/parser.lua:537
["RetStat"] = tagC("Return", kw("return") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./lib/lua-parser/parser.lua:538
["PushStat"] = tagC("Push", kw("push") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./lib/lua-parser/parser.lua:540
["ImplicitPushStat"] = tagC("Push", commaSep(V("Expr"), "RetList")), -- ./lib/lua-parser/parser.lua:541
["NameList"] = tagC("NameList", commaSep(V("Id"))), -- ./lib/lua-parser/parser.lua:543
["VarList"] = tagC("VarList", commaSep(V("VarExpr"))), -- ./lib/lua-parser/parser.lua:544
["ExprList"] = tagC("ExpList", commaSep(V("Expr"), "ExprList")), -- ./lib/lua-parser/parser.lua:545
["Expr"] = V("OrExpr"), -- ./lib/lua-parser/parser.lua:547
["OrExpr"] = chainOp(V("AndExpr"), V("OrOp"), "OrExpr"), -- ./lib/lua-parser/parser.lua:548
["AndExpr"] = chainOp(V("RelExpr"), V("AndOp"), "AndExpr"), -- ./lib/lua-parser/parser.lua:549
["RelExpr"] = chainOp(V("BOrExpr"), V("RelOp"), "RelExpr"), -- ./lib/lua-parser/parser.lua:550
["BOrExpr"] = chainOp(V("BXorExpr"), V("BOrOp"), "BOrExpr"), -- ./lib/lua-parser/parser.lua:551
["BXorExpr"] = chainOp(V("BAndExpr"), V("BXorOp"), "BXorExpr"), -- ./lib/lua-parser/parser.lua:552
["BAndExpr"] = chainOp(V("ShiftExpr"), V("BAndOp"), "BAndExpr"), -- ./lib/lua-parser/parser.lua:553
["ShiftExpr"] = chainOp(V("ConcatExpr"), V("ShiftOp"), "ShiftExpr"), -- ./lib/lua-parser/parser.lua:554
["ConcatExpr"] = V("AddExpr") * (V("ConcatOp") * expect(V("ConcatExpr"), "ConcatExpr")) ^ - 1 / binaryOp, -- ./lib/lua-parser/parser.lua:555
["AddExpr"] = chainOp(V("MulExpr"), V("AddOp"), "AddExpr"), -- ./lib/lua-parser/parser.lua:556
["MulExpr"] = chainOp(V("UnaryExpr"), V("MulOp"), "MulExpr"), -- ./lib/lua-parser/parser.lua:557
["UnaryExpr"] = V("UnaryOp") * expect(V("UnaryExpr"), "UnaryExpr") / unaryOp + V("PowExpr"), -- ./lib/lua-parser/parser.lua:559
["PowExpr"] = V("SimpleExpr") * (V("PowOp") * expect(V("UnaryExpr"), "PowExpr")) ^ - 1 / binaryOp, -- ./lib/lua-parser/parser.lua:560
["SimpleExpr"] = tagC("Number", V("Number")) + tagC("Nil", kw("nil")) + tagC("Boolean", kw("false") * Cc(false)) + tagC("Boolean", kw("true") * Cc(true)) + tagC("Dots", sym("...")) + V("FuncDef") + (when("lexpr") * tagC("LetExpr", V("NameList") * sym("=") * - sym("=") * expect(V("ExprList"), "EListLAssign"))) + V("ShortFuncDef") + V("SuffixedExpr") + V("StatExpr"), -- ./lib/lua-parser/parser.lua:570
["StatExpr"] = (V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat")) / statToExpr, -- ./lib/lua-parser/parser.lua:572
["FuncCall"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./lib/lua-parser/parser.lua:574
return exp["tag"] == "Call" or exp["tag"] == "SafeCall", exp -- ./lib/lua-parser/parser.lua:574
end), -- ./lib/lua-parser/parser.lua:574
["VarExpr"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./lib/lua-parser/parser.lua:575
return exp["tag"] == "Id" or exp["tag"] == "Index", exp -- ./lib/lua-parser/parser.lua:575
end), -- ./lib/lua-parser/parser.lua:575
["SuffixedExpr"] = Cf(V("PrimaryExpr") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr") * - V("Call") * (V("Index") + V("MethodStub") + V("Call")) ^ 0 + V("NoCallPrimaryExpr"), makeSuffixedExpr), -- ./lib/lua-parser/parser.lua:579
["PrimaryExpr"] = V("SelfId") * (V("SelfCall") + V("SelfIndex")) + V("Id") + tagC("Paren", sym("(") * expect(V("Expr"), "ExprParen") * expect(sym(")"), "CParenExpr")), -- ./lib/lua-parser/parser.lua:582
["NoCallPrimaryExpr"] = tagC("String", V("String")) + V("Table") + V("TableCompr"), -- ./lib/lua-parser/parser.lua:583
["Index"] = tagC("DotIndex", sym("." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("ArrayIndex", sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")) + tagC("SafeDotIndex", sym("?." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("SafeArrayIndex", sym("?[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")), -- ./lib/lua-parser/parser.lua:587
["MethodStub"] = tagC("MethodStub", sym(":" * - P(":")) * expect(V("StrId"), "NameMeth")) + tagC("SafeMethodStub", sym("?:" * - P(":")) * expect(V("StrId"), "NameMeth")), -- ./lib/lua-parser/parser.lua:589
["Call"] = tagC("Call", V("FuncArgs")) + tagC("SafeCall", P("?") * V("FuncArgs")), -- ./lib/lua-parser/parser.lua:591
["SelfCall"] = tagC("MethodStub", V("StrId")) * V("Call"), -- ./lib/lua-parser/parser.lua:592
["SelfIndex"] = tagC("DotIndex", V("StrId")), -- ./lib/lua-parser/parser.lua:593
["FuncDef"] = (kw("function") * V("FuncBody")), -- ./lib/lua-parser/parser.lua:595
["FuncArgs"] = sym("(") * commaSep(V("Expr"), "ArgList") ^ - 1 * expect(sym(")"), "CParenArgs") + V("Table") + tagC("String", V("String")), -- ./lib/lua-parser/parser.lua:598
["Table"] = tagC("Table", sym("{") * V("FieldList") ^ - 1 * expect(sym("}"), "CBraceTable")), -- ./lib/lua-parser/parser.lua:600
["FieldList"] = sepBy(V("Field"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./lib/lua-parser/parser.lua:601
["Field"] = tagC("Pair", V("FieldKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Expr"), -- ./lib/lua-parser/parser.lua:603
["FieldKey"] = sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprFKey") * expect(sym("]"), "CBracketFKey") + V("StrId") * # ("=" * - P("=")), -- ./lib/lua-parser/parser.lua:605
["FieldSep"] = sym(",") + sym(";"), -- ./lib/lua-parser/parser.lua:606
["TableCompr"] = tagC("TableCompr", sym("[") * V("Block") * expect(sym("]"), "CBracketTableCompr")), -- ./lib/lua-parser/parser.lua:608
["SelfId"] = tagC("Id", sym("@") / "self"), -- ./lib/lua-parser/parser.lua:610
["Id"] = tagC("Id", V("Name")) + V("SelfId"), -- ./lib/lua-parser/parser.lua:611
["StrId"] = tagC("String", V("Name")), -- ./lib/lua-parser/parser.lua:612
["Skip"] = (V("Space") + V("Comment")) ^ 0, -- ./lib/lua-parser/parser.lua:615
["Space"] = space ^ 1, -- ./lib/lua-parser/parser.lua:616
["Comment"] = P("--") * V("LongStr") / function() -- ./lib/lua-parser/parser.lua:617
return  -- ./lib/lua-parser/parser.lua:617
end + P("--") * (P(1) - P("\
")) ^ 0, -- ./lib/lua-parser/parser.lua:618
["Name"] = token(- V("Reserved") * C(V("Ident"))), -- ./lib/lua-parser/parser.lua:620
["Reserved"] = V("Keywords") * - V("IdRest"), -- ./lib/lua-parser/parser.lua:621
["Keywords"] = P("and") + "break" + "do" + "elseif" + "else" + "end" + "false" + "for" + "function" + "goto" + "if" + "in" + "local" + "nil" + "not" + "or" + "repeat" + "return" + "then" + "true" + "until" + "while", -- ./lib/lua-parser/parser.lua:625
["Ident"] = V("IdStart") * V("IdRest") ^ 0, -- ./lib/lua-parser/parser.lua:626
["IdStart"] = alpha + P("_"), -- ./lib/lua-parser/parser.lua:627
["IdRest"] = alnum + P("_"), -- ./lib/lua-parser/parser.lua:628
["Number"] = token(C(V("Hex") + V("Float") + V("Int"))), -- ./lib/lua-parser/parser.lua:630
["Hex"] = (P("0x") + "0X") * ((xdigit ^ 0 * V("DeciHex")) + (expect(xdigit ^ 1, "DigitHex") * V("DeciHex") ^ - 1)) * V("ExpoHex") ^ - 1, -- ./lib/lua-parser/parser.lua:631
["Float"] = V("Decimal") * V("Expo") ^ - 1 + V("Int") * V("Expo"), -- ./lib/lua-parser/parser.lua:633
["Decimal"] = digit ^ 1 * "." * digit ^ 0 + P(".") * - P(".") * expect(digit ^ 1, "DigitDeci"), -- ./lib/lua-parser/parser.lua:635
["DeciHex"] = P(".") * xdigit ^ 0, -- ./lib/lua-parser/parser.lua:636
["Expo"] = S("eE") * S("+-") ^ - 1 * expect(digit ^ 1, "DigitExpo"), -- ./lib/lua-parser/parser.lua:637
["ExpoHex"] = S("pP") * S("+-") ^ - 1 * expect(xdigit ^ 1, "DigitExpo"), -- ./lib/lua-parser/parser.lua:638
["Int"] = digit ^ 1, -- ./lib/lua-parser/parser.lua:639
["String"] = token(V("ShortStr") + V("LongStr")), -- ./lib/lua-parser/parser.lua:641
["ShortStr"] = P("\"") * Cs((V("EscSeq") + (P(1) - S("\"\
"))) ^ 0) * expect(P("\""), "Quote") + P("'") * Cs((V("EscSeq") + (P(1) - S("'\
"))) ^ 0) * expect(P("'"), "Quote"), -- ./lib/lua-parser/parser.lua:643
["EscSeq"] = P("\\") / "" * (P("a") / "\7" + P("b") / "\8" + P("f") / "\12" + P("n") / "\
" + P("r") / "\13" + P("t") / "\9" + P("v") / "\11" + P("\
") / "\
" + P("\13") / "\
" + P("\\") / "\\" + P("\"") / "\"" + P("'") / "'" + P("z") * space ^ 0 / "" + digit * digit ^ - 2 / tonumber / string["char"] + P("x") * expect(C(xdigit * xdigit), "HexEsc") * Cc(16) / tonumber / string["char"] + P("u") * expect("{", "OBraceUEsc") * expect(C(xdigit ^ 1), "DigitUEsc") * Cc(16) * expect("}", "CBraceUEsc") / tonumber / (utf8 and utf8["char"] or string["char"]) + throw("EscSeq")), -- ./lib/lua-parser/parser.lua:673
["LongStr"] = V("Open") * C((P(1) - V("CloseEq")) ^ 0) * expect(V("Close"), "CloseLStr") / function(s, eqs) -- ./lib/lua-parser/parser.lua:676
return s -- ./lib/lua-parser/parser.lua:676
end, -- ./lib/lua-parser/parser.lua:676
["Open"] = "[" * Cg(V("Equals"), "openEq") * "[" * P("\
") ^ - 1, -- ./lib/lua-parser/parser.lua:677
["Close"] = "]" * C(V("Equals")) * "]", -- ./lib/lua-parser/parser.lua:678
["Equals"] = P("=") ^ 0, -- ./lib/lua-parser/parser.lua:679
["CloseEq"] = Cmt(V("Close") * Cb("openEq"), function(s, i, closeEq, openEq) -- ./lib/lua-parser/parser.lua:680
return # openEq == # closeEq -- ./lib/lua-parser/parser.lua:680
end), -- ./lib/lua-parser/parser.lua:680
["OrOp"] = kw("or") / "or", -- ./lib/lua-parser/parser.lua:682
["AndOp"] = kw("and") / "and", -- ./lib/lua-parser/parser.lua:683
["RelOp"] = sym("~=") / "ne" + sym("==") / "eq" + sym("<=") / "le" + sym(">=") / "ge" + sym("<") / "lt" + sym(">") / "gt", -- ./lib/lua-parser/parser.lua:689
["BOrOp"] = sym("|") / "bor", -- ./lib/lua-parser/parser.lua:690
["BXorOp"] = sym("~" * - P("=")) / "bxor", -- ./lib/lua-parser/parser.lua:691
["BAndOp"] = sym("&") / "band", -- ./lib/lua-parser/parser.lua:692
["ShiftOp"] = sym("<<") / "shl" + sym(">>") / "shr", -- ./lib/lua-parser/parser.lua:694
["ConcatOp"] = sym("..") / "concat", -- ./lib/lua-parser/parser.lua:695
["AddOp"] = sym("+") / "add" + sym("-") / "sub", -- ./lib/lua-parser/parser.lua:697
["MulOp"] = sym("*") / "mul" + sym("//") / "idiv" + sym("/") / "div" + sym("%") / "mod", -- ./lib/lua-parser/parser.lua:701
["UnaryOp"] = kw("not") / "not" + sym("-") / "unm" + sym("#") / "len" + sym("~") / "bnot", -- ./lib/lua-parser/parser.lua:705
["PowOp"] = sym("^") / "pow", -- ./lib/lua-parser/parser.lua:706
["BinOp"] = V("OrOp") + V("AndOp") + V("BOrOp") + V("BXorOp") + V("BAndOp") + V("ShiftOp") + V("ConcatOp") + V("AddOp") + V("MulOp") + V("PowOp") -- ./lib/lua-parser/parser.lua:707
} -- ./lib/lua-parser/parser.lua:707
local parser = {} -- ./lib/lua-parser/parser.lua:710
local validator = require("lib.lua-parser.validator") -- ./lib/lua-parser/parser.lua:712
local validate = validator["validate"] -- ./lib/lua-parser/parser.lua:713
local syntaxerror = validator["syntaxerror"] -- ./lib/lua-parser/parser.lua:714
parser["parse"] = function(subject, filename) -- ./lib/lua-parser/parser.lua:716
local errorinfo = { -- ./lib/lua-parser/parser.lua:717
["subject"] = subject, -- ./lib/lua-parser/parser.lua:717
["filename"] = filename -- ./lib/lua-parser/parser.lua:717
} -- ./lib/lua-parser/parser.lua:717
lpeg["setmaxstack"](1000) -- ./lib/lua-parser/parser.lua:718
local ast, label, errpos = lpeg["match"](G, subject, nil, errorinfo) -- ./lib/lua-parser/parser.lua:719
if not ast then -- ./lib/lua-parser/parser.lua:720
local errmsg = labels[label][2] -- ./lib/lua-parser/parser.lua:721
return ast, syntaxerror(errorinfo, errpos, errmsg) -- ./lib/lua-parser/parser.lua:722
end -- ./lib/lua-parser/parser.lua:722
return validate(ast, errorinfo) -- ./lib/lua-parser/parser.lua:724
end -- ./lib/lua-parser/parser.lua:724
return parser -- ./lib/lua-parser/parser.lua:727
end -- ./lib/lua-parser/parser.lua:727
local parser = _() or parser -- ./lib/lua-parser/parser.lua:731
package["loaded"]["lib.lua-parser.parser"] = parser or true -- ./lib/lua-parser/parser.lua:732
local candran = { ["VERSION"] = "0.10.0" } -- candran.can:14
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
