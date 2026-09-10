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
	name = "Bleak Outcome",
	type = {"corruption/black-magic", 1},
	require = corrs_req1,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_vim = 15,
	getStack = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 9)) end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if self.turn_procs.dont_apply_bleak_outcome then return end
		if self:hasEffect(self.EFF_OMINOUS_SHADOW) or self:hasEffect(self.EFF_GRIM_FUTURE) then return end
		if dead or not death_note or not death_note.damtype or target == self then return end
		if death_note.damtype ~= DamageType.DARKNESS and death_note.damtype ~= DamageType.FIRE and death_note.damtype ~= DamageType.ACID and death_note.damtype ~= DamageType.BLIGHT then return end
		self.turn_procs.bleak_outcome = self.turn_procs.bleak_outcome or {}
		if self.turn_procs.bleak_outcome[target] then return end

		target:setEffect(target.EFF_BLEAK_OUTCOME, 1, {src=self, max_stacks=t.getStack(self, t), max_reduce=self:knowTalent(self.T_STRIPPED_LIFE) and self:callTalent(self.T_STRIPPED_LIFE, "getStack") or 0})
		self.turn_procs.bleak_outcome[target] = true
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Your actions foreshadow a bleak outcome for your foes.
		Each time you deal darkness, fire, blight or acid damage you curse your foe with an effect that stacks up to %d times (this can happen only once per creature per turn).
		The vim you get for killing the creature is increased by 100%% for every stack of Bleak Outcome.
		The vim's worth of a creature depends on your Willpower.]]):
		tformat(t.getStack(self, t))
	end,
}

newTalent{
	name = "Weakened Soul", short_name = "STRIPPED_LIFE",
	type = {"corruption/black-magic", 2},
	require = corrs_req2,
	points = 5,
	mode = "passive",
	getStack = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 9)) end,
	info = function(self, t)
		return ([[For each stack of Bleak Outcome up to %d the afflicted creatures are weakened, reducing their resistances by 2%%.]])
		:tformat(t.getStack(self, t))
	end,
}

newTalent{
	name = "Grim Future",
	type = {"corruption/black-magic", 3},
	require = corrs_req3,
	points = 5,
	range = 7,
	vim = 8,
	requires_target = true,
	direct_hit = true,
	tactical = { attack = {DARKNESS=1}, BUFF=1 },
	cooldown = 15,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), custom_scan_filter=function(a) return a:hasEffect(a.EFF_BLEAK_OUTCOME) end} end,
	getStack = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 9)) end,
	getDam = function(self, t)
		-- Dont want double scaling. Ugh
		local old = self.talents[t.id]
		self.talents[t.id] = 1
		local v
		pcall(function() v = self:combatTalentSpellDamage(t, 20, 200) / 10 end) -- So paranoid
		self.talents[t.id] = old
		return v or 1
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target or not target:hasEffect(target.EFF_BLEAK_OUTCOME) then return end
		local eff = target:hasEffect(target.EFF_BLEAK_OUTCOME)

		local remove = math.min(eff.stacks, t:_getStack(self))
		eff.stacks = eff.stacks - remove
		if eff.stacks <= 0 then target:removeEffect(target.EFF_BLEAK_OUTCOME) end

		self:setEffect(self.EFF_GRIM_FUTURE, 6, {power=remove * 4})
		self.turn_procs.dont_apply_bleak_outcome = true
		DamageType:get(DamageType.DARKNESS).projector(self, x, y, DamageType.DARKNESS, self:spellCrit(t:_getDam(self)) * remove)
		self.turn_procs.dont_apply_bleak_outcome = nil
		game.level.map:particleEmitter(self.x, self.y, tg.range, "grim_future", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		return ([[The future looks grim indeed... for your foes.
		You can target a creature affected by Bleak Outcome to consume up to %s stacks, dealing %0.2f darkness damage to it for every stack and increasing your Spellpower by 4 per stacks for 6 turns.
		While powered-up you can not apply new Bleak Outcome stacks.		
		Damage is based on your Spellpower.]]):
		tformat(t.getStack(self, t), damDesc(self, DamageType.DARKNESS, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Ominous Shadow",
	type = {"corruption/black-magic", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 15,
	vim = 10,
	requires_target = true,
	direct_hit = true,
	tactical = { ESCAPE=1, BUFF=1 },
	range = 7,
	no_energy = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), custom_scan_filter=function(a) return a:hasEffect(a.EFF_BLEAK_OUTCOME) end} end,
	getInvisibilityPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 70) end,
	getStack = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 9)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target or not target:hasEffect(target.EFF_BLEAK_OUTCOME) then return end
		local eff = target:hasEffect(target.EFF_BLEAK_OUTCOME)

		local remove = math.min(eff.stacks, t:_getStack(self))
		eff.stacks = eff.stacks - remove
		if eff.stacks <= 0 then target:removeEffect(target.EFF_BLEAK_OUTCOME) end

		self:setEffect(self.EFF_OMINOUS_SHADOW, remove, {power=t:_getInvisibilityPower(self)})
		game.level.map:particleEmitter(self.x, self.y, tg.range, "grim_future", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		return ([[By gorging yourself on up to %d stacks of Bleak Outcome from a creature, you turn into an Ominous Shadow for one turn per stack.
		While transformed you are invisible (power %d), convert 100%% of all damage done to darkness and gain darkness resistance penetration and damage increase equal to your highest.
		While transformed you can not apply new Bleak Outcome stacks.]]):
		tformat(t.getStack(self, t), t.getInvisibilityPower(self, t))
	end,
}
