local function _() -- candran.can:2
local util = {} -- ./lib/util.can:1
util["search"] = function(modpath, exts) -- ./lib/util.can:3
if exts == nil then exts = { -- ./lib/util.can:3
"can", -- ./lib/util.can:3
"lua" -- ./lib/util.can:3
} end -- ./lib/util.can:3
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
return function(code, ast, options) -- ./compiler/lua53.can:1
local lastInputPos = 1 -- last token position in the input code -- ./compiler/lua53.can:3
local prevLinePos = 1 -- last token position in the previous line of code in the input code -- ./compiler/lua53.can:4
local lastSource = options["chunkname"] or "nil" -- last found code source name (from the original file) -- ./compiler/lua53.can:5
local lastLine = 1 -- last found line number (from the original file) -- ./compiler/lua53.can:6
local indentLevel = 0 -- ./compiler/lua53.can:9
local function newline() -- ./compiler/lua53.can:11
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua53.can:12
if options["mapLines"] then -- ./compiler/lua53.can:13
local sub = code:sub(lastInputPos) -- ./compiler/lua53.can:14
local source, line = sub:sub(1, sub:find("\
")):match("%-%- (.-)%:(%d+)\
") -- ./compiler/lua53.can:15
if source and line then -- ./compiler/lua53.can:17
lastSource = source -- ./compiler/lua53.can:18
lastLine = tonumber(line) -- ./compiler/lua53.can:19
else -- ./compiler/lua53.can:19
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua53.can:21
lastLine = lastLine + (1) -- ./compiler/lua53.can:22
end -- ./compiler/lua53.can:22
end -- ./compiler/lua53.can:22
prevLinePos = lastInputPos -- ./compiler/lua53.can:26
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua53.can:28
end -- ./compiler/lua53.can:28
return r -- ./compiler/lua53.can:30
end -- ./compiler/lua53.can:30
local function indent() -- ./compiler/lua53.can:33
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:34
return newline() -- ./compiler/lua53.can:35
end -- ./compiler/lua53.can:35
local function unindent() -- ./compiler/lua53.can:38
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:39
return newline() -- ./compiler/lua53.can:40
end -- ./compiler/lua53.can:40
local required = {} -- { ["module"] = true, ... } -- ./compiler/lua53.can:44
local requireStr = "" -- ./compiler/lua53.can:45
local function addRequire(mod, name, field) -- ./compiler/lua53.can:47
if not required[mod] then -- ./compiler/lua53.can:48
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"]) -- ./compiler/lua53.can:49
required[mod] = true -- ./compiler/lua53.can:50
end -- ./compiler/lua53.can:50
end -- ./compiler/lua53.can:50
local function var(name) -- ./compiler/lua53.can:56
return options["variablePrefix"] .. name -- ./compiler/lua53.can:57
end -- ./compiler/lua53.can:57
local loop = { -- loops tags -- ./compiler/lua53.can:61
"While", -- loops tags -- ./compiler/lua53.can:61
"Repeat", -- loops tags -- ./compiler/lua53.can:61
"Fornum", -- loops tags -- ./compiler/lua53.can:61
"Forin" -- loops tags -- ./compiler/lua53.can:61
} -- loops tags -- ./compiler/lua53.can:61
local func = { -- function scope tags -- ./compiler/lua53.can:62
"Function", -- function scope tags -- ./compiler/lua53.can:62
"TableCompr", -- function scope tags -- ./compiler/lua53.can:62
"DoExpr", -- function scope tags -- ./compiler/lua53.can:62
"WhileExpr", -- function scope tags -- ./compiler/lua53.can:62
"RepeatExpr", -- function scope tags -- ./compiler/lua53.can:62
"IfExpr", -- function scope tags -- ./compiler/lua53.can:62
"FornumExpr", -- function scope tags -- ./compiler/lua53.can:62
"ForinExpr" -- function scope tags -- ./compiler/lua53.can:62
} -- function scope tags -- ./compiler/lua53.can:62
local function any(list, tags, nofollow) -- ./compiler/lua53.can:65
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:65
local tagsCheck = {} -- ./compiler/lua53.can:66
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:67
tagsCheck[tag] = true -- ./compiler/lua53.can:68
end -- ./compiler/lua53.can:68
local nofollowCheck = {} -- ./compiler/lua53.can:70
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:71
nofollowCheck[tag] = true -- ./compiler/lua53.can:72
end -- ./compiler/lua53.can:72
for _, node in ipairs(list) do -- ./compiler/lua53.can:74
if type(node) == "table" then -- ./compiler/lua53.can:75
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:76
return node -- ./compiler/lua53.can:77
end -- ./compiler/lua53.can:77
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:79
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:80
if r then -- ./compiler/lua53.can:81
return r -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
return nil -- ./compiler/lua53.can:85
end -- ./compiler/lua53.can:85
local states = { ["push"] = {} } -- push stack variable names -- ./compiler/lua53.can:91
local function push(name, state) -- ./compiler/lua53.can:94
table["insert"](states[name], state) -- ./compiler/lua53.can:95
return "" -- ./compiler/lua53.can:96
end -- ./compiler/lua53.can:96
local function pop(name) -- ./compiler/lua53.can:99
table["remove"](states[name]) -- ./compiler/lua53.can:100
return "" -- ./compiler/lua53.can:101
end -- ./compiler/lua53.can:101
local function peek(name) -- ./compiler/lua53.can:104
return states[name][# states[name]] -- ./compiler/lua53.can:105
end -- ./compiler/lua53.can:105
local tags -- ./compiler/lua53.can:109
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:111
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:112
lastInputPos = ast["pos"] -- ./compiler/lua53.can:113
end -- ./compiler/lua53.can:113
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:115
end -- ./compiler/lua53.can:115
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:119
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:122
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:123
end -- ./compiler/lua53.can:123
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:125
return "do" .. indent() -- ./compiler/lua53.can:126
end -- ./compiler/lua53.can:126
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:128
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
tags = setmetatable({ -- ./compiler/lua53.can:133
["Block"] = function(t) -- ./compiler/lua53.can:135
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:136
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:137
hasPush["tag"] = "Return" -- ./compiler/lua53.can:138
hasPush = false -- ./compiler/lua53.can:139
end -- ./compiler/lua53.can:139
local r = "" -- ./compiler/lua53.can:141
if hasPush then -- ./compiler/lua53.can:142
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:145
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:146
end -- ./compiler/lua53.can:146
if t[# t] then -- ./compiler/lua53.can:148
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:149
end -- ./compiler/lua53.can:149
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:151
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:152
end -- ./compiler/lua53.can:152
return r -- ./compiler/lua53.can:154
end, -- ./compiler/lua53.can:154
["Do"] = function(t) -- ./compiler/lua53.can:160
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:161
end, -- ./compiler/lua53.can:161
["Set"] = function(t) -- ./compiler/lua53.can:164
if # t == 2 then -- ./compiler/lua53.can:165
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs") -- ./compiler/lua53.can:166
elseif # t == 3 then -- ./compiler/lua53.can:167
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs") -- ./compiler/lua53.can:168
elseif # t == 4 then -- ./compiler/lua53.can:169
if t[3] == "=" then -- ./compiler/lua53.can:170
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:171
t[2], -- ./compiler/lua53.can:171
t[1][1], -- ./compiler/lua53.can:171
{ -- ./compiler/lua53.can:171
["tag"] = "Paren", -- ./compiler/lua53.can:171
t[4][1] -- ./compiler/lua53.can:171
} -- ./compiler/lua53.can:171
}, "Op") -- ./compiler/lua53.can:171
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:172
r = r .. (", " .. lua({ -- ./compiler/lua53.can:173
t[2], -- ./compiler/lua53.can:173
t[1][i], -- ./compiler/lua53.can:173
{ -- ./compiler/lua53.can:173
["tag"] = "Paren", -- ./compiler/lua53.can:173
t[4][i] -- ./compiler/lua53.can:173
} -- ./compiler/lua53.can:173
}, "Op")) -- ./compiler/lua53.can:173
end -- ./compiler/lua53.can:173
return r -- ./compiler/lua53.can:175
else -- ./compiler/lua53.can:175
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:177
t[3], -- ./compiler/lua53.can:177
{ -- ./compiler/lua53.can:177
["tag"] = "Paren", -- ./compiler/lua53.can:177
t[4][1] -- ./compiler/lua53.can:177
}, -- ./compiler/lua53.can:177
t[1][1] -- ./compiler/lua53.can:177
}, "Op") -- ./compiler/lua53.can:177
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:178
r = r .. (", " .. lua({ -- ./compiler/lua53.can:179
t[3], -- ./compiler/lua53.can:179
{ -- ./compiler/lua53.can:179
["tag"] = "Paren", -- ./compiler/lua53.can:179
t[4][i] -- ./compiler/lua53.can:179
}, -- ./compiler/lua53.can:179
t[1][i] -- ./compiler/lua53.can:179
}, "Op")) -- ./compiler/lua53.can:179
end -- ./compiler/lua53.can:179
return r -- ./compiler/lua53.can:181
end -- ./compiler/lua53.can:181
else -- ./compiler/lua53.can:181
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:184
t[2], -- ./compiler/lua53.can:184
t[1][1], -- ./compiler/lua53.can:184
{ -- ./compiler/lua53.can:184
["tag"] = "Op", -- ./compiler/lua53.can:184
t[4], -- ./compiler/lua53.can:184
{ -- ./compiler/lua53.can:184
["tag"] = "Paren", -- ./compiler/lua53.can:184
t[5][1] -- ./compiler/lua53.can:184
}, -- ./compiler/lua53.can:184
t[1][1] -- ./compiler/lua53.can:184
} -- ./compiler/lua53.can:184
}, "Op") -- ./compiler/lua53.can:184
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:185
r = r .. (", " .. lua({ -- ./compiler/lua53.can:186
t[2], -- ./compiler/lua53.can:186
t[1][i], -- ./compiler/lua53.can:186
{ -- ./compiler/lua53.can:186
["tag"] = "Op", -- ./compiler/lua53.can:186
t[4], -- ./compiler/lua53.can:186
{ -- ./compiler/lua53.can:186
["tag"] = "Paren", -- ./compiler/lua53.can:186
t[5][i] -- ./compiler/lua53.can:186
}, -- ./compiler/lua53.can:186
t[1][i] -- ./compiler/lua53.can:186
} -- ./compiler/lua53.can:186
}, "Op")) -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
return r -- ./compiler/lua53.can:188
end -- ./compiler/lua53.can:188
end, -- ./compiler/lua53.can:188
["While"] = function(t) -- ./compiler/lua53.can:192
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:193
local r = "while " .. lua(t[1]) .. " do" .. indent() -- ./compiler/lua53.can:194
if hasContinue then -- ./compiler/lua53.can:195
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:196
end -- ./compiler/lua53.can:196
r = r .. (lua(t[2])) -- ./compiler/lua53.can:198
if hasContinue then -- ./compiler/lua53.can:199
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:200
end -- ./compiler/lua53.can:200
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:202
return r -- ./compiler/lua53.can:203
end, -- ./compiler/lua53.can:203
["Repeat"] = function(t) -- ./compiler/lua53.can:206
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:207
local r = "repeat" .. indent() -- ./compiler/lua53.can:208
if hasContinue then -- ./compiler/lua53.can:209
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:210
end -- ./compiler/lua53.can:210
r = r .. (lua(t[1])) -- ./compiler/lua53.can:212
if hasContinue then -- ./compiler/lua53.can:213
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:214
end -- ./compiler/lua53.can:214
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:216
return r -- ./compiler/lua53.can:217
end, -- ./compiler/lua53.can:217
["If"] = function(t) -- ./compiler/lua53.can:220
local r = "if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent() -- ./compiler/lua53.can:221
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:222
r = r .. ("elseif " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:223
end -- ./compiler/lua53.can:223
if # t % 2 == 1 then -- ./compiler/lua53.can:225
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:226
end -- ./compiler/lua53.can:226
return r .. "end" -- ./compiler/lua53.can:228
end, -- ./compiler/lua53.can:228
["Fornum"] = function(t) -- ./compiler/lua53.can:231
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:232
if # t == 5 then -- ./compiler/lua53.can:233
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:234
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:235
if hasContinue then -- ./compiler/lua53.can:236
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:237
end -- ./compiler/lua53.can:237
r = r .. (lua(t[5])) -- ./compiler/lua53.can:239
if hasContinue then -- ./compiler/lua53.can:240
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:241
end -- ./compiler/lua53.can:241
return r .. unindent() .. "end" -- ./compiler/lua53.can:243
else -- ./compiler/lua53.can:243
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:245
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:246
if hasContinue then -- ./compiler/lua53.can:247
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:248
end -- ./compiler/lua53.can:248
r = r .. (lua(t[4])) -- ./compiler/lua53.can:250
if hasContinue then -- ./compiler/lua53.can:251
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:252
end -- ./compiler/lua53.can:252
return r .. unindent() .. "end" -- ./compiler/lua53.can:254
end -- ./compiler/lua53.can:254
end, -- ./compiler/lua53.can:254
["Forin"] = function(t) -- ./compiler/lua53.can:258
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:259
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:260
if hasContinue then -- ./compiler/lua53.can:261
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:262
end -- ./compiler/lua53.can:262
r = r .. (lua(t[3])) -- ./compiler/lua53.can:264
if hasContinue then -- ./compiler/lua53.can:265
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:266
end -- ./compiler/lua53.can:266
return r .. unindent() .. "end" -- ./compiler/lua53.can:268
end, -- ./compiler/lua53.can:268
["Local"] = function(t) -- ./compiler/lua53.can:271
local r = "local " .. lua(t[1], "_lhs") -- ./compiler/lua53.can:272
if t[2][1] then -- ./compiler/lua53.can:273
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:274
end -- ./compiler/lua53.can:274
return r -- ./compiler/lua53.can:276
end, -- ./compiler/lua53.can:276
["Let"] = function(t) -- ./compiler/lua53.can:279
local nameList = lua(t[1], "_lhs") -- ./compiler/lua53.can:280
local r = "local " .. nameList -- ./compiler/lua53.can:281
if t[2][1] then -- ./compiler/lua53.can:282
if any(t[2], { -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Function", -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Table", -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Paren" -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
}) then -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:284
else -- ./compiler/lua53.can:284
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:286
end -- ./compiler/lua53.can:286
end -- ./compiler/lua53.can:286
return r -- ./compiler/lua53.can:289
end, -- ./compiler/lua53.can:289
["Localrec"] = function(t) -- ./compiler/lua53.can:292
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:293
end, -- ./compiler/lua53.can:293
["Goto"] = function(t) -- ./compiler/lua53.can:296
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:297
end, -- ./compiler/lua53.can:297
["Label"] = function(t) -- ./compiler/lua53.can:300
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:301
end, -- ./compiler/lua53.can:301
["Return"] = function(t) -- ./compiler/lua53.can:304
local push = peek("push") -- ./compiler/lua53.can:305
if push then -- ./compiler/lua53.can:306
local r = "" -- ./compiler/lua53.can:307
for _, val in ipairs(t) do -- ./compiler/lua53.can:308
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:309
end -- ./compiler/lua53.can:309
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:311
else -- ./compiler/lua53.can:311
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:313
end -- ./compiler/lua53.can:313
end, -- ./compiler/lua53.can:313
["Push"] = function(t) -- ./compiler/lua53.can:317
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:318
r = "" -- ./compiler/lua53.can:319
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:320
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:321
end -- ./compiler/lua53.can:321
if t[# t] then -- ./compiler/lua53.can:323
if t[# t]["tag"] == "Call" or t[# t]["tag"] == "Invoke" then -- ./compiler/lua53.can:324
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:325
else -- ./compiler/lua53.can:325
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:327
end -- ./compiler/lua53.can:327
end -- ./compiler/lua53.can:327
return r -- ./compiler/lua53.can:330
end, -- ./compiler/lua53.can:330
["Break"] = function() -- ./compiler/lua53.can:333
return "break" -- ./compiler/lua53.can:334
end, -- ./compiler/lua53.can:334
["Continue"] = function() -- ./compiler/lua53.can:337
return "goto " .. var("continue") -- ./compiler/lua53.can:338
end, -- ./compiler/lua53.can:338
["Nil"] = function() -- ./compiler/lua53.can:345
return "nil" -- ./compiler/lua53.can:346
end, -- ./compiler/lua53.can:346
["Dots"] = function() -- ./compiler/lua53.can:349
return "..." -- ./compiler/lua53.can:350
end, -- ./compiler/lua53.can:350
["Boolean"] = function(t) -- ./compiler/lua53.can:353
return tostring(t[1]) -- ./compiler/lua53.can:354
end, -- ./compiler/lua53.can:354
["Number"] = function(t) -- ./compiler/lua53.can:357
return tostring(t[1]) -- ./compiler/lua53.can:358
end, -- ./compiler/lua53.can:358
["String"] = function(t) -- ./compiler/lua53.can:361
return ("%q"):format(t[1]) -- ./compiler/lua53.can:362
end, -- ./compiler/lua53.can:362
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:365
local r = "(" -- ./compiler/lua53.can:366
local decl = {} -- ./compiler/lua53.can:367
if t[1][1] then -- ./compiler/lua53.can:368
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:369
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:370
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:371
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:372
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:373
r = r .. (id) -- ./compiler/lua53.can:374
else -- ./compiler/lua53.can:374
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:376
end -- ./compiler/lua53.can:376
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:378
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:379
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:380
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:381
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:382
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:383
r = r .. (", " .. id) -- ./compiler/lua53.can:384
else -- ./compiler/lua53.can:384
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
r = r .. (")" .. indent()) -- ./compiler/lua53.can:390
for _, d in ipairs(decl) do -- ./compiler/lua53.can:391
r = r .. (d .. newline()) -- ./compiler/lua53.can:392
end -- ./compiler/lua53.can:392
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:394
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:395
end -- ./compiler/lua53.can:395
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:397
if hasPush then -- ./compiler/lua53.can:398
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:399
else -- ./compiler/lua53.can:399
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:401
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:401
r = r .. (lua(t[2])) -- ./compiler/lua53.can:403
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:404
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:405
end -- ./compiler/lua53.can:405
pop("push") -- ./compiler/lua53.can:407
return r .. unindent() .. "end" -- ./compiler/lua53.can:408
end, -- ./compiler/lua53.can:408
["Function"] = function(t) -- ./compiler/lua53.can:410
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:411
end, -- ./compiler/lua53.can:411
["Pair"] = function(t) -- ./compiler/lua53.can:414
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:415
end, -- ./compiler/lua53.can:415
["Table"] = function(t) -- ./compiler/lua53.can:417
if # t == 0 then -- ./compiler/lua53.can:418
return "{}" -- ./compiler/lua53.can:419
elseif # t == 1 then -- ./compiler/lua53.can:420
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:421
else -- ./compiler/lua53.can:421
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:423
end -- ./compiler/lua53.can:423
end, -- ./compiler/lua53.can:423
["TableCompr"] = function(t) -- ./compiler/lua53.can:427
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:428
end, -- ./compiler/lua53.can:428
["Op"] = function(t) -- ./compiler/lua53.can:431
local r -- ./compiler/lua53.can:432
if # t == 2 then -- ./compiler/lua53.can:433
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:434
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:435
else -- ./compiler/lua53.can:435
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:437
end -- ./compiler/lua53.can:437
else -- ./compiler/lua53.can:437
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:440
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:441
else -- ./compiler/lua53.can:441
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:443
end -- ./compiler/lua53.can:443
end -- ./compiler/lua53.can:443
return r -- ./compiler/lua53.can:446
end, -- ./compiler/lua53.can:446
["Paren"] = function(t) -- ./compiler/lua53.can:449
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:450
end, -- ./compiler/lua53.can:450
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:457
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:458
local r = "(function()" .. indent() -- ./compiler/lua53.can:459
if hasPush then -- ./compiler/lua53.can:460
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:461
else -- ./compiler/lua53.can:461
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:463
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:463
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:465
if hasPush then -- ./compiler/lua53.can:466
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:467
end -- ./compiler/lua53.can:467
pop("push") -- ./compiler/lua53.can:469
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:470
return r -- ./compiler/lua53.can:471
end, -- ./compiler/lua53.can:471
["DoExpr"] = function(t) -- ./compiler/lua53.can:474
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:475
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:476
end -- ./compiler/lua53.can:476
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:478
end, -- ./compiler/lua53.can:478
["WhileExpr"] = function(t) -- ./compiler/lua53.can:481
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:482
end, -- ./compiler/lua53.can:482
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:485
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:486
end, -- ./compiler/lua53.can:486
["IfExpr"] = function(t) -- ./compiler/lua53.can:489
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:490
local block = t[i] -- ./compiler/lua53.can:491
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:492
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:496
end, -- ./compiler/lua53.can:496
["FornumExpr"] = function(t) -- ./compiler/lua53.can:499
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:500
end, -- ./compiler/lua53.can:500
["ForinExpr"] = function(t) -- ./compiler/lua53.can:503
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:504
end, -- ./compiler/lua53.can:504
["Call"] = function(t) -- ./compiler/lua53.can:510
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:511
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:512
else -- ./compiler/lua53.can:512
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:514
end -- ./compiler/lua53.can:514
end, -- ./compiler/lua53.can:514
["Invoke"] = function(t) -- ./compiler/lua53.can:519
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:520
return "(" .. lua(t[1]) .. "):" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")" -- ./compiler/lua53.can:521
else -- ./compiler/lua53.can:521
return lua(t[1]) .. ":" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")" -- ./compiler/lua53.can:523
end -- ./compiler/lua53.can:523
end, -- ./compiler/lua53.can:523
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:528
if start == nil then start = 1 end -- ./compiler/lua53.can:528
local r -- ./compiler/lua53.can:529
if t[start] then -- ./compiler/lua53.can:530
r = lua(t[start]) -- ./compiler/lua53.can:531
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:532
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:533
end -- ./compiler/lua53.can:533
else -- ./compiler/lua53.can:533
r = "" -- ./compiler/lua53.can:536
end -- ./compiler/lua53.can:536
return r -- ./compiler/lua53.can:538
end, -- ./compiler/lua53.can:538
["Id"] = function(t) -- ./compiler/lua53.can:541
return t[1] -- ./compiler/lua53.can:542
end, -- ./compiler/lua53.can:542
["Index"] = function(t) -- ./compiler/lua53.can:545
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:546
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:547
else -- ./compiler/lua53.can:547
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:549
end -- ./compiler/lua53.can:549
end, -- ./compiler/lua53.can:549
["_opid"] = { -- ./compiler/lua53.can:554
["add"] = "+", -- ./compiler/lua53.can:555
["sub"] = "-", -- ./compiler/lua53.can:555
["mul"] = "*", -- ./compiler/lua53.can:555
["div"] = "/", -- ./compiler/lua53.can:555
["idiv"] = "//", -- ./compiler/lua53.can:556
["mod"] = "%", -- ./compiler/lua53.can:556
["pow"] = "^", -- ./compiler/lua53.can:556
["concat"] = "..", -- ./compiler/lua53.can:556
["band"] = "&", -- ./compiler/lua53.can:557
["bor"] = "|", -- ./compiler/lua53.can:557
["bxor"] = "~", -- ./compiler/lua53.can:557
["shl"] = "<<", -- ./compiler/lua53.can:557
["shr"] = ">>", -- ./compiler/lua53.can:557
["eq"] = "==", -- ./compiler/lua53.can:558
["ne"] = "~=", -- ./compiler/lua53.can:558
["lt"] = "<", -- ./compiler/lua53.can:558
["gt"] = ">", -- ./compiler/lua53.can:558
["le"] = "<=", -- ./compiler/lua53.can:558
["ge"] = ">=", -- ./compiler/lua53.can:558
["and"] = "and", -- ./compiler/lua53.can:559
["or"] = "or", -- ./compiler/lua53.can:559
["unm"] = "-", -- ./compiler/lua53.can:559
["len"] = "#", -- ./compiler/lua53.can:559
["bnot"] = "~", -- ./compiler/lua53.can:559
["not"] = "not" -- ./compiler/lua53.can:559
} -- ./compiler/lua53.can:559
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:562
error("don't know how to compile a " .. tostring(key) .. " to Lua 5.3") -- ./compiler/lua53.can:563
end }) -- ./compiler/lua53.can:563
local code = lua(ast) .. newline() -- ./compiler/lua53.can:569
return requireStr .. code -- ./compiler/lua53.can:570
end -- ./compiler/lua53.can:570
end -- ./compiler/lua53.can:570
local lua53 = _() or lua53 -- ./compiler/lua53.can:575
package["loaded"]["compiler.lua53"] = lua53 or true -- ./compiler/lua53.can:576
local function _() -- ./compiler/lua53.can:579
local function _() -- ./compiler/lua53.can:581
return function(code, ast, options) -- ./compiler/lua53.can:1
local lastInputPos = 1 -- last token position in the input code -- ./compiler/lua53.can:3
local prevLinePos = 1 -- last token position in the previous line of code in the input code -- ./compiler/lua53.can:4
local lastSource = options["chunkname"] or "nil" -- last found code source name (from the original file) -- ./compiler/lua53.can:5
local lastLine = 1 -- last found line number (from the original file) -- ./compiler/lua53.can:6
local indentLevel = 0 -- ./compiler/lua53.can:9
local function newline() -- ./compiler/lua53.can:11
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua53.can:12
if options["mapLines"] then -- ./compiler/lua53.can:13
local sub = code:sub(lastInputPos) -- ./compiler/lua53.can:14
local source, line = sub:sub(1, sub:find("\
")):match("%-%- (.-)%:(%d+)\
") -- ./compiler/lua53.can:15
if source and line then -- ./compiler/lua53.can:17
lastSource = source -- ./compiler/lua53.can:18
lastLine = tonumber(line) -- ./compiler/lua53.can:19
else -- ./compiler/lua53.can:19
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua53.can:21
lastLine = lastLine + (1) -- ./compiler/lua53.can:22
end -- ./compiler/lua53.can:22
end -- ./compiler/lua53.can:22
prevLinePos = lastInputPos -- ./compiler/lua53.can:26
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua53.can:28
end -- ./compiler/lua53.can:28
return r -- ./compiler/lua53.can:30
end -- ./compiler/lua53.can:30
local function indent() -- ./compiler/lua53.can:33
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:34
return newline() -- ./compiler/lua53.can:35
end -- ./compiler/lua53.can:35
local function unindent() -- ./compiler/lua53.can:38
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:39
return newline() -- ./compiler/lua53.can:40
end -- ./compiler/lua53.can:40
local required = {} -- { ["module"] = true, ... } -- ./compiler/lua53.can:44
local requireStr = "" -- ./compiler/lua53.can:45
local function addRequire(mod, name, field) -- ./compiler/lua53.can:47
if not required[mod] then -- ./compiler/lua53.can:48
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"]) -- ./compiler/lua53.can:49
required[mod] = true -- ./compiler/lua53.can:50
end -- ./compiler/lua53.can:50
end -- ./compiler/lua53.can:50
local function var(name) -- ./compiler/lua53.can:56
return options["variablePrefix"] .. name -- ./compiler/lua53.can:57
end -- ./compiler/lua53.can:57
local loop = { -- loops tags -- ./compiler/lua53.can:61
"While", -- loops tags -- ./compiler/lua53.can:61
"Repeat", -- loops tags -- ./compiler/lua53.can:61
"Fornum", -- loops tags -- ./compiler/lua53.can:61
"Forin" -- loops tags -- ./compiler/lua53.can:61
} -- loops tags -- ./compiler/lua53.can:61
local func = { -- function scope tags -- ./compiler/lua53.can:62
"Function", -- function scope tags -- ./compiler/lua53.can:62
"TableCompr", -- function scope tags -- ./compiler/lua53.can:62
"DoExpr", -- function scope tags -- ./compiler/lua53.can:62
"WhileExpr", -- function scope tags -- ./compiler/lua53.can:62
"RepeatExpr", -- function scope tags -- ./compiler/lua53.can:62
"IfExpr", -- function scope tags -- ./compiler/lua53.can:62
"FornumExpr", -- function scope tags -- ./compiler/lua53.can:62
"ForinExpr" -- function scope tags -- ./compiler/lua53.can:62
} -- function scope tags -- ./compiler/lua53.can:62
local function any(list, tags, nofollow) -- ./compiler/lua53.can:65
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:65
local tagsCheck = {} -- ./compiler/lua53.can:66
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:67
tagsCheck[tag] = true -- ./compiler/lua53.can:68
end -- ./compiler/lua53.can:68
local nofollowCheck = {} -- ./compiler/lua53.can:70
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:71
nofollowCheck[tag] = true -- ./compiler/lua53.can:72
end -- ./compiler/lua53.can:72
for _, node in ipairs(list) do -- ./compiler/lua53.can:74
if type(node) == "table" then -- ./compiler/lua53.can:75
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:76
return node -- ./compiler/lua53.can:77
end -- ./compiler/lua53.can:77
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:79
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:80
if r then -- ./compiler/lua53.can:81
return r -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
return nil -- ./compiler/lua53.can:85
end -- ./compiler/lua53.can:85
local states = { ["push"] = {} } -- push stack variable names -- ./compiler/lua53.can:91
local function push(name, state) -- ./compiler/lua53.can:94
table["insert"](states[name], state) -- ./compiler/lua53.can:95
return "" -- ./compiler/lua53.can:96
end -- ./compiler/lua53.can:96
local function pop(name) -- ./compiler/lua53.can:99
table["remove"](states[name]) -- ./compiler/lua53.can:100
return "" -- ./compiler/lua53.can:101
end -- ./compiler/lua53.can:101
local function peek(name) -- ./compiler/lua53.can:104
return states[name][# states[name]] -- ./compiler/lua53.can:105
end -- ./compiler/lua53.can:105
local tags -- ./compiler/lua53.can:109
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:111
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:112
lastInputPos = ast["pos"] -- ./compiler/lua53.can:113
end -- ./compiler/lua53.can:113
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:115
end -- ./compiler/lua53.can:115
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:119
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:122
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:123
end -- ./compiler/lua53.can:123
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:125
return "do" .. indent() -- ./compiler/lua53.can:126
end -- ./compiler/lua53.can:126
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:128
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
tags = setmetatable({ -- ./compiler/lua53.can:133
["Block"] = function(t) -- ./compiler/lua53.can:135
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:136
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:137
hasPush["tag"] = "Return" -- ./compiler/lua53.can:138
hasPush = false -- ./compiler/lua53.can:139
end -- ./compiler/lua53.can:139
local r = "" -- ./compiler/lua53.can:141
if hasPush then -- ./compiler/lua53.can:142
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:145
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:146
end -- ./compiler/lua53.can:146
if t[# t] then -- ./compiler/lua53.can:148
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:149
end -- ./compiler/lua53.can:149
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:151
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:152
end -- ./compiler/lua53.can:152
return r -- ./compiler/lua53.can:154
end, -- ./compiler/lua53.can:154
["Do"] = function(t) -- ./compiler/lua53.can:160
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:161
end, -- ./compiler/lua53.can:161
["Set"] = function(t) -- ./compiler/lua53.can:164
if # t == 2 then -- ./compiler/lua53.can:165
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs") -- ./compiler/lua53.can:166
elseif # t == 3 then -- ./compiler/lua53.can:167
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs") -- ./compiler/lua53.can:168
elseif # t == 4 then -- ./compiler/lua53.can:169
if t[3] == "=" then -- ./compiler/lua53.can:170
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:171
t[2], -- ./compiler/lua53.can:171
t[1][1], -- ./compiler/lua53.can:171
{ -- ./compiler/lua53.can:171
["tag"] = "Paren", -- ./compiler/lua53.can:171
t[4][1] -- ./compiler/lua53.can:171
} -- ./compiler/lua53.can:171
}, "Op") -- ./compiler/lua53.can:171
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:172
r = r .. (", " .. lua({ -- ./compiler/lua53.can:173
t[2], -- ./compiler/lua53.can:173
t[1][i], -- ./compiler/lua53.can:173
{ -- ./compiler/lua53.can:173
["tag"] = "Paren", -- ./compiler/lua53.can:173
t[4][i] -- ./compiler/lua53.can:173
} -- ./compiler/lua53.can:173
}, "Op")) -- ./compiler/lua53.can:173
end -- ./compiler/lua53.can:173
return r -- ./compiler/lua53.can:175
else -- ./compiler/lua53.can:175
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:177
t[3], -- ./compiler/lua53.can:177
{ -- ./compiler/lua53.can:177
["tag"] = "Paren", -- ./compiler/lua53.can:177
t[4][1] -- ./compiler/lua53.can:177
}, -- ./compiler/lua53.can:177
t[1][1] -- ./compiler/lua53.can:177
}, "Op") -- ./compiler/lua53.can:177
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:178
r = r .. (", " .. lua({ -- ./compiler/lua53.can:179
t[3], -- ./compiler/lua53.can:179
{ -- ./compiler/lua53.can:179
["tag"] = "Paren", -- ./compiler/lua53.can:179
t[4][i] -- ./compiler/lua53.can:179
}, -- ./compiler/lua53.can:179
t[1][i] -- ./compiler/lua53.can:179
}, "Op")) -- ./compiler/lua53.can:179
end -- ./compiler/lua53.can:179
return r -- ./compiler/lua53.can:181
end -- ./compiler/lua53.can:181
else -- ./compiler/lua53.can:181
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:184
t[2], -- ./compiler/lua53.can:184
t[1][1], -- ./compiler/lua53.can:184
{ -- ./compiler/lua53.can:184
["tag"] = "Op", -- ./compiler/lua53.can:184
t[4], -- ./compiler/lua53.can:184
{ -- ./compiler/lua53.can:184
["tag"] = "Paren", -- ./compiler/lua53.can:184
t[5][1] -- ./compiler/lua53.can:184
}, -- ./compiler/lua53.can:184
t[1][1] -- ./compiler/lua53.can:184
} -- ./compiler/lua53.can:184
}, "Op") -- ./compiler/lua53.can:184
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:185
r = r .. (", " .. lua({ -- ./compiler/lua53.can:186
t[2], -- ./compiler/lua53.can:186
t[1][i], -- ./compiler/lua53.can:186
{ -- ./compiler/lua53.can:186
["tag"] = "Op", -- ./compiler/lua53.can:186
t[4], -- ./compiler/lua53.can:186
{ -- ./compiler/lua53.can:186
["tag"] = "Paren", -- ./compiler/lua53.can:186
t[5][i] -- ./compiler/lua53.can:186
}, -- ./compiler/lua53.can:186
t[1][i] -- ./compiler/lua53.can:186
} -- ./compiler/lua53.can:186
}, "Op")) -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
return r -- ./compiler/lua53.can:188
end -- ./compiler/lua53.can:188
end, -- ./compiler/lua53.can:188
["While"] = function(t) -- ./compiler/lua53.can:192
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:193
local r = "while " .. lua(t[1]) .. " do" .. indent() -- ./compiler/lua53.can:194
if hasContinue then -- ./compiler/lua53.can:195
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:196
end -- ./compiler/lua53.can:196
r = r .. (lua(t[2])) -- ./compiler/lua53.can:198
if hasContinue then -- ./compiler/lua53.can:199
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:200
end -- ./compiler/lua53.can:200
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:202
return r -- ./compiler/lua53.can:203
end, -- ./compiler/lua53.can:203
["Repeat"] = function(t) -- ./compiler/lua53.can:206
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:207
local r = "repeat" .. indent() -- ./compiler/lua53.can:208
if hasContinue then -- ./compiler/lua53.can:209
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:210
end -- ./compiler/lua53.can:210
r = r .. (lua(t[1])) -- ./compiler/lua53.can:212
if hasContinue then -- ./compiler/lua53.can:213
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:214
end -- ./compiler/lua53.can:214
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:216
return r -- ./compiler/lua53.can:217
end, -- ./compiler/lua53.can:217
["If"] = function(t) -- ./compiler/lua53.can:220
local r = "if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent() -- ./compiler/lua53.can:221
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:222
r = r .. ("elseif " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:223
end -- ./compiler/lua53.can:223
if # t % 2 == 1 then -- ./compiler/lua53.can:225
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:226
end -- ./compiler/lua53.can:226
return r .. "end" -- ./compiler/lua53.can:228
end, -- ./compiler/lua53.can:228
["Fornum"] = function(t) -- ./compiler/lua53.can:231
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:232
if # t == 5 then -- ./compiler/lua53.can:233
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:234
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:235
if hasContinue then -- ./compiler/lua53.can:236
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:237
end -- ./compiler/lua53.can:237
r = r .. (lua(t[5])) -- ./compiler/lua53.can:239
if hasContinue then -- ./compiler/lua53.can:240
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:241
end -- ./compiler/lua53.can:241
return r .. unindent() .. "end" -- ./compiler/lua53.can:243
else -- ./compiler/lua53.can:243
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:245
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:246
if hasContinue then -- ./compiler/lua53.can:247
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:248
end -- ./compiler/lua53.can:248
r = r .. (lua(t[4])) -- ./compiler/lua53.can:250
if hasContinue then -- ./compiler/lua53.can:251
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:252
end -- ./compiler/lua53.can:252
return r .. unindent() .. "end" -- ./compiler/lua53.can:254
end -- ./compiler/lua53.can:254
end, -- ./compiler/lua53.can:254
["Forin"] = function(t) -- ./compiler/lua53.can:258
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:259
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:260
if hasContinue then -- ./compiler/lua53.can:261
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:262
end -- ./compiler/lua53.can:262
r = r .. (lua(t[3])) -- ./compiler/lua53.can:264
if hasContinue then -- ./compiler/lua53.can:265
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:266
end -- ./compiler/lua53.can:266
return r .. unindent() .. "end" -- ./compiler/lua53.can:268
end, -- ./compiler/lua53.can:268
["Local"] = function(t) -- ./compiler/lua53.can:271
local r = "local " .. lua(t[1], "_lhs") -- ./compiler/lua53.can:272
if t[2][1] then -- ./compiler/lua53.can:273
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:274
end -- ./compiler/lua53.can:274
return r -- ./compiler/lua53.can:276
end, -- ./compiler/lua53.can:276
["Let"] = function(t) -- ./compiler/lua53.can:279
local nameList = lua(t[1], "_lhs") -- ./compiler/lua53.can:280
local r = "local " .. nameList -- ./compiler/lua53.can:281
if t[2][1] then -- ./compiler/lua53.can:282
if any(t[2], { -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Function", -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Table", -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Paren" -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
}) then -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:284
else -- ./compiler/lua53.can:284
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:286
end -- ./compiler/lua53.can:286
end -- ./compiler/lua53.can:286
return r -- ./compiler/lua53.can:289
end, -- ./compiler/lua53.can:289
["Localrec"] = function(t) -- ./compiler/lua53.can:292
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:293
end, -- ./compiler/lua53.can:293
["Goto"] = function(t) -- ./compiler/lua53.can:296
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:297
end, -- ./compiler/lua53.can:297
["Label"] = function(t) -- ./compiler/lua53.can:300
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:301
end, -- ./compiler/lua53.can:301
["Return"] = function(t) -- ./compiler/lua53.can:304
local push = peek("push") -- ./compiler/lua53.can:305
if push then -- ./compiler/lua53.can:306
local r = "" -- ./compiler/lua53.can:307
for _, val in ipairs(t) do -- ./compiler/lua53.can:308
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:309
end -- ./compiler/lua53.can:309
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:311
else -- ./compiler/lua53.can:311
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:313
end -- ./compiler/lua53.can:313
end, -- ./compiler/lua53.can:313
["Push"] = function(t) -- ./compiler/lua53.can:317
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:318
r = "" -- ./compiler/lua53.can:319
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:320
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:321
end -- ./compiler/lua53.can:321
if t[# t] then -- ./compiler/lua53.can:323
if t[# t]["tag"] == "Call" or t[# t]["tag"] == "Invoke" then -- ./compiler/lua53.can:324
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:325
else -- ./compiler/lua53.can:325
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:327
end -- ./compiler/lua53.can:327
end -- ./compiler/lua53.can:327
return r -- ./compiler/lua53.can:330
end, -- ./compiler/lua53.can:330
["Break"] = function() -- ./compiler/lua53.can:333
return "break" -- ./compiler/lua53.can:334
end, -- ./compiler/lua53.can:334
["Continue"] = function() -- ./compiler/lua53.can:337
return "goto " .. var("continue") -- ./compiler/lua53.can:338
end, -- ./compiler/lua53.can:338
["Nil"] = function() -- ./compiler/lua53.can:345
return "nil" -- ./compiler/lua53.can:346
end, -- ./compiler/lua53.can:346
["Dots"] = function() -- ./compiler/lua53.can:349
return "..." -- ./compiler/lua53.can:350
end, -- ./compiler/lua53.can:350
["Boolean"] = function(t) -- ./compiler/lua53.can:353
return tostring(t[1]) -- ./compiler/lua53.can:354
end, -- ./compiler/lua53.can:354
["Number"] = function(t) -- ./compiler/lua53.can:357
return tostring(t[1]) -- ./compiler/lua53.can:358
end, -- ./compiler/lua53.can:358
["String"] = function(t) -- ./compiler/lua53.can:361
return ("%q"):format(t[1]) -- ./compiler/lua53.can:362
end, -- ./compiler/lua53.can:362
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:365
local r = "(" -- ./compiler/lua53.can:366
local decl = {} -- ./compiler/lua53.can:367
if t[1][1] then -- ./compiler/lua53.can:368
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:369
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:370
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:371
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:372
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:373
r = r .. (id) -- ./compiler/lua53.can:374
else -- ./compiler/lua53.can:374
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:376
end -- ./compiler/lua53.can:376
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:378
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:379
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:380
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:381
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:382
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:383
r = r .. (", " .. id) -- ./compiler/lua53.can:384
else -- ./compiler/lua53.can:384
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
r = r .. (")" .. indent()) -- ./compiler/lua53.can:390
for _, d in ipairs(decl) do -- ./compiler/lua53.can:391
r = r .. (d .. newline()) -- ./compiler/lua53.can:392
end -- ./compiler/lua53.can:392
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:394
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:395
end -- ./compiler/lua53.can:395
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:397
if hasPush then -- ./compiler/lua53.can:398
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:399
else -- ./compiler/lua53.can:399
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:401
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:401
r = r .. (lua(t[2])) -- ./compiler/lua53.can:403
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:404
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:405
end -- ./compiler/lua53.can:405
pop("push") -- ./compiler/lua53.can:407
return r .. unindent() .. "end" -- ./compiler/lua53.can:408
end, -- ./compiler/lua53.can:408
["Function"] = function(t) -- ./compiler/lua53.can:410
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:411
end, -- ./compiler/lua53.can:411
["Pair"] = function(t) -- ./compiler/lua53.can:414
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:415
end, -- ./compiler/lua53.can:415
["Table"] = function(t) -- ./compiler/lua53.can:417
if # t == 0 then -- ./compiler/lua53.can:418
return "{}" -- ./compiler/lua53.can:419
elseif # t == 1 then -- ./compiler/lua53.can:420
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:421
else -- ./compiler/lua53.can:421
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:423
end -- ./compiler/lua53.can:423
end, -- ./compiler/lua53.can:423
["TableCompr"] = function(t) -- ./compiler/lua53.can:427
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:428
end, -- ./compiler/lua53.can:428
["Op"] = function(t) -- ./compiler/lua53.can:431
local r -- ./compiler/lua53.can:432
if # t == 2 then -- ./compiler/lua53.can:433
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:434
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:435
else -- ./compiler/lua53.can:435
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:437
end -- ./compiler/lua53.can:437
else -- ./compiler/lua53.can:437
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:440
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:441
else -- ./compiler/lua53.can:441
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:443
end -- ./compiler/lua53.can:443
end -- ./compiler/lua53.can:443
return r -- ./compiler/lua53.can:446
end, -- ./compiler/lua53.can:446
["Paren"] = function(t) -- ./compiler/lua53.can:449
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:450
end, -- ./compiler/lua53.can:450
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:457
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:458
local r = "(function()" .. indent() -- ./compiler/lua53.can:459
if hasPush then -- ./compiler/lua53.can:460
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:461
else -- ./compiler/lua53.can:461
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:463
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:463
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:465
if hasPush then -- ./compiler/lua53.can:466
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:467
end -- ./compiler/lua53.can:467
pop("push") -- ./compiler/lua53.can:469
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:470
return r -- ./compiler/lua53.can:471
end, -- ./compiler/lua53.can:471
["DoExpr"] = function(t) -- ./compiler/lua53.can:474
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:475
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:476
end -- ./compiler/lua53.can:476
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:478
end, -- ./compiler/lua53.can:478
["WhileExpr"] = function(t) -- ./compiler/lua53.can:481
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:482
end, -- ./compiler/lua53.can:482
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:485
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:486
end, -- ./compiler/lua53.can:486
["IfExpr"] = function(t) -- ./compiler/lua53.can:489
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:490
local block = t[i] -- ./compiler/lua53.can:491
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:492
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:496
end, -- ./compiler/lua53.can:496
["FornumExpr"] = function(t) -- ./compiler/lua53.can:499
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:500
end, -- ./compiler/lua53.can:500
["ForinExpr"] = function(t) -- ./compiler/lua53.can:503
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:504
end, -- ./compiler/lua53.can:504
["Call"] = function(t) -- ./compiler/lua53.can:510
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:511
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:512
else -- ./compiler/lua53.can:512
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:514
end -- ./compiler/lua53.can:514
end, -- ./compiler/lua53.can:514
["Invoke"] = function(t) -- ./compiler/lua53.can:519
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:520
return "(" .. lua(t[1]) .. "):" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")" -- ./compiler/lua53.can:521
else -- ./compiler/lua53.can:521
return lua(t[1]) .. ":" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")" -- ./compiler/lua53.can:523
end -- ./compiler/lua53.can:523
end, -- ./compiler/lua53.can:523
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:528
if start == nil then start = 1 end -- ./compiler/lua53.can:528
local r -- ./compiler/lua53.can:529
if t[start] then -- ./compiler/lua53.can:530
r = lua(t[start]) -- ./compiler/lua53.can:531
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:532
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:533
end -- ./compiler/lua53.can:533
else -- ./compiler/lua53.can:533
r = "" -- ./compiler/lua53.can:536
end -- ./compiler/lua53.can:536
return r -- ./compiler/lua53.can:538
end, -- ./compiler/lua53.can:538
["Id"] = function(t) -- ./compiler/lua53.can:541
return t[1] -- ./compiler/lua53.can:542
end, -- ./compiler/lua53.can:542
["Index"] = function(t) -- ./compiler/lua53.can:545
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:546
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:547
else -- ./compiler/lua53.can:547
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:549
end -- ./compiler/lua53.can:549
end, -- ./compiler/lua53.can:549
["_opid"] = { -- ./compiler/lua53.can:554
["add"] = "+", -- ./compiler/lua53.can:555
["sub"] = "-", -- ./compiler/lua53.can:555
["mul"] = "*", -- ./compiler/lua53.can:555
["div"] = "/", -- ./compiler/lua53.can:555
["idiv"] = "//", -- ./compiler/lua53.can:556
["mod"] = "%", -- ./compiler/lua53.can:556
["pow"] = "^", -- ./compiler/lua53.can:556
["concat"] = "..", -- ./compiler/lua53.can:556
["band"] = "&", -- ./compiler/lua53.can:557
["bor"] = "|", -- ./compiler/lua53.can:557
["bxor"] = "~", -- ./compiler/lua53.can:557
["shl"] = "<<", -- ./compiler/lua53.can:557
["shr"] = ">>", -- ./compiler/lua53.can:557
["eq"] = "==", -- ./compiler/lua53.can:558
["ne"] = "~=", -- ./compiler/lua53.can:558
["lt"] = "<", -- ./compiler/lua53.can:558
["gt"] = ">", -- ./compiler/lua53.can:558
["le"] = "<=", -- ./compiler/lua53.can:558
["ge"] = ">=", -- ./compiler/lua53.can:558
["and"] = "and", -- ./compiler/lua53.can:559
["or"] = "or", -- ./compiler/lua53.can:559
["unm"] = "-", -- ./compiler/lua53.can:559
["len"] = "#", -- ./compiler/lua53.can:559
["bnot"] = "~", -- ./compiler/lua53.can:559
["not"] = "not" -- ./compiler/lua53.can:559
} -- ./compiler/lua53.can:559
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:562
error("don't know how to compile a " .. tostring(key) .. " to Lua 5.3") -- ./compiler/lua53.can:563
end }) -- ./compiler/lua53.can:563
UNPACK = function(list, i, j) -- ./compiler/luajit.can:1
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/luajit.can:2
end -- ./compiler/luajit.can:2
APPEND = function(t, toAppend) -- ./compiler/luajit.can:4
return "do" .. indent() .. "local a, p = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #a do" .. indent() .. t .. "[p] = a[i]" .. newline() .. "p = p + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/luajit.can:5
end -- ./compiler/luajit.can:5
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/luajit.can:8
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/luajit.can:9
end -- ./compiler/luajit.can:9
tags["_opid"]["band"] = function(left, right) -- ./compiler/luajit.can:11
addRequire("bit", "band", "band") -- ./compiler/luajit.can:12
return var("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:13
end -- ./compiler/luajit.can:13
tags["_opid"]["bor"] = function(left, right) -- ./compiler/luajit.can:15
addRequire("bit", "bor", "bor") -- ./compiler/luajit.can:16
return var("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:17
end -- ./compiler/luajit.can:17
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/luajit.can:19
addRequire("bit", "bxor", "bxor") -- ./compiler/luajit.can:20
return var("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:21
end -- ./compiler/luajit.can:21
tags["_opid"]["shl"] = function(left, right) -- ./compiler/luajit.can:23
addRequire("bit", "lshift", "lshift") -- ./compiler/luajit.can:24
return var("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:25
end -- ./compiler/luajit.can:25
tags["_opid"]["shr"] = function(left, right) -- ./compiler/luajit.can:27
addRequire("bit", "rshift", "rshift") -- ./compiler/luajit.can:28
return var("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:29
end -- ./compiler/luajit.can:29
tags["_opid"]["bnot"] = function(right) -- ./compiler/luajit.can:31
addRequire("bit", "bnot", "bnot") -- ./compiler/luajit.can:32
return var("bnot") .. "(" .. lua(right) .. ")" -- ./compiler/luajit.can:33
end -- ./compiler/luajit.can:33
local code = lua(ast) .. newline() -- ./compiler/lua53.can:569
return requireStr .. code -- ./compiler/lua53.can:570
end -- ./compiler/lua53.can:570
end -- ./compiler/lua53.can:570
local lua53 = _() or lua53 -- ./compiler/lua53.can:575
return lua53 -- ./compiler/luajit.can:42
end -- ./compiler/luajit.can:42
local luajit = _() or luajit -- ./compiler/luajit.can:46
package["loaded"]["compiler.luajit"] = luajit or true -- ./compiler/luajit.can:47
local function _() -- ./compiler/luajit.can:50
local function _() -- ./compiler/luajit.can:52
local function _() -- ./compiler/luajit.can:54
return function(code, ast, options) -- ./compiler/lua53.can:1
local lastInputPos = 1 -- last token position in the input code -- ./compiler/lua53.can:3
local prevLinePos = 1 -- last token position in the previous line of code in the input code -- ./compiler/lua53.can:4
local lastSource = options["chunkname"] or "nil" -- last found code source name (from the original file) -- ./compiler/lua53.can:5
local lastLine = 1 -- last found line number (from the original file) -- ./compiler/lua53.can:6
local indentLevel = 0 -- ./compiler/lua53.can:9
local function newline() -- ./compiler/lua53.can:11
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel) -- ./compiler/lua53.can:12
if options["mapLines"] then -- ./compiler/lua53.can:13
local sub = code:sub(lastInputPos) -- ./compiler/lua53.can:14
local source, line = sub:sub(1, sub:find("\
")):match("%-%- (.-)%:(%d+)\
") -- ./compiler/lua53.can:15
if source and line then -- ./compiler/lua53.can:17
lastSource = source -- ./compiler/lua53.can:18
lastLine = tonumber(line) -- ./compiler/lua53.can:19
else -- ./compiler/lua53.can:19
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do -- ./compiler/lua53.can:21
lastLine = lastLine + (1) -- ./compiler/lua53.can:22
end -- ./compiler/lua53.can:22
end -- ./compiler/lua53.can:22
prevLinePos = lastInputPos -- ./compiler/lua53.can:26
r = " -- " .. lastSource .. ":" .. lastLine .. r -- ./compiler/lua53.can:28
end -- ./compiler/lua53.can:28
return r -- ./compiler/lua53.can:30
end -- ./compiler/lua53.can:30
local function indent() -- ./compiler/lua53.can:33
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:34
return newline() -- ./compiler/lua53.can:35
end -- ./compiler/lua53.can:35
local function unindent() -- ./compiler/lua53.can:38
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:39
return newline() -- ./compiler/lua53.can:40
end -- ./compiler/lua53.can:40
local required = {} -- { ["module"] = true, ... } -- ./compiler/lua53.can:44
local requireStr = "" -- ./compiler/lua53.can:45
local function addRequire(mod, name, field) -- ./compiler/lua53.can:47
if not required[mod] then -- ./compiler/lua53.can:48
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"]) -- ./compiler/lua53.can:49
required[mod] = true -- ./compiler/lua53.can:50
end -- ./compiler/lua53.can:50
end -- ./compiler/lua53.can:50
local function var(name) -- ./compiler/lua53.can:56
return options["variablePrefix"] .. name -- ./compiler/lua53.can:57
end -- ./compiler/lua53.can:57
local loop = { -- loops tags -- ./compiler/lua53.can:61
"While", -- loops tags -- ./compiler/lua53.can:61
"Repeat", -- loops tags -- ./compiler/lua53.can:61
"Fornum", -- loops tags -- ./compiler/lua53.can:61
"Forin" -- loops tags -- ./compiler/lua53.can:61
} -- loops tags -- ./compiler/lua53.can:61
local func = { -- function scope tags -- ./compiler/lua53.can:62
"Function", -- function scope tags -- ./compiler/lua53.can:62
"TableCompr", -- function scope tags -- ./compiler/lua53.can:62
"DoExpr", -- function scope tags -- ./compiler/lua53.can:62
"WhileExpr", -- function scope tags -- ./compiler/lua53.can:62
"RepeatExpr", -- function scope tags -- ./compiler/lua53.can:62
"IfExpr", -- function scope tags -- ./compiler/lua53.can:62
"FornumExpr", -- function scope tags -- ./compiler/lua53.can:62
"ForinExpr" -- function scope tags -- ./compiler/lua53.can:62
} -- function scope tags -- ./compiler/lua53.can:62
local function any(list, tags, nofollow) -- ./compiler/lua53.can:65
if nofollow == nil then nofollow = {} end -- ./compiler/lua53.can:65
local tagsCheck = {} -- ./compiler/lua53.can:66
for _, tag in ipairs(tags) do -- ./compiler/lua53.can:67
tagsCheck[tag] = true -- ./compiler/lua53.can:68
end -- ./compiler/lua53.can:68
local nofollowCheck = {} -- ./compiler/lua53.can:70
for _, tag in ipairs(nofollow) do -- ./compiler/lua53.can:71
nofollowCheck[tag] = true -- ./compiler/lua53.can:72
end -- ./compiler/lua53.can:72
for _, node in ipairs(list) do -- ./compiler/lua53.can:74
if type(node) == "table" then -- ./compiler/lua53.can:75
if tagsCheck[node["tag"]] then -- ./compiler/lua53.can:76
return node -- ./compiler/lua53.can:77
end -- ./compiler/lua53.can:77
if not nofollowCheck[node["tag"]] then -- ./compiler/lua53.can:79
local r = any(node, tags, nofollow) -- ./compiler/lua53.can:80
if r then -- ./compiler/lua53.can:81
return r -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
end -- ./compiler/lua53.can:81
return nil -- ./compiler/lua53.can:85
end -- ./compiler/lua53.can:85
local states = { ["push"] = {} } -- push stack variable names -- ./compiler/lua53.can:91
local function push(name, state) -- ./compiler/lua53.can:94
table["insert"](states[name], state) -- ./compiler/lua53.can:95
return "" -- ./compiler/lua53.can:96
end -- ./compiler/lua53.can:96
local function pop(name) -- ./compiler/lua53.can:99
table["remove"](states[name]) -- ./compiler/lua53.can:100
return "" -- ./compiler/lua53.can:101
end -- ./compiler/lua53.can:101
local function peek(name) -- ./compiler/lua53.can:104
return states[name][# states[name]] -- ./compiler/lua53.can:105
end -- ./compiler/lua53.can:105
local tags -- ./compiler/lua53.can:109
local function lua(ast, forceTag, ...) -- ./compiler/lua53.can:111
if options["mapLines"] and ast["pos"] then -- ./compiler/lua53.can:112
lastInputPos = ast["pos"] -- ./compiler/lua53.can:113
end -- ./compiler/lua53.can:113
return tags[forceTag or ast["tag"]](ast, ...) -- ./compiler/lua53.can:115
end -- ./compiler/lua53.can:115
local UNPACK = function(list, i, j) -- table.unpack -- ./compiler/lua53.can:119
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/lua53.can:120
end -- ./compiler/lua53.can:120
local APPEND = function(t, toAppend) -- append values "toAppend" (multiple values possible) to t -- ./compiler/lua53.can:122
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end" -- ./compiler/lua53.can:123
end -- ./compiler/lua53.can:123
local CONTINUE_START = function() -- at the start of loops using continue -- ./compiler/lua53.can:125
return "do" .. indent() -- ./compiler/lua53.can:126
end -- ./compiler/lua53.can:126
local CONTINUE_STOP = function() -- at the start of loops using continue -- ./compiler/lua53.can:128
return unindent() .. "end" .. newline() .. "::" .. var("continue") .. "::" -- ./compiler/lua53.can:129
end -- ./compiler/lua53.can:129
tags = setmetatable({ -- ./compiler/lua53.can:133
["Block"] = function(t) -- ./compiler/lua53.can:135
local hasPush = peek("push") == nil and any(t, { "Push" }, func) -- push in block and push context not yet defined -- ./compiler/lua53.can:136
if hasPush and hasPush == t[# t] then -- if the first push is the last statement, it's just a return -- ./compiler/lua53.can:137
hasPush["tag"] = "Return" -- ./compiler/lua53.can:138
hasPush = false -- ./compiler/lua53.can:139
end -- ./compiler/lua53.can:139
local r = "" -- ./compiler/lua53.can:141
if hasPush then -- ./compiler/lua53.can:142
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:143
end -- ./compiler/lua53.can:143
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:145
r = r .. (lua(t[i]) .. newline()) -- ./compiler/lua53.can:146
end -- ./compiler/lua53.can:146
if t[# t] then -- ./compiler/lua53.can:148
r = r .. (lua(t[# t])) -- ./compiler/lua53.can:149
end -- ./compiler/lua53.can:149
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:151
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push")) -- ./compiler/lua53.can:152
end -- ./compiler/lua53.can:152
return r -- ./compiler/lua53.can:154
end, -- ./compiler/lua53.can:154
["Do"] = function(t) -- ./compiler/lua53.can:160
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end" -- ./compiler/lua53.can:161
end, -- ./compiler/lua53.can:161
["Set"] = function(t) -- ./compiler/lua53.can:164
if # t == 2 then -- ./compiler/lua53.can:165
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs") -- ./compiler/lua53.can:166
elseif # t == 3 then -- ./compiler/lua53.can:167
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs") -- ./compiler/lua53.can:168
elseif # t == 4 then -- ./compiler/lua53.can:169
if t[3] == "=" then -- ./compiler/lua53.can:170
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:171
t[2], -- ./compiler/lua53.can:171
t[1][1], -- ./compiler/lua53.can:171
{ -- ./compiler/lua53.can:171
["tag"] = "Paren", -- ./compiler/lua53.can:171
t[4][1] -- ./compiler/lua53.can:171
} -- ./compiler/lua53.can:171
}, "Op") -- ./compiler/lua53.can:171
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:172
r = r .. (", " .. lua({ -- ./compiler/lua53.can:173
t[2], -- ./compiler/lua53.can:173
t[1][i], -- ./compiler/lua53.can:173
{ -- ./compiler/lua53.can:173
["tag"] = "Paren", -- ./compiler/lua53.can:173
t[4][i] -- ./compiler/lua53.can:173
} -- ./compiler/lua53.can:173
}, "Op")) -- ./compiler/lua53.can:173
end -- ./compiler/lua53.can:173
return r -- ./compiler/lua53.can:175
else -- ./compiler/lua53.can:175
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:177
t[3], -- ./compiler/lua53.can:177
{ -- ./compiler/lua53.can:177
["tag"] = "Paren", -- ./compiler/lua53.can:177
t[4][1] -- ./compiler/lua53.can:177
}, -- ./compiler/lua53.can:177
t[1][1] -- ./compiler/lua53.can:177
}, "Op") -- ./compiler/lua53.can:177
for i = 2, math["min"](# t[4], # t[1]), 1 do -- ./compiler/lua53.can:178
r = r .. (", " .. lua({ -- ./compiler/lua53.can:179
t[3], -- ./compiler/lua53.can:179
{ -- ./compiler/lua53.can:179
["tag"] = "Paren", -- ./compiler/lua53.can:179
t[4][i] -- ./compiler/lua53.can:179
}, -- ./compiler/lua53.can:179
t[1][i] -- ./compiler/lua53.can:179
}, "Op")) -- ./compiler/lua53.can:179
end -- ./compiler/lua53.can:179
return r -- ./compiler/lua53.can:181
end -- ./compiler/lua53.can:181
else -- ./compiler/lua53.can:181
local r = lua(t[1], "_lhs") .. " = " .. lua({ -- ./compiler/lua53.can:184
t[2], -- ./compiler/lua53.can:184
t[1][1], -- ./compiler/lua53.can:184
{ -- ./compiler/lua53.can:184
["tag"] = "Op", -- ./compiler/lua53.can:184
t[4], -- ./compiler/lua53.can:184
{ -- ./compiler/lua53.can:184
["tag"] = "Paren", -- ./compiler/lua53.can:184
t[5][1] -- ./compiler/lua53.can:184
}, -- ./compiler/lua53.can:184
t[1][1] -- ./compiler/lua53.can:184
} -- ./compiler/lua53.can:184
}, "Op") -- ./compiler/lua53.can:184
for i = 2, math["min"](# t[5], # t[1]), 1 do -- ./compiler/lua53.can:185
r = r .. (", " .. lua({ -- ./compiler/lua53.can:186
t[2], -- ./compiler/lua53.can:186
t[1][i], -- ./compiler/lua53.can:186
{ -- ./compiler/lua53.can:186
["tag"] = "Op", -- ./compiler/lua53.can:186
t[4], -- ./compiler/lua53.can:186
{ -- ./compiler/lua53.can:186
["tag"] = "Paren", -- ./compiler/lua53.can:186
t[5][i] -- ./compiler/lua53.can:186
}, -- ./compiler/lua53.can:186
t[1][i] -- ./compiler/lua53.can:186
} -- ./compiler/lua53.can:186
}, "Op")) -- ./compiler/lua53.can:186
end -- ./compiler/lua53.can:186
return r -- ./compiler/lua53.can:188
end -- ./compiler/lua53.can:188
end, -- ./compiler/lua53.can:188
["While"] = function(t) -- ./compiler/lua53.can:192
local hasContinue = any(t[2], { "Continue" }, loop) -- ./compiler/lua53.can:193
local r = "while " .. lua(t[1]) .. " do" .. indent() -- ./compiler/lua53.can:194
if hasContinue then -- ./compiler/lua53.can:195
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:196
end -- ./compiler/lua53.can:196
r = r .. (lua(t[2])) -- ./compiler/lua53.can:198
if hasContinue then -- ./compiler/lua53.can:199
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:200
end -- ./compiler/lua53.can:200
r = r .. (unindent() .. "end") -- ./compiler/lua53.can:202
return r -- ./compiler/lua53.can:203
end, -- ./compiler/lua53.can:203
["Repeat"] = function(t) -- ./compiler/lua53.can:206
local hasContinue = any(t[1], { "Continue" }, loop) -- ./compiler/lua53.can:207
local r = "repeat" .. indent() -- ./compiler/lua53.can:208
if hasContinue then -- ./compiler/lua53.can:209
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:210
end -- ./compiler/lua53.can:210
r = r .. (lua(t[1])) -- ./compiler/lua53.can:212
if hasContinue then -- ./compiler/lua53.can:213
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:214
end -- ./compiler/lua53.can:214
r = r .. (unindent() .. "until " .. lua(t[2])) -- ./compiler/lua53.can:216
return r -- ./compiler/lua53.can:217
end, -- ./compiler/lua53.can:217
["If"] = function(t) -- ./compiler/lua53.can:220
local r = "if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent() -- ./compiler/lua53.can:221
for i = 3, # t - 1, 2 do -- ./compiler/lua53.can:222
r = r .. ("elseif " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent()) -- ./compiler/lua53.can:223
end -- ./compiler/lua53.can:223
if # t % 2 == 1 then -- ./compiler/lua53.can:225
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent()) -- ./compiler/lua53.can:226
end -- ./compiler/lua53.can:226
return r .. "end" -- ./compiler/lua53.can:228
end, -- ./compiler/lua53.can:228
["Fornum"] = function(t) -- ./compiler/lua53.can:231
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3]) -- ./compiler/lua53.can:232
if # t == 5 then -- ./compiler/lua53.can:233
local hasContinue = any(t[5], { "Continue" }, loop) -- ./compiler/lua53.can:234
r = r .. (", " .. lua(t[4]) .. " do" .. indent()) -- ./compiler/lua53.can:235
if hasContinue then -- ./compiler/lua53.can:236
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:237
end -- ./compiler/lua53.can:237
r = r .. (lua(t[5])) -- ./compiler/lua53.can:239
if hasContinue then -- ./compiler/lua53.can:240
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:241
end -- ./compiler/lua53.can:241
return r .. unindent() .. "end" -- ./compiler/lua53.can:243
else -- ./compiler/lua53.can:243
local hasContinue = any(t[4], { "Continue" }, loop) -- ./compiler/lua53.can:245
r = r .. (" do" .. indent()) -- ./compiler/lua53.can:246
if hasContinue then -- ./compiler/lua53.can:247
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:248
end -- ./compiler/lua53.can:248
r = r .. (lua(t[4])) -- ./compiler/lua53.can:250
if hasContinue then -- ./compiler/lua53.can:251
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:252
end -- ./compiler/lua53.can:252
return r .. unindent() .. "end" -- ./compiler/lua53.can:254
end -- ./compiler/lua53.can:254
end, -- ./compiler/lua53.can:254
["Forin"] = function(t) -- ./compiler/lua53.can:258
local hasContinue = any(t[3], { "Continue" }, loop) -- ./compiler/lua53.can:259
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent() -- ./compiler/lua53.can:260
if hasContinue then -- ./compiler/lua53.can:261
r = r .. (CONTINUE_START()) -- ./compiler/lua53.can:262
end -- ./compiler/lua53.can:262
r = r .. (lua(t[3])) -- ./compiler/lua53.can:264
if hasContinue then -- ./compiler/lua53.can:265
r = r .. (CONTINUE_STOP()) -- ./compiler/lua53.can:266
end -- ./compiler/lua53.can:266
return r .. unindent() .. "end" -- ./compiler/lua53.can:268
end, -- ./compiler/lua53.can:268
["Local"] = function(t) -- ./compiler/lua53.can:271
local r = "local " .. lua(t[1], "_lhs") -- ./compiler/lua53.can:272
if t[2][1] then -- ./compiler/lua53.can:273
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:274
end -- ./compiler/lua53.can:274
return r -- ./compiler/lua53.can:276
end, -- ./compiler/lua53.can:276
["Let"] = function(t) -- ./compiler/lua53.can:279
local nameList = lua(t[1], "_lhs") -- ./compiler/lua53.can:280
local r = "local " .. nameList -- ./compiler/lua53.can:281
if t[2][1] then -- ./compiler/lua53.can:282
if any(t[2], { -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Function", -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Table", -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
"Paren" -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
}) then -- predeclaration doesn't matter otherwise -- ./compiler/lua53.can:283
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:284
else -- ./compiler/lua53.can:284
r = r .. (" = " .. lua(t[2], "_lhs")) -- ./compiler/lua53.can:286
end -- ./compiler/lua53.can:286
end -- ./compiler/lua53.can:286
return r -- ./compiler/lua53.can:289
end, -- ./compiler/lua53.can:289
["Localrec"] = function(t) -- ./compiler/lua53.can:292
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword") -- ./compiler/lua53.can:293
end, -- ./compiler/lua53.can:293
["Goto"] = function(t) -- ./compiler/lua53.can:296
return "goto " .. lua(t, "Id") -- ./compiler/lua53.can:297
end, -- ./compiler/lua53.can:297
["Label"] = function(t) -- ./compiler/lua53.can:300
return "::" .. lua(t, "Id") .. "::" -- ./compiler/lua53.can:301
end, -- ./compiler/lua53.can:301
["Return"] = function(t) -- ./compiler/lua53.can:304
local push = peek("push") -- ./compiler/lua53.can:305
if push then -- ./compiler/lua53.can:306
local r = "" -- ./compiler/lua53.can:307
for _, val in ipairs(t) do -- ./compiler/lua53.can:308
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline()) -- ./compiler/lua53.can:309
end -- ./compiler/lua53.can:309
return r .. "return " .. UNPACK(push) -- ./compiler/lua53.can:311
else -- ./compiler/lua53.can:311
return "return " .. lua(t, "_lhs") -- ./compiler/lua53.can:313
end -- ./compiler/lua53.can:313
end, -- ./compiler/lua53.can:313
["Push"] = function(t) -- ./compiler/lua53.can:317
local var = assert(peek("push"), "no context given for push") -- ./compiler/lua53.can:318
r = "" -- ./compiler/lua53.can:319
for i = 1, # t - 1, 1 do -- ./compiler/lua53.can:320
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline()) -- ./compiler/lua53.can:321
end -- ./compiler/lua53.can:321
if t[# t] then -- ./compiler/lua53.can:323
if t[# t]["tag"] == "Call" or t[# t]["tag"] == "Invoke" then -- ./compiler/lua53.can:324
r = r .. (APPEND(var, lua(t[# t]))) -- ./compiler/lua53.can:325
else -- ./compiler/lua53.can:325
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t])) -- ./compiler/lua53.can:327
end -- ./compiler/lua53.can:327
end -- ./compiler/lua53.can:327
return r -- ./compiler/lua53.can:330
end, -- ./compiler/lua53.can:330
["Break"] = function() -- ./compiler/lua53.can:333
return "break" -- ./compiler/lua53.can:334
end, -- ./compiler/lua53.can:334
["Continue"] = function() -- ./compiler/lua53.can:337
return "goto " .. var("continue") -- ./compiler/lua53.can:338
end, -- ./compiler/lua53.can:338
["Nil"] = function() -- ./compiler/lua53.can:345
return "nil" -- ./compiler/lua53.can:346
end, -- ./compiler/lua53.can:346
["Dots"] = function() -- ./compiler/lua53.can:349
return "..." -- ./compiler/lua53.can:350
end, -- ./compiler/lua53.can:350
["Boolean"] = function(t) -- ./compiler/lua53.can:353
return tostring(t[1]) -- ./compiler/lua53.can:354
end, -- ./compiler/lua53.can:354
["Number"] = function(t) -- ./compiler/lua53.can:357
return tostring(t[1]) -- ./compiler/lua53.can:358
end, -- ./compiler/lua53.can:358
["String"] = function(t) -- ./compiler/lua53.can:361
return ("%q"):format(t[1]) -- ./compiler/lua53.can:362
end, -- ./compiler/lua53.can:362
["_functionWithoutKeyword"] = function(t) -- ./compiler/lua53.can:365
local r = "(" -- ./compiler/lua53.can:366
local decl = {} -- ./compiler/lua53.can:367
if t[1][1] then -- ./compiler/lua53.can:368
if t[1][1]["tag"] == "ParPair" then -- ./compiler/lua53.can:369
local id = lua(t[1][1][1]) -- ./compiler/lua53.can:370
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:371
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end") -- ./compiler/lua53.can:372
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:373
r = r .. (id) -- ./compiler/lua53.can:374
else -- ./compiler/lua53.can:374
r = r .. (lua(t[1][1])) -- ./compiler/lua53.can:376
end -- ./compiler/lua53.can:376
for i = 2, # t[1], 1 do -- ./compiler/lua53.can:378
if t[1][i]["tag"] == "ParPair" then -- ./compiler/lua53.can:379
local id = lua(t[1][i][1]) -- ./compiler/lua53.can:380
indentLevel = indentLevel + (1) -- ./compiler/lua53.can:381
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end") -- ./compiler/lua53.can:382
indentLevel = indentLevel - (1) -- ./compiler/lua53.can:383
r = r .. (", " .. id) -- ./compiler/lua53.can:384
else -- ./compiler/lua53.can:384
r = r .. (", " .. lua(t[1][i])) -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
end -- ./compiler/lua53.can:386
r = r .. (")" .. indent()) -- ./compiler/lua53.can:390
for _, d in ipairs(decl) do -- ./compiler/lua53.can:391
r = r .. (d .. newline()) -- ./compiler/lua53.can:392
end -- ./compiler/lua53.can:392
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:394
t[2][# t[2]]["tag"] = "Return" -- ./compiler/lua53.can:395
end -- ./compiler/lua53.can:395
local hasPush = any(t[2], { "Push" }, func) -- ./compiler/lua53.can:397
if hasPush then -- ./compiler/lua53.can:398
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:399
else -- ./compiler/lua53.can:399
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:401
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:401
r = r .. (lua(t[2])) -- ./compiler/lua53.can:403
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then -- add return only if needed -- ./compiler/lua53.can:404
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:405
end -- ./compiler/lua53.can:405
pop("push") -- ./compiler/lua53.can:407
return r .. unindent() .. "end" -- ./compiler/lua53.can:408
end, -- ./compiler/lua53.can:408
["Function"] = function(t) -- ./compiler/lua53.can:410
return "function" .. lua(t, "_functionWithoutKeyword") -- ./compiler/lua53.can:411
end, -- ./compiler/lua53.can:411
["Pair"] = function(t) -- ./compiler/lua53.can:414
return "[" .. lua(t[1]) .. "] = " .. lua(t[2]) -- ./compiler/lua53.can:415
end, -- ./compiler/lua53.can:415
["Table"] = function(t) -- ./compiler/lua53.can:417
if # t == 0 then -- ./compiler/lua53.can:418
return "{}" -- ./compiler/lua53.can:419
elseif # t == 1 then -- ./compiler/lua53.can:420
return "{ " .. lua(t, "_lhs") .. " }" -- ./compiler/lua53.can:421
else -- ./compiler/lua53.can:421
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}" -- ./compiler/lua53.can:423
end -- ./compiler/lua53.can:423
end, -- ./compiler/lua53.can:423
["TableCompr"] = function(t) -- ./compiler/lua53.can:427
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push") -- ./compiler/lua53.can:428
end, -- ./compiler/lua53.can:428
["Op"] = function(t) -- ./compiler/lua53.can:431
local r -- ./compiler/lua53.can:432
if # t == 2 then -- ./compiler/lua53.can:433
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:434
r = tags["_opid"][t[1]] .. " " .. lua(t[2]) -- ./compiler/lua53.can:435
else -- ./compiler/lua53.can:435
r = tags["_opid"][t[1]](t[2]) -- ./compiler/lua53.can:437
end -- ./compiler/lua53.can:437
else -- ./compiler/lua53.can:437
if type(tags["_opid"][t[1]]) == "string" then -- ./compiler/lua53.can:440
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3]) -- ./compiler/lua53.can:441
else -- ./compiler/lua53.can:441
r = tags["_opid"][t[1]](t[2], t[3]) -- ./compiler/lua53.can:443
end -- ./compiler/lua53.can:443
end -- ./compiler/lua53.can:443
return r -- ./compiler/lua53.can:446
end, -- ./compiler/lua53.can:446
["Paren"] = function(t) -- ./compiler/lua53.can:449
return "(" .. lua(t[1]) .. ")" -- ./compiler/lua53.can:450
end, -- ./compiler/lua53.can:450
["_statexpr"] = function(t, stat) -- ./compiler/lua53.can:457
local hasPush = any(t, { "Push" }, func) -- ./compiler/lua53.can:458
local r = "(function()" .. indent() -- ./compiler/lua53.can:459
if hasPush then -- ./compiler/lua53.can:460
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline()) -- ./compiler/lua53.can:461
else -- ./compiler/lua53.can:461
push("push", false) -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:463
end -- no push here (make sure higher push don't affect us) -- ./compiler/lua53.can:463
r = r .. (lua(t, stat)) -- ./compiler/lua53.can:465
if hasPush then -- ./compiler/lua53.can:466
r = r .. (newline() .. "return " .. UNPACK(var("push"))) -- ./compiler/lua53.can:467
end -- ./compiler/lua53.can:467
pop("push") -- ./compiler/lua53.can:469
r = r .. (unindent() .. "end)()") -- ./compiler/lua53.can:470
return r -- ./compiler/lua53.can:471
end, -- ./compiler/lua53.can:471
["DoExpr"] = function(t) -- ./compiler/lua53.can:474
if t[# t]["tag"] == "Push" then -- convert final push to return -- ./compiler/lua53.can:475
t[# t]["tag"] = "Return" -- ./compiler/lua53.can:476
end -- ./compiler/lua53.can:476
return lua(t, "_statexpr", "Do") -- ./compiler/lua53.can:478
end, -- ./compiler/lua53.can:478
["WhileExpr"] = function(t) -- ./compiler/lua53.can:481
return lua(t, "_statexpr", "While") -- ./compiler/lua53.can:482
end, -- ./compiler/lua53.can:482
["RepeatExpr"] = function(t) -- ./compiler/lua53.can:485
return lua(t, "_statexpr", "Repeat") -- ./compiler/lua53.can:486
end, -- ./compiler/lua53.can:486
["IfExpr"] = function(t) -- ./compiler/lua53.can:489
for i = 2, # t do -- convert final pushes to returns -- ./compiler/lua53.can:490
local block = t[i] -- ./compiler/lua53.can:491
if block[# block] and block[# block]["tag"] == "Push" then -- ./compiler/lua53.can:492
block[# block]["tag"] = "Return" -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
end -- ./compiler/lua53.can:493
return lua(t, "_statexpr", "If") -- ./compiler/lua53.can:496
end, -- ./compiler/lua53.can:496
["FornumExpr"] = function(t) -- ./compiler/lua53.can:499
return lua(t, "_statexpr", "Fornum") -- ./compiler/lua53.can:500
end, -- ./compiler/lua53.can:500
["ForinExpr"] = function(t) -- ./compiler/lua53.can:503
return lua(t, "_statexpr", "Forin") -- ./compiler/lua53.can:504
end, -- ./compiler/lua53.can:504
["Call"] = function(t) -- ./compiler/lua53.can:510
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:511
return "(" .. lua(t[1]) .. ")(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:512
else -- ./compiler/lua53.can:512
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")" -- ./compiler/lua53.can:514
end -- ./compiler/lua53.can:514
end, -- ./compiler/lua53.can:514
["Invoke"] = function(t) -- ./compiler/lua53.can:519
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:520
return "(" .. lua(t[1]) .. "):" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")" -- ./compiler/lua53.can:521
else -- ./compiler/lua53.can:521
return lua(t[1]) .. ":" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")" -- ./compiler/lua53.can:523
end -- ./compiler/lua53.can:523
end, -- ./compiler/lua53.can:523
["_lhs"] = function(t, start, newlines) -- ./compiler/lua53.can:528
if start == nil then start = 1 end -- ./compiler/lua53.can:528
local r -- ./compiler/lua53.can:529
if t[start] then -- ./compiler/lua53.can:530
r = lua(t[start]) -- ./compiler/lua53.can:531
for i = start + 1, # t, 1 do -- ./compiler/lua53.can:532
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i])) -- ./compiler/lua53.can:533
end -- ./compiler/lua53.can:533
else -- ./compiler/lua53.can:533
r = "" -- ./compiler/lua53.can:536
end -- ./compiler/lua53.can:536
return r -- ./compiler/lua53.can:538
end, -- ./compiler/lua53.can:538
["Id"] = function(t) -- ./compiler/lua53.can:541
return t[1] -- ./compiler/lua53.can:542
end, -- ./compiler/lua53.can:542
["Index"] = function(t) -- ./compiler/lua53.can:545
if t[1]["tag"] == "String" or t[1]["tag"] == "Table" then -- ./compiler/lua53.can:546
return "(" .. lua(t[1]) .. ")[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:547
else -- ./compiler/lua53.can:547
return lua(t[1]) .. "[" .. lua(t[2]) .. "]" -- ./compiler/lua53.can:549
end -- ./compiler/lua53.can:549
end, -- ./compiler/lua53.can:549
["_opid"] = { -- ./compiler/lua53.can:554
["add"] = "+", -- ./compiler/lua53.can:555
["sub"] = "-", -- ./compiler/lua53.can:555
["mul"] = "*", -- ./compiler/lua53.can:555
["div"] = "/", -- ./compiler/lua53.can:555
["idiv"] = "//", -- ./compiler/lua53.can:556
["mod"] = "%", -- ./compiler/lua53.can:556
["pow"] = "^", -- ./compiler/lua53.can:556
["concat"] = "..", -- ./compiler/lua53.can:556
["band"] = "&", -- ./compiler/lua53.can:557
["bor"] = "|", -- ./compiler/lua53.can:557
["bxor"] = "~", -- ./compiler/lua53.can:557
["shl"] = "<<", -- ./compiler/lua53.can:557
["shr"] = ">>", -- ./compiler/lua53.can:557
["eq"] = "==", -- ./compiler/lua53.can:558
["ne"] = "~=", -- ./compiler/lua53.can:558
["lt"] = "<", -- ./compiler/lua53.can:558
["gt"] = ">", -- ./compiler/lua53.can:558
["le"] = "<=", -- ./compiler/lua53.can:558
["ge"] = ">=", -- ./compiler/lua53.can:558
["and"] = "and", -- ./compiler/lua53.can:559
["or"] = "or", -- ./compiler/lua53.can:559
["unm"] = "-", -- ./compiler/lua53.can:559
["len"] = "#", -- ./compiler/lua53.can:559
["bnot"] = "~", -- ./compiler/lua53.can:559
["not"] = "not" -- ./compiler/lua53.can:559
} -- ./compiler/lua53.can:559
}, { ["__index"] = function(self, key) -- ./compiler/lua53.can:562
error("don't know how to compile a " .. tostring(key) .. " to Lua 5.3") -- ./compiler/lua53.can:563
end }) -- ./compiler/lua53.can:563
UNPACK = function(list, i, j) -- ./compiler/luajit.can:1
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")" -- ./compiler/luajit.can:2
end -- ./compiler/luajit.can:2
APPEND = function(t, toAppend) -- ./compiler/luajit.can:4
return "do" .. indent() .. "local a, p = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #a do" .. indent() .. t .. "[p] = a[i]" .. newline() .. "p = p + 1" .. unindent() .. "end" .. unindent() .. "end" -- ./compiler/luajit.can:5
end -- ./compiler/luajit.can:5
tags["_opid"]["idiv"] = function(left, right) -- ./compiler/luajit.can:8
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")" -- ./compiler/luajit.can:9
end -- ./compiler/luajit.can:9
tags["_opid"]["band"] = function(left, right) -- ./compiler/luajit.can:11
addRequire("bit", "band", "band") -- ./compiler/luajit.can:12
return var("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:13
end -- ./compiler/luajit.can:13
tags["_opid"]["bor"] = function(left, right) -- ./compiler/luajit.can:15
addRequire("bit", "bor", "bor") -- ./compiler/luajit.can:16
return var("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:17
end -- ./compiler/luajit.can:17
tags["_opid"]["bxor"] = function(left, right) -- ./compiler/luajit.can:19
addRequire("bit", "bxor", "bxor") -- ./compiler/luajit.can:20
return var("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:21
end -- ./compiler/luajit.can:21
tags["_opid"]["shl"] = function(left, right) -- ./compiler/luajit.can:23
addRequire("bit", "lshift", "lshift") -- ./compiler/luajit.can:24
return var("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:25
end -- ./compiler/luajit.can:25
tags["_opid"]["shr"] = function(left, right) -- ./compiler/luajit.can:27
addRequire("bit", "rshift", "rshift") -- ./compiler/luajit.can:28
return var("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")" -- ./compiler/luajit.can:29
end -- ./compiler/luajit.can:29
tags["_opid"]["bnot"] = function(right) -- ./compiler/luajit.can:31
addRequire("bit", "bnot", "bnot") -- ./compiler/luajit.can:32
return var("bnot") .. "(" .. lua(right) .. ")" -- ./compiler/luajit.can:33
end -- ./compiler/luajit.can:33
states["continue"] = {} -- when in a loop that use continue -- ./compiler/lua51.can:1
CONTINUE_START = function() -- ./compiler/lua51.can:3
return "local " .. var("break") .. newline() .. "repeat" .. indent() .. push("continue", var("break")) -- ./compiler/lua51.can:4
end -- ./compiler/lua51.can:4
CONTINUE_STOP = function() -- ./compiler/lua51.can:6
return pop("continue") .. unindent() .. "until true" .. newline() .. "if " .. var("break") .. " then break end" -- ./compiler/lua51.can:7
end -- ./compiler/lua51.can:7
tags["Continue"] = function() -- ./compiler/lua51.can:10
return "break" -- ./compiler/lua51.can:11
end -- ./compiler/lua51.can:11
tags["Break"] = function() -- ./compiler/lua51.can:13
local inContinue = peek("continue") -- ./compiler/lua51.can:14
if inContinue then -- ./compiler/lua51.can:15
return inContinue .. " = true" .. newline() .. "break" -- ./compiler/lua51.can:16
else -- ./compiler/lua51.can:16
return "break" -- ./compiler/lua51.can:18
end -- ./compiler/lua51.can:18
end -- ./compiler/lua51.can:18
tags["Goto"] = function() -- ./compiler/lua51.can:22
error("Lua 5.1 does not support the goto keyword") -- ./compiler/lua51.can:23
end -- ./compiler/lua51.can:23
tags["Label"] = function() -- ./compiler/lua51.can:25
error("Lua 5.1 does not support labels") -- ./compiler/lua51.can:26
end -- ./compiler/lua51.can:26
local code = lua(ast) .. newline() -- ./compiler/lua53.can:569
return requireStr .. code -- ./compiler/lua53.can:570
end -- ./compiler/lua53.can:570
end -- ./compiler/lua53.can:570
local lua53 = _() or lua53 -- ./compiler/lua53.can:575
return lua53 -- ./compiler/luajit.can:42
end -- ./compiler/luajit.can:42
local luajit = _() or luajit -- ./compiler/luajit.can:46
return luajit -- ./compiler/lua51.can:33
end -- ./compiler/lua51.can:33
local lua51 = _() or lua51 -- ./compiler/lua51.can:37
package["loaded"]["compiler.lua51"] = lua51 or true -- ./compiler/lua51.can:38
local function _() -- ./compiler/lua51.can:42
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
local function traverse_invoke(env, invoke) -- ./lib/lua-parser/validator.lua:161
local status, msg = traverse_exp(env, invoke[1]) -- ./lib/lua-parser/validator.lua:162
if not status then -- ./lib/lua-parser/validator.lua:163
return status, msg -- ./lib/lua-parser/validator.lua:163
end -- ./lib/lua-parser/validator.lua:163
for i = 3, # invoke do -- ./lib/lua-parser/validator.lua:164
status, msg = traverse_exp(env, invoke[i]) -- ./lib/lua-parser/validator.lua:165
if not status then -- ./lib/lua-parser/validator.lua:166
return status, msg -- ./lib/lua-parser/validator.lua:166
end -- ./lib/lua-parser/validator.lua:166
end -- ./lib/lua-parser/validator.lua:166
return true -- ./lib/lua-parser/validator.lua:168
end -- ./lib/lua-parser/validator.lua:168
local function traverse_assignment(env, stm) -- ./lib/lua-parser/validator.lua:171
local status, msg = traverse_varlist(env, stm[1]) -- ./lib/lua-parser/validator.lua:172
if not status then -- ./lib/lua-parser/validator.lua:173
return status, msg -- ./lib/lua-parser/validator.lua:173
end -- ./lib/lua-parser/validator.lua:173
status, msg = traverse_explist(env, stm[# stm]) -- ./lib/lua-parser/validator.lua:174
if not status then -- ./lib/lua-parser/validator.lua:175
return status, msg -- ./lib/lua-parser/validator.lua:175
end -- ./lib/lua-parser/validator.lua:175
return true -- ./lib/lua-parser/validator.lua:176
end -- ./lib/lua-parser/validator.lua:176
local function traverse_break(env, stm) -- ./lib/lua-parser/validator.lua:179
if not insideloop(env) then -- ./lib/lua-parser/validator.lua:180
local msg = "<break> not inside a loop" -- ./lib/lua-parser/validator.lua:181
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg) -- ./lib/lua-parser/validator.lua:182
end -- ./lib/lua-parser/validator.lua:182
return true -- ./lib/lua-parser/validator.lua:184
end -- ./lib/lua-parser/validator.lua:184
local function traverse_continue(env, stm) -- ./lib/lua-parser/validator.lua:187
if not insideloop(env) then -- ./lib/lua-parser/validator.lua:188
local msg = "<continue> not inside a loop" -- ./lib/lua-parser/validator.lua:189
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg) -- ./lib/lua-parser/validator.lua:190
end -- ./lib/lua-parser/validator.lua:190
return true -- ./lib/lua-parser/validator.lua:192
end -- ./lib/lua-parser/validator.lua:192
local function traverse_push(env, stm) -- ./lib/lua-parser/validator.lua:195
local status, msg = traverse_explist(env, stm) -- ./lib/lua-parser/validator.lua:196
if not status then -- ./lib/lua-parser/validator.lua:197
return status, msg -- ./lib/lua-parser/validator.lua:197
end -- ./lib/lua-parser/validator.lua:197
return true -- ./lib/lua-parser/validator.lua:198
end -- ./lib/lua-parser/validator.lua:198
local function traverse_forin(env, stm) -- ./lib/lua-parser/validator.lua:201
begin_loop(env) -- ./lib/lua-parser/validator.lua:202
new_scope(env) -- ./lib/lua-parser/validator.lua:203
local status, msg = traverse_explist(env, stm[2]) -- ./lib/lua-parser/validator.lua:204
if not status then -- ./lib/lua-parser/validator.lua:205
return status, msg -- ./lib/lua-parser/validator.lua:205
end -- ./lib/lua-parser/validator.lua:205
status, msg = traverse_block(env, stm[3]) -- ./lib/lua-parser/validator.lua:206
if not status then -- ./lib/lua-parser/validator.lua:207
return status, msg -- ./lib/lua-parser/validator.lua:207
end -- ./lib/lua-parser/validator.lua:207
end_scope(env) -- ./lib/lua-parser/validator.lua:208
end_loop(env) -- ./lib/lua-parser/validator.lua:209
return true -- ./lib/lua-parser/validator.lua:210
end -- ./lib/lua-parser/validator.lua:210
local function traverse_fornum(env, stm) -- ./lib/lua-parser/validator.lua:213
local status, msg -- ./lib/lua-parser/validator.lua:214
begin_loop(env) -- ./lib/lua-parser/validator.lua:215
new_scope(env) -- ./lib/lua-parser/validator.lua:216
status, msg = traverse_exp(env, stm[2]) -- ./lib/lua-parser/validator.lua:217
if not status then -- ./lib/lua-parser/validator.lua:218
return status, msg -- ./lib/lua-parser/validator.lua:218
end -- ./lib/lua-parser/validator.lua:218
status, msg = traverse_exp(env, stm[3]) -- ./lib/lua-parser/validator.lua:219
if not status then -- ./lib/lua-parser/validator.lua:220
return status, msg -- ./lib/lua-parser/validator.lua:220
end -- ./lib/lua-parser/validator.lua:220
if stm[5] then -- ./lib/lua-parser/validator.lua:221
status, msg = traverse_exp(env, stm[4]) -- ./lib/lua-parser/validator.lua:222
if not status then -- ./lib/lua-parser/validator.lua:223
return status, msg -- ./lib/lua-parser/validator.lua:223
end -- ./lib/lua-parser/validator.lua:223
status, msg = traverse_block(env, stm[5]) -- ./lib/lua-parser/validator.lua:224
if not status then -- ./lib/lua-parser/validator.lua:225
return status, msg -- ./lib/lua-parser/validator.lua:225
end -- ./lib/lua-parser/validator.lua:225
else -- ./lib/lua-parser/validator.lua:225
status, msg = traverse_block(env, stm[4]) -- ./lib/lua-parser/validator.lua:227
if not status then -- ./lib/lua-parser/validator.lua:228
return status, msg -- ./lib/lua-parser/validator.lua:228
end -- ./lib/lua-parser/validator.lua:228
end -- ./lib/lua-parser/validator.lua:228
end_scope(env) -- ./lib/lua-parser/validator.lua:230
end_loop(env) -- ./lib/lua-parser/validator.lua:231
return true -- ./lib/lua-parser/validator.lua:232
end -- ./lib/lua-parser/validator.lua:232
local function traverse_goto(env, stm) -- ./lib/lua-parser/validator.lua:235
local status, msg = set_pending_goto(env, stm) -- ./lib/lua-parser/validator.lua:236
if not status then -- ./lib/lua-parser/validator.lua:237
return status, msg -- ./lib/lua-parser/validator.lua:237
end -- ./lib/lua-parser/validator.lua:237
return true -- ./lib/lua-parser/validator.lua:238
end -- ./lib/lua-parser/validator.lua:238
local function traverse_if(env, stm) -- ./lib/lua-parser/validator.lua:241
local len = # stm -- ./lib/lua-parser/validator.lua:242
if len % 2 == 0 then -- ./lib/lua-parser/validator.lua:243
for i = 1, len, 2 do -- ./lib/lua-parser/validator.lua:244
local status, msg = traverse_exp(env, stm[i]) -- ./lib/lua-parser/validator.lua:245
if not status then -- ./lib/lua-parser/validator.lua:246
return status, msg -- ./lib/lua-parser/validator.lua:246
end -- ./lib/lua-parser/validator.lua:246
status, msg = traverse_block(env, stm[i + 1]) -- ./lib/lua-parser/validator.lua:247
if not status then -- ./lib/lua-parser/validator.lua:248
return status, msg -- ./lib/lua-parser/validator.lua:248
end -- ./lib/lua-parser/validator.lua:248
end -- ./lib/lua-parser/validator.lua:248
else -- ./lib/lua-parser/validator.lua:248
for i = 1, len - 1, 2 do -- ./lib/lua-parser/validator.lua:251
local status, msg = traverse_exp(env, stm[i]) -- ./lib/lua-parser/validator.lua:252
if not status then -- ./lib/lua-parser/validator.lua:253
return status, msg -- ./lib/lua-parser/validator.lua:253
end -- ./lib/lua-parser/validator.lua:253
status, msg = traverse_block(env, stm[i + 1]) -- ./lib/lua-parser/validator.lua:254
if not status then -- ./lib/lua-parser/validator.lua:255
return status, msg -- ./lib/lua-parser/validator.lua:255
end -- ./lib/lua-parser/validator.lua:255
end -- ./lib/lua-parser/validator.lua:255
local status, msg = traverse_block(env, stm[len]) -- ./lib/lua-parser/validator.lua:257
if not status then -- ./lib/lua-parser/validator.lua:258
return status, msg -- ./lib/lua-parser/validator.lua:258
end -- ./lib/lua-parser/validator.lua:258
end -- ./lib/lua-parser/validator.lua:258
return true -- ./lib/lua-parser/validator.lua:260
end -- ./lib/lua-parser/validator.lua:260
local function traverse_label(env, stm) -- ./lib/lua-parser/validator.lua:263
local status, msg = set_label(env, stm[1], stm["pos"]) -- ./lib/lua-parser/validator.lua:264
if not status then -- ./lib/lua-parser/validator.lua:265
return status, msg -- ./lib/lua-parser/validator.lua:265
end -- ./lib/lua-parser/validator.lua:265
return true -- ./lib/lua-parser/validator.lua:266
end -- ./lib/lua-parser/validator.lua:266
local function traverse_let(env, stm) -- ./lib/lua-parser/validator.lua:269
local status, msg = traverse_explist(env, stm[2]) -- ./lib/lua-parser/validator.lua:270
if not status then -- ./lib/lua-parser/validator.lua:271
return status, msg -- ./lib/lua-parser/validator.lua:271
end -- ./lib/lua-parser/validator.lua:271
return true -- ./lib/lua-parser/validator.lua:272
end -- ./lib/lua-parser/validator.lua:272
local function traverse_letrec(env, stm) -- ./lib/lua-parser/validator.lua:275
local status, msg = traverse_exp(env, stm[2][1]) -- ./lib/lua-parser/validator.lua:276
if not status then -- ./lib/lua-parser/validator.lua:277
return status, msg -- ./lib/lua-parser/validator.lua:277
end -- ./lib/lua-parser/validator.lua:277
return true -- ./lib/lua-parser/validator.lua:278
end -- ./lib/lua-parser/validator.lua:278
local function traverse_repeat(env, stm) -- ./lib/lua-parser/validator.lua:281
begin_loop(env) -- ./lib/lua-parser/validator.lua:282
local status, msg = traverse_block(env, stm[1]) -- ./lib/lua-parser/validator.lua:283
if not status then -- ./lib/lua-parser/validator.lua:284
return status, msg -- ./lib/lua-parser/validator.lua:284
end -- ./lib/lua-parser/validator.lua:284
status, msg = traverse_exp(env, stm[2]) -- ./lib/lua-parser/validator.lua:285
if not status then -- ./lib/lua-parser/validator.lua:286
return status, msg -- ./lib/lua-parser/validator.lua:286
end -- ./lib/lua-parser/validator.lua:286
end_loop(env) -- ./lib/lua-parser/validator.lua:287
return true -- ./lib/lua-parser/validator.lua:288
end -- ./lib/lua-parser/validator.lua:288
local function traverse_return(env, stm) -- ./lib/lua-parser/validator.lua:291
local status, msg = traverse_explist(env, stm) -- ./lib/lua-parser/validator.lua:292
if not status then -- ./lib/lua-parser/validator.lua:293
return status, msg -- ./lib/lua-parser/validator.lua:293
end -- ./lib/lua-parser/validator.lua:293
return true -- ./lib/lua-parser/validator.lua:294
end -- ./lib/lua-parser/validator.lua:294
local function traverse_while(env, stm) -- ./lib/lua-parser/validator.lua:297
begin_loop(env) -- ./lib/lua-parser/validator.lua:298
local status, msg = traverse_exp(env, stm[1]) -- ./lib/lua-parser/validator.lua:299
if not status then -- ./lib/lua-parser/validator.lua:300
return status, msg -- ./lib/lua-parser/validator.lua:300
end -- ./lib/lua-parser/validator.lua:300
status, msg = traverse_block(env, stm[2]) -- ./lib/lua-parser/validator.lua:301
if not status then -- ./lib/lua-parser/validator.lua:302
return status, msg -- ./lib/lua-parser/validator.lua:302
end -- ./lib/lua-parser/validator.lua:302
end_loop(env) -- ./lib/lua-parser/validator.lua:303
return true -- ./lib/lua-parser/validator.lua:304
end -- ./lib/lua-parser/validator.lua:304
traverse_var = function(env, var) -- ./lib/lua-parser/validator.lua:307
local tag = var["tag"] -- ./lib/lua-parser/validator.lua:308
if tag == "Id" then -- `Id{ <string> } -- ./lib/lua-parser/validator.lua:309
return true -- ./lib/lua-parser/validator.lua:310
elseif tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/validator.lua:311
local status, msg = traverse_exp(env, var[1]) -- ./lib/lua-parser/validator.lua:312
if not status then -- ./lib/lua-parser/validator.lua:313
return status, msg -- ./lib/lua-parser/validator.lua:313
end -- ./lib/lua-parser/validator.lua:313
status, msg = traverse_exp(env, var[2]) -- ./lib/lua-parser/validator.lua:314
if not status then -- ./lib/lua-parser/validator.lua:315
return status, msg -- ./lib/lua-parser/validator.lua:315
end -- ./lib/lua-parser/validator.lua:315
return true -- ./lib/lua-parser/validator.lua:316
else -- ./lib/lua-parser/validator.lua:316
error("expecting a variable, but got a " .. tag) -- ./lib/lua-parser/validator.lua:318
end -- ./lib/lua-parser/validator.lua:318
end -- ./lib/lua-parser/validator.lua:318
traverse_varlist = function(env, varlist) -- ./lib/lua-parser/validator.lua:322
for k, v in ipairs(varlist) do -- ./lib/lua-parser/validator.lua:323
local status, msg = traverse_var(env, v) -- ./lib/lua-parser/validator.lua:324
if not status then -- ./lib/lua-parser/validator.lua:325
return status, msg -- ./lib/lua-parser/validator.lua:325
end -- ./lib/lua-parser/validator.lua:325
end -- ./lib/lua-parser/validator.lua:325
return true -- ./lib/lua-parser/validator.lua:327
end -- ./lib/lua-parser/validator.lua:327
traverse_exp = function(env, exp) -- ./lib/lua-parser/validator.lua:330
local tag = exp["tag"] -- ./lib/lua-parser/validator.lua:331
if tag == "Nil" or tag == "Boolean" or tag == "Number" or tag == "String" then -- `String{ <string> } -- ./lib/lua-parser/validator.lua:335
return true -- ./lib/lua-parser/validator.lua:336
elseif tag == "Dots" then -- ./lib/lua-parser/validator.lua:337
return traverse_vararg(env, exp) -- ./lib/lua-parser/validator.lua:338
elseif tag == "Function" then -- `Function{ { `Id{ <string> }* `Dots? } block } -- ./lib/lua-parser/validator.lua:339
return traverse_function(env, exp) -- ./lib/lua-parser/validator.lua:340
elseif tag == "Table" then -- `Table{ ( `Pair{ expr expr } | expr )* } -- ./lib/lua-parser/validator.lua:341
return traverse_table(env, exp) -- ./lib/lua-parser/validator.lua:342
elseif tag == "Op" then -- `Op{ opid expr expr? } -- ./lib/lua-parser/validator.lua:343
return traverse_op(env, exp) -- ./lib/lua-parser/validator.lua:344
elseif tag == "Paren" then -- `Paren{ expr } -- ./lib/lua-parser/validator.lua:345
return traverse_paren(env, exp) -- ./lib/lua-parser/validator.lua:346
elseif tag == "Call" then -- `Call{ expr expr* } -- ./lib/lua-parser/validator.lua:347
return traverse_call(env, exp) -- ./lib/lua-parser/validator.lua:348
elseif tag == "Invoke" then -- `Invoke{ expr `String{ <string> } expr* } -- ./lib/lua-parser/validator.lua:349
return traverse_invoke(env, exp) -- ./lib/lua-parser/validator.lua:350
elseif tag == "Id" or tag == "Index" then -- `Index{ expr expr } -- ./lib/lua-parser/validator.lua:352
return traverse_var(env, exp) -- ./lib/lua-parser/validator.lua:353
elseif tag == "TableCompr" then -- `TableCompr{ block } -- ./lib/lua-parser/validator.lua:354
return traverse_tablecompr(env, exp) -- ./lib/lua-parser/validator.lua:355
elseif tag:match("Expr$") then -- `StatExpr{ ... } -- ./lib/lua-parser/validator.lua:356
return traverse_statexpr(env, exp) -- ./lib/lua-parser/validator.lua:357
else -- ./lib/lua-parser/validator.lua:357
error("expecting an expression, but got a " .. tag) -- ./lib/lua-parser/validator.lua:359
end -- ./lib/lua-parser/validator.lua:359
end -- ./lib/lua-parser/validator.lua:359
traverse_explist = function(env, explist) -- ./lib/lua-parser/validator.lua:363
for k, v in ipairs(explist) do -- ./lib/lua-parser/validator.lua:364
local status, msg = traverse_exp(env, v) -- ./lib/lua-parser/validator.lua:365
if not status then -- ./lib/lua-parser/validator.lua:366
return status, msg -- ./lib/lua-parser/validator.lua:366
end -- ./lib/lua-parser/validator.lua:366
end -- ./lib/lua-parser/validator.lua:366
return true -- ./lib/lua-parser/validator.lua:368
end -- ./lib/lua-parser/validator.lua:368
traverse_stm = function(env, stm) -- ./lib/lua-parser/validator.lua:371
local tag = stm["tag"] -- ./lib/lua-parser/validator.lua:372
if tag == "Do" then -- `Do{ stat* } -- ./lib/lua-parser/validator.lua:373
return traverse_block(env, stm) -- ./lib/lua-parser/validator.lua:374
elseif tag == "Set" then -- `Set{ {lhs+} (opid? = opid?)? {expr+} } -- ./lib/lua-parser/validator.lua:375
return traverse_assignment(env, stm) -- ./lib/lua-parser/validator.lua:376
elseif tag == "While" then -- `While{ expr block } -- ./lib/lua-parser/validator.lua:377
return traverse_while(env, stm) -- ./lib/lua-parser/validator.lua:378
elseif tag == "Repeat" then -- `Repeat{ block expr } -- ./lib/lua-parser/validator.lua:379
return traverse_repeat(env, stm) -- ./lib/lua-parser/validator.lua:380
elseif tag == "If" then -- `If{ (expr block)+ block? } -- ./lib/lua-parser/validator.lua:381
return traverse_if(env, stm) -- ./lib/lua-parser/validator.lua:382
elseif tag == "Fornum" then -- `Fornum{ ident expr expr expr? block } -- ./lib/lua-parser/validator.lua:383
return traverse_fornum(env, stm) -- ./lib/lua-parser/validator.lua:384
elseif tag == "Forin" then -- `Forin{ {ident+} {expr+} block } -- ./lib/lua-parser/validator.lua:385
return traverse_forin(env, stm) -- ./lib/lua-parser/validator.lua:386
elseif tag == "Local" or tag == "Let" then -- `Let{ {ident+} {expr+}? } -- ./lib/lua-parser/validator.lua:388
return traverse_let(env, stm) -- ./lib/lua-parser/validator.lua:389
elseif tag == "Localrec" then -- `Localrec{ ident expr } -- ./lib/lua-parser/validator.lua:390
return traverse_letrec(env, stm) -- ./lib/lua-parser/validator.lua:391
elseif tag == "Goto" then -- `Goto{ <string> } -- ./lib/lua-parser/validator.lua:392
return traverse_goto(env, stm) -- ./lib/lua-parser/validator.lua:393
elseif tag == "Label" then -- `Label{ <string> } -- ./lib/lua-parser/validator.lua:394
return traverse_label(env, stm) -- ./lib/lua-parser/validator.lua:395
elseif tag == "Return" then -- `Return{ <expr>* } -- ./lib/lua-parser/validator.lua:396
return traverse_return(env, stm) -- ./lib/lua-parser/validator.lua:397
elseif tag == "Break" then -- ./lib/lua-parser/validator.lua:398
return traverse_break(env, stm) -- ./lib/lua-parser/validator.lua:399
elseif tag == "Call" then -- `Call{ expr expr* } -- ./lib/lua-parser/validator.lua:400
return traverse_call(env, stm) -- ./lib/lua-parser/validator.lua:401
elseif tag == "Invoke" then -- `Invoke{ expr `String{ <string> } expr* } -- ./lib/lua-parser/validator.lua:402
return traverse_invoke(env, stm) -- ./lib/lua-parser/validator.lua:403
elseif tag == "Continue" then -- ./lib/lua-parser/validator.lua:404
return traverse_continue(env, stm) -- ./lib/lua-parser/validator.lua:405
elseif tag == "Push" then -- `Push{ <expr>* } -- ./lib/lua-parser/validator.lua:406
return traverse_push(env, stm) -- ./lib/lua-parser/validator.lua:407
else -- ./lib/lua-parser/validator.lua:407
error("expecting a statement, but got a " .. tag) -- ./lib/lua-parser/validator.lua:409
end -- ./lib/lua-parser/validator.lua:409
end -- ./lib/lua-parser/validator.lua:409
traverse_block = function(env, block) -- ./lib/lua-parser/validator.lua:413
local l = {} -- ./lib/lua-parser/validator.lua:414
new_scope(env) -- ./lib/lua-parser/validator.lua:415
for k, v in ipairs(block) do -- ./lib/lua-parser/validator.lua:416
local status, msg = traverse_stm(env, v) -- ./lib/lua-parser/validator.lua:417
if not status then -- ./lib/lua-parser/validator.lua:418
return status, msg -- ./lib/lua-parser/validator.lua:418
end -- ./lib/lua-parser/validator.lua:418
end -- ./lib/lua-parser/validator.lua:418
end_scope(env) -- ./lib/lua-parser/validator.lua:420
return true -- ./lib/lua-parser/validator.lua:421
end -- ./lib/lua-parser/validator.lua:421
local function traverse(ast, errorinfo) -- ./lib/lua-parser/validator.lua:425
assert(type(ast) == "table") -- ./lib/lua-parser/validator.lua:426
assert(type(errorinfo) == "table") -- ./lib/lua-parser/validator.lua:427
local env = { -- ./lib/lua-parser/validator.lua:428
["errorinfo"] = errorinfo, -- ./lib/lua-parser/validator.lua:428
["function"] = {} -- ./lib/lua-parser/validator.lua:428
} -- ./lib/lua-parser/validator.lua:428
new_function(env) -- ./lib/lua-parser/validator.lua:429
set_vararg(env, true) -- ./lib/lua-parser/validator.lua:430
local status, msg = traverse_block(env, ast) -- ./lib/lua-parser/validator.lua:431
if not status then -- ./lib/lua-parser/validator.lua:432
return status, msg -- ./lib/lua-parser/validator.lua:432
end -- ./lib/lua-parser/validator.lua:432
end_function(env) -- ./lib/lua-parser/validator.lua:433
status, msg = verify_pending_gotos(env) -- ./lib/lua-parser/validator.lua:434
if not status then -- ./lib/lua-parser/validator.lua:435
return status, msg -- ./lib/lua-parser/validator.lua:435
end -- ./lib/lua-parser/validator.lua:435
return ast -- ./lib/lua-parser/validator.lua:436
end -- ./lib/lua-parser/validator.lua:436
return { -- ./lib/lua-parser/validator.lua:439
["validate"] = traverse, -- ./lib/lua-parser/validator.lua:439
["syntaxerror"] = syntaxerror -- ./lib/lua-parser/validator.lua:439
} -- ./lib/lua-parser/validator.lua:439
end -- ./lib/lua-parser/validator.lua:439
local validator = _() or validator -- ./lib/lua-parser/validator.lua:443
package["loaded"]["lib.lua-parser.validator"] = validator or true -- ./lib/lua-parser/validator.lua:444
local function _() -- ./lib/lua-parser/validator.lua:447
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
local lpeg = require("lpeglabel") -- ./lib/lua-parser/parser.lua:65
lpeg["locale"](lpeg) -- ./lib/lua-parser/parser.lua:67
local P, S, V = lpeg["P"], lpeg["S"], lpeg["V"] -- ./lib/lua-parser/parser.lua:69
local C, Carg, Cb, Cc = lpeg["C"], lpeg["Carg"], lpeg["Cb"], lpeg["Cc"] -- ./lib/lua-parser/parser.lua:70
local Cf, Cg, Cmt, Cp, Cs, Ct = lpeg["Cf"], lpeg["Cg"], lpeg["Cmt"], lpeg["Cp"], lpeg["Cs"], lpeg["Ct"] -- ./lib/lua-parser/parser.lua:71
local Rec, T = lpeg["Rec"], lpeg["T"] -- ./lib/lua-parser/parser.lua:72
local alpha, digit, alnum = lpeg["alpha"], lpeg["digit"], lpeg["alnum"] -- ./lib/lua-parser/parser.lua:74
local xdigit = lpeg["xdigit"] -- ./lib/lua-parser/parser.lua:75
local space = lpeg["space"] -- ./lib/lua-parser/parser.lua:76
local labels = { -- ./lib/lua-parser/parser.lua:81
{ -- ./lib/lua-parser/parser.lua:82
"ErrExtra", -- ./lib/lua-parser/parser.lua:82
"unexpected character(s), expected EOF" -- ./lib/lua-parser/parser.lua:82
}, -- ./lib/lua-parser/parser.lua:82
{ -- ./lib/lua-parser/parser.lua:83
"ErrInvalidStat", -- ./lib/lua-parser/parser.lua:83
"unexpected token, invalid start of statement" -- ./lib/lua-parser/parser.lua:83
}, -- ./lib/lua-parser/parser.lua:83
{ -- ./lib/lua-parser/parser.lua:85
"ErrEndIf", -- ./lib/lua-parser/parser.lua:85
"expected 'end' to close the if statement" -- ./lib/lua-parser/parser.lua:85
}, -- ./lib/lua-parser/parser.lua:85
{ -- ./lib/lua-parser/parser.lua:86
"ErrExprIf", -- ./lib/lua-parser/parser.lua:86
"expected a condition after 'if'" -- ./lib/lua-parser/parser.lua:86
}, -- ./lib/lua-parser/parser.lua:86
{ -- ./lib/lua-parser/parser.lua:87
"ErrThenIf", -- ./lib/lua-parser/parser.lua:87
"expected 'then' after the condition" -- ./lib/lua-parser/parser.lua:87
}, -- ./lib/lua-parser/parser.lua:87
{ -- ./lib/lua-parser/parser.lua:88
"ErrExprEIf", -- ./lib/lua-parser/parser.lua:88
"expected a condition after 'elseif'" -- ./lib/lua-parser/parser.lua:88
}, -- ./lib/lua-parser/parser.lua:88
{ -- ./lib/lua-parser/parser.lua:89
"ErrThenEIf", -- ./lib/lua-parser/parser.lua:89
"expected 'then' after the condition" -- ./lib/lua-parser/parser.lua:89
}, -- ./lib/lua-parser/parser.lua:89
{ -- ./lib/lua-parser/parser.lua:91
"ErrEndDo", -- ./lib/lua-parser/parser.lua:91
"expected 'end' to close the do block" -- ./lib/lua-parser/parser.lua:91
}, -- ./lib/lua-parser/parser.lua:91
{ -- ./lib/lua-parser/parser.lua:92
"ErrExprWhile", -- ./lib/lua-parser/parser.lua:92
"expected a condition after 'while'" -- ./lib/lua-parser/parser.lua:92
}, -- ./lib/lua-parser/parser.lua:92
{ -- ./lib/lua-parser/parser.lua:93
"ErrDoWhile", -- ./lib/lua-parser/parser.lua:93
"expected 'do' after the condition" -- ./lib/lua-parser/parser.lua:93
}, -- ./lib/lua-parser/parser.lua:93
{ -- ./lib/lua-parser/parser.lua:94
"ErrEndWhile", -- ./lib/lua-parser/parser.lua:94
"expected 'end' to close the while loop" -- ./lib/lua-parser/parser.lua:94
}, -- ./lib/lua-parser/parser.lua:94
{ -- ./lib/lua-parser/parser.lua:95
"ErrUntilRep", -- ./lib/lua-parser/parser.lua:95
"expected 'until' at the end of the repeat loop" -- ./lib/lua-parser/parser.lua:95
}, -- ./lib/lua-parser/parser.lua:95
{ -- ./lib/lua-parser/parser.lua:96
"ErrExprRep", -- ./lib/lua-parser/parser.lua:96
"expected a conditions after 'until'" -- ./lib/lua-parser/parser.lua:96
}, -- ./lib/lua-parser/parser.lua:96
{ -- ./lib/lua-parser/parser.lua:98
"ErrForRange", -- ./lib/lua-parser/parser.lua:98
"expected a numeric or generic range after 'for'" -- ./lib/lua-parser/parser.lua:98
}, -- ./lib/lua-parser/parser.lua:98
{ -- ./lib/lua-parser/parser.lua:99
"ErrEndFor", -- ./lib/lua-parser/parser.lua:99
"expected 'end' to close the for loop" -- ./lib/lua-parser/parser.lua:99
}, -- ./lib/lua-parser/parser.lua:99
{ -- ./lib/lua-parser/parser.lua:100
"ErrExprFor1", -- ./lib/lua-parser/parser.lua:100
"expected a starting expression for the numeric range" -- ./lib/lua-parser/parser.lua:100
}, -- ./lib/lua-parser/parser.lua:100
{ -- ./lib/lua-parser/parser.lua:101
"ErrCommaFor", -- ./lib/lua-parser/parser.lua:101
"expected ',' to split the start and end of the range" -- ./lib/lua-parser/parser.lua:101
}, -- ./lib/lua-parser/parser.lua:101
{ -- ./lib/lua-parser/parser.lua:102
"ErrExprFor2", -- ./lib/lua-parser/parser.lua:102
"expected an ending expression for the numeric range" -- ./lib/lua-parser/parser.lua:102
}, -- ./lib/lua-parser/parser.lua:102
{ -- ./lib/lua-parser/parser.lua:103
"ErrExprFor3", -- ./lib/lua-parser/parser.lua:103
"expected a step expression for the numeric range after ','" -- ./lib/lua-parser/parser.lua:103
}, -- ./lib/lua-parser/parser.lua:103
{ -- ./lib/lua-parser/parser.lua:104
"ErrInFor", -- ./lib/lua-parser/parser.lua:104
"expected '=' or 'in' after the variable(s)" -- ./lib/lua-parser/parser.lua:104
}, -- ./lib/lua-parser/parser.lua:104
{ -- ./lib/lua-parser/parser.lua:105
"ErrEListFor", -- ./lib/lua-parser/parser.lua:105
"expected one or more expressions after 'in'" -- ./lib/lua-parser/parser.lua:105
}, -- ./lib/lua-parser/parser.lua:105
{ -- ./lib/lua-parser/parser.lua:106
"ErrDoFor", -- ./lib/lua-parser/parser.lua:106
"expected 'do' after the range of the for loop" -- ./lib/lua-parser/parser.lua:106
}, -- ./lib/lua-parser/parser.lua:106
{ -- ./lib/lua-parser/parser.lua:108
"ErrDefLocal", -- ./lib/lua-parser/parser.lua:108
"expected a function definition or assignment after local" -- ./lib/lua-parser/parser.lua:108
}, -- ./lib/lua-parser/parser.lua:108
{ -- ./lib/lua-parser/parser.lua:109
"ErrDefLet", -- ./lib/lua-parser/parser.lua:109
"expected a function definition or assignment after let" -- ./lib/lua-parser/parser.lua:109
}, -- ./lib/lua-parser/parser.lua:109
{ -- ./lib/lua-parser/parser.lua:110
"ErrNameLFunc", -- ./lib/lua-parser/parser.lua:110
"expected a function name after 'function'" -- ./lib/lua-parser/parser.lua:110
}, -- ./lib/lua-parser/parser.lua:110
{ -- ./lib/lua-parser/parser.lua:111
"ErrEListLAssign", -- ./lib/lua-parser/parser.lua:111
"expected one or more expressions after '='" -- ./lib/lua-parser/parser.lua:111
}, -- ./lib/lua-parser/parser.lua:111
{ -- ./lib/lua-parser/parser.lua:112
"ErrEListAssign", -- ./lib/lua-parser/parser.lua:112
"expected one or more expressions after '='" -- ./lib/lua-parser/parser.lua:112
}, -- ./lib/lua-parser/parser.lua:112
{ -- ./lib/lua-parser/parser.lua:114
"ErrFuncName", -- ./lib/lua-parser/parser.lua:114
"expected a function name after 'function'" -- ./lib/lua-parser/parser.lua:114
}, -- ./lib/lua-parser/parser.lua:114
{ -- ./lib/lua-parser/parser.lua:115
"ErrNameFunc1", -- ./lib/lua-parser/parser.lua:115
"expected a function name after '.'" -- ./lib/lua-parser/parser.lua:115
}, -- ./lib/lua-parser/parser.lua:115
{ -- ./lib/lua-parser/parser.lua:116
"ErrNameFunc2", -- ./lib/lua-parser/parser.lua:116
"expected a method name after ':'" -- ./lib/lua-parser/parser.lua:116
}, -- ./lib/lua-parser/parser.lua:116
{ -- ./lib/lua-parser/parser.lua:117
"ErrOParenPList", -- ./lib/lua-parser/parser.lua:117
"expected '(' for the parameter list" -- ./lib/lua-parser/parser.lua:117
}, -- ./lib/lua-parser/parser.lua:117
{ -- ./lib/lua-parser/parser.lua:118
"ErrCParenPList", -- ./lib/lua-parser/parser.lua:118
"expected ')' to close the parameter list" -- ./lib/lua-parser/parser.lua:118
}, -- ./lib/lua-parser/parser.lua:118
{ -- ./lib/lua-parser/parser.lua:119
"ErrEndFunc", -- ./lib/lua-parser/parser.lua:119
"expected 'end' to close the function body" -- ./lib/lua-parser/parser.lua:119
}, -- ./lib/lua-parser/parser.lua:119
{ -- ./lib/lua-parser/parser.lua:120
"ErrParList", -- ./lib/lua-parser/parser.lua:120
"expected a variable name or '...' after ','" -- ./lib/lua-parser/parser.lua:120
}, -- ./lib/lua-parser/parser.lua:120
{ -- ./lib/lua-parser/parser.lua:122
"ErrLabel", -- ./lib/lua-parser/parser.lua:122
"expected a label name after '::'" -- ./lib/lua-parser/parser.lua:122
}, -- ./lib/lua-parser/parser.lua:122
{ -- ./lib/lua-parser/parser.lua:123
"ErrCloseLabel", -- ./lib/lua-parser/parser.lua:123
"expected '::' after the label" -- ./lib/lua-parser/parser.lua:123
}, -- ./lib/lua-parser/parser.lua:123
{ -- ./lib/lua-parser/parser.lua:124
"ErrGoto", -- ./lib/lua-parser/parser.lua:124
"expected a label after 'goto'" -- ./lib/lua-parser/parser.lua:124
}, -- ./lib/lua-parser/parser.lua:124
{ -- ./lib/lua-parser/parser.lua:125
"ErrRetList", -- ./lib/lua-parser/parser.lua:125
"expected an expression after ',' in the return statement" -- ./lib/lua-parser/parser.lua:125
}, -- ./lib/lua-parser/parser.lua:125
{ -- ./lib/lua-parser/parser.lua:127
"ErrVarList", -- ./lib/lua-parser/parser.lua:127
"expected a variable name after ','" -- ./lib/lua-parser/parser.lua:127
}, -- ./lib/lua-parser/parser.lua:127
{ -- ./lib/lua-parser/parser.lua:128
"ErrExprList", -- ./lib/lua-parser/parser.lua:128
"expected an expression after ','" -- ./lib/lua-parser/parser.lua:128
}, -- ./lib/lua-parser/parser.lua:128
{ -- ./lib/lua-parser/parser.lua:130
"ErrOrExpr", -- ./lib/lua-parser/parser.lua:130
"expected an expression after 'or'" -- ./lib/lua-parser/parser.lua:130
}, -- ./lib/lua-parser/parser.lua:130
{ -- ./lib/lua-parser/parser.lua:131
"ErrAndExpr", -- ./lib/lua-parser/parser.lua:131
"expected an expression after 'and'" -- ./lib/lua-parser/parser.lua:131
}, -- ./lib/lua-parser/parser.lua:131
{ -- ./lib/lua-parser/parser.lua:132
"ErrRelExpr", -- ./lib/lua-parser/parser.lua:132
"expected an expression after the relational operator" -- ./lib/lua-parser/parser.lua:132
}, -- ./lib/lua-parser/parser.lua:132
{ -- ./lib/lua-parser/parser.lua:133
"ErrBOrExpr", -- ./lib/lua-parser/parser.lua:133
"expected an expression after '|'" -- ./lib/lua-parser/parser.lua:133
}, -- ./lib/lua-parser/parser.lua:133
{ -- ./lib/lua-parser/parser.lua:134
"ErrBXorExpr", -- ./lib/lua-parser/parser.lua:134
"expected an expression after '~'" -- ./lib/lua-parser/parser.lua:134
}, -- ./lib/lua-parser/parser.lua:134
{ -- ./lib/lua-parser/parser.lua:135
"ErrBAndExpr", -- ./lib/lua-parser/parser.lua:135
"expected an expression after '&'" -- ./lib/lua-parser/parser.lua:135
}, -- ./lib/lua-parser/parser.lua:135
{ -- ./lib/lua-parser/parser.lua:136
"ErrShiftExpr", -- ./lib/lua-parser/parser.lua:136
"expected an expression after the bit shift" -- ./lib/lua-parser/parser.lua:136
}, -- ./lib/lua-parser/parser.lua:136
{ -- ./lib/lua-parser/parser.lua:137
"ErrConcatExpr", -- ./lib/lua-parser/parser.lua:137
"expected an expression after '..'" -- ./lib/lua-parser/parser.lua:137
}, -- ./lib/lua-parser/parser.lua:137
{ -- ./lib/lua-parser/parser.lua:138
"ErrAddExpr", -- ./lib/lua-parser/parser.lua:138
"expected an expression after the additive operator" -- ./lib/lua-parser/parser.lua:138
}, -- ./lib/lua-parser/parser.lua:138
{ -- ./lib/lua-parser/parser.lua:139
"ErrMulExpr", -- ./lib/lua-parser/parser.lua:139
"expected an expression after the multiplicative operator" -- ./lib/lua-parser/parser.lua:139
}, -- ./lib/lua-parser/parser.lua:139
{ -- ./lib/lua-parser/parser.lua:140
"ErrUnaryExpr", -- ./lib/lua-parser/parser.lua:140
"expected an expression after the unary operator" -- ./lib/lua-parser/parser.lua:140
}, -- ./lib/lua-parser/parser.lua:140
{ -- ./lib/lua-parser/parser.lua:141
"ErrPowExpr", -- ./lib/lua-parser/parser.lua:141
"expected an expression after '^'" -- ./lib/lua-parser/parser.lua:141
}, -- ./lib/lua-parser/parser.lua:141
{ -- ./lib/lua-parser/parser.lua:143
"ErrExprParen", -- ./lib/lua-parser/parser.lua:143
"expected an expression after '('" -- ./lib/lua-parser/parser.lua:143
}, -- ./lib/lua-parser/parser.lua:143
{ -- ./lib/lua-parser/parser.lua:144
"ErrCParenExpr", -- ./lib/lua-parser/parser.lua:144
"expected ')' to close the expression" -- ./lib/lua-parser/parser.lua:144
}, -- ./lib/lua-parser/parser.lua:144
{ -- ./lib/lua-parser/parser.lua:145
"ErrNameIndex", -- ./lib/lua-parser/parser.lua:145
"expected a field name after '.'" -- ./lib/lua-parser/parser.lua:145
}, -- ./lib/lua-parser/parser.lua:145
{ -- ./lib/lua-parser/parser.lua:146
"ErrExprIndex", -- ./lib/lua-parser/parser.lua:146
"expected an expression after '['" -- ./lib/lua-parser/parser.lua:146
}, -- ./lib/lua-parser/parser.lua:146
{ -- ./lib/lua-parser/parser.lua:147
"ErrCBracketIndex", -- ./lib/lua-parser/parser.lua:147
"expected ']' to close the indexing expression" -- ./lib/lua-parser/parser.lua:147
}, -- ./lib/lua-parser/parser.lua:147
{ -- ./lib/lua-parser/parser.lua:148
"ErrNameMeth", -- ./lib/lua-parser/parser.lua:148
"expected a method name after ':'" -- ./lib/lua-parser/parser.lua:148
}, -- ./lib/lua-parser/parser.lua:148
{ -- ./lib/lua-parser/parser.lua:149
"ErrMethArgs", -- ./lib/lua-parser/parser.lua:149
"expected some arguments for the method call (or '()')" -- ./lib/lua-parser/parser.lua:149
}, -- ./lib/lua-parser/parser.lua:149
{ -- ./lib/lua-parser/parser.lua:151
"ErrArgList", -- ./lib/lua-parser/parser.lua:151
"expected an expression after ',' in the argument list" -- ./lib/lua-parser/parser.lua:151
}, -- ./lib/lua-parser/parser.lua:151
{ -- ./lib/lua-parser/parser.lua:152
"ErrCParenArgs", -- ./lib/lua-parser/parser.lua:152
"expected ')' to close the argument list" -- ./lib/lua-parser/parser.lua:152
}, -- ./lib/lua-parser/parser.lua:152
{ -- ./lib/lua-parser/parser.lua:154
"ErrCBraceTable", -- ./lib/lua-parser/parser.lua:154
"expected '}' to close the table constructor" -- ./lib/lua-parser/parser.lua:154
}, -- ./lib/lua-parser/parser.lua:154
{ -- ./lib/lua-parser/parser.lua:155
"ErrEqField", -- ./lib/lua-parser/parser.lua:155
"expected '=' after the table key" -- ./lib/lua-parser/parser.lua:155
}, -- ./lib/lua-parser/parser.lua:155
{ -- ./lib/lua-parser/parser.lua:156
"ErrExprField", -- ./lib/lua-parser/parser.lua:156
"expected an expression after '='" -- ./lib/lua-parser/parser.lua:156
}, -- ./lib/lua-parser/parser.lua:156
{ -- ./lib/lua-parser/parser.lua:157
"ErrExprFKey", -- ./lib/lua-parser/parser.lua:157
"expected an expression after '[' for the table key" -- ./lib/lua-parser/parser.lua:157
}, -- ./lib/lua-parser/parser.lua:157
{ -- ./lib/lua-parser/parser.lua:158
"ErrCBracketFKey", -- ./lib/lua-parser/parser.lua:158
"expected ']' to close the table key" -- ./lib/lua-parser/parser.lua:158
}, -- ./lib/lua-parser/parser.lua:158
{ -- ./lib/lua-parser/parser.lua:160
"ErrCBracketTableCompr", -- ./lib/lua-parser/parser.lua:160
"expected ']' to close the table comprehension" -- ./lib/lua-parser/parser.lua:160
}, -- ./lib/lua-parser/parser.lua:160
{ -- ./lib/lua-parser/parser.lua:162
"ErrDigitHex", -- ./lib/lua-parser/parser.lua:162
"expected one or more hexadecimal digits after '0x'" -- ./lib/lua-parser/parser.lua:162
}, -- ./lib/lua-parser/parser.lua:162
{ -- ./lib/lua-parser/parser.lua:163
"ErrDigitDeci", -- ./lib/lua-parser/parser.lua:163
"expected one or more digits after the decimal point" -- ./lib/lua-parser/parser.lua:163
}, -- ./lib/lua-parser/parser.lua:163
{ -- ./lib/lua-parser/parser.lua:164
"ErrDigitExpo", -- ./lib/lua-parser/parser.lua:164
"expected one or more digits for the exponent" -- ./lib/lua-parser/parser.lua:164
}, -- ./lib/lua-parser/parser.lua:164
{ -- ./lib/lua-parser/parser.lua:166
"ErrQuote", -- ./lib/lua-parser/parser.lua:166
"unclosed string" -- ./lib/lua-parser/parser.lua:166
}, -- ./lib/lua-parser/parser.lua:166
{ -- ./lib/lua-parser/parser.lua:167
"ErrHexEsc", -- ./lib/lua-parser/parser.lua:167
"expected exactly two hexadecimal digits after '\\x'" -- ./lib/lua-parser/parser.lua:167
}, -- ./lib/lua-parser/parser.lua:167
{ -- ./lib/lua-parser/parser.lua:168
"ErrOBraceUEsc", -- ./lib/lua-parser/parser.lua:168
"expected '{' after '\\u'" -- ./lib/lua-parser/parser.lua:168
}, -- ./lib/lua-parser/parser.lua:168
{ -- ./lib/lua-parser/parser.lua:169
"ErrDigitUEsc", -- ./lib/lua-parser/parser.lua:169
"expected one or more hexadecimal digits for the UTF-8 code point" -- ./lib/lua-parser/parser.lua:169
}, -- ./lib/lua-parser/parser.lua:169
{ -- ./lib/lua-parser/parser.lua:170
"ErrCBraceUEsc", -- ./lib/lua-parser/parser.lua:170
"expected '}' after the code point" -- ./lib/lua-parser/parser.lua:170
}, -- ./lib/lua-parser/parser.lua:170
{ -- ./lib/lua-parser/parser.lua:171
"ErrEscSeq", -- ./lib/lua-parser/parser.lua:171
"invalid escape sequence" -- ./lib/lua-parser/parser.lua:171
}, -- ./lib/lua-parser/parser.lua:171
{ -- ./lib/lua-parser/parser.lua:172
"ErrCloseLStr", -- ./lib/lua-parser/parser.lua:172
"unclosed long string" -- ./lib/lua-parser/parser.lua:172
} -- ./lib/lua-parser/parser.lua:172
} -- ./lib/lua-parser/parser.lua:172
local function throw(label) -- ./lib/lua-parser/parser.lua:175
label = "Err" .. label -- ./lib/lua-parser/parser.lua:176
for i, labelinfo in ipairs(labels) do -- ./lib/lua-parser/parser.lua:177
if labelinfo[1] == label then -- ./lib/lua-parser/parser.lua:178
return T(i) -- ./lib/lua-parser/parser.lua:179
end -- ./lib/lua-parser/parser.lua:179
end -- ./lib/lua-parser/parser.lua:179
error("Label not found: " .. label) -- ./lib/lua-parser/parser.lua:183
end -- ./lib/lua-parser/parser.lua:183
local function expect(patt, label) -- ./lib/lua-parser/parser.lua:186
return patt + throw(label) -- ./lib/lua-parser/parser.lua:187
end -- ./lib/lua-parser/parser.lua:187
local function token(patt) -- ./lib/lua-parser/parser.lua:193
return patt * V("Skip") -- ./lib/lua-parser/parser.lua:194
end -- ./lib/lua-parser/parser.lua:194
local function sym(str) -- ./lib/lua-parser/parser.lua:197
return token(P(str)) -- ./lib/lua-parser/parser.lua:198
end -- ./lib/lua-parser/parser.lua:198
local function kw(str) -- ./lib/lua-parser/parser.lua:201
return token(P(str) * - V("IdRest")) -- ./lib/lua-parser/parser.lua:202
end -- ./lib/lua-parser/parser.lua:202
local function tagC(tag, patt) -- ./lib/lua-parser/parser.lua:205
return Ct(Cg(Cp(), "pos") * Cg(Cc(tag), "tag") * patt) -- ./lib/lua-parser/parser.lua:206
end -- ./lib/lua-parser/parser.lua:206
local function unaryOp(op, e) -- ./lib/lua-parser/parser.lua:209
return { -- ./lib/lua-parser/parser.lua:210
["tag"] = "Op", -- ./lib/lua-parser/parser.lua:210
["pos"] = e["pos"], -- ./lib/lua-parser/parser.lua:210
[1] = op, -- ./lib/lua-parser/parser.lua:210
[2] = e -- ./lib/lua-parser/parser.lua:210
} -- ./lib/lua-parser/parser.lua:210
end -- ./lib/lua-parser/parser.lua:210
local function binaryOp(e1, op, e2) -- ./lib/lua-parser/parser.lua:213
if not op then -- ./lib/lua-parser/parser.lua:214
return e1 -- ./lib/lua-parser/parser.lua:215
else -- ./lib/lua-parser/parser.lua:215
return { -- ./lib/lua-parser/parser.lua:217
["tag"] = "Op", -- ./lib/lua-parser/parser.lua:217
["pos"] = e1["pos"], -- ./lib/lua-parser/parser.lua:217
[1] = op, -- ./lib/lua-parser/parser.lua:217
[2] = e1, -- ./lib/lua-parser/parser.lua:217
[3] = e2 -- ./lib/lua-parser/parser.lua:217
} -- ./lib/lua-parser/parser.lua:217
end -- ./lib/lua-parser/parser.lua:217
end -- ./lib/lua-parser/parser.lua:217
local function sepBy(patt, sep, label) -- ./lib/lua-parser/parser.lua:221
if label then -- ./lib/lua-parser/parser.lua:222
return patt * Cg(sep * expect(patt, label)) ^ 0 -- ./lib/lua-parser/parser.lua:223
else -- ./lib/lua-parser/parser.lua:223
return patt * Cg(sep * patt) ^ 0 -- ./lib/lua-parser/parser.lua:225
end -- ./lib/lua-parser/parser.lua:225
end -- ./lib/lua-parser/parser.lua:225
local function chainOp(patt, sep, label) -- ./lib/lua-parser/parser.lua:229
return Cf(sepBy(patt, sep, label), binaryOp) -- ./lib/lua-parser/parser.lua:230
end -- ./lib/lua-parser/parser.lua:230
local function commaSep(patt, label) -- ./lib/lua-parser/parser.lua:233
return sepBy(patt, sym(","), label) -- ./lib/lua-parser/parser.lua:234
end -- ./lib/lua-parser/parser.lua:234
local function tagDo(block) -- ./lib/lua-parser/parser.lua:237
block["tag"] = "Do" -- ./lib/lua-parser/parser.lua:238
return block -- ./lib/lua-parser/parser.lua:239
end -- ./lib/lua-parser/parser.lua:239
local function fixFuncStat(func) -- ./lib/lua-parser/parser.lua:242
if func[1]["is_method"] then -- ./lib/lua-parser/parser.lua:243
table["insert"](func[2][1], 1, { -- ./lib/lua-parser/parser.lua:243
["tag"] = "Id", -- ./lib/lua-parser/parser.lua:243
[1] = "self" -- ./lib/lua-parser/parser.lua:243
}) -- ./lib/lua-parser/parser.lua:243
end -- ./lib/lua-parser/parser.lua:243
func[1] = { func[1] } -- ./lib/lua-parser/parser.lua:244
func[2] = { func[2] } -- ./lib/lua-parser/parser.lua:245
return func -- ./lib/lua-parser/parser.lua:246
end -- ./lib/lua-parser/parser.lua:246
local function addDots(params, dots) -- ./lib/lua-parser/parser.lua:249
if dots then -- ./lib/lua-parser/parser.lua:250
table["insert"](params, dots) -- ./lib/lua-parser/parser.lua:250
end -- ./lib/lua-parser/parser.lua:250
return params -- ./lib/lua-parser/parser.lua:251
end -- ./lib/lua-parser/parser.lua:251
local function insertIndex(t, index) -- ./lib/lua-parser/parser.lua:254
return { -- ./lib/lua-parser/parser.lua:255
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:255
["pos"] = t["pos"], -- ./lib/lua-parser/parser.lua:255
[1] = t, -- ./lib/lua-parser/parser.lua:255
[2] = index -- ./lib/lua-parser/parser.lua:255
} -- ./lib/lua-parser/parser.lua:255
end -- ./lib/lua-parser/parser.lua:255
local function markMethod(t, method) -- ./lib/lua-parser/parser.lua:258
if method then -- ./lib/lua-parser/parser.lua:259
return { -- ./lib/lua-parser/parser.lua:260
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:260
["pos"] = t["pos"], -- ./lib/lua-parser/parser.lua:260
["is_method"] = true, -- ./lib/lua-parser/parser.lua:260
[1] = t, -- ./lib/lua-parser/parser.lua:260
[2] = method -- ./lib/lua-parser/parser.lua:260
} -- ./lib/lua-parser/parser.lua:260
end -- ./lib/lua-parser/parser.lua:260
return t -- ./lib/lua-parser/parser.lua:262
end -- ./lib/lua-parser/parser.lua:262
local function makeIndexOrCall(t1, t2) -- ./lib/lua-parser/parser.lua:265
if t2["tag"] == "Call" or t2["tag"] == "Invoke" then -- ./lib/lua-parser/parser.lua:266
local t = { -- ./lib/lua-parser/parser.lua:267
["tag"] = t2["tag"], -- ./lib/lua-parser/parser.lua:267
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:267
[1] = t1 -- ./lib/lua-parser/parser.lua:267
} -- ./lib/lua-parser/parser.lua:267
for k, v in ipairs(t2) do -- ./lib/lua-parser/parser.lua:268
table["insert"](t, v) -- ./lib/lua-parser/parser.lua:269
end -- ./lib/lua-parser/parser.lua:269
return t -- ./lib/lua-parser/parser.lua:271
end -- ./lib/lua-parser/parser.lua:271
return { -- ./lib/lua-parser/parser.lua:273
["tag"] = "Index", -- ./lib/lua-parser/parser.lua:273
["pos"] = t1["pos"], -- ./lib/lua-parser/parser.lua:273
[1] = t1, -- ./lib/lua-parser/parser.lua:273
[2] = t2[1] -- ./lib/lua-parser/parser.lua:273
} -- ./lib/lua-parser/parser.lua:273
end -- ./lib/lua-parser/parser.lua:273
local function fixShortFunc(t) -- ./lib/lua-parser/parser.lua:276
if t[1] == ":" then -- self method -- ./lib/lua-parser/parser.lua:277
table["insert"](t[2], 1, { -- ./lib/lua-parser/parser.lua:278
["tag"] = "Id", -- ./lib/lua-parser/parser.lua:278
"self" -- ./lib/lua-parser/parser.lua:278
}) -- ./lib/lua-parser/parser.lua:278
table["remove"](t, 1) -- ./lib/lua-parser/parser.lua:279
t["is_method"] = true -- ./lib/lua-parser/parser.lua:280
end -- ./lib/lua-parser/parser.lua:280
t["is_short"] = true -- ./lib/lua-parser/parser.lua:282
return t -- ./lib/lua-parser/parser.lua:283
end -- ./lib/lua-parser/parser.lua:283
local function statToExpr(t) -- tag a StatExpr -- ./lib/lua-parser/parser.lua:286
t["tag"] = t["tag"] .. "Expr" -- ./lib/lua-parser/parser.lua:287
return t -- ./lib/lua-parser/parser.lua:288
end -- ./lib/lua-parser/parser.lua:288
local function fixStructure(t) -- fix the AST structure if needed -- ./lib/lua-parser/parser.lua:291
local i = 1 -- ./lib/lua-parser/parser.lua:292
while i <= # t do -- ./lib/lua-parser/parser.lua:293
if type(t[i]) == "table" then -- ./lib/lua-parser/parser.lua:294
fixStructure(t[i]) -- ./lib/lua-parser/parser.lua:295
for j = # t[i], 1, - 1 do -- ./lib/lua-parser/parser.lua:296
local stat = t[i][j] -- ./lib/lua-parser/parser.lua:297
if type(stat) == "table" and stat["move_up_block"] and stat["move_up_block"] > 0 then -- ./lib/lua-parser/parser.lua:298
table["remove"](t[i], j) -- ./lib/lua-parser/parser.lua:299
table["insert"](t, i + 1, stat) -- ./lib/lua-parser/parser.lua:300
if t["tag"] == "Block" or t["tag"] == "Do" then -- ./lib/lua-parser/parser.lua:301
stat["move_up_block"] = stat["move_up_block"] - 1 -- ./lib/lua-parser/parser.lua:302
end -- ./lib/lua-parser/parser.lua:302
end -- ./lib/lua-parser/parser.lua:302
end -- ./lib/lua-parser/parser.lua:302
end -- ./lib/lua-parser/parser.lua:302
i = i + 1 -- ./lib/lua-parser/parser.lua:307
end -- ./lib/lua-parser/parser.lua:307
return t -- ./lib/lua-parser/parser.lua:309
end -- ./lib/lua-parser/parser.lua:309
local function searchEndRec(block, isRecCall) -- recursively search potential "end" keyword wrongly consumed by a short anonymous function on stat end (yeah, too late to change the syntax to something easier to parse) -- ./lib/lua-parser/parser.lua:312
for i, stat in ipairs(block) do -- ./lib/lua-parser/parser.lua:313
if stat["tag"] == "Set" or stat["tag"] == "Push" or stat["tag"] == "Return" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./lib/lua-parser/parser.lua:315
local exprlist -- ./lib/lua-parser/parser.lua:316
if stat["tag"] == "Set" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then -- ./lib/lua-parser/parser.lua:318
exprlist = stat[# stat] -- ./lib/lua-parser/parser.lua:319
elseif stat["tag"] == "Push" or stat["tag"] == "Return" then -- ./lib/lua-parser/parser.lua:320
exprlist = stat -- ./lib/lua-parser/parser.lua:321
end -- ./lib/lua-parser/parser.lua:321
local last = exprlist[# exprlist] -- last value in ExprList -- ./lib/lua-parser/parser.lua:324
if last["tag"] == "Function" and last["is_short"] and not last["is_method"] and # last[1] == 1 then -- ./lib/lua-parser/parser.lua:328
local p = i -- ./lib/lua-parser/parser.lua:329
for j, fstat in ipairs(last[2]) do -- ./lib/lua-parser/parser.lua:330
p = i + j -- ./lib/lua-parser/parser.lua:331
table["insert"](block, p, fstat) -- copy stats from func body to block -- ./lib/lua-parser/parser.lua:332
if stat["move_up_block"] then -- extracted stats inherit move_up_block from statement -- ./lib/lua-parser/parser.lua:334
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + stat["move_up_block"] -- ./lib/lua-parser/parser.lua:335
end -- ./lib/lua-parser/parser.lua:335
if block["is_singlestatblock"] then -- if it's a single stat block, mark them to move them outside of the block -- ./lib/lua-parser/parser.lua:338
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:339
end -- ./lib/lua-parser/parser.lua:339
end -- ./lib/lua-parser/parser.lua:339
exprlist[# exprlist] = last[1] -- replace func with paren and expressions -- ./lib/lua-parser/parser.lua:343
exprlist[# exprlist]["tag"] = "Paren" -- ./lib/lua-parser/parser.lua:344
if not isRecCall then -- if superfluous statements won't be moved in a next recursion, let fixStructure handle things -- ./lib/lua-parser/parser.lua:346
for j = p + 1, # block, 1 do -- ./lib/lua-parser/parser.lua:347
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:348
end -- ./lib/lua-parser/parser.lua:348
end -- ./lib/lua-parser/parser.lua:348
return block, i -- ./lib/lua-parser/parser.lua:352
elseif last["tag"]:match("Expr$") then -- ./lib/lua-parser/parser.lua:355
local r = searchEndRec({ last }) -- ./lib/lua-parser/parser.lua:356
if r then -- ./lib/lua-parser/parser.lua:357
for j = 2, # r, 1 do -- ./lib/lua-parser/parser.lua:358
table["insert"](block, i + j - 1, r[j]) -- move back superflous statements from our new table to our real block -- ./lib/lua-parser/parser.lua:359
end -- move back superflous statements from our new table to our real block -- ./lib/lua-parser/parser.lua:359
return block, i -- ./lib/lua-parser/parser.lua:361
end -- ./lib/lua-parser/parser.lua:361
elseif last["tag"] == "Function" then -- ./lib/lua-parser/parser.lua:363
local r = searchEndRec(last[2]) -- ./lib/lua-parser/parser.lua:364
if r then -- ./lib/lua-parser/parser.lua:365
return block, i -- ./lib/lua-parser/parser.lua:366
end -- ./lib/lua-parser/parser.lua:366
end -- ./lib/lua-parser/parser.lua:366
elseif stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Do") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./lib/lua-parser/parser.lua:371
local blocks -- ./lib/lua-parser/parser.lua:372
if stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then -- ./lib/lua-parser/parser.lua:374
blocks = stat -- ./lib/lua-parser/parser.lua:375
elseif stat["tag"]:match("^Do") then -- ./lib/lua-parser/parser.lua:376
blocks = { stat } -- ./lib/lua-parser/parser.lua:377
end -- ./lib/lua-parser/parser.lua:377
for _, iblock in ipairs(blocks) do -- ./lib/lua-parser/parser.lua:380
if iblock["tag"] == "Block" then -- blocks -- ./lib/lua-parser/parser.lua:381
local oldLen = # iblock -- ./lib/lua-parser/parser.lua:382
local newiBlock, newEnd = searchEndRec(iblock, true) -- ./lib/lua-parser/parser.lua:383
if newiBlock then -- if end in the block -- ./lib/lua-parser/parser.lua:384
local p = i -- ./lib/lua-parser/parser.lua:385
for j = newEnd + (# iblock - oldLen) + 1, # iblock, 1 do -- move all statements after the newely added statements to the parent block -- ./lib/lua-parser/parser.lua:386
p = p + 1 -- ./lib/lua-parser/parser.lua:387
table["insert"](block, p, iblock[j]) -- ./lib/lua-parser/parser.lua:388
iblock[j] = nil -- ./lib/lua-parser/parser.lua:389
end -- ./lib/lua-parser/parser.lua:389
if not isRecCall then -- if superfluous statements won't be moved in a next recursion, let fixStructure handle things -- ./lib/lua-parser/parser.lua:392
for j = p + 1, # block, 1 do -- ./lib/lua-parser/parser.lua:393
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1 -- ./lib/lua-parser/parser.lua:394
end -- ./lib/lua-parser/parser.lua:394
end -- ./lib/lua-parser/parser.lua:394
return block, i -- ./lib/lua-parser/parser.lua:398
end -- ./lib/lua-parser/parser.lua:398
end -- ./lib/lua-parser/parser.lua:398
end -- ./lib/lua-parser/parser.lua:398
end -- ./lib/lua-parser/parser.lua:398
end -- ./lib/lua-parser/parser.lua:398
return nil -- ./lib/lua-parser/parser.lua:404
end -- ./lib/lua-parser/parser.lua:404
local function searchEnd(s, p, t) -- match time capture which try to restructure the AST to free an "end" for us -- ./lib/lua-parser/parser.lua:407
local r = searchEndRec(fixStructure(t)) -- ./lib/lua-parser/parser.lua:408
if not r then -- ./lib/lua-parser/parser.lua:409
return false -- ./lib/lua-parser/parser.lua:410
end -- ./lib/lua-parser/parser.lua:410
return true, r -- ./lib/lua-parser/parser.lua:412
end -- ./lib/lua-parser/parser.lua:412
local function expectBlockOrSingleStatWithStartEnd(start, startLabel, stopLabel, canFollow) -- will try a SingleStat if start doesn't match -- ./lib/lua-parser/parser.lua:415
if canFollow then -- ./lib/lua-parser/parser.lua:416
return (- start * V("SingleStatBlock") * canFollow ^ - 1) + (expect(start, startLabel) * ((V("Block") * (canFollow + kw("end"))) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./lib/lua-parser/parser.lua:419
else -- ./lib/lua-parser/parser.lua:419
return (- start * V("SingleStatBlock")) + (expect(start, startLabel) * ((V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(stopLabel)))) -- ./lib/lua-parser/parser.lua:423
end -- ./lib/lua-parser/parser.lua:423
end -- ./lib/lua-parser/parser.lua:423
local function expectBlockWithEnd(label) -- can't work *optionnaly* with SingleStat unfortunatly -- ./lib/lua-parser/parser.lua:427
return (V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(label)) -- ./lib/lua-parser/parser.lua:429
end -- ./lib/lua-parser/parser.lua:429
local function maybeBlockWithEnd() -- same as above but don't error if it doesn't match -- ./lib/lua-parser/parser.lua:432
return (V("BlockNoErr") * kw("end")) + Cmt(V("BlockNoErr"), searchEnd) -- ./lib/lua-parser/parser.lua:434
end -- ./lib/lua-parser/parser.lua:434
local G = { -- ./lib/lua-parser/parser.lua:438
V("Lua"), -- ./lib/lua-parser/parser.lua:438
["Lua"] = (V("Shebang") ^ - 1 * V("Skip") * V("Block") * expect(P(- 1), "Extra")) / fixStructure, -- ./lib/lua-parser/parser.lua:439
["Shebang"] = P("#!") * (P(1) - P("\
")) ^ 0, -- ./lib/lua-parser/parser.lua:440
["Block"] = tagC("Block", (V("Stat") + - V("BlockEnd") * throw("InvalidStat")) ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- ./lib/lua-parser/parser.lua:442
["Stat"] = V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat") + V("LocalStat") + V("FuncStat") + V("BreakStat") + V("LabelStat") + V("GoToStat") + V("FuncCall") + V("Assignment") + V("LetStat") + V("ContinueStat") + V("PushStat") + sym(";"), -- ./lib/lua-parser/parser.lua:447
["BlockEnd"] = P("return") + "end" + "elseif" + "else" + "until" + "]" + - 1 + V("ImplicitPushStat") + V("Assignment"), -- ./lib/lua-parser/parser.lua:448
["SingleStatBlock"] = tagC("Block", V("Stat") + V("RetStat") + V("ImplicitPushStat")) / function(t) -- ./lib/lua-parser/parser.lua:450
t["is_singlestatblock"] = true -- ./lib/lua-parser/parser.lua:450
return t -- ./lib/lua-parser/parser.lua:450
end, -- ./lib/lua-parser/parser.lua:450
["BlockNoErr"] = tagC("Block", V("Stat") ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1), -- used to check if something a valid block without throwing an error -- ./lib/lua-parser/parser.lua:451
["IfStat"] = tagC("If", V("IfPart")), -- ./lib/lua-parser/parser.lua:453
["IfPart"] = kw("if") * expect(V("Expr"), "ExprIf") * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./lib/lua-parser/parser.lua:454
["ElseIfPart"] = kw("elseif") * expect(V("Expr"), "ExprEIf") * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenEIf", "EndIf", V("ElseIfPart") + V("ElsePart")), -- ./lib/lua-parser/parser.lua:455
["ElsePart"] = kw("else") * expectBlockWithEnd("EndIf"), -- ./lib/lua-parser/parser.lua:456
["DoStat"] = kw("do") * expectBlockWithEnd("EndDo") / tagDo, -- ./lib/lua-parser/parser.lua:458
["WhileStat"] = tagC("While", kw("while") * expect(V("Expr"), "ExprWhile") * V("WhileBody")), -- ./lib/lua-parser/parser.lua:459
["WhileBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoWhile", "EndWhile"), -- ./lib/lua-parser/parser.lua:460
["RepeatStat"] = tagC("Repeat", kw("repeat") * V("Block") * expect(kw("until"), "UntilRep") * expect(V("Expr"), "ExprRep")), -- ./lib/lua-parser/parser.lua:461
["ForStat"] = kw("for") * expect(V("ForNum") + V("ForIn"), "ForRange"), -- ./lib/lua-parser/parser.lua:463
["ForNum"] = tagC("Fornum", V("Id") * sym("=") * V("NumRange") * V("ForBody")), -- ./lib/lua-parser/parser.lua:464
["NumRange"] = expect(V("Expr"), "ExprFor1") * expect(sym(","), "CommaFor") * expect(V("Expr"), "ExprFor2") * (sym(",") * expect(V("Expr"), "ExprFor3")) ^ - 1, -- ./lib/lua-parser/parser.lua:466
["ForIn"] = tagC("Forin", V("NameList") * expect(kw("in"), "InFor") * expect(V("ExprList"), "EListFor") * V("ForBody")), -- ./lib/lua-parser/parser.lua:467
["ForBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoFor", "EndFor"), -- ./lib/lua-parser/parser.lua:468
["LocalStat"] = kw("local") * expect(V("LocalFunc") + V("LocalAssign"), "DefLocal"), -- ./lib/lua-parser/parser.lua:470
["LocalFunc"] = tagC("Localrec", kw("function") * expect(V("Id"), "NameLFunc") * V("FuncBody")) / fixFuncStat, -- ./lib/lua-parser/parser.lua:471
["LocalAssign"] = tagC("Local", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))), -- ./lib/lua-parser/parser.lua:472
["LetStat"] = kw("let") * expect(V("LetAssign"), "DefLet"), -- ./lib/lua-parser/parser.lua:474
["LetAssign"] = tagC("Let", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))), -- ./lib/lua-parser/parser.lua:475
["Assignment"] = tagC("Set", V("VarList") * V("BinOp") ^ - 1 * (P("=") / "=") * V("BinOp") ^ - 1 * V("Skip") * expect(V("ExprList"), "EListAssign")), -- ./lib/lua-parser/parser.lua:477
["FuncStat"] = tagC("Set", kw("function") * expect(V("FuncName"), "FuncName") * V("FuncBody")) / fixFuncStat, -- ./lib/lua-parser/parser.lua:479
["FuncName"] = Cf(V("Id") * (sym(".") * expect(V("StrId"), "NameFunc1")) ^ 0, insertIndex) * (sym(":") * expect(V("StrId"), "NameFunc2")) ^ - 1 / markMethod, -- ./lib/lua-parser/parser.lua:481
["FuncBody"] = tagC("Function", V("FuncParams") * expectBlockWithEnd("EndFunc")), -- ./lib/lua-parser/parser.lua:482
["FuncParams"] = expect(sym("("), "OParenPList") * V("ParList") * expect(sym(")"), "CParenPList"), -- ./lib/lua-parser/parser.lua:483
["ParList"] = V("NamedParList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()), -- Cc({}) generates a bug since the {} would be shared across parses -- ./lib/lua-parser/parser.lua:486
["ShortFuncDef"] = tagC("Function", V("ShortFuncParams") * maybeBlockWithEnd()) / fixShortFunc, -- ./lib/lua-parser/parser.lua:488
["ShortFuncParams"] = (sym(":") / ":") ^ - 1 * sym("(") * V("ParList") * sym(")"), -- ./lib/lua-parser/parser.lua:489
["NamedParList"] = tagC("NamedParList", commaSep(V("NamedPar"))), -- ./lib/lua-parser/parser.lua:491
["NamedPar"] = tagC("ParPair", V("ParKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Id"), -- ./lib/lua-parser/parser.lua:493
["ParKey"] = V("Id") * # ("=" * - P("=")), -- ./lib/lua-parser/parser.lua:494
["LabelStat"] = tagC("Label", sym("::") * expect(V("Name"), "Label") * expect(sym("::"), "CloseLabel")), -- ./lib/lua-parser/parser.lua:496
["GoToStat"] = tagC("Goto", kw("goto") * expect(V("Name"), "Goto")), -- ./lib/lua-parser/parser.lua:497
["BreakStat"] = tagC("Break", kw("break")), -- ./lib/lua-parser/parser.lua:498
["ContinueStat"] = tagC("Continue", kw("continue")), -- ./lib/lua-parser/parser.lua:499
["RetStat"] = tagC("Return", kw("return") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./lib/lua-parser/parser.lua:500
["PushStat"] = tagC("Push", kw("push") * commaSep(V("Expr"), "RetList") ^ - 1), -- ./lib/lua-parser/parser.lua:502
["ImplicitPushStat"] = tagC("Push", commaSep(V("Expr"), "RetList")), -- ./lib/lua-parser/parser.lua:503
["NameList"] = tagC("NameList", commaSep(V("Id"))), -- ./lib/lua-parser/parser.lua:505
["VarList"] = tagC("VarList", commaSep(V("VarExpr"))), -- ./lib/lua-parser/parser.lua:506
["ExprList"] = tagC("ExpList", commaSep(V("Expr"), "ExprList")), -- ./lib/lua-parser/parser.lua:507
["Expr"] = V("OrExpr"), -- ./lib/lua-parser/parser.lua:509
["OrExpr"] = chainOp(V("AndExpr"), V("OrOp"), "OrExpr"), -- ./lib/lua-parser/parser.lua:510
["AndExpr"] = chainOp(V("RelExpr"), V("AndOp"), "AndExpr"), -- ./lib/lua-parser/parser.lua:511
["RelExpr"] = chainOp(V("BOrExpr"), V("RelOp"), "RelExpr"), -- ./lib/lua-parser/parser.lua:512
["BOrExpr"] = chainOp(V("BXorExpr"), V("BOrOp"), "BOrExpr"), -- ./lib/lua-parser/parser.lua:513
["BXorExpr"] = chainOp(V("BAndExpr"), V("BXorOp"), "BXorExpr"), -- ./lib/lua-parser/parser.lua:514
["BAndExpr"] = chainOp(V("ShiftExpr"), V("BAndOp"), "BAndExpr"), -- ./lib/lua-parser/parser.lua:515
["ShiftExpr"] = chainOp(V("ConcatExpr"), V("ShiftOp"), "ShiftExpr"), -- ./lib/lua-parser/parser.lua:516
["ConcatExpr"] = V("AddExpr") * (V("ConcatOp") * expect(V("ConcatExpr"), "ConcatExpr")) ^ - 1 / binaryOp, -- ./lib/lua-parser/parser.lua:517
["AddExpr"] = chainOp(V("MulExpr"), V("AddOp"), "AddExpr"), -- ./lib/lua-parser/parser.lua:518
["MulExpr"] = chainOp(V("UnaryExpr"), V("MulOp"), "MulExpr"), -- ./lib/lua-parser/parser.lua:519
["UnaryExpr"] = V("UnaryOp") * expect(V("UnaryExpr"), "UnaryExpr") / unaryOp + V("PowExpr"), -- ./lib/lua-parser/parser.lua:521
["PowExpr"] = V("SimpleExpr") * (V("PowOp") * expect(V("UnaryExpr"), "PowExpr")) ^ - 1 / binaryOp, -- ./lib/lua-parser/parser.lua:522
["SimpleExpr"] = tagC("Number", V("Number")) + tagC("Nil", kw("nil")) + tagC("Boolean", kw("false") * Cc(false)) + tagC("Boolean", kw("true") * Cc(true)) + tagC("Dots", sym("...")) + V("FuncDef") + V("ShortFuncDef") + V("SuffixedExpr") + V("StatExpr"), -- ./lib/lua-parser/parser.lua:532
["StatExpr"] = (V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat")) / statToExpr, -- ./lib/lua-parser/parser.lua:534
["FuncCall"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./lib/lua-parser/parser.lua:536
return exp["tag"] == "Call" or exp["tag"] == "Invoke", exp -- ./lib/lua-parser/parser.lua:536
end), -- ./lib/lua-parser/parser.lua:536
["VarExpr"] = Cmt(V("SuffixedExpr"), function(s, i, exp) -- ./lib/lua-parser/parser.lua:537
return exp["tag"] == "Id" or exp["tag"] == "Index", exp -- ./lib/lua-parser/parser.lua:537
end), -- ./lib/lua-parser/parser.lua:537
["SuffixedExpr"] = Cf(V("PrimaryExpr") * (V("Index") + V("Invoke") + V("Call")) ^ 0 + V("NoCallPrimaryExpr") * - V("Call") * (V("Index") + V("Invoke") + V("Call")) ^ 0 + V("NoCallPrimaryExpr"), makeIndexOrCall), -- ./lib/lua-parser/parser.lua:541
["PrimaryExpr"] = V("SelfId") * (V("SelfCall") + V("SelfIndex")) + V("Id") + tagC("Paren", sym("(") * expect(V("Expr"), "ExprParen") * expect(sym(")"), "CParenExpr")), -- ./lib/lua-parser/parser.lua:544
["NoCallPrimaryExpr"] = tagC("String", V("String")) + V("Table") + V("TableCompr"), -- ./lib/lua-parser/parser.lua:545
["Index"] = tagC("DotIndex", sym("." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("ArrayIndex", sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")), -- ./lib/lua-parser/parser.lua:547
["Call"] = tagC("Call", V("FuncArgs")), -- ./lib/lua-parser/parser.lua:548
["Invoke"] = tagC("Invoke", Cg(sym(":" * - P(":")) * expect(V("StrId"), "NameMeth") * expect(V("FuncArgs"), "MethArgs"))), -- ./lib/lua-parser/parser.lua:549
["SelfIndex"] = tagC("DotIndex", V("StrId")), -- ./lib/lua-parser/parser.lua:550
["SelfCall"] = tagC("Invoke", Cg(V("StrId") * V("FuncArgs"))), -- ./lib/lua-parser/parser.lua:551
["FuncDef"] = (kw("function") * V("FuncBody")), -- ./lib/lua-parser/parser.lua:553
["FuncArgs"] = sym("(") * commaSep(V("Expr"), "ArgList") ^ - 1 * expect(sym(")"), "CParenArgs") + V("Table") + tagC("String", V("String")), -- ./lib/lua-parser/parser.lua:556
["Table"] = tagC("Table", sym("{") * V("FieldList") ^ - 1 * expect(sym("}"), "CBraceTable")), -- ./lib/lua-parser/parser.lua:558
["FieldList"] = sepBy(V("Field"), V("FieldSep")) * V("FieldSep") ^ - 1, -- ./lib/lua-parser/parser.lua:559
["Field"] = tagC("Pair", V("FieldKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Expr"), -- ./lib/lua-parser/parser.lua:561
["FieldKey"] = sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprFKey") * expect(sym("]"), "CBracketFKey") + V("StrId") * # ("=" * - P("=")), -- ./lib/lua-parser/parser.lua:563
["FieldSep"] = sym(",") + sym(";"), -- ./lib/lua-parser/parser.lua:564
["TableCompr"] = tagC("TableCompr", sym("[") * V("Block") * expect(sym("]"), "CBracketTableCompr")), -- ./lib/lua-parser/parser.lua:566
["SelfId"] = tagC("Id", sym("@") / "self"), -- ./lib/lua-parser/parser.lua:568
["Id"] = tagC("Id", V("Name")) + V("SelfId"), -- ./lib/lua-parser/parser.lua:569
["StrId"] = tagC("String", V("Name")), -- ./lib/lua-parser/parser.lua:570
["Skip"] = (V("Space") + V("Comment")) ^ 0, -- ./lib/lua-parser/parser.lua:573
["Space"] = space ^ 1, -- ./lib/lua-parser/parser.lua:574
["Comment"] = P("--") * V("LongStr") / function() -- ./lib/lua-parser/parser.lua:575
return  -- ./lib/lua-parser/parser.lua:575
end + P("--") * (P(1) - P("\
")) ^ 0, -- ./lib/lua-parser/parser.lua:576
["Name"] = token(- V("Reserved") * C(V("Ident"))), -- ./lib/lua-parser/parser.lua:578
["Reserved"] = V("Keywords") * - V("IdRest"), -- ./lib/lua-parser/parser.lua:579
["Keywords"] = P("and") + "break" + "do" + "elseif" + "else" + "end" + "false" + "for" + "function" + "goto" + "if" + "in" + "local" + "nil" + "not" + "or" + "repeat" + "return" + "then" + "true" + "until" + "while", -- ./lib/lua-parser/parser.lua:583
["Ident"] = V("IdStart") * V("IdRest") ^ 0, -- ./lib/lua-parser/parser.lua:584
["IdStart"] = alpha + P("_"), -- ./lib/lua-parser/parser.lua:585
["IdRest"] = alnum + P("_"), -- ./lib/lua-parser/parser.lua:586
["Number"] = token(C(V("Hex") + V("Float") + V("Int"))), -- ./lib/lua-parser/parser.lua:588
["Hex"] = (P("0x") + "0X") * ((xdigit ^ 0 * V("DeciHex")) + (expect(xdigit ^ 1, "DigitHex") * V("DeciHex") ^ - 1)) * V("ExpoHex") ^ - 1, -- ./lib/lua-parser/parser.lua:589
["Float"] = V("Decimal") * V("Expo") ^ - 1 + V("Int") * V("Expo"), -- ./lib/lua-parser/parser.lua:591
["Decimal"] = digit ^ 1 * "." * digit ^ 0 + P(".") * - P(".") * expect(digit ^ 1, "DigitDeci"), -- ./lib/lua-parser/parser.lua:593
["DeciHex"] = P(".") * xdigit ^ 0, -- ./lib/lua-parser/parser.lua:594
["Expo"] = S("eE") * S("+-") ^ - 1 * expect(digit ^ 1, "DigitExpo"), -- ./lib/lua-parser/parser.lua:595
["ExpoHex"] = S("pP") * S("+-") ^ - 1 * expect(xdigit ^ 1, "DigitExpo"), -- ./lib/lua-parser/parser.lua:596
["Int"] = digit ^ 1, -- ./lib/lua-parser/parser.lua:597
["String"] = token(V("ShortStr") + V("LongStr")), -- ./lib/lua-parser/parser.lua:599
["ShortStr"] = P("\"") * Cs((V("EscSeq") + (P(1) - S("\"\
"))) ^ 0) * expect(P("\""), "Quote") + P("'") * Cs((V("EscSeq") + (P(1) - S("'\
"))) ^ 0) * expect(P("'"), "Quote"), -- ./lib/lua-parser/parser.lua:601
["EscSeq"] = P("\\") / "" * (P("a") / "\7" + P("b") / "\8" + P("f") / "\12" + P("n") / "\
" + P("r") / "\13" + P("t") / "\9" + P("v") / "\11" + P("\
") / "\
" + P("\13") / "\
" + P("\\") / "\\" + P("\"") / "\"" + P("'") / "'" + P("z") * space ^ 0 / "" + digit * digit ^ - 2 / tonumber / string["char"] + P("x") * expect(C(xdigit * xdigit), "HexEsc") * Cc(16) / tonumber / string["char"] + P("u") * expect("{", "OBraceUEsc") * expect(C(xdigit ^ 1), "DigitUEsc") * Cc(16) * expect("}", "CBraceUEsc") / tonumber / (utf8 and utf8["char"] or string["char"]) + throw("EscSeq")), -- ./lib/lua-parser/parser.lua:631
["LongStr"] = V("Open") * C((P(1) - V("CloseEq")) ^ 0) * expect(V("Close"), "CloseLStr") / function(s, eqs) -- ./lib/lua-parser/parser.lua:634
return s -- ./lib/lua-parser/parser.lua:634
end, -- ./lib/lua-parser/parser.lua:634
["Open"] = "[" * Cg(V("Equals"), "openEq") * "[" * P("\
") ^ - 1, -- ./lib/lua-parser/parser.lua:635
["Close"] = "]" * C(V("Equals")) * "]", -- ./lib/lua-parser/parser.lua:636
["Equals"] = P("=") ^ 0, -- ./lib/lua-parser/parser.lua:637
["CloseEq"] = Cmt(V("Close") * Cb("openEq"), function(s, i, closeEq, openEq) -- ./lib/lua-parser/parser.lua:638
return # openEq == # closeEq -- ./lib/lua-parser/parser.lua:638
end), -- ./lib/lua-parser/parser.lua:638
["OrOp"] = kw("or") / "or", -- ./lib/lua-parser/parser.lua:640
["AndOp"] = kw("and") / "and", -- ./lib/lua-parser/parser.lua:641
["RelOp"] = sym("~=") / "ne" + sym("==") / "eq" + sym("<=") / "le" + sym(">=") / "ge" + sym("<") / "lt" + sym(">") / "gt", -- ./lib/lua-parser/parser.lua:647
["BOrOp"] = sym("|") / "bor", -- ./lib/lua-parser/parser.lua:648
["BXorOp"] = sym("~" * - P("=")) / "bxor", -- ./lib/lua-parser/parser.lua:649
["BAndOp"] = sym("&") / "band", -- ./lib/lua-parser/parser.lua:650
["ShiftOp"] = sym("<<") / "shl" + sym(">>") / "shr", -- ./lib/lua-parser/parser.lua:652
["ConcatOp"] = sym("..") / "concat", -- ./lib/lua-parser/parser.lua:653
["AddOp"] = sym("+") / "add" + sym("-") / "sub", -- ./lib/lua-parser/parser.lua:655
["MulOp"] = sym("*") / "mul" + sym("//") / "idiv" + sym("/") / "div" + sym("%") / "mod", -- ./lib/lua-parser/parser.lua:659
["UnaryOp"] = kw("not") / "not" + sym("-") / "unm" + sym("#") / "len" + sym("~") / "bnot", -- ./lib/lua-parser/parser.lua:663
["PowOp"] = sym("^") / "pow", -- ./lib/lua-parser/parser.lua:664
["BinOp"] = V("OrOp") + V("AndOp") + V("BOrOp") + V("BXorOp") + V("BAndOp") + V("ShiftOp") + V("ConcatOp") + V("AddOp") + V("MulOp") + V("PowOp") -- ./lib/lua-parser/parser.lua:665
} -- ./lib/lua-parser/parser.lua:665
local parser = {} -- ./lib/lua-parser/parser.lua:668
local validator = require("lib.lua-parser.validator") -- ./lib/lua-parser/parser.lua:670
local validate = validator["validate"] -- ./lib/lua-parser/parser.lua:671
local syntaxerror = validator["syntaxerror"] -- ./lib/lua-parser/parser.lua:672
parser["parse"] = function(subject, filename) -- ./lib/lua-parser/parser.lua:674
local errorinfo = { -- ./lib/lua-parser/parser.lua:675
["subject"] = subject, -- ./lib/lua-parser/parser.lua:675
["filename"] = filename -- ./lib/lua-parser/parser.lua:675
} -- ./lib/lua-parser/parser.lua:675
lpeg["setmaxstack"](1000) -- ./lib/lua-parser/parser.lua:676
local ast, label, errpos = lpeg["match"](G, subject, nil, errorinfo) -- ./lib/lua-parser/parser.lua:677
if not ast then -- ./lib/lua-parser/parser.lua:678
local errmsg = labels[label][2] -- ./lib/lua-parser/parser.lua:679
return ast, syntaxerror(errorinfo, errpos, errmsg) -- ./lib/lua-parser/parser.lua:680
end -- ./lib/lua-parser/parser.lua:680
return validate(ast, errorinfo) -- ./lib/lua-parser/parser.lua:682
end -- ./lib/lua-parser/parser.lua:682
return parser -- ./lib/lua-parser/parser.lua:685
end -- ./lib/lua-parser/parser.lua:685
local parser = _() or parser -- ./lib/lua-parser/parser.lua:689
package["loaded"]["lib.lua-parser.parser"] = parser or true -- ./lib/lua-parser/parser.lua:690
local candran = { ["VERSION"] = "0.9.0" } -- candran.can:14
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
local filepath = assert(util["search"](modpath), "No module named \"" .. modpath .. "\"") -- candran.can:89
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
]*)") do -- candran.can:251
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
