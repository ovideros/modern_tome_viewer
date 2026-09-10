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

local Stats = require "engine.interface.ActorStats"

newEntity{
	power_source = {steam=true},
	type = "tinker", subtype = "power",
	define_as = "APE",
	identified=true, no_unique_lore=true,
	name = "Automated Portable Extractor", display = '~', color=colors.GOLD, unique=true, image = "object/artifact/ape.png",
	desc = _t[[The APE is a multifunction tinker toolbox. It can store temporarily any amount of items and when requested melt them down using metallurgic and chemical processes.
The metals are melted into lumps of ore to server for the creation of tinkers.
Any remains are melted and turned into valuable materials.]],
	cost = 0, quest=true,

	carrier = {
		auto_id = 100,
		has_transmo = 1,
		has_transmo_orcs = 1,
	},

	no_drop = true,
	max_power = 1000, power_regen = 1,
	use_power = { name = _t"melt all the items in the APE at once (also done automatically when you change level)", 	power = 0,
		no_npc_use = true,
		use = function(self, who)
			if not who.player then return {id=true, used=false} end
			local inven = who:getInven("INVEN")
			local nb = 0
			for i = #inven, 1, -1 do
				local o = inven[i]
				if o.__transmo then nb = nb + 1 end
			end
			if nb <= 0 then
				local floor = game.level.map:getObjectTotal(who.x, who.y)
				if floor == 0 then
					if who:attr("has_transmo") >= 2 then
						require("engine.ui.Dialog"):yesnoPopup(_t"APE", _t"Make the Automated Portable Extractor the default item's destroyer?", function(ret) if ret then
							who.default_transmo_source = self
						end end)
					else
						require("engine.ui.Dialog"):simplePopup(_t"APE", _t"You do not have any items to melt in your APE or on the floor.")
					end
				else
					require("engine.ui.Dialog"):yesnoPopup(_t"APE", ("Melt all %d item(s) on the floor?"):tformat(floor), function(ret)
						if not ret then return end
						for i = floor, 1, -1 do
							local o = game.level.map:getObject(who.x, who.y, i)
							if who:transmoFilter(o, self) then
								game.level.map:removeObject(who.x, who.y, i)
								who:transmoInven(nil, nil, o, self)
							end
						end
					end)
				end
				return {id=true, used=true}
			end

			require("engine.ui.Dialog"):yesnoPopup(_t"APE", ("Melt all %d item(s) in your APE?"):tformat(nb), function(ret)
				if not ret then return end
				for i = #inven, 1, -1 do
					local o = inven[i]
					if o.__transmo then
						who:transmoInven(inven, i, o, self)
					end
				end
			end)
			return {id=true, used=true}
		end
	},

	on_pickup = function(self, who)
		who.default_transmo_source = self
	end,
	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}
