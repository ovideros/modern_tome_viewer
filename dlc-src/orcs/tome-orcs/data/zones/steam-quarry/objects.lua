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

load("/data-orcs/general/objects/objects.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "a very old journal", lore="steam-quarry-"..i,
	desc = _t[[A journal.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_SCHEMATIC", define_as = "SAW_STORM_SCHEMATIC",
	name = "schematic: Stormcutter", no_unique_lore = true,
	level_range = {30, 40},
	unique = true,
	rarity = false,
	cost = 100,
	material_level = 5,
	tinker_id = "SAW_STORM",
}
