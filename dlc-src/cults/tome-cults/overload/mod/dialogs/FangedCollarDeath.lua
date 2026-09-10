-- TE4 - T-Engine 4
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
local Chat = require "engine.Chat"

module(..., package.seeall, class.inherit(Dialog))

-- Fake dialog to pop the chat
function _M:init(actor)
	self.dont_show = true

	local o, item, inven_id = actor:findInAllInventoriesBy("define_as", "FANGED_COLLAR")
	local chat = Chat.new("cults+fanged-collar", o, actor)
	chat:invoke()
end
