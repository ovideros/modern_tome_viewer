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

local Object = require "mod.class.Object"

newTalent{
	name = "Nihil",
	type = {"demented/oblivion", 1},
	require = dementedreq_high1,
	points = 5,
	mode = "passive",
	direct_hit = true,
	getPower = function(self, t) return self:combatTalentLimit(t, 50, 10, 40)/100 end,
	getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	do_nihil = function(self, t)

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			local numb = 0
			if self:knowTalent(self.T_ERASE) then
				numb = self:callTalent(self.T_ERASE, "getNumb")
			end
			a:setEffect(a.EFF_NIHIL, 8, {src=self, power=t.getPower(self,t), numb=numb})
		end
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local power = t.getPower(self, t)*100
		return ([[Your entropy bleeds into the world around you. On having entropic backlash applied or increased to you, %d random enemies you can see within radius 10 will be shrouded in entropic forces for 8 turns. This increases the duration of new negative effects and reduces the duration of new beneficial effects applied to the target by %d%%.]]):
		tformat(targetcount, power)
	end,
}

newTalent{
	name = "Unravel Existence",
	type = {"demented/oblivion", 2},
	require = dementedreq_high2,
	points = 5,
	range = 10,
	mode = "passive",
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 25, 15)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 8)) end,
	unravel = function (self, target, t, dur)

		local x, y = util.findFreeGrid(target.x, target.y, 3, true, {[Map.ACTOR]=true})
		if not x then return nil end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "horror", subtype = "eldritch",
			display = "h", blood_color = colors.BLUE,
			faction = "horrors",
			inc_stats = { str=self:getMag(), dex=self:getMag(), mag=self:getMag(), con=self:getMag(), wil=self:getMag(), cun=self:getMag() },
			infravision = 10,
			no_breath = 1,
			fear_immune = 1,
			stun_immune = 0.5,
			blind_immune = 0.5,
			confusion_immune = 1,
			silence_immune = 1,
			disarm_immune = 1,
			knockback_immune = 1,

			name = _t"herald of oblivion", color=colors.GREY,
			desc = _t"Space warps and blurs around this titanic being, as if reality itself was struggling against it.",
			resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/void_annihilator.png", display_h=2, display_y=-1}}},
			level_range = {1, self.level}, exp_worth = 0,
			rank = 3,
			size_category = 4,
			autolevel = "warriormage",
			max_life = 100,
			life_rating = 13,
			life_regen = 4,
			allow_any_dual_weapons = 1,
			difficulty_boosted = 1,  -- Avoid difficulty boosting, adding to party probably also works but I'm positive this always does

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
			
			resolvers.equip{
				{type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true},
				{type="weapon", subtype="longsword", forbid_power_source={antimagic=true}, autoreq=true},				
				{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
			},
			
			combat_armor = 10 + self.level / 2, combat_def = self.level * 1.5,
			resists = {all = 30, [DamageType.DARKNESS] = 100, [DamageType.TEMPORAL] = 100},

			resolvers.talents{
				[Talents.T_ARMOUR_TRAINING]={base=1, every=8, max=8},
				[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=8},
				[Talents.T_WEAPONS_MASTERY]={base=1, every=15, max=8},
				[Talents.T_DUAL_WEAPON_MASTERY]={base=3, every=10, max=8},
				[Talents.T_WEAPON_FOLDING]={base=1, every=25, max=8},
				[Talents.T_RUSH]={base=1, every=6, max=8},
				[Talents.T_VOID_CRASH]={base=1, every=6, max=8},  -- 6 CD
				[Talents.T_BLINK_BLADE]={base=1, every=6, max=8},  -- 8 CD
				
			},
			resolvers.sustains_at_birth(),

			inc_damage = table.clone(self.inc_damage, true),
			resists_pen = table.clone(self.resists_pen, true),
			combat_critical_power = self.combat_critical_power,
			combat_spellcrit = self.combat_spellcrit,
			combat_physcrit = self.combat_physcrit,
			combat_mindcrit = self.combat_mindcrit,

			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self,t),
		}
		m:resolve()
		m:resolve(nil, true)
		m.ai_tactic = {attack=2, attackarea=2, disable=2, escape=0, closein=3, go_melee=1}
		if self.on_unravel_existence_npc then m = self:on_unravel_existence_npc(target, t, dur) end
		game.zone:addEntity(game.level, m, "actor", x, y)
		m:forceLevelup(self.level)
		if target then m:setTarget(target) end

		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end
		self:startTalentCooldown(t)		
	end,
	info = function(self, t)
		local dur = t.getDuration(self,t)
		return ([[Your Nihil unravels the existence of the target, tearing them apart with entropy.
		If 6 negative magical effects are applied before Nihil expires a Herald of Oblivion will be summoned to assist you for %d turns.
		Currently existing debuffs, Spellshocked, and Seen by Arcane Eye will not count towards this total.  Refreshing the same debuff is counted.
		The Herald will have a bonus to all attributes equal to your Magic.  Many other stats will scale with level.
		Your increased damage, damage penetration, critical strike chance, and critical strike multiplier stats will all be inherited.]]):
		tformat(dur)
	end,
}

newTalent{
	name = "Erase",
	type = {"demented/oblivion", 3},
	require = dementedreq_high3,
	mode = "passive",
	points = 5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 20) end,
	getNumb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local power = t.getNumb(self, t)
		return ([[Those affected by your Nihil find themselves increasingly removed from reality, reducing all damage they deal by %d%% and causing them to take %0.2f temporal damage each turn for each negative magical effect they have.
		The damage will scale with your Spellpower.]])
		:tformat(power, damDesc(self, DamageType.TEMPORAL, dam))
	end
}

-- Remove on level exit
newTalent{
	name = "All is Dust",
	type = {"demented/oblivion", 4},
	require = dementedreq_high4,
	points = 5, 
	cooldown = 20,
	insanity = -10,
	tactical = { ATTACKAREA = { TEMPORAL = 3, DARKNESS = 3}, DISABLE = 2 },
	range = 7,
	radius = 4,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 20) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 12, 3, 10)) end, -- Awful curve, fix me later
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), nolock=true, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local oe = game.level.map(x, y, Map.TERRAIN+1)
		if (oe and oe.is_maelstrom) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end
		
		local e = Object.new{
			old_feat = oe,
			type = "void", subtype = "entropic storm",
			name = ("%s's entropic storm"):tformat(self:getName():capitalize()),
			display = ' ',
			tooltip = mod.class.Grid.tooltip,
			always_remember = true,
			temporary = t.getDuration(self, t),
			is_maelstrom = true,
			x = x, y = y,
			canAct = false,
			dam = self:spellCrit(t.getDamage(self, t)),
			radius = self:getTalentRadius(t),
			act = function(self)
				local tgts = {}
				local Map = require "engine.Map"
				local DamageType = require "engine.DamageType"
				local grids = core.fov.circle_grids(self.x, self.y, self.radius, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local Map = require "engine.Map"
					local target = game.level.map(x, y, Map.ACTOR)
					local proj = game.level.map(x, y, Map.PROJECTILE)
					if proj and proj.src and not (self.summoner:reactionToward(proj.src) >= 0) then
						proj:terminate(x, y)
						game.level:removeEntity(proj, true)
						proj.dead = true
						self.summoner:logCombat(proj, ("#ORCHID#The entropic storm destroys %s!#LAST#"):tformat(proj:getName() or _t"a projectile"))
					end
					if target and not (self.summoner:reactionToward(target) >= 0) then 
						tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, x, y)}
					end
					local feat = game.level.map(x, y, Map.TERRAIN)
					if feat then
						if feat.dig then
							local newfeat_name, newfeat, silence = feat.dig, nil, false
							if type(feat.dig) == "function" then newfeat_name, newfeat, silence = feat.dig(self, x, y, feat) end
							newfeat = newfeat or game.zone.grid_list[newfeat_name]
							if newfeat then
								game.level.map(x, y, Map.TERRAIN, newfeat)
								self.dug_times = (self.dug_times or 0) + 1
								game.nicer_tiles:updateAround(game.level, x, y)
								if not silence then
									--game.logSeen({x=x,y=y}, "%s turns into %s.", feat.name:capitalize(), newfeat.name)
								end
							end
						end
					end		
				end end
				table.sort(tgts, "sqdist")
				for i, target in ipairs(tgts) do
					self.summoner.__project_source = self
					DamageType:get(DamageType.OBLIVION).projector(self.summoner, target.actor.x, target.actor.y, DamageType.OBLIVION, self.dam)
					self.summoner.__project_source = nil
				end
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:removeParticleEmitter(self.particles)	
					if self.old_feat then game.level.map(self.x, self.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+1) end
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}

		local particle = engine.Particles.new("circle", e.radius, {oversize=0.7, a=75, appear=8, speed=8, img="all_is_dust", radius=e.radius})
		if core.shader.allow("distort") then particle:setSub("vortex_distort", e.radius, {radius=e.radius}) end
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		e.energy.value = 1000 -- First tick happens immediately so you can use it reactively against projectiles
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/all_is_dust")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[Summon a radius 4 storm of all-consuming oblivion at the targeted location for %d turns, reducing those within to nothing. Targets within will take %0.2f darkness damage and %0.2f temporal damage each turn.  Walls and other terrain within the storm will be disintegrated.
		Each time the storm deals damage enemies will have any detrimental magical effect with less than 3 duration set to 3 duration, and all enemy projectiles will be destroyed.
		The damage will scale with your Spellpower.]]):tformat(duration, damDesc(self, DamageType.DARKNESS, damage), damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Void Crash",
	type = {"other/horror", 1},
	random_ego = "attack",
	points = 5,
	cooldown = 6,  -- Higher talent ranks can fit in 2
	tactical = { ATTACKAREA = {DARKNESS = 3, TEMPORAL = 3}},
	range = 0,
	radius = 2,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 2.0) end,
	is_melee = true,
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hitted = self:attackTarget(target, DamageType.VOID, t.getDamage(self, t), true)
			end
		end)
		if core.shader.active() then
			game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "starfall", {radius=self:getTalentRadius(t), tx=self.x, ty=self.y})
		else
			game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shadow_flash", {radius=self:getTalentRadius(t), grids=grids, tx=self.x, ty=self.y})
			game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "circle", {oversize=0.7, a=60, limit_life=16, appear=8, speed=-0.5, img="darkness_celestial_circle", radius=self:getTalentRadius(t)})
		end

		return true
	end,
	info = function(self, t)
		return ([[Slam your weapons into the ground, creating a radius 2 explosion of void energy dealing %d%% damage split between darkness and temporal.]]):
		tformat(t.getDamage(self, t) * 100)
	end,
}