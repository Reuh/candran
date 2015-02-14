print("========================")
print("||    CANDRAN TESTS   ||")
print("========================")

local candran = dofile(arg[1] or "../build/candran.lua")

-- test helper
local results = {} -- tests result
local function test(name, candranCode, result, args)
	results[name] = { result = "not finished", message = "no info" }
	local self = results[name]

	-- make code
	local success, code = pcall(candran.make, candranCode, args)
	if not success then
		self.result = "error"
		self.message = "error while making code :\n"..code
		return
	end

	-- load code
	local success, func = pcall(load, code)
	if not success then
		self.result = "error"
		self.message = "error while loading code :\n"..func
		return
	end

	-- run code
	local success, output = pcall(func)
	if not success then
		self.result = "error"
		self.message = "error while running code :\n"..output
		return
	end

	-- check result
	if output ~= result then
		self.result = "fail"
		self.message = "invalid result from the code; it returned "..tostring(output).." instead of "..tostring(result)
		return
	else
		self.result = "success"
		return
	end
end

-- tests
print("Running tests...")

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
test("preprocessor args table", [[
#if not (args and args.foo == "sky") then
#	error("Invalid foo argument")
#end
return true
]], true, { foo = "sky" })
test("preprocessor print function", [[
#print("local a = true")
return a
]], true)
test("preprocessor import function", [[
#import("toInclude")
return toInclude
]], 5)
test("preprocessor include function", "a = [[\n#include('toInclude.lua')\n]]\nreturn a", 
	"local a = 5\nreturn a\n")

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

test("decorator", [[
local a = function(func)
	local wrapper = function(...)
		local b = func(...)
		return b + 5
	end
	return wrapper
end
@a
function c(nb)
	return nb^2
end
return c(5)
]], 30)
test("decorator with arguments", [[
local a = function(add)
	local b = function(func)
		local wrapper = function(...)
			local c = func(...)
			return c + add
		end
		return wrapper
	end
	return b
end
@a(10)
function d(nb)
	return nb^2
end
return d(5)
]], 35)
test("multiple decorators", [[
local a = function(func)
	local wrapper = function(...)
		local b = func(...)
		return b + 5
	end
	return wrapper
end
local c = function(func)
	local wrapper = function(...)
		local d = func(...)
		return d * 2
	end
	return wrapper
end
@a
@c
function e(nb)
	return nb^2
end
return e(5)
]], 55)
test("multiple decorators with arguments", [[
local a = function(func)
	local wrapper = function(...)
		local b = func(...)
		return b + 5
	end
	return wrapper
end
local c = function(mul)
	local d = function(func)
		local wrapper = function(...)
			local e = func(...)
			return e * mul
		end
		return wrapper
	end
	return d
end
@a
@c(3)
function f(nb)
	return nb^2
end
return f(5)
]], 80)

-- results
print("=====================")
print("||     RESULTS     ||")
print("=====================")

local resultCounter = {}
local testCounter = 0
for name, test in pairs(results) do
	-- print errors & fails
	if test.result ~= "success" then
		print("Test \""..name.."\" : "..test.result)
		if test.message then print(test.message) end
		print("----------")
	end
	-- count tests results
	resultCounter[test.result] = (resultCounter[test.result] or 0) + 1
	testCounter = testCounter + 1
end

-- print final results
for name, count in pairs(resultCounter) do
	print(count.." "..name.." (" .. math.floor((count / testCounter * 100)*100)/100 .. "%)")
end
print(testCounter.." total")