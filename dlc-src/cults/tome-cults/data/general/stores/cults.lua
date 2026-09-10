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

-------------------------------------------------------------
-- Kroshkkur
-------------------------------------------------------------
newEntity{
	define_as = "KROSHKKUR_LIBRARY",
	name = "That Which Teaches History",
	display = '*', color=colors.LIGHT_RED,
	store = {
		purse = 10,
		empty_before_restock = false,
		filters = {
		},
		fixed = {
			{id=true, defined="HISTORY_OF_KROSHKKUR1"},
			{id=true, defined="HISTORY_OF_KROSHKKUR2"},
			{id=true, defined="HISTORY_OF_KROSHKKUR3"},
			{id=true, defined="GODS_RESEARCH0"},
			{id=true, defined="GODS_RESEARCH1"},
			{id=true, defined="GODS_RESEARCH2"},
			{id=true, defined="GODSLAYER_RESEARCH0"},
			{id=true, defined="GODSLAYER_RESEARCH1"},
			{id=true, defined="GODSLAYER_RESEARCH2"},
			{id=true, defined="GODSLAYER_RESEARCH3"},
		},
	},
}

newEntity{
	define_as = "KROSHKKUR_RUNES",
	name = "The Face of the Deep",
	display = '5', color=colors.WHITE,
	store = {
		purse = 10,
		nb_fill = 5,
		empty_before_restock = false,
		filters = {
			{type="scroll", subtype="rune", id=true, ego_chance = 1000 },
			{type="scroll", subtype="infusion", id=true, ego_chance = 1000 },
		},
	},
}

newEntity{
	define_as = "KROSHKKUR_STAVES",
	name = "The Crawler",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		nb_fill = 6,
		filters = {
			{type="weapon", subtype="staff", id=true, tome_drops="store"},
			{type="weapon", subtype="staff", id=true, tome_drops="store"},
			{type="weapon", subtype="staff", id=true, tome_drops="store"},
			{type="charm", subtype="wand", id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "KROSHKKUR_WEAPONS",
	name = "The Sightless Acolyte",
	display = '3', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		nb_fill = 10,
		filters = {
			{special=function(o) return o.type == "weapon" and o.subtype ~= "staff" end, id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "KROSHKKUR_ARMORS",
	name = "The One That Defends",
	display = '2', color=colors.UMBER,
	store = {
		purse = 25,
		empty_before_restock = false,
		nb_fill = 12,
		filters = {
			{special=function(o) return o.type == "armor" end, id=true, tome_drops="store"},
		},
	},
}

newEntity{
	define_as = "KROSHKKUR_TOOLS",
	name = "The Conjointed",
	display = '8', color=colors.UMBER,
	store = {
		purse = 10,
		empty_before_restock = false,
		nb_fill = 5,
		filters = {
			{type="lite", id=true, tome_drops="store"},
			{type="tool", subtype="digger", id=true, tome_drops="store"},
		},
	},
}
