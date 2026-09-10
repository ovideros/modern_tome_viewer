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

-- Find a random spot
local list = game.state:findEventGridRadius(level, 1, 9)
if not list then return false end
local x, y = list[1].bx, list[1].by

local list = mod.class.Grid:loadList("/data-cults/general/grids/fonts.lua")

local kind = "FONT_KNOWLEDGE"
local og = level.map(x, y, engine.Map.TERRAIN)
local g = list[kind]:clone()
g.image = og.image
if og.add_mos then g.add_mos = table.clone(og.add_mos, true) end
if og.add_displays then g.add_displays = table.clone(g.add_displays) else g.add_displays = {} end
g.add_displays[#g.add_displays+1] = list[kind].add_displays[1]
g.add_displays[#g.add_displays+1] = list[kind].add_displays[2]
g.nice_editer = og.nice_editer
level.map(x, y, engine.Map.TERRAIN, g)
game.nicer_tiles:updateAround(level, x, y)

-- Move object, if any
local o = level.map(x, y, engine.Map.OBJECT)
if o then
	local tot = level.map:getObjectTotal(x, y)
	for i = tot, 1, -1 do
		local o = level.map:getObject(x, y, i)		
		local nx, ny = util.findFreeGrid(x, y, 10, true, {[engine.Map.OBJECT]=true})
		level.map:removeObject(x, y, i)
		if nx then level.map:addObject(nx, ny, o)
		else o:removed() end
	end
end

return true
