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

load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "HEAVY_ARMOR_STORE",
	name="Armoury",
	display='2', color=colors.UMBER,
	resolvers.store("HEAVY_ARMOR", "kruk-pride", "store/shop_door.png", "store/shop_sign_armory.png"),
	resolvers.chatfeature("last-hope-weapon-store", "kruk-pride"),
}

newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Tanner",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "kruk-pride", "store/shop_door.png", "store/shop_sign_tanner.png"),
}

newEntity{ base = "BASE_STORE", define_as = "MELEE_WEAPON_STORE",
	name="Forge",
	display='3', color=colors.UMBER,
	resolvers.store("ORC_MELEE_WEAPON", "kruk-pride", "store/shop_door.png", "store/orc_store_steamsaws.png"),
}

newEntity{ base = "BASE_STORE", define_as = "RANGED_WEAPON_STORE",
	name="Smith",
	display='3', color=colors.UMBER,
	resolvers.store("ORC_RANGED_WEAPON", "kruk-pride", "store/shop_door.png", "store/orc_store_steamguns.png"),
}

newEntity{ base = "BASE_STORE", define_as = "HERBALIST",
	name="Herbalist",
	display='4', color=colors.LIGHT_BLUE,
	resolvers.store("POTION", "kruk-pride", "store/shop_door.png", "store/shop_sign_herbalist.png"),
}

newEntity{ base = "BASE_STORE", define_as = "TINKER_STORE",
	name="Tinkers Store",
	display='5', color=colors.GREY,
	resolvers.store("TINKER", "kruk-pride", "store/shop_door.png", "store/orc_store_tinkers.png"),
	resolvers.chatfeature("orcs+kruk-tinker-shop", "kruk-pride"),
}

newEntity{ base = "BASE_STORE", define_as = "LIBRARY",
	name="Library",
	display='4', color=colors.LIGHT_RED,
	resolvers.store("ORC_LIBRARY", "kruk-pride", "store/shop_door.png", "store/shop_sign_library.png"),
}