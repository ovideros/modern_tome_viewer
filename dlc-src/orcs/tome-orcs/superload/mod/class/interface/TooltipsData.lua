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

require "engine.class"

--module(..., package.seeall, class.make)

local _M = loadPrevious(...)
-------------------------------------------------------------
-- Resources
-------------------------------------------------------------
_M.TOOLTIP_STEAM = _t[[#GOLD#Steam#LAST#
Steam is created by special generators and is used to power most technological things.
It is very hard to increase your maximum steam capacity, but it regenerates quickly.
Use it or lose it fast.
]]
-------------------------------------------------------------
-- Steamtech
-------------------------------------------------------------
_M.TOOLTIP_STEAMPOWER = _t[[#GOLD#Steampower#LAST#
Your steampower represents how powerful and effective your steamtech abilities are.
It is similar to Physical Power but is improved with Cunning.
]] --dgdgdgdg need to finish description?
_M.TOOLTIP_STEAM_CRIT = _t[[#GOLD#Steamtech critical chance#LAST#
Each time you deal damage with a steamtech - based attack you may have a chance to perform a critical hit that deals extra damage.
Some talents allow you to increase this percentage.
It is improved by Cunning.
]]
_M.TOOLTIP_STEAM_SPEED = _t[[#GOLD#Steamtech speed#LAST#
Steamtech speed represents how fast you use your steamtech - powered abilities compared to normal.
Higher is faster.
]]
return _M