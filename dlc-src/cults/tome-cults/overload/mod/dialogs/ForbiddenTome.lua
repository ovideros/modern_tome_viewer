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

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Image = require "engine.ui.Image"
local Button = require "engine.ui.Button"
local Cults = require("mod.class.CultsDLC")
local FontPackage = require "engine.FontPackage"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(tome, actor)
	self.tome = tome
	self.actor = actor
	self.ui = "invisible"
	Dialog.init(self, _t"", 600, 400)
	local fontfile, fontsize
	if tome.book_font_style then
		fontfile, fontsize = FontPackage:getFont(tome.book_font_style)
	elseif tome.book_font then
		fontfile, fontsize = "/data/font/"..(tome.book_font or "INSULA__.ttf"), tome.book_font_size or 20
	else 
		fontfile, fontsize = FontPackage:getFont("book")
	end
	local font = core.display.newFont(fontfile, fontsize)

	local whole_text = tome.book_text
	if tome.book_read_times then
		if tome.book_read_times == 1 then
			whole_text = whole_text.._t"\n#CRIMSON#Will crumble to dust when read!"
		else
			whole_text = whole_text..("\n#YELLOW#Can only be read %d times."):tformat(tome.book_read_times)
		end
	end

	local text1, text2 = {}, {}
	local lines = whole_text:splitLines(250, font)
	for i, line in ipairs(lines) do
		if (#text1 + 1) * font:lineSkip() < 300 then
			text1[#text1+1] = line
		else
			text2[#text2+1] = line
		end
	end

	local book_texture = "book-texture-horrors"
	if tome.book_texture then book_texture = tome.book_texture end
	local frame = Image.new{file="ui/cults/"..book_texture..".png", width=self.iw, height=self.ih}
	local c_ok = Button.new{font=font, text=_t"Read the book", fct=function() self:readTome() end}
	local c_col1 = Textzone.new{font=font, width=250, height=300, text=table.concat(text1, '\n'), color={r=50,g=50,b=50}} c_col1:setTextShadow(nil)
	local c_col2 = Textzone.new{font=font, width=250, height=270, text=table.concat(text2, '\n'), color={r=50,g=50,b=50}} c_col2:setTextShadow(nil)

	self:loadUI{
		{left=0, top=0, ui=frame},
		{left=40, top=20, ui=c_col1},
		{left=math.floor(self.iw/2) + 20, top=20, ui=c_col2},
		{right=40, bottom=20, ui=c_ok},
	}
	self:setupUI()
	self:setFocus(c_ok)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:readTome(force)
	if self.actor:hasEffect(self.actor.EFF_CULTS_BOOK_COOLDOWN) then
		game.log("#RED#You can't enter a Forbidden Tome yet!#LAST#")
		return
	end
	if game.level.data.no_planechange then
		game.log("#RED#You can't enter a Forbidden Tome from here!#LAST#")
		return
	end
	if self.tome.book_level_min and self.actor.level < self.tome.book_level_min and not force then
		Dialog:yesnoPopup(self.tome.getName and self.tome:getName() or self.tome.name, _t"You feel this book is extremely dangerous for you. Proceed?", function(ret) if not ret then
			self:readTome(true)
		end end, _t"Cancel", _t"Read Tome")
		return
	end

	if self.tome.book_change_timeout then
		self.actor:setEffect(self.actor.EFF_CULTS_BOOK_TIMEOUT, self.tome.book_change_timeout, {tome=self.tome})
	else
		Cults.handleBookTransition(self.tome, self.actor)
	end
	game:unregisterDialog(self)
end
