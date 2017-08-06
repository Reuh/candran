Candran
=======
Candran is a dialect of the [Lua 5.3](http://www.lua.org) programming language which compiles to Lua 5.3 and Lua 5.1/LuaJit. It adds a preprocessor and several useful syntax additions.

Unlike Moonscript, Candran tries to stay close to the Lua syntax.

Candran code example :

````lua
#import("lib.thing")
#local debug = debug or false

local function calculate(toadd=25)
	local result = thing.do()
	result += toadd
    #if debug then
        print("Did something")
    #end
	return result
end

print(calculate())
````

##### Quick setup
Install LPegLabel (```luarocks install LPegLabel```), download this repository and use Candran through ```canc.lua``` or ```candran.lua```.

The language
------------
### Preprocessor
Before compiling, Candran's preprocessor is run. It execute every line starting with a _#_ (ignoring whitespace) as Candran code.
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
* ````import(module[, [args, autoRequire]])```` : a function which import a module. This is equivalent to use _require(module)_ in the Candran code, except the module will be embedded in the current file. _args_ is an optional preprocessor arguments table for the imported module (current preprocessor arguments will be inherited). _autoRequire_ (boolean, default true) indicate if the module should be automaticaly loaded in a local variable or not. If true, the local variable will have the name of the module.
* ````include(filename)```` : a function which copy the contents of the file _filename_ to the output.
* ````write(...)```` : write to the preprocessor output. For example, ````#print("hello()")```` will output ````hello()```` in the final file.
* ```placeholder(name)``` : if the variable _name_ is defined in the preprocessor environement, its content will be inserted here.
* ````...```` : each arguments passed to the preprocessor is directly available.
* and every standard Lua library.

### Syntax additions
After the preprocessor is run the Candran code is compiled to Lua. The Candran code adds the folowing syntax to Lua :
##### New assignment operators
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

##### Default function parameters
```lua
function foo(bar = "default", other = thing.do())
    -- stuff
end
```
If an argument isn't provided or ```nil``` when the function is called, it will be automatically set to a default value.

It is equivalent to doing ```if arg == nil then arg = default end``` for each argument at the start of the function.

The default values can be complete Lua expressions, and will be evaluated each time the function is run.

Compile targets
---------------
Candran is based on the Lua 5.3 syntax, but can be compiled to both Lua 5.3 and Lua 5.1/LuaJit.

To chose a compile target, either explicitly give ```lua53``` or ```luajit``` as a second argument to ```candran.compile```, or set the ```target``` preprocessor argument when using ```candran.make``` or the command line tools.

Lua 5.3 specific syntax (bitwise operators, integer division) will automatically be translated in valid Lua 5.1 code, using LuaJit's ```bit``` library if necessary.

The library
-----------
### Command-line usage
The library can be used standalone through the ```canc``` utility:

*	````lua canc.lua````

	Display the information text (version and basic command-line usage).

*	````lua canc.lua [arguments] filename...````

	Preprocess and compile each  _filename_ Candran files, and creates the assiociated ```.lua``` files in the same directories.

	_arguments_ is of type ````-somearg -anotherarg thing=somestring other=5 ...````, which will generate a Lua table ```{ somearg = true, anotherarg = true, thing = "somestring", other = 5 }```.

    You can choose to use another directory where files should be written using the ```dest=destinationDirectory``` argument.

    ```canc``` can write to the standard output instead of creating files using the ```-print``` argument.

	* example uses :

		````lua canc.lua foo.can````

		preprocess and compile _foo.can_ and write the result in _foo.lua_.

		````lua canc.lua foo.can -verbose -print | lua````

		preprocess _foo.can_ with _verbose_ set to _true_, compile it and execute it.

### Library usage
Candran can also be used as a Lua library. For example,
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
* ````candran.preprocess(code[, args])```` : return the Candran code _code_, preprocessed with _args_ as argument table.
* ````candran.compile(code[, target])```` : return the Candran code compiled to Lua.
* ````candran.make(code[, args])```` : return the Candran code, preprocessed  with _args_ as argument table and compilled to Lua.

### Compiling the library
The Candran library itself is written is Candran, so you have to compile it with an already compiled Candran library.

The compiled _candran.lua_ should include every Lua library needed to run it. You will still need to install LPegLabel.

This command will use the precompilled version of this repository (candran.lua) to compile _candran.can_ and write the result in _candran.lua_ :

````
lua canc.lua candran.can
````

You can then run the tests on your build :

````
cd tests
lua test.lua ../candran.lua
````
