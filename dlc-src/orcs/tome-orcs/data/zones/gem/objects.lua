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
	define_as = "BASE_LORE_DISK",
	type = "lore", subtype="disk", not_in_stores=true, no_unique_lore=true,
	unided_name = _t"disk", identified=true,
	display = "?", color=colors.ANTIQUE_WHITE, image="object/artifact/vinyl_disc.png",
	encumber = 0,
	checkFilter = function(self) if self.lore and game.party.lore_known and game.party.lore_known[self.lore] then print('[LORE] refusing', self.lore) return false else return true end end,
	desc = _t[[A strange black disk found in the G.E.M.
You have no idea how to use it.]],
}

for i = 1, 6 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "erratic scribblings", lore="gem-erratic-"..i,
	desc = _t[[A journal.]],
	rarity = false,
	encumberance = 0,
}
end

for i = 1, 3 do
newEntity{ base = "BASE_LORE_DISK",
	define_as = "GEM_VINYL"..i, unique = true,
	name = "strange black disk ("..i..")", vinyl_lore="gem-"..i,
	rarity = false,
	plot = true,
	encumberance = 0,
}
end

newEntity{ base = "BASE_SCHEMATIC", define_as = "POWER_ARMOUR_SCHEMATIC",
	name = "schematic: Steam Powered Armour", no_unique_lore = true,
	level_range = {30, 40},
	unique = true,
	rarity = false,
	cost = 100,
	material_level = 5,
	tinker_id = "POWER_ARMOUR",
}

newEntity{ define_as = "YETI_MECH_MUSCLE",
	power_source = {nature=true},
	unique = true,
	type = "flesh", subtype="muscle",
	unided_name = _t"flesh",
	name = "Yeti's Muscle Tissue (Mech)",
	level_range = {1, 1},
	display = "*", color=colors.VIOLET, image = "object/yeti_muscle_tissue.png",
	encumber = 1,
	plot = true, quest = true,
	yeti_muscle_tissue = true,
	desc = _t[[Muscle tissue, extracted from a powerful yeti. Somewhere, somebody or something is bound to be interested!]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	on_pickup = function(self, who)
		game.player:grantQuest("orcs+weissi")
	end,
}
