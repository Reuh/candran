Candran
=======
Candran is a dialect of the [Lua 5.3](http://www.lua.org) programming language which compiles to Lua 5.3 and Lua 5.1/LuaJit. It adds several useful syntax additions which aims to make Lua faster and easier to write, and a simple preprocessor.

Unlike Moonscript, Candran tries to stay close to the Lua syntax, and existing Lua code can run on Candran unmodified.

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
	hey = true,

	newHop = :(foo, thing) -- short function declaration, with self
		@hey = thing(foo) -- @ as an alias for self
	end,

	selfReference = () -- short function declaration, without self
		return a -- no need for a prior local declaration using let
	end
}

a:newHop(42, (foo)
	return "something " .. foo
end)

local list = [ -- table comprehension (kind of)
	for i=1, 10 do
		if i%2 == 0 then
			continue -- continue keyword
		end
		i -- implicit push
	end
]

local count = [for i=1,10 i] -- single line statements

local a = if condition then "one" else "two" end -- statement as expressions

````

Candran is released under the MIT License (see ```LICENSE``` for details).

#### Quick setup
Install Candran automatically using LuaRocks: ```sudo luarocks install rockspec/candran-0.6.2-1.rockspec```.

Or manually install LPegLabel (```luarocks install LPegLabel```, version 1.5 or above), download this repository and use Candran through the scripts in ```bin/``` or use it as a library with the self-contained ```candran.lua```.

You can register the Candran package searcher in your main Lua file (`require("candran").setup()`) and any subsequent `require` call in your project will automatically search for Candran modules.

#### Editor support
Most editors should be able to use their existing Lua support for Candran code. If you want full support for the additional syntax in your editor:
* **Atom**: [language-candran](https://atom.io/packages/language-candran) support the full Candran syntax

The language
------------
### Syntax additions
After the preprocessor is run the Candran code is compiled to Lua. Candran code adds the folowing syntax to Lua:

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

If you feel like writing hard to understand code, right and left operator can be used at the same time.

**Please note** that the Lua code `a=-1` will be compiled into `a = 1 - a` and not `a = -1`! Write good code, write spaced code: `a = -1` works as expected.

##### Default function parameters
```lua
function foo(bar = "default", other = thing.do())
    -- stuff
end
```
If an argument isn't provided or ```nil``` when the function is called, it will be automatically set to a default value.

It is equivalent to doing ```if arg == nil then arg = default end``` for each argument at the start of the function.

The default values can be complete Lua expressions, and will be evaluated each time the function is run.

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

A ```:``` can prefix the parameters paranthesis to automatically add a ```self``` parameter.

##### `let` variable declaration
```lua
let a = {
	foo = function()
		print(type(a)) -- table
	end
}
```

Similar to ```local```, but the variable will be declared *before* the assignemnt (i.e. it will compile into ```local a; a = value```), so you can access it from functions defined in the value.

Can also be used as a shorter name for ```local```.

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

This keyword is mainly useful when used through implicit `push` with table comprehension and statement expressions.

**Please note** that, in order to stay compatible with vanilla Lua syntax, any `push` immediatly followed by a `"string expression"`, `{table expression}` or `(paranthesis)` will be interpreted as a function call. It's recommended to use the implicit `push` instead (when possible).

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

**Please note** that this doesn't work with `v()` function calls, because these are already valid statements. Use `push v()` instead.

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

Candran allows to use `if`, `do`, `while`, `repeat` and `for` statements as expressions. Their content will be run as if they were run in a separate function which is immediatly run.

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

The table generation function also have access to the `self` (or its alias `@`) variable, which is the table which is being created, so you can set arbitrary fields of the table.

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

`if`, `elseif`, `for`, and `while` statements can be writtent without `do`, `then` or `end`, in which case they contain a single statement.

##### Suffixable string and table litterals
_Not in the latest release, install the `candran-scm-1.rockspec` version if you want this feature._
```lua
"some text":upper() -- same as ("some text"):upper() in Lua
"string".upper -- the actual string.upper function. "string"["upper"] also works.
-- Also works with calls, for example "string"(), but it isn't really useful for strings.

{thing = 3}.thing -- 3. Also works with tables!
[for i=0,5 do i*i end][3] -- 9. And table comprehensions!

-- Functions calls have priority:
someFunction"thing":upper() -- same as (someFunction("thing")):upper() (i.e., the way it would be parsed by Lua)
```

String litterals, table litterals, and comprehensions can be suffixed with `:` method calls, `.` or `[` indexing, or `(` functions calls, without needing to be enclosed in parantheses.

*Please note*, that "normal" functions calls have priority over this syntax, in order to maintain Lua compatibility.

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

The preprocessor has access to the following variables :
* ````candran```` : the Candran library table.
* ````output```` : the current preprocessor output string.
* ````import(module[, [options])```` : a function which import a module. This should be equivalent to using _require(module)_ in the Candran code, except the module will be embedded in the current file. _options_ is an optional preprocessor arguments table for the imported module (current preprocessor arguments will be inherited). Options specific to this function: ```loadLocal``` (default ```true```): ```true``` to automatically load the module into a local variable (i.e. ```local thing = require("module.thing")```); ```loadPackage``` (default ```true```): ```true``` to automatically load the module into the loaded packages table (so it will be available for following ```require("module")``` calls).
* ````include(filename)```` : a function which copy the contents of the file _filename_ to the output.
* ````write(...)```` : write to the preprocessor output. For example, ````#print("hello()")```` will output ````hello()```` in the final file.
* ```placeholder(name)``` : if the variable _name_ is defined in the preprocessor environement, its content will be inserted here.
* ````...```` : each arguments passed to the preprocessor is directly available.
* and every standard Lua library.

Compile targets
---------------
Candran is based on the Lua 5.3 syntax, but can be compiled to both Lua 5.3 and Lua 5.1/LuaJit.

To chose a compile target, set the ```target``` option to ```lua53``` (default) or ```luajit``` in the option table when using the library or the command line tools.

Lua 5.3 specific syntax (bitwise operators, integer division) will automatically be translated in valid Lua 5.1 code, using LuaJIT's ```bit``` library if necessary. Unless you require LuaJIT's library, you won't be able to use bitwise operators with simple Lua 5.1.

Usage
-----
### Command-line usage
The library can be used standalone through the ```canc``` and ```can``` utility:

*	````canc````

	Display the information text (version and basic command-line usage).

*	````canc [options] filename...````

	Preprocess and compile each  _filename_ Candran files, and creates the assiociated ```.lua``` files in the same directories.

	_options_ is of type ````-somearg -anotherarg thing=somestring other=5 ...````, which will generate a Lua table ```{ somearg = true, anotherarg = true, thing = "somestring", other = 5 }```.

    You can choose to use another directory where files should be written using the ```dest=destinationDirectory``` argument.

    ```canc``` can write to the standard output instead of creating files using the ```-print``` argument.

	You can choosed to run only the preprocessor or compile using the ```-preprocess``` and ```-compile``` flags.

	The ```-ast``` flag is also available for debugging, and will disable preprocessing, compiling and file writing, and instead directly dump the AST generated from the input file(s) to stdout.

	* example uses :

		````canc foo.can````

		preprocess and compile _foo.can_ and write the result in _foo.lua_.

		````canc indentation="  " foo.can````

		preprocess and compile _foo.can_ with 2-space indentation (readable code!) and write the result in _foo.lua_.

		````canc foo.can -verbose -print | lua````

		preprocess _foo.can_ with _verbose_ set to _true_, compile it and execute it.

*   ```can```

    Start a simplisitic Candran REPL.

*	````canc [options] filename````

    Preprocess, compile and run _filename_ using the options provided.

	This will automatically register the Candran package searcher so required file will be compiled as they are needed.

	This command will use error rewriting if enabled.

### Library usage
Candran can also be used as a Lua library. For example,
````lua
local candran = require("candran")

local f = io.open("foo.can")
local contents = f:read("*a")
f:close()

local compiled = candran.make(contents, { lang = "fr" })

load(compiled)()

-- or simpler...
candran.dofile("foo.can")
````
Will load Candran, read the file _foo.can_, compile its contents with the argument _lang_ set to _"fr"_, and then execute the result.

The table returned by _require("candran")_ gives you access to :

##### Compiler & preprocessor API
* ````candran.VERSION```` : Candran's version string.
* ````candran.preprocess(code[, options])```` : return the Candran code _code_, preprocessed with _options_ as options table.
* ````candran.compile(code[, options])```` : return the Candran code compiled to Lua with _options_ as the option table.
* ````candran.make(code[, options])```` : return the Candran code, preprocessed and compiled with _options_ as options table.

##### Code loading helpers
* ```candran.loadfile(filepath, env, options)``` : Candran equivalent to the Lua 5.3's loadfile funtion. Will rewrite errors by default.
* ```candran.load(chunk, chunkname, env, options)``` : Candran equivalent to the Lua 5.3's load funtion. Will rewrite errors by default.
* ```candran.dofile(filepath, options)``` : Candran equivalent to the Lua 5.3's dofile funtion. Will rewrite errors by default.

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

* ```candran.messageHandler(message)``` : The error message handler used by Candran. Use it in xpcall to rewrite stacktraces to display Candran source file lines instead of compiled Lua lines.

##### Package searching helpers
Candran comes with a custom package searcher which will automatically find, preprocesses and compile ```.can``` files. If you want to use Candran in your project without worrying about
compiling the files, you can simply call

```lua
require("candran").setup()
```

at the top of your main Lua file. If a Candran is found when you call ```require()```, it will be automatically compiled and loaded. If both a Lua and Candran file match a module name, the Candran
file will be loaded.

* ```candran.searcher(modpath)``` : Candran package searcher function. Use the existing package.path.
* ```candran.setup()``` : Register the Candran package searcher, and return the `candran` table.

##### Available compiler & preprocessor options
You can give arbitrary options which will be gived to the preprocessor, but Candran already provide and uses these with their associated default values:

```lua
target = "lua53" -- Compiler target. "lua53" or "luajit".
indentation = "" -- Character(s) used for indentation in the compiled file.
newline = "\n" -- Character(s) used for newlines in the compiled file.
variablePrefix = "__CAN_" -- Prefix used when Candran needs to set a local variable to provide some functionality (example: to load LuaJIT's bit lib when using bitwise operators).
mapLines = true -- If true, compiled files will contain comments at the end of each line indicating the associated line and source file. Needed for error rewriting.
chunkname = "nil" -- The chunkname used when running code using the helper functions and writing the line origin comments. Candran will try to set it to the original filename if it knows it.
rewriteErrors = true -- True to enable error rewriting when loading code using the helper functions. Will wrap the whole code in a xpcall().
```

You can change these values in the table `candran.default`.

There are also a few function-specific options available, see the associated functions documentation for more information.

### Compiling the library
The Candran library itself is written is Candran, so you have to compile it with an already compiled Candran library.

The compiled _candran.lua_ should include every Lua library needed to run it. You will still need to install LPegLabel.

This command will use the precompilled version of this repository (candran.lua) to compile _candran.can_ and write the result in _candran.lua_ :

````
canc candran.can
````

You can then run the tests on your build :

````
cd tests
lua test.lua ../candran.lua
````
