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

local Stats = require "engine.interface.ActorStats"

load("/data/general/objects/cloth-armors.lua")
load("/data/general/objects/misc-tools.lua")

newEntity{ base = "BASE_CLOTH_ARMOR", define_as = "ROBE_OF_THE_WORM",
	name = "Robe of the Worm", short_name = "worm", cosmetic=true, image = "object/robe_of_the_worm.png",
	moddable_tile = "cults/robe_of_the_worm", 
	level_range = {1, 50},
	cost = 1,
	special = 1,
	material_level = 1, material_level_min_only = true,
	special_desc = function(self, who) if self.wtw_can_takeoff or not who.is_wtw_buddy then return end return "Must level Worm that Walks talent on the master to take it off." end,
	on_cantakeoff = function(self, who)
		if self.wtw_can_takeoff or not who.is_wtw_buddy then
			self.on_cantakeoff = nil
			return false
		end
		return true
	end,
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	name = "Rags of the Sanctuary", short_name = "rags", cosmetic=true, image = "object/rags.png",
	moddable_tile = "cults/cults_shirt", 
	moddable_tile2 = "cults/cults_pants", 
	level_range = {1, 50},
	cost = 1,
	material_level = 1, material_level_min_only = true,
}

newEntity{ base = "BASE_TOOL_MISC", define_as = "SPACE_DWARF_TRINKET",
	power_source = {unkown=true},
	unique=true,
	type = "misc", subtype="tool",
	name = "Bizzare Contraption", image = "object/artifact/bizzare_contraption.png",
	unided_name = _t"bizzare contraption",
	color = colors.GREY,
	level_range = {1, 50},
	desc = _t[[This strange device appears to be entirely mechanical in nature, but you cannot understand how any of the components are supposed to work. There does appear to be some sort of metallic grid in its side which sometimes emits strange noises.]],
	cost = 320,
	material_level = 2,
	wielder = {
		resists={[DamageType.LIGHTNING] = 15,},
		inc_damage={[DamageType.LIGHTNING] = 15,},
		combat_physresist = 18,
		inc_stats = {[Stats.STAT_CUN] = 8,},
	},
	special_desc = function(self) if not self.helper_mode then return end return _t"10% chance when hit to absorb the whole blow. This effect has a 30 turn cooldown." end,
	max_power = 30, power_regen = 1,
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state)
		if not self.helper_mode then return end
		if self.power < self.max_power then return end
		if not rng.percent(10) or dam < 1 then return end
		if not who:findInAllWornInventoriesByObject(true, self) then return end -- Only when worn, we need to check because we used carrier_callbacks
		self.power = 0
		game.logSeen(who, "The Bizzare Contraption fully absorbs the blow (%0.2f damage absorbed).", dam)
		return {dam=0}
	end,
	on_wear = function(self, who)
		if self.helper_mode then
			self:specialWearAdd({"wielder","resists"}, {all = 7,})
			self:specialWearAdd({"wielder","combat_mentalresist"}, 18)
			self:specialWearAdd({"wielder","inc_stats"}, {[who.STAT_CON] = 5, [who.STAT_STR] = 5, [who.STAT_WIL] = 5})
			game.logPlayer(who, "#{italic}##LIGHT_GREEN#Enabling protective electromagnetic barrier and real time health monitoring.#{normal}#")
		end
	end,

	carrier_callbacks = true,
	callbackOnChangeLevel = function(self, who, what, zone, level)
		if not self.done_dialog and what == "enter" and zone.short_name == "wilderness" then
			self.done_dialog = true
			local chat = require("engine.Chat").new("cults+space-dwarf-trinket", self, who)
			chat:invoke()
		end
	end,
}

newEntity{
	define_as = "FANGED_COLLAR_HEAD",
	slot = "HEAD",
	type = "armor", subtype="head",
	display = "]", color=colors.BLUE, image = "",
	moddable_tile = "cults/fanged_collar_head",
	encumber = 0,
	name = "Fanged Collar",
	desc = _t[[It's a head... but is it yours?]],
	level_range = {1, 50},
	cost = 0,
	unique = "Fanged Collar Head", no_unique_lore = true,
	power_source = {unkown=true},
	material_level = 4,
	on_cantakeoff = function(self, who)
		return true
	end,
}
