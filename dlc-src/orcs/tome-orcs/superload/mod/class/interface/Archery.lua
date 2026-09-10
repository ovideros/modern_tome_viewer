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
local DamageType = require "engine.DamageType"

_M:bindHook("Combat:archeryTargetKind", function(self, data)
	if not self:hasEffect(self.EFF_ENHANCED_BULLETS_SUPERCHARGE) then return end
	local eff = self:hasEffect(self.EFF_ENHANCED_BULLETS_SUPERCHARGE)
	if data.weapon and data.weapon.talented == "steamgun" then
		if data.mode == "target" then
			if (not data.tg.type or data.tg.type == "bolt") and not data.tg.no_supercharge_bullet then
				data.tg.type = "beam"
				data.params.one_shot = true
			end
		elseif data.mode == "fire" then
			if (not data.tg.type or data.tg.type == "bolt") and not data.tg.no_supercharge_bullet then
				data.tg.type = "beam"
				data.params.apr = eff.power
			end
		end
	end
end)

-- Tag bullets with bullet enhancements
_M:bindHook("Combat:archeryFire", function(self, data)
	if not (data.weapon and data.weapon.talented == "steamgun") then return end
	local eff = self:hasEffect(self.EFF_ENHANCED_BULLETS_OVERHEAT) or self:hasEffect(self.EFF_ENHANCED_BULLETS_PERCUSIVE) or self:hasEffect(self.EFF_ENHANCED_BULLETS_COMBUSTIVE)
	if not eff then return end
	data.tg.bullet_effect = eff
	return true
end)

_M:bindHook("Combat:archeryDamage", function(self, data)
	if not data.target then return end
	if data.target:hasEffect(data.target.EFF_STARTLING_SHOT) then
		local eff = data.target:hasEffect(data.target.EFF_STARTLING_SHOT)
		data.mult = data.mult * eff.power
		data.target:removeEffect(data.target.EFF_STARTLING_SHOT)
	end
	return true
end)

-- apply bullet enhancements to targets hit
_M:bindHook("Combat:archeryHit", function(self, data)
	if not data.hitted then return end

	local eff = data.tg and data.tg.bullet_effect
	if not eff then return end
	if data.weapon and data.weapon.talented == "steamgun" and eff then
		-- note: can adjust these effects after hit here (to balance them)
		if eff.kind == "overheated" then
			data.target:setEffect(data.target.EFF_BURNING, 5, {power=eff.power / 5, src=self})
		elseif eff.kind == "percusive" then
			if rng.percent(eff.power) and data.target:checkHit(self:combatSteampower(), data.target:combatPhysicalResist(), 0, 95, 15) and data.target:canBe("knockback") then
				data.target:knockback(self.x, self.y, 3)
				data.target:crossTierEffect(data.target.EFF_OFFBALANCE, self:combatSteampower())
				game.logSeen(data.target, "%s is knocked back!", data.target:getName():capitalize())
			end
			if rng.percent(eff.stunpower) and data.target:checkHit(self:combatSteampower(), data.target:combatPhysicalResist(), 0, 95, 15) and data.target:canBe("stun") then
				data.target:setEffect(data.target.EFF_STUNNED, 3, {})
				data.target:crossTierEffect(data.target.EFF_OFFBALANCE, self:combatSteampower())
				game.logSeen(data.target, "%s is knocked back!", data.target:getName():capitalize())
			end
		elseif eff.kind == "combustive" then
			local tg = {type="ball", radius=2, x=data.target.x, y=data.target.y, selffire=false, friendlyfire=false}
			self:project(tg, data.target.x, data.target.y, DamageType.FIRE, eff.power)
			game.level.map:particleEmitter(data.target.x, data.target.y, 2, "ball_fire", {radius=2})
		end
	end
end)

return _M
