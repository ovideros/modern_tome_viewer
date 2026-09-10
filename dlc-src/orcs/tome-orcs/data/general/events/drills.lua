-- ToME - Tales of Maj'Eyal
-- Copyright (C) 4009 - 2016 Nicolas Casalini
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
local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while tries < 400 do
	local ok = false
	if game.state:canEventGrid(level, x, y) then
		-- We want to be close a mountain on one side
		for _, dir in ipairs{4,6,8,2} do
			local mx, my = util.coordAddDir(x, y, dir)
			local odir = util.opposedDir(dir)
			local omx, omy = util.coordAddDir(x, y, odir)
			local olx, oly = util.coordAddDir(x, y, util.dirSides(odir).left)
			local orx, ory = util.coordAddDir(x, y, util.dirSides(odir).right)
			if not game.player:canMove(mx, my) and game.player:canMove(omx, omy) and game.player:canMove(olx, oly) and game.player:canMove(orx, ory) then
				ok = true
				break
			end
		end
	end
	if ok then break end

	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries >= 400 then return false end

local drillkind = rng.range(1, 4)
local drillimage = ({"geothermal_drill_01", "geothermal_drill_02", "corrupted_geothermal_drill_01", "corrupted_geothermal_drill_02", })[drillkind]
local drillcorrupted = drillkind >= 3
local g = mod.class.Grid.new{
	type = "drill", subtype = "rock",
	display = "7", color=colors.UMBER, image="terrain/rocky_ground.png", add_displays={mod.class.Grid.new{image = "terrain/"..drillimage.."_1.png", z=6}, mod.class.Grid.new{image = "terrain/"..drillimage.."_0.png", display_y=-1, z=18}},
	name = drillcorrupted and _t"corrupted geothermal drill" or _t"geothermal drill",
	desc = _t[[A huge geothermal drill, pumping heat and steam from Eyal's crust.]], show_tooltip = true,
	does_block_move = true,
	block_sight = true,
}
g:resolve()
g:resolve(nil, true)

game.zone:addEntity(game.level, g, "terrain", x, y)

-- Grab items under it
for i = game.level.map:getObjectTotal(x, y), 1, -1 do
	local ox, oy = util.findFreeGrid(x, y, 10, true, {[engine.Map.ACTOR]=true})
	if ox then
		local o = game.level.map:getObject(x, y, i)
		game.level.map:removeObject(x, y, i)
		game.level.map:addObject(ox, oy, o)
	end
end

return true
