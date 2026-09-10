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
	name = "Rocket Pod",
	type = {"steamtech/artillery", 1},
	points = 5,
	require = dex_steamreq_high1,
	mode = "sustained",
	drain_steam = 6,
	cooldown = 20,
	tactical = { ATTACKAREA = { weapon = 2 }, },
	no_npc_use = true,
	range = steamgun_range,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.6) end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="arrow", particle_args={tile="particles_images/guided_missile"}}, friendlyblock=false, friendlyfire=false} end,
	getNb = function(self, t) return 2 end,
	callbackOnActBase = function(self, t)
		local eff = self:hasEffect(self.EFF_LOCK_ON_BEN) 
		if eff then
			local tg = self:getTalentTarget(t)		
			local targets = self:archeryAcquireTargets(tg, {no_sound=true, one_shot=true, infinite=true, no_energy=true, x=eff.target.x, y=eff.target.y})
			if not targets then return end
			local dam = t.getDamage(self,t) + (t.getDamage(self,t) * eff.power/100)
			game:playSoundNear(self, "talents/rocket_pod")
			self:archeryShoot(targets, t, tg, {mult=dam, proc_mult=0.5, damtype=DamageType.PHOSPHOROUS}) --by default just fire damage but can interact with Incendiary Powder		
		else
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
			end end
	
			-- Randomly take targets
			local tg = self:getTalentTarget(t)
			for i = 1, t.getNb(self, t) do
				if #tgts <= 0 then break end
				local a, id = rng.table(tgts)
				table.remove(tgts, id)
				local targets = self:archeryAcquireTargets(tg, {no_sound=true, one_shot=true, infinite=true, no_energy=true, ignore_ressources=true, x=a.x, y=a.y})
				if targets then
					game:playSoundNear(self, "talents/rocket_pod")
					self:archeryShoot(targets, t, tg, {mult=t.getDamage(self,t), proc_mult=0.5, damtype=DamageType.PHOSPHOROUS}) --by default just fire damage but can interact with Incendiary Powder
				end
			end
		end
	end,
	activate = function(self, t)
		local ret = {}
		self.using_steam_rocketpod = true
		self:updateModdableTile()
		return ret
	end,
	deactivate = function(self, t, p)
		self.using_steam_rocketpod = nil
		self:updateModdableTile()
		return true
	end,
	info = function(self, t)
		return ([[You equip an automated, shoulder mounted rocket launcher. Each turn it will launch rockets at up to %d enemies in weapon range, dealing %d%% steamgun damage as fire.
		The rockets will pass harmlessly through allies, but on-hit effects triggered by them only deal 50%% of their usual damage.]]):tformat(t.getNb(self,t), t.getDamage(self,t)*100)
	end,
}

newTalent{
	name = "Incendiary Powder",
	type = {"steamtech/artillery", 2},
	points = 5,
	require = dex_steamreq_high2,
	mode = "passive",
	no_npc_use = true,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 15, 150) end,
	getApr = function(self, t) return 0 end,
	getFear = function(self, t) return math.min(50, math.floor(self:combatTalentScale(t, 15, 30))) end,
	info = function(self, t)
		local dam = t.getDamage(self,t)
		local apr = t.getApr(self,t)
		local fear = t.getFear(self,t)
		return ([[Augment your rockets with highly flammable materials, causing them to burn targets for %0.2f fire damage over 3 turns. Subsequent shots against burning targets refresh the effect of the duration (but do not stack) and inflict %0.2f additional fire damage.
Targets affected by this burning that fall below 25%% life enter a state of panic, giving them a %d%% chance each turn to flee in terror from you.
The fire damage will increase with your Steampower.]]):
		tformat(damDesc(self, DamageType.FIRE, dam), damDesc(self, DamageType.FIRE, dam/2), fear)
	end,
}

newTalent{
	name = "Lock On",
	type = {"steamtech/artillery", 3},
	points = 5,
	cooldown = 12,
	require = dex_steamreq_high3,
	steam = 30,
	tactical = { ATTACK = 2 },
	no_npc_use = true,
	range = steamgun_range,
	no_energy = true,
	getDamage = function(self, t) return 40 + math.floor(self:combatTalentScale(t, 40, 120)) end,
	getDefense = function(self, t) return math.floor(self:combatTalentSteamDamage(t, 15, 50)) end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamgun")
		if not weapon then return nil end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTargetLimited(tg)
		if not x or not y or not target then return nil end

		self:setEffect(self.EFF_LOCK_ON_BEN, 5, {src=self, target=target, power=t.getDamage(self,t)})
		target:setEffect(target.EFF_LOCK_ON_DET, 5, {src=self, power=t.getDefense(self,t)})
		return true
	end,
	info = function(self, t)
		return ([[Lock on to your target with your rocket pod for 5 turns.
While locked on your regular rocket pod attacks are disabled. However, each turn you automatically fire a rocket barrage dealing %d%% increased damage at your target.
Marked targets also lose %d defense and cannot benefit from concealment or evasion.
The defense loss will increase with your Steampower.]]):
		tformat(t.getDamage(self, t), t.getDefense(self,t))
	end,
}

newTalent{
	name = "Death From Above", short_name = "SEEKER_WARHEAD",
	type = {"steamtech/artillery", 4},
	points = 5,
	cooldown = 20,
	require = dex_steamreq_high4,
	steam = 30,
	tactical = { ATTACK = 2, ESCAPE=2 },
	no_npc_use = true,
	range = steamgun_range,
	rocket_barrage = true,
	no_energy = "fake",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.5) end,
	getEvasion = function(self, t) return self:combatTalentLimit(t, 75, 15, 45) end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 400, 650, 0.75) end,
	target = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=2, talent=t}
		return tg
	end,
	archery_onreach = function(self, t, x, y)
		game.level.map:particleEmitter(x, y, 2, "ball_fire", {radius=2})
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamgun")
		if not weapon then return nil end
		
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		local dam = t.getDamage(self,t)
		self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.PHOSPHOROUS})
		game:playSoundNear(self, "talents/fireflash")
		
		self:setEffect(self.EFF_DEATH_FROM_ABOVE, 3, {src=self, power=t.getDamage(self,t), evasion=t.getEvasion(self,t), speed=t.getSpeed(self,t)/100})
		
		return true
	end,
	info = function(self, t)
		return ([[You use your rocket pods to launch yourself into the air for 3 turns, firing a radius 2 barrage of rockets that deal %d%% steamgun damage as fire in radius 2. 
		While flying you gain %d%% movement speed, %d%% chance to evade melee and ranged attacks, and can reactivate this talent at will to repeat the rocket barrage.
		Using any talent other than Rocket Barrage will end this effect immediately.]]):
		tformat(t.getDamage(self,t)*100, t.getSpeed(self,t), t.getEvasion(self,t))
	end,
}

newTalent{
	name = "Rocket Barrage",
	type = {"steamtech/other", 1},
	no_energy = "fake",
	no_unlearn_last = true,
	points = 1,
	random_ego = "attack",
	range = steamgun_range,
	radius = 2,
	tactical = { ATTACKAREA = { weapon = 2 }, DISABLE = { stun = 2 } },
	no_npc_use = true,
	requires_target = true,
	rocket_barrage = true,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), selffire=false, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	getDamage = function(self, t) return self:callTalent(self.T_SEEKER_WARHEAD, "getDamage") end,
	archery_onreach = function(self, t, x, y)
		game.level.map:particleEmitter(x, y, 2, "ball_fire", {radius=2})
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamgun")
		if not weapon then return nil end
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		local dam = t.getDamage(self,t)
		self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.PHOSPHOROUS})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self,t)*100
		return ([[Fires a barrage of rockets in radius 2, dealing %d%% steamgun damage as fire.]])
		:tformat(dam)
	end,
}