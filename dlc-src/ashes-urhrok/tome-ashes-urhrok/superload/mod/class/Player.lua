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

local die = _M.die
function _M:die(src, ...)
	local ret = die(self, src, ...)

	if src and ((src.resolveSource and src:resolveSource().player) or src.player) then
		if self.type == "demon" then
			local p = game.party:findMember{main=true}
			world:gainAchievement("ASHES_DEMO", p, self)
		end
	end

	return ret
end

local function checkSeed(self, inven, pos)
	local inven = self:getInven(inven)
	if not inven or not inven[pos] then return end
	if not inven[pos].tinker or inven[pos].tinker.is_tinker ~= "demon-seed" then return end
	return true
end

local doWearTinker = _M.doWearTinker
function _M:doWearTinker(...)
	local ok, base_o = doWearTinker(self, ...)

	if ok and self.can_tinker and self.can_tinker['demon-seed'] then
		if      checkSeed(self, "MAINHAND", 1) and
			checkSeed(self, "OFFHAND", 1) and
			checkSeed(self, "BODY", 1) and 
			checkSeed(self, "FINGER", 1) and 
			checkSeed(self, "FINGER", 2) then
			game:setAllowedBuild("cosmetic_red_skin", true)
		end
	end

	return ok, base_o
end

return _M
