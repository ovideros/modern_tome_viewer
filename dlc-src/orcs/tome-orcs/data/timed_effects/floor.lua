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
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

local function floorEffect(t)
	t.name = t.name or t.desc
	t.name = t.name:upper():gsub("[ ']", "_")
	local d = t.long_desc
	if type(t.long_desc) == "string" then t.long_desc = function() return d end end
	t.type = "other"
	t.subtype = { floor=true }
	t.status = "neutral"
	t.parameters = {}
	t.on_gain = function(self, err) return nil, "+"..t.desc end
	t.on_lose = function(self, err) return nil, "-"..t.desc end

	newEffect(t)
end

floorEffect{
	desc = _t"Warm", name = "CAMPFIRE", image = "talents/wildfire.png",
	long_desc = _t"The target is warm from the campfire. Increasing steam regeneration by 6/turn, stun immunity by 30% and stamina regeneration by 4/turn.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stamina_regen", 4)
		self:effectTemporaryValue(eff, "steam_regen", 6)
		self:effectTemporaryValue(eff, "stun_immune", 0.3)
	end,
}

floorEffect{
	desc = _t"Sun Radiance", name = "SUNWELL", image = "effects/zone_aura_fire.png",
	long_desc = _t"The target is under the effect of the sun. Increasing lite and sight radius by 2, blindness immunity by 30%, stealth seeing by 20 and light resistance by 30%.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "lite", 2)
		self:effectTemporaryValue(eff, "sight", 2)
		self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT] = 30})
		self:effectTemporaryValue(eff, "blind_immune", 0.3)
		self:effectTemporaryValue(eff, "see_stealth", 20)
	end,
}

floorEffect{
	desc = _t"Moon Radiance", name = "MOONWELL", image = "effects/zone_aura_out_of_time.png",
	long_desc = _t"The target is under the effect of the moons. Decreasing lite and sight radius by 1, increasing stun immunity by 30%, granting 10 stealth and darkness resistance by 30%.",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "lite", -1)
		self:effectTemporaryValue(eff, "sight", -1)
		self:effectTemporaryValue(eff, "resists", {[DamageType.DARKNESS] = 30})
		self:effectTemporaryValue(eff, "stun_immune", 0.3)
		self:effectTemporaryValue(eff, "stealth", 10)
	end,
}
