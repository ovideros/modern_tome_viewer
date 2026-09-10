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
local Talents = require "engine.interface.ActorTalents"

load("/data/general/objects/objects.lua")
loadIfNot("/data-cults/general/objects/forbidden-tomes-base.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "the truth beyond the veil ("..i..")", lore="cults-tome-horrors-"..i,
	desc = _t[[A page of the tome.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_FORBIDDEN_TOME", define_as = "FORBIDDEN_TOME_HOME",
	name = 'Forbidden Tome: "Home, Horrific Home"', unique=true,
	image = "object/artifact/forbidden_tome_home.png",
	desc = _t[[A tome of lost knowledge. Touching it you feel both sick and yet strangely at peace.]],
	level_range = {25, 50},
	rarity = nil,
	cost = 500,
	material_level = 5,

	change_zone = "cults+ft-home",
	book_in_combat = true,
	book_texture = "book-texture-home",
	book_change_timeout = 3,
	book_change_cooldown = 80,
	book_font = "Unquiet Spirits.ttf",
	book_font_style = "book_unquiet",
	book_text = _t[[Clarity found in safety.
Clarity found in comfort.
Thoughts and idle dreams drifting through space.
No one to harm.
No one to distract.
Just thoughts.
Work to great works.
Meditate.
Pain is a lens.
Focus through it.
Let flesh be your canvas.
Let flesh fuel dreams.
Thoughts are treasures.
Treasure thoughts.
Thoughts treasured when they are alone. 

#RED#Reading this tome will slowly pull you in over 5 turns.]],

	on_pickup = function(self)
		self.on_pickup = nil
		world:gainAchievement("CULTS_BOOKCEPTION", game.player)
	end,
}
