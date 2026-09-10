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

newEntity{ base = "BASE_SCHEMATIC", define_as = "PAYLOAD_SCHEMATIC",
	name = "schematic: Payload", no_unique_lore = true,
	level_range = {30, 40},
	unique = true,
	rarity = false,
	cost = 100,
	material_level = 5,
	tinker_id = "GUN_PAYLOAD",
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic=true},
	unique = true,
	name = "The Forgotten",
	unided_name = _t"pale mindstar",
	level_range = {15, 25},
	color=colors.AQUAMARINE, image = "object/artifact/the_forgotten.png",
	rarity = 20,
	desc = _t[[A strange mindstar, overgrown with granite and cracked. It seems incredibly ancient and horribly damaged, but still functions.]],
	cost = 280,
	require = { stat = { wil=27 }, },
	material_level = 3,
	combat = {
		dam = 12,
		apr = 22,
		physcrit = 5,
		dammod = {wil=0.5, cun=0.1},
		damtype = DamageType.MIND,
	},
	wielder = {
		combat_mindpower = 5,
		combat_mindcrit = 5,
		combat_mentalresist=15,
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 3, },
	},
	max_power = 25, power_regen = 1,
	use_power = {
		power = 25,
		name = _t"confuse all enemies in radius 3 for 5 turns",
		use = function(self, who)
			local blast = {type="ball", range=0, radius=3, friendlyfire=false}
			who:project(blast, who.x, who.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				if target:canBe("confusion") then
					target:setEffect(target.EFF_CONFUSED, 5, {power=50, apply_power=who:combatMindpower()})
				else
					game.logSeen(target, "%s resists!", target:getName():capitalize())
				end
			end)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {psionic=true},
	unique = true,
	name = "The Cage", image = "object/artifact/the_cage.png",
	unided_name = _t"thick leather cap",
	level_range = {20, 25},
	color=colors.WHITE,
	encumber = 1,
	rarity = 20,
	desc = _t[[Nothing will ever reach you again.]],
	cost = 200,
	material_level=3,
	special_desc = function(self) return _t"You are immune to mental status effects." end,
	wielder = {
		resists = {[DamageType.MIND] = 30, all = 10},
		resists_cap = {[DamageType.MIND] = 30,},
		mental_negative_status_effect_immune = 1,
		global_speed_add = -0.25,
	},
}