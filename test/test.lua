local candran = dofile(arg[1] or "../candran.lua")

-- test helper
local results = {} -- tests result
local function test(name, candranCode, expectedResult, options)
	results[name] = { result = "not finished", message = "no info" }
	local self = results[name]

	-- make code
	local success, code = pcall(candran.make, candranCode, options)
	if not success then
		self.result = "error"
		self.message = "error while making code:\n"..code
		return
	end

	-- load code
	local success, func = pcall(loadstring or load, code)
	if not success then
		self.result = "error"
		self.message = "error while loading code:\n"..func
		return
	end

	-- run code
	local success, output = pcall(func)
	if not success then
		self.result = "error"
		self.message = "error while running code:\n"..output
		return
	end

	-- check result
	if output ~= expectedResult then
		self.result = "fail"
		self.message = "invalid result from the code; it returned "..tostring(output).." instead of "..tostring(expectedResult)
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
test("continue keyword", [[
local a = ""
for i=1, 10 do
	if i % 2 == 0 then
		continue
	end
	a = a .. i
end
return a
]], "13579")

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
