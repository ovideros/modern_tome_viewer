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

local list = mod.class.Grid:loadList("/data-ashes-urhrok/general/grids/demon_statues.lua")

local allowed = nil
if level.data.restrict_demon_statues then allowed = level.data.restrict_demon_statues
elseif list.demon_statues_list then allowed = table.keys(list.demon_statues_list) end
if not allowed then return true end

allowed = table.clone(allowed)

local function createStatue(x, y)
	local kind = "DEMON_STATUE_"..rng.tableRemove(allowed):upper()

	local og = level.map(x, y, engine.Map.TERRAIN)
	local g = list[kind]:clone()
	g.image = og.image
	if og.add_mos then g.add_mos = table.clone(og.add_mos, true) end
	if og.add_displays then g.add_displays = table.clone(g.add_displays) else g.add_displays = {} end
	g.add_displays[#g.add_displays+1] = list[kind].add_displays[1]
	g.add_displays[#g.add_displays+1] = list[kind].add_displays[2]
	g.nice_editer = og.nice_editer
	g.demon_statue_actived = function(self, x, y, who)
		game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
		game.state:attr("demon_statues_activated", 1)
		if game.state:attr("demon_statues_activated") > 3 and rng.percent(game.state:attr("demon_statues_activated") * 3) then end

		local v = rng.range(0, 99)
		-- 30% : nothing
		if v <= 30 then
			game.logSeen(who, "#CRIMSON#The power of the Fearscape touches %s and fades away, leaving no traces.", who:getName())
		-- 30% : random hostile demon summon
		elseif v <= 60 then
			local npcs = mod.class.NPC:loadList{"/data/general/npcs/minor-demon.lua", "/data/general/npcs/major-demon.lua"}
			local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs, not_properties={"unique"}}, nil, true)
			local x, y = util.findFreeGrid(x, y, 5, true, {[engine.Map.ACTOR]=true})
			if not m or not x then return end
			m.faction = "fearscape"
			m:forceLevelup(who.level + rng.range(7, 10))
			game.zone:addEntity(game.level, m, "actor", x, y)
			game.logSeen(who, "#CRIMSON#The power of the Fearscape touches %s and fades away, leaving a nasty looking %s nearby.", who:getName(), m:getName())
		-- 20% : random debuff
		elseif v <= 80 then
			local v = rng.range(0, 99)
			if v <= 20 then
				who:setEffect(who.EFF_BURNING_PLAGUE, 8, {src=who, power=5 + who.level * 2})
			elseif v <= 40 then
				who:setEffect(who.EFF_CONFUSED, 5, {power=40})
			elseif v <= 60 then
				who:setEffect(who.EFF_BLINDED, 5, {})
			elseif v <= 80 then
				who:setEffect(who.EFF_STUNNED, 5, {})
			else
				who:setEffect(who.EFF_ITEM_BLIGHT_ILLNESS, 5, {reduce=2 + who.level})
			end
			game.logPlayer(who, "#CRIMSON#The power of the Fearscape touches %s and fades away, leaving a nasty effect upon you.", who:getName())
		-- 15% : random buff
		elseif v <= 95 then
			local v = rng.range(0, 99)
			if v <= 20 then
				who:setEffect(who.EFF_DESTROYER_FORM, 8, {power=8 + who.level * 2})
			elseif v <= 40 then
				who:setEffect(who.EFF_SURGE_OF_POWER, 8, {power=10 + who.level})
			elseif v <= 60 then
				who:setEffect(who.EFF_DEMON_SEED_ARMOURED_LEVIATHAN, 8, {power=5 + who.level})
			elseif v <= 80 then
				who:setEffect(who.EFF_ARCANE_SUPREMACY, 8, {power=8 + who.level})
			else
				who:setEffect(who.EFF_BLOOD_PACT, 8, {})
			end
			game.logPlayer(who, "#CRIMSON#The power of the Fearscape touches %s and fades away, leaving a strange effect upon you.", who:getName())
		-- 5% : arcane artifact
		else
			local o = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}, special=function(e) return e.power_source and e.power_source.arcane end}, nil, true)
			local x, y = util.findFreeGrid(x, y, 5, true, {[engine.Map.OBJECT]=true})
			if not x or not o then return end
			game.zone:addEntity(game.level, o, "object", x, y)
			game.logSeen(who, "#CRIMSON#The power of the Fearscape touches %s and fades away, leaving a strange item behind.", who:getName())
		end
	end
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
end

local debug = false

if (rng.percent(97) or level.data.demon_statues_only_one) and not debug then
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	-- Place one statue and call it a day
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	createStatue(x, y)
elseif debug then
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	-- Place them all
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	createStatue(x, y)
	local nb = rng.range(7, 12)
	while #allowed > 0 do
		local list = game.state:findEventGridRadius(level, 1, 9)
		if list then
			createStatue(list[1].bx, list[1].by)
		end
	end
else
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	-- Oh! place many many !!! Very rare
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	createStatue(x, y)
	local nb = rng.range(7, 12)
	for i = 1, nb do if #allowed <= 0 then break end
		local list = game.state:findEventGridRadius(level, 1, 9)
		if list then
			createStatue(list[1].bx, list[1].by)
		end
	end
end

return true
