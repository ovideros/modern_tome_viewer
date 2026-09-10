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

-----------------------------------------------------------------
-- Find a random spot
local masks = {
	{
		[7] = 0, [8] = 1, [9] = 1, 
		[4] = 0, [5] = 1, [6] = 1, 
		[1] = 0, [2] = 1, [3] = 1, 
	},
	{
		[7] = 1, [8] = 1, [9] = 0, 
		[4] = 1, [5] = 1, [6] = 0, 
		[1] = 1, [2] = 1, [3] = 0, 
	},
	{
		[7] = 0, [8] = 0, [9] = 0, 
		[4] = 1, [5] = 1, [6] = 1, 
		[1] = 1, [2] = 1, [3] = 1, 
	},
	{
		[7] = 1, [8] = 1, [9] = 1, 
		[4] = 1, [5] = 1, [6] = 1, 
		[1] = 0, [2] = 0, [3] = 0, 
	},
}

local map = level.map
local checkSpot = function(i, j, mask)
	for dir, state in pairs(mask) do
		local x, y = util.coordAddDir(i, j, dir)
		local check = state == 1 and "floor" or "rockwall"
		if map:checkEntity(x, y, map.TERRAIN, "type") ~= check then return false end
	end
	return true
end

local spots = {}
for i = 1, map.w - 2 do for j = 1, map.h - 2 do 
	if checkSpot(i, j, masks[1]) or checkSpot(i, j, masks[2]) or checkSpot(i, j, masks[3]) or checkSpot(i, j, masks[4]) then
	  	spots[#spots+1] = {x=i, y=j}
	end
end end

if #spots == 0 then return false end
local spot = rng.table(spots)
local x, y = spot.x, spot.y
-----------------------------------------------------------------

local stallid = rng.range(1, 3)
local g = mod.class.Grid.new{
	type = "stall", subtype = "rock",
	display = "7", color=colors.UMBER, image="terrain/rocky_ground.png", add_displays={mod.class.Grid.new{image = "terrain/market_stall_0"..stallid.."_1.png", z=6}, mod.class.Grid.new{image = "terrain/market_stall_0"..stallid.."_0.png", display_y=-1, z=18}},
	name = _t"market stall",
	desc = _t[[A market stall, it looks abandoned..]],
	does_block_move = true,
	block_sight = true,
	looted = false,
	special = true,
	block_move = function(self, x, y, e, act, couldpass)
		if not self.looted and e and e.player and act then
			self.looted = true
			self.special = nil
			self.autoexplore_ignore = true
			local money = rng.range(10, 30)
			local list = { ("- #GOLD#%0.2f gold#LAST# worth of money"):tformat(money) }

			e:incMoney(money)
			for _, o in ipairs(self.loots) do
				o.__transmo = true
				o:identify(true)
				e:addObject(e.INVEN_INVEN, o)
				list[#list+1] = "- "..o:getName{do_color=true}
			end
			e:sortInven()

			for _, ad in ipairs(self.add_displays or {}) do
				if ad.image:find("^terrain/market_stall_0") then
					ad.image = ad.image:gsub("^terrain/market_stall_0", "terrain/looted_market_stall_0")
					ad:removeAllMOs()
				end
			end
			game.level.map:updateMap(x, y)

			require("engine.ui.Dialog"):simpleLongPopup(_t"Market Stall", _t"You loot the stall and gain:\n"..table.concat(list, "\n"), 500)
		end
		return mod.class.Grid.block_move(self, x, y, e, act, couldpass)
	end,
}
g:resolve()
g:resolve(nil, true)

game.zone:addEntity(game.level, g, "terrain", x, y)

g.loots = {}

-- Grab items under it
for i = game.level.map:getObjectTotal(x, y), 1, -1 do
	local o = game.level.map:getObject(x, y, i)
	game.level.map:removeObject(x, y, i)

	o:identify(true)
	g.loots[#g.loots+1] = o
end

-- Sometimes make a few items
if rng.percent(25) then
	for i = 1, rng.range(1, 3) do
		local o = game.zone:makeEntity(game.level, "object", {not_properties={"lore", "auto_pickup"}}, nil, true)
		if o then
			game.zone:addEntity(game.level, o, "object")
			g.loots[#g.loots+1] = o
		end
	end
end

return true
