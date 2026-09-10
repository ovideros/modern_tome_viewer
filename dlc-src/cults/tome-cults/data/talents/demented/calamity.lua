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
	name = "Jinxed Touch",
	type = {"demented/calamity", 1},
	points = 5,
	require = dementedreq1,
	cooldown = 10,
	mode = "sustained",
--	getChance = function(self, t) return self:combatTalentLimit(t, 100, 35, 70) end,
	getCrit = function(self, t)
		if self:getTalentLevelRaw(t) >= 5 then 
			return 2
		elseif self:getTalentLevelRaw(t) >= 3 then
			return 1.5
		else
			return 1
		end
	end,
	getSaves = function(self, t)
		if self:getTalentLevelRaw(t) >= 4 then 
			return 3
		elseif self:getTalentLevelRaw(t) >= 2 then
			return 2
		else
			return 1
		end
	end,	
	callbackOnDealDamage = function(self, t, dam, target)
		if dam <=0 then return end
		if self.turn_procs.jinx and self.turn_procs.jinx[target] then return end
		table.set(self.turn_procs, "jinx", {[target] = true})
		target:setEffect(target.EFF_JINX, 5, {src = self, stacks=1, max_stacks=10, power = t.getSaves(self, t), crit=t.getCrit(self,t), fail=(self:callTalent(self.T_PREORDAIN, "getChance") or 0), src=self })
		if self:knowTalent(self.T_LUCKDRINKER) then
			local t = self:getTalentFromId(self.T_LUCKDRINKER)
			if rng.percent(t.getChance(self,t)) then
				local avoid = 0
				if self:knowTalent(self.T_PREORDAIN) then avoid = t.getAvoid(self,t) end
				self:setEffect(self.EFF_FORTUNE, 5, {src = self, stacks=1, max_stacks=10, power = t.getSaves(self, t), crit=t.getCrit(self,t), avoid=avoid })
			end
		end
	end,

	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local saves = t.getSaves(self,t)
		local crit = t.getCrit(self,t)
		return ([[Your touch carries an entropic curse, marking your victims for a terrible fate. Each time you deal damage to a target, they are Jinxed for 5 turns. This stacks up to 10 times, reducing saves and defense by %0.2f and critical strike chance by %0.2f%%.
			This can only be applied once per target per turn and will fade entirely if you break line of sight with your target for more than 2 turns.]]):
		tformat(saves, crit)
	end,
}

newTalent{
	name = "Preordain",
	type = {"demented/calamity", 2},
	require = dementedreq2,
	points = 5,
	mode = "passive",
	getChance = function(self, t) return math.min(7, 1 + self:getTalentLevel(t)) end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		return ([[You subtly alter the course of events to cause your foes further misfortune. Each stack of Jinx beyond 6 will cause enemies to also suffer a %d%% chance to fail talent usage.]]):
		tformat(chance)
	end,
}

newTalent{
	name = "Luckdrinker",
	type = {"demented/calamity", 3},
	require = dementedreq3,
	points = 5,
	mode = "passive",
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 40, 70) end,
	getCrit = function(self, t)
		if self:getTalentLevelRaw(t) >= 5 then 
			return 2
		elseif self:getTalentLevelRaw(t) >= 3 then
			return 1.5
		else
			return 1
		end
	end,
	getSaves = function(self, t)
		if self:getTalentLevelRaw(t) >= 4 then 
			return 3
		elseif self:getTalentLevelRaw(t) >= 2 then
			return 2
		else
			return 1
		end
	end,
	getAvoid = function(self, t) return math.min(6, 2 + math.floor(self:getTalentLevel(t)/2)) end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		local saves = t.getSaves(self,t)
		local crit = t.getCrit(self,t)
		local avoid = t.getAvoid(self,t)
		return ([[Each time you apply Jinx to an enemy, you have a %d%% chance to siphon some of their luck for yourself for 5 turns. This stacks up to 10 times, increasing saves and defense by %0.2f and critical strike chance by %0.2f%%.
		If you know Preordain, stacks beyond 6 also grant a %d%% chance for you to entirely avoid damage taken.]]):
		tformat(chance, saves, crit, avoid)
	end,
}

newTalent{
	name = "Fatebreaker",
	type = {"demented/calamity", 4},
	require = dementedreq4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 20, 55, 30)) end,
	insanity = -30,
	range = 10,
	tactical = { DISABLE = 3 },
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 9)) end,	
	getLife = function(self,t) return self:combatTalentScale(t, 5, 20) + self:combatTalentSpellDamage(t, 20, 350)/100 end,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y, target = self:getTargetLimited(tg)
		if not target or target == self then return nil end
		self:setEffect(self.EFF_FATEBREAKER, t.getDuration(self,t), {src=self, power=t.getLife(self,t), target=target})
		game:playSoundNear(self, "talents/netherlance")
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self,t)
		local life = t.getLife(self,t)
		return ([[You form a link between yourself and the chosen target for %d turns, tying your fates together. If during this time you receive fatal damage, you reflexively warp reality, ending the effect and attempting to force them to die in your place.
		As long as your target remains alive this redirects all damage you take to it as temporal and darkness damage for 1 turn.
		Any Fortune stacks you have and any Jinx stacks the enemy have will then be consumed to heal you for %d life per stack.]]):
		tformat(dur, life)
	end,
}
