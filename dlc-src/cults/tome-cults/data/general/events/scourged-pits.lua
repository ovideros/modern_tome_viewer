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

if not game:isCampaign("Maj'Eyal") then return end

level.data.on_enter_list.scourged_pits = function()
	if game.level.data.scourged_pits_added then return end
	if game:getPlayer(true).level < 20 then return end

	local spot = {x=72, y=26} -- aww hardcoded :<

	game.level.data.scourged_pits_added = true
	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN):cloneFull()
	g.name = _t"Way into the scourged pits"
	g.display='>' g.color_r=0 g.color_g=255 g.color_b=0 g.notice = true
	g.change_level=1 g.change_zone="cults+scourged-pits" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/scourged_pit_entrance.png", z=5}
	g:altered()
	g:initGlow()
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
	print("[WORLDMAP] scourged pits at", spot.x, spot.y)
	require("engine.ui.Dialog"):simplePopup(_t"The air is pestilent", _t"You smell a blighted perfume in the air for an instant...")
end

return true
