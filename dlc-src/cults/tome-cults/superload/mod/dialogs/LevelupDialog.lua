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

local _M = loadPrevious(...)

local finish = _M.finish
function _M:finish(...)
	local ret = finish(self, ...)

	-- Check for parasite tree
	if self.actor:knowTalentType("race/parasite") and self.actor:getTalentLevelRaw(self.actor.T_TAKE_A_BITE) >= 5 and self.actor:getTalentLevelRaw(self.actor.T_ULTRA_INSTINCT) >= 5 and self.actor:getTalentLevelRaw(self.actor.T_CORRUPTING_INFLUENCE) >= 5 and self.actor:getTalentLevelRaw(self.actor.T_HORROR_SHELL) >= 5 then
		world:gainAchievement("CULTS_PARASITE", self.actor)
	end

	return ret
end

return _M
