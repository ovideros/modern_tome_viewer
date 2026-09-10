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

load("/data-orcs/general/npcs/steam-spiders.lua", function(e) e.faction = "enemies" end)

newEntity{
	define_as = "AAT",
	type = "construct", subtype = "mechanical",
	display = "A", color=colors.UMBER, image = "npc/construct_mechanical_ancient_automated_archive.png",
	name = "Ancient Automated Teacher",
	desc = _t[[An ancient archive of knowledge! It seems to have some kind of vocal interface.]],
	level_range = {50, nil}, exp_worth = 1,
	faction = "unaligned",
	repairable = 1,
	never_anger = true,

	combat = { dam=1, atk=1, apr=1 },

	life_rating = 0, life = 500,
	rank = 3,
	size_category = 3,
	power_source = {steamtech=true},
	can_talk = "orcs+aaf",

	resolvers.genericlast(function(e)
		e.store = game:getStore("TINKER")
		e.store.faction = e.faction
		e.store.store.sell_percent = 50
	end),
}
