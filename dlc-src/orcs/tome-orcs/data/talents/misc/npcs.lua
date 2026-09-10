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

newTalent{
	name = "Petrifying Gaze",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 25,
	cooldown = 15,
	tactical = { DISABLE = { stun = 1.5, instakill = 1.5 } },
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	range = 0,
	requires_target = true,
	target = function(self, t)
		return {type="cone", radius=self:getTalentRange(t), talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3.6, 8.3)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end

			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
				game.level.map:particleEmitter(tx, ty, 1, "archery")
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=8, size=2, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Gaze at your foes and turn them to stone for %d turns.
		Stoned creatures are unable to act or regen life, and are very brittle.
		If a stoned creature is hit by an attack that deals more than 30%% of its life, it will shatter and be destroyed.
		Stoned creatures are highly resistant to fire and lightning, and somewhat resistant to physical attacks.
		This spell may fail against creatures resistant to being stunned, that are specifically immune to stoning, or certain bosses.]]):
		tformat(duration)
	end,
}

newTalent{
	name = "Gnashing Maw",
	type = {"technique/other", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 12,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	action = function(self, t)
		local weapon = self.combat

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to Sunder !
		if hit then
			target:setEffect(target.EFF_SUNDER_ARMS, t.getDuration(self, t), {power=3*self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target's Accuracy is reduced by %d for %d turns.
		Accuracy reduction chance increases with your Physical Power.]])
		:tformat(
			100 * self:combatTalentWeaponDamage(t, 1, 1.5), 3 * self:getTalentLevel(t), t.getDuration(self, t))
	end,
}

local sandtrap = nil
newTalent{
	name = "Sandrush",
	type = {"technique/other", 1},
	message = _t"@Source@ dives in the sand!",
	require = techs_strdex_req1,
	points = 5,
	random_ego = "attack",
	stamina = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 36, 20)) end, --Limit to >0
	tactical = { ATTACK = { weapon = 1, pin = 1 }, CLOSEIN = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	duration = function(self, t) return math.floor(self:combatStatScale("str", 6, 15)) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

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

		local dur = t.duration(self, t)
		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			self:attackTarget(target, nil, 1.2, true)
		end

		-- Make some nasty traps
		if not sandtrap then
			local list = mod.class.Trap:loadList("/data-orcs/general/traps/ritch.lua")
			sandtrap = list.RITCH_SAND_PIT
		end
		for i = -1, 1 do for j = -1, 1 do
			local x, y = self.x + i, self.y + j
			local t = sandtrap:clone()
			t:resolve()
			t:resolve(nil, true)
			t.temporary = dur
			t.x, t.y = x, y
			game.zone:addEntity(game.level, t, "trap", x, y)
			game.level:addEntity(t) --?
		end end

		return true
	end,
	info = function(self, t)
		return ([[Dive into the sand and rush towards your target at up to range %d, gaining a free attack if you reach it.
		At the exit point, up to 9 sand pits will appear that last for %d turns (based on your Strength).
		You must rush from at least 2 tiles away.]]):tformat(t.range(self, t), t.duration(self, t))
	end,
}

newTalent{
	name = "Ritch Larva Infect",
	type = {"wild-gift/other", 1},
	message = _t"@Source@ stings with her ovipositor!",
	require = techs_strdex_req1,
	points = 5,
	stamina = 10,
	cooldown = 8,
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getNb = function(self, t) return math.ceil(self:combatTalentLimit(t, 9, 1, 3)) end,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "dex", 10, 70) end, --Final "burst" damage per larva
	on_pre_use_ai = function(self, t, silent, fake) return self.ai_target.actor and (self.ai_target.actor:checkClassification("living") or rng.chance(2)) end,  -- AI less likely to use against undead/constructs
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		if self:attackTarget(target, nil, 1.0, true) and target:checkClassification("living") then
			target:setEffect(target.EFF_RITCH_LARVA_EGGS, 5, {src=self, apply_power=self:combatAttack(), dam=t.getDamage(self, t), nb=t.getNb(self, t), gestation=5})
		end

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local nb = t.getNb(self, t)
		local Pdam, Fdam = self:damDesc(DamageType.PHYSICAL, dam/2), self:damDesc(DamageType.FIRE, dam/2)
		return ([[Sting the target with your ovipositor, injecting %d larvae into it to finish their hatching process.
		Over a 5 turn gestation period, the larvae will feed on the victim internally, dealing %0.2f to %0.2f physical damage each turn (increasing as they grow).
		After the gestation period is complete, each larva will rip itself free of its host, dealing %0.2f physical and %0.2f fire damage.
		]]):tformat(nb, nb*Pdam*2*.05, nb*Pdam*2*.25, Pdam, Fdam)
	end,
}

newTalent{
	name = "Slumbering...", short_name = "AMAKTHEL_SLUMBER",
	type = {"other/horror", 1},
	mode = "sustained",
	points = 1,
	message = _t"@Source@ enters a deep slumber.",
	cooldown = 15,
	no_energy = true,
	tactical = { BUFF = 100 }, -- Just so that it tries to get used ASAP
	callbackOnActBase = function(self, t)
		if self.perma_slumber then return end
		local p = self:isTalentActive(t.id)
		if not p then return end
		if rng.percent(p.percent) then self:forceUseTalent(t.id, {ignore_energy=true})
		else p.percent = p.percent * 1.2 end
	end,
	activate = function(self, t)
		if not self.silent_slumber then
			game.bignews:saySimple(60, "#STEEL_BLUE#%s slumbers...", self:getName())
		end
		local ret = { percent = 4 }
		self:talentTemporaryValue(ret, "never_act", 1)

		self.replace_display = mod.class.Actor.new{
			image="invis.png", 
			add_mos = {{image = "npc/"..tostring(self.type or "unknown").."_"..tostring(self.subtype or "unknown"):lower():gsub("[^a-z0-9]", "_").."_"..(self.name or "unknown"):lower():gsub("[^a-z0-9]", "_").."_closed.png", 
			display_y = -1, 
			display_h = 2}},
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		return ret
	end,
	deactivate = function(self, t)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		if not self.silent_slumber then
			game.bignews:saySimple(60, "#CRIMSON#%s awakens!", self:getName())
		end
		return true
	end,
	info = function(self, t)
		return (_t[[The Dead God slumbers. For now.]])
	end,
}

newTalent{
	name = "Tentacle Spawn", short_name = "AMAKTHEL_TENTACLE_SPAWN",
	type = {"other/horror", 1},
	points = 1,
	message = _t"@Source@ spawns a tentacle near @target@.",
	cooldown = 12,
	range = 10,
	tactical = { ATTACK = 10 },
	target = function(self, t) return {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t} end,
	action = function(self, t)
		if not self:canBe("summon") then game.logPlayer(self, "You cannot summon; you are suppressed!") return end

		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)

		local ok = false
		
		-- Find space
		for i = 1, (self.tentacle_summon_nb or 1) do
			local x, y = util.findFreeGrid(tx, ty, 10, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return false
			end

			-- Find an actor with that filter
			local m = game.zone:makeEntityByName(game.level, "actor", self.tentacle_summon, true)
			if m then
				m.exp_worth = 0
				m:resolve()

				m.summoner = self
				m.summon_time = 24
				m.faction = self.faction

				game.zone:addEntity(game.level, m, "actor", x, y)

				self:logCombat(m, "#ORCHID#%s summons a %s...", self:getName():capitalize(), m:getName())

				game.bignews:saySimple(60, "#ORCHID#%s summons a %s...", self:getName():capitalize(), m:getName())
				ok = true
			end
		end
		if ok then return true end
		return nil
	end,
	info = function(self, t)
		return (_t[[The Dead God wishes to tickle you...]])
	end,
}

newTalent{
	name = "Curse of Amakthel",
	type = {"psionic/other", 1},
	points = 1,
	cooldown = 16,
	range = 10,
	tactical = { DISABLE = 5 },
	getDuration = function(self, t) return 10 end,
	radius = function(self, t) return 3 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)

		-- Add a lasting map effect
		game.level.map:addEffect(self,
			tx, ty, self:spellCrit(t.getDuration(self, t)),
			DamageType.CURSE_OF_AMAKTHEL, 200,
			self:getTalentRadius(t),
			5, nil,
			{zdepth=6, only_one=true, type="circle", args={img="sun_circle", a=10, speed=0.04, radius=self:getTalentRadius(t)}},
			nil, false
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Create a circle of cursed ground (radius %d) for %d turns. Any foes inside will be cursed, all new negative effects on them will have their duration doubled.
		]]):
		tformat(radius, duration)
	end,
}

newTalent{
	name = "Temporal Ripples",
	type = {"chronomancy/other", 1},
	points = 1,
	cooldown = 16,
	range = 10,
	tactical = { DISABLE = 5 },
	getDuration = function(self, t) return 10 end,
	radius = function(self, t) return 3 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)

		-- Add a lasting map effect
		game.level.map:addEffect(self,
			tx, ty, self:spellCrit(t.getDuration(self, t)),
			DamageType.TEMPORAL_RIPPLES, 200,
			self:getTalentRadius(t),
			5, nil,
			{zdepth=6, only_one=true, type="circle", args={img="sun_circle", a=10, speed=0.04, radius=self:getTalentRadius(t)}},
			nil, false
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Creates a circle of radius %d of altered time for %d turns. Any damage your foes take while standing in it will heal the attacker for 200%% of the damage dealt.
		]]):
		tformat(radius, duration)
	end,
}

newTalent{
	name = "Saw Storm", image = "talents/sawfield.png",
	type = {"psionic/horror",1},
	points = 5,
	random_ego = "attack",
	psi = 25,
	cooldown = 20,
	tactical = { ATTACKAREA = { PHYSICAL = 2, stun = 1 } },
	range = 0,
	radius = 3,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 120) end,
	getDuration = function(self, t) return
		math.floor(self:combatScale(self:combatMindpower(0.06) + self:getTalentLevel(t)/1.5, 3, 0, 8.33, 5.33))
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.PHYSICALBLEED, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="sawstorm", args={rad=self:getTalentRadius(t)}, only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/icestorm")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Summon a storm of swirling sawblades to slice your foes, inflicting %d physical damage and bleeding to anyone who approaches for %d turns.
		The damage and duration will increase with your Mindpower.]]):tformat(damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}

newTalent{
	name = "Razor Saw", image = "talents/to_the_arms.png",
	type = {"psionic/horror", 1},
	points = 5,
	psi = 18,
	cooldown = 8,
	range = 7,
	random_ego = "attack",
	tactical = { ATTACK = {PHYSICAL = 2} },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICALBLEED, self:mindCrit(self:combatTalentMindDamage(t, 60, 300)), {type="bones"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[Launches a sawblade with intense power doing %0.2f physical damage to all targets in line.
		The damage will increase with Mindpower]]):tformat(damDesc(self, DamageType.PHYSICAL, self:combatTalentMindDamage(t, 60, 300)))
	end,
}

newTalent{
	name = "Rocket Dash",
	type = {"technique/other", 1},
	message = _t"@Source@ rockets forward!",
	points = 5,
	random_ego = "attack",
	cooldown = 12,
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
		game.level.map:particleEmitter(ox, oy, tg.radius, "flamebeam", {tx=self.x-ox, ty=self.y-oy})
		-- Attack ?
		if target and core.fov.distance(self.x, self.y, target.x, target.y) <= 1 then
			self:attackTarget(target, nil, 1.3, true)
		end

		return true
	end,
	info = function(self, t)
		return (_t[[Dash forward using rockets.
		If the spot is reached and occupied, you will perform a free melee attack against the target there.
		This attack does 130% weapon damage.
		You must dash from at least 2 tiles away.]])
	end,
}

-- Solely used to track the achievement
newTalent{
	name = "Mind Controlled Yeti", short_name = "ACHIEVEMENT_MIND_CONTROLLED_YETI",
	type = {"psionic/other", 1},
	points = 1,
	mode = "passive",
	callbackOnKill = function(self, t, who)
		world:gainAchievement("ORCS_YETI_WAR", game.player)
	end,
	info = function(self, t)
		return "Yeti SMASH!"
	end,
}
