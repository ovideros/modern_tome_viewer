-- ToME - Tales of Maj'Eyal:
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

local class = require"engine.class"

-- class:bindHook("Boot:load", function()
-- 	local Base = require "engine.ui.Base"
-- 	local Button = require "engine.ui.Button"
-- 	Base.ui = "steam"
-- 	Button.ui = "steam"
-- end)


class:bindHook("Boot:loadBackground", function(self, data)
	if rng.percent(50) then
		data.value.name = "tome-orcs"
		return true
	end
end)


local credits = {
	false,
	false,
	false,
	{img="/data/gfx/background/tome-orcs-logo.png"},
	false,
	{"Project Lead", title=1},
	{"Nicolas 'DarkGod' Casalini"},
	false,
	false,

	{"World Builders", title=1},
	{"Nicolas 'DarkGod' Casalini"},
	-- {"Taylor 'PureQuestion' Miller"},
	false,
	false,

	{"Graphic Artists", title=2},
	{"Assen 'Rexorcorum' Kanev"},
	{"Jeffrey 'Jotwebe' Buschhorn"},
	false,
	false,

	{"Expert Shaders Design", title=1},
	{"Alex 'Suslik' Sannikov"},
	false,
	false,

	{"Soundtracks", title=2},
	{"Matti Paalanen - 'Celestial Aeon Project'"},
	false,
	false,

	{"Lore Creation and Writing", title=2},
	{"David Mott"},
	false,
	false,
}


class:bindHook("Boot:credits", function(self, data)
	table.append(data.credits, credits)
end)
