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
local Trap = require "mod.class.Trap"

newTalent{
	name = "Reality Fracture",
	type = {"demented/rift", 1},
	require = dementedreq_high1,
	points = 5,
	insanity = -10,
	cooldown = 14,
	tactical = { ATTACKAREA = {TEMPORAL = 2, DARKNESS = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 40) end,
	getSpawnRadius = function(self, t) return 4 end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 2, 6)) end,
	getNb = function(self, t) return 3 end,  -- Its actually 3.3 with the proc
	getMult = function(self, t)	if self:knowTalent(self.T_ZERO_POINT_ENERGY) then return self:callTalent(self.T_ZERO_POINT_ENERGY, "getPower") else return 0 end end,
	target = function(self, t)
		return {type="ball", radius=100, range=0, talent=t}
	end,
	create_rift = function(self, t)
		if not self.in_combat then return end

		local rift = rng.range(1,3)

		local x, y = self.x, self.y
		local range = t.getSpawnRadius(self, t)
		local poss = {}
		for i = x - range, x + range do
			for j = y - range, y + range do
				if game.level.map:isBound(i, j) and
					core.fov.distance(x, y, i, j) <= range and
					--core.fov.distance(x, y, i, j) >= range/2 and
					self:canMove(i, j) and 
					self:hasLOS(i, j) and not game.level.map(i, j, engine.Map.TRAP) then
					poss[#poss+1] = {i,j}
				end
			end
		end
		if #poss == 0 then return x, y  end
		local pos = poss[rng.range(1, #poss)]
		x, y = pos[1], pos[2]
		
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "rift_alert", {tx=x-self.x, ty=y-self.y}, {time_factor=0.1, type="lightning"})
		if self:knowTalent(self.T_PIERCE_THE_VEIL) and rng.percent(self:callTalent(self.T_PIERCE_THE_VEIL, "getChance")) and rift then
			local t2 = self:getTalentFromId(self.T_PIERCE_THE_VEIL)
			if rift == 1 then
				t2.nether_breach(self, t2, x, y)
			elseif rift == 2 then 
				t2.temporal_vortex(self, t2, x, y)
			elseif rift == 3 then 
				t2.dimensional_gateway(self, t2, x, y)
			end
		else
			local e = Trap.new{
				triggered = function(self, x, y, who) return true, true end,
				disarmable = false,
				energy = {value=0},
				canTrigger = function() return false end,
				type = "rift", name = _t"void rift",
				name = _t"void rift", image = "terrain/entropic/void_rift.png",
				add_mos = {image = "terrain/entropic/void_rift.png"},
				display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
				always_remember = true,
				temporary = t.getDuration(self, t),
				x = x, y = y,
				canAct = false,
				void_rift = true,
				all_know = true,
				dam = self:spellCrit(t.getDamage(self, t)),
				mult = t.getMult(self,t)/100,
				empower = false,
				act = function(self)
					local tgts = {}
					local grids = core.fov.circle_grids(self.x, self.y, 10, true)
					for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
						local a = game.level.map(x, y, engine.Map.ACTOR)
						if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
					end end
	        
					-- Randomly take targets
					if self.empower then
						local tg = {type="ball", speed=5, range=10, radius=1, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_REALITY_FRACTURE), friendlyblock=false, friendlyfire=false, display={particle="bolt_void"}}
						if #tgts >= 0 then
							local a, id = rng.table(tgts)
							table.remove(tgts, id)
							if a then
								self.summoner:projectile(tg, a.x, a.y, engine.DamageType.VOID, self.dam + (self.dam * self.mult), {type="voidblast"})
								game:playSoundNear(self, "talents/fire")
							end 
						end
					else
						local tg = {type="bolt", speed=5, range=10, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_REALITY_FRACTURE), friendlyblock=false, friendlyfire=false, display={particle="bolt_void"}}
						if #tgts >= 0 then
							local a, id = rng.table(tgts)
							table.remove(tgts, id)
							if a then
								self.summoner:projectile(tg, a.x, a.y, engine.DamageType.VOID, self.dam, {type="voidblast"})
								game:playSoundNear(self, "talents/fire")
							end 
						end
					end
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary < 0 then
						if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
						game.level:removeEntity(self)
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}

			e:identify(true)
			e:resolve() e:resolve(nil, true)
			e:setKnown(self, true)

			game.level:addEntity(e)
			game.level.map(x, y, Map.TRAP, e)
		end
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	callbackOnTalentPost = function(self, t, ab)
		if not rng.percent(30) then return end
		if not ab.type[1]:find("^demented/") then return end
		if ab.mode == "sustained" then return end
		t.create_rift(self, t)
	end,
	callbackOnChangeLevel = function(self, t, what, zone, level)
		if what == "leave" then
			for uid, e in pairs(game.level.entities) do
				if e.void_rift and e.x then
					game.level.map:removeParticleEmitter(game.level.map(e.x, e.y, engine.Map.TRAP).particles)
					game.level.map:remove(e.x, e.y, engine.Map.TRAP)
					game.level:removeEntity(e)
				end
			end
		end
		self.cultist_rifts = nil
	end,
	action = function(self, t)
		if self:knowTalent(self.T_ZERO_POINT_ENERGY) then
			local tg = self:getTalentTarget(t)
			self:project(tg, self.x, self.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.TRAP)
				if target and target.void_rift and target.summoner == self then
					-- Add effect here
					target.name = ("%s (empowered)"):tformat(target.name)
					target.empower = true
					if target.on_empower then target:on_empower() end
				end	
			end)
		end

		t.create_rift(self, t)
		t.create_rift(self, t)
		t.create_rift(self, t)

		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self,t)
		local damage = t.getDamage(self,t)/2
		local nb = t.getNb(self,t)
		return ([[The sheer power of your entropy tears holes through spacetime, opening this world to the void.
On casting a Demented spell you have a 30%% chance of creating a void rift lasting %d turns in a nearby tile, which will launch void blasts each turn at a random enemy in range 7, dealing %0.2f darkness and %0.2f temporal damage.

You may activate this talent to forcibly destabilize spacetime, spawning %d void rifts around you.]]):
		tformat(dur, damDesc(self, DamageType.DARKNESS, damage), damDesc(self, DamageType.TEMPORAL, damage), nb)
	end,
}

newTalent{
	name = "Quantum Tunnelling",
	type = {"demented/rift", 2},
	require = dementedreq_high2,
	points = 5,
	insanity = 5,
	cooldown = 10,
	tactical = { ESCAPE = 2, DEFEND = 2 },
	range = function(self, t) return 10 end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 40, 400) end,
	getDuration = function(self, t) return 4 end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), scan_on=engine.Map.TRAP, no_first_target_filter=true, talent=t} end,
	direct_hit = true,
	is_teleport = true,
	onAIGetTarget = function(self, t)
		local tgts = {}
		self:project({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, function(px, py)
			local g = game.level.map(px, py, Map.TRAP)
			if g and g.void_rift then tgts[#tgts+1] = {x=px, y=py} end
		end)
		if #tgts > 0 then local t = rng.table(tgts) return t.x, t.y end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)

		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then -- To prevent teleporting through walls
			game.logPlayer(self, "You do not have line of sight.")
			return nil
		end
		
		local target = game.level.map(x, y, engine.Map.TRAP)
		if not (target and target.void_rift) then
			game.logPlayer(self, "You must target a void rift.")
			return nil
		end
				
		local _ _, x, y = self:canProject(tg, x, y)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "%s's space-time folding fizzles!", self:getName():capitalize())
		else
			game.logSeen(self, "%s emerges from a space-time rift!", self:getName():capitalize())
			local absorb = self:spellCrit(t.getPower(self,t))

			self:setEffect(self.EFF_DAMAGE_SHIELD, t.getDuration(self, t), {color={0xe1/255, 0xcb/255, 0x3f/255}, image="quantum_tunelling_shield", power=absorb})
			local trap = game.level.map(target.x, target.y, engine.Map.TRAP)
			if trap and trap.particles then game.level.map:removeParticleEmitter(trap.particles) end
			game.level.map:remove(target.x, target.y, engine.Map.TRAP)
			game.level:removeEntity(target, true)
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
		end
		
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = self:getShieldDuration(t.getDuration(self, t))
		local power = self:getShieldAmount(t.getPower(self, t))
		return ([[You briefly open a tunnel through spacetime, teleporting to a void rift in range %d. This destroys the rift, granting you a shield for %d turns absorbing %d damage.
		The damage absorbed will scale with your Spellpower]]):
		tformat(range, duration, power)
	end
}

newTalent{
	name = "Pierce the Veil",
	type = {"demented/rift", 3},
	require = dementedreq_high3,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 15, 40) end,
	getNetherDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 60) end,
	getTemporalDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 50) end,
	getDimensionalDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	getDimensionalStats = function(self, t) return self:getMag() end,
	getDuration = function(self, t) return self:callTalent(self.T_REALITY_FRACTURE, "getDuration") end,
	getPower = function(self, t) return self:callTalent(self.T_ZERO_POINT_ENERGY, "getPower") end,
	nether_breach = function(self, t, x, y)
		local dur = t.getDuration(self,t)
		local dam = self:spellCrit(t.getNetherDamage(self, t))
		local mult = t.getPower(self,t)/100

		local e = Trap.new{
			triggered = function(self, x, y, who) return true, true end,
			disarmable = false,
			energy = {value=0},
			canTrigger = function() return false end,
			type = "rift", subtype = "nether breach",
			name = _t"nether breach", image = "terrain/entropic/nether_breach.png",
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = dur,
			x = x, y = y,
			canAct = false,
			void_rift = true,
			all_know = true,
			nether_breach = true,
			dam = dam,
			mult = mult,
			empower = false,
			act = function(self)
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, 10, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, engine.Map.ACTOR)
					if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
				end end

				-- Randomly take targets
				if self.empower then
					local tg = {type="bolt", range=10, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_PIERCE_THE_VEIL), friendlyblock=false, friendlyfire=false}
					if #tgts >= 0 then
						local a, id = rng.table(tgts)
						table.remove(tgts, id)
						if a then
							local affected = {}
							local first = nil
					
							self.summoner:project(tg, a.x, a.y, function(dx, dy)
								local actor = game.level.map(dx, dy, engine.Map.ACTOR)
								if actor and not affected[actor] then
									affected[actor] = true
									first = actor
									self.summoner:projectSource({type="ball", selffire=false, friendlyfire=false, x=dx, y=dy, radius=7, range=0, talent=self.summoner:getTalentFromId(self.summoner.T_PIERCE_THE_VEIL) }, dx, dy, function(bx, by)
										local actor = game.level.map(bx, by, engine.Map.ACTOR)
										if actor and not affected[actor] and self.summoner:reactionToward(actor) < 0 then
											affected[actor] = true
										end
									end, nil, nil, self)
									return true
								end
							end)
					
							if not first then return end
							local targets = { first }
							affected[first] = nil
							local possible_targets = table.listify(affected)
							for i = 1, 3 do
								if #possible_targets == 0 then break end
								local act = rng.tableRemove(possible_targets)
								targets[#targets+1] = act[1]
							end
					
							local sx, sy = self.x, self.y
							for i, actor in ipairs(targets) do
								local tgr = {type="beam", range=7, friendlyfire=false, talent=self.summoner:getTalentFromId(self.summoner.T_PIERCE_THE_VEIL), x=sx, y=sy}
								local dam = self.dam + (self.dam * self.mult)
								local DamageType = require "engine.DamageType"

								self.summoner:projectSource(tgr, actor.x, actor.y, DamageType.DARKNESS, dam, nil, self)

								if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "shadow_beam", {tx=actor.x-sx, ty=actor.y-sy})
								else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "shadow_beam", {tx=actor.x-sx, ty=actor.y-sy})
								end
					
								sx, sy = actor.x, actor.y
							end
							game:playSoundNear(self, "talents/flame")
						end
					end
				else
					-- Not empowered
					local tg = {type="beam", range=10, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_PIERCE_THE_VEIL), friendlyfire=false, display={particle="bolt_void"}}
					if #tgts >= 0 then
						local a, id = rng.table(tgts)
						table.remove(tgts, id)
						if a then
							local DamageType = require "engine.DamageType"
							self.summoner:projectSource(tg, a.x, a.y, DamageType.DARKNESS, self.dam, nil, self)
							game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "shadow_beam", {tx=a.x-self.x, ty=a.y-self.y})
							game:playSoundNear(self, "talents/flame")
						end 
					end
				end
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		game.level:addEntity(e)
		game.level.map(x, y, Map.TRAP, e)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	temporal_vortex = function(self, t, x, y)	
		local dur = t.getDuration(self,t)
		local dam = self:spellCrit(t.getTemporalDamage(self, t))
		local mult = t.getPower(self,t)/100

		local e = Trap.new{
			triggered = function(self, x, y, who) return true, true end,
			disarmable = false,
			energy = {value=0},
			canTrigger = function() return false end,
			type = "rift", subtype = "temporal vortex",
			name = _t"temporal vortex", image = "terrain/entropic/temporal_vortex.png",
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = dur,
			x = x, y = y,
			canAct = false,
			void_rift = true,
			all_know = true,
			temporal_vortex = true,
			dam = dam,
			mult = mult,
			empower = false,
			act = function(self)
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, 7, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, engine.Map.ACTOR)
					if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
				end end

				local DamageType = require "engine.DamageType"
				-- Randomly take targets
				if self.empower then
					local tg = {type="ball", range=0, friendlyfire=false, radius=5}
					local damage = self.dam + (self.dam * self.mult)
					self.summoner:projectSource(tg, self.x, self.y, DamageType.CHRONOSLOW, {dam=damage, slow=0.5}, nil, self )
				else
					local tg = {type="ball", range=0, friendlyfire=false, radius=4}
					self.summoner:projectSource(tg, self.x, self.y, DamageType.CHRONOSLOW, {dam=self.dam, slow=0.3}, nil, self )
				end
				
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map:removeParticleEmitter(self.particles)	
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
			on_empower = function(self)
				game.level.map:removeParticleEmitter(self.particles)	
				self.particles = game.level.map:addParticleEmitter(engine.Particles.new("generic_vortex", 5, {radius=5, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90, density=50}), self.x, self.y)
			end,
		}
		local particle = engine.Particles.new("generic_vortex", 4, {radius=4, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90, density=50})
		e.particles = game.level.map:addParticleEmitter(engine.Particles.new("generic_vortex", 4, {radius=4, rm=255, rM=255, gm=180, gM=255, bm=180, bM=255, am=35, aM=90, density=50}), x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TRAP, e)
		e:setKnown(self, true)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	dimensional_gateway = function(self, t, x, y)
		local dur = t.getDuration(self,t)
		local dam = t.getDimensionalStats(self,t)
		local mult = t.getPower(self,t)/100
		local sdur = t.getDimensionalDuration(self,t)

		local e = Trap.new{
			triggered = function(self, x, y, who) return true, true end,
			disarmable = false,
			energy = {value=0},
			canTrigger = function() return false end,
			type = "rift", subtype = "dimensional gateway",
			name = _t"dimensional gateway", image = "terrain/entropic/dimentional_gateway.png",
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = dur,
			x = x, y = y,
			canAct = false,
			void_rift = true,
			all_know = true,
			dimensional_gateway = true,
			dam = dam,
			mult = mult,
			empower = false,
			sdur = sdur,
			act = function(self)
				local t = self.summoner:getTalentFromId(self.summoner.T_PIERCE_THE_VEIL)
				if rng.percent(50) then t.voidling(self, self.dam, self.sdur) end
				
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
					game.level:removeEntity(self)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		e:setKnown(self, true)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TRAP, e)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	voidling = function (self, dam, dur)
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then return nil end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "horror", subtype = "eldritch",
			display = "h", blood_color = colors.BLUE,
			faction = self.faction,
			stats = { str=dam, dex=dam, wil=dam, mag=dam, con=dam, cun=dam },
			infravision = 10,
			no_breath = 1,
			fear_immune = 1,
			sight = 15,
			infravision = 15,
			name = _t"void skitterer", color=colors.CRIMSON,
			desc = _t"A bizarre creature covered in writhing tendrils, rapidly teleporting from one place to another as it closes in on its prey.",
			image = "npc/voidling_smaller.png",
			level_range = {self.summoner.level, self.summoner.level}, exp_worth = 0,
			rank = 2,
			size_category = 2,
			autolevel = "zerker",
			max_life = 100,
			life_rating = 4,
			life_regen = 4,
			movement_speed = 2,
			combat_armor = 16, combat_def = 1,
			combat = { dam=10 + self.summoner.level, atk=self.summoner.level*2.2, apr=0, dammod={str=1.1}, physcrit = 10 },

			resolvers.talents{
				[Talents.T_DIMENSIONAL_SKITTER]=1,			
			},

			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self:resolveSource(), -- Objects can't be summoners for various reasons, so just summon them for the highest source
			summoner_gain_exp=true,
			summon_time = dur,
		}
		
		if self.empower then
			m.name = ("%s (empowered)"):tformat(m.name)
			m.global_speed_base  = m.global_speed_base  + self.mult
		end
		m:resolve()
		m:resolve(nil, true)

		game.zone:addEntity(game.level, m, "actor", x, y)
		if target then m:setTarget(target) end
		
		if game.party:hasMember(self.summoner) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self,t)
		local ndam = t.getNetherDamage(self,t)
		local tdam = t.getTemporalDamage(self,t)
		local dur = t.getDimensionalDuration(self,t)
		return ([[Pouring more energy into your rifts, you have a %d%% chance for each one to instead appear as a more powerful type.
#PURPLE#Nether Breach:#LAST# Fires a beam dealing %0.2f darkness damage at a random target in radius 10.
#PURPLE#Temporal Vortex:#LAST# Inflicts %0.2f temporal damage each turn to enemies in radius 4 and reduces their global speed by 30%%.
#PURPLE#Dimensional Gate:#LAST# Has a 50%% chance each turn to summon a voidling lasting %d turns; a fast melee attacker that can teleport.
The stats of your Void Skitterers will scale with your Magic stat and level.]])
		:tformat(chance, damDesc(self, DamageType.DARKNESS, ndam), damDesc(self, DamageType.TEMPORAL, tdam), dur)
	end
}

newTalent{
	name = "Dimensional Skitter",
	type = {"other/horror", 1},
	points = 1,
	cooldown = 4,
	tactical = { ATTACK = { weapon = 0.5, }, CLOSEIN = 3 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	is_melee = true,
	is_teleport = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return 1 end,
	action = function(self, t)
		if self:attr("never_move") then return end
		
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not target or not self:canProject(tg, x, y) then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end -- To prevent teleporting through walls
		if not self:teleportRandom(x, y, 0) then 
			game.logSeen(self, "%s's Dimensional Skitter fizzles!", self:getName():capitalize()) 
			return true 
		end

		if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			local DamageType = require "engine.DamageType"
			self:attackTarget(target, DamageType.TEMPORAL, t.getDamage(self, t), true)
			game:playSoundNear(self, "talents/teleport")
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Teleport to a target within range 10 and strike them with your fangs dealing %d%% weapon damage.]]):tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Zero Point Energy",
	type = {"demented/rift", 4},
	require = dementedreq_high4,
	points = 5, 
	mode = "passive",
	points = 5,
	getPower = function(self, t) return self:combatTalentScale(t, 20, 100) end,	
	info = function(self, t)
		local power = t.getPower(self,t)
		return ([[You draw power from the depths of the void causing your Reality Fracture to enhance any existing rifts.
#GREY#Void Rift:#LAST# Deals %d%% increased damage and projectiles explode in radius 1.
#PURPLE#Nether Breach:#LAST# Deals %d%% increased damage and chains to 3 targets.
#PURPLE#Temporal Vortex:#LAST# Deals %d%% increased damage, radius increased by 1, and slow increased to 50%%.
#PURPLE#Dimensional Gate:#LAST# Voidling Skitterers will be frenzied, increasing their global speed by %d%%.]])
		:tformat(power, power, power, power)
	end,
}


