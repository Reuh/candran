print("========================")
print("||    CANDRAN TESTS   ||")
print("========================")

local candran = dofile(arg[1] or "../candran.lua")

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
	local success, func = pcall(loadstring or load, code)
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
#if not foo == "sky" then
#	error("Invalid foo argument")
#end
return true
]], true, { foo = "sky" })
test("preprocessor write function", [[
#write("local a = true")
return a
]], true)
test("preprocessor import function", [[
#import("toInclude")
return toInclude
]], 5)
test("preprocessor include function", "a = [[\n#include('toInclude.lua')\n]]\nreturn a",
	"local a = 5\nreturn a\n\n")

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
test("default parameters", [[
local function test(hey, def="re", no, foo=("bar"):gsub("bar", "batru"))
	return def..foo
end
return test(78, "SANDWICH", true)
]], "SANDWICHbatru")

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
