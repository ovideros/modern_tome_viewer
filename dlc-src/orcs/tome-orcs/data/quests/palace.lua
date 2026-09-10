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

name = _t"No Fumes Without Fire"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"The time for revenge is at hand! The Tribe stands crippled under your assaults."
	desc[#desc+1] = _t"Enter the Palace of Fumes and crush their leaders once and for all!"
	desc[#desc+1] = _t"For Kruk!"
	desc[#desc+1] = _t"For the Prides!"
	desc[#desc+1] = _t"For the Garkul!"
	desc[#desc+1] = _t""
	if self:isStatus(self.COMPLETED, "COUNCIL1") then desc[#desc+1] = _t"#LIGHT_GREEN#* Council Member Nashal is dead.#WHITE#" end
	if self:isStatus(self.COMPLETED, "COUNCIL2") then desc[#desc+1] = _t"#LIGHT_GREEN#* Council Member Tormak is dead.#WHITE#" end
	if self:isStatus(self.COMPLETED, "COUNCIL3") then desc[#desc+1] = _t"#LIGHT_GREEN#* Council Member Pendor is dead.#WHITE#" end
	if self:isStatus(self.COMPLETED, "COUNCIL4") then desc[#desc+1] = _t"#LIGHT_GREEN#* Council Member Palaquie is dead.#WHITE#" end
	if self:isStatus(self.COMPLETED, "COUNCIL5") then desc[#desc+1] = _t"#LIGHT_GREEN#* Council Member Tantalos is dead.#WHITE#" end
	if self:isStatus(self.DONE) then desc[#desc+1] = _t"#LIGHT_GREEN#* You have destroyed the Council and shattered the Tribe.#WHITE#" end
	return table.concat(desc, "\n")
end

on_grant = function(self)
	self.killed = {}
	self.nb_killed = 0
end

on_status_change = function(self, who, status, sub)
	if sub == "COUNCIL1" or sub == "COUNCIL2" or sub == "COUNCIL3" or sub == "COUNCIL4" or sub == "COUNCIL5" then
		if not self.killed[sub] then
			self.killed[sub] = true
			self.nb_killed = self.nb_killed + 1
			self:on_kill_boss()
			if self.nb_killed >= 5 then who:setQuestStatus(self.id, engine.Quest.COMPLETED) end
		end
	elseif self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		world:gainAchievement("ORCS_DONE_PALACE", who)
		if not who:isQuestStatus("orcs+quarry", engine.Quest.DONE) then world:gainAchievement("ORCS_PALACE_RUSH", who) end
		who:grantQuest("orcs+voyage")
	end
end

on_kill_boss = function(self)
	local kind = ({"COUNCIL3", "COUNCIL4", "COUNCIL5"})[self.nb_killed]
	local spot = game.level:pickSpot{type="pop", subtype="council"}
	if not kind or not spot then return end
	local x, y = util.findFreeGrid(spot.x, spot.y, 30, true, {[engine.Map.ACTOR]=true})

	-- Failsafe
	if not x then
		for i = 1, 200 do
			spot = game.level:pickSpot{type="pop", subtype="council-failsafe"}
			if spot then x, y = util.findFreeGrid(spot.x, spot.y, 30, true, {[engine.Map.ACTOR]=true}) end
			if x then break end
		end
	end
	if not x then return end

	local m = game.zone:makeEntityByName(game.level, "actor", kind)
	if not m then return end
	game.zone:addEntity(game.level, m, "actor", x, y)
	if kind ~= "COUNCIL5" then
		m:doEmote(_t"What is all this noise about!", 120)
	else
		for uid, e in pairs(game.level.entities) do if e.is_council_member then
			e:doEmote(_t"Tantalos! What have you done!", 120, colors.CRIMSON)
			e:setPersonalReaction(m, -100)
			e:setTarget(m)
		end end

		local floor = game.zone:makeEntityByName(game.level, "terrain", "LOCKED_DOOR_OPEN")
		local spot = game.level:pickSpotRemove{type="pop", subtype="gates"}
		while spot do
			game.zone:addEntity(game.level, floor, "terrain", spot.x, spot.y)
			game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
			spot = game.level:pickSpotRemove{type="pop", subtype="gates"}
		end
	end
end
