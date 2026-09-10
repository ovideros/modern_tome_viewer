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

local Map = require "engine.Map"
local Shader = require "engine.Shader"
local Dialog = require "engine.ui.Dialog"
local _M = loadPrevious(...)

_M.unlocks_list.demented_cultist_entropy = _t"Class: Cultist of Entropy"
_M.unlocks_list.race_drem = _t"Race: Drem"
_M.unlocks_list.race_krog = _t"Race: Krog"
_M.unlocks_list.wyrmic_scourge = _t"Class tree: Scourge drake"
_M.unlocks_list.cosmetic_class_alchemist_glass_golem = _t"Class feature: Alchemist's Glass Golem"

local saveGame = _M.saveGame
function _M:saveGame()
	if game._chronoworlds and game._chronoworlds.multiverse_fight then
		Dialog:yesnoPopup(_t"S.M.A.C.K", _t"Saving is not possible in the S.M.A.C.K. Do you want to cancel the fight?", function(ret) if ret then
			require("mod.class.CultsDLC").backFromSMACK("S.M.A.C.K", [[With but a thought you enact Yiilkgur's safety protocols and pull yourself out of the arena.
You have fled your fight.]])
		end end)
		return
	end
	return saveGame(self)
end

local changeLevelReal = _M.changeLevelReal
function _M:changeLevelReal(...)
	local ret = changeLevelReal(self, ...)
	self:updateCultsBookTexture()

	-- For the font of sacrifice glyphs
	local p = self:getPlayer(true)
	if self.zone.short_name == "town-last-hope" and self.state:isAdvanced() and not self.state.cults_lost_merchant_evil_message and p:hasQuest("lost-merchant") and p:hasQuest("lost-merchant"):isCompleted("evil") then
		self.state.cults_lost_merchant_evil_message = true
		self.party:learnLore("cults-lost-merchant-glyph")
	end

	-- For the krog quest
	local p = self:getPlayer(true)
	if profile.mod.allow_build.race_ogre and self.zone.short_name == "town-last-hope" and p.level > 16 and p:isQuestStatus("antimagic", engine.Quest.DONE) and not self.state.cults_krog_quest_starter then
		self.state.cults_krog_quest_starter = true
		Dialog:simpleLongPopup(_t"Urgent affair in Zigur", (_t[[As you enter Last Hope a courier finds you to deliver a letter from Protector Myssil of Zigur:

%s, while you were away destroying arcane filth I have received grave news.
A group of Krogs has been ambushed and taken to a hidden ruin on the eastern shores of the sea of Sash near Zigur.
From what the scouts can tell they were taken by a group of necromancers, probably to do vile experiments on them.

All our other elite fighting forces are currently abroad, you are their only hope.
Please, go there at once, free them and show the necromancers filth the True Wrath of the Ziguranth!

#{italic}#Protector Myssil#{normal}#
]]):format(p.name), 700)

		p:grantQuest("cults+krogs-rescue")
	end

	return ret
end

local createFBOs = _M.createFBOs
function _M:createFBOs()	
	-- Current tome version
	if not core.renderer then
		self.cults_book_data = {}
		self.cults_book_data.fbo = core.display.newFBO(Map.viewport.width, Map.viewport.height)
		while self.cults_book_data.fbo do -- Breakable if
			self.cults_book_data.fbo_shader = Shader.new("cults_book")
			self.cults_book_data.seens_shader = Shader.new("cults_book_seens")
			if not self.cults_book_data.fbo_shader.shad or not self.cults_book_data.seens_shader.shad then self.cults_book_data.fbo = nil break end
		break end
	-- New rendering engine
	else
		self.cults_book_data = {}
		self.cults_book_data.fbo = core.renderer.target(Map.viewport.width, Map.viewport.height)
		while true do -- Breakable if
			self.cults_book_data.fbo_shader = Shader.new("cults_book")
			self.cults_book_data.seens_shader = Shader.new("cults_book_seens")
			if not self.cults_book_data.fbo_shader.shad or not self.cults_book_data.seens_shader.shad then self.cults_book_data.fbo = nil break end

			self.cults_book_data.fborenderer = core.renderer.renderer("static")
			self.cults_book_data.fborenderer:add(self.cults_book_data.fbo)
			self.cults_book_data.fbo:shader(self.cults_book_data.fbo_shader)

			self.cults_book_data.fborenderer:scale(1, 1, 1):translate(Map.viewport.width * 0, Map.viewport.height * 0)
		break end
	end

	self:updateCultsBookTexture()

	return createFBOs(self)
end

function _M:updateCultsBookTexture()
	if not self:useCultsBookLook() then return end

	local book_texture = "book-texture-horrors"
	if type(self.zone.is_cults_book) == "string" then book_texture = self.zone.is_cults_book end

	if self.cults_book_data.cur_book_texture == book_texture then return end
	self.cults_book_data.cur_book_texture = book_texture

	-- Current tome version
	if not core.renderer then
		self.cults_book_data.booktex = core.display.loadImage("/data/gfx/ui/cults/"..book_texture..".png"):glTexture()
	-- New rendering engine
	else
		self.cults_book_data.booktex = core.loader.png("/data/gfx/ui/cults/"..book_texture..".png")
		self.cults_book_data.fbo:texture(self.cults_book_data.booktex, 1)
	end
end

function _M:useCultsBookLook()
	return self.zone and self.level and self.zone.is_cults_book and self.cults_book_data and self.cults_book_data.fbo and not config.settings.tome.cults_disable_book_zone and not self.level.data.cults_book_suppress
end

function _M:displaySeensMap(map, x, y, nb_keyframe)
	if self:useCultsBookLook() then
		self.cults_book_data.seens_shader.shad:use(true)
		map._map:drawSeensTexture(x, y)
		self.cults_book_data.seens_shader.shad:use(false)
	else
		map._map:drawSeensTexture(x, y)
	end
end

local displayMap = _M.displayMap
function _M:displayMap(nb_keyframes, prev_fbo)
	if self:useCultsBookLook() and self.cults_book_data.booktex then
		if not game.level or not game.level.map then return end

		-- Old renderer code
		if not core.renderer then
			self.cults_book_data.fbo:use(true, 0, 0, 0, 0)
			displayMap(self, nb_keyframes, self.cults_book_data.fbo)
			self.cults_book_data.fbo:use(false, prev_fbo)
			local x, y, w, h = Map.viewport.width * 0, Map.viewport.height * 0, Map.viewport.width * 1, Map.viewport.height * 1
			self.cults_book_data.booktex:bind(1)
			self.cults_book_data.fbo:toScreen(x, y, w, h, self.cults_book_data.fbo_shader.shad, 1, 1, 1, 1, true)
		-- New renderer code
		else
			self.cults_book_data.fbo:use(true)
			displayMap(self, nb_keyframes)
			self.cults_book_data.fbo:use(false)
			self.cults_book_data.fborenderer:toScreen()
		end
	else
		displayMap(self, nb_keyframes, prev_fbo)
	end
end

return _M
