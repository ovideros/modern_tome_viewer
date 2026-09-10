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

_M:addCombatTraining("steamgun", "T_STEAMGUN_MASTERY")
_M:addCombatTraining("steamgun", "T_PSYSHOT")
_M:addCombatTraining("steamgun", "T_AUTOLOADER")
_M:addCombatTraining("steamsaw", "T_STEAMSAW_MASTERY")
_M:addCombatTraining("steamsaw", "T_OVERRUN")
_M:addCombatTraining("steamsaw", "T_METATEMPORAL_SPINNER")

local crossTierEffect = _M.crossTierEffect
function _M:crossTierEffect(eff_id, apply_power, apply_save, use_given_e)
	local ct = crossTierEffect(self, eff_id, apply_power, apply_save, use_given_e)

	if self:hasEffect(self.EFF_INCOMING_DISASTERS) and not self.turn_procs.master_of_disasters then
		self.turn_procs.master_of_disasters = true
		if ct == self.EFF_OFFBALANCE then
			self:crossTierEffect(self.EFF_SPELLSHOCKED, apply_power, nil, nil)
			self:crossTierEffect(self.EFF_BRAINLOCKED, apply_power, nil, nil)
		elseif ct == self.EFF_SPELLSHOCKED then
			self:crossTierEffect(self.EFF_OFFBALANCE, apply_power, nil, nil)
			self:crossTierEffect(self.EFF_BRAINLOCKED, apply_power, nil, nil)
		elseif ct == self.EFF_BRAINLOCKED then
			self:crossTierEffect(self.EFF_SPELLSHOCKED, apply_power, nil, nil)
			self:crossTierEffect(self.EFF_OFFBALANCE, apply_power, nil, nil)
		end
		self.turn_procs.master_of_disasters = nil
	end

	return ct
end

local combatMindpower = _M.combatMindpower
function _M:combatMindpower(mod, add)
	if self:isTalentActive(self.T_GESTALT) then
		add = (add or 0) + self:callTalent(self.T_GESTALT, "getMind") * self:getSteam() / self:getMaxSteam()
	end
	return combatMindpower(self, mod, add)
end

local combatSpellpower = _M.combatSpellpower
function _M:combatSpellpower(mod, add)
	if self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then
		add = (add or 0) + self:callTalent(self.T_TINKER_ARCANE_DYNAMO, "getSpellpower")
	end

	return combatSpellpower(self, mod, add)
end

--- Gets steampower
function _M:combatSteampowerRaw(add)
	if self.combat_precomputed_steampower then return self.combat_precomputed_steampower end
		
	add = add or 0

	if self.combat_generic_power then
		add = add + self.combat_generic_power
	end

	local p = self.combat_steampower or 0
	local d = (p > 0 and p or 0) + add + self:getCun()
	if self:attr("dazed") then d = d / 2 end

	if self:attr("hit_penalty_2h") then d = d * (1 - math.max(0, 20 - (self.size_category - 4) * 5) / 100) end

	return d
end

--- Gets steampower
function _M:combatSteampower(mod, add)
	mod = mod or 1
	return self:rescaleCombatStats(self:combatSteampowerRaw(add)) * mod
end

--- Scale for therapeutics
function _M:combatScaleTherapeutic(o, base, mult)
	local power = base + o.material_level * mult
	return self:combatScale(self:combatSteampower(), power / 2, 0, power, 100)
end

--- Gets damage based on talent
function _M:combatTalentSteamDamage(t, base, max)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return self:rescaleDamage((base + (self:combatSteampower())) * ((math.sqrt(self:getTalentLevel(t)) - 1) * 0.8 + 1) * mod)
end

--- Gets damage based on material level
function _M:combatMLSteamDamage(tl, base, max)
	-- Compute at "max"
	local mod = max / ((base + 100) * ((math.sqrt(5) - 1) * 0.8 + 1))
	-- Compute real
	return self:rescaleDamage((base + (self:combatSteampower())) * ((math.sqrt(tl) - 1) * 0.8 + 1) * mod)
end

--- Gets steamcrit
function _M:combatSteamCrit()
	local crit = (self.combat_steamcrit or 0) + (self.combat_generic_crit or 0) + (self:getCun() - 10) * 0.3 + (self:getLck() - 50) * 0.30 + 1

	return util.bound(crit, 0, 100)
end

--- Computes steam crit for a damage
function _M:steamCrit(dam, add_chance, crit_power_add)
	self.turn_procs.is_crit = nil

	crit_power_add = crit_power_add or 0
	local chance = self:combatSteamCrit() + (add_chance or 0)
	local crit = false

	if self:isTalentActive(self.T_STEALTH) and self:knowTalent(self.T_SHADOWSTRIKE) then
		chance = 100
	end

	print("[STEAM CRIT %]", chance)
	if rng.percent(chance) then
		self.turn_procs.is_crit = "steam"
		self.turn_procs.crit_power = (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		dam = dam * (1.5 + crit_power_add + (self.combat_critical_power or 0) / 100)
		crit = true
		game.logSeen(self, "#{bold}#%s's tinker attains critical power!#{normal}#", self:getName():capitalize())

		if self:knowTalent(self.T_EYE_OF_THE_TIGER) then self:triggerTalent(self.T_EYE_OF_THE_TIGER, nil, "steam") end

		self:fireTalentCheck("callbackOnCrit", "steam", dam, chance)
	end
	return dam, crit
end

-- Gets steamtech speed
function _M:combatSteamSpeed()
	return 1 / math.max(self.combat_steamspeed, 0.1)
end

local attackTargetWith = _M.attackTargetWith
function _M:attackTargetWith(target, weapon, damtype, mult, force_dam)
	mult = mult or 1
	if weapon and weapon.talented == "steamsaw" and self:attr("steamsaw_dam_mult") then
		mult = mult + self:attr("steamsaw_dam_mult") / 100
	end
	return attackTargetWith(self, target, weapon, damtype, mult, force_dam)
end

_M:bindHook("Combat:getDammod:subs", function(self, data)
	if data.combat.talented == 'shield' and self:knowTalent('T_STATIC_SHOCK') then data.sub('str', 'cun') end
	if data.combat.talented == 'steamsaw' and self:knowTalent('T_OVERRUN') then data.sub('str', 'dex') end
	if data.combat.talented == 'steamsaw' and self:isTalentActive('T_METATEMPORAL_SPINNER') then data.sub('str', 'mag') end
end)

return _M
