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

load("/data/general/objects/objects.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "tattered paper scrap", lore="cults-illusory-castle-"..i,
	desc = _t[[A paper scrap, left by an adventurer.]],
	rarity = false,
	encumberance = 0,
}
end

-- This never drops, it only exists to customize the visual appearance of the glass golem
newEntity{ base = "BASE_GREATSWORD", define_as = "HARDENED_GLASS_SWORD",
	power_source = {psionic=true},
	unique = true,
	name = "Hardened Glass Sword", image = "object/artifact/2hsword_crystalline.png",
	unided_name = _t"shining sword",
	desc = _t[[.]],
	level_range = {20, 40},
	require = { stat = { str=25, mag=25 }, },
	color = colors.AQUAMARINE,
	encumber = 12,
	cost = 350,
	rarity = table.NIL_MERGE,
	material_level = 3,
	moddable_tile = "special/%s_2Hsword_crystalline",
	moddable_tile_big = true,
	combat = {
		dam = 49,
		apr = 9,
		physcrit = 9,
		dammod = {str=1.2},
		melee_project={[DamageType.ARCANE] = 20, [DamageType.LIGHT] = 20},
	},
}

newEntity{ base = "BASE_HELM", define_as = "HELM_OF_KNOWLEDGE",
	power_source = {psionic=true, arcane=true},
	unique = true, color = colors.GOLD,
	name = "Helm of Knowledge", image = "object/artifact/helm_of_knowledge.png",
	moddable_tile = "cults/helm_of_knowledge", moddable_tile_big = true,
	unided_name = _t"psionic crown",
	desc = _t[[A large crown, part metallic part glass that radiates with psionic powers.]],
	level_range = {20, 40},
	cost = 270,
	rarity = table.NIL_MERGE,
	material_level = 3,
	wielder = {
		combat_armor = 12,
		fatigue = 8,
		inc_stats = { [Stats.STAT_WIL] = 10, [Stats.STAT_CUN] = 10},
		resists={
			[DamageType.ARCANE] = 10,
			[DamageType.LIGHT] = 15,
			[DamageType.MIND] = 15,
		},
		life_regen = 2,
	},
	special_desc = function(self) return _t"It can be used without being worn." end,
	use_no_wear = true,
	max_power = 20, power_regen = 1,
	use_power = { name = _t"sense the presence of unique objects", power = 20,
		use = function(self, who)
			if not who.player then return {id=true, used=true} end
			local nb_floor, nb_npc = 0, 0
			
			-- Count the floor
			for x = 0, game.level.map.w do for y = 0, game.level.map.h do
				local i, nb = game.level.map:getObjectTotal(x, y), 0
				local obj = game.level.map:getObject(x, y, i)
				while obj do
					if obj.unique or obj.randart then nb_floor = nb_floor + 1 end
					i = i - 1
					obj = game.level.map:getObject(x, y, i)
				end
			end end

			-- Count npcs
			for uid, npc in pairs(game.level.entities) do if not game.party:hasMember(npc) and npc.getInven then
				npc:inventoryApplyAll(function(inven, item, obj)
					if obj.unique or obj.randart then nb_npc = nb_npc + 1 end
				end)
			end end

			if nb_floor == 0 then game.log("#GREY#You sense no unique items on the floor.")
			else game.log("#GOLD#You sense %d unique item(s) on the floor.", nb_floor) end
			if nb_npc == 0 then game.log("#GREY#You sense no unique items on creatures.")
			else game.log("#GOLD#You sense %d unique item(s) on creatures.", nb_npc) end

			return {id=true, used=true}
		end,
	}
}
