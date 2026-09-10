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
	define_as = "BOOK_OUT",
	name = "book of exit",
	display = '<', color_r=255, color_g=0, color_b=255,
	notice = true, show_tooltip = true,
	change_level = 1,
	change_level_shift_back = true,
}

newEntity{
	define_as = "FLOOR",
	type = "floor", subtype = "horror",
	name = "floor",
	desc = _t"You can leave items here for safekeeping.", show_tooltip = true,
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
}

newEntity{
	define_as = "WALL",
	type = "wall", subtype = "horror",
	name = "wall",
	display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	air_level = -20,
}

newEntity{
	define_as = "TORTURE",
	type = "wall", subtype = "horror",
	name = "torture tools",
	display = '#', color=colors.CRIMSON, back_color=colors.GREY,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			require("engine.ui.Dialog"):yesnoPopup(_t"Torture tools", _t"Use the torture tools on yourself?", function(ret) if not ret then
				e:incVim(25)
				local oldc = e.in_combat
				e.in_combat = true
				e:incInsanity(15)
				e.in_combat = oldc
				e:takeHit(e.life * 0.1, e)
				e:useEnergy()
				game.level.map:particleEmitter(e.x, e.y, 1, "blood")
				game:playSoundNear(e, "talents/slime")
			end end, _t"No", _t"Self-torture")
		end
		return true
	end,
}

newEntity{
	define_as = "VOID",
	type = "void", subtype = "void",
	name = "void",
	display = ' ',
	_noalpha = false,
	always_remember = true,
	does_block_move = true,
	pass_projectile = true,
	air_level = -40,
	is_void = true,
	can_pass = {pass_void=1},
}
