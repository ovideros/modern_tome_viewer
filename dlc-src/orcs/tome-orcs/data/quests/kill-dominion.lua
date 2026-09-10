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

name = _t"This is our land!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"A group of trolls from the Kar'Haïb Dominion is trying to take foot on the mainland."
	desc[#desc+1] = _t"With the Sunwall at full force we can not have the luxury of having to fight on both fronts, the Dominion port of the south must be destroyed."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"A potent bomb was given to you, you must place it at a weak spot of the tower where it will detonate and destroy the port."
	desc[#desc+1] = _t"It would be a good idea for you to not be there anymore when the bomb explodes however."
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the Dominion port, the trolls will not be a problem in the near future.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_grant = function(self)
	local o = mod.class.Object.new{
		power_source = {steam=true},
		type = "tinker", subtype = "bomb",
		identified=true, no_unique_lore=true,
		name = _t"Tower Detonator", display = '*', color=colors.CRIMSON, unique=true, image = "trap/trap_bomb_01.png",
		desc = _t[[This bomb was tailored to weaken the structure of the Dominion's port tower. If placed at the right spot it will explode after 100 turns and destroy the whole port.]],
		cost = 0, quest=true,
		auto_hotkey = 1,

		use_simple = { name=_t"place the bomb on the structural weakness.", use = function(self, who, inven, item)
			local g = game.level.map(who.x, who.y, engine.Map.TERRAIN)
			if not g or not g.tower_structural_weakness then
				require("engine.ui.Dialog"):simplePopup(_t"Sewer Detonator", _t"You must first locate the structural weakness in the Dominion's port tower.")
				return {}
			end
			require("engine.ui.Dialog"):simpleLongPopup(_t"Sewer Detonator", _t"You place the detonator, you have 100 turns to get out or be destroyed by the explosion.\nUse your #{bold}##GOLD#Rod of Recall#LAST##{normal}#!", 500)
			local q = game:getPlayer(true):hasQuest("orcs+kill-dominion")
			if q then q:start_destruction() end
			return {used=true, id=true, destroy=true}
		end},
	}
	game:getPlayer(true):addObject("INVEN", o)
	game:getPlayer(true):sortInven()	
end

start_destruction = function(self)
	game.level.max_turn_counter = 1000
	game.level.turn_counter = 1000
	game:onLevelLoad("wilderness-1", function(zone, level)
		game.player:setQuestStatus("orcs+kill-dominion", engine.Quest.COMPLETED)

		local spot = level:pickSpot{type="questpop", subtype="orcs+dominion-port"}
		local g = zone:makeEntityByName(level, "terrain", "DOMINION_PORT_DESTROYED")
		if g and spot then
			zone:addEntity(level, g, "terrain", spot.x, spot.y)
			game.nicer_tiles:updateAround(level, spot.x, spot.y)
		end
	end)
end

do_destruction = function(self)
	game.level.no_return_from_eidolon = true
	game:changeLevel(1, "wilderness")
	game.player:die(game.player)
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+free-prides")
	end
end
