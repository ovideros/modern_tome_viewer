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
	name = "Vaporous Step",
	type = {"psionic/psionic-fog", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "sustained", no_sustain_autoreset = true,
	sustain_psi = 18,
	drain_steam = 1,
	cooldown = 12,
	no_energy = true,
	range = 7,
	no_npc_use = true,
	is_steam = true,
	requires_target = true,
	radius = 4,
	target = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false, default_target=self, friendlyblock = false, nowarning=true}
		return tg
	end,
	getMaxCharge = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 25, 200) * 0.75 end,
	callbackOnRest = function(self, t) game:onTickEnd(function() local p = self:isTalentActive(t.id) if p then p.cancel = true self:forceUseTalent(t.id, {ignore_cooldown=true, ignore_energy=true}) end end) end,
	callbackOnRun = function(self, t) game:onTickEnd(function() local p = self:isTalentActive(t.id) if p then p.cancel = true self:forceUseTalent(t.id, {ignore_cooldown=true, ignore_energy=true}) end end) end,
	callbackOnChangeLevel = function(self, t, what, zone, level) if what == "leave" then local p = self:isTalentActive(t.id) if p then p.cancel = true self:forceUseTalent(t.id, {ignore_cooldown=true, ignore_energy=true}) end end end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id) if not p then return end
		p.charge = math.min(p.charge + 1, t.getMaxCharge(self, t))
	end,
	iconOverlay = function(self, t, p)
		local val = p.charge or 0
		if val <= 0 then return "" end
		local fnt = "buff_font_small"
		return tostring(math.ceil(val)), fnt
	end,
	activate = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		local ret = {x=x, y=y, charge=0}

		ret.p1 = game.level.map:particleEmitter(x, y, 2, "naga_portal_smoke", {smoke="particles_images/smoke_whispery_bright"})
		ret.p2 = game.level.map:particleEmitter(x, y, 2, "naga_portal_smoke", {smoke="particles_images/smoke_heavy_bright"})
		ret.p3 = game.level.map:particleEmitter(x, y, 2, "naga_portal_smoke", {smoke="particles_images/smoke_dark"})

		game:playSoundNear(self, "talents/fire")
		return ret
	end,
	deactivate = function(self, t, p)
		game.level.map:removeParticleEmitter(p.p1)
		game.level.map:removeParticleEmitter(p.p2)
		game.level.map:removeParticleEmitter(p.p3)
		if self:attr("save_cleanup") then return true end

		if game.level.map(p.x, p.y, Map.ACTOR) then p.cancel = true end
		if not self:hasLOS(p.x, p.y) then p.cancel = true end

		if not p.cancel then
			local ox, oy = self.x, self.y
			self:teleportRandom(p.x, p.y, 0)

			local tg = {type="ball", radius=4, talent=t, selffire=false, start_x=ox, start_y=oy}
			local dam = self:steamCrit(t.getDamage(self, t))
			local mult = 1
			for i = 1, p.charge do mult = mult * (1 - 0.33) end
			dam = dam * (2 - mult)
			self:project(tg, ox, oy, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				DamageType:get(DamageType.FIRE).projector(self, px, py, DamageType.FIRE, dam)
				target:setEffect(target.EFF_WET, 4, {apply_power=self:combatMindpower()})
			end)
			game.level.map:particleEmitter(ox, oy, 4, "vapour_explosion", {radius=4, smoke="particles_images/smoke_whispery_bright"})
			game.level.map:particleEmitter(ox, oy, 4, "vapour_explosion", {radius=4, smoke="particles_images/smoke_heavy_bright"})
			game.level.map:particleEmitter(ox, oy, 4, "vapour_explosion", {radius=4, smoke="particles_images/smoke_dark"})
			game.level.map:particleEmitter(ox, oy, 4, "fireflash", {radius=4})

			if self:knowTalent(self.T_INHALE_VAPOURS) then self:callTalent(self.T_INHALE_VAPOURS, "onVaporousStep", p.charge) end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You concentrate your will to psychoport some of the steam of your generator to a remote location. Each turn steam accumulates there, up to %d charges.
		When you deactivate the effect you release the accumulated psionic and steam energies, instantly switching places with the target location and releasing the charges in a fiery explosion of hot wet steam in radius 4.
		The explosion will do %0.2f fire damage, multiplied by 33%% (diminutive) for each charge and apply the wet effect.
		The effect will fizzle if the charged grid is currently occupied by a creature or not in sight.
		The damage will increase with your Steampower.]]):
		tformat(t.getMaxCharge(self, t), damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Inhale Vapours",
	type = {"psionic/psionic-fog", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "passive",
	no_npc_use = true, -- not possible for NPCs to benefit from because Vaporous Step is banned
	is_heal = true,
	getSteam = function(self, t) return (self:combatTalentScale(t, 10, 70)) / 2 end,
	getHeal = function(self, t) return (40 + self:combatTalentMindDamage(t, 10, 520)) / 2 end,
	onVaporousStep = function(self, t, charge)
		local mult = 1
		for i = 1, charge do mult = mult * (1 - 0.33) end
		mult = 2 - mult

		self:attr("allow_on_heal", 1)
		self:heal(t.getHeal(self, t) * mult, self)
		self:attr("allow_on_heal", -1)

		self:incSteam(t.getSteam(self, t) * mult)
	end,
	info = function(self, t)
		return ([[When you deactivate Vaporous Step, if the psychoport succeeds you inhale some of the vapours, regenerating %d steam and %d life.
		The effects will be multiplied by 33%% (diminutive) for each charge of Vaporous Step.
		The healing done will increase with your Mindpower.]]):
		tformat(t.getSteam(self, t), t.getHeal(self, t))
	end,
}

newTalent{
	name = "Psionic Fog",
	type = {"psionic/psionic-fog", 3},
	points = 5,
	require = psi_wil_req3,
	psi = 10,
	steam = 30,
	cooldown = 10,
	tactical = { ATTACKAREA = { MIND = 2 } },
	range = 8,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSearing = function(self, t) return self:combatTalentScale(t, 10, 30) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 75) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.PSIONIC_FOG, {dam=t.getDamage(self, t), sear=t.getSearing(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="vapour_spin", args={radius=1, smoke="particles_images/smoke_whispery_bright", density=2, sub_particle="vapour_spin", sub_particle_args={radius=1, smoke="particles_images/smoke_heavy_bright", density=2}}},
			nil, false, false
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Using the steam of your generators you shape it into a psionic fog that lasts %d turns. Any foes caught inside will take %0.2f damage per turn and be seared, reducing their fire resistance by %d%% and and mind save by %d.
		The damage will increase with your Mindpower.]]):
		tformat(duration, damDesc(self, DamageType.MIND, damage), t.getSearing(self, t), t.getSearing(self, t))
	end,
}

isOnPsionicFog = function(map, x, y)
	for i, e in ipairs(map.effects) do
		if e.damtype == DamageType.PSIONIC_FOG and e.grids[x] and e.grids[x][y] then return true end
	end
end

newTalent{
	name = "Uncertainty Principle",
	type = {"psionic/psionic-fog", 4},
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.max(3, math.ceil(self:combatTalentScale(t, 15, 7))) end,
	require = psi_wil_req4,
	callbackOnHit = function(self, t, cb, src, death_note)
		if not game.level.map or not isOnPsionicFog(game.level.map, self.x, self.y) then return end
		if self:isTalentCoolingDown(t) then return end
		if self.turn_procs.phase_shift then return end
		self.turn_procs.phase_shift = true

		local nx, ny = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if nx then
			local ox, oy = self.x, self.y
			self:move(nx, ny, true)
			game.level.map:particleEmitter(ox, oy, math.max(math.abs(nx-ox), math.abs(ny-oy)), "lightning", {tx=nx-ox, ty=ny-oy})
			game:delayedLogDamage(src or {}, self, 0, ("#STEEL_BLUE#(%d quantum shifted)#LAST#"):tformat(cb.value), nil)
			cb.value = 0
			self:startTalentCooldown(t)
			return true
		end
	end,
	info = function(self, t)
		return ([[While inside a psionic fog the quantum state of space is warped by your powerful tech-augmented psionic powers.
		When you would get hit you instead find yourself in an adjacent location.
		This effect has a cooldown.]]):
		tformat()
	end,
}
