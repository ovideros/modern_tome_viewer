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

uberTalent{
	name = "Subcutaneous Metallisation",
	mode = "passive",
	require = { talent={{"T_THICK_SKIN", 5}} },
	cooldown = 12,
	callbackOnHit = function(self, t, cb, src)
		if self:isTalentCoolingDown(t.id) then return end
		if self.life - cb.value < self.max_life * 0.5 and self.life > self.max_life * 0.5 then
			self:setEffect(self.EFF_SUBCUTANEOUS_METALLISATION, 5, {power=math.floor(self:getCon() * 1)})
			self:startTalentCooldown(t)
		end
	end,
	info = function(self, t)
		return ([[When your life dips below 50%% of your total life an automated process turns some of your lower skin layers (or other internal organs) into a thick metallic layer for 6 turns.
		While the effect lasts all damage done to you is reduced by a flat amount equal to 100%% of your Constitution.
		This effect can only trigger once every %d turns.]])
		:tformat(self:getTalentCooldown(t))
	end,
}
