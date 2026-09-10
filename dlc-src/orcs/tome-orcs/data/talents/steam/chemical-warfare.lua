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
	name = "Miasma Engine",
	type = {"steamtech/chemical-warfare", 1},
	points = 5,
	require = dex_steamreq_high1,
	mode = "sustained",
	drain_steam = 3,
	cooldown = 20,
	tactical = { ATTACK = 2 },
	getMax = function(self, t) return 5 end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 150) end,
	getHealing = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 30, 75)) end,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 15, 35)) end,		
	callbackOnTalentPost = function(self, t, ab, ret)
		if ab.is_steam and ab.no_energy ~= true then
			self:setEffect(self.EFF_MIASMA_ENGINE, 3, {src=self, fail=t.getChance(self,t), radius=3, heal=t.getHealing(self,t), dam=t.getDamage(self,t), stacks=1, max_stacks=t.getMax(self,t)})
		end
	end,
	activate = function(self, t)
		return {
--			particles = self:addParticles(Particles.new("crystalline_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
--		self:removeParticles(p.particles)
		return true
	end,
	info = function(self, t)
		local rad = t.getMax(self, t)
		local chance = t.getChance(self,t)
		local heal = t.getHealing(self,t)
		local dam = t.getDamage(self,t)
		return ([[You repurpose your steam engine to emit a cloud of toxic, corrosive chemicals around you.
		Each time you use a non-instant steamtech talent, you create a radius 3 cloud of miasma for 5 turns. All enemies within the miasma have %d%% reduced healing and %d%% chance to fail talent usage.
		Each time miasma is reapplied the failure chance increases, up to %d%% after 5 reapplications.
		The first time each turn a target affected by miasma is hit by a melee or ranged attack the miasma seeps into their wounds, dealing an additional %0.2f acid damage.
		Miasma duration does not increase on re-apply.
		When a creature survives the miasma it becomes immune to it for 9 turns.]]):
		tformat(heal, chance / 5, chance, damDesc(self, DamageType.ACID, dam), rad)
	end,
}

newTalent{
	name = "Caustic Dispersal",
	type = {"steamtech/chemical-warfare", 2},
	points = 5,
	require = dex_steamreq_high2,
	cooldown = 9,
	steam = 20,
	random_ego = "attack",
	no_energy = "fake",
	is_steamgun = true,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = { weapon = 2 }, DISABLE = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 3.7)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.1) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	archery_onreach = function(self, t, x, y)
		game.level.map:addEffect(self,
			x, y, t.getDuration(self,t),
			DamageType.CAUSTIC_STEAM, {dam=1},
			0,
			5, nil,
			{type="vapour"},
			nil, false
		)
	end,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		if not weapon then return {type="bolt", range=1} end
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), selffire=false, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		local dam = t.getDamage(self,t)
		self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.ACID})
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)*100
		local rad = self:getTalentRadius(t)
		local dur = t.getDuration(self,t)
		return ([[You fire a toxic shell that explodes in radius %d, dealing %d%% weapon damage as acid and leaving behind a cloud of miasma for %d turns that inherits all effects from your Miasma Engine.]]):
		tformat(rad, dam, dur)
	end,
}

newTalent{
	name = "Smogscreen",
	type = {"steamtech/chemical-warfare", 3},
	points = 5,
	require = dex_steamreq_high3,
	mode = "passive",
	getEvade = function(self, t) return math.floor(self:combatTalentLimit(t, 12, 3, 9)) end,
	getEvadeStacks = function(self, t) return math.floor(self:combatTalentLimit(t, 4, 1, 3.05)) end,		
	info = function(self, t)
		local evade = t.getEvade(self,t)
		local evades = t.getEvadeStacks(self,t)
		return ([[You become difficult to target through the thick smog generated by your Miasma Engine. While surrounded by miasma you have a %d%% chance to entirely avoid damage, increased by %d%% per stack.]]):
		tformat(evade, evades)
	end,
}

newTalent{
	name = "Fumigate",
	type = {"steamtech/chemical-warfare", 4},
	points = 5,
	require = dex_steamreq_high4,
	cooldown = 5,
	steam = 15,
	no_energy = "fake",
	is_steamgun = true,
	range = 0,
	radius = steamgun_range,
	no_npc_use = true, -- can be upwards of 500% weapon damage and ignores all armour 
	requires_target = true,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type = "cone", range = self:getTalentRange(t), radius = self:getTalentRadius(t), selffire = false, talent = t }
	end,
	on_pre_use = function(self, t, silent) if not (self:hasArcheryWeapon("steamgun") and self:hasEffect(self.EFF_MIASMA_ENGINE)) then if not silent then game.logPlayer(self, "You require a steamgun and an active miasma cloud for this talent.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.8) end,
	getChance = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 25, 75)) end,
	archery_onhit = function(self, t, target, x, y, tg)
		local effs = {}
		-- Go through all effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if (e.type == "physical" or e.type == "mental") and e.status == "beneficial" then
				effs[#effs+1] = eff_id
			end
		end
		
		for i = 1, tg.nb do
			if #effs == 0 then break end
			if rng.percent(t.getChance(self,t)) then
				local eff = rng.tableRemove(effs)
				target:removeEffect(eff)
			end
		end
	end,
	action = function(self, t)
		-- Get list of possible targets, possibly doubled.
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return end
		local targets = {}
		local add_target = function(x, y)
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if target and self:reactionToward(target) < 0 and self:canSee(target) then
				targets[#targets + 1] = target
			end
		end
		self:project(tg, x, y, add_target)
		if #targets == 0 then return end

		table.shuffle(targets)
		local eff = self:hasEffect(self.EFF_MIASMA_ENGINE)

		-- Fire each shot individually.
		local old_target_forced = game.target.forced
		local fired = nil -- If we've fired at least one shot.
		for i = 1, #targets do
			local target = targets[i]
			game.target.forced = {target.x, target.y, target}
			local targets = self:archeryAcquireTargets({type = "hit", speed = 200}, {one_shot=true, no_energy = fired})
			if targets then
				local target = targets.dual and targets.main[1] or targets[1]
				local dist = core.fov.distance(self.x, self.y, target.x, target.y) - 1
				local mult = t.getDamage(self,t) + (t.getDamage(self,t) * eff.stacks)/2
				self:archeryShoot(targets, t, {type = "hit", speed = 200, nb=1+eff.stacks}, {mult = mult, apr=1000, phasing = true, phase_target = game.level.map(target.x, target.y, game.level.map.ACTOR), damtype=DamageType.ACID})
				fired = true
			else
				-- If no target that means we're out of ammo.
				break
			end
		end

		game.target.forced = old_target_forced
		self:removeEffect(self.EFF_MIASMA_ENGINE)
		return fired
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)*100
		local rad = self:getTalentRadius(t)
		local chance = t.getChance(self,t)
		return ([[You consume all Miasma Engine stacks you have to fire a blast of corrosive death through your steamgun, dealing %d%% weapon damage as acid in a radius %d cone with a %d%% chance to remove a random beneficial physical or mental effect. For every stack beyond the first the damage dealt is increased by 50%% and there is a %d%% chance to remove an additional effect.
		This attack ignores all enemy armour, and you must have at least 1 stack of Miasma Engine to use this talent.]])
		:tformat(dam, rad, chance, chance)
	end,
}