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

local Trap = require "mod.class.Trap"
local Object = require "mod.class.Object"

newTalent{
	name = "Continuous Butchery",
	type = {"steamtech/automated-butchery",1},
	require = steamreq_high1,
	points = 5,
	steam = 15,
	cooldown = 12,
	tactical = { ATTACK = 2 },
	range = 1,
	no_energy = true,
	getInc = function(self, t) return math.ceil(self:combatTalentScale(t, 6, 17)) end,
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamsaw")
		if not weapon then return nil end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local inc = t.getInc(self, t)
		self:setEffect(self.EFF_CONTINUOUS_BUTCHERY, 5, {target=target, power_inc=inc, power=inc})
		return true
	end,
	info = function(self, t)
		return ([[You attune your saws to a specific target for 5 turns.
		Each time you strike this target all damage done with steamsaws (including by other talents) is increased by +%d%%.
		If you strike any other foe the bonus ends.
		#{italic}#Metal your foes to death!#{normal}#]]):
		tformat(t.getInc(self, t))
	end,
}

newTalent{
	name = "Explosive Saw",
	type = {"steamtech/automated-butchery",2},
	require = steamreq_high2,
	points = 5,
	cooldown = 11,
	steam = 35,
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 9)) end,
	tactical = { ATTACK = 1, CLOSEIN = 3 },
	requires_target = true,
	getDamP = function(self, t) return self:combatTalentSteamDamage(t, 5, 250) / 4 end,
	getDamF = function(self, t) return self:combatTalentSteamDamage(t, 15, 320) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			local dam = self:steamCrit(t.getDamP(self, t))
			local dam_final = self:steamCrit(t.getDamF(self, t))
			local silence = true

			if not target:canBe("silence") then silence = false end

			target:setEffect(target.EFF_EXPLOSIVE_WOUND, 4, {src=self, apply_power=self:combatSteampower(), power=dam, power_final=dam_final, silence=silence, range = t.range(self, t)})
		end)

		return true
	end,
	info = function(self, t)
		return ([[You send a saw mounted on an automated steam propulsor to assault a foe, dealing %0.2f physical damage each turn for 4 turns and silencing it.
		At the end of the duration, the saw explodes for %0.2f fire damage and flies back, pulling the target up to %d tiles towards you.
		The damage will increase with your Steampower.]]):
		tformat(damDesc(self, DamageType.PHYSICAL, t.getDamP(self, t)), damDesc(self, DamageType.FIRE, t.getDamF(self, t)), t.range(self, t))
	end,
}

newTalent{
	name = "Mow Down",
	type = {"steamtech/automated-butchery",3},
	require = steamreq_high3,
	points = 5,
	mode = "sustained",
	sustain_steam = 20,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 32) end,
	getRegen = function(self, t) return self:combatTalentScale(t, 3, 12) end,
	getDur = function(self, t) return self:combatTalentScale(t, 1, 4) end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if not target or not hitted then return end
		local chance = 0
		if crit then chance = t.getChance(self, t) end
		if target.dead then chance = 100 end
		if not rng.percent(chance) then return end

		game.level.map:particleEmitter(target.x, target.y, 1, "blood")
		self:incSteam(t.getRegen(self, t))

		self:project({type="ball", x=target.x, y=target.y, radius=4}, target.x, target.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) >= 0 then return end
			act:setEffect(act.EFF_BRAINLOCKED, t.getDur(self, t), {apply_power=self:combatSteampower()})
		end)
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[When you kill a foe with a melee strike you quickly throw some of their remains in your steam engine, instantly regenerating %d steam.
		When you deal a critical melee strike you also have a %d%% chance to cut a part of your foe and use it in your steam engine.
		When either of those happens this strikes fear in all foes in radius 4 of the victim, brainlocking them for %d turns.
		#{italic}#To the meat grinder!#{normal}#]]):
		tformat(t.getRegen(self, t), t.getChance(self, t), t.getDur(self, t))
	end,
}


newTalent{
	name = "Tech Overload",
	type = {"steamtech/automated-butchery",4},
	require = str_steamreq_high4,
	points = 5,
	steam = 20,
	cooldown = 50,
	fixed_cooldown = true,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return math.floor(self:combatTalentScale(t, 10, 40)) end,
	getTalentCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 7, "log")) end,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if not tt.fixed_cooldown then
				if tt.type[2] <= t.getMaxLevel(self, t) and tt.is_steam then
					tids[#tids+1] = tid
				end
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self:setEffect(self.EFF_TECH_OVERLOAD, 6, {regen=t.getIncrease(self, t) / 100})
		return true
	end,
	info = function(self, t)
		local inc = t.getIncrease(self, t)
		local talentcount = t.getTalentCount(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[You override all security measures of your tinkers, allowing you to reset the cooldown of %d of most of your steamtech talents of tier %d or less and instantly increases your steam level by %d%% of the maximum.
		In addition for 6 turns your maximum steam capacity is doubled, but steam regeneration is halved.
		#{italic}#Master of Tech, Master of Death!#{normal}#]]):
		tformat(talentcount, maxlevel, inc)
	end,
}

