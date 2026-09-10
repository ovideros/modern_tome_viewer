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

newEntity{ define_as = "WHIRLING_CHAOS",
	name = "entropic breach",
	image = "terrain/solidwall/solid_floor1.png",
	display = '*', color = colors.GREY,
	force_clone = true,
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "entropic_wormhole", nil, nil, 5)
	end,
}

newEntity{
	define_as = "ORB_MULTIVERSE",
	name = "Entropic Wormhole Control Orb", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{z=18, image="terrain/pedestal_orb_02.png", display_y=-1, display_h=2}},
	display = '*', color=colors.LIGHT_BLUE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			if game._chronoworlds and game._chronoworlds.multiverse_fight then
				game.bignews:say(120, "#CRIMSON#The entropic forces are already at work. FIGHT!")
			elseif not profile:isDonator() or not profile.connected or not profile.auth or not profile.chat.channels.tome then
				game.bignews:say(120, "#CRIMSON#The entropic control orb seems unresponsive...")
				game.log("#PURPLE#Make sure you are connected and joined the main Tales of Maj'Eyal chat channel.")
			else
				package.loaded['mod.dialogs.EntropicWormhole'] = nil
				game:registerDialog(require('mod.dialogs.EntropicWormhole').new())
			end
		end
		return true
	end,
}
