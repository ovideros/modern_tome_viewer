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

local answers = {}

player:inventoryApplyAll(function(inven, item, o) if o.vinyl_lore then
	table.insert(answers, {("[insert %s]"):tformat(o:getName{do_color=1}), cond=function() return not game.party:knownLore(o.vinyl_lore) end, action=function() game.party:learnLore(o.vinyl_lore) end, jump="welcome"})
end end)

table.insert(answers, {"[leave]"})

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*This machine seems to have a slot for some kind of disks.*#WHITE#]],
	answers = answers
}

return "welcome"
