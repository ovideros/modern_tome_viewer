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
	name = "Massive Physique",
	type = {"steamtech/blacksmith",1},
	require = str_steamreq1,
	points = 5,
	mode = "passive",
	getStats = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 17, 0.75)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inc_stats", {
			[self.STAT_STR] = t.getStats(self, t),
			[self.STAT_CON] = t.getStats(self, t),
		})
		if self:getTalentLevelRaw(t) >= 5 then
			self:talentTemporaryValue(p, "size_category", 1)
		end
	end,
	info = function(self, t)
		return ([[Working iron has honed your body into an amazing shape, granting %d strength and constitution.
		At talent level 5, you are so incredibly built that you gain one size category.]])
		:tformat(t.getStats(self, t))
	end,
}

newTalent{
	name = "Endless Endurance",
	type = {"steamtech/blacksmith",2},
	require = str_steamreq2,
	points = 5,
	mode = "passive",
	getHealmod = function(self, t) return self:combatTalentScale(t, 0.04, 0.175) end,
	getRegen = function(self, t) return self:combatTalentScale(t, 3, 7.5) end,
	getPin = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.5, false, 1.2) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "healing_factor", t.getHealmod(self, t))
		self:talentTemporaryValue(p, "life_regen", t.getRegen(self, t))
		self:talentTemporaryValue(p, "pin_immune", t.getPin(self, t))
	end,
	info = function(self, t)
		return ([[Working long hours at a forge has made you incredibly slow to tire and given you endless vitality.
		Your healing factor is increased by %d%% and your life regeneration by %0.2f.
		Stopping you is nearly impossible; your pinning resistance is increased by %d%%.]])
		:tformat(t.getHealmod(self, t)*100, t.getRegen(self, t), t.getPin(self, t)*100)
	end,
}

newTalent{
	name = "Life in the Flames",
	type = {"steamtech/blacksmith",3},
	require = str_steamreq3,
	points = 5,
	mode = "passive",
	getFireRes = function(self, t) return self:combatTalentScale(t, 3.5, 22) end,
	getPhysRes = function(self, t) return self:combatTalentScale(t, 2, 17.5) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 5 then self:attr("ignore_fireburn", 1) end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 4 then self:attr("ignore_fireburn", -1) end
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists", {
			[DamageType.FIRE] = t.getFireRes(self, t),
			[DamageType.PHYSICAL] = t.getPhysRes(self, t),
		})
	end,
	info = function(self, t)
		return ([[Slaving for many years at the forge has made you more resilient to physical pain and fire burns.
		Your fire resistance is increased by %d%% and your physical resistance by %d%%.
		At talent level 5, you are so accustomed to the flames that you become immune to the fireburn effect.]])
		:tformat(t.getFireRes(self, t), t.getPhysRes(self, t))
	end,
}

newTalent{
	name = "Craftsman's Eye", short_name = "CRAFTS_EYE",
	type = {"steamtech/blacksmith",4},
	require = str_steamreq4,
	no_npc_use = true,
	points = 5,
	mode = "passive",
	getAPR = function(self, t) return math.floor(self:combatTalentScale(t, 4, 14)) end,
	getCritMult = function(self, t) return self:combatTalentScale(t, 3.5, 22) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_apr", t.getAPR(self, t))
		self:talentTemporaryValue(p, "combat_critical_power", t.getCritMult(self, t))
		if self:getTalentLevel(t) >= 5 then
			self:talentTemporaryValue(p, "blind_fight", 1)
		end
	end,
	info = function(self, t)
		return ([[You can easily see the weak points in your enemy's defenses. After all, you know to look for the same flaws in your own work.
		This grants %d armour penetration and %d%% critical strike multiplier.
		At talent level 5, you can also fight stealthed and invisible creatures without penalty.]])
		:tformat(t.getAPR(self, t), t.getCritMult(self, t))
	end,
}
