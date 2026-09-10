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

local damDesc = Talents.main_env.damDesc

newTalent{
	name = "Nebula Spear",
	type = {"celestial/void", 1},
	require = divi_req_high1,
	points = 5,
	range = 6,
	radius = 4,
	proj_speed = 3.5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 140) end,
	target = function(self, t) return 
		{type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), cone_angle=25, stop_block=true, talent=t, display={particle="nebula_spear", trail="darktrail"}, start_x = self.x, start_y = self.y,
		block_radius = function(typ, lx, ly) --the only difference is adding a check for actors that block move
			local nb = game.level.map:checkAllEntitiesCount(lx, ly, "block_move")
					-- Reduce the nb blocking for friendlies
				if (typ.pass_terrain or game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile")) then
					nb = nb - 1
				end
				if not typ.friendlyblock and typ.source_actor and typ.source_actor.reactionToward then
					local a = game.level.map(lx, ly, engine.Map.ACTOR)
					if a and typ.source_actor:reactionToward(a) > 0 then
						nb = nb - 1
					end
				end
			return not typ.no_restrict and nb > 0 and not game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "pass_projectile") and not (for_highlights and not (game.level.map.remembers(lx, ly) or game.level.map.seens(lx, ly)))
		end}
	end,
	action = function(self, t)
		local tgt = self:getTalentTarget(t)
		local x, y = self:getTarget(tgt)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		tgt.display.tx = x - self.x
		tgt.display.ty = y - self.y
		tgt.type = "bolt" --in order to count the grids we have to do the projection ourselves
		tgt.damage = self:spellCrit(t.getDamage(self, t))
		tgt.on_stop_check = function(self, typ, tg, damtype, dam, particles, px, py, tmp, rx, ry, projectile)
			DamageType = require "engine.DamageType"
			if game.level.map(rx, ry, engine.Map.ACTOR) then
				DamageType:get(DamageType.DARKNESS).projector(self, rx, ry, DamageType.DARKNESS, tg.damage * 2.5, nil, nil)
			else
				tg.type = "cone"
				tg.stop_block = false
			
				local grids = self:project(tg, rx, ry, function() end)
				--don't want to do this but I have to
				local old_block = tg.block_radius
				tg.block_radius = nil
				local theoretical_nb = 0
				local nb = 0
				--this is the number of grids excluding walls, unlike the alchemist bombs which are higher when there are more walls
				local theoretical_grids = self:project(tg, rx, ry, function() end)
				if theoretical_grids then for px, ys in pairs(theoretical_grids or {}) do for py, _ in pairs(ys) do theoretical_nb = theoretical_nb + 1 end end end
				if grids then for px, ys in pairs(grids or {}) do for py, _ in pairs(ys) do nb = nb + 1 end end end
				local dammult
				if theoretical_nb == 0 then dammult = 1
				else dammult = 1 + 1 * math.max(nb - 1, 0) / theoretical_nb end
				
				if grids then for px, ys in pairs(grids or {}) do for py, _ in pairs(ys) do DamageType:get(DamageType.DARKNESS).projector(self, px, py, DamageType.DARKNESS, tg.damage * dammult, nil, nil) end end end
				game.level.map:particleEmitter(px, py, tg.radius, "breath_dark", {radius=tg.radius, spread = tg.cone_angle, grids=grids, tx=px - tg.start_x, ty=py - tg.start_y})
			
				--nothing should use this but just in case
				tg.type = "bolt"
				tg.stop_block = true
			end
			return true
		end
		
		self:projectile(tgt, x, y, function(px, py, tg, self)
			local Map = require("engine.Map")
			local proj = game.level.map(px, py, Map.PROJECTILE)
			if not proj then --i.e. the projectile finished
				--part of the reason we're using the same tg is due to things in reflection and such that change the start_x, y etc which we need for cones
				
			end
		end)
		return true
	end,
	info = function(self, t)
		local damage = damDesc(self, DamageType.DARKNESS, t.getDamage(self, t))
		local radius = self:getTalentRadius(t)
		return ([[Fire out a spear of cosmic energies. If it hits an enemy it deals %0.2f damage, otherwise it explodes in a thin cone of radius %d at the end of its range, blocked by enemies, which deals %0.2f to %0.2f damage depending on how much the enemies block.]]):
		tformat(damage * 2.5, radius, damage, damage * 2.5)
	end,
	
}

newTalent{
	name = "Crescent Wave",
	type = {"celestial/void", 2},
	require = divi_req_high2,
	points = 5,
	action = function(self, t)
	end,
	info = function(self, t)
		return (_t[[Fires out a projectile in a clockwise arc. If it hits an enemy it deals %0.2f damage and roots them for one turn. If another projectile damages them within %d turns, they take half that damage and are rooted again.]])
	end,
	
}

newTalent{
	name = "Twilit Echoes",
	type = {"celestial/void", 2},
	require = divi_req_high2,
	range = 7,
	positive = 20,
	negative = 20,
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getEchoDur = function(self, t) return 3 end,
	getDarkEcho = function(self, t) return self:combatTalentScale(t, 0.075, 0.15) end,
	getSlowPer = function(self, t) return 0.001 end,
	getSlowMax = function(self, t) return t.getSlowPer(self, t) * self:combatTalentSpellDamage(t, 150, 400) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then return nil end
		target:setEffect(target.EFF_TWILIT_ECHOES, t.getDuration(self, t), {echo_dur = 3, dam_factor = t.getDarkEcho(self,t), slow_per = t.getSlowPer(self, t), slow_max = t.getSlowMax(self, t)})
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local echo_dur = t.getEchoDur(self, t)
		local slow_per = t.getSlowPer(self, t)
		local slow_max = t.getSlowMax(self, t)
		local echo_factor = t.getDarkEcho(self, t)
		return ([[The target feels the echoes of all your light and dark damage for %d turns. 

Light damage slows the target by %0.2f%% per point of damage dealt for %d turns, up to a maximum of %d%% at %d damage.
Dark damage creates an effect at the tile for %d turns which deals %d%% of the damage dealt each turn. It will be refreshed as long as the target continues taking damage from it or another source while Twilit Echoes is active, dealing its remaining damage over the new duration as well as the new damage.]])
		:tformat(duration, slow_per * 100, echo_dur, slow_max * 100, slow_max/slow_per, echo_dur, 100 * echo_factor)
	end,
}

newTalent{
	name = "Starscape",
	type = {"celestial/void", 4},
	require = divi_req_high4,
	points = 5,
	cooldown = 60,
	positive = 0,
	negative = 0,
	radius = 8,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 9)) end,
	requires_target = true,
	action = function(self, t)
		if game.zone.no_planechange then
			game.logPlayer(self, "This spell cannot be cast here.")
			return
		end
		t.terrains = t.terrains or mod.class.Grid:loadList("/data/general/grids/void.lua")
		-- cache
		--the effects are handled in the main buff
		self:setEffect(self.EFF_STARSCAPE, t.getDuration(self, t), {radius=self:getTalentRadius(t), t=t, terrains=t.terrains})
		return self:hasEffect(self.EFF_STARSCAPE)
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		
		return ([[Summons the starscape in the surrounding area in a radius of %d. For %d turns, this area exists outside normal time, and in zero gravity. In addition to the effects of zero gravity, Movement of projectiles and other creatures is three times as slow. Spells and attacks cannot escape the radius until the effect ends.]]):
		tformat(radius, duration)
	end,
}