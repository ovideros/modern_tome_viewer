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

local getStatDesc = _M.getStatDesc
function _M:getStatDesc(item)
	local text = getStatDesc(self, item)

	if self.actor:knowTalent(self.actor.T_STEAM_POOL) then
		local stat_id = item.stat
		local diff = self.actor:getStat(stat_id, nil, nil, true) - self.actor_dup:getStat(stat_id, nil, nil, true)
		local color = diff >= 0 and {"color", "LIGHT_GREEN"} or {"color", "RED"}
		local dc = {"color", "LAST"}

		if stat_id == self.actor.STAT_CUN then
			text:add(_t"Steampower: ", color, ("%0.2f"):format(diff), dc, true)
		end
	end

	return text
end

return _M
