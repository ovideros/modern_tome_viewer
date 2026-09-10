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

local Object = require "engine.Object"

newTalent{
	name = "Metalstar",
	type = {"steamtech/mechstar", 1},
	points = 5,
	cooldown = 15,
	steam = 20,
	psi = 6,
	require = steamreq1,
	tactical = { DISABLE={stun=1, knockback=1} },
	radius = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 7)) end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 9)) end,
	getKnockback = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 4)) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), talent=t, friendlyfire=false} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:canBe("knockback") then target:knockback(self.x, self.y, t.getKnockback(self, t)) end
			if target:canBe("stun") then target:setEffect(target.EFF_DAZED, t.getDur(self, t), {apply_power=self:combatSteampower()}) end
			if self:knowTalent(self.T_BLOODSTAR) then
				self:callTalent(self.T_BLOODSTAR, "applyOn", target)
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[Quickly aggregate particles of metal around your mindstar and focus psionic energies into it.
		The metal explodes like shrapnel, knocking back (%d away) and dazing (%d duration) all foes in radius %d.]])
		:tformat(t.getKnockback(self, t), t.getDur(self, t), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Bloodstar",
	type = {"steamtech/mechstar", 2},
	points = 5,
	mode = "passive",
	require = steamreq2,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 6)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 25, 250) / 6 end,
	applyOn = function(self, t, target)
			-- No save check because one long cooldown action is linked to 4 different talents
			local mt = self:getTalentFromId(self.T_METALSTAR)
			local params = {src=self, dam=t.getDamage(self, t), free=self:getTalentRadius(mt) * 2}
			
			if self:knowTalent(self.T_STEAMSTAR) then
				params.steamstar = {dam=self:callTalent(self.T_STEAMSTAR, "getDamage"), steam=self:callTalent(self.T_STEAMSTAR, "getSteam")}
			end

			target:setEffect(target.EFF_BLOODSTAR, t.getDur(self, t), params)
	end,
	info = function(self, t)
		local mt = self:getTalentFromId(self.T_METALSTAR)
		return ([[When you fire your metalstar, your also establish a psionic bloodlink with the shrapnel still inside for %d turns.
		Each turn the victims are drained for %0.2f physical damage, half of which heals you (each additional victim healing is reduced by half).
		If the victim move more than twice away from the radius of Metalstar (currently %d) the effect stops.
		This damage does not break daze and increases with your Steampower.]])
		:tformat(t.getDur(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), self:getTalentRadius(mt) * 2)
	end,
}

newTalent{
	name = "Steamstar",
	type = {"steamtech/mechstar", 3},
	points = 5,
	mode = "passive",
	require = steamreq3,
	getSteam = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 10)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 25, 250) / 6 end,
	info = function(self, t)
		local mt = self:getTalentFromId(self.T_METALSTAR)
		return ([[Your bloodstar effect also burns part of your victim's flesh, dealing %0.2f fire damage.
		The intensity of the fire generates steam which you psionically absorb through gestalt, providing %d steam each turn (each additional victim steam generation is reduced by 66%%).
		This damage does not break daze and increases with your Steampower.]])
		:tformat(damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getSteam(self, t))
	end,
}

newTalent{
	name = "Deathstar",
	type = {"steamtech/mechstar", 4},
	points = 5,
	mode = "passive",
	require = steamreq4,
	getReduct = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if not hitted or not talent or not talent.is_psyshot then return end
		if not target:hasEffect(target.EFF_BLOODSTAR) then return end
		local tids = {}
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.is_psyshot and tid ~= talent.id then tids[#tids+1] = tid end
		end
		if #tids > 0 then self:alterTalentCoolingdown(rng.table(tids), -t.getReduct(self, t)) end
	end,
	info = function(self, t)
		return ([[When you use a shoot class talent to hit a creature affected by bloodstar an other shoot talent will have its current cooldown reduced by %d turns.]])
		:tformat(t.getReduct(self, t))
	end,
}
