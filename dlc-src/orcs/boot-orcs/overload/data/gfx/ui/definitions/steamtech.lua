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

steam = {
	frame_shadow = {x=15, y=15, a=0.5},
	frame_alpha = 1,
	frame_ox1 = -42,
	frame_ox2 =  42,
	frame_oy1 = -42,
	frame_oy2 =  42,
	title_bar = {x=0, y=-17, w=4, h=25},
	particles = {
		{position={base=7, ox=0,oy=0}, chance=300, name="steamui_vapour", args={jetdir=-1, smoke="particles_images/smoke_heavy_bright"}},
		{position={base=9, ox=0,oy=0}, chance=300, name="steamui_vapour", args={jetdir= 1, smoke="particles_images/smoke_heavy_bright"}},
		{position={base=1, ox=0,oy=0}, chance=300, name="steamui_vapour", args={jetdir=-1, smoke="particles_images/smoke_heavy_bright"}},
		{position={base=3, ox=0,oy=0}, chance=300, name="steamui_vapour", args={jetdir= 1, smoke="particles_images/smoke_heavy_bright"}},
	},
}