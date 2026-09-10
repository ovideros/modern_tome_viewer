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


local Map = require "engine.Map"
local damDesc = Talents.main_env.damDesc

newTalent{
	name = "Lunar Orb",
	type = {"celestial/cosmic", 1},
	require = divi_req1,
	points = 5,
	cooldown = 5,
	negative = 0,
	range = 999,
	proj_speed = 2.5,
	tactical = {ATTACK = {DARKNESS = 2}, NEGATIVE = 2},
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 250) end,
	getNegative = function(self, t) return math.floor(self:combatTalentScale(t, 6, 12)) end,
	requires_target = true,
	target = function(self, t) return {type="beam", talent=t, range=math.inf, display={particle="lunar_orb", trail="darktrail"}, selffire=false, negative = t.getNegative(self, t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local x_ = (x - self.x) * 1000 + self.x
		local y_ = (y - self.y) * 1000 + self.y
		
		local damage = self:spellCrit(t.getDamage(self, t))
		tg.damage = damage --upvalue stuff, calculate after targeting so people can't scum crits
		
		self:projectile(tg, x_, y_, function(px, py, tg, self)
			local DT = require("engine.DamageType")
			local Map = require("engine.Map")
			
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then target:setTarget(self) end
			if target and target ~= self and target.summoner ~= self then
				tg.negative = tg.negative or t.getNegative(self, t)
				self:incNegative(tg.negative) 
				tg.negative = 0.75 * tg.negative
			end
			DT:get(DT.DARKNESS).projector(self, px, py, DT.DARKNESS, tg.damage or 0)
		end)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local restore = t.getNegative(self, t)
		return ([[Fires out a bolt of cosmic energy in the target direction. The projectile continues until it hits a wall or the edge of the map, dealing %0.2f dark damage to enemies hit and restoring %d negative energy. The negative energy gained is reduced by 25%% per enemy hit, restoring a maximum of %d. Enemies hit will become aware of you.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage), restore, restore * 4)
	end,
}

newTalent{
	name = "Astral Path",
	type = {"celestial/cosmic", 2},
	require = divi_req2,
	points = 5,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 1, 6.25, 4.5, false, 1.0)) end, --limit >= 1, 4 at 6.5, 3 with cat point
	positive = 10,
	negative = 10,
	requires_target = true,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t, display={particle="astral_orb", trail="darktrail"}, selffire=false} end,
	tactical =  {ESCAPE = 1, CLOSEIN = 2},
	proj_speed = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, "log") * math.max(1, self.movement_speed) * 100) / 100 end, --just truncating it brutally because the display won't truncate it
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7.5, 0.5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		tg.on_stop_check = function(self, typ, tg, damtype, dam, particles, px, py, tmp, rx, ry, projectile)
			local tx, ty = util.findFreeGrid(px, py, 1, true, {[engine.Map.ACTOR]=true})
			if tx and ty then
				game.level.map:particleEmitter(self.x, self.y, 1, "dark_teleport", {size=4, distorion_factor=5, radius=1.25, life=6, nb_circles=4, warpin=false})
				if not self:teleportRandom(tx, ty, 0) then
					game.logSeen(self, "The spell fizzles: there are no available spots to teleport to.")
				end
				game.level.map:particleEmitter(self.x, self.y, 1, "dark_teleport", {size=4, distorion_factor=5, radius=1.25, life=12, nb_circles=4, warpin=true})
				game:playSoundNear(self, "talents/teleport")
			end
			return true
		end
-- another case where the NPC needs to get an escape spot
		self:projectile(tg, x, y, function(px, py, tg, self) end)
		return true
	end,
	info = function(self, t)
		return ([[Fire an orb of negative energy towards a spot within range %d.
		When the orb reaches its destination, it will teleport you to its location.
		The speed of the projectile (%d%%) increases with your movement speed]]):tformat(t.range(self, t), t.proj_speed(self, t)*100)
	end,
}

newTalent{
	name = "Galactic Pulse",
	type = {"celestial/cosmic", 3},
	require = divi_req3,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 37, 22)) end,
	negative = 15,
	range = 8,
	requires_target = true,
	proj_speed = 1.25,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	--getNegative = function(self, t) return math.ceil(self:combatTalentScale(t, 0.5, 1.5)) end,
	tactical = {ATTACKAREA = {DARKNESS = 1}, DISABLE = 1, ESCAPE = 1},
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t, display={particle="galactic_pulse"}} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local damage = self:spellCrit(t.getDamage(self, t))
		tg.damage = damage
		self:projectile(tg, x, y, function(px, py, tg, self)
			local DT = require("engine.DamageType")
			local Map = require("engine.Map")
			local aoe = {type="ball", radius=1, friendlyfire=true, selffire=false, talent=t or tg.talent}
			
			--doing it with the damage in the projector causes it to only hit once
			self:project(aoe, px, py, function(tx, ty)
				DT:get(DT.DARKNESS_PULL).projector(self, tx, ty, DT.DARKNESS_PULL, {dam=tg.damage or damage or 0, px=px, py=py, dist=1.5, ignore_chance=50, silent=true})
				local target = game.level.map(tx, ty, Map.ACTOR)
				if target then 
					self:incNegative(1) 
				end
			end)
			
		end)
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Sends out a slow-moving spiral of cosmic energy towards a target location within range 8.
		As the cosmic energy moves, it pulls in targets adjacent to it, dealing %0.2f darkness damage and granting you 1 negative energy per hit.]]):
		tformat(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Supernova",
	type = {"celestial/cosmic", 4},
	require = divi_req4,
	points = 5,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 40, 25)) end, --limit >= 15
	negative = 30, --I would make this show your current value, but dividing by and then multiplying by fatigue causes floating point errors that just barely make it unusable at some points
	range = 6,
	radius = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) * self:getNegative(), 1, 0, 4, 1000)) end,
	requires_target = true,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), friendlyfire=true, selffire=true, talent=t} end,
	tactical = {ATTACKAREA = {DARKNESS=2}, DISABLE = {pin=2}},
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 260) * (1/2 + self:getNegative() / 100) end,
	getPinDuration = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) * self:getNegative(), 2, 0, 8, 1000)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local damage = self:spellCrit(t.getDamage(self, t))
		local pin = t.getPinDuration(self, t)
		
		local grids = self:project(tg, x, y, DamageType.DARKNESS_PIN, {dam=damage, pin=pin})
		game.level.map:particleEmitter(x, y, tg.radius, "dark_collapse", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
		
		self.negative = 0
		game:playSoundNear(self, "talents/echo")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local pin = t.getPinDuration(self, t)
		return ([[Expend all of your negative energy to create a massive burst of dark energy (radius %d) at a target location within range %d.
		This deals %0.2f darkness damage and pins targets hit for %d turns.
		The damage and pin chance increase with your spellpower, and the damage, radius and pin duration all increase with negative energy and talent level]]):
		tformat(radius, self:getTalentRange(t), damDesc(self, DamageType.DARKNESS, damage), pin)
	end,
}
