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

local list = mod.class.Grid:loadList("/data-cults/general/grids/tentacle-tree.lua")

local function createTree(x, y)
	local og = level.map(x, y, engine.Map.TERRAIN)
	local g = list.TENTACLE_TREEE:clone()
	g.old_g = og
	g.image = og.image
	if og.add_mos then g.add_mos = table.clone(og.add_mos, true) end	
	g.tentacle_tree_actived = function(self, x, y, who)
		game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
		self.tentacle_tree_actived = nil
		local v = rng.range(0, 99)
		-- 20% : nothing
		if v <= 20 then
			game.logSeen(who, "#DARK_SEA_GREEN#As you approach to touch it, the tentacle shrivels and disappears.")
			game.level.map(x, y, engine.Map.TERRAIN, self.old_g)
			game.nicer_tiles:updateAround(game.level, x, y)
		-- 40% : become a hostile randelite/randboss
		elseif v <= 60 then
			local filter
			if rng.percent(75) then
				filter = {base_list="mod.class.NPC:/data-cults/general/npcs/tentacle-tree.lua", special_rarity="is_tentacle_tree", random_elite = {}}
			else
				filter = {base_list="mod.class.NPC:/data-cults/general/npcs/tentacle-tree.lua", special_rarity="is_tentacle_tree", random_boss = {}}
			end
			local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
			if m then
				m:addParticles(require("engine.Particles").new("tentacle_tree2", 1, {force_tf=250}))
				game.zone:addEntity(game.level, m, "actor", x, y)
				m:setTarget(game.player)
				game.logSeen(m, "#DARK_SEA_GREEN#As you touch it the tentacle tree awakens and attacks you!")
			end
			local CultsDLC = require "mod.class.CultsDLC"
			local art = CultsDLC.generateCorruptedItem()
			if not art then return end
			m:addObject(m.INVEN_INVEN, art)
			game.level.map(x, y, engine.Map.TERRAIN, self.old_g)
			game.nicer_tiles:updateAround(game.level, x, y)
			local nx, ny = util.findFreeGrid(x, y, 20, true, {[engine.Map.ACTOR]=true})
			if nx then
				who:move(nx, ny, true)
			end
		-- 35% : swallowed whole
		elseif v <= 95 then
			game.level.map(x, y, engine.Map.TERRAIN, self.old_g)
			game.nicer_tiles:updateAround(game.level, x, y)
			game.logPlayer(who, "#DARK_SEA_GREEN#As you touch it the tentacle constricts you and swallows you whole!")

			local npcs = mod.class.NPC:loadList{"/data-cults/general/npcs/corrupted_blobs.lua"}
			local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
			local terrains = mod.class.Grid:loadList{"/data-cults/general/grids/scourge.lua"}
			
			terrains.PORTAL_BACK = terrains.SCOURGE_LADDER_UP:cloneFull()
			terrains.PORTAL_BACK.name = ("way back to %s"):tformat(game.zone.name)
			terrains.PORTAL_BACK.change_level = 1
			terrains.PORTAL_BACK.change_zone = game.zone.short_name
			terrains.PORTAL_BACK.change_level_shift_back = true
			terrains.PORTAL_BACK.change_level_check = function(self)
				game.log("#DARK_SEA_GREEN# You escaped the tentacle!")
				-- May delete old zone file here?
				return
			end

			local zone = mod.class.Zone.new("tentacle-swallow-"..game.turn, {
				name = _t"inside a giant tentacle",
				level_range = game.zone.actor_adjust_level and {math.floor(game.zone:actor_adjust_level(game.level, game.player)*1.05),
					math.ceil(game.zone:actor_adjust_level(game.level, game.player)*1.15)} or {game.zone.base_level, game.zone.base_level}, -- 5-15% higher levels
				__applied_difficulty = true, -- Difficulty already applied to parent zone
				level_scheme = "player",
				max_level = 1,
				actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
				width = 30, height = 30,
				ambient_music = {"cults/scourged_pits.ogg"},
				reload_lists = false,
				persistent = "zone",
				
				no_worldport = game.zone.no_worldport,
				min_material_level = util.getval(game.zone.min_material_level),
				max_material_level = util.getval(game.zone.max_material_level),
				generator =  {
					map = {
						class = "engine.generator.map.Cavern",
						zoom = 4,
						min_floor = 400,
						floor = "SCOURGE_FLOOR",
						wall = "SCOURGE_TREE",
						down = "PORTAL_BACK",
						force_last_stair = true,
					},
					actor = {
						class = "mod.class.generator.actor.Random",
						nb_npc = {20, 20},
						guardian = {random_elite={life_rating=function(v) return v * 1.5 + 4 end, name_scheme=_t"#rng# the Blightborn",
						nb_rares=(rng.percent(resolvers.current_level-50) and 5 or 4),
						nb_classes=(rng.percent(resolvers.current_level-50) and 2 or 1)
						}}
					},
					object = {
						class = "engine.generator.object.Random",
						filters = {{type="gem"}},
						nb_object = {6, 9},
					},
					trap = {
						class = "engine.generator.trap.Random",
						nb_trap = {0, 0},
					},
				},

				gastric_chance = 0,
				gastric_countdown = nil,
				on_turn = function(zone)
					if zone.is_dead then return end
					if game.turn % 10 ~= 0 then return end

					if not zone.gastric_countdown then
						if not rng.percent(zone.gastric_chance) then
							zone.gastric_chance = zone.gastric_chance + 0.5
							return
						end
						zone.gastric_countdown = rng.range(4, 6)
						game.bignews:say(120, "#DARK_SEA_GREEN#You can feel tremors in the tentacle.. A gastric wave is coming!")
						game:shakeScreen(20, 3)
					else
						zone.gastric_countdown = zone.gastric_countdown - 1
						if zone.gastric_countdown <= 0 then
							zone.gastric_countdown = nil
							zone.gastric_chance = 0
							game.bignews:say(120, "#DARK_SEA_GREEN#The gastric wave is upon you!")
							game:shakeScreen(30, 5)

							local map = game.level.map
							for i = math.max(map.mx, 0), math.min(map.mx + map.viewport.mwidth, map.w - 1) do for j = math.max(map.my, 0), math.min(map.my + map.viewport.mheight, map.h - 1) do
								if not map:checkEntity(i, j, map.TERRAIN, "block_move") then
									map:particleEmitter(i, j, 1, "acid")
								end
							end end

							for uid, e in pairs(game.level.entities) do
								if e.x and e.y and e.setEffect then
									if game:getPlayer(true):reactionToward(e) < 0 then
										e:setEffect(e.EFF_GASTRIC_WAVE_BUFF, 4, {})
									else
										e:setEffect(e.EFF_GASTRIC_WAVE_DEBUFF, 4, {})
									end
								end
							end
						end
					end
				end,
				post_process = function(level)
					local CultsDLC = require "mod.class.CultsDLC"
					local randbosses = {}  -- Put the corrupted item on something worthy
					for uid, e in pairs(level.entities) do 
						if e.rank >= 3.2 then randbosses[#randbosses+1] = e end
					end
					if #randbosses <= 0 then return end

					for i = 1,2 do
						local owner = rng.table(randbosses)
						local art = CultsDLC.generateCorruptedItem()
						if not art then return end

						owner:addObject(owner.INVEN_INVEN, art)
					end
				end,

				npc_list = npcs,
				grid_list = terrains,
				object_list = objects,
				trap_list = {},
			})

			game:changeLevel(1, zone, {temporary_zone_shift=true, temporary_zone_shift_save_pos=true, direct_switch=true})
		-- 5% : arcane artifact
		else
			local o = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}, special=function(e) return e.power_source and e.power_source.arcane end}, nil, true)
			game.level.map(x, y, engine.Map.TERRAIN, self.old_g)
			game.nicer_tiles:updateAround(game.level, x, y)
			if not o then return end
			game.zone:addEntity(game.level, o, "object", x, y)
			game.logSeen(who, "#DARK_SEA_GREEN#As you approach to touch it, the tentacle shrivels and disappears, leaving behind %s.", o:getName{do_color=1})
		end
	end
	g:resolve() g:resolve(nil, true)
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

if rng.percent(97) then
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	-- Place one statue and call it a day
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	createTree(x, y)
else
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	-- Oh! place many many !!! Very rare
	--------------------------------------------------------------------------
	--------------------------------------------------------------------------
	createTree(x, y)
	local nb = rng.range(7, 12)
	for i = 1, nb do
		local list = game.state:findEventGridRadius(level, 1, 9)
		if list then
			createTree(list[1].bx, list[1].by)
		end
	end
end

return true
