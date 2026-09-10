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

local class = require "class"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.make)

function hookLoad()
	local Birther = require "engine.Birther"
	local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
	local ActorTalents = require "engine.interface.ActorTalents"
	local WorldAchievements = require "mod.class.interface.WorldAchievements"
	local PartyLore = require "mod.class.interface.PartyLore"

	WorldAchievements:loadDefinition("/data-ashes-urhrok/achievements/")

	ActorTalents:loadDefinition("/data-ashes-urhrok/talents/misc/races.lua")
	ActorTalents:loadDefinition("/data-ashes-urhrok/talents/corruptions/corruptions.lua")
	ActorTemporaryEffects:loadDefinition("/data-ashes-urhrok/timed_effects.lua")
	Birther:loadDefinition("/data-ashes-urhrok/birth/doomelf.lua")
	Birther:loadDefinition("/data-ashes-urhrok/birth/races_cosmetic.lua")
	Birther:loadDefinition("/data-ashes-urhrok/birth/corrupted.lua")
	PartyLore:loadDefinition("/data-ashes-urhrok/lore/demon.lua")
end

function hookEntityLoadList(self, data)
	if type(game) ~= "table" then return end

	if data.file == "/data/general/objects/objects.lua" then
		self:loadList("/data-ashes-urhrok/general/objects/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/npcs/major-demon.lua" then
		self:loadList("/data-ashes-urhrok/general/npcs/major-demon.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/npcs/aquatic_demon.lua" then
		self:loadList("/data-ashes-urhrok/general/npcs/aquatic-demon.lua", data.no_default, data.res, data.mod, data.loaded)
	end
	
end

function hookObjectDescWielder(self, data)
	data.compare_fields(data.w, data.compare_with, data.field, "artifact_power_obsidian", "%+d", _t"Shadow Power: ")
end

local demon_statues_zones = {
	["old-forest"] = 25,
	["daikara"] = 25,
	["maze"] = 25,
	["crypt-kryl-feijan"] = 40,
	["reknor"] = 25,
	["eruan"] = 25,
	["valley-moon-caverns"] = 100,
	["mark-spellblaze"] = 70,

	-- Embers of Rage
	["orcs+ritch-hive"] = {percent = 50, forbid={4}},
	["orcs+cave-hatred"] = 50,
	["orcs+internment-camp"] = {percent = 25, forbid={1}},
	["orcs+krimbul"] = {percent = 32, forbid={3}},
	["orcs+lost-city"] = {percent = 70, forbid={3}},
	["orcs+sunwall-observatory"] = {percent = 50, forbid={3}},
	["orcs+ureslak-host"] = 32,
	["orcs+yeti-caves"] = 32,
}

local fire_haven_zones = {
	["charred-scar"] = 100,
	["daikara"] = 25,
	["scintillating-caves"] = 25,
	["vor-pride"] = 40,
	["eruan"] = 25,
	["valley-moon-caverns"] = 100,
	["mark-spellblaze"] = 100,
}

function hookZoneLoadEvents(self, data)
	if demon_statues_zones[data.zone] then
		local d = demon_statues_zones[data.zone]
		if type(d) ~= "table" then d = {percent=d} end
		data.events[#data.events+1] = {name="ashes-urhrok+demon-statue", minor=true, percent=d.percent, forbid=d.forbid}
	end
	if fire_haven_zones[data.zone] then data.events[#data.events+1] = {name="ashes-urhrok+fire-haven", minor=true, percent=fire_haven_zones[data.zone]} end

	if data.zone == "infinite-dungeon" then return end
	for _, e in ipairs(data.events) do
		if e.name == "cultists" and type(e.percent) == "number" and e.percent < 27 then e.percent = 27 end
	end
end

function hookPossessorBirthBodies(self, data)
	if data.desc.subrace == "Doomelf" then
		data.extra_types.demon = true
		local m = {name="fire imp", base_list="mod.class.NPC:/data/general/npcs/minor-demon.lua"}
		if m then data.bodies[#data.bodies+1] = m end
		return true
	end
end
