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

load("/data/general/objects/cloak.lua")

newEntity{ base = "BASE_CLOAK",
	name = "kruk cloak", short_name = "kruk",
	image = "object/kruk_cloak.png", moddable_tile = "special/kruk_cloak_%s", cosmetic = true, no_unique_lore=true,
	desc = _t"A stylish kruk-style cloak, to look awesome.",
	level_range = {1, 20},
	cost = 2,
	material_level = 1,
}

newEntity{ define_as = "TINKER_CAVE_TELEPORTER",
	name = "Teleporter to the Tinker's Cave",
	image = "object/artifact/yeti_beacon.png", unique=true, no_unique_lore=true,
	desc = _t"A strange metal contraption imbued with some kind of teleportation magic.",
	level_range = {1, 50},
	cost = 0,
	material_level = 1,

	power_source = {steam=true},
	use_simple = { name=_t"teleport.", use = function(self, who, inven, item)
		local hostiles = false
		for uid, e in pairs(game.level.entities) do
			if who:reactionToward(e) < 0 then
				hostiles = true
				break
			end
		end
		if hostiles then
			game.logPlayer(who, "The teleporter's delicate systems are perturbed by foes on this level. You must have no foes left to be able to use it.")
			return {used=true, id=true}
		end

		local oz, ol = game.zone.short_name, game.level.level

		game:changeLevel(1, "orcs+tinker-master", {temporary_zone_shift=true, direct_switch=true})

		-- Alter the stairs & zone
		if game.zone.short_name == "orcs+tinker-master" then
			game.level.data.no_worldport = true -- Dont recall out!
			for x = 0, game.level.map.w do for y = 0, game.level.map.h do 
				local g = game.level.map(x, y, engine.Map.TERRAIN)
				if g and g.change_zone then
					g.change_zone = oz
					g.change_level = ol
					g.change_level_shift_back = true
				end
			end end
		end

		return {used=true, id=true}
	end}	
}
