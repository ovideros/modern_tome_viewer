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

name = _t"Ashes in the Wind"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[You do not remember much of your life before you were on this burning continent, floating in the void between worlds.  You have been helping demons, happily participating in their experiments to shatter some sort of shield preventing them from taking their righteous revenge on Eyal.

You are being taken by your handler to the torture-pits to help them figure out how to cause the most pain to those on Eyal, when you hear a roaring above you; you look up and see a burning meteor, flying closer, and the demons' spells failing to divert its course!  It lands near you, knocking you off your feet with its shockwave and killing your handler instantly.

As you recover, and your platform of searing earth splits from the main continent, your old memories flood your mind and you come to your senses - the demons are out to destroy your home!  You must escape... but not without destroying the crystal they've used to keep track of you.
]]
	if self:isCompleted("crystal") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the controlling crystal. The demons can no track you down anymore.#WHITE#"

		if self:isCompleted("planar-walker") then
			desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the Planar Controller. Flee now!#WHITE#"
		else
			desc[#desc+1] = _t"#SLATE#* You have to destroy the Planar Controller to escape.#WHITE#"
		end
	else
		desc[#desc+1] = _t"#SLATE#* You have to destroy the controlling crystal before leaving or the demons will be able to track you down.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub == "crystal" then
		if not self.summoned then
			local npc = game.zone:makeEntityByName(game.level, "actor", "PLANAR_CONTROLLER", true)
			local x, y = util.findFreeGrid(who.x, who.y, 6, true, {[engine.Map.ACTOR]=true})
			if npc and x then
				game.zone:addEntity(game.level, npc, "actor", x, y)
				game.level.map:particleEmitter(x, y, 1, "demon_teleport")
				self.summoned = true
			end
		end
	elseif sub == "escaped" then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest(who.ashes_urhrok_race_start_quest)
	end
end
