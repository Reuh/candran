Candran
=======
Candran is a dialect of the [Lua 5.4](http://www.lua.org) programming language which compiles to Lua 5.4, Lua 5.3, Lua 5.2, LuaJIT and Lua 5.1 compatible code. It adds several useful syntax additions which aims to make Lua faster and easier to write, and a simple preprocessor.

Unlike Moonscript, Candran tries to stay close to the Lua syntax, and existing Lua code should be able to run on Candran unmodified.

````lua
#import("lib.thing") -- static import
#local debug or= false

local function calculate(toadd=25) -- default parameters
	local result = thing.do()
	result += toadd
	#if debug then -- preprocessor conditionals
		print("Did something")
	#end
	return result
end

let a = {
	hey = 5 // 2, -- Lua 5.3+ syntax, that will be translated to work with the current Lua version

	child = nil,

	method = :(foo, thing) -- short function declaration, with self
		@hey = thing(foo) -- @ as an alias for self
	end,

	selfReference = () -- short function declaration, without self
		return a -- no need for a prior local declaration when using let
	end
}

const five = 5 -- shortcut for Lua 5.4 attributes 

a:method(42, (foo)
	return "something " .. foo
end)

local fn = a:method -- bundles an object and method in a function
fn(42, (foo)
	return "something" .. foo
end)

a.child?:method?() -- safe navigation operator

local {hey, method} = a -- destructuring assignement

local odd = [ -- table comprehension
	for i=1, 10 do
		if i%2 == 0 then
			continue -- continue keyword
		end
		i -- implicit push
	end
]

local count = [for i=1,10 i] -- single line statements

local a = if condition then "one" else "two" end -- statement as expressions

print("Hello %s":format("world")) -- methods calls on strings (and tables) litterals without enclosing parentheses

if f, err = io.open("data") then -- if condition with assignements
	thing.process(f)
else
	error("can't open data: "..err)
end

````

**Current status**: Candran is heavily used in several of my personal projects and works as expected.

Candran is released under the MIT License (see ```LICENSE``` for details).

#### Quick setup
Install Candran automatically using LuaRocks: ```sudo luarocks install candran```.

Or manually install LPegLabel (```luarocks install lpeglabel```, version 1.5 or above), download this repository and use Candran through the scripts in ```bin/``` or use it as a library with the self-contained ```candran.lua```.

You can optionally install lua-linenoise (```luarocks install linenoise```, version 0.9 or above) for an improved REPL, and luacheck (```luarocks install luacheck```, version 0.23.0 or above) to be able to use ```cancheck```. Installing Candran using LuaRocks will install linenoise and luacheck by default.

You can register the Candran package searcher in your main Lua file (`require("candran").setup()`) and any subsequent `require` call in your project will automatically search for Candran modules.

If you use LÖVE, some integration with Candran is detailled [here](https://github.com/Reuh/candran/wiki/L%C3%96VE).

#### Editor support
Most editors should be able to use their existing Lua support for Candran code. If you want full support for the additional syntax in your editor:
* **Sublime Text 3**:
	* [sublime-candran](https://github.com/Reuh/sublime-candran) support the full Candran syntax
	* [SublimeLinter-cancheck-contrib](https://github.com/Reuh/SublimeLinter-contrib-cancheck) SublimeLinter plugin for Candran using ```cancheck```
	* [SublimeLinter-candran-contrib](https://github.com/Reuh/SublimeLinter-contrib-candran) SublimeLinter plugin for Candran using ```canc -parse``` (only checks for syntaxic errors, no linting)
* **Atom**: [language-candran](https://atom.io/packages/language-candran) support the full Candran syntax

For linting, if your editor support [luacheck](https://github.com/luarocks/luacheck), you should be able to replace it with ```cancheck``` (in this repository ```bin/cancheck```, or installed automatically if Candran was installed using LuaRocks), which is a wrapper around luacheck that monkey-patch it to support Candran.

The language
------------
### Syntax additions
After the [preprocessor](#preprocessor) is run the Candran code is compiled to Lua. Candran code adds the folowing syntax to Lua 5.4 syntax:

##### Assignment operators
* ````var += nb````
* ````var -= nb````
* ````var *= nb````
* ````var /= nb````
* ````var //= nb````
* ````var ^= nb````
* ````var %= nb````
* ````var ..= str````
* ````var and= str````
* ````var or= str````
* ````var &= nb````
* ````var |= nb````
* ````var <<= nb````
* ````var >>= nb````

For example, a ````var += nb```` assignment will be compiled into ````var = var + nb````.

All theses operators can also be put right of the assigment operator, in which case ```var =+ nb``` will be compiled into ```var = nb + var```.

Right and left operator can be used at the same time.

**Please note** that the code `a=-1` will be compiled into `a = -1` and not `a = a - 1`, like in pure Lua. If you want the latter, spacing is required between the `=-` and the expression: `a=- 1`. Yes, this is also valid Lua code, but as far as I'm aware, nobody write code like this; people who really like spacing would write `a= - 1` or `a = - 1`, and Candran will read both of those as it is expected in pure Lua. This is the only incompatibility between Candran and pure Lua.

##### Default function parameters
```lua
function foo(bar = "default", other = thing.do())
	-- stuff
end
```
If an argument isn't provided or set to ```nil``` when the function is called, it will automatically be set to its default value.

It is equivalent to doing ```if arg == nil then arg = default end``` for each argument at the start of the function.

The default values can be any Lua expression, which will be evaluated in the function's scope each time the default value end up being used.

##### Short anonymous function declaration
```lua
a = (arg1, arg2)
	print(arg1)
end

b = :(hop)
	print(self, hop)
end
```
Anonymous function (functions values) can be created in a more concise way by omitting the ```function``` keyword.

A ```:``` can prefix the parameters parenthesis to automatically add a ```self``` parameter.

##### `@` self aliases
```lua
a = {
	foo = "Hoi"
}

function a:hey()
	print(@foo) -- Hoi
	print(@["foo"]) -- also works
	print(@ == self) -- true
end
```
When a variable name is prefied with ```@```, the name will be accessed in ```self```.

When used by itself, ```@``` is an alias for ```self```.

##### `let` variable declaration
```lua
let a = {
	foo = function()
		print(type(a)) -- table
	end
}
```

Similar to ```local```, but the variable will be declared *before* the assignemnt (i.e. it will compile into ```local a; a = value```), so you can access it from functions defined in the value.

This does not support Lua 5.4 attributes.

Can also be used as a shorter name for ```local```.

##### `const` and `close` variable declaration
```lua
const a = 5
close b = {}

const x, y, z = 1, 2, 3 -- every variable will be defined using <const>
```

Shortcut to Lua 5.4 variable attribute. Do not behave like `let`, as attributes require the variable to be constant and therefore can't be predeclared. Only compatibel with Lua 5.4 target.

##### `continue` keyword
```lua
for i=1, 10 do
	if i % 2 == 0 then
		continue
	end
	print(i) -- 1, 3, 5, 7, 9
end
```

Will skip the current loop iteration.

##### `push` keyword
```lua
function a()
	for i=1, 5 do
		push i, "next"
	end
	return "done"
end
print(a()) -- 1, next, 2, next, 3, next, 4, next, 5, next, done

push "hey" -- Does *not* work, because it is a valid Lua syntax for push("hey")
```

Add one or more value to the returned value list. If you use a `return` afterwards, the pushed values will be placed *before* the `return` values, otherwise the function will only return what was pushed.

In particular, this keyword is useful when used through implicit `push` with table comprehension and statement expressions.

**Please note** that, in order to stay compatible with vanilla Lua syntax, any `push` immediatly followed by a `"string expression"`, `{table expression}` or `(parenthesis)` will be interpreted as a function call. It's recommended to use the implicit `push` when possible.

##### Implicit `push`
```lua
function a()
	for i=1, 5 do
		i, next
	end
	return "done"
end
print(a()) -- 1, next, 2, next, 3, next, 4, next, 5, next, done

-- or probably more useful...
local square = (x) x*x end -- function(x) return x*x end
```

Any list of expressions placed *at the end of a block* will be converted into a `push` automatically.

**Please note** that this doesn't work with `v()` function calls, because these are already valid statements. Use `push v()` in this case.

##### Table comprehension
```lua
a = [
	for i=1, 10 do
		i
	end
] -- { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }

a = [
	for i=1, 10 do
		if i%2 == 0 then
			@[i] = true
		end
	end
] -- { [2] = true, [4] = true, [6] = true, [8] = true, [10] = true }

a = [push unpack(t1); push unpack(t2)] -- concatenate t1 and t2
```

Comprehensions provide a shorter syntax for defining and initializing tables based on a block of code.

You can write *any* code you want between `[` and `]`, this code will be run as if it was a separate function which is immediadtly run.

Values returned by the function will be inserted in the generated table in the order they were returned. This way, each time you `push` value(s), they will be added to the table.

The table generation function also have access to the `self` variable (and its alias `@`), which is the table which is being created, so you can set any of the table's field.

##### Destructuring assignement
```lua
t = { x = 1, y = 2, z = 3 }

{x, y, z} = t -- x, y, z = t.x, t.y, t.z

{x = o} = t -- o = t.x

{["x"] = o} = t -- o = t["x"]

-- Also works with local, let, for ... in, if with assignement, +=, etc.
local {x, y} = t
let {x, y} = t
for i, {x, y} in ipairs{t} do end
if {x, y} = t then end
{x} += t -- x = x + t.x

-- Works as expected with multiple assignement.
a, {x, y, z}, b = 1, t, 2

```

Destruturing assignement allows to quickly extract fields from a table into a variable.

This is done by replacing the variable name in any assignement with a table literal, where every item is the name of the field and assigned variable. It is possible to use a different field name than the variable name by naming the table item (`fieldName = var` or `[fieldExpression] = var`).


##### Safe navigation operators
```lua
a = nil
print(a?.b) -- nil

a = {b=true}
print(a?.b) -- true

-- So instead of typing
if object and object.child and object.child.isGreen then
	-- stuff
end
-- you can type
if object?.child?.isGreen then
	-- stuff
end

-- The ?. operator does not break the whole chain; make sure to use the operator on each index.
print(a?.undefined.field) -- a?.undefined returns nil, so this throws a "attempt to index a nil value"

-- Other safe navigator operators behave similarly:
print(a:method) -- nil if a is nil, other normal behaviour
print(a["key"]) -- nil if a is nil, other normal behaviour
print(a?()) -- nil if a is nil, other normal behaviour
```

Some operators can be prefixed by a `?` to turn into a safe version of the operator: if the base value if `nil`, the normal behaviour of the operator will be skipped and nil will be returned; otherwise, the operator run as usual. Is available safe dot index `?.`, safe array index `?[...]`, safe method stub `?:` and safe function call `?(...)`.

##### If and while with assignement in the condition
```lua
if f, err = io.open("somefile") then -- condition if verified if f is a truthy value (not nil or false)
	-- do something with f
	f:close()
elseif f2, err2 = io.open("anotherfile") then -- same behaviour on elseif
	print("could not open somefile:", err) -- f and err stay in scope for the rest of the if-elseif-else block
	-- do something with f2
	f2:close()
else
	print("could not open somefile:", err)
	print("could not open anotherfile:", err2)
end
-- f, err, f2 and err2 are now out of scope

if (value = list[index = 2]) and yes = true then -- several assignements can be performed, anywhere in the expression; index is defined before value, yes is defined after these two. The condition is verified if both value and yes are thruthy.
	print(index, value)
end

-- When used in a while, the expression is evaluated at each iteration.
while line = io.read() do
	print(line)
end

-- The assignement have the same priority as regular assignements, i.e., the lowest.
if a = 1 and 2 then -- will be read as a = (1 and 2)
elseif (a = 1) and 2 then -- will be read as (a = 1) and 2
end
```

Assignements can be used in the condition of if, elseif and while statements. Several variables can be assigned; only the first will be tested in the condition, for each assignement. The assigned variables will be in scope the duration of the block; for if statements, they will also be in scope for the following elseif(s) and else.

For while statements, the assigned expression will be reevaluated at each iteration.

##### Suffixable string and table litterals
```lua
"some text":upper() -- "SOME TEXT". Same as ("some text"):upper() in Lua.
"string".upper -- the string.upper function. "string"["upper"] also works.

{thing = 3}.thing -- 3. Also works with tables!
[for i=0,5 do i*i end][3] -- 9. And table comprehensions!

-- Functions calls have priority:
someFunction"thing":upper() -- same as (someFunction("thing")):upper() (i.e., the way it would be parsed by Lua)
```

String litterals, table litterals, and comprehensions can be suffixed with `:` method calls, `.` indexing, or `[` indexing, without needing to be enclosed in parentheses.

**Please note**, that "normal" functions calls have priority over this syntax, in order to maintain Lua compatibility.

##### Method stubs
```lua
object = {
	value = 25,
	method = function(self, str)
		print(str, self.value)
	end
}

stub = object:method

object.method = error -- stub stores the method as it was when stub was defined
object = nil -- also stores the object

print(stub("hello")) -- hello	25
```

Create a closure function which bundles the variable and its method; when called it will call the method on the variable, without requiring to pass the variable as a first argument.

The closure stores the value of the variable and method when created.

##### Statement expressions
```lua
a = if false then
	"foo" -- i.e. push "foo", i.e. return "foo"
else
	"bar"
end
print(a) -- bar

a, b, c = for i=1,2 do i end
print(a, b, c) -- 1, 2, nil
```

`if`, `do`, `while`, `repeat` and `for` statements can be used as expressions. Their content will be run as if they were run in a separate function which is immediatly run.

##### One line statements
```lua
if condition()
	a()
elseif foo()
	b()

if other()
	a()
else -- "end" is always needed for else!
	c()
end
```

`if`, `elseif`, `for`, and `while` statements can be written without `do`, `then` or `end`, in which case they contain a single statement.

**Please note** that an `end` is always required for `else` blocks.

### Preprocessor
Before compiling, Candran's preprocessor is run. It execute every line starting with a _#_ (ignoring prefixing whitespace, long strings and comments) as Candran code.
For example,

````lua
#if lang == "fr" then
	print("Bonjour")
#else
	print("Hello")
#end
````

Will output ````print("Bonjour")```` or ````print("Hello")```` depending of the "lang" argument passed to the preprocessor.

The preprocessor has access to the following variables:
* ````candran````: the Candran library table.
* ````output````: the current preprocessor output string. Can be redefined at any time. If you want to write something in the preprocessor output, it is preferred to use `write(...)` instead of directly modifying `output`.
* ````import(module[, [options])````: a function which import a module. This should be equivalent to using _require(module)_ in the Candran code, except the module will be embedded in the current file. _options_ is an optional preprocessor arguments table for the imported module (current preprocessor arguments will be inherited). Options specific to this function:
	* ```loadLocal``` (default ```true```): ```true``` to automatically load the module into a local variable (i.e. ```local thing = require("module.thing")```)
	* ```loadPackage``` (default ```true```): ```true``` to automatically load the module into the loaded packages table (so it will be available for following ```require("module")``` calls).
* ````include(filename)````: a function which copy the contents of the file _filename_ to the output.
* ````write(...)````: write to the preprocessor output. For example, ````#write("hello()")```` will output ````hello()```` in the final file.
* ```placeholder(name)```: if the variable _name_ is defined in the preprocessor environement, its content will be inserted here.
* each arguments passed to the preprocessor is directly available in the environment.
* and every standard Lua library.

Compile targets
---------------
Candran is based on the Lua 5.4 syntax, but can be compiled to Lua 5.4, Lua 5.3, Lua 5.2, LuaJIT, and Lua 5.1 compatible code.

To chose a compile target, set the ```target``` option to  ```lua54```, ```lua53```, ```lua52```, ```luajit```, or ```lua51``` in the option table when using the library or the command line tools. Candran will try to detect the currently used Lua version and use it as the default target.

Candran will try to translate Lua 5.4 syntax into something usable with the current target if possible. Here is what is currently supported:

| Lua version     | Candran target | Integer division operator // | Bitwise operators                                     | Goto/Labels        | Variable attributes |
| ---             | ---            | ---                          | ---                                                   | ---                | ---                 |
| Lua 5.4         | lua54          | :white_check_mark:           | :white_check_mark:                                    | :white_check_mark: | :white_check_mark:  |
| Lua 5.3         | lua53          | :white_check_mark:           | :white_check_mark:                                    | :white_check_mark: | X                   |
| Lua 5.2         | lua52          | :white_check_mark:           | :white_check_mark: (32bit)                            | :white_check_mark: | X                   |
| LuaJIT          | luajit         | :white_check_mark:           | :white_check_mark: (32bit)                            | :white_check_mark: | X                   |
| Lua 5.1         | lua51          | :white_check_mark:           | :white_check_mark: if LuaJIT bit library is available (32bit) | X                  | X                   |

**Please note** that Candran only translates syntax, and will not try to do anything about changes in the Lua standard library (for example, the new utf8 module). If you need this, you should be able to use [lua-compat-5.3](https://github.com/keplerproject/lua-compat-5.3) along with Candran.

Usage
-----
### Command-line usage
The library can be used standalone through the ```canc``` (for compiling Candran files) and ```can``` (for running Candran files directly) utilities:

*	````canc````

	Display the information text (version and basic command-line usage).

*	````canc [options] filename...````

	Preprocess and compile each  _filename_ Candran files, and creates the assiociated ```.lua``` files in the same directories.

	_options_ is of type ````-somearg -anotherarg thing=somestring other=5````, which will generate a Lua table ```{ somearg = true, anotherarg = true, thing = "somestring", other = 5 }```.

	You can choose to use another directory where files should be written using the ```dest=destinationDirectory``` argument.

	You can choose the output filename using ```out=filename```. By default, compiled files have the same name as their input file, but with a ```.lua``` extension.

	```canc``` can write to the standard output instead of creating files using the ```-print``` argument.

	You can choose to run only the preprocessor or compile using the ```-preprocess``` and ```-compile``` flags.

	You can choose to only parse the file and check it for syntaxic errors using the ```-parse``` flag. Errors will be printed to stderr in a similar format to ```luac -p```.

	The ```-ast``` flag is also available for debugging, and will disable preprocessing, compiling and file writing, and instead directly dump the AST generated from the input file(s) to stdout.

	Instead of providing filenames, you can use ```-``` to read from standard input.

	Use the ```-h``` or ```-help``` option to display a short help text.

	Example uses:

	* ````canc foo.can````

		preprocess and compile _foo.can_ and write the result in _foo.lua_.

	* ````canc indentation="  " foo.can````

		preprocess and compile _foo.can_ with 2-space indentation (readable code!) and write the result in _foo.lua_.

	* ````canc foo.can -verbose -print | lua````

		preprocess _foo.can_ with _verbose_ set to _true_, compile it and execute it.

	* ````canc -parse foo.can````

		checks foo.can for syntaxic errors.

*   ```can```

	Start a simplisitic Candran REPL. Will automatically call `candran.setup()`.

	If you want a better REPL (autocompletion, history, ability to move the cursor), install lua-linenoise: ```luarocks install linenoise``` (automatically installed if Candran was installed using LuaRocks).

*	````can [options] filename````

	Preprocess, compile and run _filename_ using the options provided.

	This will automatically register the Candran package searcher using `candran.setup()`, so required Candran modules will be compiled as they are needed.

	This command will use error rewriting unless explicitely enabled (by setting the `rewriteErrors=false` option).

	Instead of providing a filename, you can use ```-``` to read from standard input.

	Use the ```-h``` or ```-help``` option to display a short help text.

*   ```cancheck```

	Provides a linter and static analyzer with the exact same interface as [luacheck](https://github.com/luarocks/luacheck).

	This requires luacheck: ```luarocks install luacheck``` (automatically installed if Candran was installed through LuaRocks).

### Library usage
Candran can also be used as a Lua library:
````lua
local candran = require("candran") -- load Candran

local f = io.open("foo.can") -- read the file foo.can
local contents = f:read("*a")
f:close()

local compiled = candran.make(contents, { debug = true }) -- compile foo.can with debug set to true

load(compiled)() -- execute!

-- or simpler...
candran.dofile("foo.can")

-- or, if you want to be able to directly load Candran files using require("module")
candran.setup()
local foo = require("foo")
````

The table returned by _require("candran")_ gives you access to:

##### Compiler & preprocessor
* ````candran.VERSION````: Candran's version string (e.g. `"0.10.0"`).
* ````candran.preprocess(code[, options])````: return the Candran code _code_, preprocessed with the _options_ options table; or nil, err in case of error.
* ````candran.compile(code[, options])````: return the Candran code compiled to Lua with the _options_ option table; or nil, err in case of error.
* ````candran.make(code[, options])````: return the Candran code, preprocessed and compiled with the _options_ options table; or nil, err in case of error.

##### Code loading helpers
* ```candran.loadfile(filepath, env, options)```: Candran equivalent to the Lua 5.4's loadfile funtion. Will rewrite errors by default.
* ```candran.load(chunk, chunkname, env, options)```: Candran equivalent to the Lua 5.4's load funtion. Will rewrite errors by default.
* ```candran.dofile(filepath, options)```: Candran equivalent to the Lua 5.4's dofile funtion. Will rewrite errors by default.

#### Error rewriting
When using the command-line tools or the code loading helpers, Candran will automatically setup error rewriting: because the code is reformated when
compiled and preprocessed, lines numbers given by Lua in case of error are hardly usable. To fix that, Candran map each line from the compiled file to
the lines from the original file(s), inspired by MoonScript. Errors will be displayed as:

```
example.can:12(5): attempt to call a nil value (global 'iWantAnError')
```

12 is the line number in the original Candran file, and 5 is the line number in the compiled file.

If you are using the preprocessor ```import()``` function, the source Candran file and destination Lua file might not have the same name. In this case, the error will be:

```
example.can:12(final.lua:5): attempt to call a nil value (global 'iWantAnError')
```

Please note that Candran can only wrap code directly called from Candran; if an error is raised from Lua, there will be no rewriting of Candran lines the stacktrace. These lines are indicated using `(compiled candran)` before the line number.

If you want Candran to always wrap errors, you will need to wrap your whole code in a `xpcall`: `xpcall(func, candran.messageHandler)`.

* ```candran.messageHandler(message[, noTraceback])```: the error message handler used by Candran. Given `message` the Lua error string, returns full Candran traceback where soure files and lines are rewritten to their Candran source. You can use it as is in xpcall as a message handler. If `noTraceback` is `true`, Candran will only rewrite `message` and not add a new traceback.

Also note that the Candran message handler will add a new, rewritten, stacktrace to the error message; it can't replace the default Lua one. You will therefore see two stacktraces when raising an error, the last one being the Lua one and can be ignored.

##### Package searching helpers
Candran comes with a custom package searcher which will automatically find, preprocesses and compile ```.can``` files.

If you want to use Candran in your project without worrying about compiling the files, you can simply call

```lua
require("candran").setup()
```

at the top of your main Lua file. If a Candran file is found when you call ```require()```, it will be automatically compiled and loaded. If both a Lua and Candran file match a module name, the Candran file will be loaded.

* ```candran.searcher(modpath)```: Candran package searcher function. Use the existing package.path.
* ```candran.setup()```: register the Candran package searcher (if not already done), and return the `candran` table.

##### Available compiler & preprocessor options
You can give arbitrary options to the compiler and preprocessor, but Candran already provide and uses these with their associated default values:

```lua
target = "lua53" -- compiler target. "lua53", "lua52", "luajit" or "lua51" (default is automatically selected based on the Lua version used).
indentation = "" -- character(s) used for indentation in the compiled file.
newline = "\n" -- character(s) used for newlines in the compiled file.
variablePrefix = "__CAN_" -- Prefix used when Candran needs to set a local variable to provide some functionality (example: to load LuaJIT's bit lib when using bitwise operators).
mapLines = true -- if true, compiled files will contain comments at the end of each line indicating the associated line and source file. Needed for error rewriting.
chunkname = "nil" -- the chunkname used when running code using the helper functions and writing the line origin comments. Candran will try to set it to the original filename if it knows it.
rewriteErrors = true -- true to enable error rewriting when loading code using the helper functions. Will wrap the whole code in a xpcall().
```

You can change the defaults used for these variables in the table `candran.default`.

There are also a few function-specific options available, see the preprocessor functions documentation for more information.

### Compiling the library
The Candran library itself is written is Candran, so you have to compile it with an already compiled Candran library.

The compiled _candran.lua_ should include every Lua library needed to run it. You will still need to install LPegLabel.

This command will use the precompilled version of this repository (_candran.lua_) to compile _candran.can_ and write the result in _candran.lua_:

````
canc candran.can
````

You can then run the tests on your build:

````
cd test
lua test.lua ../candran.lua
````
