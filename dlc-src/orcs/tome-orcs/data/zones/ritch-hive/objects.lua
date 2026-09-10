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

newEntity{
	define_as = "SAND_RITCH_EGGS",
	type = "egg", subtype = "ritch",
	name = "pile of ritch eggs", image="terrain/ritch_eggs.png",
	desc = _t"A gross pile of eggs.",
	display = '*', color_r=255, color_g=100, color_b=50,
	special_minimap = {b=50, g=100, r=255},
	level_range={1,50}, rarity=false,
	no_decay = true,
	on_prepickup = function(self, who, id)
		game.zone.ritches_collected = game.zone.ritches_collected + 1
		if game.zone.ritches_collected >= 30 then
			who:setQuestStatus("orcs+ritch-hive", engine.Quest.COMPLETED, "collect")
		end
		game.bignews:easing(60, "inBack", "#YELLOW#You carefully collect some ritch eggs.")
		world:gainAchievement("ORCS_RITCH_EGGS_40", who)
		-- Remove from the map
		game.level.map:removeObject(who.x, who.y, id)
		return true
	end,
	auto_pickup = true,
}

newEntity{ base = "BASE_GAUNTLETS", 
	power_source = {nature=true, technique=true},
	unique = true, image = "object/artifact/gloves_ritch_claws.png",
	name = "Ritch Claws", color = colors.UMBER, 
	unided_name = _t"sharply clawed gloves",
	desc = _t[[A pair of sharply honed gauntlets made from the claws of Ritch Impalers.]],
	level_range = {14, 24},
	rarity = 20,
	cost = 240,
	material_level = 2,
	wielder = {
		combat_dam = 5,
		combat_physcrit = 5,
		combat_armor = 6,
		combat = {
			dam = 20,
			apr = 10,
			physcrit = 10,
			physspeed = 0.1, --Semifast
			damage_convert = {[DamageType.PHYSICALBLEED]=20,},
			dammod = {dex=0.4, str=-0.6, cun=0.4 },
			damrange = 0.3,
		},
	},
	max_power = 24, power_regen = 1,
	use_talent = { id = Talents.T_RUSHING_CLAWS, level = 2, power = 24 },
}

newEntity{ base = "BASE_STEAMSAW",
	power_source = {steam=true, nature=true},
	name = "Stinger", image = "object/artifact/stinger.png",
	unided_name = _t"scaled steamsaw", unique = true,
	level_range = {15, 25},
	desc = _t[[Is that... an ovipositor?]],
	require = { stat = { dex=20 }, },
	cost = 300,
	material_level = 2,
	rarity = 20,
	combat = {
		dam = 17,
		apr = 16,
		physcrit = 4,
		dammod = {str=1},
		block = 44,
	},
	wielder = {
		combat_armor = 6,
		combat_def = 5,
		fatigue = 8,
		learn_talent = { [Talents.T_BLOCK] = 1, },
	},
	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_RITCH_LARVA_INFECT, level = 2, power = 30 },
}
