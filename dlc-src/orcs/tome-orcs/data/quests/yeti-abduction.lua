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

name = _t"Yeti Reinforcements"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"You found a yeti mind control tinker. If you can tame 8 wild yetis and send them back to Kruk Pride they can be trained and sent back to you at your request using a psychoportation beacon."
	desc[#desc+1] = _t"Wild yetis are mostly found in yeti's caves."
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t""
		desc[#desc+1] = _t"#LIGHT_GREEN#* Captured eight yetis (will be available to summon at level 20).#WHITE#"
	else
		desc[#desc+1] = _t""
		desc[#desc+1] = ("#LIGHT_GREY#* Captured %d/8 yetis.#WHITE#"):tformat((self.yeti_hacked or 0))
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game:setAllowedBuild("race_yeti", true)

		local o = mod.class.Object.new{
			power_source = {steam=true},
			type = "tinker", subtype = "steamtech",
			identified=true, no_unique_lore=true,
			name = _t"Yeti's Psychoportation Beacon", display = '*', color=colors.UMBER, unique=true, image = "object/artifact/yeti_beacon.png",
			desc = _t[[Call a trained yeti to your side.]],
			cost = 0, quest=true,
			encumber = 0,
			rarity = false,
			metallic = true,
			material_level = 4,
			special_desc = function(self) local q = game:getPlayer(true):hasQuest("orcs+yeti-abduction") return ("Yetis left to call: %d"):tformat(self.power) end,
			max_power = 8,
			power = 8,
			use_power = { power=1, name=_t"call a trained yeti for help", no_npc_use = true, use = function(self, who, inven, item)
				if who.level < 20 then game.log("The yetis are not ready yet.") return {id=true} end
				local m = game.zone:makeEntity(game.level, "actor", {name="yeti demolisher", base_list="mod.class.NPC:/data-orcs/general/npcs/yeti.lua"})
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
				if m and x then
					m.faction = who.faction
					m.remove_from_party_on_death = true
					game.zone:addEntity(game.level, m, "actor", x, y)
					m:forceLevelup(who.level)
					m:learnTalent(m.T_ACHIEVEMENT_MIND_CONTROLLED_YETI, true)
					if game.party:hasMember(who) then
						game.party:addMember(m, {control="no", type="summon", title=_t"Yeti", orders = {target=true, leash=true, anchor=true, talents=true}})
					end
					return {used=true, id=true}
				end
				return {id=true}
			end},
		}
		who:addObject(who.INVEN_INVEN, o)
		game.log("You extract the psychoportation beacon from the mind controller. Yetis will require some time to train before being usable.")
	end
end

function one_more(self, who)
	self.yeti_hacked = (self.yeti_hacked or 0) + 1
	if self.yeti_hacked >= 8 then
		who:setQuestStatus(self.id, engine.Quest.COMPLETED)
	end
end
