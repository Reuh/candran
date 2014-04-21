print("=====================")
print("||    LUNE TESTS   ||")
print("=====================")

local lune = dofile(arg[1] or "../build/lune.lua")

-- test helper
local results = {} -- tests result
local function test(name, luneCode, result, args)
	results[name] = { result = "not finished", message = "no info" }
	local self = results[name]

	-- make code
	local success, code = pcall(lune.make, luneCode, args)
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
test("preprocessor include function", [[
#include("toInclude.lua")
return a
]], 5)
test("preprocessor rawInclude function", "a = [[\n#rawInclude('toInclude.lua')\n]]\nreturn a", 
	"a = 5\n")

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

test("++", [[
local a = 5
a++
return a
]], 6)
test("--", [[
local a = 5
a--
return a
]], 4)

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