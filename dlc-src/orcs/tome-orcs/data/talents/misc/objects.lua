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

local oldTalent = newTalent
local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end

newTalentType{ type="steam/objects", name = _t("object techniques", "talent type"), description = _t"Steam powers of the various objects of the world." }

newTalent{ --Grasping Moss clone with range so that it can proc on archery. Feel free to change if there is a better way to do this.
	name = "Overgrowth",
	type = {"wild-gift/objects", 1},
	require = gifts_req1,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 8)) end, 
	getSlow = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 36, 60)) end, -- Limit < 100%
	getPin = function(self, t) return math.ceil(self:combatTalentLimit(t, 100, 25, 45)) end, -- Limit < 100%
	range = 10,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t,2.5, 4.5, nil, 0, 0, true)) --uses raw talent level
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.GRASPING_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), pin=t.getPin(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local slow = t.getSlow(self, t)
		local pin = t.getPin(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Instantly grow a moss circle of radius %d at target area.
		Each turn the moss deals %0.2f nature damage to each foe within its radius.
		This moss is very thick and sticky causing all foes passing through it have their movement speed reduced by %d%% and have a %d%% chance to be pinned to the ground for 4 turns.
		The moss lasts %d turns.
		Moss talents are instant but place all other moss talents on cooldown for 3 turns.
		The damage will increase with your Mindpower.]]):
		tformat(radius, damDesc(self, DamageType.NATURE, damage), slow, pin, duration)
	end,
}

newTalent{
	name = "Ceasefire", short_name = "TALOSIS_CEASEFIRE",
	type = {"steam/objects", 1},
	points = 5,
	cooldown = 10,
	steam = 45,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 }, },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require at least a steamgun for this talent.") end return false end return true end,
	getDur = function(self, t) return math.floor(2 + self:getTalentLevel(t)) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			game:onTickEnd(function() target:setEffect(target.EFF_DAZED, t.getDur(self, t), {apply_power=self:combatSteampower()}) end)
		else
			game.logSeen(target, "%s resists!", target:getName():capitalize())
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.8)})
		return true
	end,
	info = function(self, t)
		return ([[You fire an incredibly potent shot at an enemy, doing %d%% damage and dazing them for %d turns.
		The daze chance increases with your Steampower.]]):tformat(100 * self:combatTalentWeaponDamage(t, 1, 1.8), t.getDur(self, t))
	end,
}

newTalent{
	name = "Surekill", short_name = "GUN_SUREKILL", image = "talents/anatomy.png",
	type = {"steam/objects", 1},
	points = 5,
	cooldown = 8,
	steam = 35,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require at least a steamgun for this talent.") end return false end return true end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {crushing_blow=true, mult=self:combatTalentWeaponDamage(t, 1, 1.8)})
		return true
	end,
	info = function(self, t)
		return ([[You fire an exceptionally lethal shot at an enemy, doing %d%% damage.
Damage dealt by this talent is increased by half your critical multiplier, if doing so would kill the target.]]):tformat(100 * self:combatTalentWeaponDamage(t, 1, 1.8))
	end,
}

newTalent{
	name = "Rocket Smash",
	type = {"technique/other", 1},
	message = _t"@Source@ rockets forward!",
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	tactical = { ATTACK = { weapon = 1}, CLOSEIN = 3 },
	requires_target = true,
	is_melee = true,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), nolock=true, nowarning=true, requires_knowledge=false, stop__block=true} end,
	range = function(self, t) return 8 end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not self:canProject(tg, x, y) then return nil end
		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local linestep = self:lineFOV(x, y, block_actor)

		local tx, ty, lx, ly, is_corner_blocked
		repeat  -- make sure each tile is passable
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = linestep:step()
		until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
		if not tx or core.fov.distance(self.x, self.y, tx, ty) < 1 then
			game.logPlayer(self, "You are too close to build up momentum!")
			return
		end
		if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then return nil end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
		local can = function(target)
			return true
		end
		game.level.map:particleEmitter(ox, oy, tg.radius, "flamebeam", {tx=self.x-ox, ty=self.y-oy})
		-- Attack ?
		if target and core.fov.distance(self.x, self.y, target.x, target.y) <= 1 then
			local hit = self:attackTarget(target, nil, 1.3, true)
			if hit then
			target:knockback(self.x, self.y, 4, can)
			end
		end

		return true
	end,
	info = function(self, t)
		return (_t[[Dash forward using rockets.
		If the spot is reached and occupied, you will perform a free melee attack against the target there and knock them back 4 spaces as well as anyone else they collide with.
		This attack does 180% weapon damage.
		You must dash from at least 2 tiles away.]])
	end,
}

newTalent{
	name = "Laser Powered Smash",
	type = {"technique/other", 1},
	message = _t"@Source@ unleashes the power of the Gloryhammer!",
	points = 5,
	cooldown = 30,
	tactical = { ATTACK = { weapon = 1}, ATTACKAREA = { weapon = 2 }, DISABLE = {blind = 1} },
	is_melee = true,
	target = function(self, t) return {type="ball", radius=self:getTalentRange(t)} end,
	range = function(self, t) return 4 end,
	action = function(self, t)
		local tgts = {}

		self:project(self:getTalentTarget(t), self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target == self or self:reactionToward(target) >= 0 then return end

			-- Yes this can hit the same targets multiple times, hence the low multiplier
			tgts[#tgts+1] = {x=px, y=py}
		end)

		for _, tgt in ipairs(tgts) do
			self:project({type="ball", radius=1, x=tgt.x, y=tgt.y}, tgt.x, tgt.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target or target == self or self:reactionToward(target) >= 0 then return end

				local hit = self:attackTarget(target, nil, 0.5, true)
				if hit and target:canBe("blind") then
					target:setEffect(target.EFF_BLINDED, 4, {apply_power=self:combatPhysicalpower(), no_ct_effect=true})
				end
			end)
			game.level.map:particleEmitter(tgt.x, tgt.y, 1, "fireflash", {radius=1})
		end

		return true
	end,
	info = function(self, t)
		return (_t[[Unleash the ultimate power of the Gloryhammer to all foes around in radius 1.
		This attack creates an explosion of radius 1 around every affected target, dealing 50% weapon damage and blinding them for 4 turns.]])
	end,
}
