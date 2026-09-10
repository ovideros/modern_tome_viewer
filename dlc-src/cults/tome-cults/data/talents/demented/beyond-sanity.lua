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
	name = "Chaos Orbs",
	type = {"demented/beyond-sanity", 1},
	points = 5,
	require = dementedreq1,
	cooldown = 10,
	mode = "sustained",
	tactical = { BUFF=1 },
	getTrigger = function(self, t) return self:combatTalentLimit(t, 5, 25, 9) end,  -- Past the first point you need ~40 insanity to have any chance of proccing but quickly reach essentially 100%
	getMax = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)+1) end,
	callbackOnChaosEffect = function(self, t, effectname, ief, v)
		if self.turn_procs.chaos_orbs then return end
		local trig = t.getTrigger(self, t)
		if ief >= trig or ief <= -trig then
			self.turn_procs.chaos_orbs = true
			self:setEffect(self.EFF_CHAOS_ORBS, 10, {stacks = 1, max_stacks=t.getMax(self, t)})
		end
	end,
	activate = function(self, t)
		local ret = {}
		game:playSoundNear(self, "talents/chaos_orb_cast")
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You harness the chaos created by high insanity.
		Each time you trigger an insanity chaotic effect with a power higher than %d or lower than -%d you gain a chaos orb for 10 turns (this effect can only happen once per turn).
		Each orb increases your damage by 3%% and can stack up to %d.]]):
		tformat(t.getTrigger(self, t), t.getTrigger(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Anarchic Walk",
	type = {"demented/beyond-sanity", 2},
	require = dementedreq2,
	points = 5,
	insanity = -15,
	cooldown = 6,
	tactical = { CLOSE_IN=1 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not (self:hasEffect(self.EFF_CHAOS_ORBS) and self:hasEffect(self.EFF_CHAOS_ORBS).stacks >= 2) then if not silent then game.logPlayer(self, "You require at least two chaos orbs.") end return false end return true end,
	--range = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 10)) end,
	range = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 1, 5)) end,
	getMax = function(self, t) return 8 end,
	target = function(self, t) return {type="cone", range=0, selffire=false, radius=t.getMax(self, t), nolock=true, simple_dir_request=true} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x then return nil end
		local range = self:getTalentRange(t)
		local spots, shortspots = {}, {}
		self:project(tg, x, y, function(px, py)
			if self:canMove(px, py) then
				if core.fov.distance(self.x, self.y, px, py) >= range then spots[#spots+1] = {x=px, y=py}
				else shortspots[#shortspots+1] = {x=px, y=py} end
			end
		end)
		if #spots == 0 then spots = shortspots end
		if #spots == 0 then return nil end
		local spot = rng.table(spots)

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(spot.x, spot.y, 0)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")

		self:callEffect(self.EFF_CHAOS_ORBS, "useOrb", 2)

		game:playSoundNear(self, "talents/anarchic_walk")
		return true
	end,
	info = function(self, t)
		return ([[You consume the chaotic forces of 2 chaos orbs, randomly teleporting you in a general direction up to %d tiles away.
		You will always travel at least %d tiles away if possible.]]):tformat(t.getMax(self, t), self:getTalentRange(t))
	end,
}

newTalent{
	name = "Disjointed Mind",
	type = {"demented/beyond-sanity", 3},
	require = dementedreq3,
	points = 5,
	insanity = -15,
	cooldown = 16,
	range = 7,
	tactical = { DISABLE = {confusion = 2} },
	requires_target = true,
	no_energy = true,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_CHAOS_ORBS) then if not silent then game.logPlayer(self, "You require at least one chaos orb.") end return false end return true end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDur = function(self,t) return self:combatTalentLimit(t, 15, 5, 10) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not target then return nil end

		local charges = self:callEffect(self.EFF_CHAOS_ORBS, "charges")
		if target:canBe("confusion") then
			target:setEffect(target.EFF_CONFUSED, t.getDur(self, t), {apply_power=self:combatSpellpower() * (1 + charges / 10), power=charges * 10})
		else
			game.logSeen(target, "%s resists the chaotic mental assault!", target:getName():capitalize())
		end
		self:removeEffect(self.EFF_CHAOS_ORBS)
		
		game:playSoundNear(self, "talents/slime")

		return true
	end,
	info = function(self, t)
		return ([[You trigger an explosion of your chaos orbs on a target.
		The orbs do no damage but confuse it for %d turns with a confusion power of 10%% per orb.
		Your effective spellpower used to overcome the target's mental save is also increased by 10%% per orb.
		All your orbs are always spent.]]):
		tformat(t.getDur(self, t))
	end,
}

newTalent{
	name = "Controlled Chaos",
	type = {"demented/beyond-sanity", 4},
	require = dementedreq4,
	points = 5,
	no_energy = true,
	cooldown = 30,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_CHAOS_ORBS) then if not silent then game.logPlayer(self, "You require at least one chaos orb.") end return false end return true end,
	getReduced = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 28)) end,
	getInsanity = function(self, t) return 10 end,
	action = function(self, t)
		local charges = self:callEffect(self.EFF_CHAOS_ORBS, "charges")
		self:incInsanity(charges * 10)
		self:removeEffect(self.EFF_CHAOS_ORBS)
		game:playSoundNear(self, "talents/controlled_chaos")

		return true
	end,
	info = function(self, t)
		return ([[You lean to alter chaotic forces to your advantage.
		Your maximum negative insanity effect is reduced from 50%% to %d%%.
		You may activate this talent to consume any Chaos Orbs you have, gaining %d insanity per orb.]]):
		tformat(t.getReduced(self, t), t.getInsanity(self, t))
	end,
}
