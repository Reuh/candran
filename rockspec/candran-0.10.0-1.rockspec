rockspec_format = "3.0"

package = "candran"

version = "0.10.0-1"

description = {
	summary = "A simple Lua dialect and preprocessor.",
	detailed = [[
		Candran is a dialect of the Lua 5.3 programming language which compiles to Lua 5.3, LuaJIT and Lua 5.1 compatible code. It adds several useful syntax additions which aims to make Lua faster and easier to write, and a simple preprocessor.
		Unlike Moonscript, Candran tries to stay close to the Lua syntax, and existing Lua code should be able to run on Candran unmodified.
	]],
	license = "MIT",
	homepage = "https://github.com/Reuh/candran",
	issues_url = "https://github.com/Reuh/candran",
	maintainer = "Étienne 'Reuh' Fildadut <fildadut@reuh.eu>",
	labels = { "lpeg", "commandline" }
}

source = {
	url = "git://github.com/Reuh/candran",
	tag = "v0.10.0"
}

dependencies = {
	"lua >= 5.1",
	"lpeglabel >= 1.5.0"
}

build = {
	type = "builtin",
	modules = {
		candran = "candran.lua"
	},
	install = {
		bin = { "bin/can", "bin/canc" }
	}
}
