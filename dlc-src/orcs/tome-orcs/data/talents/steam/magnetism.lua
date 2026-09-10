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
	name = "Static Shock", 
	type = {"steamtech/magnetism", 1},
	points = 5,
	require = steamreq1,
	mode = "passive",
	getResists = function(self, t) return self:combatTalentLimit(t, 50, 10, 25) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1) end,
	on_learn = function(self, t)
		self:attr("allow_wear_shield", 1)
		self:attr("show_shield_combat", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("allow_wear_shield", -1)
		self:attr("show_shield_combat", 1)
	end,
	callbackOnTalentPost = function(self, t, ab, ret)
		if ab.id == self.T_BLOCK and ret == true then
		self:setEffect(self.EFF_STATIC_SHIELD, 4, {src=self, power=t.getResists(self,t), dam=t.getDamage(self,t)})
		
		local apply = function(a)
			a:setEffect(a.EFF_STATIC_SHIELD, 4, {src=self, power=t.getResists(self,t), dam=t.getDamage(self,t)})
		end

		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.turret then apply(act) end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.turret then apply(act) end
			end
		end
		
		return true
		else return end
	end,
	info = function(self, t)
		local resist = t.getResists(self,t)
		local damage = t.getDamage(self, t)
		return ([[Using your Block talent surrounds you and your minions in a static barrier for 4 turns, increasing all resistances by %d%%. If an enemy deals damage to you or your minions, the barrier will shock them for %d%% of your shield damage.
		This effect cannot damage the same target more than once per turn, and will not interact with Counterstrike.
You now also use your Cunning in place of Strength when equipping shields as well as when calculating shield damage.]]):tformat(resist, damage*100)
	end,
}

newTalent{
	name = "Magnetic Field",
	type = {"steamtech/magnetism", 2},
	require = steamreq2,
	points = 5,
	cooldown = 10,
	steam = 20,
	tactical = { ATTACKAREA = {SHIELD = 2, LIGHTNING = 2} },
	radius = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 6)) end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a shield for this talent.") end return false end return true end,
	getSlow = function(self,t) return math.min(100, self:combatTalentScale(t, 15, 50)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 3.0) end,
	getCrit = function(self,t) return self:combatTalentLimit(t, 25, 3, 15) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "slow_projectiles", t.getSlow(self, t))
		self:talentTemporaryValue(p, "combat_crit_reduction", t.getCrit(self, t))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local shield, shield_combat = self:hasShield()
		if not shield then return end
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			self:attackTargetWith(target, shield_combat, DamageType.LIGHTNING, t.getDamage(self,t))
			if target:canBe("knockback") then target:knockback(self.x, self.y, self:getTalentRadius(t)) end
		end)
		self:project(tg, self.x, self.y, function(px, py)
				local proj = game.level.map(px, py, Map.PROJECTILE)
				if not proj then return end
				proj:terminate(x, y)
				game.level:removeEntity(proj, true)
				proj.dead = true
				self:logCombat(proj, "#Source# shatters '#Target#'.")
		end)
			
		if core.shader.active(4) then
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "shader_ring", {radius=tg.radius*2, life=8}, {type="sparks"})
		else
			local x, y = self.x, self.y
			-- Lightning ball gets a special treatment to make it look neat
			local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
			local nb_forks = 16
			local angle_diff = 360 / nb_forks
			for i = 0, nb_forks - 1 do
				local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
				local tx = x + math.floor(math.cos(a) * tg.radius)
				local ty = y + math.floor(math.sin(a) * tg.radius)
				game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
			end
		end
		self:setEffect(self.EFF_DEMAGNETIZED, 10, {src=self, slow=t.getSlow(self,t), crit=t.getCrit(self,t)})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self,t)
		local crit = t.getCrit(self,t)
		local damage = t.getDamage(self,t)*100
		local radius = self:getTalentRadius(t)
		return ([[You project a powerful blast of magnetic energy from your shield in radius %d around you. Enemies caught within are knocked back %d tiles and take %d%% shield damage as lightning, and any projectiles will be destroyed.
		While this talent is not on cooldown, you also project a magnetic field from your shield, reducing the speed of incoming projectiles by %d%% and your chance to be critically hit by %d%%.]])
		:tformat(radius, radius, damage, slow, crit)
	end,
}

newTalent{
	name = "Capacitor Discharge",
	type = {"steamtech/magnetism", 3},
	require = steamreq3,
	points = 5,
	steam = 15,
	cooldown = 4,
	tactical = { ATTACK = {SHIELD = 2, LIGHTNING = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a shield for this talent.") end return false end return true end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.3) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 40, 400) end,
	getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	getBlock = function(self, t) return math.floor(self:combatTalentScale(t, 15, 40)) end,
	passives = function(self, t, p)
		local shield, combat = self:hasShield()
		if not combat then return end
		self:talentTemporaryValue(p, "block_bonus", (combat.block or 0) * t.getBlock(self, t) / 100)
	end,
	callbackOnBlock = function(self, t, eff, dam, type, src, blocked)
		self:setEffect(self.EFF_CAPACITOR_DISCHARGE, 10, {power=blocked, max_power=t.getDamage(self,t)})		
	end,
	callbackOnWear = function(self, t, o, bypass_set)
		self:updateTalentPassives(t)
	end,
	callbackOnTakeoff = function(self, t, o, bypass_set)
		self:updateTalentPassives(t)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end
		local eff = self:hasEffect(self.EFF_CAPACITOR_DISCHARGE)
		local shield, shield_combat = self:hasShield()
		if not shield then return end
		
		if not eff then
			local target = game.level.map(fx, fy, Map.ACTOR)
			if not target then return nil end
			self:attackTargetWith(target, shield_combat, DamageType.LIGHTNING, t.getShieldDamage(self,t))		
			return true
		end
		
		local nb = t.getTargetCount(self, t)
		local affected = {}
		local first = nil
		local dam = self:steamCrit(eff.power)

		self:project(tg, fx, fy, function(dx, dy)
			print("[Chain lightning] targetting", fx, fy, "from", self.x, self.y)
			local actor = game.level.map(dx, dy, Map.ACTOR)
			if actor and not affected[actor] then
				affected[actor] = true
				first = actor

				print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 10, "from", actor.name)
				self:project({type="ball", selffire=false, x=dx, y=dy, radius=10, range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		if not first then return end
		local targets = { first }
		affected[first] = nil
		local possible_targets = table.listify(affected)
		print("[Chain lightning] Found targets:", #possible_targets)
		for i = 2, nb do
			if #possible_targets == 0 then break end
			local act = rng.tableRemove(possible_targets)
			targets[#targets+1] = act[1]
		end

		local sx, sy = self.x, self.y
		for i, actor in ipairs(targets) do
			local tgr = {type="hit", range=self:getTalentRange(t), selffire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			daze = 0
			if eff.power == eff.max_power then
				self.turn_procs.auto_phys_crit = true										
				daze = 100
			end
			if i==1 then
				self:attackTargetWith(actor, shield_combat, DamageType.LIGHTNING, t.getShieldDamage(self,t))
			end
			self.turn_procs.auto_phys_crit = nil							
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING_DAZE, {dam=dam, daze=daze})
			if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy}, {type="lightning"})
			else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy})
			end

			sx, sy = actor.x, actor.y
		end

		self:removeEffect(self.EFF_CAPACITOR_DISCHARGE)
		
		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
	local block = t.getBlock(self,t)
	local dam = t.getDamage(self,t)
	local shielddam = t.getShieldDamage(self,t)*100
	local nb = t.getTargetCount(self,t)
		return ([[Mount capacitors to your shield that dampen the impact of attacks, increasing block value by %d%% and storing 100%% of the damage blocked as an electrical charge (to a maximum of %d).
Activating this ability discharges blocked damage, firing a bolt of lightning dealing %d%% shield damage as lightning to the first target, then projecting a bolt of lightning that arcs to %d other targets dealing lightning damage equal to the stored amount.
If at maximum charge, this also dazes for 2 turns and the shield strike is a guarenteed critical hit.
The maximum damage you can absorb will increase with your Steampower.]]):
		tformat(block, dam, shielddam, nb)
	end,
}

newTalent{
	name = "Lightning Web",
	type = {"steamtech/magnetism", 4},
	points = 5,
	cooldown = 18,
	steam = 40,
	random_ego = "attack",
	require = steamreq4,
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false}
	end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a shield for this talent.") end return false end return true end,
	tactical = { ATTACKAREA = { LIGHTNING = 2 }, DEFEND = 2, },
	getDuration = function(self,t) return 4 end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.6) end,
	getBlock = function(self,t) return self:combatTalentLimit(t, 100, 15, 50) end,
	action = function(self, t)
		local base = self:combatShieldBlock()
		if not base then return end
		local block = base * t.getBlock(self,t)/100
		-- Add a lasting map effect
		local ef = game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.LIGHTNING_WEB, {dam=t.getDamage(self,t), block=block},
			3,
			5, nil,
			{type="shader_ring_rotating", args={rotation=0, radius=3, img="lightning_web_lightningshield"}, shader={type="lightningshield"}, only_one=true},
			-- {type="firestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			true
		)
		ef.name = _t"lightning web"
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)*100
		local duration = t.getDuration(self, t)
		local block = t.getBlock(self,t)
		local base = self:combatShieldBlock()
		local block2 = 0
		if base then block2 = base * t.getBlock(self,t)/100 end
		return ([[Project a radius 3 electric field from your shield lasting %d turns. Enemies within this field will take an automatic shield strike for %d%% lightning damage each turn, while allies will gain flat damage reduction equal to %d%% (%d) of block value.
		All damage reduced by this effect will be stored for Capacitor Discharge.]]):
		tformat(duration, damage, block, block2)
	end,
}