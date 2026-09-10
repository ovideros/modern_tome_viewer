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
	name = "Entropic Gift",
	type = {"demented/entropy", 1},
	require = dementedreq1,
	points = 5,
	cooldown = 15,
	insanity = 10,
	range = 10,
	tactical = {ATTACK = function(self, t, aitarget)
		local eff = self:hasEffect(self.EFF_ENTROPIC_WASTING)
		if not eff then return end
		return {DARKNESS = eff.power / 150 * 8, TEMPORAL = eff.power / 150 * 8}
	end},
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_ENTROPIC_WASTING) end,
	requires_target = true,
	getInsanity = function(self, t) return 0 end,
	getPower = function(self, t) return 40 + self:combatTalentScale(t, 70, 120) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	no_unlearn_last = true,
	requires_target = true,
	direct_hit = true,
	callbackPriorities={callbackOnHeal = 1}, -- trigger after (most) other healing callbacks
	callbackOnHeal = function(self, t, value, src, raw_value)
		if raw_value > 0 and not t.projecting and not self.resting and not self.reverse_entropy and self.in_combat then -- avoid feedback; it's bad to lose out on dmg but it's worse to break the game
			t.projecting = true
			local dam = math.floor(value/32)
			local shield = 0 
			local psrc = self
			psrc.__project_source = t
			self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power=dam})
			psrc.__project_source = nil
			t.projecting = false
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		local eff = self:hasEffect(self.EFF_ENTROPIC_WASTING)
		local edam = 0
		if eff then edam = eff.power * eff.dur end
		
		local damage = self:spellCrit( (edam * t.getPower(self,t)/100) )
		local res = 0
		local p = self:isTalentActive(self.T_POWER_OVERWHELMING)
		if p then
			res = p.dambonus	
		end
		self:project(tg, x, y, function(px, py)
			target:setEffect(target.EFF_ENTROPIC_GIFT, 4, {src=self, power=damage/4})
			self:removeEffect(self.EFF_ENTROPIC_WASTING)

			if self:knowTalent(self.T_BLACK_HOLE) then
				local dam = self:callTalent(self.T_BLACK_HOLE, "getDamage")
				local dur = self:callTalent(self.T_BLACK_HOLE, "getDuration")
				local mult = self:callTalent(self.T_BLACK_HOLE, "getEntropyBonus")
				local rad = 1
				local max_radius = self:callTalent(self.T_BLACK_HOLE, "getMaxRadius")
				dam = self:spellCrit(dam + (edam * mult))
					local oe = game.level.map(px, py, Map.TERRAIN+1)
					if (oe and oe.is_maelstrom) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end
					
					local e = Object.new{
						old_feat = oe,
						type = "void", subtype = "black hole",
						name = ("%s's black hole"):tformat(self:getName():capitalize()),
						display = ' ',
						tooltip = mod.class.Grid.tooltip,
						always_remember = true,
						temporary = dur,
						is_maelstrom = true,
						x = px, y = py,
						canAct = false,
						dam = dam,
						radius = rad,
						max_radius = max_radius,
						rebuild_particles = function(self)
							if self.particles then game.level.map:removeParticleEmitter(self.particles) end
							if self.particles2 then game.level.map:removeParticleEmitter(self.particles2) end

							local particle = engine.Particles.new("generic_vortex", self.radius, {radius=self.radius, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
							local particle2 = engine.Particles.new("image", self.radius, {size=64*self.radius, image="particles_images/black_hole"}) particle2.zdepth = 4
							if core.shader.allow("distort") then particle:setSub("vortex_distort", self.radius, {radius=self.radius}) end
							self.particles2 = game.level.map:addParticleEmitter(particle2, self.x, self.y)
							self.particles = game.level.map:addParticleEmitter(particle, self.x, self.y)
							game:shakeScreen(10, 3)
						end,
						act = function(self)
							local tgts = {}
							local Map = require "engine.Map"
							local DamageType = require "engine.DamageType"
							if self.radius < self.max_radius then
								self.radius = math.min(self.max_radius, (self.radius + 1))
								self:rebuild_particles()
							end
							local grids = core.fov.circle_grids(self.x, self.y, self.radius, true)
							for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
								local Map = require "engine.Map"
								local target = game.level.map(x, y, Map.ACTOR)
								local friendlyfire = false
								if target and not (friendlyfire == false and self.summoner:reactionToward(target) >= 0) then 
									tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, x, y)}
								end
							end end
							table.sort(tgts, "sqdist")
							for i, target in ipairs(tgts) do
								local old_source = self.summoner.__project_source
								self.summoner.__project_source = self
								if target.actor:canBe("knockback") then
									target.actor:pull(self.x, self.y, 1)
									target.actor.logCombat(self, target.actor, "#Source# pulls #Target# in!")
								end
								DamageType:get(DamageType.VOID).projector(self.summoner, target.actor.x, target.actor.y, DamageType.VOID, self.dam)
								self.summoner.__project_source = old_source
							end
			
							self:useEnergy()
							self.temporary = self.temporary - 1
							if self.temporary <= 0 then
								game.level.map:removeParticleEmitter(self.particles)	
								game.level.map:removeParticleEmitter(self.particles2)
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
					e:rebuild_particles()
			
					game.level:addEntity(e)
					game.level.map(x, y, Map.TERRAIN+1, e)
					game.level.map:updateMap(x, y)
			end

		end)

		game:playSoundNear(self, "talents/tidalwave")

		return true
	end,
	info = function(self, t)
		local power = t.getPower(self,t)
		return ([[Your unnatural existence causes the fabric of reality to reject your presence. 25%% of all direct healing received damages you in the form of entropic backlash over 8 turns, which is irresistible and bypasses all shields, but cannot kill you.

You may activate this talent to channel your entropy onto a nearby enemy, removing all entropic backlash to inflict darkness and temporal damage equal to %d%% of your entropy over 4 turns.

The damage dealt when applying this to an enemy will increase with your Spellpower.]]):
		tformat(power)
	end,
}

newTalent{
	name = "Reverse Entropy",
	type = {"demented/entropy", 2},
	require = dementedreq2,
	points = 5,
	no_npc_use = true,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_ENTROPIC_WASTING) end,
	getReduction = function(self, t) return math.min(self:combatTalentSpellDamage(t, 20, 70), 80) end,
	cooldown = function(self, t) return self:combatTalentLimit(t, 10, 40, 20) end,
	no_energy = true,
	action = function(self, t)
		self:removeEffect(self.EFF_ENTROPIC_WASTING)
		game:playSoundNear(self, "talents/spell_generic2")

		-- Someone put pretty effects here I suck at them
		return true
	end,
	info = function(self, t)

		return ([[Your knowledge of entropy allows you to defy the laws of physics, allowing you to better endure your entropic energies.
			You take %d%% less damage from your entropic backlash.
		You may activate this talent to instantly remove your current Entropy.]]):
		tformat(t.getReduction(self, t))
	end,
}

newTalent{
	name = "Black Hole",
	type = {"demented/entropy", 3},
	require = dementedreq3,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 35) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 3.6)) end,
	getEntropyBonus = function(self, t) return self:combatTalentScale(t, 5, 15)/100 end,
	getMaxRadius = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 1, 3)) end,
	info = function(self, t)
		local rad = t.getMaxRadius(self,t)
		local dam = t.getDamage(self,t)/2
		local dur = t.getDuration(self,t)
		local bonus = t.getEntropyBonus(self,t)*100
		local entropy = 0
		if self:hasEffect(self.EFF_ENTROPIC_WASTING) then
			local eff = self:hasEffect(self.EFF_ENTROPIC_WASTING)
			local edam = 0
			if eff then edam = (eff.power * eff.dur) * t.getEntropyBonus(self,t) end
			entropy = edam
		end
		return ([[On casting Entropic Gift, a radius 1 rift in spacetime will be opened underneath the target for %d turns, increasing in radius by 1 each turn to a maximum of %d.
		All caught within the rift are pulled towards the center and take %0.2f darkness and %0.2f temporal damage, plus %d%% of your total entropy each turn (currently %d).]]):
		tformat(dur, rad, damDesc(self, DamageType.DARKNESS, dam), damDesc(self, DamageType.TEMPORAL, dam), bonus, entropy)
	end,
}

newTalent{
	name = "Power Overwhelming",
	require = dementedreq4,
	type = {"demented/entropy", 4},
	points = 5,
	mode = "sustained",
	cooldown = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getDamageIncrease = function(self, t) return self:combatTalentScale(t, 4, 16) end,
	getResistPenalty = function(self, t) return self:combatTalentScale(t, 6, 24) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 30) end,
	callbackOnTalentPost = function(self, t,  ab)
		if ab.is_spell and not ab.no_energy and ab.mode == "activated" and self.in_combat then
			local backlash = t.getDamage(self,t)
			self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power=backlash/8})
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/power_overwhelming")
		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="power_overwhelming"}, {type="lightningshield"}))
		else
			particle = self:addParticles(Particles.new("power_overwhelming", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.DARKNESS] = t.getDamageIncrease(self, t), [DamageType.TEMPORAL] = t.getDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.DARKNESS] = t.getResistPenalty(self, t), [DamageType.TEMPORAL] = t.getResistPenalty(self, t)}),
			dambonus = t.getDamageIncrease(self,t),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		p.dambonus = nil
		return true
	end,
	info = function(self, t)
		local power = t.getDamageIncrease(self,t)
		local pen = t.getResistPenalty(self,t)
		local dam = t.getDamage(self,t)
		return ([[You empower your spells with dangerous levels of entropic energy, increasing your darkness and temporal damage by %d%% and resistance penetration by %d%% at the cost of suffering %0.2f entropic backlash for each non-instant spell.]]):
		tformat(power, pen, dam)
	end,
}