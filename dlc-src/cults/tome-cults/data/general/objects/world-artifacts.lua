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
local Talents = require "engine.interface.ActorTalents"

loadIfNot("/data-cults/general/objects/forbidden-tomes-base.lua")

--BOSS DROPS, Included here so they can appear elsewhere. I don't really want to make a new file for two items. --

newEntity{ base = "BASE_LIGHT_ARMOR",
	power_source = {nature=true, arcane=true},
	define_as = "SPINAL_CAGE", image = "object/artifact/spinal_cage.png",
	name = "Spinal Cage", unique=true,
	moddable_tile = "cults/upper_body_spinal_cage", moddable_tile2 = "cults/lower_body_spinal_cage",
	unided_name = _t"gross mass of spinal matter", color=colors.VIOLET,
	desc = _t[[A gross mass of spinal matter hastily assembled into armour.]],
	level_range = {5, 12},
	rarity = 200,
	cost = 500,
	material_level = 2,
	wielder = {
		inc_stats = { [Stats.STAT_DEX] = 2 },
		resists = { [DamageType.PHYSICAL] = 15 },
		combat_armor = 8,
		combat_def = 5,
		fatigue = 3,
	},

	max_power = 30, power_regen = 1,
	use_talent = { id = Talents.T_BONE_GRAB, level=2, power = 20 },
}

newEntity{ base = "BASE_LEATHER_CAP",
	power_source = {unknown=true},
	unique = true,
	name = "Infused Cerebrum",
	unided_name = _t"a disgusting pile of brain-matter", image = "object/artifact/infused_cerebrum.png",
	level_range = {34, 42},
	color=colors.GREEN,
	moddable_tile = "cults/infused_cerebrum",
	moddable_tile_big = true,
	encumber = 2,
	rarity = 250,
	desc = _t[[This #{italic}#headwear#{normal}# seems made entirely out of half-rotten brain matter. Do you really want to put that over your head?]],
	cost = 500,
	material_level = 4,
	wielder = {
		combat_def = 8,
		fear_immune = -0.6,
		inc_stats = { [Stats.STAT_WIL] = 12, [Stats.STAT_CUN] = 10, [Stats.STAT_MAG] = 10, },
		combat_mindpower = 12,
		combat_spellpower = 12,
	},
	max_power = 150, power_regen = 1,
	use_power = { name = _t"assault the mind of a foe to utterly dominate it", power = 100,
		use = function(self, who)
			local tg = {type="hit", range=3}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target or target.dead or target == who then return end
				if not target:canBe("instakill") or target.rank > 3 or target:attr("undead") or game.party:hasMember(target) or not target:checkHit(math.max(who:getWil(20, true), who:getMag(20, true)) + who.level * 1.5, target.level) then
					game.logSeen(target, "%s resists the mental assault!", target:getName():capitalize())
					return
			end
				target:takeHit(1, who)
				target:takeHit(1, who)
				target:takeHit(1, who)
				target:setEffect(target.EFF_DOMINANT_WILL, 6, {src=who})
			end)
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_RING",
	power_source = {unknown=true},
	unique = true,
	name = "Writhing Ring of the Hunter", color = colors.GREEN, image = "object/artifact/writhing_ring_of_the_hunter.png",
	unided_name = _t"green slimy ring",
	desc = _t[[A writhing mass of tentacles roughtly warped into the form of a ring. A dark malovelant power emanates from it.]],
	level_range = {30, 50},
	rarity = 250,
	cost = 1000,
	material_level = 4,
	special_desc = function(self) return _t"When first worn the ring attunes to you, letting you choose a prodigy it will forever grant while worn (can not be changed once chosen, re-wear it to select again if you refused to choose at first)." end,
	special = true,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, },
	},
	-- We want to control the horror more specifically than just combat state so it can despawn immediately when no enemies are around and not delay resting
	-- Note that while this can result in the hunter leaving/rejoining the level a lot it won't reset its cooldowns until normal combat is dropped
	checkHunterCombat = function(self, who)
		local grids = core.fov.circle_grids(who.x, who.y, 10, true)
		local found = false
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target = game.level.map(x, y, engine.Map.ACTOR)
				if target and target ~= self.current_horror and (target.ai_target and target.ai_target.actor and ( (target.ai_target.actor == who) or (target.ai_target.actor == who:resolveSource()) )) and who:reactionToward(target) < 0 then
					found = true
					break
				end
			end
		end
		return found
	end,
	on_cantakeoff = function(self, who)
		if who.in_combat then
			game.logPlayer(who, "#DARK_SEA_GREEN#While the ring senses battle it grips your finger so hard you can not take it off.")
			return true
		end
	end,
	createHunter = function(self, who)
		if not self.prodigy_granted then return end
		if game.zone.wilderness then return end
		if self.current_horror then self.current_horror:removeHunter() end

		local base_list = require("mod.class.NPC"):loadList("/data-cults/general/npcs/horror-special.lua")
		base_list.__real_type = "actor"
		local npc = game.zone:makeEntityByName(game.level, base_list, "THE_ONE_THAT_HUNTS")
		local x, y = util.findFreeGrid(who.x, who.y, 15, true, {[engine.Map.ACTOR]=true})
		if npc and x then
			game.zone:addEntity(game.level, npc, "actor", x, y)
			npc:setTarget(who)
			self.current_horror = npc
			npc:forceLevelup(who.level)
			npc.ring_actor = who
			npc.summoned_level = game.level -- Tracked for cases like Fearscape that don't trigger callbackOnLevelChange resulting in duplicates
			return npc
		end
	end,
	callbackOnCombat = function(self, who, combat)
		if not self.prodigy_granted then return end

		-- If we fully dropped combat reset the entire pet instead of just temporarily removing it from level (mostly relevant for ability cooldowns)
		if not combat and self.current_horror and not self:checkHunterCombat(who) then
			self.current_horror:removeHunter()
			self.current_horror = nil
		end
	end,
	callbackOnChangeLevel = function(self, who, mode, zone, level)
		if not self.prodigy_granted then return end
		if mode == "leave" and self.current_horror then
			self.current_horror:removeHunter()
			self.current_horror = nil
		end
	end,
	callbackOnAct = function(self, who)
		if not self.prodigy_granted then return end
		if self.current_horror then self.current_horror.timeout = 5 end
		if self:checkHunterCombat(who) then
			if self.current_horror and self.current_horror.is_gone and not game.level:hasEntity(self.current_horror) then
					-- Horror is only temporarily removed so don't recreate it
					local x, y = util.findFreeGrid(who.x, who.y, 15, true, {[engine.Map.ACTOR]=true})
					if x then
						self.current_horror.is_gone = nil
						self.current_horror.dead = nil
						game.zone:addEntity(game.level, self.current_horror, "actor", x, y)
						game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "shadow_beam", {tx=x-who.x, ty=y-who.y})
					end
				else
					self:createHunter(who)
			end
		else
			if self.current_horror then
				-- Temporarily remove the Hunter to preserve cooldown state
				self.current_horror:removeHunter()
				self.current_horror.is_gone = true
			end
		end
	end,
	callbackOnDeath = function(self, who)
		if not self.current_horror then return end
		self.current_horror:removeHunter()
		self.current_horror = nil
	end,
	on_takeoff = function(self, who)
		if not self.prodigy_granted then return end
		if not self.current_horror then return end
		self.current_horror:removeHunter()
		self.current_horror = nil
	end,
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subclass == "Writhing One" then
			local Stats = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","resists"}, { all = 8, }) 
			game.logPlayer(who, "#DARK_SEA_GREEN#As you put the %s on your finger, you feel more attuned to the horror within you.", self:getName({no_add_name = true, do_color = true}))
		end

		if not self.prodigy_granted then
			if who ~= game:getPlayer(true) then return end
			local d = require("mod.dialogs.RingOfTheHunter").new(self, who)
			game:registerDialog(d)
		else
			-- Just as if we entered combat
			if who.in_combat then self:callbackOnCombat(who, true) end
		end
	end,
}

newEntity{ base = "BASE_STAFF", define_as = "BONESTAFF",
	power_source = {arcane=true},
	unique = true,
	name = "Staff of Bones",
	flavor_name = "bonestaff",
	flavors = {bonestaff=true},
	unided_name = _t"bone staff", image = "object/artifact/bone_staff_of_the_necromancer.png",
	moddable_tile = "cults/%s_bone_staff_of_the_necromancer",
	level_range = {25, 35},
	color=colors.VIOLET,
	rarity = 190,
	desc = _t[[A staff made out of the bones of fallen foes. Disgustingly powerful.]],
	cost = 200,
	material_level = 3,

	is_bonestaff = true,
	has_command_staff_portrait = true,

	require = { stat = { mag=24 }, },
	combat = {
		dam = 20,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.DARKNESS,
		element = DamageType.DARKNESS,
		is_greater = true,
		melee_element = true,
		sentient = "bonestaff",
	},
	wielder = {
		combat_spellpower = 20,
		combat_spellcrit = 15,
		inc_damage={
			[DamageType.ACID] = 20,
			[DamageType.DARKNESS] = 20,
			[DamageType.COLD] = 20,
			[DamageType.BLIGHT] = 20,
		},
		learn_talent = {[Talents.T_COMMAND_STAFF] = 1},
		talents_types_mastery = {
			["spell/master-of-bones"] = 0.1,  
			["spell/master-of-flesh"] = 0.1,  
			["spell/nightfall"] = 0.1,  
			["spell/grace"] = 0.1,  
			["spell/necrosis"] = 0.1,  
			["spell/master-necromancer"] = 0.1,  
			["corruption/bone"] = 0.1,  
		}
	},
	special_desc = function(self) return _t"It seems willing and able to talk to you (use Command Staff)." end,
	callbackOnLevelup = function(self, who)
		local msg = rng.table{
			_t"Growing more powerful? Still pathetic compared to a True Necromancer!",
			_t"Ahh the rush of power... I love that!",
			_t"What feeble power you wield now is nothing!",
			_t"Yes yes you've leveled up, so what?",
			_t"One more level, that's hardly impressive you know?",
			_t"If you weren't so useless I'd be nearly impressed by that new level...",
		}
		who:setEmote(require("engine.Emote").new(_t(self.name)..': "'..msg..'"', 120, colors.VERY_DARK_RED))
		game.logPlayer(who, "#VERY_DARK_RED#".._t(self.name)..': "'..msg..'"')
	end,
	callbackOnKill = function(self, who, target)
		-- if not rng.percent(6) then return end
		local msg = rng.table{
			_t"KILL! KILL!",
			_t"We require more souls!",
			_t"Destroy them all! OBEY!",
			_t"FEED ME!",
			_t"I nee ..err.. you need more souls. Yes you...",
			_t"Pain and misery, spread them!",
			_t"I love the smell of a fresh corpse.",
			_t"Splatter me with the blood of our foes!",
			_t"That one wasn't such an impressive kill...",
			_t"Getting a bit sloppy on the kills no?",
		}
		local txt = ('%s: "%s"'):tformat(self:getName({do_color = true, no_add_name = true}), msg)
		who:setEmote(require("engine.Emote").new(txt, 120, colors.VERY_DARK_RED))
		game.logPlayer(who, "#VERY_DARK_RED#"..txt)
	end,
}

newEntity{ base = "BASE_FORBIDDEN_TOME",
	name = 'Forbidden Tome: "Of Knowledge And Horrors"', unique=true,
	image = "object/artifact/forbidden_tome_horror.png",
	desc = _t[[A gross tome of lost knowledge. Even touching it makes you feel sick.]],
	level_range = {30, 50},
	rarity = 300,
	cost = 500,
	material_level = 4,

	change_zone = "cults+ft-horrors",
	book_read_times = 1,
	book_level_min = 99999,
	book_texture = "book-texture-horrors",
	book_font = "Unquiet Spirits.ttf",
	book_font_style = "book_unquiet",
	book_text = _t[[The book of horrors,
the book of terrors,
the book of pain,
the book of gain,
the book of insanity,
the book of lunacy.

It which reads the book shall know pain beyond pain.
Read now for a fate worse than death inside awaits.
]],
}

-- newEntity{ base = "BASE_FORBIDDEN_TOME",
-- 	name = 'Forbidden Tome: "A Yaech\'s Dive"', unique=true,
	-- image = "object/artifact/forbidden_tome_water.png",
-- 	desc = _t[[How a single yaech managed to free her people from both a naga invasion and The Way clawing at their minds.]],
-- 	level_range = {30, 50},
-- 	-- rarity = 250, -- DGDGDGDG DO ME!
-- 	cost = 500,
-- 	material_level = 4,

-- 	change_zone = "cults+ft-yaech",
-- 	book_text = [[DGDGDGDG
-- ]],
-- 	book_make_party = function(self, who, party)
-- 		local player = require("mod.class.Player").new{
-- 			name = "Yirla", image = "npc/humanoid_yaech_yaech_psion.png",
-- 			type = "humanoid", subtype = "yaech", female = 1, display = '@', color = colors.LIGHT_BLUE,
-- 			descriptor = { sex="Female", race="Yeek", subrace="Yaech", class="Psionic", subclass="Psion", world="Maj'Eyal", difficulty=who.descriptor.difficulty, permadeath=who.descriptor.permadeath},
-- 			level_range = {1, 1}, exp_worth = 1,
-- 			__no_save_json = true,
-- 			no_inventory_access = true,
-- 			faction = "player",
-- 			can_change_level = true, can_change_zone = true,
-- 			body = {INVEN=10},
-- 		}
-- 		party:addMember(player, {
-- 			control="full",
-- 			type="player",
-- 			title=_t"Main protagonist",
-- 			main=true,
-- 			orders = {target=true, anchor=true, behavior=true, leash=true, talents=true},
-- 		})
-- 		party:setPlayer(player)
-- 	end,
-- }

newEntity{ base = "BASE_FORBIDDEN_TOME", define_as = "FT_ENTROPY",
	name = 'Forbidden Tome: "The Day It Came"', unique=true,
	image = "object/artifact/forbidden_tome_cultist.png",
	desc = _t[[The cover of this tome is old and withered. As you hold it, you get the impression of many things. Despair, misery, desperation and hopelessness all assail you at once. Something about the book also promises great power, but at what cost?]],
	level_range = {22, 50},
	rarity = 220,
	cost = 500,

	change_zone = "cults+ft-cultist",
	book_text = _t[[In the Age of Pyre, it seemed that the world was ending to many of Eyal's inhabitants. The destruction caused by the Spellblaze left the land withered and scorched. Food was scarce, paranoia was rampant and everyone was desperate. For a select few, their salvation came from an unlikely visitor. An entity they simply came to knew as The Teacher visited Eyal from somewhere beyond the stars, emerging from an ancient Sher'tul farportal. It discovered a group of survivors in the depths of Eyal which begged it for knowledge, anything they could use as a weapon against the horrors ravaging their world.]],
	book_font_size = 16,
	book_texture = "book-texture-impossible",
	book_on_party_death = "remake",
	book_party_dead_msg = function(self) if self.book_ended then return else return _t"Hithre died. Somehow this is not what should have happened." end end,
	book_make_party = function(self, who, party)
		local player = require("mod.class.Player").new{
			name = _t"Hithre", image = "player/shalore_female.png",
			type = "humanoid", subtype = "shalore", display = '@', color = colors.BLUE,
			descriptor = { sex="Female", race="Elf", subrace="Shalore", class="Demented", subclass="Cultist of Entropy", world="Maj'Eyal", difficulty=who.descriptor.difficulty, permadeath=who.descriptor.permadeath},
			female = 1,
			moddable_tile = "elf_#sex#",
			moddable_tile_base = "base_shalore_01.png",
			moddable_tile_ornament = {female="braid_02"},
			level_range = {1, 1}, exp_worth = 1,
			__no_save_json = true,
			no_inventory_access = true,
			no_levelup_access = true,
			allow_player_selffire = 1,
			is_student = 1,
			is_hithre = 1,
			life_regen = 0,
			faction = "sanctuary-of-horrors",
			can_change_level = true, can_change_zone = false,
			size_category = 3,
			lite = 25,
			sight = 25,
			body = {INVEN=10, BODY=1, MAINHAND=1, OFFHAND=1},
			stats = { str=10, dex=10, cun=20, mag=30, con=10, wil=15 },
			resolvers.talents{
				[who.T_ENTROPIC_GIFT] = 1,
			},
			resolvers.inscription("INFUSION:_HEALING", {cooldown=10, heal=450})
		}
		player:resolve() player:resolve(nil, true)

		party:addMember(player, {
			control="full",
			type="player",
			title=_t"Main protagonist",
			main=true,
			orders = {target=true, anchor=true, behavior=true, leash=true, talents=true},
		})
		party:setPlayer(player)

		party.on_dispose = function(self, newparty)
			local o, item, inven_id = newparty.player:findInAllInventoriesBy("define_as", "FT_ENTROPY")
			if not o or not o.book_ended then return end
			local list = {
				{name=_t"The importance of power (+3% spell critical chance)", effect=function() newparty.player:attr("combat_spellcrit", 3) end},
				{name=_t"The importance of thought (+10 spell save)", effect=function() newparty.player:attr("combat_spellresist", 10) end},
				{name=_t"The importance of magic (+5 magic)", effect=function() newparty.player:incIncStat("mag", 5) end},
				{name=_t"The importance of wisdom (+5 willpower)", effect=function() newparty.player:incIncStat("wil", 5) end},
			}
			require("engine.ui.Dialog"):listPopup(_t"The Day It Came", _t"This chapter has taught your some important lesson. What did you learn?", list, 400, 250, function(sel)
				if not sel then return end
				sel.effect()
				game:setAllowedBuild("demented_cultist_entropy", true)
			end)
			game.party:learnLore("cults-cultist-unlock-epilogue")
		end
	end,
}

newEntity{ base = "BASE_FORBIDDEN_TOME", define_as = "FT_GRUNG",
	name = 'Forbidden Tome: "A View From The Gallery"', unique=true,
	image = "object/artifact/forbidden_tome_grung.png",
	desc = _t[[The story of Grung, a halfling separated from his tribe that is just trying to survive while a terrible war, very long ago, rages on.]],
	level_range = {10, 25},
	rarity = 250,
	cost = 500,
	material_level = 2,

	change_zone = "cults+ft-haze-cave",
	book_text = _t[[It's a cold night and you did not find anything to eat during the day. Your fur pelt doesn't do much to keep the cold out either. You're about to go out to hunt, but everyone else has warned you that you must not do that. The night is dangerous and there appears to be strange lights in the sky. An ill omen, to say the least. Food has been hard to come by lately, so everyone is just as famished as you are.]],
	book_texture = "book-texture-fire",
	book_read_lore = "cults-ft-grung",
	book_on_party_death = "remake",
	book_party_dead_msg = function(self) if self.book_ended then return else return _t"Poor Grung. All he wanted was food, but what he found instead was death." end end,
	book_make_party = function(self, who, party)
		local player = require("mod.class.Player").new{
			name = _t"Grung", image = "npc/humanoid_halfling_grung.png",
			resolvers.nice_tile{tall=1},
			type = "humanoid", subtype = "halfling", display = '@', color = colors.UMBER,
			descriptor = { sex="Male", race="Halfling", subrace="Halfling", class="Rogue", subclass="Marauder", world="Maj'Eyal", difficulty=who.descriptor.difficulty, permadeath=who.descriptor.permadeath},
			level_range = {1, 1}, exp_worth = 1,
			__no_save_json = true,
			no_inventory_access = true,
			no_levelup_access = true,
			is_grung = true,
			life_regen = 3,
			faction = "grung-faction",
			can_change_level = true, can_change_zone = false,
			size_category = 2,
			lite = 7,
			body = {INVEN=10, BODY=1, MAINHAND=1, OFFHAND=1},
			stats = { str=20, dex=20, cun=15, mag=2, con=15, wil=15 },
			resolvers.talents{
				[who.T_THROW_PEEBLE] = 3,
				[who.T_SKIRMISHER_CUNNING_ROLL] = 25,
			},
		}
		player:resolve() player:resolve(nil, true)

		local old_u_weapon = game.uniques["mod.class.Object/Crooked Club"]
		local old_u_armor = game.uniques["mod.class.Object/Skin of Many"]
		local weapon = game.zone:makeEntityByName(game.level, "object", "CROOKED_CLUB", true) weapon.use_talent = nil
		local armor = game.zone:makeEntityByName(game.level, "object", "SKIN_OF_MANY", true)
		player:wearObject(weapon, true, true)
		player:wearObject(armor, true, true)
		game.uniques["mod.class.Object/Crooked Club"] = old_u_weapon
		game.uniques["mod.class.Object/Skin of Many"] = old_u_armor

		party:addMember(player, {
			control="full",
			type="player",
			title=_t"Main protagonist",
			main=true,
			orders = {target=true, anchor=true, behavior=true, leash=true, talents=true},
		})
		party:setPlayer(player)

		party.on_dispose = function(self, newparty)
			local o, item, inven_id = newparty.player:findInAllInventoriesBy("define_as", "FT_GRUNG")
			if not o or not o.book_ended then return end
			local list = {
				{name=_t"The importance of evading blows (+10 defense)", effect=function() newparty.player:attr("combat_def", 10) end},
				{name=_t"The importance of speed (+10% movement speed)", effect=function() newparty.player:attr("movement_speed", 0.1) end},
				{name=_t"The importance of reflexes (+5 dexterity)", effect=function() newparty.player:incIncStat("dex", 5) end},
				{name=_t"The importance of a honed mind (+5 cunning)", effect=function() newparty.player:incIncStat("cun", 5) end},
			}
			require("engine.ui.Dialog"):listPopup(_t"A View From The Gallery", _t"This chapter has taught your some survival tips. What did you learn?", list, 400, 250, function(sel)
				if not sel then return end
				sel.effect()
			end)
			world:gainAchievement("CULTS_AGE_HAZE", newparty.player)
		end
	end,
}

newEntity{ base = "BASE_FORBIDDEN_TOME",
	name = 'Forbidden Tome: "The Illusory Castle"', unique=true,
	image = "object/artifact/forbidden_tome_illusory.png",
	desc = _t[[The tome in front of you seems to be as much made of dreamstuff as it is from leather and parchment. Crystalline shards dance underneath its surface, giving you an impression of a world altering itself to the tune of some indiscernable logic.]],
	level_range = {20, 50},
	rarity = 250,
	cost = 500,

	change_zone = "cults+ft-illusory-castle",
	book_texture = "book-texture-illusory",
	book_read_lore = "cults-ft-illusory-castle",
	book_font_size = 17,
	book_text = _t[[The world inside the tome depicts a castle. At least, it gives the impression of a castle. It has a dreamlike feeling to it, enough so to make you wonder if you're awake or not. The glass walls shimmer brightly with countless brilliant lights, reflected from some unknown source.

Judging by the way the walls constantly shift and change themselves, you can be certain that this place will be difficult to explore.]],
}

newEntity{ base = "BASE_TOOL_MISC", define_as = "CUT_DREM_ARM",
	power_source = {unknown=true},
	unique=true, rarity=240,
	type = "misc", subtype="gross",
	name = "Cut Drem Arm", image = "object/artifact/cut_drem_arm.png",
	unided_name = _t"bloody arm",
	color = colors.RED,
	level_range = {20, 30},
	desc = _t[[The arm appears desiccated, but you swear that you see something wriggling underneath its ashen skin.]],
	cost = 320,
	material_level = 3,
	wielder = {
		on_melee_hit={[DamageType.DARKNESS] = 25},
		disarm_immune = 1,
	},
	special_desc = function(self) return _t"The arm can sometimes reach out to a foe in radius 5 and grab it to you with a tentacle pull. This action is not your own choice, it has a mind of its own." end,
	callbackOnAct = function(self, who)
		if game.zone.wilderness then return end
		if not rng.percent(15) then return end

		local tgts = {}
		who:project({type="ball", radius=5}, who.x, who.y, function(ppx, ppy)
			local a = game.level.map(ppx, ppy, engine.Map.ACTOR)
			if a and who:reactionToward(a) < 0 and core.fov.distance(ppx, ppy, who.x, who.y) > 1 then tgts[#tgts+1] = a end
		end)

		while #tgts > 0 do
			local target = rng.tableRemove(tgts)
			if target:canBe("knockback") then 
				local x, y = target.x, target.y
				target:pull(who.x, who.y, 5)

				local hx, hy = who:attachementSpot(who._flipx and "hand1" or "hand2", true)
				local ps = engine.Particles.new("tentacle_pull", 1, {range=core.fov.distance(who.x, who.y, x, y), dir=math.deg(math.atan2(y-who.y, x-who.x)+math.pi/2)})
				ps.dx = hx ps.dy = hy who:addParticles(ps)

				if not who.is_amalgamation then
					game.logSeen(who, "#DARK_SEA_GREEN#The %s reaches for %s with a tentacle!", self:getName{no_add_name = true, do_color = true}, target:getName())
				end
				break
			end
		end
	end,
}

newEntity{ base = "BASE_MASSIVE_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Monolith Armour", image = "object/artifact/monolith_armour.png",
	unided_name = _t"black stone armour",
	moddable_tile = "cults/upper_monolith_armour",
	moddable_tile2 = "cults/lower_monolith_armour",
	desc = _t[[This 'armour' seems to mostly consist of chunks of a rune etched stone somehow fused with a highly flexible black mesh. The titanic pieces of stone would undoubtedly deflect any blow thrown at you, but you would need obscene strength just to move while wearing this. The glyphs and runes carved into the chunks sometimes light up of their own accord, letting out small bursts of magic.]],
	color = colors.GREY,
	level_range = {40, 50},
	rarity = 320,
	require = { stat = { con=150 }, },
	cost = 500,
	material_level = 5,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = 15, [Stats.STAT_MAG] = 25, },
		combat_armor = 50,
		combat_def = 40,
		combat_physresist = 35,
		combat_spellresist = 35,
		combat_spellpower = 25,
		fatigue = 70,
		life_regen = 10,
		max_life = 270,
		resists={all = 10},
	},
	max_power = 30, power_regen = 1,
	special_desc = function(self) return _t"15% chance when hit to shatter reality around you creating rifts to help you (free cast of a Reality Fracture talent, level 4). This effect has a 30 turns cooldown.\n#PURPLE#If your constitution drops below requirement while using it, it is so heavy you will automatically unequip it. Beware.#LAST#" end,
	callbackOnTakeDamage = function(self, who, src, x, y, type, dam, state)
		if self.power < self.max_power then return end
		if not rng.percent(15) or dam < 1 then return end
		who:forceUseTalent(who.T_REALITY_FRACTURE, {no_talent_fail=true, ignore_energy=true, ignore_ressources=true, ignore_cd=true, force_level=4})
		self.power = 0
	end,
	callbackOnStatChange = function(self, who, stat, v)
		if who:getCon() < self.require.stat.con and not self.is_being_removed then
			game.logPlayer(who, "#LIGHT_RED#Your %s is too heavy to carry with your punny constitution anymore. You remove it.", self:getName{no_add_name = true, do_color = true})
			self.is_being_removed = true
			game:onTickEnd(function()
				local o, item_id, inven_id = who:findInAllWornInventoriesByObject(true, self)
				if item_id then 
					who:takeoffObject(inven_id, item_id) 
					who:addObject(who.INVEN_INVEN, o, true)
				end
				self.is_being_removed = false
			end)
			return
		end
	end,
}

newEntity{ base = "BASE_AMULET", define_as = "FANGED_COLLAR",
	power_source = {unknown=true},
	unique = true,
	name = "Fanged Collar", color = colors.YELLOW, image = "object/artifact/fanged_collar.png",
	unided_name = _t"a necklace with fangs",
	desc = _t[[This strange creature seems to melt around your neck, keeping its mouth open just wide enough so that its teeth do not touch you. You suspect that in the case your head somehow goes missing, the creature is going to make itself at home in your neck stump.]],
	level_range = {10, 25},
	rarity = 300,
	cost = 700,
	material_level = 2,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = 10,
			[Stats.STAT_WIL] = -5,
		},
		resists = {
			[DamageType.BLIGHT] = 15,
			[DamageType.DARKNESS] = 15,
			[DamageType.ACID] = 15,
		},
		combat_mentalresist = -7,
		combat_physresist = 15,
		combat_spellresist = 15,
		max_life = 20,
		death_dialog = "FangedCollarDeath",
	},
	special_desc = function(self) if self.on_cantakeoff then return _t"You have died, but that does not bother the collar at all..." else return _t"Try to not die..." end end,
}

newEntity{ base = "BASE_LONGSWORD", define_as = "ART_PAIR_PERSEVERANCE",
	power_source = {antimagic=true},
	unique = true,
	name = "Perseverance", image = "object/artifact/perseverence.png",
	unided_name = _t"always sharp blade",
	moddable_tile = "cults/%s_perseverence",
	moddable_tile_big = true,
	desc = _t[[It is said that the preferred weapons of the krog is a mace in one hand and a sword in the other. One hand to spread the message of the Zigurath, the other to see that message through to the end.
The sword symbolizes the krogs committment to their task of fighting against the forces of the arcane. With each slash the krog would endevor to continue, until at last their opponents would fall.]],
	level_range = {20, 35},
	rarity = 250,
	require = { stat = { str=24, wil=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 31,
		apr = 9,
		physcrit = 12,
		dammod = {str=0.9, wil=0.2},
		melee_project={[DamageType.MANABURN] = 15},
		special_on_crit = {desc=_t"restore 7 stamina and equilibrium", fct=function(combat, who, target)
			who:incStamina(7)
			who:incEquilibrium(-7)
		end}
	},
	wielder = {
		combat_spellresist = 18,
		confusion_immune = 0.3,
		stun_immune = 0.1,
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Krog" then
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["race/krog"] = 0.1 })
			self:specialWearAdd({"combat","dam"}, 12)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 15)
			game.logPlayer(who, "#LIGHT_BLUE#As you wear the sword you feel it attuning to your Krog body, increasing in power!")
		end
	end,
	set_list = { {"define_as","ART_PAIR_DEDICATION"} },
	set_desc = {
		dedication = _t"It is said perseverance comes hand in hand with dedication.",
	},
	max_power = 20, power_regen = 1,
	on_set_complete = function(self, who)
		self.use_talent = { id = "T_WHIRLWIND", level = 2, power = 20 }
		game.logSeen(who, "#AQUAMARINE#As the twin weapons of the Krogs are reunited you can feel bursting with power!")
	end,
	on_set_broken = function(self, who)
		self.use_talent = nil
		game.logPlayer(who, "#AQUAMARINE#The twin weapons of the Krogs de-power as you separate them.")
	end,
}

newEntity{ base = "BASE_MACE",
	power_source = {antimagic=true},
	name = "Dedication", define_as = "ART_PAIR_DEDICATION", image="object/artifact/dedication.png",
	unided_name = _t"always blunt mace", unique = true,
	moddable_tile = "cults/%s_dedication",
	desc = _t[[It is said that the preferred weapons of the krog is a mace in one hand and a sword in the other. One hand to spread the message of the Zigurath, the other to see that message through to the end.
The mace symbolizes the krogs willingness to endure until the final blow is struck against the arcane. Commonly the mace would be used to batter a mage senseless, thus preventing them from being able to cast their spells. ]],
	level_range = {20, 35},
	rarity = 250,
	require = { stat = { str=24, cun=24 }, },
	cost = 300,
	material_level = 3,
	combat = {
		dam = 31,
		apr = 6,
		physcrit = 20,
		dammod = {str=0.9, cun=0.2},
		burst_on_crit = {
			[DamageType.MANABURN] = 50,
		},
	},
	wielder = {
		resists = {
			[DamageType.ARCANE] = 15,
			[DamageType.BLIGHT] = 20,
		},
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subrace == "Krog" then
			self:specialWearAdd({"wielder", "talents_types_mastery"}, { ["race/krog"] = 0.1 })
			self:specialWearAdd({"combat","dam"}, 12)
			self:specialWearAdd({"wielder","combat_mentalresist"}, 15)
			game.logPlayer(who, "#LIGHT_BLUE#As you wear the mace you feel it attuning to your Krog body, increasing in power!")
		end
	end,
	set_list = { {"define_as","ART_PAIR_PERSEVERANCE"} },
	set_desc = {
		dedication = _t"It is said perseverance comes hand in hand with dedication.",
	},
	on_set_complete = function(self, who)
		self.wielder.learn_talent = { [who.T_DUAL_WEAPON_DEFENSE] = 2 }
	end,
	on_set_broken = function(self, who)
		self.wielder.learn_talent = nil
	end,
}

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {antimagic=true, psionic=true},
	unique=true, rarity=340,
	type = "charm", subtype="totem",
	name = "Persistent Will", image = "object/artifact/persistant_will.png",
	unided_name = _t"ever burning stake",
	color = colors.RED,
	level_range = {10, 25},
	desc = _t[[During the Age of Dusk a rash of anti-magic activities took place in the Nargol Kingdom immediately after the Spellblaze. Citizens would turn on those with magical powers, burning them alive on stakes of wood. When the authorities found the perpetrators they executed them and planted their heads on stakes throughout their capital city.
Despite this however, the citizenry continued to burn alive the enemies of nature. Unbeknownst to the authorities, the heads of the dead perpetrators continued to spread their message long after their deaths.

This stake of wood appears to one of those used to prop up one of the executed heads. It has seemingly absorbed the will of the head it propped up, and holding it you can hear the Ziguranth's message echo through your mind.]],
	cost = 300,
	material_level = 2,
	wielder = {
		inc_damage={[DamageType.MIND] = 12},
		inc_stats = {[Stats.STAT_WIL] = 8,},
		combat_mindpower = 10,
	},
	max_power = 25, power_regen = 1,
	use_power = {
		power = 25,
		name = function(self, who) return ("convince all non arcane users in radius 10 to turn on their spellcasting friends for 6 turns (chance increases with your Mindpower)"):tformat() end,
		range = 0,
		radius = 10,
		target = function(self, who) return {type="ball", range=self.use_power.range, radius=self.use_power.radius} end,
		requires_target = true,
		use = function(self, who)
			local tg = self.use_power.target(self, who)
			who:project(tg, who.x, who.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target or who:reactionToward(target) >= 0 or target:attr("has_arcane_knowledge") then return end
				target:setEffect(target.EFF_PERSISTANT_WILL, 6, {apply_power=who:combatMindpower()})
			end)
			game.level.map:particleEmitter(who.x, who.y, tg.radius, "shadow_flash", {radius=tg.radius})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {arcane=true},
	unique = true,
	name = "Worm Nest", color = colors.DARK_GREY, image = "object/artifact/worm_nest.png",
	moddable_tile = "cults/worm_nest",
	unided_name = _t"disgusting robe",
	desc = _t[[This unusually thick robe constantly wriggles and squirms. Small worms sometimes pop out of it, dropping to the floor. The worms will cushion attacks against your person, but you somehow do not like the idea of having so many parasitic creatures so close to your vulnerable flesh.]],
	level_range = {25, 38},
	rarity = 220,
	cost = 150,
	material_level = 4,
	wielder = {
		inc_damage = {[DamageType.BLIGHT]=22},
		inc_stats = { [Stats.STAT_MAG] = 15 },
		combat_spellcrit = 8,
		combat_spellpower = 15,
		flat_damage_armor = {all=22},
		movement_speed = 0.32,
	},
	max_power = 20, power_regen = 1,
	use_talent = { id = Talents.T_CARRION_FEET, level=3, power = 15 },
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.subclass == "Writhing One" then
			local Stats = require "engine.interface.ActorStats"

			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_CON] = 5, [Stats.STAT_CUN] = 5})
			self:specialWearAdd({"wielder","flat_damage_armor"}, {all=8})
			game.logPlayer(who, "#GREEN#The worms embed themselves easily in your mutated skin.")
		end
	end,
	-- Doesnt nto look good enough, sad :<
	-- on_wear = function(self, who)
	-- 	local Particles = require "engine.Particles"
	-- 	local hx, hy = who:attachementSpot("belly", true)
	-- 	if hx and hy then
	-- 		self._worm_particle = Particles.new("worm_nest", 1, {x=hx, y=hy})
	-- 		-- self._worm_particle.dx, self._worm_particle.dy = hx, hy
	-- 		who:addParticles(self._worm_particle)
	-- 	end
	-- end,
	-- on_takeoff = function(self, who)
	-- 	if self._worm_particle then
	-- 		who:removeParticles(self._worm_particle)
	-- 		self._worm_particle = nil
	-- 	end
	-- end,
}

newEntity{ base = "BASE_LITE",
	power_source = {unknown=true},
	unided_name = _t"disturbing lantern", unique = true, image="object/artifact/light_of_revalation.png",
	name = "Light of Revelation", color=colors.DARK_GREY,
	desc = _t[[The "lantern" appears to be a glowing shard of a glass-like substance. Despite how bright it is, its light deeply disturbs you. It illuminates everything in its wake, including things which you would rather not see. Part of you wants to throw it away, but another part wants to know the unearthly truths it will reveal to you.]],
	level_range = {8, 18},
	rarity = 500,
	encumber = 2,
	cost = 70,
	material_level = 2,

	wielder = {
		lite = 7,
		see_invisible = 35,
		see_stealth = 35,
		life = 30,
		resists_actor_type = {horror=25},
		inc_damage_actor_type = {horror=25},
	},
	special_desc = function(self) return _t"Sometimes reveals the hidden truths you'd rather not see." end,
	callbackOnDealDamage = function(self, who, dam, target)
		if target.rank >= 3 then return end -- Only works on crap foes
		if target.on_die then return end
		if target.type == "horror" then return end
		if who and who.reactionToward and who:reactionToward(target) > 0 then return end
		if not rng.percent(4) then return end
		if target.__light_revelation then return end
		target.__light_revelation = true

		game:onTickEnd(function()
			if self:attr("dead") then return end
			local horror = game.zone:makeEntity(game.level, "actor", {type="horror", subtype="eldritch", base_list="mod.class.NPC:/data/general/npcs/horror.lua"})
			if horror then
				local oldname = target.name
				local x, y = target.x, target.y
				local life_pct = target.life / target.max_life
				target:disappear(who)
				target:replaceWith(horror)
				game.zone:addEntity(game.level, target, "actor", x, y)
				target.life = target.max_life * life_pct
				game.bignews:say(120, "#YELLOW#Light of Revelation shines on %s revealing its true nature as %s!", oldname, target:getName())
			end
		end)
	end,
}

newEntity{ base = "BASE_GEM", define_as = "GLOWING_CORE",
	power_source = {arcane=true},
	unique = true,
	name = "Glowing Core", image = "object/artifact/glowing_core.png",
	unided_name = _t"burning core",
	level_range = {40, 50},
	color=colors.YELLOW,
	encumber = 1,
	identified = false,
	searing_horror_rarity = 1,
	material_level = 4,
	material_level_min_only = true,
	color_attributes = {
		damage_type = 'LIGHT',
		alt_damage_type = 'LIGHT_BLIND',
		particle = 'light',
	},
	desc = _t[[This is all that's left of the Searing Horror. Even after its death, the object in your hand glows just as brightly as it did before.]],
	cost = 450,

	carrier = {
		lite = 2,
	},
	wielder = {
		resists = {
			[DamageType.FIRE] = 50,
			[DamageType.LIGHT] = 50,
		},
		damage_affinity = {
			[DamageType.LIGHT] = 20,
			[DamageType.FIRE] = 20,
		},
		blind_immune = 1,
		see_invisible = 20,
	},
	imbue_powers = {
		lite = 4,
		resists = {
			[DamageType.FIRE] = 50,
			[DamageType.LIGHT] = 50,
		},
		damage_affinity = {
			[DamageType.LIGHT] = 20,
			[DamageType.FIRE] = 20,
		},
		blind_immune = 1,
		see_invisible = 20,
	},
}

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {unknown=true},
	unique = true,
	name = "Shoes of Moving Slowly", image = "object/artifact/shoes_of_moving_slowly.png",
	moddable_tile = "cults/shoes_of_moving_slowly",
	unided_name = _t"restful shoes",
	desc = _t[[Fast does not always win.

#GOLD#Rumoured to be able to combine with the Shoes of Moving Quickly.]],
	color = colors.PURPLE,
	level_range = {30, 40},
	rarity = 200,
	cost = 100,
	material_level = 4,
	special_desc = function(self) return _t"Each turn you spend not moving gain a buff for 2 defense and armour. Stacks up to 12 times." end,
	wielder = {
		combat_armor = 0,
		combat_def = 0,
		fatigue = 3,
		combat_spellpower = 5,
		inc_stats = { [Stats.STAT_MAG] = 8, [Stats.STAT_WIL] = 8,},
		knockback_immune = 1,
	},
	callbackOnAct = function(self, who)
		if not self.old_x then self.old_x, self.old_y = who.x, who.y return end
		
		if self.old_x == who.x and self.old_y == who.y then
			who:setEffect(who.EFF_SHOES_SLOWLY, 1, {})
		end

		self.old_x, self.old_y = who.x, who.y
	end,
	max_power = 20, power_regen = 1,
	use_simple = { name=_t"combine it with the Shoes of Moving Quickly", use = function(self, who, inven, item)
		if not who.player then return end
		local quick, quick_item, quick_inven_id = who:findInAllWornInventoriesBy(false, "define_as", "SHOES_OF_MOVING_QUICKLY")
		if not quick then game.logPlayer(who, "You need to have the Shoes of Moving Quickly in your inventory.") return end
		who:removeObject(quick_inven_id, quick_item, true)

		who:onTakeoff(self, inven, true)
		self.name = _t"Shoes of Slowly Moving Quickly"
		self.desc = _t"A wonder of footwear! You can set a shoe to stay in place while the other one goes very fast, spinning around to create tornados!"
		self.image = "object/artifact/shoes_of_slowly_moving_quickly.png"
		self.moddable_tile = "cults/shoes_of_slowly_moving_quickly"
		self.power_source.steam = true
		self.callbackOnMove = quick.callbackOnMove
		self.use_simple = nil
		self.wielder.combat_steampower = 5
		self.wielder.fatigue = 6
		self.wielder.pin_immune = 6
		self.wielder.inc_stats[who.STAT_CUN] = 8
		self.wielder.inc_stats[who.STAT_DEX] = 8
		self.special_desc = function(self) return _t"Each turn you spend not moving gain a buff for 2 defense and armour. Stacks up to 12 times.\nYou move 3 spaces at once." end
		self.use_talent = { id = who.T_TORNADO, level=3, power = 15 }
		self:removeAllMOs()
		who:onWear(self, inven, true)
		game.logPlayer(who, "As you combine the two pair of shoes you make something marvelous: %s", self:getName{do_color=true})

		return {used=true, id=true}
	end},
}

newEntity{ base = "BASE_ROD",
	power_source = {unknown=true},
	define_as = "ROD_ENTROPY",
	unided_name = _t"light sucking rod", image = "object/artifact/rod_of_entropy.png",
	name = "Rod of Entropy", color=colors.PURPLE, unique=true,
	desc = _t[[This rod seems to make light die around it. You feel tired just looking at it.]],
	cost = 200,
	level_range = {8, 20},
	rarity = 200,
	material_level = 2,
	max_power = 75, power_regen = 1,
	carrier = {
		lite = -1,
	},
	use_power = {
		name = function(self, who) return ("temporarily causes the target to receive entropic backlash from any healing they receive for %d turns up to %d%% of the healing done. This effect scales with your Magic stat."):
			tformat(self.use_power.duration, self.use_power.getpower(self, who))
		end,
		getpower = function(self, who) return 50 + who:getMag() end,
		power = 75,
		duration = 6,
		range = 7,
		requires_target = true,
		target = function(self, who) return {type="bolt", range=self.use_power.range} end,
		tactical = { ANNOY = 1 },
		use = function(self, who)
			local tg = self.use_power.target(self, who)
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			game.logSeen(who, "%s activates %s %s!", who:getName():capitalize(), who:his_her(), self:getName({no_add_name = true, do_color = true}))
			who:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:setEffect(target.EFF_ENTROPIC_ROD, 10, {src=who, power=self.use_power.getpower(self, who), apply_power=who:combatSpellpower()})
			end, 1, {type="slime"})
			return {id=true, used=true}
		end
	},
}

newEntity{ base = "BASE_MINDSTAR",
	power_source = {unknown=true, nature=true, psionic=true},
	unique = true,
	name = "Seeds of the Black Tree",
	unided_name = _t"corrupt stone",
	moddable_tile = "cults/%s_seeds_of_the_black_tree",
	level_range = {25, 35},
	color=colors.DARK_SEA_GREEN, image = "object/artifact/seeds_of_the_black_tree.png",
	rarity = 320,
	desc = _t[[This writhing mass of tentacles appears to have infested a mindstar, creating some bizarre fusion between natural and unnatural. The once clear gem now seems more like a shard of black obsidian with tentacles striking out from it like whips. You do not want to think of the implications of this horror being able to fuse with Nature itself.]],
	cost = 280,
	require = { stat = { wil=28, mag=20 }, },
	material_level = 4,
	combat = {
		dam = 17,
		apr = 27,
		physcrit = 5,
		dammod = {wil=0.4, mag=0.3},
		damtype = DamageType.DARKNESS,
		special_on_hit = {desc=_t"15% chance to cast Tendrils Eruption level 3 on your target", fct=function(combat, who, target)
			if not rng.percent(15) then return end
			who.override_tentacle_combat_oneshot = {
				talented = "tentacles",
				damtype = engine.DamageType.DARKNESS,
				dam = 30,
				apr = 7,
				dammod = {wil=0.6, mag=0.6},
				damrange = 1.4,
				physcrit = 9,
				physspeed = 1,
				sound = {"actions/tentacle_attack"}, sound_miss = {"actions/tentacle_attack", pitch=0.6},
			}
			who:forceUseTalent(who.T_TENDRILS_ERUPTION, {ignore_cd=true, ignore_energy=true, force_target=target, force_level=3, ignore_ressources=true})
		end},
	},
	wielder = {
		combat_mindpower = 12,
		combat_mindcrit = 12,
		combat_spellpower = 12,
		combat_spellcrit = 12,
		inc_damage={
			[DamageType.MIND] 	= 10,
			[DamageType.BLIGHT] 	= 10,
			[DamageType.DARKNESS] 	= 10,
		},
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_MAG] = 6, },
	},
}
