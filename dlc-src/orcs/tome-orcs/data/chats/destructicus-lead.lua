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

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*Several loyal Orcs are eagerly waiting outside the palace to meet you; one steps forward, handing you a set of keys.  The word 'DESTRUCTICUS' is etched into one.*#WHITE#
Chief @playername@!  The Giants are fleeing, and we intercepted a scout carrying this!  We believe they can be used with...  well, you should see for yourself!  Please, come with us to the mountains just south of Kruk Pride!
#LIGHT_GREEN#*This sounds important.  You should probably head there right away!*#WHITE#]],
	answers = {
		{_t"Lead the way.", action=function(npc, player)
			local spot = game.level:pickSpot{type="questpop", subtype="destructicus"}
			if spot then player:move(spot.x, spot.y + 1, true) end
		end},
	}
}

return "welcome"
