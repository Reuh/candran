package = "Candran"

version = "0.3.1-1"

description = {
	summary = "A simple Lua dialect and preprocessor.",
	detailed = [[
		Candran is a dialect of the Lua 5.3 programming language which compiles to Lua 5.3 and Lua 5.1/LuaJit. It adds a preprocessor and several useful syntax additions.
		Unlike Moonscript, Candran tries to stay close to the Lua syntax.
	]],
	license = "MIT",
	homepage = "https://github.com/Reuh/Candran",
	--issues_url = "https://github.com/Reuh/Candran", -- LuaRocks 3.0
	maintainer = "Étienne 'Reuh' Fildadut <fildadut@reuh.eu>",
	--labels = {} -- LuaRocks 3.0
}

source = {
	url = "git://github.com/Reuh/Candran",
	tag = "v0.3.1"
}

dependencies = {
	"lua >= 5.1",
	"lpeglabel >= 1.0.0"
}

build = {
	type = "builtin",
	modules = {
		candran = "candran.lua"
	},
	install = {
		bin = { "bin/can", "bin/canc" }
	}
	--copy_directories = { "doc", "test" }
}
