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

newEntity{
	define_as = "TENTACLE_TREEE", image = "invis.png",
	add_displays={class.new{
		z = 16,
		image="terrain/sprouting_tentacles_nest_base.png",
		embed_particles = {
			{name="tentacle_tree2", rad=1, args={tentacle_id=id, force_tf=0}},
		},
	}},
	type = "floor", subtype = "creep",
	name = "strange tentacle 'tree'",
	display = '&', color=colors.DARK_SEA_GREEN,
	special_minimap = colors.CRIMSON,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act and not self.tentacle_tree_active then
			require("engine.ui.Dialog"):yesnoPopup(_t"Tentacle Tree", _t"Do you #{strong}#really#{normal}# want to touch that?", function(ret) if not ret then
				self.block_move_activated(self, x, y, e, act, couldpass)
			end end, _t"No", _t"Yes", nil, true)
			if self.lore_name and game.party:getLore(self.lore_name, true) then game.party:learnLore(self.lore_name) end
		end
		return false
	end,
	block_move_activated = function(self, x, y, e, act, couldpass)
		self.nice_editer = nil
		self.nice_tiler = nil
		self:altered()
		if not self.tentacle_tree_active then
			game.log("#CRIMSON#The %s glows ominously.", self:getName())
			self:check("tentacle_tree_actived", x, y, e)
		end
		self.tentacle_tree_active = true
	end
}
