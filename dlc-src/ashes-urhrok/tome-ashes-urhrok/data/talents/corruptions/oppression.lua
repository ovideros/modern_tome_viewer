-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

-- DESIGN NOTES

-- The core design of this tree is to encourage melee combat by giving you defensive benefits only while engaging and actually hitting enemies.
-- The stacking, "leash" range, and mechanics encouraging large numbers of enemies all play into this.
-- Ignoring saves and immunities is vital to this design.  The reasoning for this is more clear when you realize that this is conceptually all resist or another
-- mitigation stat in a new form, not part of the debuff/cleanse/etc minigame.

local Map = require "engine.Map"




newTalent{
	name = "Horrifying Blows",
	type = {"corruption/oppression", 1},
	require = str_corrs_req1,
	points = 5,
	mode = "sustained",
	sustain_vim=20,
	no_energy=true,
	activate = function(self, t)
		return true
	end,
	deactivate = function(self, t, p)
		return true
	end,
	radius = function(self, t)
		if self:getTalentLevel(t) >= 5 then
			return 1
		else
			return 0
		end
	end,
	getSlowPower = function(self, t)
		if self:getTalentLevel(t) >= 3 then 
			return 0.0125
		else
			return 0
		end
	end,
	getDamageReduction = function(self, t)
		return (self:combatTalentScale(t, 1, 3) )
	end,
	getLeashRange = function(self, t)
		return self:combatTalentScale(t, 2, 5)
	end,
	getDuration = function(self, t)
		return 8
	end,
	getMaxStacks = function(self, t)
		return 8
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		local tt = self:isTalentActive(t.id)
		if not tt then return end
		if not hitted then return end
		
		local tg = {type="ball", range=1, friendlyfire = false,  radius=t.radius(self, t)}
		self:project(tg, target.x, target.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				target:setEffect(target.EFF_INFERNAL_FEAR, t.getDuration(self, t), {src = self, power = t.getDamageReduction(self, t), max_distance = t.getLeashRange(self, t), max_stacks = 8, slow_power = -t.getSlowPower(self, t), stacks = 1})

			end
		end)
		
		return
	end,
	info = function(self, t)
		return ([[Your successful melee hits apply a stacking effect that decreases damage done by %d%%.
		You can have up to %d stacks per target and further attacks refresh the duration, but any turn you are farther than %d spaces from the victim the fear will wear off quickly.
		At level 3 it also slows by %0.2f%% per stack.
		At level 5 you can horrify enemies in a radius of %d.
		This talent ignores saves and immunities.
		]])
		:tformat(t.getDamageReduction(self,t),
		t.getMaxStacks(self,t),
		t.getLeashRange(self, t),
		t.getSlowPower(self,t)*100,
		self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Mass Hysteria",
	type = {"corruption/oppression", 2},
	require = str_corrs_req2,
	points = 5,
	cooldown = function(self, t) return 10 end,
	vim=20,
	range = 7,
	radius = function(self, t)
		return self:combatTalentScale(t, 3, 8)
	end,
	getDurationBonus = function(self, t)
		return 10
	end,
	getPowerBonus = function(self, t)
		return 1
	end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		local effParam = target:hasEffect(target.EFF_INFERNAL_FEAR)
		if not effParam then return end
		
		effParam.dur = t.getDurationBonus(self, t)
		effParam.power = effParam.power + t.getPowerBonus(self, t)
		
		local fearCount = effParam.stacks
		
		local tg = {type="ball", range=1, selffire=false, radius=t.radius(self, t)}
		self:project(tg, target.x, target.y, function(px, py, tg, self)
			local target2 = game.level.map(px, py, Map.ACTOR)
			if target2 and target2 ~= self and target2 ~= target and self:reactionToward(target) < 0 then
				target2:setEffect(target2.EFF_INFERNAL_FEAR, t.getDurationBonus(self, t), {src = self, power = effParam.power, max_distance = effParam.max_distance, max_stacks = effParam.max_stacks, slow_power = effParam.slow_power, stacks = effParam.stacks})
			end
		end)
		game.level.map:particleEmitter(target.x, target.y, tg.radius, "circle", {oversize=1, a=170, limit_life=18, appear=8, speed=2, img="mass_hysteria", radius=tg.radius})
		return true
	end,

	info = function(self, t)
		return ([[Amplifies the power of your fear on the target by %d%% per stack and sets its duration to %d.  The amplified fear spreads to all enemies in a radius of %d.]]):tformat(t.getPowerBonus(self, t), t.getDurationBonus(self, t), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Fearfeast",
	type = {"corruption/oppression", 3},
	points = 5,
	require = str_corrs_req3,
	cooldown = 20,
	vim = 40,
	radius = function(self, t)
		return 10
	end,
	range = 1,
	getHeal = function(self, t) return self:combatTalentScale(t, 5, 25) end, -- heal per stack
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	getEnergyDrain = function(self, t) -- doesn't currently reduce energy
		return self:combatTalentScale(t, 40, 70)
	end,
	getEnergyCap = function(self, t)
		return 4000
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local fears = 0
					
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			local effParam
			if target then 
				effParam = target:hasEffect(target.EFF_INFERNAL_FEAR) 
			end
			if target and target ~= self and effParam then
				fears = fears + effParam.stacks
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "circle", {oversize=1, a=170, limit_life=18, shader=true, appear=12, speed=2, img="fearfeast", radius=tg.radius})
		
		if fears > 0 then
			self:attr("allow_on_heal", 1)
			self:heal(t.getHeal(self, t) * fears, t)
			self:attr("allow_on_heal", -1)
			
			if self.is_destroyer then
				self:incVim(self.is_destroyer * 0.4 * fears)
			end

			local gain = fears * t.getEnergyDrain(self, t)
			gain = math.min(gain, t.getEnergyCap(self, t))

			self.energy.value = self.energy.value + gain
			game.logPlayer(self, "You gain %.1f turns!", gain / 1000)

		end
		
		return true
	end,
	info = function(self, t)
		return ([[You consume the fear of enemies in radius %d, healing for %d life and gaining %0.1f%% of a turn for each stack up to a max of %.1f turns.]])
		:tformat(self:getTalentRadius(t), t.getHeal(self, t), t.getEnergyDrain(self, t)*0.1, t.getEnergyCap(self, t) / 1000)
	end,
}

newTalent{
	name = "Hope Wanes",
	type = {"corruption/oppression", 4},
	require = str_corrs_req4,
	points = 5,
	cooldown = function(self, t) 
		return self:combatTalentScale(t, 50, 32)
	end,
	vim=80,
	no_npc_use=true, --Instantly ends player life.
	range = 5,
	getDuration = function(self, t)
		return self:combatTalentScale(t, 2, 4.5)
	end,
	getStackReq = function(self, t)
		return 8
	end,	
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		local effParam = target:hasEffect(target.EFF_INFERNAL_FEAR)
		if not effParam then return end
		if core.fov.distance(target.x, target.y, x, y) > 5 then return nil end
		if effParam.stacks >= t.getStackReq(self, t) then
			target:setEffect(target.EFF_HOPELESS, t.getDuration(self, t), {})
			target:removeEffect(target.EFF_INFERNAL_FEAR)
			game.level.map:particleEmitter(self.x, self.y, 1, "circle", {oversize=1.7, a=170, limit_life=12, shader=true, appear=12, speed=0, base_rot=180, img="hope_wanes", radius=0})
			else
			return false
		end
		return true
	end,
	info = function(self, t)
		return ([[You crush the spirit of a target with at least %d fear stacks, consuming all stacks and making it unable to act for %d turns.
		This talent ignores saves and immunities.]]):tformat(t.getStackReq(self, t), t.getDuration(self, t))
	end,
}
