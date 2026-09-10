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

local Object = require "mod.class.Object"

newTalent{
	name = "Atrophy",
	type = {"demented/chronophage", 1},
	require = dementedreq_high1,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	tactical = { BUFF = 2 },
	iconOverlay = function(self, t, p)
		local p = self.sustain_talents[t.id]
		if not p or not self.atrophy_count then return "" end
		return tostring(self.atrophy_count), "buff_font_smaller"
	end,
	getStat = function(self, t) return math.floor(self:combatTalentLimit(t, 4, 1.3, 2.3)) end,
	getStacks = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	getMaxStacks = function(self, t) return 10 end,
	updateStacks = function(self, t)
		if not self.atrophy_targets then return end
		local count = 0
		local todel = {}
		for act, _ in pairs(self.atrophy_targets) do
			if act and act.hasEffect then
				local eff = act:hasEffect(act.EFF_ATROPHY)
				if not eff or act.dead or not act.x then 
					todel[#todel+1] = act
				else
					count = count + eff.charges
				end 
			end
		end
		
		for _, act in pairs(todel) do
			self.atrophy_targets[act] = nil
		end

		self.atrophy_count = count
	end,
	callbackOnChangeLevel = function(self)
		self.atrophy_targets = nil
		self.atrophy_count = 0
	end,
	callbackOnTalentPost = function(self, t, ab)
		if ab.mode == "sustained" then return end
		if ab.is_spell and not ab.no_energy then
			local radius = 10
			local grids = core.fov.circle_grids(self.x, self.y, radius, true)
			local targets = {}
			for x, yy in pairs(grids) do
				for y, _ in pairs(grids[x]) do
					local target = game.level.map(x, y, Map.ACTOR)
					if target and self:reactionToward(target) < 0 then
						local eff = target:hasEffect(target.EFF_ATROPHY)
						targets[#targets+1] = {target,0}
					end
				end
			end
			for i = 1, t.getStacks(self, t) do
				if #targets == 0 then break end
				local act, index = rng.table(targets)
				local target = act[1]
				act[2] = act[2] + 1
				if act[2] >= 2 then table.remove(targets, index) end
				target:setEffect(target.EFF_ATROPHY, 8, {src = self, power = t.getStat(self, t), max_charges = t.getMaxStacks(self, t), charges = 1, src = self})
				if self:knowTalent(self.T_SEVERED_THREADS) then
					local life = self:callTalent(self.T_SEVERED_THREADS, "getLife")
					local dur = self:callTalent(self.T_SEVERED_THREADS, "getDuration")
					local power = self:callTalent(self.T_SEVERED_THREADS, "getPower")														
					if target.life <= (target.max_life * life) and target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") then
						game.logSeen(target, "%s has been cut from the timeline!", target:getName():capitalize())
						target:die(self)
						self:setEffect(self.EFF_INVIGORATE, dur, {power=power})
					end
				end
				if self:knowTalent(self.T_TEMPORAL_FEAST) and target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("slow") then
					local eff = target:hasEffect(target.EFF_ATROPHY)
					if eff then
						local energyDrain = (game.energy_to_act * self:callTalent(self.T_TEMPORAL_FEAST, "getSlow"))
						target.energy.value = target.energy.value - energyDrain
						self:setEffect(self.EFF_TEMPORAL_FEAST, 5, {src = self, power = self:callTalent(self.T_TEMPORAL_FEAST, "getSpeed"), max_charges = t.getStacks(self,t), charges = eff.charges})
					end
				end
			end
		end
		t.updateStacks(self, t)
	end,
	-- Ideally only update this when the UI is displayed, but this works well enough
	callbackOnAct = function(self, t)
		t.updateStacks(self, t)
	end,
	callbackOnActBase = function(self, t)
		t.updateStacks(self, t)
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/atrophy_cast")
		local ret = {}

		if core.shader.allow("adv") then
			ret.particle1, ret.particle2 = self:addParticles3D("volumetric", {kind="conic_cylinder", twist=1, shineness=50, density=50, radius=1.4, growSpeed=0.004, img="atrophy_buff"})
		end

		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end
		return true
	end,
	info = function(self, t)
		return ([[You are surrounded by a vortex of entropic energy that feeds on the timelines of others. Each time you cast a spell random targets in radius 10 begin rapidly aging and decaying, reducing all stats by %d for 8 turns, stacking up to %d times.
			Up to %d stacks total will be applied to enemies each cast with a max of 2 stacks on the same target.]]):
		tformat(t.getStat(self, t), t.getMaxStacks(self, t), t.getStacks(self, t))
	end,
}

newTalent{
	name = "Severed Threads",
	type = {"demented/chronophage", 2},
	require = dementedreq_high2,
	mode = "passive",
	points = 5,
	getLife = function(self, t) return .15 end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 2, 4.6)) end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	info = function(self, t)
		local life = t.getLife(self,t)*100
		local dur = t.getDuration(self,t)
		local power = t.getPower(self,t)
		return ([[On applying atrophy to a target below %d%% of their maximum life you will sever their lifeline, slaying them instantly. You will then feast on the remnants of their timeline for %d turns, increasing your life regeneration by %0.1f and causing talents without fixed cooldowns to refresh twice as fast.]])
		:tformat(life, dur, power)
	end
}

newTalent{
	name = "Temporal Feast",
	type = {"demented/chronophage", 3},
	require = dementedreq_high3,
	mode = "passive",
	points = 5,
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.7, 1.75)/100 end,	
	getSlow = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2.5, 6.5))/100 end,	
	info = function(self, t)
		local speed = t.getSpeed(self,t)*100
		local slow = t.getSlow(self,t)*100
		return ([[You drink deeper from the timeline of others. Each time you apply atrophy you gain %0.1f%% spell speed per atrophy stack on the target and cause them to lose %d%% of a turn.
			The highest atrophy stack found will be used for the spell speed calculation.]])
		:tformat(speed, slow)
	end
}

newTalent{
	name = "Terminus",
	type = {"demented/chronophage", 4},
	require = dementedreq_high4,
	points = 5, 
	cooldown = 15,
	insanity = -10,
	tactical = { ATTACKAREA = { TEMPORAL = 2 }, BUFF = 2 },
	range = 0,
	radius = function(self, t) return 10 end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 180) end,
	getTurn = function(self, t) return math.floor(self:combatTalentScale(t, 15, 70)) end,	
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), selffire=false, friendlyfire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local dam = self:spellCrit(t.getDamage(self, t))
		local bonus = dam/6
		local turn = t.getTurn(self, t)
		local nb = 0

		-- We rely on EFF_ATROPHY to populate the atrophy_targets table so we don't have to care about distance
		for target, _ in pairs(self.atrophy_targets or {}) do
			DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam)		
			if target and target:hasEffect(target.EFF_ATROPHY) and self:reactionToward(target) < 0 then
				local eff = target:hasEffect(target.EFF_ATROPHY)
				nb = nb + eff.charges
				DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, bonus * eff.charges)
				target:removeEffect(target.EFF_ATROPHY)
			end
		end
		if nb > 0 then
			local gain = nb * t.getTurn(self, t)
			gain = math.min(gain, 3000)
		
			self.energy.value = self.energy.value + gain
			if self == game.player then game.bignews:say(80, "#GREEN#You gain %.1f turns!", gain / 1000) end
		end

		-- In case the atrophy count got desynced somewhere just clear it
		self.atrophy_targets = {}
		self.atrophy_count = 0

		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "terminus", {radius=self:getTalentRadius(t), rm=100, rM=125, gm=100, gM=125, bm=100, bM=125, am=200, aM=255})
		game:playSoundNear(self, "talents/terminus")		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local rad = self:getTalentRadius(t)
		local turn = t.getTurn(self,t)/10
		return ([[Shatter the spacetime continuum around yourself, inflicting %0.2f temporal damage to all targets within radius %d. Any atrophy stacks will be consumed to steal time from your victims, inflicting an additional %0.2f temporal damage and granting you %d%% of a turn per stack (but no more than 3 turns).
		The damage will scale with your Spellpower.]]):tformat(damDesc(self, DamageType.TEMPORAL, damage), rad, damDesc(self, DamageType.TEMPORAL, damage/6), turn)
	end,
}