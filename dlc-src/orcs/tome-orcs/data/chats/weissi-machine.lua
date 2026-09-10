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

local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")

local set = function(what) return function(npc, player) npc["chat-progress-"..what] = true end end
local isNotSet = function(what) return function(npc, player) return not npc["chat-progress-"..what] end end

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*Before you is an extremely old looking machine. It seems to be infused with some sort of psionic energy; impossible as this sounds.
And it #{bold}#speaks#{normal}# to you!*#WHITE#
Welcome @playername@. We have been waiting for you.]],
	answers = {
		{_t"What are you?", jump="what", cond=isNotSet"what", action=function(npc, plauer) set("what")(npc, player) game.party:learnLore("weissi-1") end},
		{_t"Waiting for me?", jump="waiting", cond=isNotSet"waiting", action=set"waiting"},
		{_t"What do you need me for?", jump="for", cond=isNotSet"for", action=set"for"},
		{_t"I have muscle tissue for you.", jump="give", cond=function(npc, player)
			if not npc["chat-progress-what"] then return false end
			if not npc["chat-progress-for"] then return false end
			if not player:hasQuest("orcs+weissi") then return false end
			local o = player:findInInventoryBy(player:getInven("INVEN"), "yeti_muscle_tissue", true)
			return o and true or false
		end},
		{_t"[leave]"},
	}
}

newChat{ id="what",
	text = _t[[#LIGHT_GREEN#*You feel a powerful presence in your mind.*#WHITE#]],
	answers = {
		{_t"I see...", jump="welcome"},
	}
}

newChat{ id="waiting",
	text = _t[[Yes. We predict you will be useful to us. If you are not, another will be.]],
	answers = {
		{_t"I see...", jump="welcome"},
	}
}

newChat{ id="for",
	text = _t[[We require recent yeti muscle tissue from powerful specimens. You will help us, or you will not. Either way they will come to us.
If you do so we shall reward you with petty knowledge so that you may postpone your death.]],
	answers = {
		{_t"That is... generous of you.", jump="welcome", action=function(npc, player)
			player:grantQuest("orcs+weissi")
			player:setQuestStatus("orcs+weissi", engine.Quest.COMPLETED, "for")
		end},
	}
}

local talent_types = {
	physical = {
		"technique/conditioning",
		"technique/mobility",
		"cunning/survival",
		"cunning/scoundrel",
	},

	arcane = {
		"spell/divination",
		"spell/staff-combat",
		"celestial/chants",
		-- "celestial/light", -- shibari told me to remove it for mex ! ;)
		"chronomancy/chronomancy",
		"corruption/curses",
		"corruption/vile-life",
	},

	nature = {
		"psionic/dreaming",
		"psionic/augmented-mobility",
		"psionic/feedback",
		"wild-gift/antimagic",
		"wild-gift/call",
		"wild-gift/mindstar-mastery",
		"wild-gift/harmony",
	},
}

local talents = {
	physical = {
		Talents.T_VITALITY,
		Talents.T_UNFLINCHING_RESOLVE,
		Talents.T_EXOTIC_WEAPONS_MASTERY,
		Talents.T_HEIGHTENED_SENSES,
		Talents.T_DEVICE_MASTERY,
		Talents.T_TRACK,
		Talents.T_LACERATING_STRIKES,
		Talents.T_MISDIRECTION,
		Talents.T_DISARM,
	},

	arcane = {
		Talents.T_ARCANE_EYE,
		Talents.T_PREMONITION,
		Talents.T_VISION,
		Talents.T_CHANNEL_STAFF,
		Talents.T_STAFF_MASTERY,
		Talents.T_STONE_TOUCH,
		Talents.T_CHANT_OF_FORTITUDE,
		Talents.T_CHANT_OF_FORTRESS,
		Talents.T_PRECOGNITION,
		Talents.T_FORESIGHT,
		Talents.T_CURSE_OF_DEFENSELESSNESS,
		Talents.T_CURSE_OF_IMPOTENCE,
		Talents.T_CURSE_OF_DEATH,
	},

	nature = {
		Talents.T_NATURE_TOUCH,
		Talents.T_EARTH_S_EYES,
		Talents.T_PSIBLADES,
		Talents.T_THORN_GRAB,
		Talents.T_SLEEP,
		Talents.T_DREAM_WALK,
		Talents.T_RESOLVE,
		Talents.T_MANA_CLASH,
		Talents.T_SKATE,
		Talents.T_TELEKINETIC_LEAP,
		Talents.T_RESONANCE_FIELD,
		Talents.T_CONVERSION,
		Talents.T_MIND_SEAR,
		Talents.T_SPIT_POISON,
	},
}

local stats = {
	Stats.STAT_STR,
	Stats.STAT_DEX,
	Stats.STAT_CON,
	Stats.STAT_MAG,
	Stats.STAT_WIL,
	Stats.STAT_CUN,
}

local give_anwsers = {
	{_t"Talent categories", jump="learn_types"},
	{_t"Talents", jump="learn_talents"},
	{_t"Improved core stats", jump="learn_stats"},
}

newChat{ id="give",
	text = _t[[#LIGHT_GREEN#*The muscle tissue suddenly vanishes from your inventory.*#WHITE#
Thank you @playername@, this is indeed a suitable specimen. We shall honor our bargain with you. What do you wish to learn?]],
	answers = give_anwsers,
}
newChat{ id="give_re",
	text = _t[[What do you wish to learn?]],
	answers = give_anwsers,
}

on_learn = function(npc, player)
	local o, item = player:findInInventoryBy(player:getInven("INVEN"), "yeti_muscle_tissue", true)
	player:removeObject(player:getInven("INVEN"), item, true)
	player:sortInven()

	game:setAllowedBuild("tinker_psyshot", true)

	if not npc.next_lore_id then npc.next_lore_id = 2 end
	if npc.next_lore_id <= 5 then
		game.party:learnLore("weissi-"..npc.next_lore_id)
		if npc.next_lore_id == 5 then
			player:setQuestStatus("orcs+weissi", engine.Quest.COMPLETED)
		end
		npc.next_lore_id = npc.next_lore_id + 1
	end
end

-- Remove equipment if the player learns antimagic
remove_arcane_equipment = function(player)
	for inven_id, inven in pairs(player.inven) do
		for i = #inven, 1, -1 do
			local o = inven[i]
			if o.power_source and o.power_source.arcane then
				if o.wielded then game.logPlayer(player, "You cannot use your %s anymore; it is tainted by magic.", o:getName{do_color=true}) end
				local o = player:removeObject(inven, i, true)
				player:addObject(player.INVEN_INVEN, o)
				player:sortInven()
			end
		end
	end
end
------------------------------------------------------------
-- Hack for antimagic
------------------------------------------------------------
newChat{ id="learn_types_antimagic",
	text = _t[[Antimagic is a very special category. If you learn it you will never be able to use arcane powered items or talents again.
Do you still wish to take this path?]],
	answers = {
		{_t"No.", jump="learn_types"},
		{_t"Yes!", action=function(npc, player)
			local tt = "wild-gift/antimagic"
			game.party:reward(_t"Select the party member to receive the reward:", function(player)
				if player:knowTalentType(tt) == nil then player:setTalentTypeMastery(tt, 1.0) end
				player:learnTalentType(tt, true)
				player:attr("forbid_arcane", 1)

				for tid, _ in pairs(player.sustain_talents) do
					local t = player:getTalentFromId(tid)
					if t.is_spell then player:forceUseTalent(tid, {ignore_energy=true}) end
				end

				remove_arcane_equipment(player)
				-- player:hasQuest(npc.quest_id).reward_message = ("gained talent category %s (at mastery %0.2f)"):format(cat:capitalize().." / "..tt_def.name:capitalize(), mastery)
			end)
			on_learn(npc, player)
		end, on_select=function(npc, player)
			local tt = "wild-gift/antimagic"
			local tt_def = player:getTalentTypeFrom(tt)
			local cat = tt_def.type:gsub("/.*", "")
			game.tooltip_x, game.tooltip_y = 1, 1
			game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..(_t(cat, "talent category"):capitalize().." / "..tt_def.name:capitalize()).."#LAST#\n"..tt_def.description)
		end,
		},
	}
}
------------------------------------------------------------
------------------------------------------------------------

newChat{ id="learn_types",
	text = _t[[Very well. We can teach you a talent category; which do you want?]],
	answers = {
		{_t"Physical techniques", jump="learn_types_physical"},
		{_t"Arcane spells", jump="learn_types_arcane", cond=function(npc, player) return not player:attr("forbid_arcane") end},
		{_t"Nature/Psionic talents", jump="learn_types_nature"},
		{_t"Hum no let me change my mind.", jump="give_re"},
	}
}
for kind, types in pairs(talent_types) do
	local answers = {}
	for _, tt in ipairs(types) do if game.player:knowTalentType(tt) == nil then
		local tt_def = player:getTalentTypeFrom(tt)
		local cat = tt_def.type:gsub("/.*", "")
		if tt == "wild-gift/antimagic" and not player:attr("forbid_arcane") then
			table.insert(answers, {("[Allow training of talent category %s (at mastery %0.2f)]"):tformat(_t(cat, "talent category"):capitalize().." / "..tt_def.name:capitalize(), 1.0), jump="learn_types_antimagic", on_select=function(npc, player)
					game.tooltip_x, game.tooltip_y = 1, 1
					game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..(_t(cat, "talent category"):capitalize().." / "..tt_def.name:capitalize()).."#LAST#\n"..tt_def.description)
			end})
		else
			table.insert(answers, {("[Allow training of talent category %s (at mastery %0.2f)]"):tformat(_t(cat, "talent category"):capitalize().." / "..tt_def.name:capitalize(), 1.0), action=function(npc, player)
					game.party:reward(_t"Select the party member to receive the reward:", function(player)
						if player:knowTalentType(tt) == nil then player:setTalentTypeMastery(tt, 1.0) end
						player:learnTalentType(tt, true)
						-- player:hasQuest(npc.quest_id).reward_message = ("gained talent category %s (at mastery %0.2f)"):format(cat:capitalize().." / "..tt_def.name:capitalize(), mastery)
					end)
					on_learn(npc, player)
				end, on_select=function(npc, player)
					game.tooltip_x, game.tooltip_y = 1, 1
					game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..(_t(cat, "talent category"):capitalize().." / "..tt_def.name:capitalize()).."#LAST#\n"..tt_def.description)
				end,
			})
		end
	end end
	table.insert(answers, {_t"Hum no let me change my mind.", jump="give_re"})
	newChat{ id="learn_types_"..kind,
		text = _t[[Very well. We can teach you a talent.  Which do you want?]],
		answers = answers
	}
end

newChat{ id="learn_talents",
	text = _t[[Very well. We can teach you a talent; which type do you want?]],
	answers = {
		{_t"Physical techniques", jump="learn_talents_physical"},
		{_t"Arcane spells", jump="learn_talents_arcane", cond=function(npc, player) return not player:attr("forbid_arcane") end},
		{_t"Nature/Psionic talents", jump="learn_talents_nature"},
		{_t"Hum no let me change my mind.", jump="give_re"},
	}
}
for kind, tids in pairs(talents) do
	local answers = {}
	for _, tid in ipairs(tids) do local t = player:getTalentFromId(tid) local level = math.min(t.points - player:getTalentLevelRaw(tid), 1) if level > 0 then
		table.insert(answers, {("[%s talent %s (+%d level(s))]"):tformat(game.player:knowTalent(tid) and _t"Improve" or _t"Learn", t.name, level), action=function(npc, player)
				local function learn()
					game.party:reward(_t"Select the party member to receive the reward:", function(player)
						if player:knowTalentType(t.type[1]) == nil then player:setTalentTypeMastery(t.type[1], 1.0) end
						player:learnTalent(tid, true, level, {no_unlearn=true})
						if t.hide then player.__show_special_talents = player.__show_special_talents or {} player.__show_special_talents[tid] = true end
						if t.is_antimagic then remove_arcane_equipment(player) end
						-- player:hasQuest(npc.quest_id).reward_message = ("%s talent %s (+%d level(s))"):format(game.player:knowTalent(tid) and "improved" or "learnt", t.name, level)
					end)
					on_learn(npc, player)
				end

				if t.is_antimagic and not player:attr("forbid_arcane") then
					newChat{ id="learn_talent_"..t.id,
						text = _t[[Antimagic talents are very special. To learn one means you will never be able to use arcane powered items or talents again.
Do you still wish to take this path?]],
						answers = {
							{_t"No.", jump="learn_talents"},
							{_t"Yes!", action=function(npc, player)
								learn()
							end}					
						}
					}
					return "learn_talent_"..t.id
				else
					learn()
				end
			end, on_select=function(npc, player)
				game.tooltip_x, game.tooltip_y = 1, 1
				local mastery = nil
				if player:knowTalentType(t.type[1]) == nil then mastery = 1.0 end
				game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..t.name.."#LAST#\n"..tostring(player:getTalentFullDescription(t, 1, nil, mastery)))
			end,
		})
	end end
	table.insert(answers, {_t"Hum no let me change my mind.", jump="give_re"})
	newChat{ id="learn_talents_"..kind,
		text = _t[[Very well. We can teach you a talent (unlocking the talent category is separate). Which do you want?]],
		answers = answers
	}
end

do
	local answers = {}
	for _, i in ipairs(stats) do
		table.insert(answers, {("[Improve %s by +%d]"):tformat(player.stats_def[i].name, 4), action=function(npc, player)
				game.party:reward(_t"Select the party member to receive the reward:", function(player)
					player:incIncStat(i, 4)
					-- player:hasQuest(npc.quest_id).reward_message = ("improved %s by +%d"):format(npc.stats_def[i].name, reward.stats[i])
				end)
				on_learn(npc, player)
			end, on_select=function(npc, player)
				game.tooltip_x, game.tooltip_y = 1, 1
				local TooltipsData = require("mod.class.interface.TooltipsData")
				game:tooltipDisplayAtMap(game.w, game.h, TooltipsData["TOOLTIP_"..player.stats_def[i].short_name:upper()])
			end,
		})
	end
	table.insert(answers, {_t"Hum no let me change my mind.", jump="give_re"})
	newChat{ id="learn_stats",
		text = _t[[Very well. We can increase one of your core stats by 4, which one?]],
		answers = answers
	}
end

return "welcome"
