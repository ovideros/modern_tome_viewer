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
	name = "Steamgun Mastery",
	type = {"steamtech/gunner-training", 1},
	points = 5,
	require = { stat = { dex=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	autolearn_talent = "T_SHOOT",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	ammo_mastery_reload = function(self, t)
		return math.floor(self:combatTalentScale(t, 0, 2.7, "log"))
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'ammo_mastery_reload', t.ammo_mastery_reload(self, t))
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		local reloads = t.ammo_mastery_reload(self, t)
		return ([[Increases weapon damage by %d%% and Physical Power by 30 when using steamguns.
		Also, increases your reload rate by %d.]]):tformat(inc * 100, reloads)
	end,
}

newTalent{
	name = "Double Shots",
	type = {"steamtech/gunner-training", 2},
	points = 5,
	cooldown = 10,
	steam = 25,
	require = dex_steamreq2,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 }, },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDur = function(self, t) return self:combatTalentLimit(t, 6, 1.1, 2.5, false, 1.0) end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.7) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, t.getDur(self, t), {apply_power=self:combatSteampower()})
		else
			game.logSeen(target, "%s resists!", target:getName():capitalize())
		end
	end,
	action = function(self, t)
		local targetmode_trigger_hotkey
		if self.player then targetmode_trigger_hotkey = game.targetmode_trigger_hotkey end
		local mult = t.getMultiple(self, t)
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, type="steamgun"})
		if not targets then return end

		self:archeryShoot(targets, t, nil, {mult=mult, type="steamgun"})

		if self.player then game.targetmode_trigger_hotkey = targetmode_trigger_hotkey end
		local targets = self:archeryAcquireTargets(nil, {no_energy=true, type="steamgun"})
		if not targets then return true end
		self:archeryShoot(targets, t, nil, {mult=mult, type="steamgun"})
		return true
	end,
	info = function(self, t)
		return ([[In an overpowering display of marksmanship, you fire your steamgun(s) twice in rapid succession.
Each shot (targeted separately) deals %d%% damage and stuns its target for %d turns.
		The stun chance increases with your Steampower.]]):tformat(100 * t.getMultiple(self, t), t.getDur(self, t))
	end,
}

newTalent{
	name = "Uncanny Reload",
	type = {"steamtech/gunner-training", 3},
	points = 5,
	cooldown = 20,
	steam = 15,
	require = dex_steamreq3,
	range = steamgun_range,
	no_energy = true,
	requires_target = true, -- keep ai from wasting this talent out of combat
	tactical = { BUFF=1, AMMO=1 },
	getDur = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 2, 5)) end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	on_pre_use_ai = function(self, t, silent, fake)
		if (self.steam or 0) + (self.steam_regen or 0) < t.steam + 10 then return end -- Make sure AI doesn't use this and not have a followup attack
		local weapon, ammo, offweapon = self:hasArcheryWeapon("steamgun")
		if not (weapon and ammo) or ammo.infinite or self:attr("infinite_ammo") or ammo.combat.shots_left/ammo.combat.capacity > 0.5 then return end
		return true
	end,
	action = function(self, t)
		self:setEffect(self.EFF_UNCANNY_RELOAD, math.floor(self:steamCrit(t.getDur(self, t))), {})
		return true
	end,
	info = function(self, t)
		return ([[You focus on managing your steamgun ammo for %d turns.
		While the effect lasts your attacks do not consume shots.]])
		:tformat(t.getDur(self, t))
	end,
}

newTalent{
	name = "Static Shot",
	type = {"steamtech/gunner-training", 4},
	points = 5,
	cooldown = 8,
	steam = 40,
	require = dex_steamreq4,
	radius = 2,
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACKAREA = { LIGHTNING = 3 }},
	target = function(self, t) return {type="ball", range=nil, radius=self:getTalentRadius(t), selffire=false,
	display={particle="bolt_lightning", trail="lightningtrail"}} end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getRemoveCount = function(self, t) return self:combatTalentLimit(t, 3, 1, 1.5) end,
	getMultiple = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.2) end,
	archery_onhit = function(self, t, target, x, y)
		game.level.map:particleEmitter(x, y, 1, "ball_lightning_beam", {radius=1.5, tx=self.x, ty=self.y})
		if table.get(target.turn_procs, "static_shot", self) == true then return end -- only debuff once per turn
		table.set(target.turn_procs, "static_shot", self, true)

		local effs = {}
		-- Go through all effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if (e.type == "physical" or e.type == "mental") and e.status == "beneficial" then
				effs[#effs+1] = eff_id
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			target:dispel(eff, self)
		end
	end,
	action = function(self, t)
		local tg = t.target(self, t)
		local targets = self:archeryAcquireTargets(tg, {no_energy=true, infinite=true, one_shot=true, type="steamgun"})
		if targets then
			-- Note:proj.project.def.x/y as set by archeryAcquireTargets are the target location selected, not necessarily reachable 
			tg.on_stop_check=function(self, typ, tg, damtype, dam, particles, x, y, tmp, rx, ry, proj)
				if (proj.project.def.x == x and proj.project.def.y == y) or typ:block_path(x, y) or core.fov.distance(x, y, proj.start_x, proj.start_y) >= tg.range then
					print("[Static Shot] Projectile", proj.uid, "burst at ", x, y)
					local burst = table.clone(tg, true)
					burst.type = "hit" burst.radius = nil
					game:playSoundNear({x=x, y=y}, "talents/lightning")
					self:project(burst, x, y, self.archery_projectile)
					return true 
				end
				proj._stop_count = (proj._stop_count or 0) + 1
				if proj._stop_count > 1 then
					print("[Static Shot] Projectile", proj.uid, "stop at ", x, y, " proj:")
					table.print(proj, "--")
					if proj._stop_count > 1 then return true end -- safety net
				end
			end
			self:archeryShoot(targets, t, tg, {mult=t.getMultiple(self, t), damtype=DamageType.LIGHTNING, type="steamgun"})
			return true
		end
	end,
	info = function(self, t)
		return ([[You fire a special, electrically charged shot with your steamgun(s) at a spot within range.
		When each shot reaches its target, it bursts into electrified shrapnel within radius %d, which shocks each target hit and deals %d%% weapon damage as lightning.
		Shocked targets lose up to %d non-magical effects (for the first shot that hits).
		This talent does not use ammo.]])
		:tformat(self:getTalentRadius(t), 100 * t.getMultiple(self, t), t.getRemoveCount(self, t))
	end,
}
