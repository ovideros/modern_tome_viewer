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
	name = "Solar Orb",
	type = {"celestial/sol", 1},
	require = divi_req1,
	points = 5,
	getRealCooldown = function(self, t) return self:combatTalentLimit(t, 3, 10, 6) end, --the cooldown reduction uses this to halve instead
	cooldown = function(self, t) return math.ceil(t.getRealCooldown(self, t)) end, --limit to >= 4
	getCooldownReduction = function(self, t) return
		math.ceil(math.max(t.getRealCooldown(self, t) / 2, (self.talents_cd[t.id] or 0) / 2))
	end,
	positive = -10,
	range = 7,
	proj_speed = 4,
	tactical = {ATTACK = {LIGHT = 2}, POSITIVE = 1},
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), talent=t, display={particle="solar_orb", trail="lighttrail"}, selffire=false} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 140) end,
	requires_target = true,
	refresh = function(self, t)
		if self.talents_cd[t.id] then
			self:alterTalentCoolingdown(t.id, - t.getCooldownReduction(self, t))
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local damage = self:spellCrit(t.getDamage(self, t))
		local speed = self:getTalentProjectileSpeed(t)
		local newrange = self:getTalentRange(t) * 4
		
		tg._damage = damage
		tg._speed = speed
		tg._newrange = newrange

		tg.on_stop_check = function(self, typ, tg, damtype, dam, particles, px, py, tmp, rx, ry, projectile)
			if self then
				local proj = require("engine.Projectile"):makeHoming(
					self,
					{particle="solar_orb", trail="lighttrail"},
					{speed=tg._speed, name=_t"Solar Orb", damage=tg._damage, owner=self, talent_id=tg.talent_id},
					self,
					tg._newrange,
					function(self, src)
						local DT = require("engine.DamageType")
						DT:get(DT.LIGHT).projector(self.def.owner, self.x, self.y, DT.LIGHT, self.def.damage)
					end,
					function(self, src, target)
						local t = self.def.owner:getTalentFromId(self.def.talent_id)
						if target == self.def.owner then
							t.refresh(self.def.owner, t)
						else --spacial prism can make this happen
							local DT = require("engine.DamageType")
							DT:get(DT.LIGHT).projector(self.def.owner, self.x, self.y, DT.LIGHT, self.def.damage)
						end
					end
				)
				game.zone:addEntity(game.level, proj, "projectile", px, py)
			end
			return true
		end
		self:projectile(tg, x, y, function(px, py, tg, self)
			if not self then return end
			local t = self:getTalentFromId(tg.talent_id)
			if not t then return end
			local DT = require("engine.DamageType")
			local Map = require("engine.Map")
			local damage = tg._damage
			
			DT:get(DT.LIGHT).projector(self, px, py, DT.LIGHT, damage)
			if self.x and self.y and x == self.x and y == self.y then
				t.refresh(self, t)
			end
		end)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local cooldownred = t.getCooldownReduction(self, t)
		return ([[Fire out an orb of light that deals %0.2f light damage and then returns, dealing the same amount of damage again and reducing the cooldown by half (%d) when it reaches you. The damage will increase with your spellpower. The ball will travel at most %d distance to return to you.]]):
		tformat(damDesc(self, DamageType.LIGHT, damage), cooldownred, self:getTalentRange(t) * 4)
	end,
}

newTalent{
	name = "Solar Wind",
	type = {"celestial/sol", 2},
	require = divi_req2,
	points = 5,
	cooldown = 4,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_positive = 20,
	range = 0,
	requires_target = false,
	
	getSpeed = function(self, t) return self:combatTalentSpellDamage(t, 20, 120) end,
	getSlowFromSpeed = function(speed) return 100 - 100/(2 - 1/(1 + speed / 100)) end, --solar orb will never take longer when fired straight out unless the player moves
	getSlow = function(self, t) return getSlowFromSpeed(t.getSpeed(self, t)) end, --the slow is also asymptotic to 50% because at over 50% it would take longer regardless of the outgoing speed
	activate = function(self, t)
		local speed = t.getSpeed(self, t)
		local slow = t.getSlowFromSpeed(speed)
		return {
			incoming = self:addTemporaryValue("slow_projectiles", slow),
			outgoing = self:addTemporaryValue("slow_projectiles_outgoing", -speed),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("slow_projectiles", p.incoming)
		self:removeTemporaryValue("slow_projectiles_outgoing", p.outgoing)
		return true
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t)
		local slow = t.getSlowFromSpeed(speed)
		return ([[While sustained, this ability speeds up outgoing projectiles by %d%% while slowing incoming projectiles by %d%%. The increase and decrease improve with your spellpower]]):
		tformat(speed, slow)
	end,
}

newTalent{
	name = "Lucent Wrath",
	type = {"celestial/sol", 3},
	require = divi_req3,
	points = 5,
	cooldown = 12,
	tactical = {ATTACKAREA = {LIGHT = 2}},
	positive = 15,
	range = 7,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	radius = function (self, t) return 2 end,--1 + math.floor(math.sqrt(1.25 * self:getTalentLevel(t) + 1)) end,
	--locked at 2 to make sure it remains avoidable, only delay decreased
	--breakpoints for radius 3, 4 at 2.4, 6.4
	getDelay = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 4, 2)) end, --limit >= 1
	--breakpoints for delay 3, 2, 1 at 
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local duration = 1 + t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		
		--this is a pretty cheaty way to go about it, and yes the damage in the damage arg isn't used until projecting
		local map_eff = game.level.map:addEffect(self, x, y, duration, DamageType.NULL_TYPE, 
		{dam = t.getDamage(self, t), radius = radius, self = self, talent = t}, 
		0, 5, nil, 
		{type="sunstrike_warning", args ={radius = radius}}, --Particles.new("sunstrike_warning", 1, { })
		function(e, update_shape_only)
			if not update_shape_only and e.duration == 1 then
				local DamageType = require("engine.DamageType") --block_path means that it will always hit the tile we've targeted here
				local aoe = {type="ball", radius = e.dam.radius, friendlyfire=true, selffire=true, talent=e.dam.talent, block_path = function(self, t) return false, true, true end}
				e.src.__project_source = e
				local grids = e.src:project(aoe, e.x, e.y, DamageType.LITE_LIGHT, e.dam.dam)
				e.src.__project_source = nil
				game.level.map:particleEmitter(e.x, e.y, e.dam.radius, "sunburst", {radius=e.dam.radius * 0.92, grids=grids, tx=e.x, ty=e.y, max_alpha=80})
				e.duration = 0
				for _, ps in ipairs(e.particles) do game.level.map:removeParticleEmitter(ps) end
				e.particles = nil
				game:playSoundNear(self, "talents/fireflash")
				--I'll let map remove it
			end
			
		end)
		map_eff.name = t.name
		return true
	end,
	info = function(self, t)
		local delay = t.getDelay(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[After %d turns, the target area in (radius %d) is blasted with a beam of light, dealing %0.2f damage and lighting the area]]):
		tformat(delay, radius, damDesc(self, DamageType.LIGHT, damage))
		
	end,
}

newTalent{
	name = "Lightspeed",
	type = {"celestial/sol", 4},
	require = divi_req4,
	points = 5,
	cooldown = 45,
	fixed_cooldown = true,
	positive = 25,
	tactical = { BUFF = 1, ESCAPE = 1}, --instant will already make it have high priority
	range = 0,
	no_energy = true,
	requires_target = false,
	on_pre_use_ai = function(self, t, silent, fake) -- don't waste out of combat or out of range
		if self.ai_target.actor and (core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y) <= 7 or self.ai_state.tactic == "escape") then return true end
	end,
	getTurn = function(self, t) return self:combatTalentScale(t, 0.5, 1.0, "log") end, -- be careful with these "gain a turn" talents. a randboss with this can be devastating
	action = function(self, t)
		self.energy.value = self.energy.value + (t.getTurn(self, t) * game.energy_to_act)
		game.logSeen(self, "%s moves at light speed!", self:getName():capitalize())
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		local turn = t.getTurn(self, t)
		return ([[Instantly gain %d%% percent of a turn.]]):
		tformat(turn * 100)
	end,
}


