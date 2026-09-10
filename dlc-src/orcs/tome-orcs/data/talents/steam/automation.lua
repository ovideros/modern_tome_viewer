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

newTalent{
	name = "Pulse Detonator",
	type = {"steamtech/automation", 1},
	points = 5,
	require = steamreq_high1,
	cooldown = 12,
	steam = 25,
	getDur = function(self, t) return math.floor(self:getTalentLevel(t) / 2) * 2 + 1 end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 230) end,
	radius = 4,
	range = 6,
	proj_speed = 5,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t, display={particle="bolt_fire"}}
	end,
	tactical = { ATTACK = { PHYSICAL=1 }, ESCAPE=1 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.PULSE_DETONATOR, {dam=self:steamCrit(t.getDamage(self, t)), dur=t.getDur(self, t), dist=3})
		return true
	end,
	info = function(self, t)
		return ([[Sends a pulse detonator to the target. Upon arrival it explodes in radius 4 cone, dealing %0.2f physical damage, knocking back foes by 3 and dazing them for %d turns.
		Damage increases with your steampower.]]):
		tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t.getDur(self, t))
	end,
}

newTalent{
	name = "Flying Grapple",
	type = {"steamtech/automation", 2},
	points = 5,
	cooldown = 10,
	steam = 30,
	require = steamreq_high2,
	radius = 3,
	range = 10,
	proj_speed = 5,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 180) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}	end,
	tactical = { ATTACK = { PHYSICAL=1 }, ESCAPE=1 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local dam = self:steamCrit(t.getDamage(self, t))

		local proj = require("engine.Projectile"):makeHoming(
			self,
			{particle="bolt_fire"},
			{speed=5, name=_t"Flying Grapple", dam=dam},
			target,
			self:getTalentRange(t),
			function(self, src)
			end,
			function(self, src, target)
				local DT = require("engine.DamageType")
				local tgts = {}
				src:project({type="ball", radius=3, x=self.x, y=self.y}, self.x, self.y, function(px, py)
					local tgt = game.level.map(px, py, engine.Map.ACTOR)
					if (px ~= self.x or py ~= self.y) and tgt and src:reactionToward(tgt) < 0 then tgts[#tgts+1] = {tgt=tgt, dist=core.fov.distance(self.x, self.y, px, py)} end
				end)
				if #tgts == 0 then return end
				table.sort(tgts, "dist")
				for i, d in ipairs(tgts) do
					d.tgt:pull(self.x, self.y, 4, function(a)
						DT:get(DT.PHYSICAL).projector(src, d.tgt.x, d.tgt.y, DT.PHYSICAL, self.def.dam)
						DT:get(DT.PHYSICAL).projector(src, a.x, a.y, DT.PHYSICAL, self.def.dam)
						game.logSeen(d.tgt, "A flying grapple pull %s into %s!", d.tgt.name, a.name)
					end)
				end
			end
		)
		game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
		return true
	end,
	info = function(self, t)
		return ([[You send a small steam-powered flying grapple to a target. The drone is homing so if the target moves it will follow.
		When it reaches its target it deploys grapples in all directions around it in radius 4.
		The grapples latch onto any foes and pull them toward the target. If they are stopped by a creature (or the target) both them and the creature take %0.2f physical damage.
		]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}


newTalent{
	name = "Net Projector",
	type = {"steamtech/automation", 3},
	points = 5,
	cooldown = 15,
	require = steamreq_high3,
	steam = 40,
	getResist = function(self, t) return self:combatTalentLimit(t, 70, 20, 50) end,
	radius = 2,
	range = 8,
	proj_speed = 6,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	tactical = { DISABLE=2 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or self:reactionToward(target) >= 0 then return end
			if target:canBe("pin") then
				target:setEffect(target.EFF_NET_PROJECTOR, 5, {apply_power=self:combatSteampower(), power=t.getResist(self, t)})
			else
				game.logSeen(target, "%s resists the net.", target:getName():capitalize())
			end
		end)

		if core.shader.active(4) then
			game.level.map:particleEmitter(x, y, tg.radius, "shader_ring", {radius=tg.radius*2, life=8}, {type="sparks"})
		else
			-- Lightning ball gets a special treatment to make it look neat
			local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
			local nb_forks = 16
			local angle_diff = 360 / nb_forks
			for i = 0, nb_forks - 1 do
				local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
				local tx = x + math.floor(math.cos(a) * tg.radius)
				local ty = y + math.floor(math.sin(a) * tg.radius)
				game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
			end
		end

		game:playSoundNear(self, "talents/lightning")

		return true
	end,
	info = function(self, t)
		return ([[Sends a lightly electrified net of radius 2 toward a target, all creatures caught inside will be pinned in place for 5 turns.
		While the electricity is not enough to do damage it does shock their body, reducing all resistances by %d%%.]]):
		tformat(t.getResist(self, t))
	end,
}

newTalent{
	name = "Sawfield",
	type = {"steamtech/automation", 4},
	points = 5,
	cooldown = 10,
	require = steamreq_high4,
	steam = 25,
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 5)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 190) end,
	range = 6,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	tactical = { ATTACK = { PHYSICAL=1 }, ESCAPE=1 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, 4,
			DamageType.PHYSICALBLEED, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="sawstorm", args={rad=self:getTalentRadius(t)}, only_one=true},
			nil,
			false
		)
		game:playSoundNear(self, "talents/icestorm")
		return true
	end,
	info = function(self, t)
		return ([[For 4 turns many small saws circle around the target in radius %d, making any creature caught inside bleed for %0.2f physical damage.
		Damage increases with your steampower.]]):
		tformat(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}
