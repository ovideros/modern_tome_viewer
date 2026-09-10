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

local newInscription = function(t)
	-- Warning, up that if more than 5 inscriptions are ever allowed
	for i = 1, 6 do
		local tt = table.clone(t)
		tt.short_name = tt.name:upper():gsub("[ ]", "_").."_"..i
		tt.display_name = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{t.name, " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return t.name
			end
		end
		if not tt.no_cooldown then
			tt.cooldown = function(self, t)
				local data = self:getInscriptionData(t.short_name)
				return data.cooldown
			end
		else
			tt.no_cooldown = nil
			tt.cooldown = nil
		end
		tt.old_info = tt.info
		tt.info = function(self, t)
			local ret = t.old_info(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.use_stat and data.use_stat_mod then
				ret = ret..("\nIts effects scale with your %s stat."):tformat(self.stats_def[data.use_stat].name)
			end
			return ret
		end
		if not tt.image then
			tt.image = "talents/"..(t.short_name or t.name):lower():gsub("[^a-z0-9_]", "_")..".png"
		end
		tt.no_unlearn_last = true
		tt.is_inscription = true
		newTalent(tt)
	end
end

-----------------------------------------------------------------------
-- Implants
-----------------------------------------------------------------------
newInscription{
	name = "Implant: Steam Generator",
	type = {"inscriptions/implants", 1},
	points = 1,
	steam = 0,
	tactical = { STEAM = 2 },
	on_pre_use = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return self:getSteam() <= self:getMaxSteam() - ((data.power + data.inc_stat) * 5) / 2
	end,
	on_learn = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		if not data.newmode then self:attr("steam_regen", data.power + data.inc_stat) end
		self:attr("steam_generator_nb", 1)
	end,
	on_unlearn = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		if not data.newmode then self:attr("steam_regen", -(data.power + data.inc_stat)) end
		self:attr("steam_generator_nb", -1)
	end,
	passives = function(self, t, p)
		local data = self:getInscriptionData(t.short_name)
		if not data.newmode then return end

		self:talentTemporaryValue(p, "steam_regen", data.power + data.inc_stat)
	end,
	callbackOnStatChange = function(self, t, stat, v)
		local data = self:getInscriptionData(t.short_name)
		if not data.newmode then return end
		self:updateTalentPassives(t.id)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:incSteam((data.power + data.inc_stat) * 5)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Steam generator that permanently creates %0.1f steam per turn.
		Can be activated for an instant burst of %d steam.]]):tformat(data.power + data.inc_stat, (data.power + data.inc_stat) * 5)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[steam %d]]):tformat(data.power + data.inc_stat)
	end,
}

newInscription{
	name = "Implant: Medical Injector",
	type = {"inscriptions/implants", 1},
	points = 1,
	cooldown = 0,
	no_energy = true,
	no_npc_use = true,
	cooldownStart = function(self, t)
		local bt = self:getTalentFromId(self.T_GLOBAL_MEDICAL_CD)
		bt.cooldownStart(self, bt)
	end,
	on_learn = function(self, t)
		self:addMedicalInjector(t)
	end,
	on_unlearn = function(self, t)
		self:removeMedicalInjector(t)
	end,
	action = function(self, t)
		game.bignews:saySimple(120, "#LIGHT_BLUE#Medical injector selected to be used first by salves.")
		game.logPlayer(self, "This medical injector will now be used first if available when using medical salves.")
		self:setFirstMedicalInjector(t)
		return false
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Medical injector allows using therapeutics with %d%% efficiency and cooldown mod of %d%%.]])
		:tformat(data.power + data.inc_stat, data.cooldown_mod)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[efficiency %d%% / cooldown %d%%]]):tformat(data.power + data.inc_stat, data.cooldown_mod)
	end,
}
