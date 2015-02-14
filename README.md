Candran
=======
Candran is a dialect of the [Lua](http://www.lua.org) programming language which compiles to Lua. It adds a preprocessor and several useful syntax additions.

Candran code example :

````lua
#import("lib.thing")
#local debug = args.debug or false

local function debugArgs(func)
	return function(...)
		#if debug then
			for _,arg in pairs({...}) do
				print(arg, type(arg))
			end
		#end
		return func(...)
	end
end

@debugArgs
local function calculate()
	local result = thing.do()
	result += 25
	return result
end

print(calculate())
````

The language
------------
### Preprocessor
Before compiling, Candran's preprocessor is run. It execute every line starting with a _#_ (ignoring whitespace) as Candran code.
For example,

````lua
#if args.lang == "fr" then
	print("Bonjour")
#else
	print("Hello")
#end
````

Will output ````print("Bonjour")```` or ````print("Hello")```` depending of the "lang" argument passed to the preprocessor.

The preprocessor has access to the following variables :
* ````candran```` : the Candran library table.
* ````output```` : the preprocessor output string.
* ````import(module[, autoRequire])```` : a function which import a module. This is equivalent to use _require(module)_ in the Candran code, except the module will be embedded in the current file. _autoRequire_ (boolean, default true) indicate if the module should be automaticaly loaded in a local variable or not. If true, the local variable will have the name of the module.
* ````include(filename)```` : a function which copy the contents of the file _filename_ to the output.
* ````print(...)```` : instead of writing to stdout, _print(...)_ will write to the preprocessor output. For example, ````#print("hello()")```` will output ````hello()````.
* ````args```` : the arguments table passed to the compiler. Example use : ````withDebugTools = args["debug"]````.
* and every standard Lua library.

### Syntax additions
After the preprocessor is run the Candran code is compiled to Lua. The Candran code adds the folowing syntax to Lua :
##### New assignment operators
* ````var += nb````
* ````var -= nb````
* ````var *= nb````
* ````var /= nb````
* ````var ^= nb````
* ````var %= nb````
* ````var ..= str````

For example, a ````var += nb```` assignment will be compiled into ````var = var + nb````.

##### Decorators
Candran supports function decorators similar to Python. A decorator is a function returning another function, and allows easy function modification with this syntax :
````lua
@decorator
function name(...)
	...
end
````
This is equivalent to :
````lua
function name(...)
	...
end
name = decorator(name)
````
The decorators can be chained. Note that Candran allows this syntax for every variable, not only functions.

The library
-----------
### Command-line usage
The library can be used standalone :

*	````lua candran.lua````
	
	Display the information text (version and basic command-line usage).

*	````lua candran.lua <filename> [arguments]````
	
	Output to stdout the _filename_ Candran file, preprocessed (with _arguments_) and compiled to Lua.

	_arguments_ is of type ````--somearg value --anotherarg anothervalue ...````.

	* example uses :

		````lua candran.lua foo.can > foo.lua````

		preprocess and compile _foo.can_ and write the result in _foo.lua_.

		````lua candran.lua foo.can --verbose true | lua````

		preprocess _foo.can_ with _verbose_ set to _true_, compile it and execute it.

### Library usage
Candran can also be used as a normal Lua library. For example,
````lua
local candran = require("candran")

local f = io.open("foo.can")
local contents = f:read("*a")
f:close()

local compiled = candran.make(contents, { lang = "fr" })

load(compiled)()
````
Will load Candran, read the file _foo.can_, compile its contents with the argument _lang_ set to _"fr"_, and then execute the result.

The table returned by _require("candran")_ gives you access to :
* ````candran.VERSION```` : Candran's version string.
* ````candran.syntax```` : table containing all the syntax additions of Candran.
* ````candran.preprocess(code[, args])```` : return the Candran code _code_, preprocessed with _args_ as argument table.
* ````candran.compile(code)```` : return the Candran code compiled to Lua.
* ````candran.make(code[, args])```` : return the Candran code, preprocessed  with _args_ as argument table and compilled to Lua.

### Compiling the library
The Candran library itself is written is Candran, so you have to compile it with an already compiled Candran library.

This command will use the precompilled version of this repository (build/candran.lua) to compile _candran.can_ and write the result in _candran.lua_ :

````
lua build/candran.lua candran.can > candran.lua
````

You can then run the tests on your build :

````
cd tests
lua test.lua ../candran.lua
````