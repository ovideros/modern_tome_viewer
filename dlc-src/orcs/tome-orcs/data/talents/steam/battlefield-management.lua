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
	name = "Saw Wheels", short_name="SAWWHEELS",
	type = {"steamtech/battlefield-management",1},
	require = str_steamreq1,
	points = 5,
	drain_steam = 5,
	cooldown = 7,
	mode = "sustained",
	no_npc_use = true,
	tactical = { ESCAPE = 3, CLOSEIN = 3 },
	no_energy = true,
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	iconOverlay = function(self, t, p)
		local val = math.ceil(100 * (p.charges or 0) * 0.2)
		if val <= 0 then return "" end
		return tostring(math.ceil(val)).."%", "buff_font_smaller"
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		if not moved or force or (ox == self.x and oy == self.y) then return end

		local dir = util.getDir(ox, oy, self.x, self.y) or 6
		local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
		local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
		local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		if lt and self:reactionToward(lt) < 0 and lt:canBe("knockback") then
			lt:knockback(self.x, self.y, 3)
		end
		if rt and self:reactionToward(rt) < 0 and rt:canBe("knockback") then
			rt:knockback(self.x, self.y, 3)
		end

		local p = self:isTalentActive(t.id)
		if p then
			p.charges = util.bound((p.charges or 0) + 1, 0, 5)
		end
	end,
	callbackBreakOnTalent = function(self, t, bt)
		if t.id == bt.id then return end
		self:forceUseTalent(t.id, {ignore_energy=true})
	end,
	getSpeed = function(self, t) return (100 + self:combatTalentSteamDamage(t, 50, 320)) * (1 + (self:attr("sawwheel_speed") or 0)) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "movement_speed", t.getSpeed(self, t)/100)
		return ret
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		if self.turn_procs.resetting_talents then return true end

		local add_dam = 0
		if self:knowTalent(self.T_BATTLEFIELD_VETERAN) then
			add_dam = self:callTalent(self.T_BATTLEFIELD_VETERAN, "getSawwheelDamage") / 100
		end
		if p.charges then
			self:project({type="ball", selffire=false, radius=1} , self.x, self.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					self:attackTarget(target, nil, (self:combatTalentWeaponDamage(t, 1, 2) + add_dam) * (p.charges * 0.2), true)
				end
			end)
			self:addParticles(Particles.new("meleestorm", 1, {img="spinningwinds_black"}))
		end
		return true
	end,
	info = function(self, t)
		return ([[Firmly plant your steamsaws in the ground, using them to propel yourself very quickly (+%d%% movement speed).
		Any foes on either side of your movement get wrecked by the saws, knocking them 3 tiles away from you.
		Attacking or using any talent will break this effect.
		When this effect is broken or cancelled the sudden change in motion deals %d%% weapon damage to all foes around you. To do full damage you need to have moved at least 5 times, otherwise damage is lower (or null for no movement).
		#{italic}#The wheels of death! Amazing!#{normal}#]]):
		tformat(t.getSpeed(self, t), self:combatTalentWeaponDamage(t, 1, 2) * 100)
	end,
}

newTalent{
	name = "Grinding Shield",
	type = {"steamtech/battlefield-management",2},
	require = str_steamreq2,
	points = 5,
	cooldown = 5,
	drain_steam = 3,
	mode = "sustained",
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	getEvasion = function(self, t) return self:combatTalentLimit(t, 50, 12, 25), 1 end,
	getFlatMax = function(self, t) return self:combatTalentLimit(t, 50, 100, 70), 1 end,
	callbackOnHit = function(self, t, val, src, death_note)
		if src and src.x and src.y and self.x and self.y and core.fov.distance(self.x, self.y, src.x, src.y) > 1 then return end
		local ev, spread = t.getEvasion(self, t)
		val.value = val.value * (100 - ev) / 100
		return true
	end,
	activate = function(self, t)
		local ret = {}
		local ev, spread = t.getEvasion(self, t)
		self:talentTemporaryValue(ret, "projectile_evasion", ev)
		self:talentTemporaryValue(ret, "projectile_evasion_spread", spread)
		self:talentTemporaryValue(ret, "flat_damage_cap", {all = t.getFlatMax(self, t)})
		if self:knowTalent(self.T_BATTLEFIELD_VETERAN) then
			self:talentTemporaryValue(ret, "die_at", -self:callTalent(self.T_BATTLEFIELD_VETERAN, "getLife"))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local ev, spread = t.getEvasion(self, t)
		local flat = t.getFlatMax(self, t)
		return ([[Spin your saws wildly around you to create a wall of steamy sawteeth.
		All melee damage against you is reduced by %d%%, you have %d%% chance to evade projectiles and you can never take a blow that deals more than %d%% of your max life.
		#{italic}#Split their bones on the saws of death!#{normal}#]])
		:tformat(ev, ev, flat)
	end,
}

-- Core highest damage potential strike
newTalent{
	name = "Punishment",
	type = {"steamtech/battlefield-management",3},
	require = str_steamreq3,
	points = 5,
	cooldown = 10,
	steam = 30,
	requires_target = true,
	getBonus = function(self, t) return self:combatTalentLimit(t, 60, 10, 30) end,
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	tactical = { ATTACK = 1, },
	action = function(self, t)
		local weapon = self:hasWeaponType("steamsaw")
		if not weapon then return nil end
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local effs = target:effectsFilter({types={physical=true, magical=true, mental=true}}, 10)

		local nb = math.min(7, #effs)
		local bonus = (t.getBonus(self, t) * nb)
		game.logSeen(self, "#CRIMSON#%s unleashes a punishing strike for %d%% bonus damage!", self:getName(), bonus )
		
		local hit = self:attackTarget(target, nil, 1 + (bonus / 100), true)
		if hit then
			if nb > 0 and self:knowTalent(self.T_BATTLEFIELD_VETERAN) then
				local reduc = 0
				for i = 1, nb do if rng.percent(self:callTalent(self.T_BATTLEFIELD_VETERAN, "getChance")) then
					reduc = reduc + 1
				end end
				if reduc > 0 then game:onTickEnd(function() self:alterTalentCoolingdown(t.id, -reduc) end) end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Slam your saws into your target, dealing 100%% weapon damage + %d%% per physical, magical, or mental effect on them (up to 7 effects).
			Sustains are not effects.
		#{italic}#The Metal Punisher!#{normal}#]]):
		tformat(t.getBonus(self, t))
	end,
}

-- Needs new bonus for Saw Wheels
newTalent{
	name = "Battlefield Veteran",
	type = {"steamtech/battlefield-management",4},
	require = str_steamreq4,
	points = 5,
	mode = "passive",
	getSawwheelDamage = function(self, t) return math.floor(self:combatTalentScale(t, 10, 30)) end,
	getChance = function(self, t) return math.min(100, math.floor(self:combatTalentScale(t, 30, 85))) end,
	getLife = function(self, t) return math.floor(self:combatTalentScale(t, 60, 250)) end,
	info = function(self, t)
		return ([[You have lived through many battles, and your experience makes you a gritty veteran.
		Saw Wheels end of effect attack increased by %d%%.
		Grinding Shield lets you live below your normal limits, up to -%d life.
		Punishment has a %d%% chance to have its cooldown reduced by 1 for each effect.
		#{italic}#Domination for all!#{normal}#]]):
		tformat(t.getSawwheelDamage(self, t), t.getLife(self, t), t.getChance(self, t))
	end,
}
