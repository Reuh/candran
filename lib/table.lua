--[[
Table utility by Thomas99.

LICENSE :
Copyright (c) 2015 Thomas99

This software is provided 'as-is', without any express or implied warranty. 
In no event will the authors be held liable for any damages arising from the 
use of this software.

Permission is granted to anyone to use this software for any purpose, including 
commercial applications, and to alter it and redistribute it freely, subject 
to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not 
	claim that you wrote the original software. If you use this software in a 
	product, an acknowledgment in the product documentation would be appreciated 
	but is not required.

	2. Altered source versions must be plainly marked as such, and must not be 
	misrepresented as being the original software.

	3. This notice may not be removed or altered from any source distribution.
]]

-- Diverses fonctions en rapport avec les tables.
-- v0.1.0
--
-- Changements :
-- - v0.1.0 :
-- 		Première version versionnée. Il a dû se passer des trucs avant mais j'ai pas noté :p

-- Copie récursivement la table t dans la table dest (ou une table vide si non précisé) et la retourne
-- replace (false) : indique si oui ou non, les clefs existant déjà dans dest doivent être écrasées par celles de t
-- metatable (true) : copier ou non également les metatables
-- filter (function) : filtre, si retourne true copie l'objet, sinon ne le copie pas
-- Note : les metatables des objets ne sont jamais re-copiées (mais référence à la place), car sinon lors de la copie
-- 		la classe de ces objets changera pour une nouvelle classe, et c'est pas pratique :p
function table.copy(t, dest, replace, metatable, filter, copied)
	local copied = copied or {}
	local replace = replace or false
	local metatable = (metatable==nil or metatable) and true
	local filter = filter or function(name, source, destination) return true end

	if type(t) ~= "table" then
		return t
	elseif copied[t] then -- si la table a déjà été copiée
		return copied[t]
	end

	local dest = dest or {} -- la copie

	copied[t] = dest -- on marque la table comme copiée

	for k, v in pairs(t) do
		if filter(k, t, dest) then
			if replace then
				dest[k] = table.copy(v, dest[k], replace, metatable, filter, copied)
			else
				if dest[k] == nil or type(v) == "table" then -- si la clef n'existe pas déjà dans dest ou si c'est une table à copier
					dest[k] = table.copy(v, dest[k], replace, metatable, filter, copied)
				end
			end
		end
	end

	-- copie des metatables
	if metatable then
		if t.__classe then
			setmetatable(dest, getmetatable(t))
		else
			setmetatable(dest, table.copy(getmetatable(t), getmetatable(dest), replace, filter))
		end
	end

	return dest
end

-- retourne true si value est dans la table
function table.isIn(table, value)
	for _,v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

-- retourne la longueur exacte d'une table (fonctionne sur les tables à clef)
function table.len(t)
	local len=0
	for i in pairs(t) do
		len=len+1
	end
	return len
end

-- Sépare str en éléments séparés par le pattern et retourne une table
function string.split(str, pattern)
	local t = {}
	local pos = 0

	for i,p in string.gmatch(str, "(.-)"..pattern.."()") do
		table.insert(t, i)
		pos = p
	end

	table.insert(t, str:sub(pos))

	return t
end