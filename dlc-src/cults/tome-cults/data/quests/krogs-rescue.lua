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

name = _t"Cleaning the trash"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t[[Protector Myssil has requested that you go at once to the ruins on the eastern shores of the sea of Sash to rescue a party of Krogs taken by necromancers filth.
Save our people and show the evildoers the wrongness of their way. Permanently.]]
	if self:isFailed() then desc[#desc+1] = _t[[#LIGHT_RED#* You have killed the necromancers but not in time to save any of the captive Krogs.]] end
	if self:isCompleted("some-saved") then desc[#desc+1] = _t[[#LIGHT_GREEN#* You have killed the necromancers and saved some of the Krogs.]] end
	if self:isCompleted("all-saved") then desc[#desc+1] = _t[[#LIGHT_GREEN#* You have killed the necromancers and saved all of the Krogs, well done Ziguranth!]] end
	return table.concat(desc, "\n")
end

on_grant = function(self)
	game:onLevelLoad("wilderness-1", function(zone, level, data)
		local g = level.map(52, 26, engine.Map.TERRAIN):cloneFull()
		g.name = _t"trapdoor into the necromancer's ruins"
		g.display='>' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
		g.change_level=1 g.change_zone="cults+necromancers-ruins" g.glow=true
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/crystal_ladder_down.png", z=5}
		g:altered()
		g:initGlow()
		zone:addEntity(level, g, "terrain", 52, 26) -- ugh hardcoding :/
	end)
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

checkKills = function(self, who)
	game:onLevelLoad("cults+necromancers-ruins-2", function(zone, level, data)
		local nb_necros = 0
		local nb_krog = 0
		for uid, e in pairs(game.level.entities) do
			if e:attr("is_necromancer") then nb_necros = nb_necros + 1 end
			if e:attr("is_captive_krog") then nb_krog = nb_krog + 1 end
		end

		if nb_krog == 0 then
			game.level.turn_counter = nil
			game.level.max_turn_counter = nil
			game.level.turn_counter_desc = nil
		end

		if nb_necros > 0 then return end

		if nb_krog == 0 then
			who:setQuestStatus(self.id, engine.Quest.FAILED)
		elseif nb_krog < 4 then
			who:setQuestStatus(self.id, engine.Quest.COMPLETED, "some-saved")
			who:setQuestStatus(self.id, engine.Quest.COMPLETED)
		else
			who:setQuestStatus(self.id, engine.Quest.COMPLETED, "all-saved")
			who:setQuestStatus(self.id, engine.Quest.COMPLETED)

			game:setAllowedBuild("race_giant")
			game:setAllowedBuild("race_krog", true)
		end

		game.level.turn_counter = nil
		game.level.max_turn_counter = nil
		game.level.turn_counter_desc = nil
		for uid, e in pairs(game.level.entities) do
			if e:attr("is_captive_krog") then e:removeEffect(e.EFF_TIME_PRISON, true, true) end
		end
	end)
end
