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

newTalent{
	name = "Molten Iron Blood",
	type = {"steamtech/thoughts-of-iron", 1},
	points = 5,
	cooldown = 10,
	mode = "sustained",
	require = steamreq1,
	tactical = { BUFF=2 },
	requires_target = true,
	range = 10,
	drain_steam = 4, -- 1 less than starting steam generator
	getSplash = function(self, t) return self:combatTalentSteamDamage(t, 2, 50) end,
	getReduction = function(self, t) return self:combatTalentLimit(t, 40, 5, 25) end,
	getResists = function(self, t) return self:combatTalentLimit(t, 40, 5, 20) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "on_melee_hit", {[DamageType.FIRE] = t.getSplash(self, t)})
		self:talentTemporaryValue(ret, "resists", {all=t.getResists(self, t)})
		self:talentTemporaryValue(ret, "reduce_detrimental_status_effects_time", t.getReduction(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Using psionic energies you temporarily alter your blood, turning it into molten iron.
		When affected by molten blood all creatures that hit you in melee take %0.2f fire damage, all your resistances are increased by %d%% and all new detrimental effects on you have their duration reduced by %d%%.
		Damage increases with your Steampower.
		]]):tformat(damDesc(self, DamageType.FIRE, t.getSplash(self, t)), t.getResists(self, t), t.getReduction(self, t))
	end,
}

newTalent{
	name = "Mind Drones",
	type = {"steamtech/thoughts-of-iron", 2},
	points = 5,
	require = steamreq2,
	cooldown = 12,
	steam = 30,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 2, 240) end,
	tactical = { DISABLE = 1 },
	range = 10,
	reflectable = true,
	proj_speed = 2,
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, selffire=false, display={display=' ', particle="arrow", particle_args={tile="shockbolt/npc/mechanical_drone_mind_drone"}}}
	end,
	getFail = function(self, t) return self:combatTalentLimit(t, 50, 19, 35) end, -- Limit < 50%
	getReduction = function(self, t) return self:combatTalentLimit(t, 70, 25, 65) end, -- Limit < 50%
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local lx, ly
		local a = math.atan2(y - self.y, x - self.x) + math.pi / 2
		local l = core.fov.line(self.x, self.y, self.x + 10 * math.cos(a), self.y + 10 * math.sin(a))
		local nb = 0
		while nb < 2 do
			lx, ly = l:step() if not lx then break end
			local tg = self:getTalentTarget(t)
			tg.start_x = lx
			tg.start_y = ly
			self:projectile(tg, x, y, DamageType.MIND_DRONE, {dam=0, fail=t.getFail(self, t), reduction=t.getReduction(self, t)})
			nb = nb + 1
		end
		a = a + math.pi
		nb = 0
		local l = core.fov.line(self.x, self.y, self.x + 10 * math.cos(a), self.y + 10 * math.sin(a))
		while nb < 2 do
			lx, ly = l:step() if not lx then break end
			local tg = self:getTalentTarget(t)
			tg.start_x = lx
			tg.start_y = ly
			self:projectile(tg, x, y, DamageType.MIND_DRONE, {dam=0, fail=t.getFail(self, t), reduction=t.getReduction(self, t)})
			nb = nb + 1
		end
		local tg = self:getTalentTarget(t)
		self:projectile(tg, x, y, DamageType.MIND_DRONE, {dam=0, fail=t.getFail(self, t), reduction=t.getReduction(self, t)})

		return true
	end,
	info = function(self, t)
		return ([[Melding psionics with steamtech you create 5 mind drones at your sides that fly towards your target.
		If they encounter a creature they will latch on it and bore into its skull for 6 turns, disrupting its thoughts.
		Disrupted creatures have %d%% chances to fail to use talents and suffer a -%d%% reduction to fear and sleep immunity.]]):
		tformat(t.getFail(self, t), t.getReduction(self, t))
	end,
}

newTalent{
	name = "Psionic Mirror",
	type = {"steamtech/thoughts-of-iron", 3},
	points = 5,
	cooldown = 20,
	steam = 30,
	require = steamreq3,
	tactical = { CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "mental" then nb = nb + 1 end
		end
		return nb
	end},
	no_energy = true,
	requires_target = true,
	range = 5,
	getNum = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	action = function(self, t)

		-- Pick valid targets for transfer attempt
		local tgts = {}
		self:project({type="ball", radius=5}, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) >= 0 then return end
			tgts[#tgts+1] = act
		end)

		-- Transfer the debuffs before they're removed in the filter function
		local cleansed = self:removeEffectsFilter(self, function(eff)
			if eff.status == "detrimental" and eff.type == "mental" then
				if #tgts > 0 then
					local target = rng.table(tgts)
					self:cloneEffect(eff.id, target, {apply_power = self:combatSteampower()})

					-- local newp = self:copyEffect(eff.id)
					-- newp.src = self
					-- newp.apply_power = self:combatSteampower()
					-- target:setEffect(eff.id, newp.dur, newp)
				end
				return true
			else
				return false
			end
		end, t.getNum(self, t))
		
		return true
	end,
	info = function(self, t)
		return ([[You cleanse your mind of %d mental debuffs.
		Cleansed effects will be randomly sent to closeby foes (range 5, subject to a mental save).]])
		:tformat(t.getNum(self, t))
	end,
}

newTalent{
	name = "Mind Injection",
	type = {"steamtech/thoughts-of-iron", 4},
	points = 5,
	require = steamreq4,
	cooldown = 0,
	no_npc_use = true,
	getPower = function(self, t) return math.floor(60 + self:combatTalentScale(t, 10, 50)) end,
	getCooldownMod = function(self, t) return math.floor(140 - self:combatTalentLimit(t, 60, 5, 45)) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then self:addMedicalInjector(t) end
		self.inscriptions_data.MIND_INJECTION = {
			power = t.getPower(self, t),
			cooldown_mod = t.getCooldownMod(self, t),
			cooldown = 1,
		}
	end,
	on_unlearn = function(self, t)
		self.inscriptions_data.MIND_INJECTION = {
			power = t.getPower(self, t),
			cooldown_mod = t.getCooldownMod(self, t),
			cooldown = 1,
		}
		if self:getTalentLevelRaw(t) == 0 then self:removeMedicalInjector(t) self.inscriptions_data.MIND_INJECTION = nil end
	end,
	action = function(self, t)
		game.bignews:saySimple(120, "#LIGHT_BLUE#Mind Injection selected to be used first by salves.")
		game.logPlayer(self, "This medical injector will now be used first if available when using medical salves.")
		self:setFirstMedicalInjector(t)
		return false
	end,
	info = function(self, t)
		local faked = false
		if not self.inscriptions_data.MIND_INJECTION then self.inscriptions_data.MIND_INJECTION = {power=t.getPower(self, t), cooldown_mod=t.getCooldownMod(self, t), cooldown=1} faked = true end
		local data = self:getInscriptionData(t.short_name)
		if faked then self.inscriptions_data.MIND_INJECTION = nil end
		return ([[By using a direct psionic link to your body you can use even more therapeutics. This talent acts as an extra medical injector with %d%% efficiency and %d%% cooldown mod.]])
		:tformat(t.getPower(self, t), t.getCooldownMod(self, t))
	end,
}
