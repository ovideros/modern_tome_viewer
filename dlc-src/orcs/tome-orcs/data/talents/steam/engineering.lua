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
	name = "Emergency Steam Purge",
	type = {"steamtech/engineering",1},
	require = steamreq1,
	points = 5,
	cooldown = 15,
	steam = function(self, t) return math.min(self:getSteam(), 50) end,
	tactical = { DISABLE = 2, ATTACKAREA = { FIRE = 2 } },
	range = 0,
	radius = 3,
	getFactor = function(self, t) return self:combatScale(math.min(self:getSteam(), 50), 15, 0, 50, 50, 1) / 50 end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 330) * t.getFactor(self, t) end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4.5) * t.getFactor(self, t)) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t} end,
	tactical = {ATTACKAREA = {FIRE = function(self, t, aitarget)
			return 2*(math.min(self.steam/200, 1))
		end},
		DISABLE = function(self, t, aitarget)
			return self.steam >= 35 and {blind=2} or nil
		end,
	},
	requires_target = true,
	action = function(self, t)
		local tg = t.target(self, t)
		self:project(tg, self.x, self.y, DamageType.FIRE, t.getDamage(self, t))
		if self:getSteam() >= 35 then self:project(tg, self.x, self.y, DamageType.BLIND, t.getDur(self, t)) end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "fireflash", {radius=tg.radius})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[You open all steam valves at once, releasing a radius %d wave of superheated steam around yourself which deals %0.2f fire damage (but can not be a critical hit).
		If you had at least 35 steam, the vapours will be so hot that they can burn sensory organs, blinding affected creatures for %d turns.
		The effects scale with your current steam value; at 1 steam they are only 15%% as effective as at 50 or more (current factor %d%%).]])
		:tformat(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)), t.getDur(self, t), t.getFactor(self, t) * 100)
	end,
}

newTalent{
	name = "Innovation",
	type = {"steamtech/engineering",2},
	require = steamreq2,
	points = 5,
	mode = "passive",
	getFactor = function(self, t) return self:combatTalentScale(t, 4, 15) end,
	passives = function(self, t)
		if self and self.turn_procs.__innovation_recursive then
			return nil
		end
		game:onTickEnd(function()
			self:inventoryApplyAll(function(inven, item, o)
				if inven.worn then
					self.turn_procs.__innovation_recursive = true
					self:onTakeoff(o, inven.id, true)
					self:onWear(o, inven.id, true)
					self.turn_procs.__innovation_recursive = nil
				end
			end)
		end
		)
	end,
	info = function(self, t)
		return ([[Your knowledge of physical laws allows you to use and improve equipment in ways their creators never dreamed.
		Increases all stats, saves, armour, and defense bonuses by %d%% on equipment that is crafted by a master or powered by steamtech.]])
		:tformat(t.getFactor(self, t))
	end,
}

newTalent{
	name = "Supercharge Tinkers",
	type = {"steamtech/engineering",3},
	require = steamreq3,
	points = 5,
	cooldown = function(self, t) return t.getDur(self, t) end,
	steam = 60,
	no_energy = true,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.1, 5)) end,
	getBoost = function(self, t) return 20 + self:getTalentLevel(t) * 5, self:combatTalentScale(t, 5, 20, 0.75) end,
	tactical = {BUFF = 2},
	on_pre_use_ai = function(self, t, silent, fake) return self.steam >= 60 + math.max(30 - 2*self.steam_regen, 20) end,
	action = function(self, t)
		local pow, crit = t.getBoost(self, t)
		self:setEffect(self.EFF_SUPERCHARGE_TINKERS, t.getDur(self, t), {power=pow, crit=crit})
		return true
	end,
	info = function(self, t)
		return ([[Using a huge amount of steam, you temporarily supercharge your tinkers and other steam-powered talents.
		For %d turns, you gain %d steampower and %d%% steamtech critical chance.]])
		:tformat(t.getDur(self, t), t.getBoost(self, t))
	end,
}

newTalent{
	name = "Last Engineer Standing",
	type = {"steamtech/engineering",4},
	require = steamreq4,
	points = 5,
	mode = "passive",
	critResist = function(self, t) return self:combatTalentScale(t, 8, 25, 0.75) end,
	selfResist = function(self, t) return self:combatTalentLimit(t, 100, 18, 50) end,
	physSave = function(self, t) return self:combatTalentScale(t, 7, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inc_stats", { [self.STAT_CUN] = 2 * self:getTalentLevel(t) })
		self:talentTemporaryValue(p, "resists_self", { all = t.selfResist(self, t)})
		self:talentTemporaryValue(p, "combat_physresist", t.physSave(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
	end,
	info = function(self, t)
		return ([[Sometimes, being a master tinker requires taking risks; yours are more calculated than others.
		Gain %d cunning, %d physical save, %d%% resistance to self-inflicted damage, and %d%% chance to avoid being critically hit.]])
		:tformat(self:getTalentLevel(t) * 2, t.physSave(self, t), t.selfResist(self, t), t.critResist(self, t))
	end,
}
