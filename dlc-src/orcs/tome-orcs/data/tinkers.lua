-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local base_newRecipe = newRecipe

function newRecipe(t) t.base_category = _t"smith" return base_newRecipe(t) end
load("/data-orcs/tinkers/smith.lua")
function newRecipe(t) t.base_category = _t"mechanical" return base_newRecipe(t) end
load("/data-orcs/tinkers/mechanical.lua")
function newRecipe(t) t.base_category = _t"electricity" return base_newRecipe(t) end
load("/data-orcs/tinkers/electricity.lua")
function newRecipe(t) t.base_category = _t"therapeutics" return base_newRecipe(t) end
load("/data-orcs/tinkers/therapeutics.lua")
function newRecipe(t) t.base_category = _t"chemistry" return base_newRecipe(t) end
load("/data-orcs/tinkers/chemistry.lua")
function newRecipe(t) t.base_category = _t"explosives" return base_newRecipe(t) end
load("/data-orcs/tinkers/explosive.lua")

--[[
local tinkers = {}
for id, t in pairs(mod.class.interface.PartyTinker.__tinkers_ings) do
	tinkers[t.base_category] = tinkers[t.base_category] or {}
	local lvl = -1
	if t.talents and t.talents["T_"..t.base_category:upper()] then lvl = t.talents["T_"..t.base_category:upper()] end
	tinkers[t.base_category][lvl] = tinkers[t.base_category][lvl] or {}
	table.insert(tinkers[t.base_category][lvl], id)
end
table.print(tinkers)
os.crash()
--]]
