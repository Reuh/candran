local candran = dofile(arg[1] or "../candran.lua")
candran.default.indentation = "\t"
candran.default.mapLines = false

local load = require("candran.util").load

-- test helper
local results = {} -- tests result
local function test(name, candranCode, expectedResult, options)
	results[name] = { result = "not finished", message = "no info" }
	local self = results[name]

	-- options
	options = options or {}
	options.chunkname = name

	-- make code
	local success, code = pcall(candran.make, candranCode, options)
	if not success then
		self.result = "error"
		self.message = "/!\\ error while making code:\n"..code
		return
	end

	-- load code
	local env = {}
	for k, v in pairs(_G) do env[k] = v end
	local success, func = pcall(load, code, nil, env)
	if not success then
		self.result = "error"
		self.message = "/!\\ error while loading code:\n"..func.."\ngenerated code:\n"..code
		return
	end

	-- run code
	local success, output = pcall(func)
	if not success then
		self.result = "error"
		self.message = "/!\\ error while running code:\n"..output.."\ngenerated code:\n"..code
		return
	end

	-- check result
	if output ~= expectedResult then
		self.result = "fail"
		self.message = "/!\\ invalid result from the code; it returned "..tostring(output).." instead of "..tostring(expectedResult).."; generated code:\n"..code
		return
	else
		self.result = "success"
		return
	end
end

-- tests
print("Running tests...")

------------------
-- PREPROCESSOR --
------------------

test("preprocessor", [[
#local foo = true
return true
]], true)

test("preprocessor condition", [[
#local foo = true
#if not foo then
	return false
#else
	return true
#end
]], true)

test("preprocessor candran table", [[
#write(("return %q"):format(candran.VERSION))
]], candran.VERSION)

test("preprocessor output variable", [[
#output = "return 5"
]], 5)

test("preprocessor import function", [[
#import("toInclude")
return toInclude
]], 5)

test("preprocessor include function", [[
#include('toInclude.lua')
]], 5)

test("preprocessor write function", [[
#write("local a = true")
return a
]], true)

test("preprocessor placeholder function", [[
#placeholder('foo')
]], 5, { foo = "return 5" })

test("preprocessor options", [[
#if not foo == "sky" then
#	error("Invalid foo argument")
#end
return true
]], true, { foo = "sky" })

test("preprocessor long comment", [[
--[[
#error("preprocessor should ignore long comments")
]].."]]"..[[
return true
]], true)

test("preprocessor long comment in long string", [[
a=]].."[["..[[
--[[
#error("preprocessor should ignore long strings")
]].."]]"..[[
return a
]], [[
--[[
#error("preprocessor should ignore long strings")
]])

----------------------
-- SYNTAX ADDITIONS --
----------------------

-- Assignement operators
test("+=", [[
	local a = 5
	a += 2
	return a
]], 7)
test("-=", [[
	local a = 5
	a -= 2
	return a
]], 3)
test("*=", [[
	local a = 5
	a *= 2
	return a
]], 10)
test("/=", [[
	local a = 5
	a /= 2
	return a
]], 5/2)
test("//=", [[
	local a = 5
	a //= 2
	return a
]], 2)
test("^=", [[
	local a = 5
	a ^= 2
	return a
]], 25)
test("%=", [[
	local a = 5
	a %= 2
	return a
]], 5%2)
test("..=", [[
	local a = "hello"
	a ..= " world"
	return a
]], "hello world")
test("and=", [[
	local a = true
	a and= "world"
	return a
]], "world")
test("or=", [[
	local a = false
	a or= "world"
	return a
]], "world")
test("&=", [[
	local a = 5
	a &= 3
	return a
]], 1)
test("|=", [[
	local a = 5
	a |= 3
	return a
]], 7)
test("<<=", [[
	local a = 23
	a <<= 2
	return a
]], 92)
test(">>=", [[
	local a = 23
	a >>= 2
	return a
]], 5)

test("right assigments operators", [[
	local a = 5
	a =+ 2 assert(a == 7, "=+")
	a =- 2 assert(a == -5, "=-")
	a =* -2 assert(a == 10, "=*")
	a =/ 2 assert(a == 0.2, "=/")
	a =// 2 assert(a == 10, "=//")
	a =^ 2 assert(a == 1024, "=^")
	a =% 2000 assert(a == 976, "=%")

	a = "world"
	a =.. "hello " assert(a == "hello world", "=..")
	a =and true assert(a == "hello world", "=and")

	a = false
	a =or nil assert(a == false, "=or")

	a = 3
	a =& 5 assert(a == 1, '=&')
	a =| 20 assert(a == 21, "=|")
	a =<< 1 assert(a == 2097152, "=<<")

	a = 2
	a =>> 23 assert(a == 5, "=>>")
]], nil)

test("some left+right assigments operators", [[
	local a = 5
	a -=+ 2 assert(a == 8, "-=+")

	a = "hello"
	a ..=.. " world " assert(a == "hello world hello", "..=..")
]], nil)

test("left assigments operators priority", [[
	local a = 5
	a *= 2 + 3
	return a
]], 25)
test("right assigments operators priority", [[
	local a = 5
	a =/ 2 + 3
	return a
]], 1)
test("left+right assigments operators priority", [[
	local a = 5
	a *=/ 2 + 3
	return a
]], 5)

-- Default function parameters
test("default parameters", [[
	local function test(hey, def="re", no, foo=("bar"):gsub("bar", "batru"))
		return def..foo
	end
	return test(78, "SANDWICH", true)
]], "SANDWICHbatru")

-- @ self alias
test("@ as self alias", [[
	local a = {}
	function a:hey()
		return @ == self
	end
	return a:hey()
]], true)
test("@ as self alias and indexation", [[
	local a = {
		foo = "Hoi"
	}
	function a:hey()
		return @.foo
	end
	return a:hey()
]], "Hoi")
test("@name indexation", [[
	local a = {
		foo = "Hoi"
	}
	function a:hey()
		return @foo
	end
	return a:hey()
]], "Hoi")
test("@name method call", [[
	local a = {
		foo = "Hoi",
		bar = function(self)
			return self.foo
		end
	}
	function a:hey()
		return @bar()
	end
	return a:hey()
]], "Hoi")
test("@[expt] indexation", [[
	local a = {
		foo = "Hoi"
	}
	function a:hey()
		return @["foo"]
	end
	return a:hey()
]], "Hoi")

-- Short anonymous functions declaration
test("short anonymous function declaration", [[
	local a = (arg1)
		return arg1
	end
	return a(5)
]], 5)
test("short anonymous method declaration", [[
	local a = :(arg1)
		return self + arg1
	end
	return a(2, 3)
]], 5)
test("short anonymous method parsing edge cases", [[
	-- Taken from the file I used when solving this horror, too tired to make separate tests.
	x = ""
	function a(s)
		x = x .. tostring(s or "+")
	end
	k=true
	while k do
		k=false
		cap = {[0] = op, a}
		a(tostring(h))
		if true then
			a()
			if false then
				a = x, (a)
				c()
			end
			a()
		end
		a()
	end
	a()
	a("l")
	let h = (h)
		a("h")
	end
	h()
	a("lol")
	if false then exit() end
	a("pmo")
	if true then
		if false
			a = (h)

		a()
		a("pom")
	end
	a("lo")
	a("kol")
	if false then
		j()
		p()
	end
	do
		b = [
		k = () end
		if false
			k = (lol)
				error("niet")
			end

		k()
		a()]
	end
	if a() then h() end
	local function f (...)
	  if select('#', ...) == 1 then
	    return (...)
	  else
	    return "***"
	  end
	end
	return f(x)
]], "nil++++lhlolpmo+pomlokol++")

-- let variable declaration
test("let variable declaration", [[
	let a = {
		foo = function()
			return type(a)
		end
	}
	return a.foo()
]], "table")

-- continue keyword
test("continue keyword in while", [[
	local a = ""
	local i = 0
	while i < 10 do
		i = i + 1
		if i % 2 == 0 then
			continue
		end
		a = a .. i
	end
	return a
]], "13579")
test("continue keyword in while, used with break", [[
	local a = ""
	local i = 0
	while i < 10 do
		i = i + 1
		if i % 2 == 0 then
			continue
		end
		a = a .. i
		if i == 5 then
			break
		end
	end
	return a
]], "135")
test("continue keyword in repeat", [[
	local a = ""
	local i = 0
	repeat
		i = i + 1
		if i % 2 == 0 then
			continue
		end
		a = a .. i
	until i == 10
	return a
]], "13579")
test("continue keyword in repeat, used with break", [[
	local a = ""
	local i = 0
	repeat
		i = i + 1
		if i % 2 == 0 then
			continue
		end
		a = a .. i
		if i == 5 then
			break
		end
	until i == 10
	return a
]], "135")
test("continue keyword in fornum", [[
	local a = ""
	for i=1, 10 do
		if i % 2 == 0 then
			continue
		end
		a = a .. i
	end
	return a
]], "13579")
test("continue keyword in fornum, used with break", [[
	local a = ""
	for i=1, 10 do
		if i % 2 == 0 then
			continue
		end
		a = a .. i
		if i == 5 then
			break
		end
	end
	return a
]], "135")
test("continue keyword in for", [[
	local t = {1,2,3,4,5,6,7,8,9,10}
	local a = ""
	for _, i in ipairs(t) do
		if i % 2 == 0 then
			continue
		end
		a = a .. i
	end
	return a
]], "13579")
test("continue keyword in for, used with break", [[
	local t = {1,2,3,4,5,6,7,8,9,10}
	local a = ""
	for _, i in ipairs(t) do
		if i % 2 == 0 then
			continue
		end
		a = a .. i
		if i == 5 then
			break
		end
	end
	return a
]], "135")

-- push keyword
test("push keyword", [[
	function a()
		for i=1, 5 do
			push i, "next"
		end
		return "done"
	end
	return table.concat({a()})
]], "1next2next3next4next5nextdone")
test("push keyword variable length", [[
	function v()
		return "hey", "hop"
	end
	function w()
		return "foo", "bar"
	end
	function a()
		push 5, v(), w()
		return
	end
	return table.concat({a()})
]], "5heyfoobar")

-- implicit push
test("implicit push", [[
	function a()
		for i=1, 5 do
			i, "next"
		end
		return "done"
	end
	return table.concat({a()})
]], "1next2next3next4next5nextdone")
test("implicit push variable length", [[
	function v()
		return "hey", "hop"
	end
	function w()
		return "foo", "bar"
	end
	function a()
		if true then
			5, v(), w()
		end
	end
	return table.concat({a()})
]], "5heyfoobar")

-- statement expressions
test("if statement expressions", [[
	a = if false then
		"foo" -- i.e. push "foo", i.e. return "foo"
	else
		"bar"
	end
	return a
]], "bar")
test("do statement expressions", [[
	a = do
		"bar"
	end
	return a
]], "bar")
test("while statement expressions", [[
	i=0
	a, b, c = while i<2 do i=i+1; i end
	return table.concat({a, b, tostring(c)})
]], "12nil")
test("repeat statement expressions", [[
	local i = 0
	a, b, c = repeat i=i+1; i until i==2
	return table.concat({a, b, tostring(c)})
]], "12nil")
test("for statement expressions", [[
	a, b, c = for i=1,2 do i end
	return table.concat({a, b, tostring(c)})
]], "12nil")

-- table comprehension
test("table comprehension sequence", [[
	return table.concat([for i=1,10 do i end])
]], "12345678910")
test("table comprehension associative/self", [[
	a = [for i=1, 10 do @[i] = true end]
	return a[1] and a[10]
]], true)
test("table comprehension variable length", [[
	t1 = {"hey", "hop"}
	t2 = {"foo", "bar"}
	return table.concat([push unpack(t1); push unpack(t2)])
]], "heyhopfoobar")

-- one line statements
test("one line if", [[
	a = 5
	if false
		a = 0
	return a
]], 5)
test("one line if-elseif", [[
	a = 5
	if false
		a = 0
	elseif true
		a = 3
	elseif false
		a = -1
	return a
]], 3)
test("one line for", [[
	a = 0
	for i=1,5
		a = a + 1
	return a
]], 5)
test("one line while", [[
	a = 0
	while a < 5
		a = a + 1
	return a
]], 5)

-- suffixable string litals, table, table comprehension
test("suffixable string litteral method", [[
	return "foo":len()
]], 3)
test("suffixable string litteral method lua conflict", [[
	local s = function() return "four" end
	return s"foo":len()
]], 4)
test("suffixable string litteral dot index", [[
	local a = "foo".len
	return a("foo")
]], 3)
test("suffixable string litteral dot index lua conflict", [[
	local s = function() return {len=4} end
	local a = s"foo".len
	return a
]], 4)
test("suffixable string litteral array index", [[
	local a = "foo"["len"]
	return a("foo")
]], 3)
test("suffixable string litteral dot index lua conflict", [[
	local s = function() return {len=4} end
	local a = s"foo"["len"]
	return a
]], 4)

test("suffixable table litteral method", [[
	return {a=3,len=function(t) return t.a end}:len()
]], 3)
test("suffixable table litteral method lua conflict", [[
	local s = function() return "four" end
	return s{a=3,len=function(t) return t.a end}:len()
]], 4)
test("suffixable table litteral dot index", [[
	return {len=3}.len
]], 3)
test("suffixable table litteral dot index lua conflict", [[
	local s = function() return {len=4} end
	return s{len=3}.len
]], 4)
test("suffixable table litteral array index", [[
	return {len=3}["len"]
]], 3)
test("suffixable table litteral dot index lua conflict", [[
	local s = function() return {len=4} end
	return s{len=3}["len"]
]], 4)

test("suffixable table comprehension method", [[
	return [@len = function() return 3 end]:len()
]], 3)
test("suffixable table comprehension dot index", [[
	return [@len = 3].len
]], 3)
test("suffixable table comprehension array index", [[
	return [@len=3]["len"]
]], 3)

-- let in condition expression
test("let in while condition, evaluation each iteration", [[
	local s = ""
	local i = 0
	while (a = i+2) and i < 3 do
		s = s .. tostring(a)
		i = i + 1
		a = 0
	end
	return s
]], "234")
test("let in while condition, scope", [[
	local s = ""
	local i = 0
	while (a = i+2) and i < 3 do
		s = s .. tostring(a)
		i = i + 1
		a = 0
	end
	return a
]], nil)
test("several let in while condition, evaluation order", [[
	local s = ""
	local i = 0
	while (a = (b=i+1)+1) and i < 3 do
		assert(b==i+1)
		s = s .. tostring(a)
		i = i + 1
		a = 0
	end
	return s
]], "234")
test("several let in while condition, only test the first", [[
	local s = ""
	local i = 0
	while (a,b = false,i) and i < 3 do
		s = s .. tostring(a)
		i = i + 1
	end
	return s
]], "")

test("let in if condition", [[
	if a = false then
		error("condition was false")
	elseif b = nil then
		error("condition was nil")
	elseif c = true then
		return "ok"
	elseif d = true then
		error("should not be reachable")
	end
]], "ok")
test("let in if condition, scope", [[
	local r
	if a = false then
		error("condition was false")
	elseif b = nil then
		error("condition was nil")
	elseif c = true then
		assert(a == false)
		assert(d == nil)
		r = "ok"
	elseif d = true then
		error("should not be reachable")
	end
	assert(c == nil)
	return r
]], "ok")
test("several let in if condition, only test the first", [[
	if a = false then
		error("condition was false")
	elseif b = nil then
		error("condition was nil")
	elseif c, d = false, "ok" then
		error("should have tested against c")
	else
		return d
	end
]], "ok")
test("several let in if condition, evaluation order", [[
	local t = { k = "ok" }
	if a = t[b,c = "k", "l"] then
		assert(c == "l")
		assert(b == "k")
		return a
	end
]], "ok")

-- Method stub
test("method stub, basic", [[
	local t = { s = "ok", m = function(self) return self.s end }
	local f = t:m
	return f()
]], "ok")
test("method stub, store method", [[
	local t = { s = "ok", m = function(self) return self.s end }
	local f = t:m
	t.m = function() return "not ok" end
	return f()
]], "ok")
test("method stub, store object", [[
	local t = { s = "ok", m = function(self) return self.s end }
	local f = t:m
	t = {}
	return f()
]], "ok")
test("method stub, returns nil if method nil", [[
	local t = { m = nil }
	return t:m
]], nil)

-- Safe prefixes
test("safe method stub, when nil", [[
	return t?:m
]], nil)
test("safe method stub, when non-nil", [[
	local t = { s = "ok", m = function(self) return self.s end }
	return t?:m()
]], "ok")

test("safe call, when nil", [[
	return f?()
]], nil)
test("safe call, when non nil", [[
	f = function() return "ok" end
	return f?()
]], "ok")

test("safe index, when nil", [[
	return f?.l
]], nil)
test("safe index, when non nil", [[
	f = { l = "ok" }
	return f?.l
]], "ok")

test("safe prefixes, random chaining", [[
	f = { l = { m = function(s) return s or "ok" end } }
	assert(f?.l?.m() == "ok")
	assert(f?.l?.o == nil)
	assert(f?.l?.o?() == nil)
	assert(f?.lo?.o?() == nil)
	assert(f?.l?:m?() == f.l)
	assert(f?.l:mo == nil)
	assert(f.l?:o?() == nil)
]])

-- Destructuring assigments
test("destructuring assignement with an expression", [[
	local {x, y} = { x = 5, y = 1 }
	return x + y
]], 6)
test("destructuring assignement with local", [[
	t = { x = 5, y = 1 }
	local {x, y} = t
	return x + y
]], 6)
test("destructuring assignement", [[
	t = { x = 5, y = 1 }
	{x, y} = t
	return x + y
]], 6)
test("destructuring assignement with +=", [[
	t = { x = 5, y = 1 }
	local x, y = 5, 9
	{x, y} += t
	return x + y
]], 20)
test("destructuring assignement with =-", [[
	t = { x = 5, y = 1 }
	local x, y = 5, 9
	{x, y} =- t
	return x + y
]], -8)
test("destructuring assignement with +=-", [[
	t = { x = 5, y = 1 }
	local x, y = 5, 9
	{x, y} +=- t
	return x + y
]], 6)
test("destructuring assignement with =-", [[
	t = { x = 5, y = 1 }
	local x, y = 5, 9
	{x, y} =- t
	return x + y
]], -8)
test("destructuring assignement with let", [[
	t = { x = 5, y = 1 }
	let {x, y} = t
	return x + y
]], 6)
test("destructuring assignement with for in", [[
	t = {{ x = 5, y = 1 }}
	for k, {x, y} in pairs(t) do
		return x + y
	end
]], 6)
test("destructuring assignement with if with assignement", [[
	t = { x = 5, y = 1 }
	if {x, y} = t then
		return x + y
	end
]], 6)
test("destructuring assignement with if-elseif with assignement", [[
	t = { x = 5, y = 1 }
	if ({u} = t) and u then
		return 0
	elseif {x, y} = t then
		return x + y
	end
]], 6)

test("destructuring assignement with an expression with custom name", [[
	local {o = x, y} = { o = 5, y = 1 }
	return x + y
]], 6)
test("destructuring assignement with local with custom name", [[
	t = { o = 5, y = 1 }
	local {o = x, y} = t
	return x + y
]], 6)
test("destructuring assignement with custom name", [[
	t = { o = 5, y = 1 }
	{o = x, y} = t
	return x + y
]], 6)
test("destructuring assignement with += with custom name", [[
	t = { o = 5, y = 1 }
	local x, y = 5, 9
	{o = x, y} += t
	return x + y
]], 20)
test("destructuring assignement with =- with custom name", [[
	t = { o = 5, y = 1 }
	local x, y = 5, 9
	{o = x, y} =- t
	return x + y
]], -8)
test("destructuring assignement with +=- with custom name", [[
	t = { o = 5, y = 1 }
	local x, y = 5, 9
	{o = x, y} +=- t
	return x + y
]], 6)
test("destructuring assignement with let with custom name", [[
	t = { o = 5, y = 1 }
	let {o = x, y} = t
	return x + y
]], 6)
test("destructuring assignement with for in with custom name", [[
	t = {{ o = 5, y = 1 }}
	for k, {o = x, y} in pairs(t) do
		return x + y
	end
]], 6)
test("destructuring assignement with if with assignement with custom name", [[
	t = { o = 5, y = 1 }
	if {o = x, y} = t then
		return x + y
	end
]], 6)
test("destructuring assignement with if-elseif with assignement with custom name", [[
	t = { o = 5, y = 1 }
	if ({x} = t) and x then
		return 0
	elseif {o = x, y} = t then
		return x + y
	end
]], 6)

test("destructuring assignement with an expression with expression as key", [[
	local {[1] = x, y} = { 5, y = 1 }
	return x + y
]], 6)
test("destructuring assignement with local with expression as key", [[
	t = { 5, y = 1 }
	local {[1] = x, y} = t
	return x + y
]], 6)
test("destructuring assignement with expression as key", [[
	t = { 5, y = 1 }
	{[1] = x, y} = t
	return x + y
]], 6)
test("destructuring assignement with += with expression as key", [[
	t = { 5, y = 1 }
	local x, y = 5, 9
	{[1] = x, y} += t
	return x + y
]], 20)
test("destructuring assignement with =- with expression as key", [[
	t = { 5, y = 1 }
	local x, y = 5, 9
	{[1] = x, y} =- t
	return x + y
]], -8)
test("destructuring assignement with +=- with expression as key", [[
	t = { 5, y = 1 }
	local x, y = 5, 9
	{[1] = x, y} +=- t
	return x + y
]], 6)
test("destructuring assignement with let with expression as key", [[
	t = { 5, y = 1 }
	let {[1] = x, y} = t
	return x + y
]], 6)
test("destructuring assignement with for in with expression as key", [[
	t = {{ 5, y = 1 }}
	for k, {[1] = x, y} in pairs(t) do
		return x + y
	end
]], 6)
test("destructuring assignement with if with assignement with expression as key", [[
	t = { 5, y = 1 }
	if {[1] = x, y} = t then
		return x + y
	end
]], 6)
test("destructuring assignement with if-elseif with assignement with expression as key", [[
	t = { 5, y = 1 }
	if ({x} = t) and x then
		return 0
	elseif {[1] = x, y} = t then
		return x + y
	end
]], 6)

-- results
local resultCounter = {}
local testCounter = 0
for name, t in pairs(results) do
	-- print errors & fails
	if t.result ~= "success" then
		print(name.." test: "..t.result)
		if t.message then print(t.message) end
		print("----------")
	end
	-- count tests results
	resultCounter[t.result] = (resultCounter[t.result] or 0) + 1
	testCounter = testCounter + 1
end

-- print final results
for name, count in pairs(resultCounter) do
	print(count.." "..name.." (" .. math.floor((count / testCounter * 100)*100)/100 .. "%)")
end
print(testCounter.." total")
