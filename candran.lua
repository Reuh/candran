local function _()
local util = {}
util["search"] = function(modpath, exts)
if exts == nil then exts = {
"can",
"lua"
} end
for _, ext in ipairs(exts) do
for path in package["path"]:gmatch("[^;]+") do
local fpath = path:gsub("%.lua", "." .. ext):gsub("%?", (modpath:gsub("%.", "/")))
local f = io["open"](fpath)
if f then
f:close()
return fpath
end
end
end
end
util["load"] = function(str, name, env)
if _VERSION == "Lua 5.1" then
local fn, err = loadstring(str, name)
if not fn then
return fn, err
end
return env ~= nil and setfenv(fn, env) or fn
else
if env then
return load(str, name, nil, env)
else
return load(str, name)
end
end
end
util["merge"] = function(...)
local r = {}
for _, t in ipairs({ ... }) do
for k, v in pairs(t) do
r[k] = v
end
end
return r
end
return util
end
local util = _() or util
package["loaded"]["lib.util"] = util or true
local function _()
local ipairs, pairs, setfenv, tonumber, loadstring, type = ipairs, pairs, setfenv, tonumber, loadstring, type
local tinsert, tconcat = table["insert"], table["concat"]
local function commonerror(msg)
return nil, ("[cmdline]: " .. msg)
end
local function argerror(msg, numarg)
msg = msg and (": " .. msg) or ""
return nil, ("[cmdline]: bad argument #" .. numarg .. msg)
end
local function iderror(numarg)
return argerror("ID not valid", numarg)
end
local function idcheck(id)
return id:match("^[%a_][%w_]*$") and true
end
return function(t_in, options, params)
local t_out = {}
for i, v in ipairs(t_in) do
local prefix, command = v:sub(1, 1), v:sub(2)
if prefix == "$" then
tinsert(t_out, command)
elseif prefix == "-" then
for id in command:gmatch("[^,;]+") do
if not idcheck(id) then
return iderror(i)
end
t_out[id] = true
end
elseif prefix == "!" then
local f, err = loadstring(command)
if not f then
return argerror(err, i)
end
setfenv(f, t_out)()
elseif v:find("=") then
local ids, val = v:match("^([^=]+)%=(.*)")
if not ids then
return argerror("invalid assignment syntax", i)
end
if val == "false" then
val = false
elseif val == "true" then
val = true
else
val = val:sub(1, 1) == "$" and val:sub(2) or tonumber(val) or val
end
for id in ids:gmatch("[^,;]+") do
if not idcheck(id) then
return iderror(i)
end
t_out[id] = val
end
else
tinsert(t_out, v)
end
end
if options then
local lookup, unknown = {}, {}
for _, v in ipairs(options) do
lookup[v] = true
end
for k, _ in pairs(t_out) do
if lookup[k] == nil and type(k) == "string" then
tinsert(unknown, k)
end
end
if # unknown > 0 then
return commonerror("unknown options: " .. tconcat(unknown, ", "))
end
end
if params then
local missing = {}
for _, v in ipairs(params) do
if t_out[v] == nil then
tinsert(missing, v)
end
end
if # missing > 0 then
return commonerror("missing parameters: " .. tconcat(missing, ", "))
end
end
return t_out
end
end
local cmdline = _() or cmdline
package["loaded"]["lib.cmdline"] = cmdline or true
local function _()
return function(code, ast, options)
local lastInputPos = 1
local prevLinePos = 1
local lastSource = options["chunkname"] or "nil"
local lastLine = 1
local indentLevel = 0
local function newline()
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel)
if options["mapLines"] then
local sub = code:sub(lastInputPos)
local source, line = sub:sub(1, sub:find("\
")):match("%-%- (.-)%:(%d+)\
")
if source and line then
lastSource = source
lastLine = tonumber(line)
else
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do
lastLine = lastLine + (1)
end
end
prevLinePos = lastInputPos
r = " -- " .. lastSource .. ":" .. lastLine .. r
end
return r
end
local function indent()
indentLevel = indentLevel + (1)
return newline()
end
local function unindent()
indentLevel = indentLevel - (1)
return newline()
end
local required = {}
local requireStr = ""
local function addRequire(mod, name, field)
if not required[mod] then
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"])
required[mod] = true
end
end
local function var(name)
return options["variablePrefix"] .. name
end
local loop = {
"While",
"Repeat",
"Fornum",
"Forin"
}
local func = {
"Function",
"TableCompr",
"DoExpr",
"WhileExpr",
"RepeatExpr",
"IfExpr",
"FornumExpr",
"ForinExpr"
}
local function any(list, tags, nofollow)
if nofollow == nil then nofollow = {} end
local tagsCheck = {}
for _, tag in ipairs(tags) do
tagsCheck[tag] = true
end
local nofollowCheck = {}
for _, tag in ipairs(nofollow) do
nofollowCheck[tag] = true
end
for _, node in ipairs(list) do
if type(node) == "table" then
if tagsCheck[node["tag"]] then
return node
end
if not nofollowCheck[node["tag"]] then
local r = any(node, tags, nofollow)
if r then
return r
end
end
end
end
return nil
end
local states = { ["push"] = {} }
local function push(name, state)
table["insert"](states[name], state)
return ""
end
local function pop(name)
table["remove"](states[name])
return ""
end
local function peek(name)
return states[name][# states[name]]
end
local tags
local function lua(ast, forceTag, ...)
if options["mapLines"] and ast["pos"] then
lastInputPos = ast["pos"]
end
return tags[forceTag or ast["tag"]](ast, ...)
end
local UNPACK = function(list, i, j)
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")"
end
local APPEND = function(t, toAppend)
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end"
end
tags = setmetatable({
["Block"] = function(t)
local hasPush = peek("push") == nil and any(t, { "Push" }, func)
if hasPush and hasPush == t[# t] then
hasPush["tag"] = "Return"
hasPush = false
end
local r = ""
if hasPush then
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline())
end
for i = 1, # t - 1, 1 do
r = r .. (lua(t[i]) .. newline())
end
if t[# t] then
r = r .. (lua(t[# t]))
end
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push"))
end
return r
end,
["Do"] = function(t)
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end"
end,
["Set"] = function(t)
if # t == 2 then
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs")
elseif # t == 3 then
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs")
elseif # t == 4 then
if t[3] == "=" then
local r = lua(t[1], "_lhs") .. " = " .. lua({
t[2],
t[1][1],
{
["tag"] = "Paren",
t[4][1]
}
}, "Op")
for i = 2, math["min"](# t[4], # t[1]), 1 do
r = r .. (", " .. lua({
t[2],
t[1][i],
{
["tag"] = "Paren",
t[4][i]
}
}, "Op"))
end
return r
else
local r = lua(t[1], "_lhs") .. " = " .. lua({
t[3],
{
["tag"] = "Paren",
t[4][1]
},
t[1][1]
}, "Op")
for i = 2, math["min"](# t[4], # t[1]), 1 do
r = r .. (", " .. lua({
t[3],
{
["tag"] = "Paren",
t[4][i]
},
t[1][i]
}, "Op"))
end
return r
end
else
local r = lua(t[1], "_lhs") .. " = " .. lua({
t[2],
t[1][1],
{
["tag"] = "Op",
t[4],
{
["tag"] = "Paren",
t[5][1]
},
t[1][1]
}
}, "Op")
for i = 2, math["min"](# t[5], # t[1]), 1 do
r = r .. (", " .. lua({
t[2],
t[1][i],
{
["tag"] = "Op",
t[4],
{
["tag"] = "Paren",
t[5][i]
},
t[1][i]
}
}, "Op"))
end
return r
end
end,
["While"] = function(t)
local hasContinue = any(t[2], { "Continue" }, loop)
local r = "while " .. lua(t[1]) .. " do" .. indent()
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[2]))
if hasContinue then
r = r .. (unindent() .. "until true")
end
r = r .. (unindent() .. "end")
return r
end,
["Repeat"] = function(t)
local hasContinue = any(t[2], { "Continue" }, loop)
local r = "repeat" .. indent()
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[1]))
if hasContinue then
r = r .. (unindent() .. "until true")
end
r = r .. (unindent() .. "until " .. lua(t[2]))
return r
end,
["If"] = function(t)
local r = "if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()
for i = 3, # t - 1, 2 do
r = r .. ("elseif " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent())
end
if # t % 2 == 1 then
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent())
end
return r .. "end"
end,
["Fornum"] = function(t)
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3])
if # t == 5 then
local hasContinue = any(t[5], { "Continue" }, loop)
r = r .. (", " .. lua(t[4]) .. " do" .. indent())
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[5]))
if hasContinue then
r = r .. ("until true" .. unindent())
end
return r .. unindent() .. "end"
else
local hasContinue = any(t[4], { "Continue" }, loop)
r = r .. (" do" .. indent())
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[4]))
if hasContinue then
r = r .. (unindent() .. "until true")
end
return r .. unindent() .. "end"
end
end,
["Forin"] = function(t)
local hasContinue = any(t[3], { "Continue" }, loop)
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent()
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[3]))
if hasContinue then
r = r .. ("until true" .. unindent())
end
return r .. unindent() .. "end"
end,
["Local"] = function(t)
local r = "local " .. lua(t[1], "_lhs")
if t[2][1] then
r = r .. (" = " .. lua(t[2], "_lhs"))
end
return r
end,
["Let"] = function(t)
local nameList = lua(t[1], "_lhs")
local r = "local " .. nameList
if t[2][1] then
if any(t[2], {
"Function",
"Table",
"Paren"
}) then
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs"))
else
r = r .. (" = " .. lua(t[2], "_lhs"))
end
end
return r
end,
["Localrec"] = function(t)
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword")
end,
["Goto"] = function(t)
return "goto " .. lua(t, "Id")
end,
["Label"] = function(t)
return "::" .. lua(t, "Id") .. "::"
end,
["Return"] = function(t)
local push = peek("push")
if push then
local r = ""
for _, val in ipairs(t) do
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline())
end
return r .. "return " .. UNPACK(push)
else
return "return " .. lua(t, "_lhs")
end
end,
["Push"] = function(t)
local var = assert(peek("push"), "no context given for push")
r = ""
for i = 1, # t - 1, 1 do
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline())
end
if t[# t] then
if t[# t]["tag"] == "Call" or t[# t]["tag"] == "Invoke" then
r = r .. (APPEND(var, lua(t[# t])))
else
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t]))
end
end
return r
end,
["Break"] = function()
return "break"
end,
["Continue"] = function()
return "break"
end,
["Nil"] = function()
return "nil"
end,
["Dots"] = function()
return "..."
end,
["Boolean"] = function(t)
return tostring(t[1])
end,
["Number"] = function(t)
return tostring(t[1])
end,
["String"] = function(t)
return ("%q"):format(t[1])
end,
["_functionWithoutKeyword"] = function(t)
local r = "("
local decl = {}
if t[1][1] then
if t[1][1]["tag"] == "ParPair" then
local id = lua(t[1][1][1])
indentLevel = indentLevel + (1)
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end")
indentLevel = indentLevel - (1)
r = r .. (id)
else
r = r .. (lua(t[1][1]))
end
for i = 2, # t[1], 1 do
if t[1][i]["tag"] == "ParPair" then
local id = lua(t[1][i][1])
indentLevel = indentLevel + (1)
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end")
indentLevel = indentLevel - (1)
r = r .. (", " .. id)
else
r = r .. (", " .. lua(t[1][i]))
end
end
end
r = r .. (")" .. indent())
for _, d in ipairs(decl) do
r = r .. (d .. newline())
end
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then
t[2][# t[2]]["tag"] = "Return"
end
local hasPush = any(t[2], { "Push" }, func)
if hasPush then
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline())
else
push("push", false)
end
r = r .. (lua(t[2]))
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then
r = r .. (newline() .. "return " .. UNPACK(var("push")))
end
pop("push")
return r .. unindent() .. "end"
end,
["Function"] = function(t)
return "function" .. lua(t, "_functionWithoutKeyword")
end,
["Pair"] = function(t)
return "[" .. lua(t[1]) .. "] = " .. lua(t[2])
end,
["Table"] = function(t)
if # t == 0 then
return "{}"
elseif # t == 1 then
return "{ " .. lua(t, "_lhs") .. " }"
else
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}"
end
end,
["TableCompr"] = function(t)
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push")
end,
["Op"] = function(t)
local r
if # t == 2 then
if type(tags["_opid"][t[1]]) == "string" then
r = tags["_opid"][t[1]] .. " " .. lua(t[2])
else
r = tags["_opid"][t[1]](t[2])
end
else
if type(tags["_opid"][t[1]]) == "string" then
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3])
else
r = tags["_opid"][t[1]](t[2], t[3])
end
end
return r
end,
["Paren"] = function(t)
return "(" .. lua(t[1]) .. ")"
end,
["_statexpr"] = function(t, stat)
local hasPush = any(t, { "Push" }, func)
local r = "(function()" .. indent()
if hasPush then
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline())
else
push("push", false)
end
r = r .. (lua(t, stat))
if hasPush then
r = r .. (newline() .. "return " .. UNPACK(var("push")))
end
pop("push")
r = r .. (unindent() .. "end)()")
return r
end,
["DoExpr"] = function(t)
if t[# t]["tag"] == "Push" then
t[# t]["tag"] = "Return"
end
return lua(t, "_statexpr", "Do")
end,
["WhileExpr"] = function(t)
return lua(t, "_statexpr", "While")
end,
["RepeatExpr"] = function(t)
return lua(t, "_statexpr", "Repeat")
end,
["IfExpr"] = function(t)
for i = 2, # t do
local block = t[i]
if block[# block] and block[# block]["tag"] == "Push" then
block[# block]["tag"] = "Return"
end
end
return lua(t, "_statexpr", "If")
end,
["FornumExpr"] = function(t)
return lua(t, "_statexpr", "Fornum")
end,
["ForinExpr"] = function(t)
return lua(t, "_statexpr", "Forin")
end,
["Call"] = function(t)
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")"
end,
["Invoke"] = function(t)
return lua(t[1]) .. ":" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")"
end,
["_lhs"] = function(t, start, newlines)
if start == nil then start = 1 end
local r
if t[start] then
r = lua(t[start])
for i = start + 1, # t, 1 do
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i]))
end
else
r = ""
end
return r
end,
["Id"] = function(t)
return t[1]
end,
["Index"] = function(t)
return lua(t[1]) .. "[" .. lua(t[2]) .. "]"
end,
["_opid"] = {
["add"] = "+",
["sub"] = "-",
["mul"] = "*",
["div"] = "/",
["idiv"] = "//",
["mod"] = "%",
["pow"] = "^",
["concat"] = "..",
["band"] = "&",
["bor"] = "|",
["bxor"] = "~",
["shl"] = "<<",
["shr"] = ">>",
["eq"] = "==",
["ne"] = "~=",
["lt"] = "<",
["gt"] = ">",
["le"] = "<=",
["ge"] = ">=",
["and"] = "and",
["or"] = "or",
["unm"] = "-",
["len"] = "#",
["bnot"] = "~",
["not"] = "not"
}
}, { ["__index"] = function(self, key)
error("don't know how to compile a " .. tostring(key) .. " to Lua 5.3")
end })
local code = lua(ast) .. newline()
return requireStr .. code
end
end
local lua53 = _() or lua53
package["loaded"]["compiler.lua53"] = lua53 or true
local function _()
local function _()
return function(code, ast, options)
local lastInputPos = 1
local prevLinePos = 1
local lastSource = options["chunkname"] or "nil"
local lastLine = 1
local indentLevel = 0
local function newline()
local r = options["newline"] .. string["rep"](options["indentation"], indentLevel)
if options["mapLines"] then
local sub = code:sub(lastInputPos)
local source, line = sub:sub(1, sub:find("\
")):match("%-%- (.-)%:(%d+)\
")
if source and line then
lastSource = source
lastLine = tonumber(line)
else
for _ in code:sub(prevLinePos, lastInputPos):gmatch("\
") do
lastLine = lastLine + (1)
end
end
prevLinePos = lastInputPos
r = " -- " .. lastSource .. ":" .. lastLine .. r
end
return r
end
local function indent()
indentLevel = indentLevel + (1)
return newline()
end
local function unindent()
indentLevel = indentLevel - (1)
return newline()
end
local required = {}
local requireStr = ""
local function addRequire(mod, name, field)
if not required[mod] then
requireStr = requireStr .. ("local " .. options["variablePrefix"] .. name .. (" = require(%q)"):format(mod) .. (field and "." .. field or "") .. options["newline"])
required[mod] = true
end
end
local function var(name)
return options["variablePrefix"] .. name
end
local loop = {
"While",
"Repeat",
"Fornum",
"Forin"
}
local func = {
"Function",
"TableCompr",
"DoExpr",
"WhileExpr",
"RepeatExpr",
"IfExpr",
"FornumExpr",
"ForinExpr"
}
local function any(list, tags, nofollow)
if nofollow == nil then nofollow = {} end
local tagsCheck = {}
for _, tag in ipairs(tags) do
tagsCheck[tag] = true
end
local nofollowCheck = {}
for _, tag in ipairs(nofollow) do
nofollowCheck[tag] = true
end
for _, node in ipairs(list) do
if type(node) == "table" then
if tagsCheck[node["tag"]] then
return node
end
if not nofollowCheck[node["tag"]] then
local r = any(node, tags, nofollow)
if r then
return r
end
end
end
end
return nil
end
local states = { ["push"] = {} }
local function push(name, state)
table["insert"](states[name], state)
return ""
end
local function pop(name)
table["remove"](states[name])
return ""
end
local function peek(name)
return states[name][# states[name]]
end
local tags
local function lua(ast, forceTag, ...)
if options["mapLines"] and ast["pos"] then
lastInputPos = ast["pos"]
end
return tags[forceTag or ast["tag"]](ast, ...)
end
local UNPACK = function(list, i, j)
return "table.unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")"
end
local APPEND = function(t, toAppend)
return "do" .. indent() .. "local a = table.pack(" .. toAppend .. ")" .. newline() .. "table.move(a, 1, a.n, #" .. t .. "+1, " .. t .. ")" .. unindent() .. "end"
end
tags = setmetatable({
["Block"] = function(t)
local hasPush = peek("push") == nil and any(t, { "Push" }, func)
if hasPush and hasPush == t[# t] then
hasPush["tag"] = "Return"
hasPush = false
end
local r = ""
if hasPush then
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline())
end
for i = 1, # t - 1, 1 do
r = r .. (lua(t[i]) .. newline())
end
if t[# t] then
r = r .. (lua(t[# t]))
end
if hasPush and (t[# t] and t[# t]["tag"] ~= "Return") then
r = r .. (newline() .. "return " .. UNPACK(var("push")) .. pop("push"))
end
return r
end,
["Do"] = function(t)
return "do" .. indent() .. lua(t, "Block") .. unindent() .. "end"
end,
["Set"] = function(t)
if # t == 2 then
return lua(t[1], "_lhs") .. " = " .. lua(t[2], "_lhs")
elseif # t == 3 then
return lua(t[1], "_lhs") .. " = " .. lua(t[3], "_lhs")
elseif # t == 4 then
if t[3] == "=" then
local r = lua(t[1], "_lhs") .. " = " .. lua({
t[2],
t[1][1],
{
["tag"] = "Paren",
t[4][1]
}
}, "Op")
for i = 2, math["min"](# t[4], # t[1]), 1 do
r = r .. (", " .. lua({
t[2],
t[1][i],
{
["tag"] = "Paren",
t[4][i]
}
}, "Op"))
end
return r
else
local r = lua(t[1], "_lhs") .. " = " .. lua({
t[3],
{
["tag"] = "Paren",
t[4][1]
},
t[1][1]
}, "Op")
for i = 2, math["min"](# t[4], # t[1]), 1 do
r = r .. (", " .. lua({
t[3],
{
["tag"] = "Paren",
t[4][i]
},
t[1][i]
}, "Op"))
end
return r
end
else
local r = lua(t[1], "_lhs") .. " = " .. lua({
t[2],
t[1][1],
{
["tag"] = "Op",
t[4],
{
["tag"] = "Paren",
t[5][1]
},
t[1][1]
}
}, "Op")
for i = 2, math["min"](# t[5], # t[1]), 1 do
r = r .. (", " .. lua({
t[2],
t[1][i],
{
["tag"] = "Op",
t[4],
{
["tag"] = "Paren",
t[5][i]
},
t[1][i]
}
}, "Op"))
end
return r
end
end,
["While"] = function(t)
local hasContinue = any(t[2], { "Continue" }, loop)
local r = "while " .. lua(t[1]) .. " do" .. indent()
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[2]))
if hasContinue then
r = r .. (unindent() .. "until true")
end
r = r .. (unindent() .. "end")
return r
end,
["Repeat"] = function(t)
local hasContinue = any(t[2], { "Continue" }, loop)
local r = "repeat" .. indent()
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[1]))
if hasContinue then
r = r .. (unindent() .. "until true")
end
r = r .. (unindent() .. "until " .. lua(t[2]))
return r
end,
["If"] = function(t)
local r = "if " .. lua(t[1]) .. " then" .. indent() .. lua(t[2]) .. unindent()
for i = 3, # t - 1, 2 do
r = r .. ("elseif " .. lua(t[i]) .. " then" .. indent() .. lua(t[i + 1]) .. unindent())
end
if # t % 2 == 1 then
r = r .. ("else" .. indent() .. lua(t[# t]) .. unindent())
end
return r .. "end"
end,
["Fornum"] = function(t)
local r = "for " .. lua(t[1]) .. " = " .. lua(t[2]) .. ", " .. lua(t[3])
if # t == 5 then
local hasContinue = any(t[5], { "Continue" }, loop)
r = r .. (", " .. lua(t[4]) .. " do" .. indent())
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[5]))
if hasContinue then
r = r .. ("until true" .. unindent())
end
return r .. unindent() .. "end"
else
local hasContinue = any(t[4], { "Continue" }, loop)
r = r .. (" do" .. indent())
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[4]))
if hasContinue then
r = r .. (unindent() .. "until true")
end
return r .. unindent() .. "end"
end
end,
["Forin"] = function(t)
local hasContinue = any(t[3], { "Continue" }, loop)
local r = "for " .. lua(t[1], "_lhs") .. " in " .. lua(t[2], "_lhs") .. " do" .. indent()
if hasContinue then
r = r .. ("repeat" .. indent())
end
r = r .. (lua(t[3]))
if hasContinue then
r = r .. ("until true" .. unindent())
end
return r .. unindent() .. "end"
end,
["Local"] = function(t)
local r = "local " .. lua(t[1], "_lhs")
if t[2][1] then
r = r .. (" = " .. lua(t[2], "_lhs"))
end
return r
end,
["Let"] = function(t)
local nameList = lua(t[1], "_lhs")
local r = "local " .. nameList
if t[2][1] then
if any(t[2], {
"Function",
"Table",
"Paren"
}) then
r = r .. (newline() .. nameList .. " = " .. lua(t[2], "_lhs"))
else
r = r .. (" = " .. lua(t[2], "_lhs"))
end
end
return r
end,
["Localrec"] = function(t)
return "local function " .. lua(t[1][1]) .. lua(t[2][1], "_functionWithoutKeyword")
end,
["Goto"] = function(t)
return "goto " .. lua(t, "Id")
end,
["Label"] = function(t)
return "::" .. lua(t, "Id") .. "::"
end,
["Return"] = function(t)
local push = peek("push")
if push then
local r = ""
for _, val in ipairs(t) do
r = r .. (push .. "[#" .. push .. "+1] = " .. lua(val) .. newline())
end
return r .. "return " .. UNPACK(push)
else
return "return " .. lua(t, "_lhs")
end
end,
["Push"] = function(t)
local var = assert(peek("push"), "no context given for push")
r = ""
for i = 1, # t - 1, 1 do
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[i]) .. newline())
end
if t[# t] then
if t[# t]["tag"] == "Call" or t[# t]["tag"] == "Invoke" then
r = r .. (APPEND(var, lua(t[# t])))
else
r = r .. (var .. "[#" .. var .. "+1] = " .. lua(t[# t]))
end
end
return r
end,
["Break"] = function()
return "break"
end,
["Continue"] = function()
return "break"
end,
["Nil"] = function()
return "nil"
end,
["Dots"] = function()
return "..."
end,
["Boolean"] = function(t)
return tostring(t[1])
end,
["Number"] = function(t)
return tostring(t[1])
end,
["String"] = function(t)
return ("%q"):format(t[1])
end,
["_functionWithoutKeyword"] = function(t)
local r = "("
local decl = {}
if t[1][1] then
if t[1][1]["tag"] == "ParPair" then
local id = lua(t[1][1][1])
indentLevel = indentLevel + (1)
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][1][2]) .. " end")
indentLevel = indentLevel - (1)
r = r .. (id)
else
r = r .. (lua(t[1][1]))
end
for i = 2, # t[1], 1 do
if t[1][i]["tag"] == "ParPair" then
local id = lua(t[1][i][1])
indentLevel = indentLevel + (1)
table["insert"](decl, "if " .. id .. " == nil then " .. id .. " = " .. lua(t[1][i][2]) .. " end")
indentLevel = indentLevel - (1)
r = r .. (", " .. id)
else
r = r .. (", " .. lua(t[1][i]))
end
end
end
r = r .. (")" .. indent())
for _, d in ipairs(decl) do
r = r .. (d .. newline())
end
if t[2][# t[2]] and t[2][# t[2]]["tag"] == "Push" then
t[2][# t[2]]["tag"] = "Return"
end
local hasPush = any(t[2], { "Push" }, func)
if hasPush then
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline())
else
push("push", false)
end
r = r .. (lua(t[2]))
if hasPush and (t[2][# t[2]] and t[2][# t[2]]["tag"] ~= "Return") then
r = r .. (newline() .. "return " .. UNPACK(var("push")))
end
pop("push")
return r .. unindent() .. "end"
end,
["Function"] = function(t)
return "function" .. lua(t, "_functionWithoutKeyword")
end,
["Pair"] = function(t)
return "[" .. lua(t[1]) .. "] = " .. lua(t[2])
end,
["Table"] = function(t)
if # t == 0 then
return "{}"
elseif # t == 1 then
return "{ " .. lua(t, "_lhs") .. " }"
else
return "{" .. indent() .. lua(t, "_lhs", nil, true) .. unindent() .. "}"
end
end,
["TableCompr"] = function(t)
return push("push", "self") .. "(function()" .. indent() .. "local self = {}" .. newline() .. lua(t[1]) .. newline() .. "return self" .. unindent() .. "end)()" .. pop("push")
end,
["Op"] = function(t)
local r
if # t == 2 then
if type(tags["_opid"][t[1]]) == "string" then
r = tags["_opid"][t[1]] .. " " .. lua(t[2])
else
r = tags["_opid"][t[1]](t[2])
end
else
if type(tags["_opid"][t[1]]) == "string" then
r = lua(t[2]) .. " " .. tags["_opid"][t[1]] .. " " .. lua(t[3])
else
r = tags["_opid"][t[1]](t[2], t[3])
end
end
return r
end,
["Paren"] = function(t)
return "(" .. lua(t[1]) .. ")"
end,
["_statexpr"] = function(t, stat)
local hasPush = any(t, { "Push" }, func)
local r = "(function()" .. indent()
if hasPush then
r = r .. (push("push", var("push")) .. "local " .. var("push") .. " = {}" .. newline())
else
push("push", false)
end
r = r .. (lua(t, stat))
if hasPush then
r = r .. (newline() .. "return " .. UNPACK(var("push")))
end
pop("push")
r = r .. (unindent() .. "end)()")
return r
end,
["DoExpr"] = function(t)
if t[# t]["tag"] == "Push" then
t[# t]["tag"] = "Return"
end
return lua(t, "_statexpr", "Do")
end,
["WhileExpr"] = function(t)
return lua(t, "_statexpr", "While")
end,
["RepeatExpr"] = function(t)
return lua(t, "_statexpr", "Repeat")
end,
["IfExpr"] = function(t)
for i = 2, # t do
local block = t[i]
if block[# block] and block[# block]["tag"] == "Push" then
block[# block]["tag"] = "Return"
end
end
return lua(t, "_statexpr", "If")
end,
["FornumExpr"] = function(t)
return lua(t, "_statexpr", "Fornum")
end,
["ForinExpr"] = function(t)
return lua(t, "_statexpr", "Forin")
end,
["Call"] = function(t)
return lua(t[1]) .. "(" .. lua(t, "_lhs", 2) .. ")"
end,
["Invoke"] = function(t)
return lua(t[1]) .. ":" .. lua(t[2], "Id") .. "(" .. lua(t, "_lhs", 3) .. ")"
end,
["_lhs"] = function(t, start, newlines)
if start == nil then start = 1 end
local r
if t[start] then
r = lua(t[start])
for i = start + 1, # t, 1 do
r = r .. ("," .. (newlines and newline() or " ") .. lua(t[i]))
end
else
r = ""
end
return r
end,
["Id"] = function(t)
return t[1]
end,
["Index"] = function(t)
return lua(t[1]) .. "[" .. lua(t[2]) .. "]"
end,
["_opid"] = {
["add"] = "+",
["sub"] = "-",
["mul"] = "*",
["div"] = "/",
["idiv"] = "//",
["mod"] = "%",
["pow"] = "^",
["concat"] = "..",
["band"] = "&",
["bor"] = "|",
["bxor"] = "~",
["shl"] = "<<",
["shr"] = ">>",
["eq"] = "==",
["ne"] = "~=",
["lt"] = "<",
["gt"] = ">",
["le"] = "<=",
["ge"] = ">=",
["and"] = "and",
["or"] = "or",
["unm"] = "-",
["len"] = "#",
["bnot"] = "~",
["not"] = "not"
}
}, { ["__index"] = function(self, key)
error("don't know how to compile a " .. tostring(key) .. " to Lua 5.3")
end })
UNPACK = function(list, i, j)
return "unpack(" .. list .. (i and (", " .. i .. (j and (", " .. j) or "")) or "") .. ")"
end
APPEND = function(t, toAppend)
return "do" .. indent() .. "local a, p = { " .. toAppend .. " }, #" .. t .. "+1" .. newline() .. "for i=1, #a do" .. indent() .. t .. "[p] = a[i]" .. newline() .. "p = p + 1" .. unindent() .. "end" .. unindent() .. "end"
end
tags["_opid"]["idiv"] = function(left, right)
return "math.floor(" .. lua(left) .. " / " .. lua(right) .. ")"
end
tags["_opid"]["band"] = function(left, right)
addRequire("bit", "band", "band")
return getRequire("band") .. "(" .. lua(left) .. ", " .. lua(right) .. ")"
end
tags["_opid"]["bor"] = function(left, right)
addRequire("bit", "bor", "bor")
return getRequire("bor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")"
end
tags["_opid"]["bxor"] = function(left, right)
addRequire("bit", "bxor", "bxor")
return getRequire("bxor") .. "(" .. lua(left) .. ", " .. lua(right) .. ")"
end
tags["_opid"]["shl"] = function(left, right)
addRequire("bit", "lshift", "lshift")
return getRequire("lshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")"
end
tags["_opid"]["shr"] = function(left, right)
addRequire("bit", "rshift", "rshift")
return getRequire("rshift") .. "(" .. lua(left) .. ", " .. lua(right) .. ")"
end
tags["_opid"]["bnot"] = function(right)
addRequire("bit", "bnot", "bnot")
return getRequire("bnot") .. "(" .. lua(right) .. ")"
end
local code = lua(ast) .. newline()
return requireStr .. code
end
end
local lua53 = _() or lua53
return lua53
end
local luajit = _() or luajit
package["loaded"]["compiler.luajit"] = luajit or true
local function _()
local scope = {}
scope["lineno"] = function(s, i)
if i == 1 then
return 1, 1
end
local l, lastline = 0, ""
s = s:sub(1, i) .. "\
"
for line in s:gmatch("[^\
]*[\
]") do
l = l + 1
lastline = line
end
local c = lastline:len() - 1
return l, c ~= 0 and c or 1
end
scope["new_scope"] = function(env)
if not env["scope"] then
env["scope"] = 0
else
env["scope"] = env["scope"] + 1
end
local scope = env["scope"]
env["maxscope"] = scope
env[scope] = {}
env[scope]["label"] = {}
env[scope]["local"] = {}
env[scope]["goto"] = {}
end
scope["begin_scope"] = function(env)
env["scope"] = env["scope"] + 1
end
scope["end_scope"] = function(env)
env["scope"] = env["scope"] - 1
end
scope["new_function"] = function(env)
if not env["fscope"] then
env["fscope"] = 0
else
env["fscope"] = env["fscope"] + 1
end
local fscope = env["fscope"]
env["function"][fscope] = {}
end
scope["begin_function"] = function(env)
env["fscope"] = env["fscope"] + 1
end
scope["end_function"] = function(env)
env["fscope"] = env["fscope"] - 1
end
scope["begin_loop"] = function(env)
if not env["loop"] then
env["loop"] = 1
else
env["loop"] = env["loop"] + 1
end
end
scope["end_loop"] = function(env)
env["loop"] = env["loop"] - 1
end
scope["insideloop"] = function(env)
return env["loop"] and env["loop"] > 0
end
return scope
end
local scope = _() or scope
package["loaded"]["lib.lua-parser.scope"] = scope or true
local function _()
local scope = require("lib.lua-parser.scope")
local lineno = scope["lineno"]
local new_scope, end_scope = scope["new_scope"], scope["end_scope"]
local new_function, end_function = scope["new_function"], scope["end_function"]
local begin_loop, end_loop = scope["begin_loop"], scope["end_loop"]
local insideloop = scope["insideloop"]
local function syntaxerror(errorinfo, pos, msg)
local l, c = lineno(errorinfo["subject"], pos)
local error_msg = "%s:%d:%d: syntax error, %s"
return string["format"](error_msg, errorinfo["filename"], l, c, msg)
end
local function exist_label(env, scope, stm)
local l = stm[1]
for s = scope, 0, - 1 do
if env[s]["label"][l] then
return true
end
end
return false
end
local function set_label(env, label, pos)
local scope = env["scope"]
local l = env[scope]["label"][label]
if not l then
env[scope]["label"][label] = {
["name"] = label,
["pos"] = pos
}
return true
else
local msg = "label '%s' already defined at line %d"
local line = lineno(env["errorinfo"]["subject"], l["pos"])
msg = string["format"](msg, label, line)
return nil, syntaxerror(env["errorinfo"], pos, msg)
end
end
local function set_pending_goto(env, stm)
local scope = env["scope"]
table["insert"](env[scope]["goto"], stm)
return true
end
local function verify_pending_gotos(env)
for s = env["maxscope"], 0, - 1 do
for k, v in ipairs(env[s]["goto"]) do
if not exist_label(env, s, v) then
local msg = "no visible label '%s' for <goto>"
msg = string["format"](msg, v[1])
return nil, syntaxerror(env["errorinfo"], v["pos"], msg)
end
end
end
return true
end
local function set_vararg(env, is_vararg)
env["function"][env["fscope"]]["is_vararg"] = is_vararg
end
local traverse_stm, traverse_exp, traverse_var
local traverse_block, traverse_explist, traverse_varlist, traverse_parlist
traverse_parlist = function(env, parlist)
local len = # parlist
local is_vararg = false
if len > 0 and parlist[len]["tag"] == "Dots" then
is_vararg = true
end
set_vararg(env, is_vararg)
return true
end
local function traverse_function(env, exp)
new_function(env)
new_scope(env)
local status, msg = traverse_parlist(env, exp[1])
if not status then
return status, msg
end
status, msg = traverse_block(env, exp[2])
if not status then
return status, msg
end
end_scope(env)
end_function(env)
return true
end
local function traverse_tablecompr(env, exp)
new_function(env)
new_scope(env)
local status, msg = traverse_block(env, exp[1])
if not status then
return status, msg
end
end_scope(env)
end_function(env)
return true
end
local function traverse_statexpr(env, exp)
new_function(env)
new_scope(env)
exp["tag"] = exp["tag"]:gsub("Expr$", "")
local status, msg = traverse_stm(env, exp)
exp["tag"] = exp["tag"] .. "Expr"
if not status then
return status, msg
end
end_scope(env)
end_function(env)
return true
end
local function traverse_op(env, exp)
local status, msg = traverse_exp(env, exp[2])
if not status then
return status, msg
end
if exp[3] then
status, msg = traverse_exp(env, exp[3])
if not status then
return status, msg
end
end
return true
end
local function traverse_paren(env, exp)
local status, msg = traverse_exp(env, exp[1])
if not status then
return status, msg
end
return true
end
local function traverse_table(env, fieldlist)
for k, v in ipairs(fieldlist) do
local tag = v["tag"]
if tag == "Pair" then
local status, msg = traverse_exp(env, v[1])
if not status then
return status, msg
end
status, msg = traverse_exp(env, v[2])
if not status then
return status, msg
end
else
local status, msg = traverse_exp(env, v)
if not status then
return status, msg
end
end
end
return true
end
local function traverse_vararg(env, exp)
if not env["function"][env["fscope"]]["is_vararg"] then
local msg = "cannot use '...' outside a vararg function"
return nil, syntaxerror(env["errorinfo"], exp["pos"], msg)
end
return true
end
local function traverse_call(env, call)
local status, msg = traverse_exp(env, call[1])
if not status then
return status, msg
end
for i = 2, # call do
status, msg = traverse_exp(env, call[i])
if not status then
return status, msg
end
end
return true
end
local function traverse_invoke(env, invoke)
local status, msg = traverse_exp(env, invoke[1])
if not status then
return status, msg
end
for i = 3, # invoke do
status, msg = traverse_exp(env, invoke[i])
if not status then
return status, msg
end
end
return true
end
local function traverse_assignment(env, stm)
local status, msg = traverse_varlist(env, stm[1])
if not status then
return status, msg
end
status, msg = traverse_explist(env, stm[# stm])
if not status then
return status, msg
end
return true
end
local function traverse_break(env, stm)
if not insideloop(env) then
local msg = "<break> not inside a loop"
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg)
end
return true
end
local function traverse_continue(env, stm)
if not insideloop(env) then
local msg = "<continue> not inside a loop"
return nil, syntaxerror(env["errorinfo"], stm["pos"], msg)
end
return true
end
local function traverse_push(env, stm)
local status, msg = traverse_explist(env, stm)
if not status then
return status, msg
end
return true
end
local function traverse_forin(env, stm)
begin_loop(env)
new_scope(env)
local status, msg = traverse_explist(env, stm[2])
if not status then
return status, msg
end
status, msg = traverse_block(env, stm[3])
if not status then
return status, msg
end
end_scope(env)
end_loop(env)
return true
end
local function traverse_fornum(env, stm)
local status, msg
begin_loop(env)
new_scope(env)
status, msg = traverse_exp(env, stm[2])
if not status then
return status, msg
end
status, msg = traverse_exp(env, stm[3])
if not status then
return status, msg
end
if stm[5] then
status, msg = traverse_exp(env, stm[4])
if not status then
return status, msg
end
status, msg = traverse_block(env, stm[5])
if not status then
return status, msg
end
else
status, msg = traverse_block(env, stm[4])
if not status then
return status, msg
end
end
end_scope(env)
end_loop(env)
return true
end
local function traverse_goto(env, stm)
local status, msg = set_pending_goto(env, stm)
if not status then
return status, msg
end
return true
end
local function traverse_if(env, stm)
local len = # stm
if len % 2 == 0 then
for i = 1, len, 2 do
local status, msg = traverse_exp(env, stm[i])
if not status then
return status, msg
end
status, msg = traverse_block(env, stm[i + 1])
if not status then
return status, msg
end
end
else
for i = 1, len - 1, 2 do
local status, msg = traverse_exp(env, stm[i])
if not status then
return status, msg
end
status, msg = traverse_block(env, stm[i + 1])
if not status then
return status, msg
end
end
local status, msg = traverse_block(env, stm[len])
if not status then
return status, msg
end
end
return true
end
local function traverse_label(env, stm)
local status, msg = set_label(env, stm[1], stm["pos"])
if not status then
return status, msg
end
return true
end
local function traverse_let(env, stm)
local status, msg = traverse_explist(env, stm[2])
if not status then
return status, msg
end
return true
end
local function traverse_letrec(env, stm)
local status, msg = traverse_exp(env, stm[2][1])
if not status then
return status, msg
end
return true
end
local function traverse_repeat(env, stm)
begin_loop(env)
local status, msg = traverse_block(env, stm[1])
if not status then
return status, msg
end
status, msg = traverse_exp(env, stm[2])
if not status then
return status, msg
end
end_loop(env)
return true
end
local function traverse_return(env, stm)
local status, msg = traverse_explist(env, stm)
if not status then
return status, msg
end
return true
end
local function traverse_while(env, stm)
begin_loop(env)
local status, msg = traverse_exp(env, stm[1])
if not status then
return status, msg
end
status, msg = traverse_block(env, stm[2])
if not status then
return status, msg
end
end_loop(env)
return true
end
traverse_var = function(env, var)
local tag = var["tag"]
if tag == "Id" then
return true
elseif tag == "Index" then
local status, msg = traverse_exp(env, var[1])
if not status then
return status, msg
end
status, msg = traverse_exp(env, var[2])
if not status then
return status, msg
end
return true
else
error("expecting a variable, but got a " .. tag)
end
end
traverse_varlist = function(env, varlist)
for k, v in ipairs(varlist) do
local status, msg = traverse_var(env, v)
if not status then
return status, msg
end
end
return true
end
traverse_exp = function(env, exp)
local tag = exp["tag"]
if tag == "Nil" or tag == "Boolean" or tag == "Number" or tag == "String" then
return true
elseif tag == "Dots" then
return traverse_vararg(env, exp)
elseif tag == "Function" then
return traverse_function(env, exp)
elseif tag == "Table" then
return traverse_table(env, exp)
elseif tag == "Op" then
return traverse_op(env, exp)
elseif tag == "Paren" then
return traverse_paren(env, exp)
elseif tag == "Call" then
return traverse_call(env, exp)
elseif tag == "Invoke" then
return traverse_invoke(env, exp)
elseif tag == "Id" or tag == "Index" then
return traverse_var(env, exp)
elseif tag == "TableCompr" then
return traverse_tablecompr(env, exp)
elseif tag:match("Expr$") then
return traverse_statexpr(env, exp)
else
error("expecting an expression, but got a " .. tag)
end
end
traverse_explist = function(env, explist)
for k, v in ipairs(explist) do
local status, msg = traverse_exp(env, v)
if not status then
return status, msg
end
end
return true
end
traverse_stm = function(env, stm)
local tag = stm["tag"]
if tag == "Do" then
return traverse_block(env, stm)
elseif tag == "Set" then
return traverse_assignment(env, stm)
elseif tag == "While" then
return traverse_while(env, stm)
elseif tag == "Repeat" then
return traverse_repeat(env, stm)
elseif tag == "If" then
return traverse_if(env, stm)
elseif tag == "Fornum" then
return traverse_fornum(env, stm)
elseif tag == "Forin" then
return traverse_forin(env, stm)
elseif tag == "Local" or tag == "Let" then
return traverse_let(env, stm)
elseif tag == "Localrec" then
return traverse_letrec(env, stm)
elseif tag == "Goto" then
return traverse_goto(env, stm)
elseif tag == "Label" then
return traverse_label(env, stm)
elseif tag == "Return" then
return traverse_return(env, stm)
elseif tag == "Break" then
return traverse_break(env, stm)
elseif tag == "Call" then
return traverse_call(env, stm)
elseif tag == "Invoke" then
return traverse_invoke(env, stm)
elseif tag == "Continue" then
return traverse_continue(env, stm)
elseif tag == "Push" then
return traverse_push(env, stm)
else
error("expecting a statement, but got a " .. tag)
end
end
traverse_block = function(env, block)
local l = {}
new_scope(env)
for k, v in ipairs(block) do
local status, msg = traverse_stm(env, v)
if not status then
return status, msg
end
end
end_scope(env)
return true
end
local function traverse(ast, errorinfo)
assert(type(ast) == "table")
assert(type(errorinfo) == "table")
local env = {
["errorinfo"] = errorinfo,
["function"] = {}
}
new_function(env)
set_vararg(env, true)
local status, msg = traverse_block(env, ast)
if not status then
return status, msg
end
end_function(env)
status, msg = verify_pending_gotos(env)
if not status then
return status, msg
end
return ast
end
return {
["validate"] = traverse,
["syntaxerror"] = syntaxerror
}
end
local validator = _() or validator
package["loaded"]["lib.lua-parser.validator"] = validator or true
local function _()
local pp = {}
local block2str, stm2str, exp2str, var2str
local explist2str, varlist2str, parlist2str, fieldlist2str
local function iscntrl(x)
if (x >= 0 and x <= 31) or (x == 127) then
return true
end
return false
end
local function isprint(x)
return not iscntrl(x)
end
local function fixed_string(str)
local new_str = ""
for i = 1, string["len"](str) do
char = string["byte"](str, i)
if char == 34 then
new_str = new_str .. string["format"]("\\\"")
elseif char == 92 then
new_str = new_str .. string["format"]("\\\\")
elseif char == 7 then
new_str = new_str .. string["format"]("\\a")
elseif char == 8 then
new_str = new_str .. string["format"]("\\b")
elseif char == 12 then
new_str = new_str .. string["format"]("\\f")
elseif char == 10 then
new_str = new_str .. string["format"]("\\n")
elseif char == 13 then
new_str = new_str .. string["format"]("\\r")
elseif char == 9 then
new_str = new_str .. string["format"]("\\t")
elseif char == 11 then
new_str = new_str .. string["format"]("\\v")
else
if isprint(char) then
new_str = new_str .. string["format"]("%c", char)
else
new_str = new_str .. string["format"]("\\%03d", char)
end
end
end
return new_str
end
local function name2str(name)
return string["format"]("\"%s\"", name)
end
local function boolean2str(b)
return string["format"]("\"%s\"", tostring(b))
end
local function number2str(n)
return string["format"]("\"%s\"", tostring(n))
end
local function string2str(s)
return string["format"]("\"%s\"", fixed_string(s))
end
var2str = function(var)
local tag = var["tag"]
local str = "`" .. tag
if tag == "Id" then
str = str .. " " .. name2str(var[1])
elseif tag == "Index" then
str = str .. "{ "
str = str .. exp2str(var[1]) .. ", "
str = str .. exp2str(var[2])
str = str .. " }"
else
error("expecting a variable, but got a " .. tag)
end
return str
end
varlist2str = function(varlist)
local l = {}
for k, v in ipairs(varlist) do
l[k] = var2str(v)
end
return "{ " .. table["concat"](l, ", ") .. " }"
end
parlist2str = function(parlist)
local l = {}
local len = # parlist
local is_vararg = false
if len > 0 and parlist[len]["tag"] == "Dots" then
is_vararg = true
len = len - 1
end
local i = 1
while i <= len do
l[i] = var2str(parlist[i])
i = i + 1
end
if is_vararg then
l[i] = "`" .. parlist[i]["tag"]
end
return "{ " .. table["concat"](l, ", ") .. " }"
end
fieldlist2str = function(fieldlist)
local l = {}
for k, v in ipairs(fieldlist) do
local tag = v["tag"]
if tag == "Pair" then
l[k] = "`" .. tag .. "{ "
l[k] = l[k] .. exp2str(v[1]) .. ", " .. exp2str(v[2])
l[k] = l[k] .. " }"
else
l[k] = exp2str(v)
end
end
if # l > 0 then
return "{ " .. table["concat"](l, ", ") .. " }"
else
return ""
end
end
exp2str = function(exp)
local tag = exp["tag"]
local str = "`" .. tag
if tag == "Nil" or tag == "Dots" then

elseif tag == "Boolean" then
str = str .. " " .. boolean2str(exp[1])
elseif tag == "Number" then
str = str .. " " .. number2str(exp[1])
elseif tag == "String" then
str = str .. " " .. string2str(exp[1])
elseif tag == "Function" then
str = str .. "{ "
str = str .. parlist2str(exp[1]) .. ", "
str = str .. block2str(exp[2])
str = str .. " }"
elseif tag == "Table" then
str = str .. fieldlist2str(exp)
elseif tag == "Op" then
str = str .. "{ "
str = str .. name2str(exp[1]) .. ", "
str = str .. exp2str(exp[2])
if exp[3] then
str = str .. ", " .. exp2str(exp[3])
end
str = str .. " }"
elseif tag == "Paren" then
str = str .. "{ " .. exp2str(exp[1]) .. " }"
elseif tag == "Call" then
str = str .. "{ "
str = str .. exp2str(exp[1])
if exp[2] then
for i = 2, # exp do
str = str .. ", " .. exp2str(exp[i])
end
end
str = str .. " }"
elseif tag == "Invoke" then
str = str .. "{ "
str = str .. exp2str(exp[1]) .. ", "
str = str .. exp2str(exp[2])
if exp[3] then
for i = 3, # exp do
str = str .. ", " .. exp2str(exp[i])
end
end
str = str .. " }"
elseif tag == "Id" or tag == "Index" then
str = var2str(exp)
else
error("expecting an expression, but got a " .. tag)
end
return str
end
explist2str = function(explist)
local l = {}
for k, v in ipairs(explist) do
l[k] = exp2str(v)
end
if # l > 0 then
return "{ " .. table["concat"](l, ", ") .. " }"
else
return ""
end
end
stm2str = function(stm)
local tag = stm["tag"]
local str = "`" .. tag
if tag == "Do" then
local l = {}
for k, v in ipairs(stm) do
l[k] = stm2str(v)
end
str = str .. "{ " .. table["concat"](l, ", ") .. " }"
elseif tag == "Set" then
str = str .. "{ "
str = str .. varlist2str(stm[1]) .. ", "
str = str .. explist2str(stm[2])
str = str .. " }"
elseif tag == "While" then
str = str .. "{ "
str = str .. exp2str(stm[1]) .. ", "
str = str .. block2str(stm[2])
str = str .. " }"
elseif tag == "Repeat" then
str = str .. "{ "
str = str .. block2str(stm[1]) .. ", "
str = str .. exp2str(stm[2])
str = str .. " }"
elseif tag == "If" then
str = str .. "{ "
local len = # stm
if len % 2 == 0 then
local l = {}
for i = 1, len - 2, 2 do
str = str .. exp2str(stm[i]) .. ", " .. block2str(stm[i + 1]) .. ", "
end
str = str .. exp2str(stm[len - 1]) .. ", " .. block2str(stm[len])
else
local l = {}
for i = 1, len - 3, 2 do
str = str .. exp2str(stm[i]) .. ", " .. block2str(stm[i + 1]) .. ", "
end
str = str .. exp2str(stm[len - 2]) .. ", " .. block2str(stm[len - 1]) .. ", "
str = str .. block2str(stm[len])
end
str = str .. " }"
elseif tag == "Fornum" then
str = str .. "{ "
str = str .. var2str(stm[1]) .. ", "
str = str .. exp2str(stm[2]) .. ", "
str = str .. exp2str(stm[3]) .. ", "
if stm[5] then
str = str .. exp2str(stm[4]) .. ", "
str = str .. block2str(stm[5])
else
str = str .. block2str(stm[4])
end
str = str .. " }"
elseif tag == "Forin" then
str = str .. "{ "
str = str .. varlist2str(stm[1]) .. ", "
str = str .. explist2str(stm[2]) .. ", "
str = str .. block2str(stm[3])
str = str .. " }"
elseif tag == "Local" then
str = str .. "{ "
str = str .. varlist2str(stm[1])
if # stm[2] > 0 then
str = str .. ", " .. explist2str(stm[2])
else
str = str .. ", " .. "{  }"
end
str = str .. " }"
elseif tag == "Localrec" then
str = str .. "{ "
str = str .. "{ " .. var2str(stm[1][1]) .. " }, "
str = str .. "{ " .. exp2str(stm[2][1]) .. " }"
str = str .. " }"
elseif tag == "Goto" or tag == "Label" then
str = str .. "{ " .. name2str(stm[1]) .. " }"
elseif tag == "Return" then
str = str .. explist2str(stm)
elseif tag == "Break" then

elseif tag == "Call" then
str = str .. "{ "
str = str .. exp2str(stm[1])
if stm[2] then
for i = 2, # stm do
str = str .. ", " .. exp2str(stm[i])
end
end
str = str .. " }"
elseif tag == "Invoke" then
str = str .. "{ "
str = str .. exp2str(stm[1]) .. ", "
str = str .. exp2str(stm[2])
if stm[3] then
for i = 3, # stm do
str = str .. ", " .. exp2str(stm[i])
end
end
str = str .. " }"
else
error("expecting a statement, but got a " .. tag)
end
return str
end
block2str = function(block)
local l = {}
for k, v in ipairs(block) do
l[k] = stm2str(v)
end
return "{ " .. table["concat"](l, ", ") .. " }"
end
pp["tostring"] = function(t)
assert(type(t) == "table")
return block2str(t)
end
pp["print"] = function(t)
assert(type(t) == "table")
print(pp["tostring"](t))
end
pp["dump"] = function(t, i)
if i == nil then
i = 0
end
io["write"](string["format"]("{\
"))
io["write"](string["format"]("%s[tag] = %s\
", string["rep"](" ", i + 2), t["tag"] or "nil"))
io["write"](string["format"]("%s[pos] = %s\
", string["rep"](" ", i + 2), t["pos"] or "nil"))
for k, v in ipairs(t) do
io["write"](string["format"]("%s[%s] = ", string["rep"](" ", i + 2), tostring(k)))
if type(v) == "table" then
pp["dump"](v, i + 2)
else
io["write"](string["format"]("%s\
", tostring(v)))
end
end
io["write"](string["format"]("%s}\
", string["rep"](" ", i)))
end
return pp
end
local pp = _() or pp
package["loaded"]["lib.lua-parser.pp"] = pp or true
local function _()
local lpeg = require("lpeglabel")
lpeg["locale"](lpeg)
local P, S, V = lpeg["P"], lpeg["S"], lpeg["V"]
local C, Carg, Cb, Cc = lpeg["C"], lpeg["Carg"], lpeg["Cb"], lpeg["Cc"]
local Cf, Cg, Cmt, Cp, Cs, Ct = lpeg["Cf"], lpeg["Cg"], lpeg["Cmt"], lpeg["Cp"], lpeg["Cs"], lpeg["Ct"]
local Rec, T = lpeg["Rec"], lpeg["T"]
local alpha, digit, alnum = lpeg["alpha"], lpeg["digit"], lpeg["alnum"]
local xdigit = lpeg["xdigit"]
local space = lpeg["space"]
local labels = {
{
"ErrExtra",
"unexpected character(s), expected EOF"
},
{
"ErrInvalidStat",
"unexpected token, invalid start of statement"
},
{
"ErrEndIf",
"expected 'end' to close the if statement"
},
{
"ErrExprIf",
"expected a condition after 'if'"
},
{
"ErrThenIf",
"expected 'then' after the condition"
},
{
"ErrExprEIf",
"expected a condition after 'elseif'"
},
{
"ErrThenEIf",
"expected 'then' after the condition"
},
{
"ErrEndDo",
"expected 'end' to close the do block"
},
{
"ErrExprWhile",
"expected a condition after 'while'"
},
{
"ErrDoWhile",
"expected 'do' after the condition"
},
{
"ErrEndWhile",
"expected 'end' to close the while loop"
},
{
"ErrUntilRep",
"expected 'until' at the end of the repeat loop"
},
{
"ErrExprRep",
"expected a conditions after 'until'"
},
{
"ErrForRange",
"expected a numeric or generic range after 'for'"
},
{
"ErrEndFor",
"expected 'end' to close the for loop"
},
{
"ErrExprFor1",
"expected a starting expression for the numeric range"
},
{
"ErrCommaFor",
"expected ',' to split the start and end of the range"
},
{
"ErrExprFor2",
"expected an ending expression for the numeric range"
},
{
"ErrExprFor3",
"expected a step expression for the numeric range after ','"
},
{
"ErrInFor",
"expected '=' or 'in' after the variable(s)"
},
{
"ErrEListFor",
"expected one or more expressions after 'in'"
},
{
"ErrDoFor",
"expected 'do' after the range of the for loop"
},
{
"ErrDefLocal",
"expected a function definition or assignment after local"
},
{
"ErrDefLet",
"expected a function definition or assignment after let"
},
{
"ErrNameLFunc",
"expected a function name after 'function'"
},
{
"ErrEListLAssign",
"expected one or more expressions after '='"
},
{
"ErrEListAssign",
"expected one or more expressions after '='"
},
{
"ErrFuncName",
"expected a function name after 'function'"
},
{
"ErrNameFunc1",
"expected a function name after '.'"
},
{
"ErrNameFunc2",
"expected a method name after ':'"
},
{
"ErrOParenPList",
"expected '(' for the parameter list"
},
{
"ErrCParenPList",
"expected ')' to close the parameter list"
},
{
"ErrEndFunc",
"expected 'end' to close the function body"
},
{
"ErrParList",
"expected a variable name or '...' after ','"
},
{
"ErrLabel",
"expected a label name after '::'"
},
{
"ErrCloseLabel",
"expected '::' after the label"
},
{
"ErrGoto",
"expected a label after 'goto'"
},
{
"ErrRetList",
"expected an expression after ',' in the return statement"
},
{
"ErrVarList",
"expected a variable name after ','"
},
{
"ErrExprList",
"expected an expression after ','"
},
{
"ErrOrExpr",
"expected an expression after 'or'"
},
{
"ErrAndExpr",
"expected an expression after 'and'"
},
{
"ErrRelExpr",
"expected an expression after the relational operator"
},
{
"ErrBOrExpr",
"expected an expression after '|'"
},
{
"ErrBXorExpr",
"expected an expression after '~'"
},
{
"ErrBAndExpr",
"expected an expression after '&'"
},
{
"ErrShiftExpr",
"expected an expression after the bit shift"
},
{
"ErrConcatExpr",
"expected an expression after '..'"
},
{
"ErrAddExpr",
"expected an expression after the additive operator"
},
{
"ErrMulExpr",
"expected an expression after the multiplicative operator"
},
{
"ErrUnaryExpr",
"expected an expression after the unary operator"
},
{
"ErrPowExpr",
"expected an expression after '^'"
},
{
"ErrExprParen",
"expected an expression after '('"
},
{
"ErrCParenExpr",
"expected ')' to close the expression"
},
{
"ErrNameIndex",
"expected a field name after '.'"
},
{
"ErrExprIndex",
"expected an expression after '['"
},
{
"ErrCBracketIndex",
"expected ']' to close the indexing expression"
},
{
"ErrNameMeth",
"expected a method name after ':'"
},
{
"ErrMethArgs",
"expected some arguments for the method call (or '()')"
},
{
"ErrArgList",
"expected an expression after ',' in the argument list"
},
{
"ErrCParenArgs",
"expected ')' to close the argument list"
},
{
"ErrCBraceTable",
"expected '}' to close the table constructor"
},
{
"ErrEqField",
"expected '=' after the table key"
},
{
"ErrExprField",
"expected an expression after '='"
},
{
"ErrExprFKey",
"expected an expression after '[' for the table key"
},
{
"ErrCBracketFKey",
"expected ']' to close the table key"
},
{
"ErrCBracketTableCompr",
"expected ']' to close the table comprehension"
},
{
"ErrDigitHex",
"expected one or more hexadecimal digits after '0x'"
},
{
"ErrDigitDeci",
"expected one or more digits after the decimal point"
},
{
"ErrDigitExpo",
"expected one or more digits for the exponent"
},
{
"ErrQuote",
"unclosed string"
},
{
"ErrHexEsc",
"expected exactly two hexadecimal digits after '\\x'"
},
{
"ErrOBraceUEsc",
"expected '{' after '\\u'"
},
{
"ErrDigitUEsc",
"expected one or more hexadecimal digits for the UTF-8 code point"
},
{
"ErrCBraceUEsc",
"expected '}' after the code point"
},
{
"ErrEscSeq",
"invalid escape sequence"
},
{
"ErrCloseLStr",
"unclosed long string"
}
}
local function throw(label)
label = "Err" .. label
for i, labelinfo in ipairs(labels) do
if labelinfo[1] == label then
return T(i)
end
end
error("Label not found: " .. label)
end
local function expect(patt, label)
return patt + throw(label)
end
local function token(patt)
return patt * V("Skip")
end
local function sym(str)
return token(P(str))
end
local function kw(str)
return token(P(str) * - V("IdRest"))
end
local function tagC(tag, patt)
return Ct(Cg(Cp(), "pos") * Cg(Cc(tag), "tag") * patt)
end
local function unaryOp(op, e)
return {
["tag"] = "Op",
["pos"] = e["pos"],
[1] = op,
[2] = e
}
end
local function binaryOp(e1, op, e2)
if not op then
return e1
else
return {
["tag"] = "Op",
["pos"] = e1["pos"],
[1] = op,
[2] = e1,
[3] = e2
}
end
end
local function sepBy(patt, sep, label)
if label then
return patt * Cg(sep * expect(patt, label)) ^ 0
else
return patt * Cg(sep * patt) ^ 0
end
end
local function chainOp(patt, sep, label)
return Cf(sepBy(patt, sep, label), binaryOp)
end
local function commaSep(patt, label)
return sepBy(patt, sym(","), label)
end
local function tagDo(block)
block["tag"] = "Do"
return block
end
local function fixFuncStat(func)
if func[1]["is_method"] then
table["insert"](func[2][1], 1, {
["tag"] = "Id",
[1] = "self"
})
end
func[1] = { func[1] }
func[2] = { func[2] }
return func
end
local function addDots(params, dots)
if dots then
table["insert"](params, dots)
end
return params
end
local function insertIndex(t, index)
return {
["tag"] = "Index",
["pos"] = t["pos"],
[1] = t,
[2] = index
}
end
local function markMethod(t, method)
if method then
return {
["tag"] = "Index",
["pos"] = t["pos"],
["is_method"] = true,
[1] = t,
[2] = method
}
end
return t
end
local function makeIndexOrCall(t1, t2)
if t2["tag"] == "Call" or t2["tag"] == "Invoke" then
local t = {
["tag"] = t2["tag"],
["pos"] = t1["pos"],
[1] = t1
}
for k, v in ipairs(t2) do
table["insert"](t, v)
end
return t
end
return {
["tag"] = "Index",
["pos"] = t1["pos"],
[1] = t1,
[2] = t2[1]
}
end
local function fixShortFunc(t)
if t[1] == ":" then
table["insert"](t[2], 1, {
["tag"] = "Id",
"self"
})
table["remove"](t, 1)
t["is_method"] = true
end
t["is_short"] = true
return t
end
local function statToExpr(t)
t["tag"] = t["tag"] .. "Expr"
return t
end
local function fixStructure(t)
local i = 1
while i <= # t do
if type(t[i]) == "table" then
fixStructure(t[i])
for j = # t[i], 1, - 1 do
local stat = t[i][j]
if type(stat) == "table" and stat["move_up_block"] and stat["move_up_block"] > 0 then
table["remove"](t[i], j)
table["insert"](t, i + 1, stat)
if t["tag"] == "Block" or t["tag"] == "Do" then
stat["move_up_block"] = stat["move_up_block"] - 1
end
end
end
end
i = i + 1
end
return t
end
local function searchEndRec(block, isRecCall)
for i, stat in ipairs(block) do
if stat["tag"] == "Set" or stat["tag"] == "Push" or stat["tag"] == "Return" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then
local exprlist
if stat["tag"] == "Set" or stat["tag"] == "Local" or stat["tag"] == "Let" or stat["tag"] == "Localrec" then
exprlist = stat[# stat]
elseif stat["tag"] == "Push" or stat["tag"] == "Return" then
exprlist = stat
end
local last = exprlist[# exprlist]
if last["tag"] == "Function" and last["is_short"] and not last["is_method"] and # last[1] == 1 then
local p = i
for j, fstat in ipairs(last[2]) do
p = i + j
table["insert"](block, p, fstat)
if stat["move_up_block"] then
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + stat["move_up_block"]
end
if block["is_singlestatblock"] then
fstat["move_up_block"] = (fstat["move_up_block"] or 0) + 1
end
end
exprlist[# exprlist] = last[1]
exprlist[# exprlist]["tag"] = "Paren"
if not isRecCall then
for j = p + 1, # block, 1 do
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1
end
end
return block, i
elseif last["tag"]:match("Expr$") then
local r = searchEndRec({ last })
if r then
for j = 2, # r, 1 do
table["insert"](block, i + j - 1, r[j])
end
return block, i
end
elseif last["tag"] == "Function" then
local r = searchEndRec(last[2])
if r then
return block, i
end
end
elseif stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Do") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then
local blocks
if stat["tag"]:match("^If") or stat["tag"]:match("^While") or stat["tag"]:match("^Repeat") or stat["tag"]:match("^Fornum") or stat["tag"]:match("^Forin") then
blocks = stat
elseif stat["tag"]:match("^Do") then
blocks = { stat }
end
for _, iblock in ipairs(blocks) do
if iblock["tag"] == "Block" then
local oldLen = # iblock
local newiBlock, newEnd = searchEndRec(iblock, true)
if newiBlock then
local p = i
for j = newEnd + (# iblock - oldLen) + 1, # iblock, 1 do
p = p + 1
table["insert"](block, p, iblock[j])
iblock[j] = nil
end
if not isRecCall then
for j = p + 1, # block, 1 do
block[j]["move_up_block"] = (block[j]["move_up_block"] or 0) + 1
end
end
return block, i
end
end
end
end
end
return nil
end
local function searchEnd(s, p, t)
local r = searchEndRec(fixStructure(t))
if not r then
return false
end
return true, r
end
local function expectBlockOrSingleStatWithStartEnd(start, startLabel, stopLabel, canFollow)
if canFollow then
return (- start * V("SingleStatBlock") * canFollow ^ - 1) + (expect(start, startLabel) * ((V("Block") * (canFollow + kw("end"))) + (Cmt(V("Block"), searchEnd) + throw(stopLabel))))
else
return (- start * V("SingleStatBlock")) + (expect(start, startLabel) * ((V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(stopLabel))))
end
end
local function expectBlockWithEnd(label)
return (V("Block") * kw("end")) + (Cmt(V("Block"), searchEnd) + throw(label))
end
local function maybeBlockWithEnd()
return (V("BlockNoErr") * kw("end")) + Cmt(V("BlockNoErr"), searchEnd)
end
local G = {
V("Lua"),
["Lua"] = (V("Shebang") ^ - 1 * V("Skip") * V("Block") * expect(P(- 1), "Extra")) / fixStructure,
["Shebang"] = P("#!") * (P(1) - P("\
")) ^ 0,
["Block"] = tagC("Block", (V("Stat") + - V("BlockEnd") * throw("InvalidStat")) ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1),
["Stat"] = V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat") + V("LocalStat") + V("FuncStat") + V("BreakStat") + V("LabelStat") + V("GoToStat") + V("FuncCall") + V("Assignment") + V("LetStat") + V("ContinueStat") + V("PushStat") + sym(";"),
["BlockEnd"] = P("return") + "end" + "elseif" + "else" + "until" + "]" + - 1 + V("ImplicitPushStat") + V("Assignment"),
["SingleStatBlock"] = tagC("Block", V("Stat") + V("RetStat") + V("ImplicitPushStat")) / function(t)
t["is_singlestatblock"] = true
return t
end,
["BlockNoErr"] = tagC("Block", V("Stat") ^ 0 * ((V("RetStat") + V("ImplicitPushStat")) * sym(";") ^ - 1) ^ - 1),
["IfStat"] = tagC("If", V("IfPart")),
["IfPart"] = kw("if") * expect(V("Expr"), "ExprIf") * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenIf", "EndIf", V("ElseIfPart") + V("ElsePart")),
["ElseIfPart"] = kw("elseif") * expect(V("Expr"), "ExprEIf") * expectBlockOrSingleStatWithStartEnd(kw("then"), "ThenEIf", "EndIf", V("ElseIfPart") + V("ElsePart")),
["ElsePart"] = kw("else") * expectBlockWithEnd("EndIf"),
["DoStat"] = kw("do") * expectBlockWithEnd("EndDo") / tagDo,
["WhileStat"] = tagC("While", kw("while") * expect(V("Expr"), "ExprWhile") * V("WhileBody")),
["WhileBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoWhile", "EndWhile"),
["RepeatStat"] = tagC("Repeat", kw("repeat") * V("Block") * expect(kw("until"), "UntilRep") * expect(V("Expr"), "ExprRep")),
["ForStat"] = kw("for") * expect(V("ForNum") + V("ForIn"), "ForRange"),
["ForNum"] = tagC("Fornum", V("Id") * sym("=") * V("NumRange") * V("ForBody")),
["NumRange"] = expect(V("Expr"), "ExprFor1") * expect(sym(","), "CommaFor") * expect(V("Expr"), "ExprFor2") * (sym(",") * expect(V("Expr"), "ExprFor3")) ^ - 1,
["ForIn"] = tagC("Forin", V("NameList") * expect(kw("in"), "InFor") * expect(V("ExprList"), "EListFor") * V("ForBody")),
["ForBody"] = expectBlockOrSingleStatWithStartEnd(kw("do"), "DoFor", "EndFor"),
["LocalStat"] = kw("local") * expect(V("LocalFunc") + V("LocalAssign"), "DefLocal"),
["LocalFunc"] = tagC("Localrec", kw("function") * expect(V("Id"), "NameLFunc") * V("FuncBody")) / fixFuncStat,
["LocalAssign"] = tagC("Local", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))),
["LetStat"] = kw("let") * expect(V("LetAssign"), "DefLet"),
["LetAssign"] = tagC("Let", V("NameList") * (sym("=") * expect(V("ExprList"), "EListLAssign") + Ct(Cc()))),
["Assignment"] = tagC("Set", V("VarList") * V("BinOp") ^ - 1 * (P("=") / "=") * V("BinOp") ^ - 1 * V("Skip") * expect(V("ExprList"), "EListAssign")),
["FuncStat"] = tagC("Set", kw("function") * expect(V("FuncName"), "FuncName") * V("FuncBody")) / fixFuncStat,
["FuncName"] = Cf(V("Id") * (sym(".") * expect(V("StrId"), "NameFunc1")) ^ 0, insertIndex) * (sym(":") * expect(V("StrId"), "NameFunc2")) ^ - 1 / markMethod,
["FuncBody"] = tagC("Function", V("FuncParams") * expectBlockWithEnd("EndFunc")),
["FuncParams"] = expect(sym("("), "OParenPList") * V("ParList") * expect(sym(")"), "CParenPList"),
["ParList"] = V("NamedParList") * (sym(",") * expect(tagC("Dots", sym("...")), "ParList")) ^ - 1 / addDots + Ct(tagC("Dots", sym("..."))) + Ct(Cc()),
["ShortFuncDef"] = tagC("Function", V("ShortFuncParams") * maybeBlockWithEnd()) / fixShortFunc,
["ShortFuncParams"] = (sym(":") / ":") ^ - 1 * sym("(") * V("ParList") * sym(")"),
["NamedParList"] = tagC("NamedParList", commaSep(V("NamedPar"))),
["NamedPar"] = tagC("ParPair", V("ParKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Id"),
["ParKey"] = V("Id") * # ("=" * - P("=")),
["LabelStat"] = tagC("Label", sym("::") * expect(V("Name"), "Label") * expect(sym("::"), "CloseLabel")),
["GoToStat"] = tagC("Goto", kw("goto") * expect(V("Name"), "Goto")),
["BreakStat"] = tagC("Break", kw("break")),
["ContinueStat"] = tagC("Continue", kw("continue")),
["RetStat"] = tagC("Return", kw("return") * commaSep(V("Expr"), "RetList") ^ - 1),
["PushStat"] = tagC("Push", kw("push") * commaSep(V("Expr"), "RetList") ^ - 1),
["ImplicitPushStat"] = tagC("Push", commaSep(V("Expr"), "RetList")),
["NameList"] = tagC("NameList", commaSep(V("Id"))),
["VarList"] = tagC("VarList", commaSep(V("VarExpr"))),
["ExprList"] = tagC("ExpList", commaSep(V("Expr"), "ExprList")),
["Expr"] = V("OrExpr"),
["OrExpr"] = chainOp(V("AndExpr"), V("OrOp"), "OrExpr"),
["AndExpr"] = chainOp(V("RelExpr"), V("AndOp"), "AndExpr"),
["RelExpr"] = chainOp(V("BOrExpr"), V("RelOp"), "RelExpr"),
["BOrExpr"] = chainOp(V("BXorExpr"), V("BOrOp"), "BOrExpr"),
["BXorExpr"] = chainOp(V("BAndExpr"), V("BXorOp"), "BXorExpr"),
["BAndExpr"] = chainOp(V("ShiftExpr"), V("BAndOp"), "BAndExpr"),
["ShiftExpr"] = chainOp(V("ConcatExpr"), V("ShiftOp"), "ShiftExpr"),
["ConcatExpr"] = V("AddExpr") * (V("ConcatOp") * expect(V("ConcatExpr"), "ConcatExpr")) ^ - 1 / binaryOp,
["AddExpr"] = chainOp(V("MulExpr"), V("AddOp"), "AddExpr"),
["MulExpr"] = chainOp(V("UnaryExpr"), V("MulOp"), "MulExpr"),
["UnaryExpr"] = V("UnaryOp") * expect(V("UnaryExpr"), "UnaryExpr") / unaryOp + V("PowExpr"),
["PowExpr"] = V("SimpleExpr") * (V("PowOp") * expect(V("UnaryExpr"), "PowExpr")) ^ - 1 / binaryOp,
["SimpleExpr"] = tagC("Number", V("Number")) + tagC("String", V("String")) + tagC("Nil", kw("nil")) + tagC("Boolean", kw("false") * Cc(false)) + tagC("Boolean", kw("true") * Cc(true)) + tagC("Dots", sym("...")) + V("FuncDef") + V("Table") + V("ShortFuncDef") + V("SuffixedExpr") + V("TableCompr") + V("StatExpr"),
["StatExpr"] = (V("IfStat") + V("DoStat") + V("WhileStat") + V("RepeatStat") + V("ForStat")) / statToExpr,
["FuncCall"] = Cmt(V("SuffixedExpr"), function(s, i, exp)
return exp["tag"] == "Call" or exp["tag"] == "Invoke", exp
end),
["VarExpr"] = Cmt(V("SuffixedExpr"), function(s, i, exp)
return exp["tag"] == "Id" or exp["tag"] == "Index", exp
end),
["SuffixedExpr"] = Cf(V("PrimaryExpr") * (V("Index") + V("Call")) ^ 0, makeIndexOrCall),
["PrimaryExpr"] = V("SelfId") * (V("SelfCall") + V("SelfIndex")) + V("Id") + tagC("Paren", sym("(") * expect(V("Expr"), "ExprParen") * expect(sym(")"), "CParenExpr")),
["Index"] = tagC("DotIndex", sym("." * - P(".")) * expect(V("StrId"), "NameIndex")) + tagC("ArrayIndex", sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprIndex") * expect(sym("]"), "CBracketIndex")),
["Call"] = tagC("Invoke", Cg(sym(":" * - P(":")) * expect(V("StrId"), "NameMeth") * expect(V("FuncArgs"), "MethArgs"))) + tagC("Call", V("FuncArgs")),
["SelfIndex"] = tagC("DotIndex", V("StrId")),
["SelfCall"] = tagC("Invoke", Cg(V("StrId") * V("FuncArgs"))),
["FuncDef"] = (kw("function") * V("FuncBody")),
["FuncArgs"] = sym("(") * commaSep(V("Expr"), "ArgList") ^ - 1 * expect(sym(")"), "CParenArgs") + V("Table") + tagC("String", V("String")),
["Table"] = tagC("Table", sym("{") * V("FieldList") ^ - 1 * expect(sym("}"), "CBraceTable")),
["FieldList"] = sepBy(V("Field"), V("FieldSep")) * V("FieldSep") ^ - 1,
["Field"] = tagC("Pair", V("FieldKey") * expect(sym("="), "EqField") * expect(V("Expr"), "ExprField")) + V("Expr"),
["FieldKey"] = sym("[" * - P(S("=["))) * expect(V("Expr"), "ExprFKey") * expect(sym("]"), "CBracketFKey") + V("StrId") * # ("=" * - P("=")),
["FieldSep"] = sym(",") + sym(";"),
["TableCompr"] = tagC("TableCompr", sym("[") * V("Block") * expect(sym("]"), "CBracketTableCompr")),
["SelfId"] = tagC("Id", sym("@") / "self"),
["Id"] = tagC("Id", V("Name")) + V("SelfId"),
["StrId"] = tagC("String", V("Name")),
["Skip"] = (V("Space") + V("Comment")) ^ 0,
["Space"] = space ^ 1,
["Comment"] = P("--") * V("LongStr") / function()
return 
end + P("--") * (P(1) - P("\
")) ^ 0,
["Name"] = token(- V("Reserved") * C(V("Ident"))),
["Reserved"] = V("Keywords") * - V("IdRest"),
["Keywords"] = P("and") + "break" + "do" + "elseif" + "else" + "end" + "false" + "for" + "function" + "goto" + "if" + "in" + "local" + "nil" + "not" + "or" + "repeat" + "return" + "then" + "true" + "until" + "while",
["Ident"] = V("IdStart") * V("IdRest") ^ 0,
["IdStart"] = alpha + P("_"),
["IdRest"] = alnum + P("_"),
["Number"] = token(C(V("Hex") + V("Float") + V("Int"))),
["Hex"] = (P("0x") + "0X") * ((xdigit ^ 0 * V("DeciHex")) + (expect(xdigit ^ 1, "DigitHex") * V("DeciHex") ^ - 1)) * V("ExpoHex") ^ - 1,
["Float"] = V("Decimal") * V("Expo") ^ - 1 + V("Int") * V("Expo"),
["Decimal"] = digit ^ 1 * "." * digit ^ 0 + P(".") * - P(".") * expect(digit ^ 1, "DigitDeci"),
["DeciHex"] = P(".") * xdigit ^ 0,
["Expo"] = S("eE") * S("+-") ^ - 1 * expect(digit ^ 1, "DigitExpo"),
["ExpoHex"] = S("pP") * S("+-") ^ - 1 * expect(xdigit ^ 1, "DigitExpo"),
["Int"] = digit ^ 1,
["String"] = token(V("ShortStr") + V("LongStr")),
["ShortStr"] = P("\"") * Cs((V("EscSeq") + (P(1) - S("\"\
"))) ^ 0) * expect(P("\""), "Quote") + P("'") * Cs((V("EscSeq") + (P(1) - S("'\
"))) ^ 0) * expect(P("'"), "Quote"),
["EscSeq"] = P("\\") / "" * (P("a") / "\7" + P("b") / "\8" + P("f") / "\12" + P("n") / "\
" + P("r") / "\13" + P("t") / "\9" + P("v") / "\11" + P("\
") / "\
" + P("\13") / "\
" + P("\\") / "\\" + P("\"") / "\"" + P("'") / "'" + P("z") * space ^ 0 / "" + digit * digit ^ - 2 / tonumber / string["char"] + P("x") * expect(C(xdigit * xdigit), "HexEsc") * Cc(16) / tonumber / string["char"] + P("u") * expect("{", "OBraceUEsc") * expect(C(xdigit ^ 1), "DigitUEsc") * Cc(16) * expect("}", "CBraceUEsc") / tonumber / (utf8 and utf8["char"] or string["char"]) + throw("EscSeq")),
["LongStr"] = V("Open") * C((P(1) - V("CloseEq")) ^ 0) * expect(V("Close"), "CloseLStr") / function(s, eqs)
return s
end,
["Open"] = "[" * Cg(V("Equals"), "openEq") * "[" * P("\
") ^ - 1,
["Close"] = "]" * C(V("Equals")) * "]",
["Equals"] = P("=") ^ 0,
["CloseEq"] = Cmt(V("Close") * Cb("openEq"), function(s, i, closeEq, openEq)
return # openEq == # closeEq
end),
["OrOp"] = kw("or") / "or",
["AndOp"] = kw("and") / "and",
["RelOp"] = sym("~=") / "ne" + sym("==") / "eq" + sym("<=") / "le" + sym(">=") / "ge" + sym("<") / "lt" + sym(">") / "gt",
["BOrOp"] = sym("|") / "bor",
["BXorOp"] = sym("~" * - P("=")) / "bxor",
["BAndOp"] = sym("&") / "band",
["ShiftOp"] = sym("<<") / "shl" + sym(">>") / "shr",
["ConcatOp"] = sym("..") / "concat",
["AddOp"] = sym("+") / "add" + sym("-") / "sub",
["MulOp"] = sym("*") / "mul" + sym("//") / "idiv" + sym("/") / "div" + sym("%") / "mod",
["UnaryOp"] = kw("not") / "not" + sym("-") / "unm" + sym("#") / "len" + sym("~") / "bnot",
["PowOp"] = sym("^") / "pow",
["BinOp"] = V("OrOp") + V("AndOp") + V("BOrOp") + V("BXorOp") + V("BAndOp") + V("ShiftOp") + V("ConcatOp") + V("AddOp") + V("MulOp") + V("PowOp")
}
local parser = {}
local validator = require("lib.lua-parser.validator")
local validate = validator["validate"]
local syntaxerror = validator["syntaxerror"]
parser["parse"] = function(subject, filename)
local errorinfo = {
["subject"] = subject,
["filename"] = filename
}
lpeg["setmaxstack"](1000)
local ast, label, sfail = lpeg["match"](G, subject, nil, errorinfo)
if not ast then
local errpos = # subject - # sfail + 1
local errmsg = labels[label][2]
return ast, syntaxerror(errorinfo, errpos, errmsg)
end
return validate(ast, errorinfo)
end
return parser
end
local parser = _() or parser
package["loaded"]["lib.lua-parser.parser"] = parser or true
local candran = { ["VERSION"] = "0.6.0" }
local default = {
["target"] = "lua53",
["indentation"] = "",
["newline"] = "\
",
["variablePrefix"] = "__CAN_",
["mapLines"] = true,
["chunkname"] = "nil",
["rewriteErrors"] = true
}
candran["preprocess"] = function(input, options)
if options == nil then options = {} end
options = util["merge"](default, options)
local preprocessor = ""
local i = 0
for line in (input .. "\
"):gmatch("(.-\
)") do
i = i + (1)
if line:match("^%s*#") and not line:match("^#!") then
preprocessor = preprocessor .. (line:gsub("^%s*#", ""))
else
local l = line:sub(1, - 2)
if options["mapLines"] and not l:match("%-%- (.-)%:(%d+)$") then
preprocessor = preprocessor .. (("write(%q)"):format(l .. " -- " .. options["chunkname"] .. ":" .. i) .. "\
")
else
preprocessor = preprocessor .. (("write(%q)"):format(line:sub(1, - 2)) .. "\
")
end
end
end
preprocessor = preprocessor .. ("return output")
local env = util["merge"](_G, options)
env["candran"] = candran
env["output"] = ""
env["import"] = function(modpath, margs)
if margs == nil then margs = {} end
local filepath = assert(util["search"](modpath), "No module named \"" .. modpath .. "\"")
local f = io["open"](filepath)
if not f then
error("Can't open the module file to import")
end
margs = util["merge"](options, {
["chunkname"] = filepath,
["loadLocal"] = true,
["loadPackage"] = true
}, margs)
local modcontent = candran["preprocess"](f:read("*a"), margs)
f:close()
local modname = modpath:match("[^%.]+$")
env["write"]("-- MODULE " .. modpath .. " --\
" .. "local function _()\
" .. modcontent .. "\
" .. "end\
" .. (margs["loadLocal"] and ("local %s = _() or %s\
"):format(modname, modname) or "") .. (margs["loadPackage"] and ("package.loaded[%q] = %s or true\
"):format(modpath, margs["loadLocal"] and modname or "_()") or "") .. "-- END OF MODULE " .. modpath .. " --")
end
env["include"] = function(file)
local f = io["open"](file)
if not f then
error("Can't open the file " .. file .. " to include")
end
env["write"](f:read("*a"))
f:close()
end
env["write"] = function(...)
env["output"] = env["output"] .. (table["concat"]({ ... }, "\9") .. "\
")
end
env["placeholder"] = function(name)
if env[name] then
env["write"](env[name])
end
end
local preprocess, err = util["load"](candran["compile"](preprocessor, args), "candran preprocessor", env)
if not preprocess then
error("Error while creating Candran preprocessor: " .. err)
end
local success, output = pcall(preprocess)
if not success then
error("Error while preprocessing file: " .. output)
end
return output
end
candran["compile"] = function(input, options)
if options == nil then options = {} end
options = util["merge"](default, options)
local ast, errmsg = parser["parse"](input, options["chunkname"])
if not ast then
error("Compiler: error while parsing file: " .. errmsg)
end
return require("compiler." .. options["target"])(input, ast, options)
end
candran["make"] = function(code, options)
return candran["compile"](candran["preprocess"](code, options), options)
end
local errorRewritingActive = false
local codeCache = {}
candran["loadfile"] = function(filepath, env, options)
local f, err = io["open"](filepath)
if not f then
error("can't open the file: " .. err)
end
local content = f:read("*a")
f:close()
return candran["load"](content, filepath, env, options)
end
candran["load"] = function(chunk, chunkname, env, options)
if options == nil then options = {} end
options = util["merge"]({ ["chunkname"] = tostring(chunkname or chunk) }, options)
codeCache[options["chunkname"]] = candran["make"](chunk, options)
local f = util["load"](codeCache[options["chunkname"]], options["chunkname"], env)
if options["rewriteErrors"] == false then
return f
else
return function()
if not errorRewritingActive then
errorRewritingActive = true
local t = { xpcall(f, candran["messageHandler"]) }
errorRewritingActive = false
if t[1] == false then
error(t[2], 0)
end
return unpack(t, 2)
else
return f()
end
end
end
end
candran["dofile"] = function(filename, options)
return candran["loadfile"](filename, nil, options)()
end
candran["messageHandler"] = function(message)
return debug["traceback"](message, 2):gsub("(\
?%s*)([^\
]-)%:(%d+)%:", function(indentation, source, line)
line = tonumber(line)
local originalFile
local strName = source:match("%[string \"(.-)\"%]")
if strName then
if codeCache[strName] then
originalFile = codeCache[strName]
source = strName
end
else
local fi = io["open"](source, "r")
if fi then
originalFile = fi:read("*a")
end
fi:close()
end
if originalFile then
local i = 0
for l in originalFile:gmatch("([^\
]*)") do
i = i + 1
if i == line then
local extSource, lineMap = l:match("%-%- (.-)%:(%d+)$")
if lineMap then
if extSource ~= source then
return indentation .. extSource .. ":" .. lineMap .. "(" .. extSource .. ":" .. line .. "):"
else
return indentation .. extSource .. ":" .. lineMap .. "(" .. line .. "):"
end
end
break
end
end
end
end)
end
candran["searcher"] = function(modpath)
local filepath = util["search"](modpath)
if not filepath then
return "\
\9no candran file in package.path"
end
return candran["loadfile"](filepath)
end
candran["setup"] = function()
if _VERSION == "Lua 5.1" then
table["insert"](package["loaders"], 2, candran["searcher"])
else
table["insert"](package["searchers"], 2, candran["searcher"])
end
end
return candran
