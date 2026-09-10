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
local x, y = game.state:findEventGrid(level, function(self, level, x, y)
	return 
		level.map:checkEntity(x, y, engine.Map.TERRAIN, "type") == "wall" and
		not game.player:canMove(x, y) and
		game.player:canMove(x, y + 1) and
		not level.map.attrs(x, y, "no_teleport") and
		not level.map:checkAllEntities(x, y, "change_level") and
		not level.map:checkAllEntities(x, y, "special")
end)
if not x then return false end

local o
local r = rng.range(0, 99)
if r < 10 then
	o = game.state:generateRandart{lev=resolvers.current_level+10}
elseif r < 40 then
	o = game.zone:makeEntity(game.level, "object", {tome={double_greater=1}}, nil, true)
else
	o = game.zone:makeEntity(game.level, "object", {tome={greater_normal=1}}, nil, true)
end
r = 99 - r 
local ms = {}
r = rng.range(0, 99)
if r < 8 then
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator", random_boss=true}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
elseif r < 25 then
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator", random_elite=true}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator", random_elite=true}, nil, true)
elseif r < 60 then
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator", random_elite=true}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
else
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
	ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {type = "reptile", subtype = "alligator"}, nil, true)
end 

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = _t"strange conduit on the wall"
g.display='#' g.color_r=0 g.color_g=215 g.color_b=0 g.notice = true
g.always_remember = true g.special_minimap = {b=0, g=215, r=0}
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then g.image = "terrain/granite_wall_sewer_glow.png" end
g:altered()
g.special = true
g.chest_item = o
g.chest_guards = ms
g.block_move = function(self, x, y, who, act, couldpass)
	if not who or not who.player or not act then return true end
	if self.chest_opened then return true end

	require("engine.ui.Dialog"):yesnoPopup(_t"Strange conduit", _t"Crack open?", function(ret) if ret then
		self.chest_opened = true
		if self.chest_item then
			game.zone:addEntity(game.level, self.chest_item, "object", x, y+1)
			game.logSeen(who, "#GOLD#The conduit shatters open, releasing huge angry alligators!")
			for _, m in ipairs(self.chest_guards) do
				if game.level.data and game.level.data.special_level_faction then
					m.faction = game.level.data.special_level_faction
				end
				local mx, my = util.findFreeGrid(x, y, 5, true, {[engine.Map.ACTOR]=true})
				if mx then game.zone:addEntity(game.level, m, "actor", mx, my) end
			end
		end
		self.chest_item = nil
		self.chest_guards = nil
		self.block_move = nil
		self.special = nil
		self.autoexplore_ignore = true
		self.name = _t"open conduit on the wall"
		self.image = "terrain/granite_wall_sewer_glow_open.png"
		self:removeAllMOs()
		game.level.map:updateMap(x, y)
		self.block_move = function(self, x, y, who, act, couldpass)
			if not who or not who.player or not act then return true end
			game.logPlayer(who, "#CRIMSON#The conduit is smashed and impassible.")
			return true
		end
	end end, _t"Open", _t"Leave")

	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

return true
