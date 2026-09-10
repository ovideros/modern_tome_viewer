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

function turretCooldown(self, id)
	local turrets = {self.T_STEAMGUN_TURRET, self.T_FLAME_TURRET, self.T_MEDIC_TURRET}
	for i, t in ipairs(turrets) do
		if id and id ~= t then
			if self:knowTalent(t) then
				local t = self:getTalentFromId(t)
				self:startTalentCooldown(t, 5)
			end	
		end
	end
end

newTalent{
	name = "Deploy Turret", image = "talents/steamgun_turret.png",
	type = {"steamtech/turrets", 1},
	points = 5,
	require = steamreq1,
	mode = "passive",
	getStatBonus = function(self, t) return self:combatTalentSteamDamage(t, 5, 50) end,
	getHeal = function(self, t) return self:combatTalentSteamDamage(t, 5, 60) end,
	getFlameArmor = function(self, t) return 5 + math.floor(self:combatTalentSteamDamage(t, 5, 50)) end,
	getSteamgunDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.5) end,
	getEffectReduce = function(self, t) return math.min(70, math.floor(self:combatTalentScale(t, 10, 45))) end,
	callbackOnDeath = function(self, t)
		-- Remove all turrets on death, QOL vs NPCs
		for uid, e in pairs(game.level.entities) do
			if e.turret and e.summoner and e.summoner == self then e:die() end
		end
	end,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self:learnTalent(self.T_STEAMGUN_TURRET, true, nil, {no_unlearn=true})
		elseif lev == 3 then
			self:learnTalent(self.T_FLAME_TURRET, true, nil, {no_unlearn=true})
		elseif lev == 4 then
			self:learnTalent(self.T_MEDIC_TURRET, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(self.T_STEAMGUN_TURRET)
		elseif lev == 2 then
			self:unlearnTalent(self.T_FLAME_TURRET)
		elseif lev == 3 then
			self:unlearnTalent(self.T_MEDIC_TURRET)
		end
	end,
	info = function(self, t)
		return ([[You are able to deploy turrets, stationary constructs that defend you in combat. Turrets last 10 turns, have a 20 turn cooldown, and deploying a turret places the others on a 5 turn cooldown.
You learn new turrets as you invest in this talent.

At raw talent level 1 you can use Steamgun turrets, which fire at a random target nearby for %d%% steamgun damage. These shots bypass allies.
At raw talent level 3 you can use Flame turrets, which deal fire damage to enemies in a radius 3 cone. Flame turrets gain %d bonus armor and 30%% resistance to all damage.
At raw talent level 4 you can use Medic turrets, which emit a healing mist that restores %d life to allies and reduces the duration of newly applied detrimental effects by %d%%.
This talent also increases the Dexterity, Constitution and Cunning of all Turrets by %d.

All turrets gain bonus armor equal to 1/2 your level, are immune to all detrimental effects, and inherit your increased damage, resistance penetration, Steampower, Physical Power, and Accuracy.
The stat bonus as well as the damage and healing dealt by Flame and Medic Turrets will increase with your Steampower.]]):
		tformat(t.getSteamgunDamage(self,t)*100, t.getFlameArmor(self,t), t.getHeal(self,t), t.getEffectReduce(self,t), t.getStatBonus(self,t))
end,
}

newTalent{
	name = "Steamgun Turret",
	type = {"steamtech/turret-types",1},
	range = 3,
	points = 1,
	steam = 35,
	cooldown = 20,
	tactical = { ATTACK = {PHYSICAL = 2} },
	requires_target = true,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_DEPLOY_TURRET)
		return t.getStatBonus(self, t)
	end,
	getDamage = function(self, t) 
		local t = self:getTalentFromId(self.T_DEPLOY_TURRET)
		return t.getSteamgunDamage(self, t)
	end,
	target = function(self, t) return {type="bolt", nowarning=true, radius=2, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end, -- for the ai
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "sentry",
			display = "*", color=colors.GREEN,
			name = _t"steamgun turret", faction = self.faction, image = "npc/steamgun_turret1.png",
			desc = _t[[An automated turret equipped with a steamgun.]],
			autolevel = "rogue",
			ai = "tactical", ai_state = { talent_in=1, },
			stats = { dex=15, con=15, cun=15 },
			level_range = {1, 1},
			power_source = {steamtech=true},
			exp_worth = 0,
			inc_stats = {
				dex = t.getStatBonus(self,t),
				con = t.getStatBonus(self,t),
				cun = t.getStatBonus(self,t),
			},

			max_life = 20,
			life_rating = 10,
			never_move = 1,

			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),

			combat_armor_hardiness = 50,
			combat_armor = self.level/2,
			resists = {all = 0},

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			infravision = 20,
			no_breath = 1,
			no_drops = 1,
			archery_pass_friendly = 1,
			minion_be_nice = 1, --not entirely appropriate but works
			mult = t.getDamage(self,t),
			t = t,
			combat = { dam=resolvers.levelup(5, 1, 0.7), atk=7, apr=1 },
			
			on_act = function(self)
				self:useEnergy()
				local Map = require "engine.Map"
				local weapon, ammo, offweapon = self:hasArcheryWeapon()
				if not weapon then return end
				local range = weapon.combat.range
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, range, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, engine.Map.ACTOR)
					if a and self:reactionToward(a) < 0 then
						tgts[#tgts+1] = a
					end
				end end
				local a, id = rng.table(tgts)				
				if not a then return end
				local dualshot = 0
				if self:knowTalent(self.T_TURRET_DUAL_STEAMGUN) then dualshot = self:callTalent(self.T_TURRET_DUAL_STEAMGUN, "getDamage") end
				
				local tg = {type="bolt", range=range, talent=self.t, display=self:archeryDefaultProjectileVisual(weapon, ammo), friendlyblock=false, friendlyfire=false}
				local targets = self:archeryAcquireTargets(tg, {no_sound=true, one_shot=true, infinite=true, no_energy=true, x=a.x, y=a.y})
				local target = game.level.map(a.x, a.y, engine.Map.ACTOR)		
				if not target then return end
				if self:knowTalent(self.T_TURRET_ROCKET_LAUNCHER) and not self:isTalentCoolingDown(self.T_TURRET_ROCKET_LAUNCHER) then
					self:forceUseTalent(self.T_TURRET_ROCKET_LAUNCHER, {ignore_energy=true, force_target=target, ignore_ressources=true}) 
				else
					self:archeryShoot(targets, self.t, tg, {mult=self.mult}) 
					if dualshot > 0 then self:archeryShoot(targets, self.t, tg, {mult=dualshot})  end				
				end

				ammo.combat.shots_left = ammo.combat.capacity
			end,
			on_die = function(self, killer)
				local src = self.summoner
				
				if src:knowTalent(src.T_SAPPER) and self:hasLOS(src.x, src.y) then
					local t = src:getTalentFromId(src.T_SAPPER)
					local tg = {type="ball", radius=3, range=0, friendlyfire=false, x=self.x, y=self.y}
					src:project(tg, self.x, self.y, engine.DamageType.PHYSICAL, t.getTurretPower(src,t))
					game.level.map:particleEmitter(self.x, self.y, 3, "shrapnel_explosion", {radius=3})					
				end
	
			end,
			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },
			resolvers.equip{
				{type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, not_properties={unique=true}, ego_chance=-1000},
				{type="ammo", subtype="shot", autoreq=true, not_properties={unique=true}, ego_chance=-1000},
			},
			resolvers.talents{ [Talents.T_STEAM_POOL]=1, [Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1,
				[Talents.T_STEAMGUN_MASTERY]=self:getTalentLevel(self.T_DEPLOY_TURRET), 
			},
			silent_levelup = true, no_points_on_levelup = true,
			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
		}

		m:resolve() m:resolve(nil, true)
		m.turret = true
		m.steamgun_turret = true

		m.combat_precomputed_steampower = self:combatSteampower()
		m.combat_precomputed_physpower = self:combatPhysicalpower()
		m.combat_precomputed_accuracy = self:combatAttack()

		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control="no",
				type="minion",
				title=_t"Turret",
				orders = {target=true},
			})
		end
		game.zone:addEntity(game.level, m, "actor", x, y)
		m.max_level = self.level m:forceLevelup(self.level)
		turretCooldown(self, t.id)
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self,t)
		local dam = t.getDamage(self,t)*100
		return ([[Deploy a turret mounted with a steamgun that fires at foes within range for %d%% steamgun damage. The turret gains +%d Dexterity, Constitution and Cunning and %0.2f Steamgun Mastery.]]):
		tformat(dam, stat, self:getTalentLevel(self.T_DEPLOY_TURRET))
	end,
}


newTalent{
	name = "Rocket Launcher", short_name = "TURRET_ROCKET_LAUNCHER",
	type = {"steamtech/other", 1},
	points = 1,
	cooldown = 3,
	range = steamgun_range,
	requires_target = true,
	speed = "archery",
	no_energy = "fake",
	tactical = { ATTACKAREA = { weapon = 2 }, },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	archery_onreach = function(self, t, x, y)
		game.level.map:particleEmitter(x, y, 2, "ball_fire", {radius=2})
	end,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="ball", radius=2, range=self:getTalentRange(t), friendlyfire=false, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = nil
		targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		
		local eff = self:hasEffect(self.EFF_UPGRADE)
		local dam = 1 + (eff.power*0.03)
			
		self.turn_procs.rocket_launcher = true
		self:archeryShoot(targets, t, tg, {mult=dam, damtype=DamageType.FIRE})
		return true
	end,
	info = function(self, t)
		return ([[Fire a missile dealing steamgun damage as fire in radius 2.]]):
		tformat()
	end,
}

newTalent{
	name = "Dual Steamgun", short_name = "TURRET_DUAL_STEAMGUN",
	type = {"steamtech/other", 1},
	points = 1,
	mode = "passive",
	getDamage = function(self,t)
		local dam = 0.1
		local eff = self:hasEffect(self.EFF_UPGRADE)
		if eff then dam = eff.power/200 end
		return dam
	end,
	info = function(self, t)
		return ([[Gain a second steamgun that deals %d%% damage.]]):
		tformat(t.getDamage(self,t)*100)
	end,
}

newTalent{
	name = "Flame Turret",
	type = {"steamtech/turret-types",1},
	range = 3,
	points = 1,
	steam = 35,
	cooldown = 20,
	tactical = { ATTACK = {PHYSICAL = 2} },
	requires_target = true,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_DEPLOY_TURRET)
		return t.getStatBonus(self, t)
	end,
	target = function(self, t) return {type="bolt", nowarning=true, radius=2, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end, -- for the ai
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "sentry",
			display = "*", color=colors.GREEN,
			name = _t"flame turret", faction = self.faction, image = "npc/flame_turret1.png",
			desc = _t[[An automated turret equiped with a flamethrower.]],
			autolevel = "rogue",
			ai = "tactical", ai_state = { talent_in=1, },
			stats = { dex=15, con=15, cun=15 },
			level_range = {1, 1},
			power_source = {steamtech=true},
			exp_worth = 0,
			inc_stats = {
				dex = t.getStatBonus(self,t),
				con = t.getStatBonus(self,t),
				cun = t.getStatBonus(self,t),
			},

			max_life = 20,
			life_rating = 15,
			never_move = 1,

			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),

			combat_armor_hardiness = 100,
			combat_armor = self.level/2 + self:callTalent(self.T_DEPLOY_TURRET, "getFlameArmor"),
			resists = {all = 30},

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			infravision = 20,
			no_breath = 1,
			no_drops = 1,
			combat = { dam=resolvers.levelup(5, 1, 0.7), atk=7, apr=1 },
		
			on_act = function(self)
				local Map = require "engine.Map"
				self:useEnergy()
				local range = self:callTalent(self.T_TURRET_FLAMETHROWER, "radius")
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, range, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, engine.Map.ACTOR)
					if a and self:reactionToward(a) < 0 then
						tgts[#tgts+1] = a
					end
				end end
				local a, id = rng.table(tgts)				
				if not a then return end
				if self:knowTalent(self.T_TURRET_FLAME_VORTEX) and not self:isTalentCoolingDown(self.T_TURRET_FLAME_VORTEX) then
					self:forceUseTalent(self.T_TURRET_FLAME_VORTEX, {ignore_energy=true, ignore_ressources=true})
				end
				local target = game.level.map(a.x, a.y, engine.Map.ACTOR)
				if not target then return end
				self:forceUseTalent(self.T_TURRET_FLAMETHROWER, {ignore_cd=true, ignore_energy=true, force_target=target, ignore_ressources=true})

			end,
			on_die = function(self, killer)
				local src = self.summoner
				
				if src:knowTalent(src.T_SAPPER) and self:hasLOS(src.x, src.y) then
					local t = src:getTalentFromId(src.T_SAPPER)
					local tg = {type="ball", radius=3, range=0, friendlyfire=false, x=self.x, y=self.y}
					src:project(tg, self.x, self.y, engine.DamageType.PHYSICAL, t.getTurretPower(src,t))
					game.level.map:particleEmitter(self.x, self.y, 3, "shrapnel_explosion", {radius=3})					
				end
	
			end,			
			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },

			resolvers.talents{ [Talents.T_STEAM_POOL]=1,
				[Talents.T_TURRET_FLAMETHROWER]={base=1, every=4, max=15},
			},
			silent_levelup = true, no_points_on_levelup = true,
			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
		}

		m:resolve() m:resolve(nil, true)
		m.turret = true
		m.flame_turret = true

		m.combat_precomputed_steampower = self:combatSteampower()
		m.combat_precomputed_physpower = self:combatPhysicalpower()
		m.combat_precomputed_accuracy = self:combatAttack()

		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control="no",
				type="minion",
				title=_t"Turret",
				orders = {target=true},
			})
		end
		game.zone:addEntity(game.level, m, "actor", x, y)
		m.max_level = self.level m:forceLevelup(self.level)
		turretCooldown(self, t.id)
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self,t)
		return ([[Deploy a turret mounted with a flamethrower, scorching nearby targets. The turret gains +%d Dexterity, Constitution and Cunning.]]):
		tformat(stat)
	end,
}

newTalent{
	name = "Flamethrower", short_name = "TURRET_FLAMETHROWER",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 0,
	tactical = { ATTACK = { FIRE = 1 } },
	range = 0,
	radius = function(self, t) if self:hasEffect(self.EFF_UPGRADE) then local eff = self:hasEffect(self.EFF_UPGRADE) return 3 + eff.range/2 else return 3 end end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getBaseDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 100) end,
	getDamage = function(self, t) 
		if self:hasEffect(self.EFF_UPGRADE) then 
			local eff = self:hasEffect(self.EFF_UPGRADE) 
			return t.getBaseDamage(self,t) + t.getBaseDamage(self,t)*eff.power/200 
		else 
			return t.getBaseDamage(self,t)
		end 
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			if self:reactionToward(target) < 0 then
				if self.ai_target then self.ai_target.target = target end
				target:setTarget(self)
			end
		end)
		self:project(tg, x, y, DamageType.FIRE, self:steamCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Throw a cone of flame with radius %d, dealing %0.2f fire damage.
		The damage will increase with your Steampower.]]):
		tformat(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Flame Vortex", short_name = "TURRET_FLAME_VORTEX",
	type = {"steamtech/other",1},
	points = 1,
	cooldown = 3,
	random_ego = "attack",
	tactical = { ATTACK = { FIRE = 3 } },
	range = 0,
	radius = function(self, t) if self:hasEffect(self.EFF_UPGRADE) then local eff = self:hasEffect(self.EFF_UPGRADE) return 3 + eff.range/2 else return 3 end end,
	requires_target = true,
	getDamage = function(self, t) 
		local t = self:getTalentFromId(self.T_TURRET_FLAMETHROWER)
		return t.getDamage(self, t)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:steamCrit(t.getDamage(self, t)))
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if tx and ty and target:canBe("teleport") then
				target:move(tx, ty, true)
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_spike", {radius=tg.radius, allow=core.shader.allow("distort")})
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Project a radius %d vortex of superheated air, dealing %0.2f fire damage and pulling targets towards you.
		The damage will increase with your Steampower.]]):
		tformat(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Medic Turret",
	type = {"steamtech/turret-types",1},
	range = 3,
	points = 1,
	steam = 35,
	cooldown = 20,
	tactical = { ATTACK = {PHYSICAL = 2} },
	requires_target = true,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_DEPLOY_TURRET)
		return t.getStatBonus(self, t)
	end,
	getHeal = function(self, t) 
		local t = self:getTalentFromId(self.T_DEPLOY_TURRET)
		return t.getHeal(self, t)
	end,	
	getNegativeResist = function(self, t) return math.floor(self:combatTalentScale(self:getTalentLevel(self.T_DEPLOY_TURRET), 10, 45)) end,
	target = function(self, t) return {type="bolt", nowarning=true, radius=2, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end, -- for the ai
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "sentry",
			display = "*", color=colors.GREEN,
			name = _t"medic turret", faction = self.faction, image = "npc/healing_turret1.png",
			desc = _t[[An automated turret emitting a healing mist.]],
			autolevel = "rogue",
			ai = "tactical", ai_state = { talent_in=1, },
			stats = { dex=15, con=15, cun=15 },
			level_range = {1, 1},
			power_source = {steamtech=true},
			exp_worth = 0,
			inc_stats = {
				dex = t.getStatBonus(self,t),
				con = t.getStatBonus(self,t),
				cun = t.getStatBonus(self,t),
			},

			max_life = 20,
			life_rating = 15,
			never_move = 1,

			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),
			combat_armor_hardiness = 50,
			combat_armor = self.level/2,
			resists = {all = 0},
			healing = t.getHeal(self, t),
			power = t.getNegativeResist(self, t),

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			infravision = 20,
			no_breath = 1,
			no_drops = 1,
			
			combat = { dam=resolvers.levelup(5, 1, 0.7), atk=7, apr=1 },
			on_die = function(self, killer)
				local src = self.summoner
				
				if src:knowTalent(src.T_SAPPER) and self:hasLOS(src.x, src.y) then
					local t = src:getTalentFromId(src.T_SAPPER)
					local tg = {type="ball", radius=3, range=0, friendlyfire=false, x=self.x, y=self.y}
					src:project(tg, self.x, self.y, engine.DamageType.PHYSICAL, t.getTurretPower(src,t))
					game.level.map:particleEmitter(self.x, self.y, 3, "shrapnel_explosion", {radius=3})					
				end
			end,		
			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },
			on_act = function(self)
				local Map = require "engine.Map"
				local tg = {type="ball", range=0, radius=3}
				self:project(tg, self.x, self.y, function(px, py)
					local target = game.level.map(px, py, engine.Map.ACTOR)
					if not target then return end
		
					if self:reactionToward(target) >= 0 then
						target:setEffect(target.EFF_HEALING_MIST, 1, { power=self.power, heal=self.healing, src=self } )
					end
				end)
			end,
			resolvers.talents{ [Talents.T_STEAM_POOL]=1,
			},
			silent_levelup = true, no_points_on_levelup = true,
			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
		}

		m:resolve() m:resolve(nil, true)
		m.turret = true
		m.medic_turret = true

		m.combat_precomputed_steampower = self:combatSteampower()
		m.combat_precomputed_physpower = self:combatPhysicalpower()
		m.combat_precomputed_accuracy = self:combatAttack()

		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control="no",
				type="minion",
				title=_t"Turret",
				orders = {target=true},
			})
		end
		turretCooldown(self, t.id)
		game.zone:addEntity(game.level, m, "actor", x, y)
		m.max_level = self.level m:forceLevelup(self.level)
		return true
	end,
	info = function(self, t)
		local stat = t.getStatBonus(self,t)
		return ([[Deploy a turret that emits a healing mist in radius 3. The turret gains +%d Dexterity, Constitution and Cunning.]]):
		tformat(stat)
	end,
}

newTalent{
	name = "Overclock",
	type = {"steamtech/turrets", 2},
	points = 5,
	require = steamreq2,
	points = 5,
	steam = 30,
	cooldown = 20,
	tactical = { ATTACKAREA = 2 },
	no_energy = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	getShield = function(self, t) return self:combatTalentSteamDamage(t, 40, 600) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 10, 100) end,
	on_pre_use = function(self, t, silent)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.turret then return true end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.turret then return true end
			end
		end
		return false
	end,
	action = function(self, t)
		local apply = function(a)
			a:setEffect(a.EFF_OVERCLOCK, 10, {power=t.getShield(self, t), dam=t.getDamage(self, t), src=self})
			a.summon_time = a.summon_time + t.getDuration(self,t)
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

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		return ([[Send a surge of power into all turrets in sight, extending their duration by %d turns and granting them a charged shield absorbing %d damage for 10 turns. While the shield holds, each turn the turret will project a bolt of lightning dealing %0.2f lightning damage to a random enemy in radius 6, with a 25%% chance to daze.
		The effects will increase with your Steampower.]]):
		tformat(t.getDuration(self,t), t.getShield(self,t), damDesc(self, DamageType.FIRE, t.getDamage(self,t)))
	end,
}

newTalent{
	name = "Upgrade",
	type = {"steamtech/turrets", 3},
	points = 5,
	require = steamreq3,
	steam = 20,
	cooldown = 15,
	range = 10,
	no_energy = true,
	getPower = function(self, t) return math.floor(self:combatTalentScale(t, 20, 100)) end,
	getRange = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTargetLimited(tg)
		if not tx or not ty or not target or not target.summoner or target.summoner ~= self or not target.turret then return nil end
		target:setEffect(target.EFF_UPGRADE, 1, {power=t.getPower(self,t), range=t.getRange(self,t), src=self})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self,t)
		local range = t.getRange(self,t)
		return ([[Upgrade the target turret, granting it %d%% increased maximum life and enhanced abilities based on type:
		Steamgun: Gains a second steamgun dealing %d%% damage, and every 3 turns will fire a rocket dealing %d%% steamgun damage as fire in radius 2.
		Flame: Increases damage by %d%%, range by %d, and every 3 turns will project a vortex of superheated air that drags targets within range %d towards the turret as well as dealing normal flamethrower damage.
		Medic: Increases healing on affected targets by %d%%, and has a %d%% chance to cleanse a negative effect each turn.]]):
		tformat(power, power/2, 100 + (power*3), power/2, range/2, range, power/2, power/3)
	end,
}

newTalent{
	name = "Hunker Down",
	type = {"steamtech/turrets", 4},
	points = 5,
	require = steamreq4,
	steam = 50,
	cooldown = 30,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	getPower = function(self, t) return math.floor(self:combatTalentScale(t, 15, 50)) end,
	getStatBonus = function(self, t) 
		local t = self:getTalentFromId(self.T_DEPLOY_TURRET)
		return t.getStatBonus(self, t)
	end,
	action = function(self, t)
		for i = 1, 2 do

			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "construct", subtype = "sentry",
				display = "*", color=colors.GREEN,
				name = _t"guardian turret", faction = self.faction, image = "npc/guardian_turret1.png",
				desc = _t[[An advanced turret equipped with dual steamguns.]],
				autolevel = "rogue",
				ai = "tactical", ai_state = { talent_in=1, },
				stats = { dex=15, con=15, cun=15 },
				level_range = {1, 1},
				power_source = {steamtech=true},
				exp_worth = 0,
				inc_stats = {
					dex = t.getStatBonus(self,t),
					con = t.getStatBonus(self,t),
					cun = t.getStatBonus(self,t),
				},
	
				max_life = 20,
				life_rating = 10,
				never_move = 1,
	
				inc_damage = table.clone(self.inc_damage),
				resists_pen = table.clone(self.resists_pen),
	
				combat_armor_hardiness = 50,
				combat_armor = self.level/2,
				resists = {all = 0},
	
				negative_status_effect_immune = 1,
				cant_be_moved = 1,
				infravision = 20,
				no_breath = 1,
				no_drops = 1,
				power = t.getPower(self,t),
				
				combat = { dam=resolvers.levelup(5, 1, 0.7), atk=7, apr=1 },
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, CLOAK=1, QUIVER=1 },
				resolvers.equip{
					{type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", not_properties={unique=true}, autoreq=true, ego_chance=-1000},
					{type="weapon", subtype="steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", not_properties={unique=true}, autoreq=true, ego_chance=-1000},
					{type="ammo", subtype="shot", autoreq=true, not_properties={unique=true}, ego_chance=-1000},
				},
				resolvers.talents{ [Talents.T_STEAM_POOL]=1, [Talents.T_SHOOT]=1, [Talents.T_RELOAD]=1,
					[Talents.T_STEAMGUN_MASTERY]=self:getTalentLevel(self.T_HUNKER_DOWN),
					[Talents.T_TURRET_GAUSS_CANNON]=1,
				},
				silent_levelup = true, no_points_on_levelup = true,
				summoner = self, summoner_gain_exp=true,
				summon_time = t.getDuration(self,t),
				on_act = function(self)
					local Map = require "engine.Map"
					local tg = {type="ball", range=0, radius=1}
					self:project(tg, self.x, self.y, function(px, py)
						local target = game.level.map(px, py, engine.Map.ACTOR)
						if not target then return end
			
						if self:reactionToward(target) >= 0  then
							target:setEffect(target.EFF_GUARDIAN_SHIELD, 2, { power=self.power, src=self } )
						end
					end)
					self:useEnergy()
					local weapon, ammo, offweapon = self:hasArcheryWeapon()
					if not weapon then return end
					local range = weapon.combat.range
					local tgts = {}
					local grids = core.fov.circle_grids(self.x, self.y, range, true)
					for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
						local a = game.level.map(x, y, engine.Map.ACTOR)
						if a and self:reactionToward(a) < 0 then
							tgts[#tgts+1] = a
						end
					end end
					local a, id = rng.table(tgts)				
					if not a then return end
					local target = game.level.map(a.x, a.y, engine.Map.ACTOR)
					if not target then return end
					self:forceUseTalent(self.T_TURRET_GAUSS_CANNON, {ignore_energy=true, force_target=target, ignore_ressources=true})

					ammo.combat.shots_left = ammo.combat.capacity
				end,
			}
	
			m:resolve() m:resolve(nil, true)
			m.turret = true
			m.guardian_turret = true
			m:attr("archery_pass_friendly", 1)

			m.combat_precomputed_steampower = self:combatSteampower()
			m.combat_precomputed_physpower = self:combatPhysicalpower()
			m.combat_precomputed_accuracy = self:combatAttack()

			game.zone:addEntity(game.level, m, "actor", x, y)
			m.max_level = self.level m:forceLevelup(self.level)
		end

		return true
	end,
	info = function(self, t)
		local dam = t.getPower(self,t)
		local dur = t.getDuration(self,t)
		return ([[Deploy a defensive emplacement around you, summoning 2 guardian turrets in adjacent tiles for %d turns. Guardian turrets redirect %d%% of all damage taken by other adjacent allies (other than fellow guardian turrets) to themselves, and each is armed with a powerful turret capable of firing piercing bullets.
			Guardian Turrets gain %0.2f ranks in Steamgun Mastery based on your Hunker Down talent level.]]):
		tformat(dur, dam, self:getTalentLevel(self.T_HUNKER_DOWN))
	end,
}

newTalent{
	name = "Gauss Cannon", short_name = "TURRET_GAUSS_CANNON",
	type = {"steamtech/other",1},
	no_energy = "fake",
	points = 5,
	range = steamgun_range,
	speed = "archery",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	no_energy = "fake",
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="beam", speed = 200, range=self:getTalentRange(t), friendlyfire=false, display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = nil
		local x, y = self:getTarget(tg)
		
		local targets = self:archeryAcquireTargets(tg, {one_shot=true, type="steamgun"})
		if not targets then return end
		self:archeryShoot(targets, t, tg, {mult=1, apr=1000, damtype=DamageType.LIGHTNING, type="steamgun"})
		return true
	end,
	info = function(self, t)
		return ([[Fire your twin-linked gauss cannons, dealing 100%% steamgun damage as lightning in a piercing beam that bypasses all armor. This does not harm friendly targets.]]):tformat()
	end,
}