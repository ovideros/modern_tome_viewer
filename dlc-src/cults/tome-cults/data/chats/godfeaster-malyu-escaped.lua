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

local function finish(mode)
	game.state.cults_malyu_reward_mode = mode
	return function(npc, player)
		world:gainAchievement("CULTS_ESCORTED", player)
	end
end

local talent_name = "---"
local cat_name = "---"

local cat_list = {}
for kind, status in pairs(player.talents_types) do if status == true then
	local tt = player:getTalentTypeFrom(kind)
	if tt and tt.generic then cat_list[#cat_list+1] = tt.type end
end end
if #cat_list > 0 then cat_name = rng.table(cat_list) end

local talent_list = {}
for tid, lvl in pairs(player.talents) do
	local t = player:getTalentFromId(tid)
	if not t.generic and not t.is_inscription and t.hide ~= "always" and not t.cant_steal and not t.no_npc_use then
		talent_list[#talent_list+1] = {name=t.name, lvl=lvl}
	end
end
table.sort(talent_list, "lvl")
if #talent_list > 0 then talent_name = rng.table(talent_list).name end

newChat{ id="welcome",
	text = _t[[#DARK_SEA_GREEN##{italic}#Fresh air!#{normal}##LAST#
Nice job! You handled yourself a lot better than I thought you would. Now, usually I get a reward... What? Why are you looking at me like that? I'm obviously the one who saved you here. It's customary for adventurers to get rewarded when they do a good deed.]],
	answers = {
		{("[Offer to teach her '%s'.]"):tformat(talent_name), jump="talent", action=finish("talent")},
		{("[Offer to teach her '%s'.]"):tformat(cat_name), jump="category", action=finish("category")},
		{_t"[Offer her stat increases.]", jump="stats", action=finish("stats")},
		{_t"[Offer her nothing.]", jump="nothing", action=finish("nothing")},
	}
}

newChat{ id="talent",
	text = _t[[Oh this will sure come in handy! Thanks!]],
	answers = {
		{_t"Take care!"},
	}
}

newChat{ id="category",
	text = _t[[I always did want to learn how to do these kind of things!]],
	answers = {
		{_t"Take care!"},
	}
}

newChat{ id="stats",
	text = _t[[Oh, I suddenly feel like I have potential to grow.]],
	answers = {
		{_t"Take care!"},
	}
}

newChat{ id="nothing",
	text = _t[[...Fine, be that way. Good luck out there, though.]],
	answers = {
		{_t"You too!"},
	}
}

return "welcome"
