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

for _, i in ipairs{5, 8, 9, 12, 13} do
local l = mod.class.interface.PartyLore.lore_defs["cults-gods-"..i]
newEntity{ base = "BASE_LORE_RANDOM",
	define_as = "CULTS_GODS_NOTE"..i,
	subtype = "gods", unique=true,
	name = l.name, lore="cults-gods-"..i,
	level_range = {30, 50},
	rarity = 60,
	encumberance = 0,
	cost = 2,
}
end

for i = 4, 9 do
local l = mod.class.interface.PartyLore.lore_defs["cults-godslayers-"..i]
newEntity{ base = "BASE_LORE_RANDOM",
	define_as = "CULTS_GODSLAYERS_NOTE"..i,
	subtype = "godslayers", unique=true,
	name = l.name, lore="cults-godslayers-"..i,
	level_range = {30, 50},
	rarity = 60,
	encumberance = 0,
	cost = 2,
}
end

for _, i in ipairs{"krog", "drem"} do
local l = mod.class.interface.PartyLore.lore_defs["races-"..i]
newEntity{ base = "BASE_LORE_RANDOM",
	define_as = "RACES_NOTE"..i,
	subtype = "analysis", unique=true,
	name = l.name, lore="races-"..i,
	level_range = {20, 50},
	rarity = 40,
	encumberance = 0,
	cost = 2,
}
end
