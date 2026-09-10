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

newAchievement{
	name = "A Fist Full of Demons", id = "ASHES_DEMO", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Killed 1000 demons.]],
	mode = "world",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 1000 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
}

newAchievement{
	name = "Glory to the Fearscape", id = "ASHES_ALL_STATUES", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Activated all 23 different kinds of demon statues.]],
	mode = "world",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 23 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 23"} end,
}

newAchievement{
	name = "Well Seeded", id = "ASHES_SEED_500", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Created 500 demon seeds.]],
	mode = "world",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 500 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 500"} end,
}

newAchievement{
	name = "Demonic Party!", id = "ASHES_FULL_PARTY", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Have your party composed of at least 5 demons.]],
	mode = "player",
	can_gain = function(self, who, target)
		local nb = 0
		for i, actor in ipairs(game.party.m_list) do
			if (actor.type == "demon" or actor.subtype == "demon") then nb = nb + 1 end
		end
		if nb >= 5 then return true end
	end,
}

newAchievement{
	name = "Hell has no fury like a demon scorned!", id = "ASHES_ESCAPED", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Escaped the Searing Halls.]],
	mode = "player",
}

newAchievement{
	name = "Once bitten, twice shy", id = "ASHES_RE_ESCAPED", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Escaped the Anteroom of Agony.]],
	mode = "player",
}

newAchievement{
	name = "The Old Ones", id = "ASHES_OLD_ONES", category = "Ashes of Urh'Rok",
	show = "full",
	desc = _t[[Kill all the three demons that are on Eyal since before the Spellblaze: Shasshhiy'Kaish, Kryl'Feijan and Walrog.]],
	mode = "player",
	can_gain = function(self, who, target)
		self.kills = self.kills or {}
		if target.name == "Shasshhiy'Kaish" then self.kills.shass = true
		elseif target.name == "Kryl-Feijan" then self.kills.kryl = true
		elseif target.name == "Walrog" then self.kills.walrog = true
		end
		if self.kills.shass and self.kills.kryl and self.kills.walrog then return true end
	end,
	track = function(self)
		self.kills = self.kills or {}
		local desc = {}
		if self.kills.shass then desc[#desc+1] = _t"#LIGHT_GREEN#Shasshhiy'Kaish#LAST#" else desc[#desc+1] = _t"Shasshhiy'Kaish" end
		if self.kills.kryl then desc[#desc+1] = _t"#LIGHT_GREEN#Kryl-Feijan#LAST#" else desc[#desc+1] = _t"Kryl-Feijan" end
		if self.kills.walrog then desc[#desc+1] = _t"#LIGHT_GREEN#Walrog#LAST#" else desc[#desc+1] = _t"Walrog" end
		return table.concat(desc, ', '):toTString()
	end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("race_doomelf", true)
	end,
}
