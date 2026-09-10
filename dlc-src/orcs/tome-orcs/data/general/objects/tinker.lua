-- ToME - Tales of Maj'Eyal:
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

local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

newEntity{
	define_as = "BASE_TINKER",
	power_source = {steam=true},
	type = "tinker", subtype="steamtech",
	display = "*", color=colors.SLATE,
	encumber = 0,
	material_level = 1,
	is_tinker = "steamtech",
	rarity = false,
	metallic = true,
	desc = _t[[Tinkers can be attached to normal items to improve them with steam power!]],
	cost = 1,
}

newEntity{ define_as = "BASE_SALVE",
	power_source = {nature=true, steam=true},
	type = "misc", subtype="salve",
	add_name = "#CHARM#",
	unided_name = _t"salve",
	display = "%", color=colors.GREEN,
	encumber = 1,
	not_in_stores = true,
	uses_medical_injector = true,
	desc = _t[[Medical salve.]],
	cost = 1,
}

load("/data-orcs/general/objects/tinkers/smith.lua")
load("/data-orcs/general/objects/tinkers/mechanical.lua")
load("/data-orcs/general/objects/tinkers/electricity.lua")
load("/data-orcs/general/objects/tinkers/therapeutics.lua")
load("/data-orcs/general/objects/tinkers/chemistry.lua")
load("/data-orcs/general/objects/tinkers/explosive.lua")

--[[
local tinkers = {}
for i, e in ipairs(loading_list) do if e.tinker_category then
	local name = e.define_as:sub(1, #(e.define_as) - 1):sub(8)
	tinkers[e.tinker_category] = tinkers[e.tinker_category] or {}
	tinkers[e.tinker_category][name] = e
end end

local slots = {nb=0}
for cat, list in pairs(tinkers) do for name, e in pairs(list) do
	local slot = "--not tinkerable--"
	if e.on_type and e.on_subtype then slot = e.on_type.."/"..e.on_subtype
	elseif e.on_type then slot = e.on_type
	elseif e.on_slot then slot = e.on_slot
	end
	slots[slot] = slots[slot] or {nb=0}
	slots[slot][name] = true
	slots[slot].nb = slots[slot].nb + 1
	slots.nb = slots.nb + 1
end end

print("===")
table.print(tinkers)
print("===")
table.print(slots)
os.crash()
--]]
