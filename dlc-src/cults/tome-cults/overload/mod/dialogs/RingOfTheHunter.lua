-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even th+e implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"

local UberTalent = require "mod.dialogs.UberTalent"

module(..., package.seeall, class.inherit(UberTalent))

function _M:init(o, who)
	self.object = o
	UberTalent.init(self, who, {})
	self:updateTitle("Writhing Ring of the Hunter: Bonus Prodigy")
	self.selectable_prodigy = 1
end

_M.tuttext = [[Prodigies are special talents that only the most powerful of characters can attain.
All of them require at least 50 in a core stat and many also have more special demands.
#LIGHT_GREEN#The Writhing Ring of the Hunter can learn a prodigy for you without costing you a prodigy point.]]

function _M:use(item)
	local t = self.actor:getTalentFromId(item.talent)

	if self.actor:knowTalent(item.talent) then
	elseif t.cant_steal or (t.on_learn and not t.on_unlearn) or (t.on_unlearn and not t.on_learn) then
		self:simplePopup(_t"Impossible", _t"The Writhing Ring seems unable to learn this prodigy.")
	elseif self.levelup_end_prodigies[item.talent] then
		self.levelup_end_prodigies[item.talent] = false
		self.selectable_prodigy = self.selectable_prodigy + 1
	elseif (self.actor:canLearnTalent(t) and self.selectable_prodigy > 0) then
		if not self.levelup_end_prodigies[item.talent] then
			self.levelup_end_prodigies[item.talent] = true
			self.selectable_prodigy = math.max(0, self.selectable_prodigy - 1)
		end
	else
	end
end

function _M:unload()
	local tid, _ = next(self.levelup_end_prodigies)
	if tid then
		local o, item, inven_id = self.actor:findInAllWornInventoriesByObject("define_as", self.object)
		if not o then return end -- This really shouldnt happen
		self.actor:onTakeoff(self.object, inven_id, true)
		self.object.prodigy_granted = tid
		self.object.wielder.learn_talent = { [tid] = 1 }
		self.object.special_desc = function(self) local t = game.player:getTalentFromId(self.prodigy_granted) return ("You have set the ring to grant you #LIGHT_GREEN#%s%s!"):format(t.display_entity and t.display_entity:getDisplayString() or "", t.name) end,
		self.actor:onWear(self.object, inven_id, true)

		local t = self.actor:getTalentFromId(tid)
		game.log("#PURPLE#The Ring writhes and contracts around your finger and suddently you realize your now possess the prodigy #LIGHT_GREEN#%s%s!", (t.display_entity and t.display_entity:getDisplayString() or ""), t.name)
	end
	UberTalent.unload(self)
end
