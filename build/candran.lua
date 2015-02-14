--[[
Candran language, preprocessor and compiler by Thomas99.

LICENSE :
Copyright (c) 2015 Thomas99

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

local candran = {
	VERSION = "0.1.0",
	syntax = {
		assignment = { "+=", "-=", "*=", "/=", "^=", "%=", "..=" },
		decorator = "@"
	}
}
package.loaded["candran"] = candran

-- IMPORT OF MODULE "lib.table" --
local function _()
--[[
Table utility by Thomas99.

LICENSE :
Copyright (c) 2015 Thomas99

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

-- Diverses fonctions en rapport avec les tables.
-- v0.1.0
--
-- Changements :
-- - v0.1.0 :
-- 		Première version versionnée. Il a dû se passer des trucs avant mais j'ai pas noté :p

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
package.loaded["lib.table"] = table or true
-- END OF IMPORT OF MODULE "lib.table" --
-- IMPORT OF MODULE "lib.LuaMinify.Util" --
local function _()
--[[
This file is part of LuaMinify by stravant (https://github.com/stravant/LuaMinify).

LICENSE :
The MIT License (MIT)

Copyright (c) 2012-2013

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--
-- Util.lua
--
-- Provides some common utilities shared throughout the project.
--

local function lookupify(tb)
	for _, v in pairs(tb) do
		tb[v] = true
	end
	return tb
end


local function CountTable(tb)
	local c = 0
	for _ in pairs(tb) do c = c + 1 end
	return c
end


local function PrintTable(tb, atIndent)
	if tb.Print then
		return tb.Print()
	end
	atIndent = atIndent or 0
	local useNewlines = (CountTable(tb) > 1)
	local baseIndent = string.rep('    ', atIndent+1)
	local out = "{"..(useNewlines and '\n' or '')
	for k, v in pairs(tb) do
		if type(v) ~= 'function' then
		--do
			out = out..(useNewlines and baseIndent or '')
			if type(k) == 'number' then
				--nothing to do
			elseif type(k) == 'string' and k:match("^[A-Za-z_][A-Za-z0-9_]*$") then 
				out = out..k.." = "
			elseif type(k) == 'string' then
				out = out.."[\""..k.."\"] = "
			else
				out = out.."["..tostring(k).."] = "
			end
			if type(v) == 'string' then
				out = out.."\""..v.."\""
			elseif type(v) == 'number' then
				out = out..v
			elseif type(v) == 'table' then
				out = out..PrintTable(v, atIndent+(useNewlines and 1 or 0))
			else
				out = out..tostring(v)
			end
			if next(tb, k) then
				out = out..","
			end
			if useNewlines then
				out = out..'\n'
			end
		end
	end
	out = out..(useNewlines and string.rep('    ', atIndent) or '').."}"
	return out
end


local function splitLines(str)
	if str:match("\n") then
		local lines = {}
		for line in str:gmatch("[^\n]*") do 
			table.insert(lines, line)
		end
		assert(#lines > 0)
		return lines
	else
		return { str }
	end
end


local function printf(fmt, ...)
	return print(string.format(fmt, ...))
end


return {
	PrintTable = PrintTable,
	CountTable = CountTable,
	lookupify  = lookupify,
	splitLines = splitLines,
	printf     = printf,
}

end
local Util = _() or Util
package.loaded["lib.LuaMinify.Util"] = Util or true
-- END OF IMPORT OF MODULE "lib.LuaMinify.Util" --
-- IMPORT OF MODULE "lib.LuaMinify.Scope" --
local function _()
--[[
This file is part of LuaMinify by stravant (https://github.com/stravant/LuaMinify).

LICENSE :
The MIT License (MIT)

Copyright (c) 2012-2013

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local Scope = {
	new = function(self, parent)
		local s = {
			Parent = parent,
			Locals = { },
			Globals = { },
			oldLocalNamesMap = { },
			oldGlobalNamesMap = { },
			Children = { },
		}
		
		if parent then
			table.insert(parent.Children, s)
		end
		
		return setmetatable(s, { __index = self })
	end,
	
	AddLocal = function(self, v)
		table.insert(self.Locals, v)
	end,
	
	AddGlobal = function(self, v)
		table.insert(self.Globals, v)
	end,
	
	CreateLocal = function(self, name)
		local v
		v = self:GetLocal(name)
		if v then return v end
		v = { }
		v.Scope = self
		v.Name = name
		v.IsGlobal = false
		v.CanRename = true
		v.References = 1
		self:AddLocal(v)
		return v
	end,
	
	GetLocal = function(self, name)
		for k, var in pairs(self.Locals) do
			if var.Name == name then return var end
		end
		
		if self.Parent then
			return self.Parent:GetLocal(name)
		end
	end,
	
	GetOldLocal = function(self, name)
		if self.oldLocalNamesMap[name] then
			return self.oldLocalNamesMap[name]
		end
		return self:GetLocal(name)
	end,
	
	mapLocal = function(self, name, var)
		self.oldLocalNamesMap[name] = var
	end,
	
	GetOldGlobal = function(self, name)
		if self.oldGlobalNamesMap[name] then
			return self.oldGlobalNamesMap[name]
		end
		return self:GetGlobal(name)
	end,
	
	mapGlobal = function(self, name, var)
		self.oldGlobalNamesMap[name] = var
	end,
	
	GetOldVariable = function(self, name)
		return self:GetOldLocal(name) or self:GetOldGlobal(name)
	end,
	
	RenameLocal = function(self, oldName, newName)
		oldName = type(oldName) == 'string' and oldName or oldName.Name
		local found = false
		local var = self:GetLocal(oldName)
		if var then
			var.Name = newName
			self:mapLocal(oldName, var)
			found = true
		end
		if not found and self.Parent then
			self.Parent:RenameLocal(oldName, newName)
		end
	end,
	
	RenameGlobal = function(self, oldName, newName)
		oldName = type(oldName) == 'string' and oldName or oldName.Name
		local found = false
		local var = self:GetGlobal(oldName)
		if var then
			var.Name = newName
			self:mapGlobal(oldName, var)
			found = true
		end
		if not found and self.Parent then
			self.Parent:RenameGlobal(oldName, newName)
		end
	end,
	
	RenameVariable = function(self, oldName, newName)
		oldName = type(oldName) == 'string' and oldName or oldName.Name
		if self:GetLocal(oldName) then
			self:RenameLocal(oldName, newName)
		else
			self:RenameGlobal(oldName, newName)
		end
	end,
	
	GetAllVariables = function(self)
		local ret = self:getVars(true) -- down
		for k, v in pairs(self:getVars(false)) do -- up
			table.insert(ret, v)
		end
		return ret
	end,
	
	getVars = function(self, top)
		local ret = { }
		if top then
			for k, v in pairs(self.Children) do
				for k2, v2 in pairs(v:getVars(true)) do
					table.insert(ret, v2)
				end
			end
		else
			for k, v in pairs(self.Locals) do
				table.insert(ret, v)
			end
			for k, v in pairs(self.Globals) do
				table.insert(ret, v)
			end
			if self.Parent then
				for k, v in pairs(self.Parent:getVars(false)) do
					table.insert(ret, v)
				end
			end
		end
		return ret
	end,
	
	CreateGlobal = function(self, name)
		local v
		v = self:GetGlobal(name)
		if v then return v end
		v = { }
		v.Scope = self
		v.Name = name
		v.IsGlobal = true
		v.CanRename = true
		v.References = 1
		self:AddGlobal(v)
		return v
	end, 
	
	GetGlobal = function(self, name)
		for k, v in pairs(self.Globals) do
			if v.Name == name then return v end
		end
		
		if self.Parent then
			return self.Parent:GetGlobal(name)
		end
	end,
	
	GetVariable = function(self, name)
		return self:GetLocal(name) or self:GetGlobal(name)
	end,
	
	ObfuscateLocals = function(self, recommendedMaxLength, validNameChars)
		recommendedMaxLength = recommendedMaxLength or 7
		local chars = validNameChars or "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuioplkjhgfdsazxcvbnm_"
		local chars2 = validNameChars or "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuioplkjhgfdsazxcvbnm_1234567890"
		for _, var in pairs(self.Locals) do
			local id = ""
			local tries = 0
			repeat
				local n = math.random(1, #chars)
				id = id .. chars:sub(n, n)
				for i = 1, math.random(0, tries > 5 and 30 or recommendedMaxLength) do
					local n = math.random(1, #chars2)
					id = id .. chars2:sub(n, n)
				end
				tries = tries + 1
			until not self:GetVariable(id)
			self:RenameLocal(var.Name, id)
		end
	end,
}

return Scope

end
local Scope = _() or Scope
package.loaded["lib.LuaMinify.Scope"] = Scope or true
-- END OF IMPORT OF MODULE "lib.LuaMinify.Scope" --
-- IMPORT OF MODULE "lib.LuaMinify.ParseCandran" --
local function _()
--
-- CANDRAN
-- Based on the ParseLua.lua of LuaMinify.
-- Modified by Thomas99 to parse Candran code.
--
-- Modified parts are marked with "-- CANDRAN" comments.
--

--[[
This file is part of LuaMinify by stravant (https://github.com/stravant/LuaMinify).

LICENSE :
The MIT License (MIT)

Copyright (c) 2012-2013

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--
-- ParseLua.lua
--
-- The main lua parser and lexer.
-- LexLua returns a Lua token stream, with tokens that preserve
-- all whitespace formatting information.
-- ParseLua returns an AST, internally relying on LexLua.
--

--require'LuaMinify.Strict' -- CANDRAN : comment, useless here

-- CANDRAN : add Candran syntaxic additions
local candran = require("candran").syntax

local util = require 'lib.LuaMinify.Util'
local lookupify = util.lookupify

local WhiteChars = lookupify{ ' ', '\n', '\t', '\r'}
local EscapeLookup = {['\r'] = '\\r', ['\n'] = '\\n', ['\t'] = '\\t', ['"'] = '\\"', ["'"] = "\\'"}
local LowerChars = lookupify{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
local UpperChars = lookupify{ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}
local Digits = lookupify{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
local HexDigits = lookupify{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'a', 'B', 'b', 'C', 'c', 'D', 'd', 'E', 'e', 'F', 'f'}

local Symbols = lookupify{ '+', '-', '*', '/', '^', '%', ',', '{', '}', '[', ']', '(', ')', ';', '#',  
							table.unpack(candran.assignment)} -- CANDRAN : Candran symbols
local Scope = require'lib.LuaMinify.Scope'

local Keywords = lookupify{ 'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true', 'until', 'while',  candran.decorator -- LUA : Candran keywords
};

local function LexLua(src)
	--token dump
	local tokens = {}

	local st, err = pcall(function()
		--line / char / pointer tracking
		local p = 1
		local line = 1
		local char = 1

		--get / peek functions
		local function get()
			local c = src:sub(p,p)
			if c == '\n' then
				char = 1
				line = line + 1
			else
				char = char + 1
			end
			p = p + 1
			return c
		end
		local function peek(n)
			n = n or 0
			return src:sub(p+n,p+n)
		end
		local function consume(chars)
			local c = peek()
			for i = 1, #chars do
				if c == chars:sub(i,i) then return get() end
			end
		end

		--shared stuff
		local function generateError(err)
			return error(">> :"..line..":"..char..": "..err, 0)
		end

		local function tryGetLongString()
			local start = p
			if peek() == '[' then
				local equalsCount = 0
				local depth = 1
				while peek(equalsCount+1) == '=' do
					equalsCount = equalsCount + 1
				end
				if peek(equalsCount+1) == '[' then
					--start parsing the string. Strip the starting bit
					for _ = 0, equalsCount+1 do get() end

					--get the contents
					local contentStart = p
					while true do
						--check for eof
						if peek() == '' then
							generateError("Expected `]"..string.rep('=', equalsCount).."]` near <eof>.", 3)
						end

						--check for the end
						local foundEnd = true
						if peek() == ']' then
							for i = 1, equalsCount do
								if peek(i) ~= '=' then foundEnd = false end
							end
							if peek(equalsCount+1) ~= ']' then
								foundEnd = false
							end
						else
							if peek() == '[' then
								-- is there an embedded long string?
								local embedded = true
								for i = 1, equalsCount do
									if peek(i) ~= '=' then
										embedded = false
										break
									end
								end
								if peek(equalsCount + 1) == '[' and embedded then
									-- oh look, there was
									depth = depth + 1
									for i = 1, (equalsCount + 2) do
										get()
									end
								end
							end
							foundEnd = false
						end
						--
						if foundEnd then
							depth = depth - 1
							if depth == 0 then
								break
							else
								for i = 1, equalsCount + 2 do
									get()
								end
							end
						else
							get()
						end
					end

					--get the interior string
					local contentString = src:sub(contentStart, p-1)

					--found the end. Get rid of the trailing bit
					for i = 0, equalsCount+1 do get() end

					--get the exterior string
					local longString = src:sub(start, p-1)

					--return the stuff
					return contentString, longString
				else
					return nil
				end
			else
				return nil
			end
		end

		--main token emitting loop
		while true do
			--get leading whitespace. The leading whitespace will include any comments
			--preceding the token. This prevents the parser needing to deal with comments
			--separately.
			local leading = { }
			local leadingWhite = ''
			local longStr = false
			while true do
				local c = peek()
				if c == '#' and peek(1) == '!' and line == 1 then
					-- #! shebang for linux scripts
					get()
					get()
					leadingWhite = "#!"
					while peek() ~= '\n' and peek() ~= '' do
						leadingWhite = leadingWhite .. get()
					end
					local token = {
						Type = 'Comment',
						CommentType = 'Shebang',
						Data = leadingWhite,
						Line = line,
						Char = char
					}
					token.Print = function()
						return "<"..(token.Type .. string.rep(' ', 7-#token.Type)).."  "..(token.Data or '').." >"
					end
					leadingWhite = ""
					table.insert(leading, token)
				end
				if c == ' ' or c == '\t' then
					--whitespace
					--leadingWhite = leadingWhite..get()
					local c2 = get() -- ignore whitespace
					table.insert(leading, { Type = 'Whitespace', Line = line, Char = char, Data = c2 })
				elseif c == '\n' or c == '\r' then
					local nl = get()
					if leadingWhite ~= "" then
						local token = {
							Type = 'Comment',
							CommentType =  longStr and 'LongComment'or 'Comment',
							Data = leadingWhite,
							Line = line,
							Char = char,
						}
						token.Print = function()
							return "<"..(token.Type .. string.rep(' ', 7-#token.Type)).."  "..(token.Data or '').." >"
						end
						table.insert(leading, token)
						leadingWhite = ""
					end
					table.insert(leading, { Type = 'Whitespace', Line = line, Char = char, Data = nl })
				elseif c == '-' and peek(1) == '-' then
					--comment
					get()
					get()
					leadingWhite = leadingWhite .. '--'
					local _, wholeText = tryGetLongString()
					if wholeText then
						leadingWhite = leadingWhite..wholeText
						longStr = true
					else
						while peek() ~= '\n' and peek() ~= '' do
							leadingWhite = leadingWhite..get()
						end
					end
				else
					break
				end
			end
			if leadingWhite ~= "" then
				local token = {
					Type = 'Comment',
					CommentType =  longStr and 'LongComment'or 'Com mnment',
					Data = leadingWhite,
					Line = line,
					Char = char,
				}
				token.Print = function()
					return "<"..(token.Type .. string.rep(' ', 7-#token.Type)).."  "..(token.Data or '').." >"
				end
				table.insert(leading, token)
			end

			--get the initial char
			local thisLine = line
			local thisChar = char
			local errorAt = ":"..line..":"..char..":> "
			local c = peek()

			--symbol to emit
			local toEmit = nil

			--branch on type
			if c == '' then
				--eof
				toEmit = { Type = 'Eof' }

			-- CANDRAN : add decorator symbol (@)
			elseif c == candran.decorator then
				get()
				toEmit = {Type = 'Keyword', Data = c}

			elseif UpperChars[c] or LowerChars[c] or c == '_' then
				--ident or keyword
				local start = p
				repeat
					get()
					c = peek()
				until not (UpperChars[c] or LowerChars[c] or Digits[c] or c == '_')
				local dat = src:sub(start, p-1)
				if Keywords[dat] then
					toEmit = {Type = 'Keyword', Data = dat}
				else
					toEmit = {Type = 'Ident', Data = dat}
				end

			elseif Digits[c] or (peek() == '.' and Digits[peek(1)]) then
				--number const
				local start = p
				if c == '0' and peek(1) == 'x' then
					get();get()
					while HexDigits[peek()] do get() end
					if consume('Pp') then
						consume('+-')
						while Digits[peek()] do get() end
					end
				else
					while Digits[peek()] do get() end
					if consume('.') then
						while Digits[peek()] do get() end
					end
					if consume('Ee') then
						consume('+-')
						while Digits[peek()] do get() end
					end
				end
				toEmit = {Type = 'Number', Data =  src:sub(start, p-1)}

			elseif c == '\'' or c == '\"' then
				local start = p
				--string const
				local delim = get()
				local contentStart = p
				while true do
					local c = get()
					if c == '\\' then
						get() --get the escape char
					elseif c == delim then
						break
					elseif c == '' then
						generateError("Unfinished string near <eof>")
					end
				end
				local content = src:sub(contentStart, p-2)
				local constant = src:sub(start, p-1)
				toEmit = {Type = 'String', Data = constant, Constant = content}

			-- CANDRAN : accept 3 and 2 caracters symbols
			elseif Symbols[c..peek(1)..peek(2)] then
				local c = c..peek(1)..peek(2)
				get() get() get()
				toEmit = {Type = 'Symbol', Data = c}
			elseif Symbols[c..peek(1)] then
				local c = c..peek(1)
				get() get()
				toEmit = {Type = 'Symbol', Data = c}

			elseif c == '[' then
				local content, wholetext = tryGetLongString()
				if wholetext then
					toEmit = {Type = 'String', Data = wholetext, Constant = content}
				else
					get()
					toEmit = {Type = 'Symbol', Data = '['}
				end

			elseif consume('>=<') then
				if consume('=') then
					toEmit = {Type = 'Symbol', Data =  c..'='}
				else
					toEmit = {Type = 'Symbol', Data = c}
				end

			elseif consume('~') then
				if consume('=') then
					toEmit = {Type = 'Symbol', Data = '~='}
				else
					generateError("Unexpected symbol `~` in source.", 2)
				end

			elseif consume('.') then
				if consume('.') then
					if consume('.') then
						toEmit = {Type = 'Symbol', Data = '...'}
					else
						toEmit = {Type = 'Symbol', Data = '..'}
					end
				else
					toEmit = {Type = 'Symbol', Data = '.'}
				end

			elseif consume(':') then
				if consume(':') then
					toEmit = {Type = 'Symbol', Data = '::'}
				else
					toEmit = {Type = 'Symbol', Data = ':'}
				end

			elseif Symbols[c] then
				get()
				toEmit = {Type = 'Symbol', Data = c}

			else
				local contents, all = tryGetLongString()
				if contents then
					toEmit = {Type = 'String', Data = all, Constant = contents}
				else
					generateError("Unexpected Symbol `"..c.."` in source.", 2)
				end
			end

			--add the emitted symbol, after adding some common data
			toEmit.LeadingWhite = leading -- table of leading whitespace/comments
			--for k, tok in pairs(leading) do
			--	tokens[#tokens + 1] = tok
			--end

			toEmit.Line = thisLine
			toEmit.Char = thisChar
			toEmit.Print = function()
				return "<"..(toEmit.Type..string.rep(' ', 7-#toEmit.Type)).."  "..(toEmit.Data or '').." >"
			end
			tokens[#tokens+1] = toEmit

			--halt after eof has been emitted
			if toEmit.Type == 'Eof' then break end
		end
	end)
	if not st then
		return false, err
	end

	--public interface:
	local tok = {}
	local savedP = {}
	local p = 1
	
	function tok:getp()
		return p
	end
	
	function tok:setp(n)
		p = n
	end
	
	function tok:getTokenList()
		return tokens
	end
	
	--getters
	function tok:Peek(n)
		n = n or 0
		return tokens[math.min(#tokens, p+n)]
	end
	function tok:Get(tokenList)
		local t = tokens[p]
		p = math.min(p + 1, #tokens)
		if tokenList then
			table.insert(tokenList, t)
		end
		return t
	end
	function tok:Is(t)
		return tok:Peek().Type == t
	end

	--save / restore points in the stream
	function tok:Save()
		savedP[#savedP+1] = p
	end
	function tok:Commit()
		savedP[#savedP] = nil
	end
	function tok:Restore()
		p = savedP[#savedP]
		savedP[#savedP] = nil
	end

	--either return a symbol if there is one, or return true if the requested
	--symbol was gotten.
	function tok:ConsumeSymbol(symb, tokenList)
		local t = self:Peek()
		if t.Type == 'Symbol' then
			if symb then
				if t.Data == symb then
					self:Get(tokenList)
					return true
				else
					return nil
				end
			else
				self:Get(tokenList)
				return t
			end
		else
			return nil
		end
	end

	function tok:ConsumeKeyword(kw, tokenList)
		local t = self:Peek()
		if t.Type == 'Keyword' and t.Data == kw then
			self:Get(tokenList)
			return true
		else
			return nil
		end
	end

	function tok:IsKeyword(kw)
		local t = tok:Peek()
		return t.Type == 'Keyword' and t.Data == kw
	end

	function tok:IsSymbol(s)
		local t = tok:Peek()
		return t.Type == 'Symbol' and t.Data == s
	end

	function tok:IsEof()
		return tok:Peek().Type == 'Eof'
	end

	return true, tok
end


local function ParseLua(src)
	local st, tok
	if type(src) ~= 'table' then
		st, tok = LexLua(src)
	else
		st, tok = true, src
	end
	if not st then
		return false, tok
	end
	--
	local function GenerateError(msg)
		local err = ">> :"..tok:Peek().Line..":"..tok:Peek().Char..": "..msg.."\n"
		--find the line
		local lineNum = 0
		if type(src) == 'string' then
			for line in src:gmatch("[^\n]*\n?") do
				if line:sub(-1,-1) == '\n' then line = line:sub(1,-2) end
				lineNum = lineNum+1
				if lineNum == tok:Peek().Line then
					err = err..">> `"..line:gsub('\t','    ').."`\n"
					for i = 1, tok:Peek().Char do
						local c = line:sub(i,i)
						if c == '\t' then
							err = err..'    '
						else
							err = err..' '
						end
					end
					err = err.."   ^^^^"
					break
				end
			end
		end
		return err
	end
	--
	local VarUid = 0
	-- No longer needed: handled in Scopes now local GlobalVarGetMap = {} 
	local VarDigits = { '_', 'a', 'b', 'c', 'd'}
	local function CreateScope(parent)
		--[[
		local scope = {}
		scope.Parent = parent
		scope.LocalList = {}
		scope.LocalMap = {}

		function scope:ObfuscateVariables()
			for _, var in pairs(scope.LocalList) do
				local id = ""
				repeat
					local chars = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuioplkjhgfdsazxcvbnm_"
					local chars2 = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuioplkjhgfdsazxcvbnm_1234567890"
					local n = math.random(1, #chars)
					id = id .. chars:sub(n, n)
					for i = 1, math.random(0,20) do
						local n = math.random(1, #chars2)
						id = id .. chars2:sub(n, n)
					end
				until not GlobalVarGetMap[id] and not parent:GetLocal(id) and not scope.LocalMap[id]
				var.Name = id
				scope.LocalMap[id] = var
			end
		end
		
		scope.RenameVars = scope.ObfuscateVariables

		-- Renames a variable from this scope and down.
		-- Does not rename global variables.
		function scope:RenameVariable(old, newName)
			if type(old) == "table" then -- its (theoretically) an AstNode variable
				old = old.Name
			end
			for _, var in pairs(scope.LocalList) do
				if var.Name == old then
					var.Name = newName
					scope.LocalMap[newName] = var
				end
			end
		end

		function scope:GetLocal(name)
			--first, try to get my variable
			local my = scope.LocalMap[name]
			if my then return my end

			--next, try parent
			if scope.Parent then
				local par = scope.Parent:GetLocal(name)
				if par then return par end
			end

			return nil
		end

		function scope:CreateLocal(name)
			--create my own var
			local my = {}
			my.Scope = scope
			my.Name = name
			my.CanRename = true
			--
			scope.LocalList[#scope.LocalList+1] = my
			scope.LocalMap[name] = my
			--
			return my
		end]]
		local scope = Scope:new(parent)
		scope.RenameVars = scope.ObfuscateLocals
		scope.ObfuscateVariables = scope.ObfuscateLocals
		scope.Print = function() return "<Scope>" end
		return scope
	end

	local ParseExpr
	local ParseStatementList
	local ParseSimpleExpr, 
			ParseSubExpr,
			ParsePrimaryExpr,
			ParseSuffixedExpr

	local function ParseFunctionArgsAndBody(scope, tokenList)
		local funcScope = CreateScope(scope)
		if not tok:ConsumeSymbol('(', tokenList) then
			return false, GenerateError("`(` expected.")
		end

		--arg list
		local argList = {}
		local isVarArg = false
		while not tok:ConsumeSymbol(')', tokenList) do
			if tok:Is('Ident') then
				local arg = funcScope:CreateLocal(tok:Get(tokenList).Data)
				argList[#argList+1] = arg
				if not tok:ConsumeSymbol(',', tokenList) then
					if tok:ConsumeSymbol(')', tokenList) then
						break
					else
						return false, GenerateError("`)` expected.")
					end
				end
			elseif tok:ConsumeSymbol('...', tokenList) then
				isVarArg = true
				if not tok:ConsumeSymbol(')', tokenList) then
					return false, GenerateError("`...` must be the last argument of a function.")
				end
				break
			else
				return false, GenerateError("Argument name or `...` expected")
			end
		end

		--body
		local st, body = ParseStatementList(funcScope)
		if not st then return false, body end

		--end
		if not tok:ConsumeKeyword('end', tokenList) then
			return false, GenerateError("`end` expected after function body")
		end
		local nodeFunc = {}
		nodeFunc.AstType   = 'Function'
		nodeFunc.Scope     = funcScope
		nodeFunc.Arguments = argList
		nodeFunc.Body      = body
		nodeFunc.VarArg    = isVarArg
		nodeFunc.Tokens    = tokenList
		--
		return true, nodeFunc
	end


	function ParsePrimaryExpr(scope)
		local tokenList = {}

		if tok:ConsumeSymbol('(', tokenList) then
			local st, ex = ParseExpr(scope)
			if not st then return false, ex end
			if not tok:ConsumeSymbol(')', tokenList) then
				return false, GenerateError("`)` Expected.")
			end
			if false then
				--save the information about parenthesized expressions somewhere
				ex.ParenCount = (ex.ParenCount or 0) + 1
				return true, ex
			else
				local parensExp = {}
				parensExp.AstType   = 'Parentheses'
				parensExp.Inner     = ex
				parensExp.Tokens    = tokenList
				return true, parensExp
			end

		elseif tok:Is('Ident') then
			local id = tok:Get(tokenList)
			local var = scope:GetLocal(id.Data)
			if not var then
				var = scope:GetGlobal(id.Data)
				if not var then
					var = scope:CreateGlobal(id.Data)
				else
					var.References = var.References + 1
				end
			else
				var.References = var.References + 1
			end
			--
			local nodePrimExp = {}
			nodePrimExp.AstType   = 'VarExpr'
			nodePrimExp.Name      = id.Data
			nodePrimExp.Variable  = var
			nodePrimExp.Tokens    = tokenList
			--
			return true, nodePrimExp
		else
			return false, GenerateError("primary expression expected")
		end
	end

	function ParseSuffixedExpr(scope, onlyDotColon)
		--base primary expression
		local st, prim = ParsePrimaryExpr(scope)
		if not st then return false, prim end
		--
		while true do
			local tokenList = {}

			if tok:IsSymbol('.') or tok:IsSymbol(':') then
				local symb = tok:Get(tokenList).Data
				if not tok:Is('Ident') then
					return false, GenerateError("<Ident> expected.")
				end
				local id = tok:Get(tokenList)
				local nodeIndex = {}
				nodeIndex.AstType  = 'MemberExpr'
				nodeIndex.Base     = prim
				nodeIndex.Indexer  = symb
				nodeIndex.Ident    = id
				nodeIndex.Tokens   = tokenList
				--
				prim = nodeIndex

			elseif not onlyDotColon and tok:ConsumeSymbol('[', tokenList) then
				local st, ex = ParseExpr(scope)
				if not st then return false, ex end
				if not tok:ConsumeSymbol(']', tokenList) then
					return false, GenerateError("`]` expected.")
				end
				local nodeIndex = {}
				nodeIndex.AstType  = 'IndexExpr'
				nodeIndex.Base     = prim
				nodeIndex.Index    = ex
				nodeIndex.Tokens   = tokenList
				--
				prim = nodeIndex

			elseif not onlyDotColon and tok:ConsumeSymbol('(', tokenList) then
				local args = {}
				while not tok:ConsumeSymbol(')', tokenList) do
					local st, ex = ParseExpr(scope)
					if not st then return false, ex end
					args[#args+1] = ex
					if not tok:ConsumeSymbol(',', tokenList) then
						if tok:ConsumeSymbol(')', tokenList) then
							break
						else
							return false, GenerateError("`)` Expected.")
						end
					end
				end
				local nodeCall = {}
				nodeCall.AstType   = 'CallExpr'
				nodeCall.Base      = prim
				nodeCall.Arguments = args
				nodeCall.Tokens    = tokenList
				--
				prim = nodeCall

			elseif not onlyDotColon and tok:Is('String') then
				--string call
				local nodeCall = {}
				nodeCall.AstType    = 'StringCallExpr'
				nodeCall.Base       = prim
				nodeCall.Arguments  = {  tok:Get(tokenList) }
				nodeCall.Tokens     = tokenList
				--
				prim = nodeCall

			elseif not onlyDotColon and tok:IsSymbol('{') then
				--table call
				local st, ex = ParseSimpleExpr(scope)
				-- FIX: ParseExpr(scope) parses the table AND and any following binary expressions.
				-- We just want the table
				if not st then return false, ex end
				local nodeCall = {}
				nodeCall.AstType   = 'TableCallExpr'
				nodeCall.Base      = prim
				nodeCall.Arguments = { ex }
				nodeCall.Tokens    = tokenList
				--
				prim = nodeCall

			else
				break
			end
		end
		return true, prim
	end


	function ParseSimpleExpr(scope)
		local tokenList = {}

		if tok:Is('Number') then
			local nodeNum = {}
			nodeNum.AstType = 'NumberExpr'
			nodeNum.Value   = tok:Get(tokenList)
			nodeNum.Tokens  = tokenList
			return true, nodeNum

		elseif tok:Is('String') then
			local nodeStr = {}
			nodeStr.AstType = 'StringExpr'
			nodeStr.Value   = tok:Get(tokenList)
			nodeStr.Tokens  = tokenList
			return true, nodeStr

		elseif tok:ConsumeKeyword('nil', tokenList) then
			local nodeNil = {}
			nodeNil.AstType = 'NilExpr'
			nodeNil.Tokens  = tokenList
			return true, nodeNil

		elseif tok:IsKeyword('false') or tok:IsKeyword('true') then
			local nodeBoolean = {}
			nodeBoolean.AstType = 'BooleanExpr'
			nodeBoolean.Value   = (tok:Get(tokenList).Data == 'true')
			nodeBoolean.Tokens  = tokenList
			return true, nodeBoolean

		elseif tok:ConsumeSymbol('...', tokenList) then
			local nodeDots = {}
			nodeDots.AstType  = 'DotsExpr'
			nodeDots.Tokens   = tokenList
			return true, nodeDots

		elseif tok:ConsumeSymbol('{', tokenList) then
			local v = {}
			v.AstType = 'ConstructorExpr'
			v.EntryList = {}
			--
			while true do
				-- CANDRAN : read decorator(s)
				local decorated = false
				local decoratorChain = {}
				while tok:ConsumeKeyword(candran.decorator) do
					if not tok:Is('Ident') then
						return false, GenerateError("Decorator name expected")
					end
					-- CANDRAN : get decorator name
					local st, decorator = ParseExpr(scope)
					if not st then return false, ex end

					table.insert(decoratorChain, decorator)
					decorated = true
				end

				if tok:IsSymbol('[', tokenList) then
					--key
					tok:Get(tokenList)
					local st, key = ParseExpr(scope)
					if not st then
						return false, GenerateError("Key Expression Expected")
					end
					if not tok:ConsumeSymbol(']', tokenList) then
						return false, GenerateError("`]` Expected")
					end
					if not tok:ConsumeSymbol('=', tokenList) then
						return false, GenerateError("`=` Expected")
					end
					local st, value = ParseExpr(scope)
					if not st then
						return false, GenerateError("Value Expression Expected")
					end
					v.EntryList[#v.EntryList+1] = {
						Type  = 'Key';
						Key   = key;
						Value = value;
					}

				elseif tok:Is('Ident') then
					--value or key
					local lookahead = tok:Peek(1)
					if lookahead.Type == 'Symbol' and lookahead.Data == '=' then
						--we are a key
						local key = tok:Get(tokenList)
						if not tok:ConsumeSymbol('=', tokenList) then
							return false, GenerateError("`=` Expected")
						end
						local st, value = ParseExpr(scope)
						if not st then
							return false, GenerateError("Value Expression Expected")
						end
						v.EntryList[#v.EntryList+1] = {
							Type  = 'KeyString';
							Key   =  key.Data;
							Value = value;
						}

					else
						--we are a value
						local st, value = ParseExpr(scope)
						if not st then
							return false, GenerateError("Value Exected")
						end
						v.EntryList[#v.EntryList+1] = {
							Type = 'Value';
							Value = value;
						}

					end
				elseif tok:ConsumeSymbol('}', tokenList) then
					break

				else
					--value
					local st, value = ParseExpr(scope)
					v.EntryList[#v.EntryList+1] = {
						Type = 'Value';
						Value = value;
					}
					if not st then
						return false, GenerateError("Value Expected")
					end
				end

				-- CANDRAN : decorate entry
				if decorated then
					v.EntryList[#v.EntryList].Decorated = true
					v.EntryList[#v.EntryList].DecoratorChain = decoratorChain
				end

				if tok:ConsumeSymbol(';', tokenList) or tok:ConsumeSymbol(',', tokenList) then
					--all is good
				elseif tok:ConsumeSymbol('}', tokenList) then
					break
				else
					return false, GenerateError("`}` or table entry Expected")
				end
			end
			v.Tokens  = tokenList
			return true, v

		elseif tok:ConsumeKeyword('function', tokenList) then
			local st, func = ParseFunctionArgsAndBody(scope, tokenList)
			if not st then return false, func end
			--
			func.IsLocal = true
			return true, func

		else
			return ParseSuffixedExpr(scope)
		end
	end


	local unops = lookupify{ '-', 'not', '#'}
	local unopprio = 8
	local priority = {
		['+'] = { 6, 6};
		['-'] = { 6, 6};
		['%'] = { 7, 7};
		['/'] = { 7, 7};
		['*'] = { 7, 7};
		['^'] = { 10, 9};
		['..'] = { 5, 4};
		['=='] = { 3, 3};
		['<'] = { 3, 3};
		['<='] = { 3, 3};
		['~='] = { 3, 3};
		['>'] = { 3, 3};
		['>='] = { 3, 3};
		['and'] = { 2, 2};
		['or'] = { 1, 1};
	}
	function ParseSubExpr(scope, level)
		--base item, possibly with unop prefix
		local st, exp
		if unops[tok:Peek().Data] then
			local tokenList = {}
			local op = tok:Get(tokenList).Data
			st, exp = ParseSubExpr(scope, unopprio)
			if not st then return false, exp end
			local nodeEx = {}
			nodeEx.AstType = 'UnopExpr'
			nodeEx.Rhs     = exp
			nodeEx.Op      = op
			nodeEx.OperatorPrecedence = unopprio
			nodeEx.Tokens  = tokenList
			exp = nodeEx
		else
			st, exp = ParseSimpleExpr(scope)
			if not st then return false, exp end
		end

		--next items in chain
		while true do
			local prio = priority[tok:Peek().Data]
			if prio and prio[1] > level then
				local tokenList = {}
				local op = tok:Get(tokenList).Data
				local st, rhs = ParseSubExpr(scope, prio[2])
				if not st then return false, rhs end
				local nodeEx = {}
				nodeEx.AstType = 'BinopExpr'
				nodeEx.Lhs     = exp
				nodeEx.Op      = op
				nodeEx.OperatorPrecedence = prio[1]
				nodeEx.Rhs     = rhs
				nodeEx.Tokens  = tokenList
				--
				exp = nodeEx
			else
				break
			end
		end

		return true, exp
	end


	ParseExpr = function(scope)
		return ParseSubExpr(scope, 0)
	end


	local function ParseStatement(scope)
		local stat = nil
		local tokenList = {}
		if tok:ConsumeKeyword('if', tokenList) then
			--setup
			local nodeIfStat = {}
			nodeIfStat.AstType = 'IfStatement'
			nodeIfStat.Clauses = {}

			--clauses
			repeat
				local st, nodeCond = ParseExpr(scope)
				if not st then return false, nodeCond end
				if not tok:ConsumeKeyword('then', tokenList) then
					return false, GenerateError("`then` expected.")
				end
				local st, nodeBody = ParseStatementList(scope)
				if not st then return false, nodeBody end
				nodeIfStat.Clauses[#nodeIfStat.Clauses+1] = {
					Condition = nodeCond;
					Body = nodeBody;
				}
			until not tok:ConsumeKeyword('elseif', tokenList)

			--else clause
			if tok:ConsumeKeyword('else', tokenList) then
				local st, nodeBody = ParseStatementList(scope)
				if not st then return false, nodeBody end
				nodeIfStat.Clauses[#nodeIfStat.Clauses+1] = {
					Body = nodeBody;
				}
			end

			--end
			if not tok:ConsumeKeyword('end', tokenList) then
				return false, GenerateError("`end` expected.")
			end

			nodeIfStat.Tokens = tokenList
			stat = nodeIfStat

		elseif tok:ConsumeKeyword('while', tokenList) then
			--setup
			local nodeWhileStat = {}
			nodeWhileStat.AstType = 'WhileStatement'

			--condition
			local st, nodeCond = ParseExpr(scope)
			if not st then return false, nodeCond end

			--do
			if not tok:ConsumeKeyword('do', tokenList) then
				return false, GenerateError("`do` expected.")
			end

			--body
			local st, nodeBody = ParseStatementList(scope)
			if not st then return false, nodeBody end

			--end
			if not tok:ConsumeKeyword('end', tokenList) then
				return false, GenerateError("`end` expected.")
			end

			--return
			nodeWhileStat.Condition = nodeCond
			nodeWhileStat.Body      = nodeBody
			nodeWhileStat.Tokens    = tokenList
			stat = nodeWhileStat

		elseif tok:ConsumeKeyword('do', tokenList) then
			--do block
			local st, nodeBlock = ParseStatementList(scope)
			if not st then return false, nodeBlock end
			if not tok:ConsumeKeyword('end', tokenList) then
				return false, GenerateError("`end` expected.")
			end

			local nodeDoStat = {}
			nodeDoStat.AstType = 'DoStatement'
			nodeDoStat.Body    = nodeBlock
			nodeDoStat.Tokens  = tokenList
			stat = nodeDoStat

		elseif tok:ConsumeKeyword('for', tokenList) then
			--for block
			if not tok:Is('Ident') then
				return false, GenerateError("<ident> expected.")
			end
			local baseVarName = tok:Get(tokenList)
			if tok:ConsumeSymbol('=', tokenList) then
				--numeric for
				local forScope = CreateScope(scope)
				local forVar = forScope:CreateLocal(baseVarName.Data)
				--
				local st, startEx = ParseExpr(scope)
				if not st then return false, startEx end
				if not tok:ConsumeSymbol(',', tokenList) then
					return false, GenerateError("`,` Expected")
				end
				local st, endEx = ParseExpr(scope)
				if not st then return false, endEx end
				local st, stepEx;
				if tok:ConsumeSymbol(',', tokenList) then
					st, stepEx = ParseExpr(scope)
					if not st then return false, stepEx end
				end
				if not tok:ConsumeKeyword('do', tokenList) then
					return false, GenerateError("`do` expected")
				end
				--
				local st, body = ParseStatementList(forScope)
				if not st then return false, body end
				if not tok:ConsumeKeyword('end', tokenList) then
					return false, GenerateError("`end` expected")
				end
				--
				local nodeFor = {}
				nodeFor.AstType  = 'NumericForStatement'
				nodeFor.Scope    = forScope
				nodeFor.Variable = forVar
				nodeFor.Start    = startEx
				nodeFor.End      = endEx
				nodeFor.Step     = stepEx
				nodeFor.Body     = body
				nodeFor.Tokens   = tokenList
				stat = nodeFor
			else
				--generic for
				local forScope = CreateScope(scope)
				--
				local varList = {  forScope:CreateLocal(baseVarName.Data) }
				while tok:ConsumeSymbol(',', tokenList) do
					if not tok:Is('Ident') then
						return false, GenerateError("for variable expected.")
					end
					varList[#varList+1] = forScope:CreateLocal(tok:Get(tokenList).Data)
				end
				if not tok:ConsumeKeyword('in', tokenList) then
					return false, GenerateError("`in` expected.")
				end
				local generators = {}
				local st, firstGenerator = ParseExpr(scope)
				if not st then return false, firstGenerator end
				generators[#generators+1] = firstGenerator
				while tok:ConsumeSymbol(',', tokenList) do
					local st, gen = ParseExpr(scope)
					if not st then return false, gen end
					generators[#generators+1] = gen
				end
				if not tok:ConsumeKeyword('do', tokenList) then
					return false, GenerateError("`do` expected.")
				end
				local st, body = ParseStatementList(forScope)
				if not st then return false, body end
				if not tok:ConsumeKeyword('end', tokenList) then
					return false, GenerateError("`end` expected.")
				end
				--
				local nodeFor = {}
				nodeFor.AstType      = 'GenericForStatement'
				nodeFor.Scope        = forScope
				nodeFor.VariableList = varList
				nodeFor.Generators   = generators
				nodeFor.Body         = body
				nodeFor.Tokens       = tokenList
				stat = nodeFor
			end

		elseif tok:ConsumeKeyword('repeat', tokenList) then
			local st, body = ParseStatementList(scope)
			if not st then return false, body end
			--
			if not tok:ConsumeKeyword('until', tokenList) then
				return false, GenerateError("`until` expected.")
			end
			-- FIX: Used to parse in parent scope
			-- Now parses in repeat scope
			local st, cond = ParseExpr(body.Scope)
			if not st then return false, cond end
			--
			local nodeRepeat = {}
			nodeRepeat.AstType   = 'RepeatStatement'
			nodeRepeat.Condition = cond
			nodeRepeat.Body      = body
			nodeRepeat.Tokens    = tokenList
			stat = nodeRepeat

		-- CANDRAN : add decorator keyword (@)
		elseif tok:ConsumeKeyword(candran.decorator, tokenList) then
			if not tok:Is('Ident') then
				return false, GenerateError("Decorator name expected")
			end

			-- CANDRAN : get decorator name
			local st, decorator = ParseExpr(scope)
			if not st then return false, ex end

			-- CANDRAN : get decorated statement/decorator chain
			local st, nodeStatement = ParseStatement(scope)
			if not st then return false, nodeStatement end

			local nodeDecorator = {}
			nodeDecorator.AstType       = 'DecoratedStatement'
			nodeDecorator.Decorator     = decorator
			nodeDecorator.Decorated     = nodeStatement
			nodeDecorator.Tokens        = tokenList
			stat = nodeDecorator

		elseif tok:ConsumeKeyword('function', tokenList) then
			if not tok:Is('Ident') then
				return false, GenerateError("Function name expected")
			end
			local st, name = ParseSuffixedExpr(scope, true) --true => only dots and colons
			if not st then return false, name end
			--
			local st, func = ParseFunctionArgsAndBody(scope, tokenList)
			if not st then return false, func end
			--
			func.IsLocal = false
			func.Name    = name
			stat = func

		elseif tok:ConsumeKeyword('local', tokenList) then
			if tok:Is('Ident') then
				local varList = {  tok:Get(tokenList).Data }
				while tok:ConsumeSymbol(',', tokenList) do
					if not tok:Is('Ident') then
						return false, GenerateError("local var name expected")
					end
					varList[#varList+1] = tok:Get(tokenList).Data
				end

				local initList = {}
				if tok:ConsumeSymbol('=', tokenList) then
					repeat
						local st, ex = ParseExpr(scope)
						if not st then return false, ex end
						initList[#initList+1] = ex
					until not tok:ConsumeSymbol(',', tokenList)
				end

				--now patch var list
				--we can't do this before getting the init list, because the init list does not
				--have the locals themselves in scope.
				for i, v in pairs(varList) do
					varList[i] = scope:CreateLocal(v)
				end

				local nodeLocal = {}
				nodeLocal.AstType   = 'LocalStatement'
				nodeLocal.LocalList = varList
				nodeLocal.InitList  = initList
				nodeLocal.Tokens    = tokenList
				--
				stat = nodeLocal

			elseif tok:ConsumeKeyword('function', tokenList) then
				if not tok:Is('Ident') then
					return false, GenerateError("Function name expected")
				end
				local name = tok:Get(tokenList).Data
				local localVar = scope:CreateLocal(name)
				--
				local st, func = ParseFunctionArgsAndBody(scope, tokenList)
				if not st then return false, func end
				--
				func.Name         = localVar
				func.IsLocal      = true
				stat = func

			else
				return false, GenerateError("local var or function def expected")
			end

		elseif tok:ConsumeSymbol('::', tokenList) then
			if not tok:Is('Ident') then
				return false, GenerateError('Label name expected')
			end
			local label = tok:Get(tokenList).Data
			if not tok:ConsumeSymbol('::', tokenList) then
				return false, GenerateError("`::` expected")
			end
			local nodeLabel = {}
			nodeLabel.AstType = 'LabelStatement'
			nodeLabel.Label   = label
			nodeLabel.Tokens  = tokenList
			stat = nodeLabel

		elseif tok:ConsumeKeyword('return', tokenList) then
			local exList = {}
			if not tok:IsKeyword('end') then
				local st, firstEx = ParseExpr(scope)
				if st then
					exList[1] = firstEx
					while tok:ConsumeSymbol(',', tokenList) do
						local st, ex = ParseExpr(scope)
						if not st then return false, ex end
						exList[#exList+1] = ex
					end
				end
			end

			local nodeReturn = {}
			nodeReturn.AstType   = 'ReturnStatement'
			nodeReturn.Arguments = exList
			nodeReturn.Tokens    = tokenList
			stat = nodeReturn

		elseif tok:ConsumeKeyword('break', tokenList) then
			local nodeBreak = {}
			nodeBreak.AstType = 'BreakStatement'
			nodeBreak.Tokens  = tokenList
			stat = nodeBreak

		elseif tok:ConsumeKeyword('goto', tokenList) then
			if not tok:Is('Ident') then
				return false, GenerateError("Label expected")
			end
			local label = tok:Get(tokenList).Data
			local nodeGoto = {}
			nodeGoto.AstType = 'GotoStatement'
			nodeGoto.Label   = label
			nodeGoto.Tokens  = tokenList
			stat = nodeGoto

		else
			--statementParseExpr
			local st, suffixed = ParseSuffixedExpr(scope)
			if not st then return false, suffixed end

			--assignment or call?
			-- CANDRAN : check if it is a Candran assignment symbol
			local function isCandranAssignmentSymbol()
				for _,s in ipairs(candran.assignment) do
					if tok:IsSymbol(s) then
						return true
					end
				end
				return false
			end
			if tok:IsSymbol(',') or tok:IsSymbol('=') or isCandranAssignmentSymbol() then
				--check that it was not parenthesized, making it not an lvalue
				if (suffixed.ParenCount or 0) > 0 then
					return false, GenerateError("Can not assign to parenthesized expression, is not an lvalue")
				end

				--more processing needed
				local lhs = { suffixed }
				while tok:ConsumeSymbol(',', tokenList) do
					local st, lhsPart = ParseSuffixedExpr(scope)
					if not st then return false, lhsPart end
					lhs[#lhs+1] = lhsPart
				end

				--equals
				-- CANDRAN : consume the Candran assignment symbol
				local function consumeCandranAssignmentSymbol()
					for _,s in ipairs(candran.assignment) do
						if tok:ConsumeSymbol(s, tokenList) then
							return true
						end
					end
					return false
				end
				if not tok:ConsumeSymbol('=', tokenList) and not consumeCandranAssignmentSymbol() then
					return false, GenerateError("`=` Expected.")
				end

				--rhs
				local rhs = {}
				local st, firstRhs = ParseExpr(scope)
				if not st then return false, firstRhs end
				rhs[1] = firstRhs
				while tok:ConsumeSymbol(',', tokenList) do
					local st, rhsPart = ParseExpr(scope)
					if not st then return false, rhsPart end
					rhs[#rhs+1] = rhsPart
				end

				--done
				local nodeAssign = {}
				nodeAssign.AstType = 'AssignmentStatement'
				nodeAssign.Lhs     = lhs
				nodeAssign.Rhs     = rhs
				nodeAssign.Tokens  = tokenList
				stat = nodeAssign

			elseif suffixed.AstType == 'CallExpr' or
				   suffixed.AstType == 'TableCallExpr' or
				   suffixed.AstType == 'StringCallExpr'
			then
				--it's a call statement
				local nodeCall = {}
				nodeCall.AstType    = 'CallStatement'
				nodeCall.Expression = suffixed
				nodeCall.Tokens     = tokenList
				stat = nodeCall
			else
				return false, GenerateError("Assignment Statement Expected")
			end
		end

		if tok:IsSymbol(';') then
			stat.Semicolon = tok:Get( stat.Tokens )
		end
		return true, stat
	end


	local statListCloseKeywords = lookupify{ 'end', 'else', 'elseif', 'until'}

	ParseStatementList = function(scope)
		local nodeStatlist   = {}
		nodeStatlist.Scope   = CreateScope(scope)
		nodeStatlist.AstType = 'Statlist'
		nodeStatlist.Body    = { }
		nodeStatlist.Tokens  = { }
		--
		--local stats = {}
		--
		while not statListCloseKeywords[tok:Peek().Data] and not tok:IsEof() do
			local st, nodeStatement = ParseStatement(nodeStatlist.Scope)
			if not st then return false, nodeStatement end
			--stats[#stats+1] = nodeStatement
			nodeStatlist.Body[#nodeStatlist.Body + 1] = nodeStatement
		end

		if tok:IsEof() then
			local nodeEof = {}
			nodeEof.AstType = 'Eof'
			nodeEof.Tokens  = {  tok:Get() }
			nodeStatlist.Body[#nodeStatlist.Body + 1] = nodeEof
		end

		--
		--nodeStatlist.Body = stats
		return true, nodeStatlist
	end


	local function mainfunc()
		local topScope = CreateScope()
		return ParseStatementList(topScope)
	end

	local st, main = mainfunc()
	--print("Last Token: "..PrintTable(tok:Peek()))
	return st, main
end

return { LexLua = LexLua, ParseLua = ParseLua }
	
end
local ParseCandran = _() or ParseCandran
package.loaded["lib.LuaMinify.ParseCandran"] = ParseCandran or true
-- END OF IMPORT OF MODULE "lib.LuaMinify.ParseCandran" --
-- IMPORT OF MODULE "lib.LuaMinify.FormatIdentityCandran" --
local function _()
--
-- CANDRAN
-- Based on the FormatIdentity.lua of LuaMinify.
-- Modified by Thomas99 to format valid Lua code from Candran AST.
--
-- Modified parts are marked with "-- CANDRAN" comments.
--

--[[
This file is part of LuaMinify by stravant (https://github.com/stravant/LuaMinify).

LICENSE :
The MIT License (MIT)

Copyright (c) 2012-2013

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

--require'strict' -- CANDRAN : comment, useless here

-- CANDRAN : add Candran syntaxic additions
local candran = require("candran").syntax

require'lib.LuaMinify.ParseCandran'
local util = require'lib.LuaMinify.Util'

local function debug_printf(...)
	--[[
	util.printf(...)
	--]]
end

--
-- FormatIdentity.lua
--
-- Returns the exact source code that was used to create an AST, preserving all
-- comments and whitespace.
-- This can be used to get back a Lua source after renaming some variables in
-- an AST.
--

local function Format_Identity(ast)
	local out = {
		rope = {},  -- List of strings
		line = 1,
		char = 1,

		appendStr = function(self, str)
			table.insert(self.rope, str)

			local lines = util.splitLines(str)
			if #lines == 1 then
				self.char = self.char + #str
			else
				self.line = self.line + #lines - 1
				local lastLine = lines[#lines]
				self.char = #lastLine
			end
		end,

		-- CANDRAN : options
		appendToken = function(self, token, options)
			local options = options or {} -- CANDRAN
			self:appendWhite(token, options)
			--[*[
			--debug_printf("appendToken(%q)", token.Data)
			local data  = token.Data
			local lines = util.splitLines(data)
			while self.line + #lines < token.Line do
				if not options.no_newline then self:appendStr('\n') end -- CANDRAN : options
				self.line = self.line + 1
				self.char = 1
			end
			--]]
			if options.no_newline then data = data:gsub("[\n\r]*", "") end -- CANDRAN : options
			if options.no_leading_white then data = data:gsub("^%s+", "") end
			self:appendStr(data)
		end,

		-- CANDRAN : options
		appendTokens = function(self, tokens, options)
			for _,token in ipairs(tokens) do
				self:appendToken( token, options ) -- CANDRAN : options
			end
		end,

		-- CANDRAN : options
		appendWhite = function(self, token, options)
			if token.LeadingWhite then
				self:appendTokens( token.LeadingWhite, options ) -- CANDRAN : options
				--self.str = self.str .. ' '
			end
		end
	}

	local formatStatlist, formatExpr, formatStatement;

	-- CANDRAN : added options argument
	-- CANDRAN : options = { no_newline = false, no_leading_white = false }
	formatExpr = function(expr, options)
		local options = options or {} -- CANDRAN
		local tok_it = 1
		local function appendNextToken(str)
			local tok = expr.Tokens[tok_it];
			if str and tok.Data ~= str then
				error("Expected token '" .. str .. "'. Tokens: " .. util.PrintTable(expr.Tokens))
			end
			out:appendToken( tok, options ) -- CANDRAN : options
			tok_it = tok_it + 1
			options.no_leading_white = false -- CANDRAN : not the leading token anymore
		end
		local function appendToken(token)
			out:appendToken( token, options ) -- CANDRAN : options
			tok_it = tok_it + 1
			options.no_leading_white = false -- CANDRAN : not the leading token anymore
		end
		local function appendWhite()
			local tok = expr.Tokens[tok_it];
			if not tok then error(util.PrintTable(expr)) end
			out:appendWhite( tok, options ) -- CANDRAN : options
			tok_it = tok_it + 1
			options.no_leading_white = false -- CANDRAN : not the leading token anymore
		end
		local function appendStr(str)
			appendWhite()
			out:appendStr(str)
		end
		local function peek()
			if tok_it < #expr.Tokens then
				return expr.Tokens[tok_it].Data
			end
		end
		local function appendComma(mandatory, seperators)
			if true then
				seperators = seperators or { "," }
				seperators = util.lookupify( seperators )
				if not mandatory and not seperators[peek()] then
					return
				end
				assert(seperators[peek()], "Missing comma or semicolon")
				appendNextToken()
			else
				local p = peek()
				if p == "," or p == ";" then
					appendNextToken()
				end
			end
		end

		debug_printf("formatExpr(%s) at line %i", expr.AstType, expr.Tokens[1] and expr.Tokens[1].Line or -1)

		if expr.AstType == 'VarExpr' then
			if expr.Variable then
				appendStr( expr.Variable.Name )
			else
				appendStr( expr.Name )
			end

		elseif expr.AstType == 'NumberExpr' then
			appendToken( expr.Value )

		elseif expr.AstType == 'StringExpr' then
			appendToken( expr.Value )

		elseif expr.AstType == 'BooleanExpr' then
			appendNextToken( expr.Value and "true" or "false" )

		elseif expr.AstType == 'NilExpr' then
			appendNextToken( "nil" )

		elseif expr.AstType == 'BinopExpr' then
			formatExpr(expr.Lhs)
			appendStr( expr.Op )
			formatExpr(expr.Rhs)

		elseif expr.AstType == 'UnopExpr' then
			appendStr( expr.Op )
			formatExpr(expr.Rhs)

		elseif expr.AstType == 'DotsExpr' then
			appendNextToken( "..." )

		elseif expr.AstType == 'CallExpr' then
			formatExpr(expr.Base)
			appendNextToken( "(" )
			for i,arg in ipairs( expr.Arguments ) do
				formatExpr(arg)
				appendComma( i ~= #expr.Arguments )
			end
			appendNextToken( ")" )

		elseif expr.AstType == 'TableCallExpr' then
			formatExpr( expr.Base )
			formatExpr( expr.Arguments[1] )

		elseif expr.AstType == 'StringCallExpr' then
			formatExpr(expr.Base)
			appendToken( expr.Arguments[1] )

		elseif expr.AstType == 'IndexExpr' then
			formatExpr(expr.Base)
			appendNextToken( "[" )
			formatExpr(expr.Index)
			appendNextToken( "]" )

		elseif expr.AstType == 'MemberExpr' then
			formatExpr(expr.Base)
			appendNextToken()  -- . or :
			appendToken(expr.Ident)

		elseif expr.AstType == 'Function' then
			-- anonymous function
			appendNextToken( "function" )
			appendNextToken( "(" )
			if #expr.Arguments > 0 then
				for i = 1, #expr.Arguments do
					appendStr( expr.Arguments[i].Name )
					if i ~= #expr.Arguments then
						appendNextToken(",")
					elseif expr.VarArg then
						appendNextToken(",")
						appendNextToken("...")
					end
				end
			elseif expr.VarArg then
				appendNextToken("...")
			end
			appendNextToken(")")
			formatStatlist(expr.Body)
			appendNextToken("end")

		elseif expr.AstType == 'ConstructorExpr' then
			-- CANDRAN : function to get a value with its applied decorators
			local function appendValue(entry)
				out:appendStr(" ")
				if entry.Decorated then
					for _,d in ipairs(entry.DecoratorChain) do
						formatExpr(d)
						out:appendStr("(")
					end
				end
				formatExpr(entry.Value, { no_leading_white = true })
				if entry.Decorated then
					for _ in ipairs(entry.DecoratorChain) do
						out:appendStr(")")
					end
				end
			end

			appendNextToken( "{" )
			for i = 1, #expr.EntryList do
				local entry = expr.EntryList[i]
				if entry.Type == 'Key' then
					appendNextToken( "[" )
					formatExpr(entry.Key)
					appendNextToken( "]" )
					appendNextToken( "=" )
					appendValue(entry) -- CANDRAN : respect decorators
				elseif entry.Type == 'Value' then
					appendValue(entry) -- CANDRAN : respect decorators
				elseif entry.Type == 'KeyString' then
					appendStr(entry.Key)
					appendNextToken( "=" )
					appendValue(entry) -- CANDRAN : respect decorators
				end
				appendComma( i ~= #expr.EntryList, { ",", ";" } )
			end
			appendNextToken( "}" )

		elseif expr.AstType == 'Parentheses' then
			appendNextToken( "(" )
			formatExpr(expr.Inner)
			appendNextToken( ")" )

		else
			print("Unknown AST Type: ", statement.AstType)
		end

		assert(tok_it == #expr.Tokens + 1)
		debug_printf("/formatExpr")
	end

	formatStatement = function(statement)
		local tok_it = 1
		local function appendNextToken(str)
			local tok = statement.Tokens[tok_it];
			assert(tok, string.format("Not enough tokens for %q. First token at %i:%i",
				str, statement.Tokens[1].Line, statement.Tokens[1].Char))
			assert(tok.Data == str,
				string.format('Expected token %q, got %q', str, tok.Data))
			out:appendToken( tok )
			tok_it = tok_it + 1
		end
		local function appendToken(token)
			out:appendToken( str )
			tok_it = tok_it + 1
		end
		local function appendWhite()
			local tok = statement.Tokens[tok_it];
			out:appendWhite( tok )
			tok_it = tok_it + 1
		end
		local function appendStr(str)
			appendWhite()
			out:appendStr(str)
		end
		local function appendComma(mandatory)
			if mandatory
			   or (tok_it < #statement.Tokens and statement.Tokens[tok_it].Data == ",") then
			   appendNextToken( "," )
			end
		end

		debug_printf("")
		debug_printf(string.format("formatStatement(%s) at line %i", statement.AstType, statement.Tokens[1] and statement.Tokens[1].Line or -1))

		if statement.AstType == 'AssignmentStatement' then
			local newlineToCheck -- CANDRAN : position of a potential newline to eliminate in some edge cases

			for i,v in ipairs(statement.Lhs) do
				formatExpr(v)
				appendComma( i ~= #statement.Lhs )
			end
			if #statement.Rhs > 0 then
				-- CANDRAN : get the assignment operator used (default to =)
				local assignmentToken = "="
				local candranAssignmentExists = util.lookupify(candran.assignment)
				for i,v in pairs(statement.Tokens) do
					if candranAssignmentExists[v.Data] then
						assignmentToken = v.Data
						break
					end
				end
				appendNextToken(assignmentToken) -- CANDRAN : accept Candran assignments operators
				--appendNextToken( "=" )
				newlineToCheck = #out.rope + 1 -- CANDRAN : the potential newline position afte the =

				if assignmentToken == "=" then
					for i,v in ipairs(statement.Rhs) do
						formatExpr(v)
						appendComma( i ~= #statement.Rhs )
					end
				else
					out.rope[#out.rope] = "= " -- CANDRAN : remplace +=, -=, etc. with =
					for i,v in ipairs(statement.Rhs) do
						if i <= #statement.Lhs then -- CANDRAN : impossible to assign more variables than indicated in Lhs
							formatExpr(statement.Lhs[i], { no_newline = true }) -- CANDRAN : write variable to assign
							out:appendStr(" "..assignmentToken:gsub("=$","")) -- CANDRAN : assignment operation
							formatExpr(v) -- CANDRAN : write variable to add/sub/etc.
							if i ~= #statement.Rhs then -- CANDRAN : add comma to allow multi-assignment
								appendComma( i ~= #statement.Rhs )
								if i >= #statement.Lhs then
									out.rope[#out.rope] = "" -- CANDRAN : if this was the last element, remove the comma
								end
							end
						end
					end
				end
			end

			-- CANDRAN : eliminate the bad newlines
			if out.rope[newlineToCheck] == "\n" then
				out.rope[newlineToCheck] = ""
			end

		elseif statement.AstType == 'CallStatement' then
			formatExpr(statement.Expression)

		elseif statement.AstType == 'LocalStatement' then
			appendNextToken( "local" )
			for i = 1, #statement.LocalList do
				appendStr( statement.LocalList[i].Name )
				appendComma( i ~= #statement.LocalList )
			end
			if #statement.InitList > 0 then
				appendNextToken( "=" )
				for i = 1, #statement.InitList do
					formatExpr(statement.InitList[i])
					appendComma( i ~= #statement.InitList )
				end
			end

		elseif statement.AstType == 'IfStatement' then
			appendNextToken( "if" )
			formatExpr( statement.Clauses[1].Condition )
			appendNextToken( "then" )
			formatStatlist( statement.Clauses[1].Body )
			for i = 2, #statement.Clauses do
				local st = statement.Clauses[i]
				if st.Condition then
					appendNextToken( "elseif" )
					formatExpr(st.Condition)
					appendNextToken( "then" )
				else
					appendNextToken( "else" )
				end
				formatStatlist(st.Body)
			end
			appendNextToken( "end" )

		elseif statement.AstType == 'WhileStatement' then
			appendNextToken( "while" )
			formatExpr(statement.Condition)
			appendNextToken( "do" )
			formatStatlist(statement.Body)
			appendNextToken( "end" )

		elseif statement.AstType == 'DoStatement' then
			appendNextToken( "do" )
			formatStatlist(statement.Body)
			appendNextToken( "end" )

		elseif statement.AstType == 'ReturnStatement' then
			appendNextToken( "return" )
			for i = 1, #statement.Arguments do
				formatExpr(statement.Arguments[i])
				appendComma( i ~= #statement.Arguments )
			end

		elseif statement.AstType == 'BreakStatement' then
			appendNextToken( "break" )

		elseif statement.AstType == 'RepeatStatement' then
			appendNextToken( "repeat" )
			formatStatlist(statement.Body)
			appendNextToken( "until" )
			formatExpr(statement.Condition)

		-- CANDRAN : add decorator support (@)
		elseif statement.AstType == 'DecoratedStatement' then
			-- CANDRAN : list of the chained decorators
			local decoratorChain = { statement}

			-- CANDRAN : get the decorated statement
			local decorated = statement.Decorated
			while decorated.AstType == "DecoratedStatement" do
				table.insert(decoratorChain, decorated)
				decorated = decorated.Decorated
			end

			-- CANDRAN : write the decorated statement like a normal statement
			formatStatement(decorated)

			-- CANDRAN : mark the decorator token as used (and add whitespace)
			appendNextToken(candran.decorator)
			out.rope[#out.rope] = ""

			-- CANDRAN : get the variable(s) to decorate name(s)
			local names = {}
			if decorated.AstType == "Function" then
				table.insert(names, decorated.Name.Name)
			elseif decorated.AstType == "AssignmentStatement" then
				for _,var in ipairs(decorated.Lhs) do
					table.insert(names, var.Name)
				end
			elseif decorated.AstType == "LocalStatement" then
				for _,var in ipairs(decorated.LocalList) do
					table.insert(names, var.Name)
				end
			else
				error("Invalid statement type to decorate : "..decorated.AstType)
			end

			-- CANDRAN : redefine the variable(s) ( name, name2, ... = ... )
			for i,name in ipairs(names) do
				out:appendStr(name)
				if i ~= #names then out:appendStr(", ") end
			end
			out:appendStr(" = ")

			for i,name in ipairs(names) do
				-- CANDRAN : write the decorator chain ( a(b(c(... )
				for _,v in pairs(decoratorChain) do
					formatExpr(v.Decorator)
					out:appendStr("(")
				end

				-- CANDRAN : pass the undecorated variable name to the decorator chain
				out:appendStr(name)

				-- CANDRAN : close parantheses
				for _ in pairs(decoratorChain) do
					out:appendStr(")")
				end

				if i ~= #names then out:appendStr(", ") end
			end
			
		elseif statement.AstType == 'Function' then
			--print(util.PrintTable(statement))

			if statement.IsLocal then
				appendNextToken( "local" )
			end
			appendNextToken( "function" )

			if statement.IsLocal then
				appendStr(statement.Name.Name)
			else
				formatExpr(statement.Name)
			end

			appendNextToken( "(" )
			if #statement.Arguments > 0 then
				for i = 1, #statement.Arguments do
					appendStr( statement.Arguments[i].Name )
					appendComma( i ~= #statement.Arguments or statement.VarArg )
					if i == #statement.Arguments and statement.VarArg then
						appendNextToken( "..." )
					end
				end
			elseif statement.VarArg then
				appendNextToken( "..." )
			end
			appendNextToken( ")" )

			formatStatlist(statement.Body)
			appendNextToken( "end" )

		elseif statement.AstType == 'GenericForStatement' then
			appendNextToken( "for" )
			for i = 1, #statement.VariableList do
				appendStr( statement.VariableList[i].Name )
				appendComma( i ~= #statement.VariableList )
			end
			appendNextToken( "in" )
			for i = 1, #statement.Generators do
				formatExpr(statement.Generators[i])
				appendComma( i ~= #statement.Generators )
			end
			appendNextToken( "do" )
			formatStatlist(statement.Body)
			appendNextToken( "end" )

		elseif statement.AstType == 'NumericForStatement' then
			appendNextToken( "for" )
			appendStr( statement.Variable.Name )
			appendNextToken( "=" )
			formatExpr(statement.Start)
			appendNextToken( "," )
			formatExpr(statement.End)
			if statement.Step then
				appendNextToken( "," )
				formatExpr(statement.Step)
			end
			appendNextToken( "do" )
			formatStatlist(statement.Body)
			appendNextToken( "end" )

		elseif statement.AstType == 'LabelStatement' then
			appendNextToken( "::" )
			appendStr( statement.Label )
			appendNextToken( "::" )

		elseif statement.AstType == 'GotoStatement' then
			appendNextToken( "goto" )
			appendStr( statement.Label )

		elseif statement.AstType == 'Eof' then
			appendWhite()

		else
			print("Unknown AST Type: ", statement.AstType)
		end

		if statement.Semicolon then
			appendNextToken(";")
		end

		assert(tok_it == #statement.Tokens + 1)
		debug_printf("/formatStatment")
	end

	formatStatlist = function(statList)
		for _, stat in ipairs(statList.Body) do
			formatStatement(stat)
		end
	end

	formatStatlist(ast)
	
	return true, table.concat(out.rope)
end

return Format_Identity

end
local FormatIdentityCandran = _() or FormatIdentityCandran
package.loaded["lib.LuaMinify.FormatIdentityCandran"] = FormatIdentityCandran or true
-- END OF IMPORT OF MODULE "lib.LuaMinify.FormatIdentityCandran" --

-- Preprocessor
function candran.preprocess(input, args)
	-- generate preprocessor
	local preprocessor = "return function()\n"

	local lines = {}
	for line in (input.."\n"):gmatch("(.-)\n") do
		table.insert(lines, line)
		-- preprocessor instructions (exclude shebang)
		if line:match("^%s*#") and not (line:match("^#!") and #lines == 1) then
			preprocessor = 			preprocessor .. line:gsub("^%s*#", "") .. "\n"
		else
			preprocessor = 			preprocessor .. "output ..= lines[" .. #lines .. "] .. \"\\n\"\n"
		end
	end
	preprocessor = 	preprocessor .. "return output\nend"

	-- make preprocessor environement
	local env = table.copy(_G)
	env.candran = candran
	env.output = ""
	env.import = function(modpath, autoRequire)
		local autoRequire = (autoRequire == nil) or autoRequire

		-- get module filepath
		local filepath
		for _,search in ipairs(package.searchers) do
			local loader, path = search(modpath)
			if type(loader) == "function" and type(path) == "string" then
				filepath = path
				break
			end
		end
		if not filepath then error("No module named \""..modpath.."\"") end

		-- open module file
		local f = io.open(filepath)
		if not f then error("Can't open the module file to import") end
		local modcontent = f:read("*a")
		f:close()

		-- get module name (ex: module name of path.to.module is module)
		local modname = modpath:match("[^%.]+$")

		-- 
		env.output = 
		-- 
		env.output ..
			"-- IMPORT OF MODULE \""..modpath.."\" --\n"..
			"local function _()\n"..
				modcontent.."\n"..
			"end\n"..
			(autoRequire and "local "..modname.." = _() or "..modname.."\n" or "").. -- auto require
			"package.loaded[\""..modpath.."\"] = "..(autoRequire and modname or "_()").." or true\n".. -- add to package.loaded
			"-- END OF IMPORT OF MODULE \""..modpath.."\" --\n"
	end
	env.include = function(file)
		local f = io.open(file)
		if not f then error("Can't open the file to include") end
		env.output = 		env.output .. f:read("*a").."\n"
		f:close()
	end
	env.print = function(...)
		env.output = 		env.output .. table.concat({ ...}, "\t") .. "\n"
	end
	env.args = args or {}
	env.lines = lines

	-- load preprocessor
	local preprocess, err = load(candran.compile(preprocessor), "Preprocessor", nil, env)
	if not preprocess then error("Error while creating preprocessor :\n" .. err) end

	-- execute preprocessor
	local success, output = pcall(preprocess())
	if not success then error("Error while preprocessing file :\n" .. output .. "\nWith preprocessor : \n" .. preprocessor) end

	return output
end

-- Compiler
function candran.compile(input)
	local parse = require("lib.LuaMinify.ParseCandran")
	local format = require("lib.LuaMinify.FormatIdentityCandran")

	local success, ast = parse.ParseLua(input)
	if not success then error("Error while parsing the file :\n"..tostring(ast)) end
	
	local success, output  = format(ast)
	if not success then error("Error while formating the file :\n"..tostring(output)) end

	return output
end

-- Preprocess & compile
function candran.make(code, args)
	local preprocessed = candran.preprocess(code, args or {})
	local output = candran.compile(preprocessed)

	return output
end

-- Standalone mode
if debug.getinfo(3) == nil and arg then
	-- Check args
	if #arg < 1 then
		print("Candran version "..candran.VERSION.." by Thomas99")
		print("Command-line usage :")
		print("lua candran.lua <filename> [preprocessor arguments]")
		return candran
	end

	-- Parse args
	local inputFilepath = arg[1]
	local args = {}
	for i=2, #arg, 1 do
		if arg[i]:sub(1,2) == "--" then
			args[arg[i]:sub(3)] = arg[i+1]
			i = i + 1 -- skip argument value
		end
	end

	-- Open & read input file
	local inputFile, err = io.open(inputFilepath, "r")
	if not inputFile then error("Error while opening input file : "..err) end
	local input = inputFile:read("*a")
	inputFile:close()

	-- Make
	print(candran.make(input, args))
end

return candran

