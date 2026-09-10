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
	name = "Strafe",
	type = {"steamtech/gunslinging", 1},
	points = 5,
	require = dex_steamreq1,
	cooldown = 8,
	steam = 6,
	no_energy = "fake",
	getNb = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 1.5, 3.6)) end,
	getReload = function(self, t, turns) -- this is enough to maintain strafing indefinitely with high enough talent level and ammo capacity
		local weapon, ammo, offweapon = self:hasArcheryWeapon("steamgun")
		if weapon and ammo then
			local cap = ammo.combat.capacity or 20
			return math.floor(math.min(cap, self:combatTalentLimit(t, 8, 1.5, 5)+self:combatTalentLimit((turns or 0), cap/2, cap/20, cap/5)))
		else return 0 end
	end,
	range = function(self, t) return math.max(1, steamgun_range(self, t) - 1) end,
	message = _t"@Source@ strafes with @hisher@ steamguns!",
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 }, ESCAPE=1, CLOSEIN=1 , AMMO=1},
	on_pre_use = function(self, t, silent) if not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	action = function(self, t)
		local tg = {selffire=self:attr("encased_in_ice") and true or false, range = t.range(self, t),
			-- make sure the shot cannot hit the shooter after movement
			on_stop_check=function(self, typ, tg, damtype, dam, particles, x, y, tmp, rx, ry, proj)
				local act = game.level.map(x, y, engine.Map.ACTOR)
				if act ~= proj.src or (proj.project.def.x == x and proj.project.def.y == y) then
					return true 
				end
			end
		}
		local targets = self:archeryAcquireTargets(tg, {one_shot=true, no_energy=true, type="steamgun"})
		if not targets then return end
		if not self:hasEffect(self.EFF_STRAFING) then self:setEffect(self.EFF_STRAFING, t.getNb(self, t), {}) end
		local eff = self:hasEffect(self.EFF_STRAFING)
		eff.turns = eff.turns + 1
		-- shoot target and move	
		self:archeryShoot(targets, t, tg, {type="steamgun"})
		local dir, move
		if not self:attr("never_move") and not self:attr("encased_in_ice") then
			local x, y = self:getTarget{type="hit", no_restrict=true, range=1, nowarning=true, immediate_keys=true, simple_dir_request=true, default_target=self}
			if x then
				if not self.player and self.ai_state.tactic == "escape" then -- NPC trying to escape
					dir = util.getDir(self.x, self.y, x, y)
					x, y = util.coordAddDir(self.x, self.y, dir)
					if self:canMove(x, y) then -- move directly away if possible
						self:move(x, y, true)
					else
						self:moveDirection(x, y, true) --ai finds the best spot
					end
				else -- try to close with target
					dir = util.getDir(x, y, self.x, self.y)
					x, y = util.coordAddDir(self.x, self.y, dir)
					if dir ~= 5 and self:canMove(x, y) then self:moveDir(dir, true) end
				end
			end
		end
		-- use energy equal to the greater of movement and attack speed		
		local speed = math.max(self:combatSteamSpeed(), dir and self:combatMovementSpeed() or 0)
		print("[SHOOT:Strafe] speed", speed or 1, "=>", game.energy_to_act * (speed or 1))
		self:useEnergy(game.energy_to_act * speed)
		return true, {no_energy=true, ignore_cd=self:hasEffect(self.EFF_STRAFING)}
	end,
	info = function(self, t)
		local nb = t.getNb(self, t)
		return ([[You have learned to fire while moving.
		In one motion, you fire your double steamguns (100%% weapon damage, 1 tile range penalty) and may then move to an adjacent tile (unless pinned to the ground or immobilized).
		This talent can be activated for up to %d consecutive turns before it goes on cooldown, and takes time according to your steamtech speed or movement speed (if you move), whichever is slower.
		When Strafe ends you may instantly reload between %d and %d ammo (based on the number of strafes you performed and your ammo capacity).]]):
		tformat(nb, t.getReload(self, t, 1), t.getReload(self, t, nb + 1))
	end,
}

newTalent{
	name = "Startling Shot",
	type = {"steamtech/gunslinging", 2},
	no_energy = "fake",
	points = 5,
	cooldown = 7,
	steam = 12,
	no_energy = "fake",
	require = dex_steamreq2,
	range = steamgun_range,
	requires_target = true,
	tactical = { BUFF=2, ESCAPE = 1.5 },
	on_pre_use = function(self, t, silent) if not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true, type="steamgun"})
		if not targets or not targets.main or not targets.main[1] then return end

		local x, y = targets.main[1].x, targets.main[1].y
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		local srcname = game.level.map.seens(self.x, self.y) and self:getName():capitalize() or _t"Something"
		game.logSeen(target, "%s misses %s shot.", srcname, string.his_her(self))

		target:setEffect(target.EFF_STARTLING_SHOT, 3, {apply_power=self:combatAttack(), power=self:combatTalentWeaponDamage(t, 1.5, 3)})
		if target:checkHit(self:combatSteampower(), target:combatMentalResist(), 0, 95, 5) then
			target:knockback(self.x, self.y, 2)
		end

		return true
	end,
	info = function(self, t)
		return ([[You deliberately fire a missing shot at a target, startling it for 3 turns.
		If the target fails a mental save it instinctively recoils two steps back.
		The next shot that hits the startled creature will deal %d%% more damage.]])
		:tformat(100 * self:combatTalentWeaponDamage(t, 1.5, 3))
	end,
}

local onmiss = function(self, t, src)
	if self.turn_procs.evasive_shots then return end
	self.turn_procs.evasive_shots = true
	local targets = self:archeryAcquireTargets(nil, {x=src.x, y=src.y, one_shot=true, no_energy=true, type="steamgun"})
	if not targets then return end
	self:logCombat(src, "#Source# fires a retaliatory shot at #Target#!")
	self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.4, 1.5), type="steamgun"})
end
newTalent{
	name = "Evasive Shots",
	type = {"steamtech/gunslinging", 3},
	points = 5,
	mode = "sustained",
	cooldown = 30,
	drain_steam = 4,
	require = dex_steamreq3,
	tactical = { BUFF=2, DEFEND = 1.5 },
	on_pre_use = function(self, t, silent) if not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	callbackOnMeleeMiss = onmiss,
	callbackOnArcheryMiss = onmiss,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Using small engines to augment your reflexes you are able to automatically fire retaliatory shots at your foes doing %d%% weapon damage.
		Retaliation shots are fired when you evade/are missed by a melee or ranged attack.
		This can only happen once per turn and uses shots as normal.]])
		:tformat(100 * self:combatTalentWeaponDamage(t, 0.4, 1.5))
	end,
}

newTalent{
	name = "Trick Shot",
	type = {"steamtech/gunslinging", 4},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	steam = 25,
	require = dex_steamreq4,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = { weapon = 3 } },
--- Note: callback order: talent.archery_onreach, talent.archery_onmiss/archery_onhit, projectile.on_stop_check
	archery_onmiss = function(self, t, target, t_x, t_y) -- flag shot as missed
		table.set(self, "turn_procs", "trick_shot_hit", false)
	end,
	archery_onhit = function(self, t, target, t_x, t_y)  -- flag shot as hit
		table.set(self, "turn_procs", "trick_shot_hit", true)
	end,
	on_pre_use = function(self, t, silent) if not self:hasDualArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You must dual wield steamguns for this talent.") end return false end return true end,
	getNb = function(self, t) return math.max(1, math.floor(self:combatTalentScale(t, 0.8, 4.5, "log"))) end,
	ricochetDamage = function(self, t) return self:combatTalentLimit(t, 1, 0.65, 0.88) end, --Limit < 100%
	ricochetAccuracy = function(self, t) return self:combatTalentLimit(t, 1, 0.56, 0.85) end, --Limit < 100%
	damageMult = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.4) end,
	action = function(self, t)
		local main, ammo, off = self:hasDualArcheryWeapon("steamgun")
		if not main and ammo and off then return end
		local tg={no_supercharge_bullet=true, name = t.name, selffire = false,
			on_stop_check=function(self, typ, tg, damtype, dam, particles, x, y, tmp, rx, ry, projectile)
			 -- Possibly bounce to new target
				if tg.nb_tricks > 0 and tg.target_list and #tg.target_list > 0 then
					if not table.get(projectile, "src", "turn_procs", "trick_shot_hit") then --did not hit an actor
						if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, Map.TERRAIN, "pass_projectile")  then --bounce off terrain
							print("[TrickShot] struck terrain at ", x, y)
						else -- missed target, terminate
							print("[TrickShot] missed target at ", x, y)
							return true
						end
					end
					tg.nb_tricks = tg.nb_tricks - 1
					local st = table.remove(tg.target_list, 1)
					tg.x = x
					tg.y = y
					tg.archery.mult = tg.archery.mult * tg.ricochetDam --reduce damage and accuracy after bounce
					tg.archery.atk = (tg.archery.atk or 0) - tg.ricochetAcc
					print("[TrickShot] redirecting to", st.x, st.y, "from", x, y, "mult:", tg.archery.mult, "acc:", tg.archery.atk)
					self:projectile(tg, st.x, st.y, damtype)
	-- could use a nice ricochet type sound here....
					game:playSoundNear({x=x, y=y}, "actions/melee_thud")
					game.level.map:particleEmitter(x, y, 1, "force_hit", {power=1, dx=st.x-x, dy=st.y-y})
				end
				return true --kill original projectile
			end,
			nb_tricks=t.getNb(self, t),
			ricochetDam = t.ricochetDamage(self, t),
			ricochetAcc=(1-t.ricochetAccuracy(self, t))*self:combatAttackRanged(main.combat, ammo.combat),
		}
		local targets, x, y = self:archeryAcquireTargets(tg, {one_shot=true, type="steamgun"})
		if targets then
			local target_list = {} -- build list of possible targets within ricochet range
			local main = targets.main[1]
			local off = targets.off[1]
			x, y = main and main.x, main and main.y -- target coords
			if x and y then
				for actor, params in pairs(self.fov.actors) do
					-- need clear view of targets
					if actor and actor ~= self and self:reactionToward(actor) < 0 and self:canSee(actor) and (core.fov.distance(self.x, self.y, actor.x, actor.y) <= math.max(self.lite, self.heightened_senses or 0, self.infravision or 0) or game.level.map.lites(x, y)) then
						local dist = core.fov.distance(x, y, actor.x, actor.y)
						if dist > 0 and dist <= 5 then
							print("[TrickShot] found possible actor", actor.name, actor.x, actor.y, "distance", dist)
							target_list[#target_list+1] = {actor = actor, x=actor.x, y=actor.y, dist=dist}
						end
					end
				end
				table.sort(target_list, "dist")
			end
			tg.target_list = target_list
			self:archeryShoot(targets, t, tg, {mult=t.damageMult(self, t), type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		local main, ammo, off = self:hasDualArcheryWeapon("steamgun")
		local accy = main and ammo and self:combatAttackRanged(main.combat, ammo.combat) or 0
		local ricoaccy = 1-t.ricochetAccuracy(self, t)
		return ([[Your cunning and dexterity allow you to fire incredible trick shots that can hit multiple targets.
		You precisely aim your trick shot to ricochet amongst foes you can see so that whenever it hits something solid (creature or solid wall), it will bounce towards the next closest foe.
		It may ricochet up to %d times (or until it misses) within range 5 of your first target and will not target the same foe twice.
		Your shot deals %d%% weapon damage on its first strike, but loses %d%% damage and %d(%d%%) accuracy with each bounce.]]):
		tformat(t.getNb(self, t), 100 * t.damageMult(self, t), (1-t.ricochetDamage(self, t))*100, accy*ricoaccy, ricoaccy*100)
	end,
}
