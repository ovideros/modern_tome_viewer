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

newEntity{ define_as = "YETI_PATRIARCH_MUSCLE",
	power_source = {nature=true},
	unique = true,
	type = "flesh", subtype="muscle",
	unided_name = _t"flesh",
	name = "Yeti's Muscle Tissue (Patriarch)",
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