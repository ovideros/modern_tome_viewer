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

_M.sustainCallbackCheck.callbackOnChaosEffect = "talents_on_chaos_effect"

local init = _M.init
function _M:init(t, no_default)
	t.insanity_regen = t.insanity_regen or -0.6
	return init(self, t, no_default)
end

function _M:insanityEffectForce(max)
	local i = self:getInsanity() / self:getMaxInsanity()
	return i^2 * (max or 50)
end

function _M:insanityEffect(min, max)
	if self:knowTalent(self.T_CONTROLLED_CHAOS) then
		min = self:callTalent(self.T_CONTROLLED_CHAOS, "getReduced") * min / 50
	end
	return rng.range(self:insanityEffectForce(min), self:insanityEffectForce(max))
end
	
-- Superloading incInsanity doesn't work here, I *think* because defineResource isn't called for it yet the first time this file is loaded
-- Not sure what the best approach is so I've just created the incInsanity function manually instead
function _M:incInsanity(amount, no_enemy_check)
	-- Assume 3 or less regen is a "passive" action we don't need to restrict
	if no_enemy_check or amount < 3 then
		self.insanity = util.bound(self.insanity + amount, self:getMinInsanity(), self:getMaxInsanity())
	else if self.in_combat then 
		self.insanity = util.bound(self.insanity + amount, self:getMinInsanity(), self:getMaxInsanity())
	else
		game.logSeen(self, "#ORCHID#You can only gain insanity in combat!#LAST#")
	end end
end

local getTalentCooldown = _M.getTalentCooldown
function _M:getTalentCooldown(t, base)

	local cd = t.cooldown or 0
	if type(cd) == "function" then cd = cd(self, t) end
	
	local eff = self:hasEffect(self.EFF_PROPHECY_OF_MADNESS)
	if eff and not self:attr("talent_reuse") and not (t.fixed_cooldown or base) then
		return cd + math.ceil(cd * eff.power)
	end
	local eff = self:hasEffect(self.EFF_DECAYING_GROUND)
	if eff and not self:attr("talent_reuse") and not (t.fixed_cooldown or base) then
		return cd + math.ceil(cd * eff.power)
	end
	
	return getTalentCooldown(self, t, base)
end

local alterTalentCost = _M.alterTalentCost
function _M:alterTalentCost(t, rname, cost)
	if rname == "insanity" or rname == "sustain_insanity" or rname == "drain_insanity" then
		cost = -cost
	end
	return alterTalentCost(self, t, rname, cost)
end

local base_checkTwoHandedPenalty = _M.checkTwoHandedPenalty
function _M:checkTwoHandedPenalty()
	base_checkTwoHandedPenalty(self)
	if self:hasTwoHandedWeapon() and self:knowTalent(self.T_MUTATED_HAND) and self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then
		self:setEffect(self.EFF_2H_PENALTY, 1, {})
		return
	end
end

local base_on_set_temporary_effect = _M.on_set_temporary_effect
function _M:on_set_temporary_effect(eff_id, e, p)
	
	
	if e.status == "detrimental" and e.type ~= "other" and self:attr("increase_detrimental_status_effects_time")  then
		p.dur = math.ceil(p.dur + (p.dur * self.increase_detrimental_status_effects_time))
	end
	
	if e.status == "beneficial" and e.type ~= "other" and self:attr("reduce_beneficial_status_effects_time")  then
		p.dur = math.ceil(p.dur * (1 - self.reduce_beneficial_status_effects_time))
	end
	
	return base_on_set_temporary_effect(self, eff_id, e, p)
end

-- Projects with a specified source and preserves the old one
function _M:projectSource(t, x, y, damtype, dam, particles, source)
	local old_source = self.__project_source
	self.__project_source = source
	self:project(t, x, y, damtype, dam, particles)
	self.__project_source = old_source
end

_M:bindHook("Actor:startTalentCooldown", function(self, data)
	if self:hasEffect(self.EFF_DREM_FRENZY) then
		local t = data.t
		if not t.is_inscription and not t.generic and not t.uber and not (t.mode and t.mode == "passive") and not t.fixed_cooldown and (not t.no_energy or t.no_energy == "fake") then
			local eff = self:hasEffect(self.EFF_DREM_FRENZY)
			if not eff.used_talents[t.id] then
				eff.used_talents[t.id] = true
				data.cd = 0
				return true
			end
		end
	end
	if self:getInsanity() > 0 then
		local ief = -self:insanityEffect(-50, 50)
		local ncd = data.cd + math.floor(data.cd * ief / 100)
		if ncd ~= data.cd then
			--game.logPlayer(self, "#INSANE_GREEN#Insanity chaotic effect on cooldown: %+d%%", ief)
			data.cd = ncd
			self:fireTalentCheck("callbackOnChaosEffect", "cooldown", ief, ncd)
			return true
		end
	end
end)

_M:bindHook("DamageProjector:base", function(self, data)
	if self.getInsanity and self:getInsanity() > 0 then
		local ief = self:insanityEffect(-50, 50)
		if ief ~= 0 then
			data.dam = data.dam + data.dam * ief / 100
			--game.logPlayer(self, "#INSANE_GREEN#Insanity chaotic effect on damage: %+d%%", ief)
			self:fireTalentCheck("callbackOnChaosEffect", "damage", ief, data.dam)
			return true
		end
	end
end)

return _M
