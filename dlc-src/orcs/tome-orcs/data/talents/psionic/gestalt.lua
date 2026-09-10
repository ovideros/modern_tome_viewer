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

newTalent{
	name = "Gestalt",
	type = {"psionic/gestalt", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "sustained",
	cooldown = 15,
	sustain_psi = 10,
	tactical = { BUFF = 2 },
	getMind = function(self, t) return self:combatTalentStatDamage(t, "wil", 5, 600) / 10 end,
	getSteam = function(self, t) return self:combatTalentStatDamage(t, "wil", 5, 500) / 10 end,
	getPsi = function(self, t) return math.ceil(self:combatTalentScale(t, 8, 29)) end,
	callbackOnTalentPost = function(self, t, ab, ret, silent)
		if ab.is_mind then
			game:onTickEnd(function() self:setEffect(self.EFF_GESTALT_STEAM, 1, {power=t.getSteam(self, t)}) end)
		end
		if ab.is_steam then
			self:incPsi(t.getPsi(self, t))
		end
		if (ab.is_steam or ab._trigger_improved_gestalt) and self:knowTalent(self.T_IMPROVED_GESTALT) and not self:isTalentCoolingDown(self.T_IMPROVED_GESTALT) then
			self:setEffect(self.EFF_PSI_DAMAGE_SHIELD, 3, {shield_transparency=0.4, power=self:callTalent(self.T_IMPROVED_GESTALT, "getShieldPower")})
			self:startTalentCooldown(self.T_IMPROVED_GESTALT)
		end
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You let your mind tap into your steam generators for energy, increasing your Mindpower in proportion to your steam level: %d when at full steam and 0 when at 0 steam.
		Using a psionic talent will feedback into your generators, increasing your Steam power by %d for your next steamtech talent.
		Using a steamtech talent will feedback into psionic focus, increasing your psi level by %d.
		The effects increase with your Willpower.]]):
		tformat(t.getMind(self, t), t.getSteam(self, t), t.getPsi(self, t))
	end,
}

newTalent{
	name = "Improved Gestalt",
	type = {"psionic/gestalt", 2},
	points = 5,
	mode = "passive",
	require = psi_wil_req2,
	cooldown = 5,
	getShieldPower = function(self, t) return self:combatTalentMindDamage(t, 10, 140) end,
	info = function(self, t)
		local shield_power = t.getShieldPower(self, t)
		return ([[When you use a steamtech talent while Gestalt is active you drain some residual power to form a psionic shield.
		The shield forms for 3 turns and absorbs %d damage.
		The effects increase with your Mindpower.]]):tformat(shield_power)
	end,
}

newTalent{
	name = "Instant Channeling",
	type = {"psionic/gestalt", 3},
	points = 5,
	cooldown = 12,
	require = psi_wil_req3,
	steam = function(self, t) return self:getSteam() end,
	no_energy = true,
	tactical = { DEFEND = 2, PSI = 2 },
	_trigger_improved_gestalt = true,
	getPower = function(self, t) return self:combatTalentScale(t, 80, 370) end,
	getPsi = function(self, t) return self:combatTalentScale(t, 25, 50) end,
	on_pre_use = function(self, t, silent, fake)
		if not self:isTalentActive(self.T_GESTALT) or (not self:hasEffect(self.EFF_PSI_DAMAGE_SHIELD) and self:isTalentCoolingDown(self.T_IMPROVED_GESTALT)) then
			if not silent then game.logPlayer(self, "You must have either a psionic damage shield active or Improved Gestalt available to use this talent.") end
			return
		end
		return true
	end,
	action = function(self, t)
		if not self:isTalentActive(self.T_GESTALT) then return end
		local steam = self:getSteam()
		local eff = self:hasEffect(self.EFF_PSI_DAMAGE_SHIELD)
		if not eff then 
			if not self:isTalentCoolingDown(self.T_IMPROVED_GESTALT) then -- trigger improved gestalt
				self:callTalent(self.T_GESTALT, "callbackOnTalentPost", t, nil, true)
				eff = self:hasEffect(self.EFF_PSI_DAMAGE_SHIELD)
			else return
			end
		end
		if eff then
			eff.dur = eff.dur + 3
			local add = self:mindCrit(t.getPower(self, t) * steam / 100)
			self.damage_shield_absorb = self.damage_shield_absorb + add
		end
		local psi = self:mindCrit(t.getPsi(self, t) * steam / 100)
		self:incPsi(psi)
		return true
	end,
	info = function(self, t)
		return ([[Instantly channel all of your remaining steam to replenish your psi energies and either enhance your active psionic damage shield or trigger a new one.
		The (new or existing) shield duration is increased by 3 turns and its power is boosted by %d%% of the steam used.
		You restore psi equal to %d%% of the steam used.
		This talent requires Gestalt to be active and either an active psionic damage shield or Improved Gestalt off cooldown.]]):tformat(t.getPower(self, t), t.getPsi(self, t))
	end,
}

newTalent{
	name = "Forced Gestalt",
	type = {"psionic/gestalt", 4},
	points = 5,
	psi = 30,
	steam = 30,
	cooldown = 20,
	require = psi_wil_req4,
	tactical = { ANNOY = 2, BUFF = 2 },
	requires_target = true,
	radius = 5,
	target = function(self, t) return {type="ball", range=0, radius=self:getTalentRadius(t), talent=t} end,
	getSenseRadius = function(self, t) return math.floor(self:combatTalentLimit(t, 20, 8, 18)) end,
	getNb = function(self, t) return math.floor(self:combatTalentLimit(t, 25, 1.1, 5, false, 1.0)) end,
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 45) end,
	on_pre_use = function(self, t) return self:isTalentActive(self.T_GESTALT) end,
	action = function(self, t)
		self:setEffect(self.EFF_SENSE, 5, {
			range = t.getSenseRadius(self, t),
			actor = 1,
		})

		local tg = self:getTalentTarget(t)
		local tgts = {}
		self:project(tg, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) >= 0 then return end
			tgts[#tgts+1] = act
		end)
		local power = t.getPower(self, t)
		local add, nb = 0, 0
		for i = 1, t.getNb(self, t) do
			local target = rng.tableRemove(tgts)
			if not target then break end
			target:setEffect(target.EFF_FORCED_GESTALT_FOE, 5, {apply_power=self:combatMindpower(), power=power})
			if target:hasEffect(target.EFF_FORCED_GESTALT_FOE) then
				add = add + power / (2 ^ nb)
				nb = nb + 1
			end
		end
		if nb > 0 then
			self:setEffect(self.EFF_FORCED_GESTALT, 5, {power=add})
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Temporarily expand your mind to force your Gestalt upon your foes in a radius of 5. Up to %d foe(s) will be affected.
		The Gestalt will drain each affected foe's powers (physical power, mind power, spell power and steam power) by %d for 5 turns.
		Your own powers will be increased in return by the drained amount (reduced for each additional foe).
		In addition for 5 turns you can sense creatures beyond your sight, even through walls in radius %d.
		The effects improve with your Mindpower.]]):tformat(t.getNb(self, t), t.getPower(self, t), t.getSenseRadius(self, t))
	end,
}
