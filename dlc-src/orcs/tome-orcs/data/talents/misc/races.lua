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

------------------------------------------------------------------
-- Yetis' powers
------------------------------------------------------------------
newTalentType{ type="race/yeti", name = _t("yeti", "talent type"), generic = true, description = _t"The various racial bonuses a character can have." }
newTalent{
	name = "Algid Rage",
	type = {"race/yeti", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	requires_target = true,
	range = 1,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 46, 30)) end, -- Limit to >5 turns
	getPower = function(self, t) return self:combatStatScale("wil", 30, 50) end,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_ALGID_RAGE, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Your yeti is attuned to the cold climates.
		For 5 turns all damage you deal has %d%% chance to encase the target in an iceblock for 3 turns.
		While Algid Rage is up you easily pierce through iceblocks, reducing the damage they absorb by 50%%.
		The bonus will increase with your Willpower.]]):
		tformat(t.getPower(self, t))
	end,
}

newTalent{
	name = "Thick Fur",
	type = {"race/yeti", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getCResist = function(self, t) return 10 + self:combatTalentScale(t, 3, 20) end,
	getPResist = function(self, t) return 10 + self:combatTalentScale(t, 3, 10) end,
	getSave = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists",{
			[DamageType.COLD] = t.getCResist(self, t),
			[DamageType.PHYSICAL] = t.getPResist(self, t),
		})
		self:talentTemporaryValue(p, "combat_spellresist", t.getSave(self, t))
	end,
	info = function(self, t)
		return ([[Your yeti's fur acts like a shield, providing %d%% cold resistance, %d%% physical resistance and %d magical save.]]):
		tformat(t.getCResist(self, t), t.getPResist(self, t), t.getSave(self, t))
	end,
}

newTalent{
	name = "Resilient Body",
	type = {"race/yeti", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	heal = function(self, t) return 20 + self:getCon() * self:combatTalentLimit(t, 0.9, 0.2, 0.6) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "heal_on_detrimental_status", t.heal(self, t))
	end,
	info = function(self, t)
		return ([[Your yeti's body is very resilient to detrimental effects.
		Each time you are hit by a physical, magical, or mental detrimental effect your body reacts with a burst of healing.
		This effect heals for %d and can only occur up to 3 times per turn.
		It increases with your Constitution stat.]]):
		tformat(t.heal(self, t))
	end,
}

newTalent{
	name = "Mindwave",
	type = {"race/yeti", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end, -- Limit to >10
	tactical = { ATTACKAREA = {MIND=2}, DISABLE = {confusion=2} },
	getDamage = function(self, t) return self:combatStatScale("con", 50, 300) end,
	getDur = function(self, t) return self:combatTalentLimit(t, 8, 3, 5) end,
	radius = 5,
	range = 0,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false} end,
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)))
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, t.getDur(self, t), {power=35, apply_power=math.max(self:combatSpellpower(), self:combatMindpower(), self:combatPhysicalpower())})
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_spike", {radius=tg.radius, allow=core.shader.allow("distort")})
		return true
	end,
	info = function(self, t)
		return ([[You willingly fry a few parts of your yeti's brain to trigger a huge psionic blast in cone of radius %d.
		Any foes caught in the blast will suffer %0.2f mind damage and be confused (35%% power) for %d turns.
		The damage will increase with your Constitution and the apply power will be the highest of your mind, spell, or physical power.]]):
		tformat(t.radius, t.getDamage(self, t), t.getDur(self, t))
	end,
}

------------------------------------------------------------------
-- Whitehooves' powers
------------------------------------------------------------------
newTalentType{ type="race/whitehooves", name = _t("whitehooves", "talent type"), generic = true, description = _t"The various racial bonuses a character can have." }
newTalent{
	name = "Whitehooves",
	type = {"race/whitehooves", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	statBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 10, 0.75)) end,
	getMaxDamage = function(self, t) return math.max(50, 100 - self:getTalentLevelRaw(t) * 10) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inc_stats", {[self.STAT_STR]=t.statBonus(self, t)})
		self:talentTemporaryValue(p, "inc_stats", {[self.STAT_MAG]=t.statBonus(self, t)})
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy, x, y)
		if not moved or force or (ox == self.x and oy == self.y) then return end
		self:setEffect(self.EFF_DEATH_MOMENTUM, 2, {max_stacks=self:getTalentLevelRaw(t) + (self.DM_Bonus or 0)})
	end,
	info = function(self, t)
		return ([[Improves your undead body, increasing Strength and Magic by %d.
		Each time you move you gain a charge (up to %d) of death momentum, increasing your movement speed by 20%%.
		Each turn spent not moving you lose a charge.]])
		:tformat(t.statBonus(self, t), self:getTalentLevelRaw(t) + (self.DM_Bonus or 0))
	end,
}

newTalent{
	name = "Dead Hide",
	type = {"race/whitehooves", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getFlatResist = function(self, t) return math.floor(self:combatTalentScale(t, 1, 6)) end,
	info = function(self, t)
		return ([[Your undead skin hardens under stress. Each charge of death momentum also increases all flat damage resistance by %d.]]):
		tformat(t.getFlatResist(self, t))
	end,
}

newTalent{
	name = "Lifeless Rush",
	type = {"race/whitehooves", 3},
	require = racial_req3,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 46, 17)) end, -- Limit to >5 turns
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 10)) end,
	getDam = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	tactical = { BUFF = 2 },
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_DEATH_MOMENTUM, t.getDur(self, t), {force_stacks=true, max_stacks=self:getTalentLevelRaw(self.T_WHITEHOOVES) + (self.DM_Bonus or 0), stacks=self:getTalentLevelRaw(self.T_WHITEHOOVES) + (self.DM_Bonus or 0)})
		return true
	end,
	info = function(self, t)
		return ([[You summon your undead energies to instantly build up death momentum to its maximum possible charges.
		The effect will only start to decrease after %d turns.
		In addition, the death momentum effect also grants +%d%% to all damage per charge.]]):
		tformat(t.getDur(self, t), t.getDam(self, t))
	end,
}

newTalent{
	name = "Essence Drain",
	type = {"race/whitehooves", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end, -- Limit to >10
	tactical = { ATTACKAREA = {DARKNESS=2} },
	getDamage = function(self, t) return self:combatStatScale("mag", 50, 250) end,
	getDur = function(self, t) return self:combatTalentScale(t, 6, 12) end,
	radius = 5,
	range = 7,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_DEATH_MOMENTUM) end,
	target = function(self, t) return {type="hit", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false} end,
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local dam = DamageType:get(DamageType.DARKNESS).projector(self, px, py, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
			if dam and dam > 0 then
				local eff = self:hasEffect(self.EFF_DEATH_MOMENTUM)
				if eff then eff.dur = eff.dur + t.getDur(self, t) end
			end
		end, {type="bolt_dark"})
		return true
	end,
	info = function(self, t)
		return ([[You send a wave of darkness at your foe, dealing %0.2f darkness damage.
		The darkness will drain a part of its life essence (only works on living targets) to increase the duration before the next charge of death momentum is used by %d.
		Only usable when you have the death momentum effect.
		The damage scales with your Magic stat.]]):
		tformat(t.getDamage(self, t), t.getDur(self, t))
	end,
}
