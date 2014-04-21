#!/usr/bin/lua
--[[
Lune language & compiler by Thomas99.

LICENSE :
Copyright (c) 2014 Thomas99

This software is provided 'as-is', without any express or implied warranty. 
In no event will the authors be held liable for any damages arising from the 
use of this software.

Permission is granted to anyone to use this software for any purpose, including 
commercial applications, and to alter it and redistribute it freely, subject 
to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not 
    claim that you wrote the original software. If you use this software in a 
    product, an acknowledgment in the product documentation would be appreciated 
    but is not required.

    2. Altered source versions must be plainly marked as such, and must not be 
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
]]
-- INCLUSION OF FILE "lib/lexer.lua" --
local function _()
--[[
This file is a part of Penlight (set of pure Lua libraries) - https://github.com/stevedonovan/Penlight

LICENSE :
Copyright (C) 2009 Steve Donovan, David Manura.

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in the 
Software without restriction, including without limitation the rights to use, copy, 
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, subject to the 
following conditions:

The above copyright notice and this permission notice shall be included in all copies 
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--- Lexical scanner for creating a sequence of tokens from text.
-- `lexer.scan(s)` returns an iterator over all tokens found in the
-- string `s`. This iterator returns two values, a token type string
-- (such as 'string' for quoted string, 'iden' for identifier) and the value of the
-- token.
--
-- Versions specialized for Lua and C are available; these also handle block comments
-- and classify keywords as 'keyword' tokens. For example:
--
--    > s = 'for i=1,n do'
--    > for t,v in lexer.lua(s)  do print(t,v) end
--    keyword for
--    iden    i
--    =       =
--    number  1
--    ,       ,
--    iden    n
--    keyword do
--
-- See the Guide for further @{06-data.md.Lexical_Scanning|discussion}
-- @module pl.lexer

local yield,wrap = coroutine.yield,coroutine.wrap
local strfind = string.find
local strsub = string.sub
local append = table.insert

local function assert_arg(idx,val,tp)
    if type(val) ~= tp then
        error("argument "..idx.." must be "..tp, 2)
    end
end

local lexer = {}

local NUMBER1 = '^[%+%-]?%d+%.?%d*[eE][%+%-]?%d+'
local NUMBER2 = '^[%+%-]?%d+%.?%d*'
local NUMBER3 = '^0x[%da-fA-F]+'
local NUMBER4 = '^%d+%.?%d*[eE][%+%-]?%d+'
local NUMBER5 = '^%d+%.?%d*'
local IDEN = '^[%a_][%w_]*'
local WSPACE = '^%s+'
local STRING0 = [[^(['\"]).-\\%1]]
local STRING1 = [[^(['\"]).-[^\]%1]]
local STRING3 = "^((['\"])%2)" -- empty string
local PREPRO = '^#.-[^\\]\n'

local plain_matches,lua_matches,cpp_matches,lua_keyword,cpp_keyword

local function tdump(tok)
    return yield(tok,tok)
end

local function ndump(tok,options)
    if options and options.number then
        tok = tonumber(tok)
    end
    return yield("number",tok)
end

-- regular strings, single or double quotes; usually we want them
-- without the quotes
local function sdump(tok,options)
    if options and options.string then
        tok = tok:sub(2,-2)
    end
    return yield("string",tok)
end

-- long Lua strings need extra work to get rid of the quotes
local function sdump_l(tok,options)
    if options and options.string then
        tok = tok:sub(3,-3)
    end
    return yield("string",tok)
end

local function chdump(tok,options)
    if options and options.string then
        tok = tok:sub(2,-2)
    end
    return yield("char",tok)
end

local function cdump(tok)
    return yield('comment',tok)
end

local function wsdump (tok)
    return yield("space",tok)
end

local function pdump (tok)
    return yield('prepro',tok)
end

local function plain_vdump(tok)
    return yield("iden",tok)
end

local function lua_vdump(tok)
    if lua_keyword[tok] then
        return yield("keyword",tok)
    else
        return yield("iden",tok)
    end
end

local function cpp_vdump(tok)
    if cpp_keyword[tok] then
        return yield("keyword",tok)
    else
        return yield("iden",tok)
    end
end

--- create a plain token iterator from a string or file-like object.
-- @param s the string
-- @param matches an optional match table (set of pattern-action pairs)
-- @param filter a table of token types to exclude, by default {space=true}
-- @param options a table of options; by default, {number=true,string=true},
-- which means convert numbers and strip string quotes.
function lexer.scan (s,matches,filter,options)
    --assert_arg(1,s,'string')
    local file = type(s) ~= 'string' and s
    filter = filter or {space=true}
    options = options or {number=true,string=true}
    if filter then
        if filter.space then filter[wsdump] = true end
        if filter.comments then
            filter[cdump] = true
        end
    end
    if not matches then
        if not plain_matches then
            plain_matches = {
                {WSPACE,wsdump},
                {NUMBER3,ndump},
                {IDEN,plain_vdump},
                {NUMBER1,ndump},
                {NUMBER2,ndump},
                {STRING3,sdump},
                {STRING0,sdump},
                {STRING1,sdump},
                {'^.',tdump}
            }
        end
        matches = plain_matches
    end
    local function lex ()
        local i1,i2,idx,res1,res2,tok,pat,fun,capt
        local line = 1
        if file then s = file:read()..'\n' end
        local sz = #s
        local idx = 1
        --print('sz',sz)
        while true do
            for _,m in ipairs(matches) do
                pat = m[1]
                fun = m[2]
                i1,i2 = strfind(s,pat,idx)
                if i1 then
                    tok = strsub(s,i1,i2)
                    idx = i2 + 1
                    if not (filter and filter[fun]) then
                        lexer.finished = idx > sz
                        res1,res2 = fun(tok,options)
                    end
                    if res1 then
                        local tp = type(res1)
                        -- insert a token list
                        if tp=='table' then
                            yield('','')
                            for _,t in ipairs(res1) do
                                yield(t[1],t[2])
                            end
                        elseif tp == 'string' then -- or search up to some special pattern
                            i1,i2 = strfind(s,res1,idx)
                            if i1 then
                                tok = strsub(s,i1,i2)
                                idx = i2 + 1
                                yield('',tok)
                            else
                                yield('','')
                                idx = sz + 1
                            end
                            --if idx > sz then return end
                        else
                            yield(line,idx)
                        end
                    end
                    if idx > sz then
                        if file then
                            --repeat -- next non-empty line
                                line = line + 1
                                s = file:read()
                                if not s then return end
                            --until not s:match '^%s*$'
                            s = s .. '\n'
                            idx ,sz = 1,#s
                            break
                        else
                            return
                        end
                    else break end
                end
            end
        end
    end
    return wrap(lex)
end

local function isstring (s)
    return type(s) == 'string'
end

--- insert tokens into a stream.
-- @param tok a token stream
-- @param a1 a string is the type, a table is a token list and
-- a function is assumed to be a token-like iterator (returns type & value)
-- @param a2 a string is the value
function lexer.insert (tok,a1,a2)
    if not a1 then return end
    local ts
    if isstring(a1) and isstring(a2) then
        ts = {{a1,a2}}
    elseif type(a1) == 'function' then
        ts = {}
        for t,v in a1() do
            append(ts,{t,v})
        end
    else
        ts = a1
    end
    tok(ts)
end

--- get everything in a stream upto a newline.
-- @param tok a token stream
-- @return a string
function lexer.getline (tok)
    local t,v = tok('.-\n')
    return v
end

--- get current line number. <br>
-- Only available if the input source is a file-like object.
-- @param tok a token stream
-- @return the line number and current column
function lexer.lineno (tok)
    return tok(0)
end

--- get the rest of the stream.
-- @param tok a token stream
-- @return a string
function lexer.getrest (tok)
    local t,v = tok('.+')
    return v
end

--- get the Lua keywords as a set-like table.
-- So <code>res["and"]</code> etc would be <code>true</code>.
-- @return a table
function lexer.get_keywords ()
    if not lua_keyword then
        lua_keyword = {
            ["and"] = true, ["break"] = true,  ["do"] = true,
            ["else"] = true, ["elseif"] = true, ["end"] = true,
            ["false"] = true, ["for"] = true, ["function"] = true,
            ["if"] = true, ["in"] = true,  ["local"] = true, ["nil"] = true,
            ["not"] = true, ["or"] = true, ["repeat"] = true,
            ["return"] = true, ["then"] = true, ["true"] = true,
            ["until"] = true,  ["while"] = true
        }
    end
    return lua_keyword
end


--- create a Lua token iterator from a string or file-like object.
-- Will return the token type and value.
-- @param s the string
-- @param filter a table of token types to exclude, by default {space=true,comments=true}
-- @param options a table of options; by default, {number=true,string=true},
-- which means convert numbers and strip string quotes.
function lexer.lua(s,filter,options)
    filter = filter or {space=true,comments=true}
    lexer.get_keywords()
    if not lua_matches then
        lua_matches = {
            {WSPACE,wsdump},
            {NUMBER3,ndump},
            {IDEN,lua_vdump},
            {NUMBER4,ndump},
            {NUMBER5,ndump},
            {STRING3,sdump},
            {STRING0,sdump},
            {STRING1,sdump},
            {'^%-%-%[%[.-%]%]',cdump},
            {'^%-%-.-\n',cdump},
            {'^%[%[.-%]%]',sdump_l},
            {'^==',tdump},
            {'^~=',tdump},
            {'^<=',tdump},
            {'^>=',tdump},
            {'^%.%.%.',tdump},
            {'^%.%.',tdump},
            {'^.',tdump}
        }
    end
    return lexer.scan(s,lua_matches,filter,options)
end

--- create a C/C++ token iterator from a string or file-like object.
-- Will return the token type type and value.
-- @param s the string
-- @param filter a table of token types to exclude, by default {space=true,comments=true}
-- @param options a table of options; by default, {number=true,string=true},
-- which means convert numbers and strip string quotes.
function lexer.cpp(s,filter,options)
    filter = filter or {comments=true}
    if not cpp_keyword then
        cpp_keyword = {
            ["class"] = true, ["break"] = true,  ["do"] = true, ["sizeof"] = true,
            ["else"] = true, ["continue"] = true, ["struct"] = true,
            ["false"] = true, ["for"] = true, ["public"] = true, ["void"] = true,
            ["private"] = true, ["protected"] = true, ["goto"] = true,
            ["if"] = true, ["static"] = true,  ["const"] = true, ["typedef"] = true,
            ["enum"] = true, ["char"] = true, ["int"] = true, ["bool"] = true,
            ["long"] = true, ["float"] = true, ["true"] = true, ["delete"] = true,
            ["double"] = true,  ["while"] = true, ["new"] = true,
            ["namespace"] = true, ["try"] = true, ["catch"] = true,
            ["switch"] = true, ["case"] = true, ["extern"] = true,
            ["return"] = true,["default"] = true,['unsigned']  = true,['signed'] = true,
            ["union"] =  true, ["volatile"] = true, ["register"] = true,["short"] = true,
        }
    end
    if not cpp_matches then
        cpp_matches = {
            {WSPACE,wsdump},
            {PREPRO,pdump},
            {NUMBER3,ndump},
            {IDEN,cpp_vdump},
            {NUMBER4,ndump},
            {NUMBER5,ndump},
            {STRING3,sdump},
            {STRING1,chdump},
            {'^//.-\n',cdump},
            {'^/%*.-%*/',cdump},
            {'^==',tdump},
            {'^!=',tdump},
            {'^<=',tdump},
            {'^>=',tdump},
            {'^->',tdump},
            {'^&&',tdump},
            {'^||',tdump},
            {'^%+%+',tdump},
            {'^%-%-',tdump},
            {'^%+=',tdump},
            {'^%-=',tdump},
            {'^%*=',tdump},
            {'^/=',tdump},
            {'^|=',tdump},
            {'^%^=',tdump},
            {'^::',tdump},
            {'^.',tdump}
        }
    end
    return lexer.scan(s,cpp_matches,filter,options)
end

--- get a list of parameters separated by a delimiter from a stream.
-- @param tok the token stream
-- @param endtoken end of list (default ')'). Can be '\n'
-- @param delim separator (default ',')
-- @return a list of token lists.
function lexer.get_separated_list(tok,endtoken,delim)
    endtoken = endtoken or ')'
    delim = delim or ','
    local parm_values = {}
    local level = 1 -- used to count ( and )
    local tl = {}
    local function tappend (tl,t,val)
        val = val or t
        append(tl,{t,val})
    end
    local is_end
    if endtoken == '\n' then
        is_end = function(t,val)
            return t == 'space' and val:find '\n'
        end
    else
        is_end = function (t)
            return t == endtoken
        end
    end
    local token,value
    while true do
        token,value=tok()
        if not token then return nil,'EOS' end -- end of stream is an error!
        if is_end(token,value) and level == 1 then
            append(parm_values,tl)
            break
        elseif token == '(' then
            level = level + 1
            tappend(tl,'(')
        elseif token == ')' then
            level = level - 1
            if level == 0 then -- finished with parm list
                append(parm_values,tl)
                break
            else
                tappend(tl,')')
            end
        elseif token == delim and level == 1 then
            append(parm_values,tl) -- a new parm
            tl = {}
        else
            tappend(tl,token,value)
        end
    end
    return parm_values,{token,value}
end

--- get the next non-space token from the stream.
-- @param tok the token stream.
function lexer.skipws (tok)
    local t,v = tok()
    while t == 'space' do
        t,v = tok()
    end
    return t,v
end

local skipws = lexer.skipws

--- get the next token, which must be of the expected type.
-- Throws an error if this type does not match!
-- @param tok the token stream
-- @param expected_type the token type
-- @param no_skip_ws whether we should skip whitespace
function lexer.expecting (tok,expected_type,no_skip_ws)
    assert_arg(1,tok,'function')
    assert_arg(2,expected_type,'string')
    local t,v
    if no_skip_ws then
        t,v = tok()
    else
        t,v = skipws(tok)
    end
    if t ~= expected_type then error ("expecting "..expected_type,2) end
    return v
end

return lexer

end
local lexer = _() or lexer
-- END OF INCLUDSION OF FILE "lib/lexer.lua" --
-- INCLUSION OF FILE "lib/table.lua" --
local function _()
--[[
Lua table utilities by Thomas99.

LICENSE :
Copyright (c) 2014 Thomas99

This software is provided 'as-is', without any express or implied warranty. 
In no event will the authors be held liable for any damages arising from the 
use of this software.

Permission is granted to anyone to use this software for any purpose, including 
commercial applications, and to alter it and redistribute it freely, subject 
to the following restrictions:

    1. The origin of this software must not be misrepresented; you must not 
    claim that you wrote the original software. If you use this software in a 
    product, an acknowledgment in the product documentation would be appreciated 
    but is not required.

    2. Altered source versions must be plainly marked as such, and must not be 
    misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
]]

-- Copie récursivement la table t dans la table dest (ou une table vide si non précisé) et la retourne
-- replace (false) : indique si oui ou non, les clefs existant déjà dans dest doivent être écrasées par celles de t
-- metatable (true) : copier ou non également les metatables
-- filter (function) : filtre, si retourne true copie l'objet, sinon ne le copie pas
-- Note : les metatables des objets ne sont jamais re-copiées (mais référence à la place), car sinon lors de la copie
-- 		la classe de ces objets changera pour une nouvelle classe, et c'est pas pratique :p
function table.copy(t, dest, replace, metatable, filter, copied)
	local copied = copied or {}
	local replace = replace or false
	local metatable = (metatable==nil or metatable) and true
	local filter = filter or function(name, source, destination) return true end

	if type(t) ~= "table" then
		return t
	elseif copied[t] then -- si la table a déjà été copiée
		return copied[t]
	end

	local dest = dest or {} -- la copie

	copied[t] = dest -- on marque la table comme copiée

	for k, v in pairs(t) do
		if filter(k, t, dest) then
			if replace then
				dest[k] = table.copy(v, dest[k], replace, metatable, filter, copied)
			else
				if dest[k] == nil or type(v) == "table" then -- si la clef n'existe pas déjà dans dest ou si c'est une table à copier
					dest[k] = table.copy(v, dest[k], replace, metatable, filter, copied)
				end
			end
		end
	end

	-- copie des metatables
	if metatable then
		if t.__classe then
			setmetatable(dest, getmetatable(t))
		else
			setmetatable(dest, table.copy(getmetatable(t), getmetatable(dest), replace, filter))
		end
	end

	return dest
end

-- retourne true si value est dans la table
function table.isIn(table, value)
	for _,v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

-- retourne true si la clé key est dans la table
function table.hasKey(table, key)
	for k,_ in pairs(table) do
		if k == key then
			return true
		end
	end
	return false
end

-- retourne la longueur exacte d'une table (fonctionne sur les tables à clef)
function table.len(t)
	local len=0
	for i in pairs(t) do
		len=len+1
	end
	return len
end

-- Sépare str en éléments séparés par le pattern et retourne une table
function string.split(str, pattern)
	local t = {}
	local pos = 0

	for i,p in string.gmatch(str, "(.-)"..pattern.."()") do
		table.insert(t, i)
		pos = p
	end

	table.insert(t, str:sub(pos))

	return t
end
end
local table = _() or table
-- END OF INCLUDSION OF FILE "lib/table.lua" --

local lune = {}
lune.VERSION = "0.0.1"
lune.syntax = {
	affectation = { ["+"] = "= %s +", ["-"] = "= %s -", ["*"] = "= %s *", ["/"] = "= %s /", 
					["^"] = "= %s ^", ["%"] = "= %s %%", [".."] = "= %s .." },
	incrementation = { ["+"] = " = %s + 1" , ["-"] = " = %s - 1" },
}

-- Preprocessor
function lune.preprocess(input, args)
	-- generate preprocessor
	local preprocessor = "return function()\n"

	local lines = {}
	for line in (input.."\n"):gmatch("(.-)\n") do
		table.insert(lines, line)
		if line:sub(1,1) == "#" then
			-- exclude shebang
			if not (line:sub(1,2) == "#!" and #lines ==1) then
				preprocessor = preprocessor .. line:sub(2) .. "\n"
			else
				preprocessor = preprocessor .. "output ..= lines[" .. #lines .. "] .. \"\\n\"\n"
			end
		else
			preprocessor = preprocessor .. "output ..= lines[" .. #lines .. "] .. \"\\n\"\n"
		end
	end
	preprocessor = preprocessor .. "return output\nend"

	-- make preprocessor environement
	local env = table.copy(_G)
	env.lune = lune
	env.output = ""
	env.include = function(file)
		local f = io.open(file)
		if not f then error("can't open the file to include") end

		local filename = file:match("([^%/%\\]-)%.[^%.]-$")

		env.output = env.output ..
			"-- INCLUSION OF FILE \""..file.."\" --\n"..
			"local function _()\n"..
				f:read("*a").."\n"..
			"end\n"..
			"local "..filename.." = _() or "..filename.."\n"..
			"-- END OF INCLUDSION OF FILE \""..file.."\" --\n"

		f:close()
	end
	env.rawInclude = function(file)
		local f = io.open(file)
		if not f then error("can't open the file to raw include") end
		env.output = env.output .. f:read("*a").."\n"
		f:close()
	end
	env.print = function(...)
		env.output = env.output .. table.concat({...}, "\t") .. "\n"
	end
	env.args = args or {}
	env.lines = lines

	-- load preprocessor
	local preprocess, err = load(lune.compile(preprocessor), "Preprocessor", nil, env)
	if not preprocess then error("Error while creating preprocessor :\n" .. err) end

	-- execute preprocessor
	local success, output = pcall(preprocess())
	if not success then error("Error while preprocessing file :\n" .. output .. "\nWith preprocessor : \n" .. preprocessor) end

	return output
end

-- Compiler
function lune.compile(input)
	local output = ""

	local last = {}
	for t,v in lexer.lua(input, {}, {}) do
		local toInsert = v

		-- affectation
		if t == "=" then
			if table.hasKey(lune.syntax.affectation, last.token) then
				toInsert = string.format(lune.syntax.affectation[last.token], last.varName)
				output = output:sub(1, -1 -#last.token) -- remove token before =
			end
		end

		-- self-incrementation
		if table.hasKey(lune.syntax.incrementation, t) and t == last.token then
			toInsert = string.format(lune.syntax.incrementation[last.token], last.varName)
			output = output:sub(1, -#last.token*2) -- remove token ++/--
		end

		-- reconstitude full variable name (ex : ith.game.camera)
		if t == "iden" then
			if last.token == "." then
				last.varName = last.varName .. "." .. v
			else
				last.varName = v
			end
		end

		last[t] = v
		last.token = t
		last.value = v

		output = output .. toInsert
	end

	return output
end

-- Preprocess & compile
function lune.make(code, args)
	local preprocessed = lune.preprocess(code, args or {})
	local output = lune.compile(preprocessed)
	return output
end

-- Standalone mode
if debug.getinfo(3) == nil and arg then
	-- Check args
	if #arg < 1 then
		print("Lune version "..lune.VERSION.." by Thomas99")
		print("Command-line usage :")
		print("lua lune.lua <filename> [preprocessor arguments]")
		return lune
	end

	-- Parse args
	local inputFilePath = arg[1]
	local args = {}
	-- Parse compilation args
	for i=2, #arg, 1 do
		if arg[i]:sub(1,2) == "--" then
			args[arg[i]:sub(3)] = arg[i+1]
			i = i +1 -- skip argument value
		end
	end

	-- Open & read input file
	local inputFile, err = io.open(inputFilePath, "r")
	if not inputFile then error("Error while opening input file : "..err) end
	local input = inputFile:read("*a")
	inputFile:close()

	-- End
	print(lune.make(input, args))
end

return lune

