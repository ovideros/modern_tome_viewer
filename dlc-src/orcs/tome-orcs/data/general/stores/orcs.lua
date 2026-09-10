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

newEntity{
	define_as = "ORC_LIBRARY",
	name = "library",
	display = '4', color=colors.RED,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
		},
		fixed = {
			{id=true, defined="LORE_KRUK_HISTORY"},
		},
	},
}

newEntity{
	define_as = "ORC_MELEE_WEAPON",
	name = "forge",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			-- {type="weapon", subtype="greatmaul", id=true, tome_drops="store"},
			{type="weapon", subtype="steamsaw", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ORC_RANGED_WEAPON",
	name = "smith",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="steamgun", id=true, tome_drops="store"},
			{type="ammo", subtype="shot", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "TINKER",
	name = "tinker",
	display = '5', color=colors.GREY,
	store = {
		purse = 25,
		empty_before_restock = false,
		fixed = {
			{id=true, defined="SCHEMATIC_RANDOM_FROST_SALVE"},
			{id=true, defined="SCHEMATIC_RANDOM_FIERY_SALVE"},
			{id=true, defined="SCHEMATIC_RANDOM_WATER_SALVE"},
			{id=true, defined="SCHEMATIC_RANDOM_STEAMSAW"},
			{id=true, defined="SCHEMATIC_RANDOM_STEAMGUN"},
		},
		filters = {
			{type="scroll", subtype="schematic", id=true},
			{type="scroll", subtype="implant", id=true},
		},
	},
}

newEntity{
	define_as = "KALTOR_SHOP",
	name = "expensive goods",
	display = '7', color=colors.BLUE,
	store = {
		nb_fill = 20,
		purse = 35,
		empty_before_restock = false,
		sell_percent = 280,
		filters = function()
			local kind = rng.table{"uvault", "gvault"}
			return {id=true, ignore={type="money"}, add_levels=12, force_tome_drops=true, tome_drops="boss", tome_mod=kind, special=function(o) return o.type ~= "scroll" end}
		end,
	},
}

--- AAA specific stores
newEntity{
	define_as = "ORC_AAA_WEAPONS",
	name = "forge",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="steamsaw", id=true, tome_drops="store"},
			{type="weapon", subtype="steamgun", id=true, tome_drops="store"},
			{type="ammo", subtype="shot", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ORC_AAA_ARMORS",
	name = "forge",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="armor", subtype="belt", id=true, tome_drops="store"},
			{type="armor", subtype="cloak", id=true, tome_drops="store"},
			{type="armor", subtype="cloth", id=true, tome_drops="store"},
			{type="armor", subtype="feet", id=true, tome_drops="store"},
			{type="armor", subtype="hands", id=true, tome_drops="store"},
			{type="armor", subtype="head", id=true, tome_drops="store"},
			{type="armor", subtype="heavy", id=true, tome_drops="store"},
			{type="armor", subtype="light", id=true, tome_drops="store"},
			{type="armor", subtype="massive", id=true, tome_drops="store"},
			{type="armor", subtype="robe", id=true, tome_drops="store"},
			{type="armor", subtype="shield", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "ORC_AAA_ARCANE_PSI",
	name = "aracane psi collector",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="weapon", subtype="mindstar", id=true, tome_drops="store"},
			{type="charm", subtype="torque", id=true, tome_drops="store"},
			{type="charm", subtype="totem", id=true, tome_drops="store"},
			{type="charm", subtype="wand", id=true, tome_drops="store"},
			{type="weapon", subtype="staff", id=true, tome_drops="store"},
			{type="gem", id=true},
		},
	},
}

newEntity{
	define_as = "ORC_AAA_INSCRIPTIONS",
	name = "rune and infusion collector",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="scroll", subtype="rune", id=true},
			{type="scroll", subtype="infusion", id=true},
		},
	},
}

-- So we have a store without guaranteed schematics taking up space
newEntity{
	define_as = "ORC_AAA_TINKER",
	name = "tinker",
	display = '5', color=colors.GREY,
	store = {
		purse = 25,
		empty_before_restock = false,
		filters = {
			{type="scroll", subtype="schematic", id=true},
			{type="scroll", subtype="implant", id=true},
		},
	},
}

newEntity{
	define_as = "ORC_AAA_LITEDIGSTORE",
	name = "tool store",
	display = '8', color=colors.UMBER,
	store = {
		purse = 10,
		empty_before_restock = false,
		ignore_material_levels = true,
		filters = {
			{type="lite", id=true, tome_drops="store"},
			{type="tool", subtype="digger", id=true, tome_drops="store"},
		},
	},
}
