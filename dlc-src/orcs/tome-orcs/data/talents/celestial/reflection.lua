-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Diffraction Pulse",
	type = {"celestial/reflection", 1},
	require = divi_req1,
	points = 5,
	positive = 10,
	range = function(self,t) return math.floor(self:combatTalentScale(t, 2, 8, 0.75)) end,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 3, 23, 8)) end, --limit >= 3
	tactical = {SPECIAL=10},
	radius = 3,
	target = function(self, t) return {type="ball", nolock=true, pass_terrain=false, nowarning=true, friendly_fire=true, default_target=self, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	onAIGetTarget = function(self, t)
		local tgts = {}
		self:project({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, function(px, py)
			local tgt = game.level.map(px, py, Map.PROJECTILE)
			if tgt and (not tgt.src or self:reactionToward(tgt.src) < 0) then tgts[#tgts+1] = {x=px, y=py, tgt=tgt, dist=core.fov.distance(self.x, self.y, px, py)} end
		end)
		table.sort(tgts, function(a, b) return a.dist < b.dist end)
		if #tgts > 0 then return tgts[1].x, tgts[1].y, tgts[1].tgt end
	end,
	on_pre_use_ai = function(self, t, silent) return t.onAIGetTarget(self, t) and true or false end,
	action = function(self, t)
		
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
	
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		-- get locations in line of movement from center
		local locations = {}
		local grids = core.fov.circle_grids(x, y, radius, true)
		
		game.level.map:particleEmitter(x, y, tg.radius, "ball_light", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
		for x1, yy in pairs(grids) do for y1, _ in pairs(grids[x1]) do
			local l = line.new(x, y, x1, y1)
			lx = x
			ly = y
			while lx and ly do
				local proj = game.level.map(lx, ly, Map.PROJECTILE)
				if proj then
					local energy = proj.energy.value
				
					local angle = math.atan2(ly - y, lx - x)
					if ly == y and lx == x then angle = math.atan(ly - self.y, lx - self.x) end
					local ax = math.abs(angle % math.pi - math.pi / 2) < 0.1 and 0 or math.cos(angle)
					local ay = math.abs(angle % math.pi) < 0.1 and 0 or math.sin(angle)
					
					local centerdist = core.fov.distance(proj.x, proj.y, x, y)
					local dx = math.ceil(math.abs(ax * (tg.radius))) * (ax < 0 and -1 or 1)
					local dy = math.ceil(math.abs(ay * (tg.radius))) * (ay < 0 and -1 or 1)
					
					local dist, range, remaining
					if proj.project then
						dist = core.fov.distance(proj.project.def.start_x, proj.project.def.start_y, lx, ly)
						range = core.fov.distance(proj.project.def.start_x, proj.project.def.start_y, proj.project.def.x, proj.project.def.y)
							  + 1
						remaining = range - dist
						
						local lpx, lpy = lx, ly
						local stopped = false
						
						
					
						--messy stuff to get normal (i.e. non-homing) proejctiles to change paths
						
						local x_ = proj.x + math.ceil(math.abs(remaining * ax)) * (ax < 0 and -1 or 1)
						local y_ = proj.y + math.ceil(math.abs(remaining * ay)) * (ay < 0 and -1 or 1)
						
						-- here's the messy stuff most likely to break
						-- this sets the projectile's new path to its current x and y coords pointing in the new direction
						local block_corner = proj.project.def.typ.line_function.block_corner
						local block = proj.project.def.typ.line_function.block
						
						proj.project.def.typ.line_function = core.fov.line(proj.x, proj.y, x_, y_, block)
						proj.project.def.typ.line_function:set_corner_block(block_corner)
						
						--this stuff gets read out later by projectile functions e.g. solar orb (actually doesn't use it now)
						proj.project.def.start_x = proj.x
						proj.project.def.start_y = proj.y
						proj.project.def.tg.start_x = proj.x
						proj.project.def.tg.start_y = proj.y
						proj.project.def.x = x_
						proj.project.def.y = y_
						proj.start_x = proj.project.def.start_x
						proj.start_y = proj.project.def.start_y
						
						local count = 0
						while core.fov.distance(x, y, proj.x, proj.y) < tg.radius and count < 5 do
							proj.energy.value = game.energy_to_act / proj.energy.mod
							proj:act()
							--just make it move itself there because of the range we've given it and the range including this distance
							count = count + 1
						end
						
					elseif proj.homing then
						local count = 0
						while not proj.x == lx + dx and not proj.y == lx + dy and count < 10 do
							proj:moveDirection(lx + dx, ly + dy)
							count = count + 1
						end
						proj:move(lx + dx, ly + dy)
					end
					
					proj.energy.value = energy
				end
				lx, ly = l()
			end
		end end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return (_t[[Create a distortion at the target tile, knocking back all projectiles and changing their direction to face away if possible.]])
	end,
}

newTalent{
	name = "Mirror Wall",
	type = {"celestial/reflection", 2},
	require = divi_req2,
	points = 5,
	positive = 20,
	tactical = { DISABLE = 1},
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 32, 10)) end, --limit >= 5
	range = 6,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 5, 15)) end,
	getHalflength = function(self, t) return 1 end,
	action = function(self, t)
		local halflength = t.getHalflength(self, t)
		local block = function(_, lx, ly)
			return game.level.map:checkAllEntities(lx, ly, "block_move")
		end
		local tg = {type="wall", range=self:getTalentRange(t), halflength=halflength, talent=t, halfmax_spots=halflength+1, block_radius=block}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		self:project(tg, x, y, function(px, py, tg, self)
			local oe = game.level.map(px, py, Map.TERRAIN)
			if not oe or oe.special then return end
			if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
			
			local Object = require("engine.Object")
			
			local e = Object.new{
				old_feat = oe,
				name = _t"mirror wall",
				type = "wall", subtype = "light",
				display = '#', color=colors.MAGENTA, back_color=colors.PURPLE,
				always_remember = true,
				can_pass = {pass_wall=1},
				block_move = false,
				block_sight = true,
				temporary = t.getDuration(self, t),
				x = px, y = py,
				canAct = false,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map:remove(self.x, self.y, engine.Map.TERRAIN + 6)
						game.level:removeEntity(self)
						game.level.map:removeParticleEmitter(self.particles)
						game.level.map:updateMap(self.x, self.y)
						game.level.map:redisplay()
					end
				end,
				on_projectile_move = function(self, force)
					local Map = require("engine.Map")
					local proj = game.level.map(self.x, self.y, engine.Map.PROJECTILE)
					if not proj then return end
				
					local xold, yold = 0, 0
					local flipx, flipy = false, false
					local theta = 0
					if proj.project then
						tangent = math.abs((proj.project.def.start_y - proj.y) / (proj.project.def.start_x - proj.x))
						
						flipx = (game.level.map(proj.x, proj.y - 1, Map.TERRAIN + 6) ~= nil) or (game.level.map(proj.x, proj.y + 1, Map.TERRAIN + 6) ~= nil)
						flipy = (game.level.map(proj.x - 1, proj.y, Map.TERRAIN + 6) ~= nil) or (game.level.map(proj.x + 1, proj.y, Map.TERRAIN + 6) ~= nil)
						
						if not (flipx or flipy) then
							flipx = 1 >= tangent
							flipy = 1 <= tangent
						end
						
						--xold = math.floor(proj.x + math.ceil(math.abs(math.cos(theta))) * (math.abs(theta % math.pi) < math.pi / 2 and 1 or -1))
						--yold = math.floor(proj.y + math.ceil(math.abs(math.sin(theta))) * (theta > 0 and 1 or -1))
						proj.project.def.start_x = proj.x --(proj.project.def.start_x - proj.x) * (flipx and -1 or 1) + proj.x
						proj.project.def.start_y = proj.y --(proj.project.def.start_y - proj.y) * (flipy and -1 or 1) + proj.y
						proj.project.def.tg.start_x = proj.x
						proj.project.def.tg.start_y = proj.y
						proj.start_x = proj.project.def.start_x
						proj.start_y = proj.project.def.start_y
						proj.project.def.x = (proj.project.def.x - proj.x) * (flipx and -1 or 1) + proj.x
						proj.project.def.y = (proj.project.def.y - proj.y) * (flipx and 1 or -1) + proj.y
						local block_corner = proj.project.def.typ.line_function.block_corner
						local block = proj.project.def.typ.line_function.block
						
						proj.project.def.typ.line_function = core.fov.line(proj.x, proj.y, proj.project.def.x, proj.project.def.y, block)
						proj.project.def.typ.line_function:set_corner_block(block_corner)
						proj.energy.value = proj.energy.value + game.energy_to_act / proj.energy.mod
						proj:act()
					end
					
				end,
				on_project = function(proj, t, lx, ly, damtype, dam, particles)
					return false
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			e.particles = game.level.map:particleEmitter(e.x, e.y, 2, "mirror_wall", {tx=adjx, ty=adjy, max_alpha=80})
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN + 6, e)
			game.level.map:updateMap(px, py)
		--	game.nicer_tiles:updateAround(game.level, px, py)
		--	game.level.map:updateMap(px, py)
		end)
		game.level.map:redisplay() --lighting
		return true
	end,
	info = function(self, t)
		local halflength = t.getHalflength(self, t)
		local duration = t.getDuration(self, t)
		return([[Creates a wall %d units long for %d turns, reflecting all projectiles that hit it and blocking sight.]]):
		tformat(halflength * 2 + 1, duration)
	end,
}

newTalent{
	name = "Spatial Prism",
	type = {"celestial/reflection", 3},
	require = divi_req3,
	points = 5,
	getCost = function(self, t) return math.floor(self:combatTalentLimit(t, 1, 30, 10)) end, --limit >= 1
	positive = function(self, t) return t.getCost(self, t) end,
	negative = function(self, t) return t.getCost(self, t) end,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 30, 15)) end, -- limit >= 8
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7)) end,
	no_energy = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		local Map = require("engine.Map")
		local proj = game.level.map(x, y, engine.Map.PROJECTILE)
		local energy = proj.energy.value
					
		
		if proj.project then
			local range = core.fov.distance(proj.x, proj.y, proj.project.def.x, proj.project.def.y)
			
			local tg2 = (proj.project.def and proj.project.def.tg) or {type = "hit"}
			tg2.range = range
			tg2.start_x = x 
			tg2.start_y = y
			
			local x2, y2 = self:getTarget(tg2)
			if not x2 or not y2 then return nil end
			local _ _, _, _, x2, y2 = self:canProject(tg2, x2, y2)
			--this is a hack for lunar orb, deal with it
			if proj.name == "Lunar Orb" then
				x2 = 1000 * (x2 - x) + x
				y2 = 1000 * (y2 - y) + y
			end
			
			--this is all copy-pasted from distortion pulse, the retargeting is the same
			--look there for more comments and such
			local proj2 = require("engine.Projectile").new(proj:clone{})
			--not going to bother to put these in the clone block
			local block_corner = proj.project.def.typ.line_function.block_corner
			local block = proj.project.def.typ.line_function.block
			proj2.project.def.typ.line_function = core.fov.line(proj.x, proj.y, x2, y2, block)
			proj2.project.def.typ.line_function:set_corner_block(block_corner)
			proj2.project.def.start_x = proj.x
			proj2.project.def.start_y = proj.y
			proj2.project.def.x = x2
			proj2.project.def.y = y2
			proj2.start_x = proj2.project.def.start_x
			proj2.start_y = proj2.project.def.start_y
			proj2.src = self
			game.zone:addEntity(game.level, proj2, "projectile", x, y)
			if self.mirror_self and not self.mirror_self.dead then
				local proj3 = require("engine.Projectile").new(proj:clone{})
				local block_corner = proj.project.def.typ.line_function.block_corner
				local block = proj.project.def.typ.line_function.block
				proj3.project.def.typ.line_function = core.fov.line(proj.x, proj.y, x2, y2, block)
				proj3.project.def.typ.line_function:set_corner_block(block_corner)
				proj3.project.def.start_x = proj.x
				proj3.project.def.start_y = proj.y
				proj3.project.def.x = x2
				proj3.project.def.y = y2
				proj3.start_x = proj3.project.def.start_x
				proj3.start_y = proj3.project.def.start_y
				proj3.src = self
				game.zone:addEntity(game.level, proj3, "projectile", x, y)
			end
		elseif proj.homing then
			local tg2 = {type = "hit", start_x = x, start_y = y}
			local x2, y2 = self:getTarget(tg2)
			if not x2 or not y2 then return nil end
			local _ _, _, _, x2, y2 = self:canProject(tg2, x2, y2)
			local target = game.level.map(x2, y2, Map.ACTOR)
			if not target then return nil end
			local proj2 = require("engine.Projectile").new(proj:clone{})
			proj2.homing.target = target
			proj2.src = self
			game.zone:addEntity(game.level, proj2, "projectile", x, y)
			if self.mirror_self and not self.mirror_self.dead then
				local proj3 = require("engine.Projectile").new(proj:clone{})
				proj3.homing.target = target
				proj3.src = self
				game.zone:addEntity(game.level, proj3, "projectile", x, y)
			end
		end
					
		proj.energy.value = energy
		game:playSoundNear(self, "talents/distortion")
		return true
	end,
	info = function(self, t)
		return(_t[[Target a projectile in mid-flight to clone it and target that projectile independently. You gain ownership over the new projectile.]])
	end,
}

newTalent{
	name = "Mirror Self",
	type = {"celestial/reflection", 4},
	require = divi_req4,
	points = 5,
	cooldown = 30,
	positive = 10,
	negative = 35,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5.5)) end,
	getDam = function(self, t) return self:combatTalentLimit(t, 1, 0.4, 0.8) end,
	getHealth = function(self, t) return 0.5 end, --self:combatTalentScale(t, 0.35, 0.65) end,
	no_energy = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		local m = require("mod.class.NPC").new(self:clone{
			shader = "moving_transparency",
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = nil,
			name = ("Mirror Image (%s)"):tformat(self:getName()),
			desc = _t[[A cloned image of you.]],
		})
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life * t.getHealth(self, t)
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.puuid = nil
		m.on_takehit = nil
		m.exp_worth = 0
		m.no_inventory_access = true
		m.clone_on_hit = nil
		m.talents.T_MIRROR_SELF = nil
		m.remove_from_party_on_death = true
		m.inc_damage.all = ((100 + (m.inc_damage.all or 0)) * t.getDam(self, t)) - 100
		m.invert_light_dark = true
		m:incNegative(-20 * (1 + self:combatFatigue() / 100))
		m.never_move = true
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		--game.level.map:particleEmitter(x, y, 1, "shadow")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="minion",
				title=_t"Mirror Self",
				orders = {target=true},
			})
		end
		self.mirror_self = m

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDam(self, t)
		local health = t.getHealth(self, t)
		return([[Summons a clone for %d turns which casts all the spells you cast, dealing %d%% damage and having %d%% health. Additionally, all light damage the clone deals becomes darkness damage and all darkness damage becomes light damage.]]):
		tformat(duration, damage * 100, health * 100)
	end,
}