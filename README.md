Candran
=======
Candran is a dialect of the [Lua 5.3](http://www.lua.org) programming language which compiles to Lua 5.3 and Lua 5.1/LuaJit. It adds a preprocessor and several useful syntax additions.

Unlike Moonscript, Candran tries to stay close to the Lua syntax.

````lua
#import("lib.thing")
#local debug or= false

local function calculate(toadd=25)
	local result = thing.do()
	result += toadd
    #if debug then
        print("Did something")
    #end
	return result
end

local a = {
	hey = true,

	newHop = :(foo, thing)
		@hey = thing(foo)
	end
}

a:newHop(42, (foo)
	return "something " .. foo
end)

````

#### Quick setup
Install LPegLabel (```luarocks install LPegLabel```), download this repository and use Candran through the scripts in ```bin/``` or use it as a library with the self-contained ```candran.lua```.

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
* ````import(module[, [options])```` : a function which import a module. This should be equivalent to using _require(module)_ in the Candran code, except the module will be embedded in the current file. _options_ is an optional preprocessor arguments table for the imported module (current preprocessor arguments will be inherited). Options specific to this function: ```loadLocal``` (default ```true```): ```true``` to automatically load the module into a local variable (i.e. ```local thing = require("module.thing")```); ```loadPackage``` (default ```true```): ```true``` to automatically load the module into the loaded packages table (so it will be available for following ```require("module")``` calls).
* ````include(filename)```` : a function which copy the contents of the file _filename_ to the output.
* ````write(...)```` : write to the preprocessor output. For example, ````#print("hello()")```` will output ````hello()```` in the final file.
* ```placeholder(name)``` : if the variable _name_ is defined in the preprocessor environement, its content will be inserted here.
* ````...```` : each arguments passed to the preprocessor is directly available.
* and every standard Lua library.

### Syntax additions
After the preprocessor is run the Candran code is compiled to Lua. The Candran code adds the folowing syntax to Lua :

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

##### Default function parameters
```lua
function foo(bar = "default", other = thing.do())
    -- stuff
end
```
If an argument isn't provided or ```nil``` when the function is called, it will be automatically set to a default value.

It is equivalent to doing ```if arg == nil then arg = default end``` for each argument at the start of the function.

The default values can be complete Lua expressions, and will be evaluated each time the function is run.

##### @ self aliases
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

Compile targets
---------------
Candran is based on the Lua 5.3 syntax, but can be compiled to both Lua 5.3 and Lua 5.1/LuaJit.

To chose a compile target, set the ```target``` option to ```lua53``` (default) or ```luajit``` in the option table when using the library or the command line tools.

Lua 5.3 specific syntax (bitwise operators, integer division) will automatically be translated in valid Lua 5.1 code, using LuaJIT's ```bit``` library if necessary.

The library
-----------
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

	* example uses :

		````canc foo.can````

		preprocess and compile _foo.can_ and write the result in _foo.lua_.

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
* ```candran.setup()``` : Register the Candran package searcher.

##### Available compiler & preprocessor options
You can give arbitrary options which will be gived to the preprocessor, but Candran already provide and uses these with their associated default values:

```lua
target = "lua53" -- Compiler target. "lua53" or "luajit".
indentation = "" -- Character(s) used for indentation in the compiled file.
newline = "\n" -- Character(s) used for newlines in the compiled file.
requirePrefix = "CANDRAN_" -- Prefix used when Candran needs to require an external library to provide some functionality (example: LuaJIT's bit lib when using bitwise operators).
mapLines = true -- If true, compiled files will contain comments at the end of each line indicating the associated line and source file. Needed for error rewriting.
chunkname = "nil" -- The chunkname used when running code using the helper functions and writing the line origin comments. Candran will try to set it to the original filename if it knows it.
rewriteErrors = true -- True to enable error rewriting when loading code using the helper functions. Will wrap the whole code in a xpcall().
```

There are also a few function-specific options available, see the associated functions documentation for more information.

### Compiling the library
The Candran library itself is written is Candran, so you have to compile it with an already compiled Candran library.

The compiled _candran.lua_ should include every Lua library needed to run it. You will still need to install LPegLabel.

This command will use the precompilled version of this repository (candran.lua) to compile _candran.can_ and write the result in _candran.lua_ :

````
canc candran.can
````

The Candran build included in this repository were made using the ```mapLines=false``` options.

You can then run the tests on your build :

````
cd tests
lua test.lua ../candran.lua
````
