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

for _, j in ipairs{1, 4} do for i = 1, 6 do
local l = mod.class.interface.PartyLore.lore_defs["fay-willows-book"..j.."-chapter"..i]
newEntity{ base = "BASE_LORE",
	define_as = "FAY_WILLOWS_BOOK"..j.."_CHAPTER"..i,
	subtype = "book", unique=true, no_unique_lore=true, not_in_stores=false,
	name = l.name, lore="fay-willows-book"..j.."-chapter"..i,
	rarity = false,
	encumberance = 0,
	cost = 70,
}
end end
