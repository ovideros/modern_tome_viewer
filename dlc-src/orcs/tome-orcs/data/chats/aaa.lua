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
	text = _t[[#LIGHT_GREEN#*Before you stands a strange triangular device, some kind of automated storage facility.*#WHITE#]],
	answers = {
		{_t"[access store]", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player, npc.name)
		end},
		{_t"[reprogram it to order it to relocate to Kruk Pride]", jump="relocate", cond=function() return game.zone.short_name ~= "orcs+town-kruk" and game:isCampaign("Orcs") end},
		{_t"[leave]"},
	}
}

newChat{ id="relocate",
	text = _t[[#LIGHT_GREEN#*You tinker with the store bot and manage to activate the relocation function.*#WHITE#]],
	answers = {
		{_t"[order it to go to Kruk Pride]", action=function(npc, player)
			game.level:removeEntity(npc, true)
			game.state.aaas_for_kruk = game.state.aaas_for_kruk or {}
			game.state.aaas_for_kruk[#game.state.aaas_for_kruk+1] = npc
			game:onLevelLoad("orcs+town-kruk-1", function(zone, level)
				if not game.state.aaas_for_kruk or #game.state.aaas_for_kruk == 0 then return end
				local aaa = table.remove(game.state.aaas_for_kruk)
				local tries = 1000
				while tries > 0 do tries = tries - 1
					local spot = level:pickSpotRemove{type="aaa", subtype="aaa"}
					if spot and not level.map(spot.x, spot.y, level.map.ACTOR) then
						zone:addEntity(level, aaa, "actor", spot.x, spot.y)
						break
					end
				end
			end)
		end},
		{_t"[leave]"},
	}
}

return "welcome"
