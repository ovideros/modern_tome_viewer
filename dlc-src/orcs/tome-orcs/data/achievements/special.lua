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
	name = "No mercy!", id = "ORCS_CIVILIAN_KILLER", category = "Embers of Rage",
	show = "full",
	desc = _t[[Killed 1000 steam giants civilians.]],
	mode = "world",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 1000 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
}

newAchievement{
	name = "Mercy, mercy!", id = "ORCS_MERCY", category = "Embers of Rage",
	show = "full",
	desc = _t[[Killed Talosis without any civilians deaths.]],
	mode = "player",
}

newAchievement{
	name = "This will make a big Omelette!", id = "ORCS_RITCH_EGGS_40", category = "Embers of Rage",
	show = "full",
	desc = _t[[Collected 40 ritch eggs in the Ritch Hive.]],
	mode = "player",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 40 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 40"} end,
}

newAchievement{
	name = "An Other Brick in the Wall", id = "ORCS_GATES_RUSH", category = "Embers of Rage",
	show = "full", huge=true,
	desc = _t[[Defeated Aeryn in the Gates of Morning without destroying the Observatory nor using ritches help.]],
	mode = "player",
}

newAchievement{
	name = "No Steam, No Palace. No Palace, No Palace!", id = "ORCS_PALACE_RUSH", category = "Embers of Rage",
	show = "full", huge=true,
	desc = _t[[Destroyed the Palace of Fumes without first destroying the geothermal valves in the Steam Quarry.]],
	mode = "player",
}

newAchievement{
	name = "Here, I Think You Dropped This", id = "ORCS_URESLAK_URESLAK_FEMUR", category = "Embers of Rage",
	show = "full",
	desc = _t[[Killed Ureslak the Eternal while wielding Ureslak's Femur.]],
	mode = "player",
}

newAchievement{
	name = "Do not go gentle into that good night", id = "ORCS_JOHN_CAPTURED", category = "Embers of Rage",
	show = "full",
	desc = _t[[Trapped John.]],
	mode = "player",
}

newAchievement{
	name = "I did not want that!", id = "ORCS_NEKTOSH_SELF", category = "Embers of Rage",
	show = "full",
	desc = _t[[Tricked Nektosh into killing one of his own people.]],
	mode = "player",
}

newAchievement{
	name = "We weren't kidding!", id = "ORCS_DIE_NEKTOSH", category = "Embers of Rage",
	show = "full",
	desc = _t[[Die to Nektosh's beam without being pinned, stunned, asleep, dazed, or confused.]],
	mode = "player",
}

newAchievement{
	name = "Make Him Squirm", id = "ORCS_WIN_NEKTOSH", category = "Embers of Rage",
	show = "full",
	desc = _t[[Made Nektosh use up the last of his power, then left the area and ignored him until beating the game. The other Whitehooves will catch on any second now...]],
	mode = "player",
}

newAchievement{
	name = "True Savior", id = "ORCS_FREE_ORCS_SAFE", category = "Embers of Rage",
	show = "full", huge=true,
	desc = _t[[Freed all the Orc Prides without killing a single mind-controlled orc.]],
	mode = "player",
}

newAchievement{
	name = "Mender", id = "ORCS_MENDER", category = "Embers of Rage",
	show = "full", huge=true,
	desc = _t[[Destroyed the bosses of the Primal Forest without killing any uncorrupted treants.]],
	mode = "player",
}

newAchievement{
	name = "Sufficiently Advanced Technology", id = "ORCS_MAGE_FULL_TINKER", category = "Embers of Rage",
	show = "full",
	desc = _t[[Put five points into each of the tinker-crafting talents as any mage class.]],
	mode = "player",
}

newAchievement{
	name = "Radiant Horrorc", id = "ORCS_FIERY_MOCKERY", category = "Embers of Rage",
	show = "full",
	desc = _t[[While fighting in a Sunwall zone, use a Fiery Salve to reach at least 66% affinity for Fire and Light. Pointing and laughing is optional.]],
	mode = "player",
}

newAchievement{
	name = "Blood on the Moon", id = "ORCS_ASTRAL_MULTI_KILL", category = "Embers of Rage",
	show = "full", huge=true,
	desc = _t[[Kill all of the Star Gazers within 7 game turns.]],
	mode = "player",
}

newAchievement{
	name = "Once Upon A Time, In the West...", id = "ORCS_SCOURGE_STORY", category = "Embers of Rage",
	show = "full",
	desc = _t[[Hear the Eidolon's retelling of the Scourge from the West's journey.]],
	mode = "player",
}

newAchievement{
	name = "A Fistful of Gold", id = "ORCS_AAA_BUY", category = "Embers of Rage",
	show = "full",
	desc = _t[[Buy an item from an AAA.]],
	mode = "player",
}

newAchievement{
	name = "For a Few Gold More", id = "ORCS_AAA_BUY_ALL", category = "Embers of Rage",
	show = "full",
	desc = _t[[Completely deplete an AAA's stock.]],
	mode = "player",
}

newAchievement{
	name = "The Good, The Bad, and The Yeti", id = "ORCS_YETI_WAR", category = "Embers of Rage",
	show = "full",
	desc = _t[[Use mind-controlled yetis to kill 30 foes.]],
	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 30 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 30"} end,
}

newAchievement{
	name = "Total Annihilation: Redundancy", id = "ORCS_DOUBLE_ANNIHILATOR", category = "Embers of Rage",
	show = "full",
	desc = _t[[Wield the Annihilator as an Annihilator.]],
	mode = "player",
}
