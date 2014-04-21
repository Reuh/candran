Lune
====

Lune is a simple [Lua](http://www.lua.org) dialect, which compile to normal Lua. It adds a preprocessor and some usefull syntax additions to the language, like += operators.

Lune code example :

````lua
#local language = args.lang or "en"
local a = 5
a += 3
#if language == "fr" then
	print("Le resultat est "..a)
#elseif language == "en" then
	print("The result is "..a)
#end
````

This code will compile diffrently depending on the "lang" argument you pass to the compiler.

Syntax details
--------------
### Preprocessor
Before compiling, a preprocessor is run; it search the lines which start with a # and execute the Lune code after it.
For example,

````lua
#if args.lang == "fr" then
	print("Ce programme a ete compile en francais")
#else
	print("This program was compiled in english")
#end
````

Output ````print("Ce programme a ete compile en francais")```` or ````print("This program was compiled in english")```` depending of the "lang" argument.

In the preprocessor, the following global variables are available :
* ````lune```` : the Lune library table
* ````output```` : the preprocessor output string
* ````include(filename)```` : a function which copy the contents of the file filename to the output and add some code so it is equivalent to :

	````lua
	filname = require("filename") or filename
	````

	except that the required code is actually embedded in the file.
* ````rawInclude(filename)```` : a function which copy the contents of the file filename to the output, whithout modifications
* ````print(...)```` : instead of writing to stdout, write to the preprocessor output; for example,
	
	````lua
	local foo = "hello"
	#print("foo ..= ' lune')")
	print(foo)
	````

	will output :

	````lua
	local foo = "hello"
	foo = foo .. ' lune'
	print(foo)
	````

* ````args```` : the arguments table passed to the compiler. Example use :

	````lua
	argumentValue = args["argumentName"]
	````

* And all the Lua standard libraries.

### Compiler
After the preprocessor, the compiler is run; it translate Lune syntax to Lua syntax. What is translated to what :
* ````var += nb````		>	````var = var + nb````
* ````var -= nb````		>	````var = var - nb````
* ````var *= nb````		>	````var = var * nb````
* ````var /= nb````		>	````var = var / nb````
* ````var ^= nb````		>	````var = var ^ nb````
* ````var %= nb````		>	````var = var % nb````
* ````var ..= str````	>	````var = var .. str````
* ````var++````			>	````var = var + 1````
* ````var--````			>	````var = var - 1````

Command-line usage
------------------
The library can be used standalone :

	lua lune.lua

Display a simple information text (version & basic command-line usage).

	lua lune.lua <input> [arguments]

Output to stdout the Lune code compiled in Lua.
* arguments :
	* input : input file name
	* arguments : arguments to pass to the preprocessor (every argument is of type ````--<name> <value>````)
* example uses :

		lua lune.lua foo.lune > foo.lua

	compile foo.lune and write the result in foo.lua

		lua lune.lua foo.lune --verbose true | lua

	compile foo.lune with "verbose" set to true and execute it

Library usage
-------------
Lune can also be used as a normal Lua library. For example,
````lua
local lune = require("lune")

local f = io.open("foo.lune")
local contents = f:read("*a")
f:close()

local compiled = lune.make(contents, { lang = "fr" })

load(compiled)()
````
will load Lune, read the file foo.lune, compile its contents with the argument "lang" set to "fr", and then execute the result.

Lune API :
* ````lune.VERSION```` : version string
* ````lune.syntax```` : syntax table used when compiling (TODO : need more explainations)
* ````lune.preprocess(code[, args])```` : return the Lune code preprocessed with args as argument table
* ````lune.compile(code)```` : return the Lune code compiled to Lua
* ````lune.make(code[, args])```` : return the Lune code preprocessed & compilled to Lua with args as argument table

Compiling Lune
--------------
Because the Lune compiler itself is written in Lune, you have to compile it with an already compiled version of Lune. This command will use the precompilled version in build/lune.lua to compile lune.lune and write the result in lune.lua :

````
lua build/lune.lua lune.lune > lune.lua
````

You can then test your build :

````
cd tests
lua test.lua ../lune.lua
````