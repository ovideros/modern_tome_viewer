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

local move = _M.move
function _M:move(x, y, force)
	local moved = move(self, x, y, force)

	-- Little hack, only works for the player :/
	local p = game.player
	if self.src ~= p and p:knowTalent(p.T_AUTOMATED_REFLEX_SYSTEM) and not p:isTalentCoolingDown(p.T_AUTOMATED_REFLEX_SYSTEM) then
		if math.abs(x - p.x) <= 1 and math.abs(y - p.y) <= 1 then
			game.bignews:saySimple(60, "#PURPLE#Automated Reflex System activated!")
			game.log("#PURPLE#Automated Reflex System activated!")
			game.paused = true
			p.energy.value = p.energy.value + game.energy_to_act
			p:startTalentCooldown(p.T_AUTOMATED_REFLEX_SYSTEM)
		end
	end

	return moved
end

return _M
