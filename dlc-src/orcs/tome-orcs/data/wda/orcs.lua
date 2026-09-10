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

-- Orc campaign worldmap directory AI

-- Select the zone
local Map = require "engine.Map"
local zone = game.zone.display_name and game.zone.display_name() or game.zone.name
if not wda.zones[zone] then wda.zones[zone] = {} end
wda = wda.zones[zone]

game.level.level = game.player.level

local encounter_chance = function(who)
	local harmless_chance = 1 + who:getLck(7)
	local hostile_chance = 2
	if rng.percent(hostile_chance) then return "hostile"
	elseif rng.percent(harmless_chance) then return "harmless"
	end
end

---------------------------------------------------------------------
-- Far East: Clock Peninsula
---------------------------------------------------------------------
if zone == _t"Clork Peninsula" then

---------------------------------------------------------------------
-- Far East: Mainland
---------------------------------------------------------------------
elseif zone == _t"Var'Eyal" then
	wda.cur_patrols = wda.cur_patrols or 0
	wda.cur_sw_patrols = wda.cur_sw_patrols or 0
	wda.cur_hostiles = wda.cur_hostiles or 0

	-- Spawn random encounters
	local g = game.level.map(game.player.x, game.player.y, Map.TERRAIN)
	if g and g.can_encounter and not game.player.no_worldmap_encounter then
		local type = encounter_chance(game.player)
		if type then
			game.level:setEntitiesList("orcs_fareast_encounters_rng", game.zone:computeRarities("orcs_fareast_encounters_rng", game.level:getEntitiesList("orcs_fareast_encounters"), game.level, nil))
			local e = game.zone:makeEntity(game.level, "orcs_fareast_encounters_rng", {type=type, mapx=game.player.x, mapy=game.player.y, nb_tries=10}, nil, false)
			if e then
				if e:check("on_encounter", game.player) then
					e:added()
				end
			end
		end
	end

	-- Spawn some patrols
	if wda.cur_sw_patrols < 6 and rng.percent(5) then
		local e = game.zone:makeEntity(game.level, "orcs_fareast_encounters_npcs", {type="patrol", subtype="sunwall"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="patrol", subtype="orcs+sunwall"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned sunwall patrol (orcs)", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_sw_patrols = math.max(wda.cur_sw_patrols, 0)
				wda.cur_sw_patrols = wda.cur_sw_patrols + 1
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_sw_patrols = game.level.data.wda.zones[self.world_zone].cur_sw_patrols - 1 end
			end
		end
	end

	-- Spawn some hostiles
	if wda.cur_hostiles < 4 and rng.percent(5) then
		local e = game.zone:makeEntity(game.level, "orcs_fareast_encounters_npcs", {type="hostile"}, nil, true)
		if e then
			local spot = game.level:pickSpot{type="hostile", subtype="fareast"}
			if spot and not game.level.map(spot.x, spot.y, Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
				print("Spawned hostile", spot.x, spot.y, e.name)
				game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
				wda.cur_hostiles = wda.cur_hostiles + 1
				wda.cur_hostiles = math.max(wda.cur_hostiles, 0)
				e.world_zone = zone
				e.on_die = function(self) game.level.data.wda.zones[self.world_zone].cur_hostiles = game.level.data.wda.zones[self.world_zone].cur_hostiles - 1 end
			end
		end
	end
end

game.level.level = 1
