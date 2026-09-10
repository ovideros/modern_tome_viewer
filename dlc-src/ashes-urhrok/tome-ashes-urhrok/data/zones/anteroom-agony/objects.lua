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

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_LORE", define_as = "LORE_DEMO",
	name = "tattered paper scrap", lore="ashes-urhrok-tactics-demonologist",
	desc = _t[[A written message.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_LORE", define_as = "LORE_DOOM",
	name = "tattered paper scrap", lore="ashes-urhrok-tactics-doombringer",
	desc = _t[[A written message.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_LORE", define_as = "LORE_ELF",
	name = "tattered paper scrap", lore="ashes-urhrok-tactics-doomelf",
	desc = _t[[A written message.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_LORE", define_as = "LORE_FAILED",
	name = "tattered paper scrap", lore="ashes-urhrok-tactics-failed",
	desc = _t[[A hastily written message.]],
	rarity = false,
	encumberance = 0,
	unique = "demon_ashes_lore_failed",
}

newEntity{ base = "BASE_LORE", define_as = "LORE_FAILED_BADASS",
	name = "tattered paper scrap", lore="ashes-urhrok-tactics-failed-badass",
	desc = _t[[A hastily written message.]],
	rarity = false,
	encumberance = 0,
	unique = "demon_ashes_lore_failed",
}

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "HISTORY_MALROK"..i, image = "terrain/malrok_wall/crystalline_tablets.png",
	name = "crystalline tablets", lore="ashes-urhrok-demon-history-"..i,
	desc = _t[[A pile of crystalline tablets.]],
	rarity = false,
	encumberance = 0,
}
end
