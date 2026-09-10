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
	name = "Furnace",
	type = {"steamtech/furnace", 1},
	points = 5,
	require = steamreq_high1,
	mode = "sustained",
	cooldown = 3,
	drain_steam = 2,
	tactical = { BUFF=1 },
	getFireDamageIncrease = function(self, t) return self:combatTalentScale(t, 2.5, 10) end,
	getResistPenalty = function(self, t) return self:combatTalentLimit(t, 40, 5, 25) end, --Limit < 100%
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t), [DamageType.PHYSICAL] = t.getFireDamageIncrease(self, t)})
		self:talentTemporaryValue(ret, "resists_pen", {[DamageType.FIRE] = t.getResistPenalty(self, t), [DamageType.PHYSICAL] = t.getResistPenalty(self, t)})
		self:addShaderAura("furnace", "awesomeaura", {time_factor=5500, alpha=0.6, flame_scale=0.6}, "particles_images/wings.png")
		game:playSoundNear(self, "talents/fire")
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeEffect(self.EFF_FURNACE_MOLTEN_POINT, true, true)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getFireDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[You add a portable furnace to your steam generators.
		While it is active your fire and physical damage increases by %d%% and your fire and physical resistance penetration by %d%%.
		#{italic}#Burninate all with awesome Steam power!#{normal}#
		]]):
		tformat(damageinc, ressistpen)
	end,
}

newTalent{
	name = "Molten Metal",
	type = {"steamtech/furnace", 2},
	points = 5,
	mode = "passive",
	require = steamreq_high2,
	getResist = function(self, t) return 10 + self:getTalentLevel(t) * 7 end,
	callbackOnRest = function(self, t) self:removeEffect(self.EFF_FURNACE_MOLTEN_POINT, true, true) end,
	callbackOnRun = function(self, t) self:removeEffect(self.EFF_FURNACE_MOLTEN_POINT, true, true) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if not self:isTalentActive(self.T_FURNACE) then return end
		if type == DamageType.PHYSICAL or type == DamageType.MIND then return end
		
		local mp = self:hasEffect(self.EFF_FURNACE_MOLTEN_POINT)
		local reduction = 1
		if mp then reduction = 0.75 ^ mp.stacks end
		reduction = t.getResist(self, t) * reduction

		if mp and mp.stacks >= 10 and self:isTalentActive(self.T_MELTING_POINT) and self:getSteam() > 15 then
			self:callTalent(self.T_MELTING_POINT, "cleanActor")
			if not self.turn_procs.molten_furnace_trigger_vent then
				self.turn_procs.molten_furnace_trigger_vent = true
				self:forceUseTalent(self.T_FURNACE_VENT, {ignore_energy=true, force_target={x=src.x, y=src.y}})
			end
			self:removeEffect(self.EFF_FURNACE_MOLTEN_POINT, true, true)
		end

		if not self.turn_procs.molten_metal then self:setEffect(self.EFF_FURNACE_MOLTEN_POINT, 1, {}) end
		self.turn_procs.molten_metal = true

		return {dam=math.max(0, dam - reduction)}
	end,
	info = function(self, t)
		local reduction = 1
		local mp = self:hasEffect(self.EFF_FURNACE_MOLTEN_POINT)
		if mp then reduction = 0.75 ^ mp.stacks end
		return ([[While Furnace is on your armour is so hot from the furnace it dissipates parts of all energy based attacks against you.
		All non physical, non mind damage is reduced by %d (current %d).
		Each turn this happens you gain a molten point (up to 10), decreasing the efficiency of the reduction by 25%%.
		Molten points are removed upon running or resting.
		#{italic}#Hot liquid metal, the fun!#{normal}#
		]]):tformat(t.getResist(self, t), t.getResist(self, t) * reduction)
	end,
}


newTalent{
	name = "Furnace Vent",
	type = {"steamtech/furnace", 3},
	points = 5,
	require = steamreq_high3,
	steam = 15,
	tactical = {
		ATTACKAREA = function(self, t, aitarget)
			local mp = self:hasEffect(self.EFF_FURNACE_MOLTEN_POINT)
			if not mp then return nil end
			local stacks = mp.stacks
			if stacks >= 10 then return {FIRE = 3} end
		end,
	},		
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, 0.5, 0, 0, true)) end,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 400) end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_FURNACE_MOLTEN_POINT) end,
	action = function(self, t)
		local mp = self:hasEffect(self.EFF_FURNACE_MOLTEN_POINT)
		if not mp then return nil end
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local stacks = mp.stacks
		self:removeEffect(self.EFF_FURNACE_MOLTEN_POINT, true, true)
		self:project(tg, x, y, DamageType.FIRE, self:steamCrit(t.getDamage(self, t) * stacks / 10))

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local mp = self:hasEffect(self.EFF_FURNACE_MOLTEN_POINT)
		local stacks = mp and mp.stacks or 0
		return ([[Open the vents on your furnace, creating a conic blast dealing up to %0.2f fire damage at 10 molten points (currently %0.2f).
		All molten points are consumed.
		The damage will increase with your Steampower.
		#{italic}#By fire be purged!#{normal}#
		]]):
		tformat(damDesc(self, DamageType.FIRE, damage), damDesc(self, DamageType.FIRE, damage) * stacks / 10)
	end,
}

newTalent{
	name = "Melting Point",
	type = {"steamtech/furnace", 4},
	points = 5,
	require = steamreq_high4,
	mode = "sustained",
	cooldown = function(self, t) return self:combatTalentLimit(t, 10, 20, 15) end,
	tactical = { BUFF=1 },
	getNb = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	cleanActor = function(self, t)
		local nb = t.getNb(self, t)
		self:removeEffectsFilter(self, {status="detrimental", type="physical"}, nb)
		self:incSteam(-15)
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[When you reach 10 molten points your armour overheats, reaching temperatures so high that they cauterize up to %d detrimental physical effects on you.
		A special medical injector injects you with a fire immunity serum at that precise moment to make you immune to the burning effect.
		When this happens all molten points are consumed and trigger a Furnace Vent at the creature that triggered the last molten point.
		This effect drains 15 steam when triggered, and will not trigger if steam is too low.
		#{italic}#It's only a flesh burn!#{normal}#
		]]):
		tformat(t.getNb(self, t))
	end,
}
