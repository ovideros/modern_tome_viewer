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
	name = "Psyshot", 
	type = {"steamtech/psytech-gunnery", 1},
	points = 5,
	require = { stat = { dex=function(level) return 12 + level * 6 end }, },
	steam = 5,
	psi = 4,
	cooldown = 7,
	is_psyshot = true,
	autolearn_talent = "T_SHOOT",
	no_energy = "fake",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	mindstarMult = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 2.5) end,
	getShootDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 1.9) end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if not hitted or not weapon or weapon.talented ~= "steamgun" then return end
		local mindstar = self:getInven(self.INVEN_OFFHAND) and self:getInven(self.INVEN_OFFHAND)[1]
		if not mindstar or mindstar.subtype ~= "mindstar" then return end
		if self:attr("psiblades_active") then return end
		if target.dead then return end

		self.turn_procs.auto_melee_hit = true
		self:attackTargetWith(target, mindstar.combat, nil, t.mindstarMult(self, t))
		self.turn_procs.auto_melee_hit = nil
	end,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getShootDamage(self, t), damtype=DamageType.MIND})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases weapon damage by %d%% and Physical Power by 30 when using steamguns.
		When your bullets hit a target you instinctively reach out to the impact and use the kinetic force to project a mindstar attack doing %d%% damage (guaranteed hit), if you wield one in the offhand.
		This projection requires a pure mindstar; it will not work if extended into a psiblade.

		Also activable for a shot that deals %d%% weapon damage as mind damage.]]):tformat(inc * 100, t.mindstarMult(self, t) * 100, t.getShootDamage(self, t) * 100)
	end,
}

newTalent{
	name = "Boiling Shot",
	type = {"steamtech/psytech-gunnery", 2},
	points = 5,
	cooldown = 8,
	steam = 25,
	psi = 15,
	is_psyshot = true,
	require = dex_steamreq2,
	no_energy = "fake",
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getSplash = function(self, t) return self:combatTalentSteamDamage(t, 20, 400) end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 2) end,
	archery_onhit = function(self, t, target, x, y)
		if target:hasEffect(target.EFF_WET) then
			target:removeEffect(target.EFF_WET)
			self:project({type="ball", radius=4, friendlyfire=false, start_x=x, start_y=y}, x, y, DamageType.FIRE, self:steamCrit(t.getSplash(self, t)))
			game.level.map:particleEmitter(x, y, 4, "fireflash", {radius=4})
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDam(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Using psionic energies you overheat your shot, making it deal %d%% damage.
		If the shot hits a wet foe it will vaporize, removing the wet effect and dealing %0.2f fire damage in a radius 4.]]):tformat(100 * t.getDam(self, t), damDesc(self, DamageType.FIRE, t.getSplash(self, t)))
	end,
}

newTalent{
	name = "Blunt Shot",
	type = {"steamtech/psytech-gunnery", 3},
	points = 5,
	cooldown = 11,
	steam = 25,
	psi = 15,
	is_psyshot = true,
	require = dex_steamreq3,
	no_energy = "fake",
	range = steamgun_range,
	requires_target = true,
	radius = 4,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDur = function(self, t) return self:combatTalentLimit(t, 10, 3, 7) end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.5) end,
	archery_onhit = function(self, t, target, x, y)
		local a = math.atan2(y - self.y, x - self.x)
		local dx, dy = x + math.cos(a) * 100, y + math.sin(a) * 100
		self:project({type="cone", start_x=x, start_y=y, range=0, radius=self:getTalentRadius(t)}, dx, dy, function(px, py)
			local tgt = game.level.map(px, py, engine.Map.ACTOR)
			if not tgt then return end
			if tgt:canBe("stun") then
				tgt:setEffect(tgt.EFF_STUNNED, t.getDur(self, t), {apply_power=self:combatAttack()})
			end
		end)
		game.level.map:particleEmitter(x, y, self:getTalentRadius(t), "directional_shout", {life=8, size=3, tx=dx-x, ty=dy-y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.6, bm=0.1, bM=0.2, am=1, aM=1})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDam(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Fire a relatively low-powered shot at a foe doing %d%% weapon damage, if it hits a cone-shaped shockwave of radius 4 emanates from the impact, stunning it and all creatures caught inside for %d turns.]])
		:tformat(100 * t.getDam(self, t), t.getDur(self, t))
	end,
}

newTalent{
	name = "Vacuum Shot",
	type = {"steamtech/psytech-gunnery", 4},
	points = 5,
	cooldown = 8,
	steam = 10,
	psi = 10,
	is_psyshot = true,
	require = dex_steamreq4,
	no_energy = "fake",
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	radius = function(self, t) return self:combatTalentLimit(t, 10, 3, 7) end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 2.2) end,
	archery_onhit = function(self, t, target, x, y)
		self:project({type="ball", start_x=x, start_y=y, radius=self:getTalentRadius(t)}, x, y, function(px, py)
			local tgt = game.level.map(px, py, engine.Map.ACTOR)
			if not tgt or tgt == self then return end
			if tgt:canBe("knockback") then
				tgt:pull(x, y, core.fov.distance(x, y, px, py))
			end
		end)
		game.level.map:particleEmitter(x, y, self:getTalentRadius(t), "gravity_spike", {radius=self:getTalentRadius(t), allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDam(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Attach a psionic steam device to a shot doing %d%% weapon damage.
		When it hits a foe the device activates, violently sucking all the air nearby, pulling in all creatures in radius %d.]])
		:tformat(100 * t.getDam(self, t), self:getTalentRadius(t))
	end,
}
