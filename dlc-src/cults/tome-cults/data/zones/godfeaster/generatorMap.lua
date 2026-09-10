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

local Map = require "engine.Map"

-- Creates a space (Pod room) at center of map, with a number of 'arms' (Pod rooms) around it connected by tunnels
function _M:init(zone, map, level, data)
	engine.generator.map.Roomer.init(self, zone, map, level, data)

	self.spots = {}

	self.nb_rooms = data.nb_rooms or {5, 10} -- number of Pod rooms around center
	self.base_breakpoint = data.base_breakpoint or 0.4
	self.arms_range = data.arms_range or {0.5, 0.7} -- fraction dist from map center to map edge for each Pod room
	self.arms_radius = data.arms_radius or {0.2, 0.3} -- *(map.w + map.h)/4 ==> radius of each Pod room

	self.noise = data.noise or "fbm_perlin"
	self.zoom = data.zoom or 5
	self.hurst = data.hurst or nil
	self.lacunarity = data.lacunarity or nil
	self.octave = data.octave or 4
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self:resolve("#"))
	end end

	local spots = self.spots
	local ln = 0
	local path = core.noise.new(1)
	local wideness = core.noise.new(1)

	local spine_j = {}
	local spine_start = rng.range(3, 10)
	local spine_stop = self.map.w - rng.range(3, 10)

	local j, oldj = self.data.start, self.data.start
	local oldkind = "spine_horiz"
	local dir = 0
	local sx, sy, ex, ey
	for i = 1, self.map.w - 2 do
		local wd = wideness:fbm_perlin(20 * i / self.map.w, 4)
		wd = math.ceil(((wd + 1) / 2) * 4)
		if i < spine_start then wd = math.floor(wd * (i / spine_start)) end
		if i > spine_stop then wd = math.floor(wd * (1 - ((i-spine_stop) / (self.map.w-1-spine_stop)))) end

		for jj = j - wd, j + wd do if self.map:isBound(i, jj) then
			self.map(i, jj, Map.TERRAIN, self:resolve("."))
			self.map.attrs(i, jj, "worm_body", true)
		end end

		oldj = j
		if i > spine_start and i < spine_stop then -- not <= / >= to ensure the first and last segments are horizontals
			local n = path:fbm_perlin(350 * i / self.map.w, 4)
			if (ln > 0 and n < 0) or (ln < 0 and n > 0) then
				if dir == -1 then dir = util.bound(dir + rng.range(0, 1), -1, 1)
				elseif dir == 1 then dir = util.bound(dir + rng.range(-1, 0), -1, 1)
				else dir = util.bound(dir + rng.range(-1, 1), -1, 1)
				end
			end
			j = util.bound(j + dir, self.data.min_h, self.data.max_h)
			ln = n
		end

		spine_j[i] = j

		if i >= spine_start and i <= spine_stop then
			local kind
			if oldj < j then
				kind = "spine_diag_3"
				if i - 1 >= spine_start and oldkind == "spine_horiz" then self.map(i-1, oldj, Map.TERRAIN, self:resolve("spine_diag_start_3")) end
			elseif oldj > j then
				kind = "spine_diag_9"
				if i - 1 >= spine_start and oldkind == "spine_horiz" then self.map(i-1, oldj, Map.TERRAIN, self:resolve("spine_diag_start_9")) end
			else
				kind = "spine_horiz"
				if i - 1 >= spine_start and oldkind == "spine_diag_3" then self.map(i-1, oldj, Map.TERRAIN, self:resolve("spine_diag_stop_3"))
				elseif i - 1 >= spine_start and oldkind == "spine_diag_9" then self.map(i-1, oldj, Map.TERRAIN, self:resolve("spine_diag_stop_9"))
				end
			end
			-- print("!!!!!",i,j,":::", kind, oldkind," ::", j, oldj)
			self.map(i, j, Map.TERRAIN, self:resolve(kind))
			-- For tunneling
			self.map.room_map[i][j].special = true
			self.map.room_map[i][j].can_open = true
			oldkind = kind
		elseif i == spine_start - 1 then
			self.map(i, j, Map.TERRAIN, self:resolve("spine_start"))
		elseif i == spine_stop + 1 then
			self.map(i, j, Map.TERRAIN, self:resolve("spine_stop"))
			spots[#spots+1] = {x=i, y=j, type="guardian", subtype="guardian"}
		end

		if i == 1 then sx, sy = i, j end
		if i == self.map.w - 2 then ex, ey = i, j end
	end

	-- "rooms" around the spine
	local rooms = {}
	local nb_rooms = rng.range(self.nb_rooms[1], self.nb_rooms[2])
	local arm_placement_range = math.floor((spine_stop - spine_start) / nb_rooms)
	for ir = 0, nb_rooms - 1 do
		local dir = rng.percent(50) and 1 or -1 --j < self.map.h/2 and 1 or -1
		local min_i = spine_start + ir * arm_placement_range
		local max_i = spine_start + (ir+1) * arm_placement_range - 1
		local i = math.floor(rng.avg(min_i, max_i, 3))
		local j = spine_j[i]

		local range = rng.float(self.arms_range[1], self.arms_range[2])
		local rx = i
		local ry = math.floor(j + dir * self.map.h / 2 * range)
		rooms[#rooms+1] = self:makePod(rx, ry, rng.float(self.arms_radius[1], self.arms_radius[2]) * (self.map.h / 2) / 2, 2 + ir, self)
		spots[#spots+1] = {x=rx, y=ry, type="room", subtype="side"}

		self:tunnel(rx, ry, i, j, 2 + ir)
	end

	self.map(sx, sy, Map.TERRAIN, self:resolve("up"))
	-- self.map(ex, ey, Map.TERRAIN, self:resolve("down"))

	return sx, sy, ex, ey, spots
end
