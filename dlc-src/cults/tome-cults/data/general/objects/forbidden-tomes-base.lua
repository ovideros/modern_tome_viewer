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
	define_as = "BASE_FORBIDDEN_TOME",
	type = "tome", subtype="forbidden", power_source = {unknown=true},
	unided_name = _t"strange book",
	display = "?", color=colors.WHITE, image="object/spellbook.png",
	encumber = 2,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	desc = _t[[A lost tome of knowledge.]],

	use_simple = { name=_t"read the book", use = function(self, who, inven, item)
		if self.book_ended then
			require("engine.ui.Dialog"):simplePopup(self:getName(), _t"The book story is done already.")
			return {used=true, id=true}
		elseif game.zone and game.zone.is_cults_book then
			require("engine.ui.Dialog"):simplePopup(self:getName(), _t"You can not enter a book while already inside one.")
			return {used=true, id=true}
		elseif game._chronoworlds then
			require("engine.ui.Dialog"):simplePopup(self:getName(), _t"You can not enter a book while the timeline is split.")
			return {used=true, id=true}
		elseif not self.book_in_combat and who.in_combat then
			require("engine.ui.Dialog"):simplePopup(self:getName(), _t"You can not enter this book while in combat.")
			return {used=true, id=true}
		end
		package.loaded["mod.dialogs.ForbiddenTome"] = nil
		local d = require("mod.dialogs.ForbiddenTome").new(self, who)
		game:registerDialog(d)

		if self.book_read_lore then
			game.party:learnLore(self.book_read_lore)
			self.book_read_lore = nil
		end

		return {used=true, id=true}
	end}
}
