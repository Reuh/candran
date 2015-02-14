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
			local decoratorChain = {statement}

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
