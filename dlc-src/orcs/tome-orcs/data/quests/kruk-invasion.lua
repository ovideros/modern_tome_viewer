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

name = _t"Homeland"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"The giants have breached the mountain-side of Kruk pride!"
	desc[#desc+1] = _t"They are invading the town just when most of our forces are outside."
	desc[#desc+1] = _t"Only you and few others are left to close the breach by collapsing the tunnel from the inside.\n"
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have collapsed the tunnel, saving the Pride. For now.#WHITE#"
	else
		desc[#desc+1] = _t"#LIGHT_GREY#* You must place the bomb at the end of the tunnel to destroy it.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+start-orc")
	end
end

on_grant = function(self, who)
	local spot = game.level:pickSpot{type="spawn", subtype="player"}
	who:move(spot.x, spot.y, true)

	for i = 1, 4 do
		local spot = game.level:pickSpotRemove{type="spawn", subtype="defender"}
		local npc = game.zone:makeEntity(game.level, "actor", {max_ood=2}, nil, true)
		if npc then game.zone:addEntity(game.level, npc, "actor", spot.x, spot.y) end
	end

	for i = 1, 4 do
		local spot = game.level:pickSpotRemove{type="spawn", subtype="giants"}
		local npc = game.zone:makeEntity(game.level, "actor", {max_ood=2, special_rarity="attack_rarity"}, nil, true)
		if npc then game.zone:addEntity(game.level, npc, "actor", spot.x, spot.y) end
	end

	local o = mod.class.Object.new{
		power_source = {steam=true},
		type = "tinker", subtype = "bomb", define_as = "KRUK_INVASION_BOMB",
		identified=true, no_unique_lore=true,
		name = _t"Cave Detonator", display = '*', color=colors.CRIMSON, unique=true, image = "trap/trap_bomb_01.png",
		desc = _t[[This bomb was tailored to crumble the tunnel used by the Steam Giants to invade Kruk Pride.]],
		cost = 0, quest=true,
	}
	game:getPlayer(true):addObject("INVEN", o)
	game:getPlayer(true):sortInven()

	local spot = game.level:pickSpot{type="feature", subtype="down"}
	local g = game.zone:makeEntityByName(game.level, "terrain", "CAVE_IN")
	if g and spot then
		game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
	end
end

invasion_ends = function(self)
	require("engine.ui.Dialog"):simpleLongPopup(_t"Cave Detonator", _t"You place the detonator, you have 220 turns to get out or be destroyed by the explosion.\nUse your #{bold}##GOLD#Rod of Recall#LAST##{normal}#!", 500, function()
		game.bignews:saySimple(120, "#LIGHT_GREEN#Kruk Pride is safe for now. Now is time for revenge!")
		game.player:setQuestStatus("orcs+kruk-invasion", engine.Quest.COMPLETED)

		game.level.max_turn_counter = 2200
		game.level.turn_counter = 2200
		game:onLevelLoad("orcs+town-kruk-1", function(zone, level)
			local spot = level:pickSpot{type="feature", subtype="down"}
			local g = zone:makeEntityByName(level, "terrain", "FLOOR")
			if g and spot then
				zone:addEntity(level, g, "terrain", spot.x, spot.y)
				game.nicer_tiles:updateAround(level, spot.x, spot.y)
			end
		end)
	end)
end

do_destruction = function(self)
	game.level.no_return_from_eidolon = true
	game:changeLevel(1, "wilderness")
	game.player:die(game.player)
end
