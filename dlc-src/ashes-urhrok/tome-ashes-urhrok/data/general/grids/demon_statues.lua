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

local lava_editer = {method="borders_def", def="lava"}

local list = {
	rogroth = _t"Rogroth, Eater of Souls",
	champion_of_urh_rok = _t"a champion of Urh'Rok",
	corrupted_daelach = _t"the Corrupted Daelach",
	daelach = _t"a daelach",
	dolleg = _t"a dolleg",
	draebor_the_imp = _t"Draebor, the Imp",
	duathedlen = _t"a dúathedlen",
	fire_imp = _t"a fire imp",
	forge_giant = _t"a forge giant",
	general_of_urh_rok = _t"Khulmanar, General of Urh'Rok",
	kryl_feijan = _t"Kryl-Feijan",
	lithfengel = _t"Lithfengel",
	onilug = _t"an onilug",
	quasit = _t"a quasit",
	shasshhiy_kaish = _t"Shasshhiy'Kaish",
	thaurhereg = _t"a thaurhereg",
	uruivellas = _t"an uruivellas",
	walrog = _t"Walrog",
	water_imp = _t"a water imp",
	wretchling = _t"a wretchling",
	wretch_titan = _t"a wretch titan",
	ruin_banshee = _t"a ruin banshee",
	harkor_zun = _t"Harkor'Zun",
}

loading_list.demon_statues_list = list

for kind, name in pairs(list) do
newEntity{
	define_as = "DEMON_STATUE_"..kind:upper(), image = "terrain/lava/lava_floor1.png",
	add_displays = {
		mod.class.Grid.new{is_demon_statue=true, image="terrain/statues/demon_statue_"..kind.."0.png", z=18, display_y=-1},
		mod.class.Grid.new{is_demon_statue=true, image="terrain/statues/demon_statue_"..kind.."1.png", z=5},
	},
	type = "floor", subtype = "lava",
	name = ("statue of %s"):tformat(name),
	statue_name = name, statue_kind = kind,
	display = '&', color_r=255, color_g=0, color_b=0,
	special_minimap = colors.CRIMSON,
	notice = true,
	always_remember = true,
	nice_editer = lava_editer,
	lore_name = "ashes-urhrok-demon-statue-"..kind,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act and not self.demon_statue_active then
			require("engine.ui.Dialog"):yesnoPopup(("Demon Statue of %s"):tformat(self.statue_name), _t"Do you #{strong}#really#{normal}# want to touch that?", function(ret) if not ret then
				self.block_move_activated(self, x, y, e, act, couldpass)
			end end, _t"No", _t"Yes", nil, true)
			if self.lore_name and game.party:getLore(self.lore_name, true) then game.party:learnLore(self.lore_name) end
		end
		return true
	end,
	block_move_activated = function(self, x, y, e, act, couldpass)
		self.nice_editer = nil
		self:altered()
		if core.shader.active(4) and not self.demon_statue_active then
			local Particles = require("engine.Particles")
			for i, ad in ipairs(self.add_displays) do if ad.is_demon_statue then
				self.add_displays[#self.add_displays+1] = self.new{image="invis.png", z=ad.z-1, add_mos={{_isshaderaura=true, image_alter="sdm", sdm_double=false, image=ad.image, shader="awesomeaura", shader_args={time_factor=3500, alpha=0.6, flame_scale=0.6}, textures={{"image", "particles_images/wings.png"}}, display_y=ad.display_y}}}
			end end
			game.level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=3, life=30, y=-0.2, img="felfire_01"}, {type="firesurge"})
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
		end
		if not self.demon_statue_active then
			game.log("#CRIMSON#The %s glows ominously.", self:getName())
			self:check("demon_statue_actived", x, y, e)
			world:gainAchievement("ASHES_ALL_STATUES", e)
		end
		self.demon_statue_active = true
	end
}
end
