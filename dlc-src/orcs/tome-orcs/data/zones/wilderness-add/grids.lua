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

load("/data-orcs/general/grids/snow_mountains.lua")

newEntity{ base="SEA_EYAL", define_as = "MAINLAND_BRIDGE",
	name = "bridge to the mainland", add_displays = {class.new{z=3, image="terrain/worldmap/stone_bridge.png", display_x=-1, display_w=3}},
	color = colors.LIGHT_UMBER,
	can_pass = false, does_block_move = false, can_encounter = false,
}

--------------------------------------------------------------------------------
-- Zones
--------------------------------------------------------------------------------
newEntity{ base="FROZEN_SEA", define_as = "ZONE_FROZEN_SEA", change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true, nice_tiler=false }

newEntity{ base="TOWN", define_as = "TOWN_KRUK",
	name = "Kruk Pride (Town)", add_displays = {class.new{z=7, image="terrain/worldmap/kruk_worldmap.png"}},
	desc = _t"The last free Pride of the Orcs",
	change_zone="orcs+town-kruk",
}

newEntity{ base="ZONE_PLAINS", define_as = "YETI_CAVES",
	name="Entrance to the Yeti Caves",
	color={r=0, g=0, b=255},
	add_mos={{image="terrain/cave_entrance02.png"}},
	change_zone="orcs+yeti-caves",
}

newEntity{ base="ZONE_PLAINS", define_as = "KRIMBUL",
	name="Entrance to Krimbul territory",
	color={r=0, g=0, b=255},
	add_displays={class.new{image="terrain/dungeon_entrance02.png", z=4}},
	change_zone="orcs+krimbul",
}

newEntity{ base="ZONE_PLAINS", define_as = "VAPOROUS_EMPORIUM",
	name="Entrance to the Vaporous Emporium",
	color={r=128, g=0, b=255},
	add_mos={{image="terrain/village_01.png"}},
	change_zone="orcs+vaporous-emporium",
}

newEntity{ base="ZONE_PLAINS", define_as = "KALTOR_SHOP",
	name="Huge door to Kaltor's Shop",
	color={r=255, g=255, b=255},
	add_mos={{image="terrain/dungeon_entrance01.png"}},
	change_zone="orcs+kaltor-shop",
}

newEntity{ base="ZONE_PLAINS", define_as = "SUNWALL_OUTPOST",
	name="Entrance to the Sunwall Outpost",
	color=colors.GOLD,
	add_mos={{image="terrain/village_01.png"}},
	change_zone="orcs+sunwall-outpost",
}

newEntity{ base="ZONE_DESERT", define_as = "LOST_CITY",
	name="Way into old ruins in the Erúan desert",
	color=colors.BLUE,
	add_displays={class.new{z=8,image="terrain/worldmap/lost_city_ruins_entrance.png"}},
	can_pass = false, does_block_move = false, can_encounter = false,
	change_zone="orcs+lost-city",
	change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true, nice_tiler=false
}

newEntity{ base="SEA_EYAL", define_as = "DOMINION_PORT",
	name="Entrance to the Dominion Port",
	color=colors.BLUE,
	add_displays={class.new{z=8,image="terrain/worldmap/dominion_port.png"}},
	can_pass = false, does_block_move = false, can_encounter = false,
	change_zone="orcs+dominion-port",
	change_level=1, glow=true, display='>', color=colors.VIOLET, notice = true, nice_tiler=false
}

newEntity{ base="SEA_EYAL", define_as = "DOMINION_PORT_DESTROYED",
	name="Destroyed Dominion Port",
	color=colors.BLUE,
	add_displays={class.new{z=8,image="terrain/worldmap/dominion_port_ruined.png"}},
	change_level = false,
	can_pass = false, does_block_move = false, can_encounter = false,
	change_zone="orcs+dominion-port",
	display='>', color=colors.VIOLET, notice = true, nice_tiler=false
}

newEntity{ base="ZONE_DESERT", define_as = "RITCH_HIVE",
	name="Entrance to a Ritch Hive",
	color=colors.YELLOW,
	add_mos={{image="terrain/ladder_down.png"}},
	change_zone="orcs+ritch-hive",
}

newEntity{ base="ZONE_DESERT", define_as = "SUNWALL_OBSERVATORY",
	name="Path to a peak leading to the Sunwall Observatory",
	color=colors.GOLD,
	add_displays = {class.new{image="terrain/worldmap/observatory_entrance.png", z=8, display_y=-1, display_h=2}},
	change_zone="orcs+sunwall-observatory",
}

newEntity{ base="ZONE_PLAINS", define_as = "INTERNMENT_CAMP",
	name="Entrance to the Pride's Internment Camp",
	color=colors.GOLD,
	add_mos={{image="terrain/village_01.png"}},
	change_zone="orcs+internment-camp",
}

newEntity{ base="TOWN", define_as = "GATES_OF_MORNING_ORCS",
	name = "Gates of Morning (Town)",
	desc = _t"A massive hole in the Sunwall.",
	add_displays = {class.new{image="terrain/golden_cave_entrance02.png", z=8}},
	change_zone="orcs+gates-of-morning",
}

newEntity{ base="ZONE_PLAINS", define_as = "GEM",
	name="Strange mechanical mole",
	color=colors.UMBER,
	add_displays = {class.new{image="terrain/mountain_entrance8.png", z=8, display_h=2, display_y=-1}},
	change_zone="orcs+gem",
}

newEntity{ base="ZONE_PLAINS", define_as = "URESLAK_HOST",
	name="Path to a Ureslak's Host",
	color=colors.GREY,
	add_displays = {class.new{image="terrain/mountain_entrance8.png", z=8, display_h=2, display_y=-1}},
	change_zone="orcs+ureslak-host",
}

newEntity{ base="ZONE_PLAINS", define_as = "STEAM_QUARRY",
	name="Entrance to the Steam Quarry",
	color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/mountain_entrance6.png", z=8, display_w=2}},
	change_zone="orcs+steam-quarry",
}

newEntity{ base="ZONE_PLAINS", define_as = "PALACE_FUMES",
	name="Entrance to the Palace of Fumes",
	color=colors.RED,
	add_displays = {class.new{image="terrain/worldmap/palace_of_fumes.png", z=8}},
	change_zone="orcs+palace-fumes",
}

newEntity{ base="ZONE_PLAINS", define_as = "PRIMAL_FOREST",
	name="Way into a primal forest",
	color=colors.GREEN,
	add_displays={class.new{image="terrain/road_going_up_01.png", display_h=2, display_y=-1, z=4}},
	change_zone="orcs+primal-forest",
}

newEntity{ base="ZONE_PLAINS", define_as = "DESTRUCTICUS",
	name="DESTRUCTICUS!",
	color=colors.PURPLE, change_level=table.NIL_MERGE,
	add_displays = {
		class.new{image="terrain/worldmap/destructicus_launch_booth.png", z=5},
		class.new{image="terrain/worldmap/destructicus_launch_pad.png", z=6, display_x=1},
		class.new{image="terrain/worldmap/destructicus.png", z=17, display_x=1, display_h=2, display_y=-1},
	},
	chat_display_entity = {name=_t"DESTRUCTICUS!", image="terrain/worldmap/destructicus.png"},
	block_move = function(self, x, y, who, act)
		if not act or not who or not who.player then return true end
		local chat = require("engine.Chat").new("orcs+destructicus", self, who, {dx=x, dy=y})
		chat:invoke()
		return true
	end,
}
