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

local Map = require "engine.Map"
local Particles = require "engine.Particles"
local DamageType = require "engine.DamageType"

local _M = loadPrevious(...)

_M:addCombatTraining("tentacles", "T_MUTATED_HAND")

local attackTargetWith = _M.attackTargetWith
function _M:attackTargetWith(target, weapon, damtype, ...)
	local speed, hit, dam = attackTargetWith(self, target, weapon, damtype, ...)

	if weapon and self:knowTalent(self.T_MUTATED_HAND) and not self:attr("tentacle_hand_prevent") and self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") and weapon.talented ~= "tentacles" then
		self:attr("tentacle_hand_prevent", 1)
		local tcombat = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		local tdamtype = damtype
		if not tdamtype or tdamtype == DamageType.PHYSICAL then tdamtype = tcombat.damtype end
		local speed, hit = self:attackTargetWith(target, tcombat, tdamtype, ...)
		if hit then game:playSoundNear(self, tcombat.sound) else game:playSoundNear(self, tcombat.sound_miss) end

		local dir = util.getDir(target.x, target.y, self.x, self.y) or 6
		local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
		local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		if lt and self:reactionToward(lt) < 0 then
			self:attackTargetWith(lt, tcombat, tdamtype, ...)
		end
		if rt and self:reactionToward(rt) < 0 then
			self:attackTargetWith(rt, tcombat, tdamtype, ...)
		end

		if self:reactionToward(target) <= 0 and not self.turn_procs.tentacle_insanity_gain then 
			self:incInsanity(self:callTalent(self.T_MUTATED_HAND, "getInsanityBonus"))
			self.turn_procs.tentacle_insanity_gain = true
		end

		local hx, hy = self:attachementSpot(self._flipx and "hand1" or "hand2", true)
		local ps = Particles.new("tentacle_lash", 1, {dir=math.deg(math.atan2(target.y-self.y, target.x-self.x)+math.pi/2)})
		ps.dx = hx ps.dy = hy self:addParticles(ps)

		self:attr("tentacle_hand_prevent", -1)
	end

	return speed, hit, dam
end

return _M
