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

load("/data-orcs/general/objects/objects.lua")

for i = 1, 6 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "a journal", lore="slumbering-caves-"..i,
	desc = _t[[A journal.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_AMULET", define_as = "GARDANION",
	power_source = {unknown=true},
	unique = true,
	name = "Gardanion, the Light of God", image = "object/artifact/gardanion_the_light_of_god.png",
	unided_name = _t"pure white amulet",
	plot=true,
	desc = _t[["#{italic}#When Amakthel arrived, he created the Sun and brought life to this world.
You carry a piece of His Sun with you now. Do not forget who gave it to you, lest you become like those wretched fools who would forsake Him.#{normal}#"]],
	color = colors.GOLD,
	level_range = {40, 50},
	material_level = 5,
	rarity = false,
	special_desc = function(self) return _t"When worn, gives you an additional prodigy point." end,
	wielder = {
		combat_spellpower=40,
		combat_mindpower=40,
		combat_steampower=40,
		combat_dam=40,
		speaks_shertul = 1, -- Why shouldn't it, I say. WHY SHOULDN'T IT
	},
	on_wear = function(self, who)
		if not who.player then return end
		who.unused_prodigies = who.unused_prodigies + 1
		self.on_wear = nil
		self.special_desc = nil
		game.logPlayer(who, "#GOLD#The light of the Amulet envelops you, then subsides. You feel stronger. (+1 Prodigy Points)")
		game.bignews:saySimple(160, "#GOLD#The light of the Amulet envelops you, then subsides. You feel stronger. (+1 Prodigy Points)")
	end,
}
