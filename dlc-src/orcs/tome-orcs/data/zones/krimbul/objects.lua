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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

load("/data-orcs/general/objects/objects.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "tattered paper scrap", lore="krimbul-"..i,
	desc = _t[[A paper scrap.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_HELM", define_as = "NEKTOSH_HELM",
	power_source = {arcane=true},
	unique = true,
	name = "Visage of Nektosh", image = "object/artifact/visage_of_nektosh.png",
	unided_name = _t"horned helm",
	desc = _t[[You always thought his horns looked kind of stupid, to be honest.]],
	moddable_tile = "special/visage_of_nektosh",
	require = { stat = { mag=12 } },
	level_range = {15, 25},
	rarity = false,
	cost = 300,
	material_level = 2,
	special_desc = function(self) return _t"Increases your maximum stacks of Death Momentum by 1." end,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4,},
		combat_def = 4,
		combat_armor = 8,
		fatigue = 6,
		resists = { [DamageType.DARKNESS] = 10},
		talents_types_mastery = { ["race/whitehooves"] = 0.2, },
		melee_project={[DamageType.PHYSICALBLEED] = 15}, --Gore them with your horns!
		DM_Bonus = 1,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Whitehoof" then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder", "movement_speed"}, 0.1)
			self:specialWearAdd({"wielder","combat_spellpower"}, 10)
			self:specialWearAdd({"wielder","combat_dam"}, 10)
			game.logPlayer(who, "#DARK_BLUE#This helm is your birthright! Deathright? Whichever.")
		end
	end,
}

