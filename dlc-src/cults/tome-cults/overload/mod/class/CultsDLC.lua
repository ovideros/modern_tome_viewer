-- ToME - Tales of Maj'Eyal:
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

local class = require "class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local NameGenerator = require "engine.NameGenerator"
local Tiles = require "engine.Tiles"

module(..., package.seeall, class.make)

-------------------------- Hooks -----------------------

function hookLoad()
	local Birther = require "engine.Birther"
	local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
	local ActorTalents = require "engine.interface.ActorTalents"
	local WorldAchievements = require "mod.class.interface.WorldAchievements"
	local PartyLore = require "mod.class.interface.PartyLore"
	local ActorResource = require "engine.interface.ActorResource"
	local ActorInventory = require "engine.interface.ActorInventory"
	local ActorAI = require "engine.interface.ActorAI"
	local Store = require "mod.class.Store"
	local FontPackage = require "engine.FontPackage"
	FontPackage:loadDefinition("/data/font/packages/cults-dlc.lua")

	defineColor('INSANE_GREEN', 0x00, 0x65, 0x61)

	ActorResource:defineResource(_t"Insanity", "insanity", "T_INSANITY_POOL", "insanity_regen", _t"Your mental insanity.  The higher it is the more random your damage and cooldowns become.\n\nDamage and cooldowns have a chance to increase or decrease by up to chaotic%.\n\nBoth the chance and size of effects will increase with insanity.", 0, nil, {
		color = "#INSANE_GREEN#",
		restore_factor = 0.15,
		status_text = function(act)
			return ("%d%%%% (%d%%%% chaotic)"):tformat(act:getInsanity(), act:insanityEffectForce())
		end,
	})
	ActorTalents:loadDefinition("/data-cults/talents.lua")
	
	dofile("/data-cults/resolvers.lua")
	dofile("/data-cults/factions.lua")
	ActorAI:loadDefinition("/data-cults/ai/")
	DamageType:loadDefinition("/data-cults/damage_types.lua")

	ActorInventory.equipdolls.wtw_buddy = { w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64, doll_w=128, doll_h=128, list={
		MAINHAND = {{weight=1, x=48, y=120}},
		OFFHAND = {{weight=2, x=48, y=192}},
		BODY = {{weight=3, x=48, y=264}},
		TOOL = {{weight=13, x=264, y=120}},
		BELT = {{weight=11, x=264, y=264}},
		FINGER = {{weight=6, x=48, y=408, subshift="left"}, {weight=7, x=124, y=408, text="bottom", subshift="left"}, {weight=8, x=188, y=408, subshift="right"}, {weight=9, x=264, y=408, subshift="right", text="bottom"}},
	}}
	ActorInventory.equipdolls.cults_beheaded = table.clone(ActorInventory.equipdolls.default, true)
	ActorInventory.equipdolls.cults_beheaded.list.HEAD = nil

	WorldAchievements:loadDefinition("/data-cults/achievements/")

	-- ActorTalents:loadDefinition("/data-cults/talents/corruptions/corruptions.lua")
	ActorTemporaryEffects:loadDefinition("/data-cults/timed_effects.lua")
	Birther:loadDefinition("/data-cults/birth/drem.lua")
	Birther:loadDefinition("/data-cults/birth/krog.lua")
	Birther:loadDefinition("/data-cults/birth/demented.lua")
	Birther:loadDefinition("/data-cults/birth/wilder.lua")
	Birther:loadDefinition("/data-cults/birth/misc.lua")

	PartyLore:loadDefinition("/data-cults/lore/misc.lua")
	PartyLore:loadDefinition("/data-cults/lore/zones.lua")
	PartyLore:loadDefinition("/data-cults/lore/kroshkkur.lua")
	PartyLore:loadDefinition("/data-cults/lore/dremwarves.lua")
	PartyLore:loadDefinition("/data-cults/lore/fay-willows.lua")

	Store:loadStores("/data-cults/general/stores/cults.lua")
	if Store.stores_def.ELVALA_LIBRARY then
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK1_CHAPTER1"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK1_CHAPTER2"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK1_CHAPTER3"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK1_CHAPTER4"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK1_CHAPTER5"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK1_CHAPTER6"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK4_CHAPTER1"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK4_CHAPTER2"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK4_CHAPTER3"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK4_CHAPTER4"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK4_CHAPTER5"})
		table.insert(Store.stores_def.ELVALA_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK4_CHAPTER6"})
	end
	if Store.stores_def.ZIGUR_LIBRARY then
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK2_CHAPTER1"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK2_CHAPTER2"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK2_CHAPTER3"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK2_CHAPTER4"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK2_CHAPTER5"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK2_CHAPTER6"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK3_CHAPTER1"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK3_CHAPTER2"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK3_CHAPTER3"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK3_CHAPTER4"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK3_CHAPTER5"})
		table.insert(Store.stores_def.ZIGUR_LIBRARY.store.fixed, {id=true, defined="FAY_WILLOWS_BOOK3_CHAPTER6"})
	end

	loadSequenceEffects("/data-cults/glyph_sequences/cults.lua")
	loadSequenceEffects("/data-cults/glyph_sequences/orcs.lua")

	Tiles:loadTileset("/data/gfx/ts-gfx-cults.lua")
end

function hookRunDone(self, data)
	-- Try to fix the player's that have worm a buggy WTW robe
	if game.party then
		for p, _ in pairs(game.party.members) do
			local o, item, inven_id = p:findInAllWornInventoriesBy(true, "define_as", "ROBE_OF_THE_WORM")
			if o and not p.is_wtw_buddy and not p.is_wtf_buddy then
				o.wtw_can_takeoff = true
			end
		end
	end
end

function hookBirthDone(self, data)
	-- Register some "hidden" glyph sequences, for lucky people
	for i = 1, 3 do
		local list = makeGlyphsSequence()
		registerGlyphsSequence(list, "RANDOM_ARTIFACT"..i)
	end
end

function hookMapGeneratorStaticSubgenRegister(self, data)
	-- Not for now, stupid people can find a way to inject stuff... frelling people
	--[[
	if data.mapfile ~= "zones/shertul-fortress" then return end

	data.list[#data.list+1] = {
		x = 0, y = 0, w = 60, h = 60, overlay = true,
		generator = "engine.generator.map.Static",
		data = {
			map = "cults+fortress-multiverse",
		},
	}
	]]
end

function hookEntityLoadList(self, data)
	if type(game) ~= "table" then return end

	if data.file == "/data/general/objects/objects.lua" then
		self:loadList("/data-cults/general/objects/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/objects/lore/maj-eyal.lua" or data.file == "/data-orcs/general/objects/lore.lua" then
		self:loadList("/data-cults/general/objects/lore/eyal.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/zones/shertul-fortress/grids.lua" then
		self:loadList("/data-cults/general/grids/fortress-multiverse.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/npcs/horror.lua" then
		self:loadList("/data-cults/general/npcs/horror.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/npcs/humanoid_random_boss.lua" then
		self:loadList("/data-cults/general/npcs/humanoid_random_boss.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/encounters/maj-eyal.lua" and game:isCampaign("Maj'Eyal") then
		self:loadList("/data-cults/general/encounters/maj-eyal.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data-orcs/general/encounters/fareast.lua" and game:isCampaign("Orcs") then
		self:loadList("/data-cults/general/encounters/var-eyal.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data-tareyal/general/encounters/tar-eyal.lua" and game:isCampaign("TarEyal") then
		self:loadList("/data-cults/general/encounters/tar-eyal.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/general/stores/basic.lua" then
		self:loadList("/data-cults/general/stores/addons.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/zones/town-elvala/objects.lua" then
		self:loadList("/data-cults/general/zones-alters/elvala.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/zones/town-zigur/objects.lua" then
		self:loadList("/data-cults/general/zones-alters/zigur.lua", data.no_default, data.res, data.mod, data.loaded)
	elseif data.file == "/data/zones/dreadfell/objects.lua" then
		self:loadList("/data-cults/general/zones-alters/dreadfell.lua", data.no_default, data.res, data.mod, data.loaded)
	end
end

local fonts_zones = {
	["crypt-kryl-feijan"] = {["cults+font-knowledge"] = {percent=5}},
	["high-peak"] = {["cults+glyphs-sequence"] = {percent=100, level_range=function() local l = rng.range(3, 8) return {l, l} end, params={kind="ENTROPIC_VOID"}}},

	-- Embers of Rage
	["orcs+sumblering-caves"] = {
		["cults+font-knowledge"] = {percent=5},
		["cults+glyphs-sequence"] = {percent=100, level_range=function() local l = rng.range(2, 4) return {l, l} end, params={kind="ENTROPIC_VOID"}},
	},

	["old-forest"] = {
		["cults+tentacle-tree"] = {percent=7},
	},
	["daikara"] = {
		["cults+tentacle-tree"] = {percent=7},
	},
	["maze"] = {
		["cults+tentacle-tree"] = {percent=7},
	},
	["crypt-kryl-feijan"] = {
		["cults+tentacle-tree"] = {percent=5},
	},
	["reknor"] = {
		["cults+tentacle-tree"] = {percent=35},
	},
	["eruan"] = {
		["cults+tentacle-tree"] = {percent=5},
	},
	["valley-moon-caverns"] = {
		["cults+tentacle-tree"] = {percent=10},
	},
	["mark-spellblaze"] = {
		["cults+tentacle-tree"] = {percent=70},
	},

	-- Embers of Rage
	["orcs+ritch-hive"] = {
		["cults+tentacle-tree"] = {percent = 7, forbid={4}},
	},
	["orcs+cave-hatred"] = {
		["cults+tentacle-tree"] = {percent = 7},
	},
	["orcs+krimbul"] = {
		["cults+tentacle-tree"] = {percent = 7, forbid={3}},
	},
	["orcs+lost-city"] = {
		["cults+tentacle-tree"] = {percent = 7, forbid={3}},
	},
	["orcs+ureslak-host"] = {
		["cults+tentacle-tree"] = {percent = 50},
	},
	["orcs+yeti-caves"] = {
		["cults+tentacle-tree"] = {percent = 3},
	},
}

function hookZoneLoadEvents(self, data)
	if data.zone == "ambush" then
		if rng.percent(game.state.cults_slow_patrol_glyph_chance or 10) then
			data.events[#data.events+1] = {name="cults+glyphs-sequence", percent=100, minor=true, params={kind="SLOW_PATROLS"}}
		else
			game.state.cults_slow_patrol_glyph_chance = (game.state.cults_slow_patrol_glyph_chance or 10) + 7
		end
		return
	end

	-- Spaceship can happen in any open-sky zone, in zones that already have events (to avoid messing with very special ones)
	if self.day_night and #data.events > 0 and data.zone ~= "wilderness" and not data.zone:find("^town%-") and game.player.level >= 10 then
		data.events[#data.events+1] = {name="cults+space-dwarf-ship", percent=5}
		-- data.events[#data.events+1] = {name="cults+space-dwarf-ship", percent=100}
	end

	-- Random stuff to add
	if fonts_zones[data.zone] then
		for kind, d in pairs(fonts_zones[data.zone]) do
			local level_range = nil
			if d.level_range then
				if type(d.level_range) == "table" then level_range = d.d.level_range
				else level_range = d.level_range()
				end
			end
			data.events[#data.events+1] = {name=kind, minor=true, percent=d.percent, level_range=level_range, params=d.params}
		end
	end

	-- Brain in jar code
	if game:isAddonActive("orcs") and data.zone == "vor-armoury" and (game.player:knowTalentType("steamtech/physics") or game.player:knowTalentType("steamtech/chemistry")) then
		data.events[#data.events+1] = {name="cults+glyphs-sequence", minor=true, percent=100, level_range={1, 1}, params={kind="BRAIN_IN_JAR"}}
	end
end

function hookBonusZone(self, data)
	data.add("Maj'Eyal", "wilderness", "cults+scourged-pits", nil, function() return not game:isAllowedBuild("wyrmic_scourge") and game:getPlayer(true):hasDescriptor("subrace", "Drem") end)
end

-- 10% chance to replace glowing chests anywhere with digestive sacks, yummy !
function hookGameStateMakeEventName(self, data)
	if data.sub ~= "" then return end
	if data.name ~= "glowing-chest" then return end
	if rng.percent(90) then return end
	data.file = "/data-cults/general/events/digestive-sack.lua"
end

function hookPossessorBirthBodies(self, data)
	if data.desc.subrace == "Drem" then
		data.extra_types.horror = true
		local m = {name="grannor'vin", base_list="mod.class.NPC:/data/general/npcs/horror-corrupted.lua"}
		if m then data.bodies[#data.bodies+1] = m end
		return true
	elseif data.desc.subrace == "Krog" then
		data.extra_types.dragon = true
		local m = {name="storm drake", base_list="mod.class.NPC:/data/general/npcs/storm-drake.lua"}
		if m then data.bodies[#data.bodies+1] = m end
		return true
	end
end

function hookPossessorBodySnatcherSetupBody(self, data)
	data.body.demented_wtw = nil
end

function hookGameOptionsGenerateList(self, data)
	if data.kind == "misc" then
		local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=(_t"Use the book-like display for Forbidden Tomes. This option requires both framebuffers and shaders to be active in the video options.#WHITE#"):toTString()}
		data.list[#data.list+1] = { zone=zone, name=(_t"#GOLD##{bold}#Forbidden Cults: Use Book visual for forbidden tomes#WHITE##{normal}#"):toTString(), status=function(item)
			return tostring(not config.settings.tome.cults_disable_book_zone and _t"enabled" or _t"disabled")
		end, fct=function(item)
			config.settings.tome.cults_disable_book_zone = not config.settings.tome.cults_disable_book_zone
			game:saveSettings("tome.cults_disable_book_zone", ("tome.cults_disable_book_zone = %s\n"):format(tostring(config.settings.tome.cults_disable_book_zone)))
			self.c_list:drawItem(item)
		end,}	
	end
end

function hookBirtherDonatorTiles(self, data)
	data.list[#data.list+1] = "npc/horror_eldritch_disfigured_creature.png"
	data.list[#data.list+1] = "npc/horror_eldritch_drem_cultist.png"
	data.list[#data.list+1] = "npc/horror_eldritch_drem_seeker_of_knowledge.png"
	data.list[#data.list+1] = "npc/horror_eldritch_drem_seeker_of_knowledge_female.png"
	data.list[#data.list+1] = "npc/horror_eldritch_the_conjointed.png"
	data.list[#data.list+1] = "npc/horror_eldritch_the_crawler.png"
	data.list[#data.list+1] = "npc/horror_eldritch_the_face_of_the_deep.png"
	data.list[#data.list+1] = "npc/horror_eldritch_the_one_that_defends.png"
	data.list[#data.list+1] = "npc/humanoid_shalore_malyu.png"
end

function hookChatLoad(self, data)
	if self.player.cults_fanged_parasite then
		local good_meal = function(action)
			return function(npc, player)
				if action then action(npc, player)
				else npc:die(player) end
				game.log("#CRIMSON#This was a very satisfying meal, 'you' feel strengthened. (+1 generic talent point)")
				player.unused_generics = player.unused_generics + 1
			end
		end
		if self.name == "orcs+destructicus" then
			self.deeply_altered = true
			self.chats.next.answers = {
				{_t"#CRIMSON#[The parasite loves death and pain and gives no choice but to shoot down the airship]", jump="shoot_airship", switch_npc=self.chats.next.answers[1].switch_npc},
			}
		elseif self.name == "melinda-fortress" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{_t"#CRIMSON#[The parasite is hungry and promptly swallows and eat Melinda].", action=good_meal()},
			}
		elseif self.name == "fallen-aeryn" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{_t"#CRIMSON#[The parasite is hungry and promptly swallows and eat Aeryn].", action=good_meal(self.chats.welcome.answers[3].action)},
			}
		elseif self.name == "slasul" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{_t"#CRIMSON#[The parasite is hungry and attacks Slasul].", action=self.chats.welcome.answers[1].action},
			}
		elseif self.name == "escort-quest-start" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{("#CRIMSON#[The parasite is hungry and promptly swallows and eat %s]."):tformat(self.npc.name), action=good_meal()},
			}
		elseif self.name == "assassin-lord" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{_t"#CRIMSON#[The parasite is hungry and takes over the conversation.]#LAST# I smelled a weakling here and wanted a nice meal. [point your finger at the captured merchant]", jump="parasite-hungry"},
			}
			self:addChat{ id="parasite-hungry",
				text = _t"Ah I see, you are a ...thing... of special tastes. Very well, I'd rather have you as a friend so have your meal and someday we may have some more business to do together.",
				answers = {
					{_t"[eat the merchant]", action=good_meal(self.chats.offer.answers[1].action)},
				}
			}
		elseif self.name == "unremarkable-cave-fillarel" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{_t"#CRIMSON#[The parasite is hungry and promptly swallows and eat Fillarel]#LAST# No I have not...", action=good_meal()},
			}
		elseif self.name == "yeek-wayist" then
			self.deeply_altered = true
			self.chats.welcome.answers = {
				{_t"#CRIMSON#[The parasite is hungry and promptly swallows and eat the yeek wayist]#LAST# I 'saved' you to get a nice meal...", action=good_meal()},
			}
		end
	end
end

-------------------------- Forbidden Tomes --------------------------
function handleBookTransition(tome, actor)
	if game.level.data.no_planechange then
		game.log("#RED#You can't enter a Forbidden Tome from here!#LAST#")
		return
	end

	if tome.book_make_party then
		if (not tome.book_party) or (tome.book_party.player:attr("dead") and tome.book_on_party_death == "remake") then
			local party = require("mod.class.Party").new{temporary_party=true, on_game_end=function()
				if game.zone.book_source.book_party_dead_msg then
					local msg = game.zone.book_source.book_party_dead_msg
					if type(msg) == "function" then msg = msg(game.zone.book_source) end
					if msg then require("engine.ui.Dialog"):simplePopup(game.zone.name, msg) end
				end
				game:changeLevelReal(1, "useless", {temporary_zone_shift_back=true})
			end}
			tome.book_make_party(tome, actor, party)
			tome.book_party = party
		elseif tome.book_party.player:attr("dead") and tome.book_on_party_death == "close" then
			require("engine.ui.Dialog"):simplePopup(tome.name, tome.book_party_already_dead_msg or _t"The protagonist of the story is dead.")
			return
		end
	end

	game:changeLevel(tome.change_level or 1, tome.change_zone, {temporary_zone_shift_party=tome.book_party, temporary_zone_shift=true, temporary_zone_shift_save_pos=true, direct_switch=true})
	game.zone.book_source = tome
	world:gainAchievement("CULTS_READ_FORBIDDEN_TOME", actor)

	if tome.book_read_times then
		if tome.book_read_times > 1 then
			tome.book_read_times = tome.book_read_times - 1
		else
			local o, item, inven = actor:findInAllInventoriesByObject(tome)
			if o then
				actor:removeObject(inven, item)
				game.log("#PURPLE#%s starts to crumble to dust, it will be gone once you exit it!", o:getName{do_color=true})
			end
		end
	end

	if tome.book_change_cooldown then actor:setEffect(actor.EFF_CULTS_BOOK_COOLDOWN, tome.book_change_cooldown, {tome=tome}) end


	-- Mark the tome as "used" so that it can't go in the item's vault anymore
	tome.special = true
end

-------------------------- Entropic Wormhole --------------------------
function backFromSMACK(title, text)
	game:onTickEndCancelAll()
	game:onTickEnd(function() 
		game:chronoRestore("multiverse_fight", true)
		Dialog:simpleLongPopup(title, text, 500)
	end)
end


-------------------------------- Glyphs -------------------------------
function getGlyphsList()
	return {
		"center_circle_big_glyph",
		"center_circle_small_glyph",
		"center_lines_big_glyph",
		"center_lines_small_glyph",
		"center_square_big_glyph",
		"center_square_small_glyph",
		"center_triangle_big_glyph",
		"center_triangle_small_glyph",
	}
end

function makeGlyphsSequence()
	game.state.cults_glyphs_sequences = game.state.cults_glyphs_sequences or {}

	local list = getGlyphsList()
	local ret = {}
	for i = 1, 4 do
		local g = rng.tableRemove(list)
		ret[#ret+1] = g
	end

	if game.state.cults_glyphs_sequences[table.concat(ret, ",")] then
		return makeGlyphsSequence()
	else
		-- print("[CultsDLC] Made glyph seq: ", table.concat(ret, " > "))
		return ret
	end
end

function glyphToASCII(glyph)
	local ascii = {
		center_circle_big_glyph = 'A',
		center_circle_small_glyph = 'a',
		center_lines_big_glyph = 'B',
		center_lines_small_glyph = 'b',
		center_square_big_glyph = 'C',
		center_square_small_glyph = 'c',
		center_triangle_big_glyph = 'D',
		center_triangle_small_glyph = 'd',
	}
	return ascii[glyph]
end

local glyph_entities = {}
function getGlyphEntityString(glyph, tstr)
	if not glyph_entities[glyph] then
		glyph_entities[glyph] = engine.Entity.new{image="terrain/cults_glyphs/"..glyph.."_bright.png", display=glyphToASCII(glyph), color=colors.GOLD}
	end
	return glyph_entities[glyph]:getDisplayString(tstr)
end

function burnGlyphOnTerrain(zone, level, x, y, glyph)
	local g = level.map(x, y, engine.Map.TERRAIN):cloneFull()
	local function addto(m)
		m.add_mos = m.add_mos or {}
		m.add_mos[#m.add_mos+1] = {image="terrain/cults_glyphs/"..glyph.."_slab.png"}
	end
	if g.add_displays then
		local last_z = -1
		local last = g
		for i, ad in ipairs(g.add_displays) do
			if (ad.z or 0) >= last_z and (ad.z or 0) <= 3 then
				last_z = ad.z or 0
				last = ad
			end
		end
		addto(last)
	else
		addto(g)
	end
	g.display = glyphToASCII(glyph)
	g.special = 1
	g:altered()
	g:removeAllMOs()
	level.map(x, y, engine.Map.TERRAIN, g)
end

function burnGlyphSequenceOnMap(zone, level, seq)
	local spots_check = {}
	local spots = {}
	local tries = 0
	while #spots < 4 and tries < 1000 do
		tries = tries + 1
		local x, y = game.state:findEventGrid(level)
		if x and not (spots_check[x] and spots_check[x][y]) then
			spots[#spots+1] = {x=x, y=y}
			spots_check[x] = spots_check[x] or {}
			spots_check[x][y] = true
		end
	end
	if #spots ~= 4 then return end
	table.sort(spots, "x")

	for i, spot in ipairs(spots) do
		burnGlyphOnTerrain(zone, level, spot.x, spot.y, seq[i])
	end
end

function registerGlyphsSequence(seq, effect_id)
	game.state.cults_glyphs_sequences = game.state.cults_glyphs_sequences or {}
	game.state.cults_glyphs_sequences_rev = game.state.cults_glyphs_sequences_rev or {}
	game.state.cults_glyphs_sequences[table.concat(seq, ",")] = effect_id
	game.state.cults_glyphs_sequences_rev[effect_id] = table.concat(seq, ",")
end

function tableGlyphSequence(strseq)
	return strseq:split(",")
end

function effectGlyphsSequence(effect_id)
	game.state.cults_glyphs_sequences_rev = game.state.cults_glyphs_sequences_rev or {}
	if not game.state.cults_glyphs_sequences_rev[effect_id] then
		local list = makeGlyphsSequence()
		registerGlyphsSequence(list, effect_id)
	end
	local str = ""
	for i, glyph in ipairs(tableGlyphSequence(game.state.cults_glyphs_sequences_rev[effect_id])) do
		str = str..getGlyphEntityString(glyph, false)
	end
	return str
end

function checkGlyphSequence(seq)
	game.state.cults_glyphs_sequences = game.state.cults_glyphs_sequences or {}
	return game.state.cults_glyphs_sequences[table.concat(seq, ",")] or false
end

local sequence_effects = {}
function loadSequenceEffects(file, env)
	env = env or setmetatable({
		DamageType = require("engine.DamageType"),
		Particles = require("engine.Particles"),
		Map = require("engine.Map"),
		newSequenceEffect = function(t)
			assert(t.id, "No sequence effect id")
			assert(t.message, "No sequence effect message")
			assert(t.trigger, "No sequence effect trigger")
			sequence_effects[t.id] = t
		end,
		load = function(f) loadSequenceEffects(f, env) end
	}, {__index=getfenv(2)})
	local f, err = util.loadfilemods(file, env)
	if not f and err then error(err) end
	f()
end

function executeGlyphSequence(name, portal, x, y)
	if sequence_effects[name] then
		game.log("#AQUAMARINE#%s", sequence_effects[name].message)
		sequence_effects[name].trigger(portal, x, y)
		if sequence_effects[name].single_use then
			table.pairsRemove(game.state.cults_glyphs_sequences, function(seq, eff)
				if eff == name then return true end
			end)
			table.pairsRemove(game.state.cults_glyphs_sequences_rev, function(eff, seq)
				if eff == name then return true end
			end)
		end
		world:gainAchievement("CULTS_EGRESS_MASTER", game.player, name)
	end
end

local corrupted_randart_name_rules = {
	dark = {
		syllablesStart ="Night, Umbra, Void, Dark, Gloom, Woe, Dour, Shade, Dusk, Murk, Bleak, Dim, Soot, Pitch, Fog, Black, Coal, Ebony, Shadow, Obsidian, Raven, Jet, Demon, Duathel, Unlight, Eclipse, Blind, Deeps",
		syllablesEnd = "arc, bane, bait, bile, biter, blast, bliss, blood, blow, bloom, butcher, blur, bolt, bone, bore, brace, braid, braze, breacher, breaker, breeze, brawn, burst, bringer, bearer, bender, blight, brand, break, born, bright, crypt, crack, clash, clamor, cut, cast, cutter, dredge, dash, dream, dare, death, edge, envy, fury, fear, fame, foe, furnace, flash, fiend, fist, gore, gash, gasher, grind, grinder, guile, grit, glean, glory, glamour, hack, hacker, hash, hue, hunger, hunt, hunter, ire, idol, immortal, justice, jeer, jam, kill, killer, kiss, 's kiss, karma, kin, king, knave, knight, lord, lore, lash, lace, lady, maim, mark, moon, master, mistress, mire, monster, might, marrow, mortal, minister, malice, naught, null, noon, nail, nigh, oath, order, oracle, oozer, obeisance, oblivion, onslaught, obsidian, peal, pyre, parry, power, python, prophet, pain, passion, pierce, piercer, pride, pulverizer, piety, panic, pain, punish, pall, quench, quencher, quake, quarry, queen, quell, queller, quick, quill, reaper, ravage, ravager, raze, razor, roar, rage, race, radiance, raider, rain, rot, ransom, rune, reign, rupture, ream, rebel, raven, river, ripper, rip, ripper, rock, reek, reeve, resolve, rigor, rend, raptor, shine, slice, slicer, spar, spawn, spawner, spitter, squall, steel, stoker, snake, sorrow, sage, stake, serpent, shear, sin, sear, spire, stalker, shaper, strider, streak, streaker, saw, scar, schism, star, streak, sting, stinger, strike, striker, stun, sun, sweep, sweeper, swift, stone, seam, sever, smash, smasher, spike, spiker, thorn, terror, touch, tide, torrent, trial, typhoon, titan, tickler, tooth, treason, trencher, taint, trail, usher, valor, vagrant, vile, vein, veil, venom, viper, vault, vengeance, vortex, vice, wrack, walker, wake, waker, war, ward, warden, wasp, weeper, wedge, wend, well, whisper, wild, wilder, will, wind, wilter, wing, winnow, winter, wire, wisp, wish, witch, wolf, wither, witherer, worm, wreath, worth, wreck, wrecker, wrest, writher, wyrd, zeal, zephyr",
		rules = "$s$e",
	},
}


-- Generate a Horror-themed randart
function generateCorruptedItem()
	local Stats = require "engine.interface.ActorStats"
	local Entity = require("engine.Entity")
	local ActorTalents = require "engine.interface.ActorTalents"

	local art = {}
	local level = resolvers.current_level
	local mutation = Entity.new{
		fake_ego = true,
	}
	local do_mutation = false
	local r = rng.range(1, 100)
	if r <= 20 then
		-- Generate a high level strongly themed blight, darkness, temporal item with 1 less ego
		local themes = {"temporal", "blight", "dark"}
		local o = game.zone:makeEntity(game.level, "object", 
			{properties={"randart_able"}, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
		art = game.state:generateRandart{base=o, lev=level+20, nb_themes = 2, force_themes=themes, forbid_power_source = {"antimagic", } }
		art.voidthemed = true
	elseif r <= 50 then
		-- Generate a randart with one random stat lowered and one increased
		do_mutation = true
		mutation.name = "mutation-specialist"
		mutation.keywords = {specialist=true}
		local o = game.zone:makeEntity(game.level, "object",
			{properties={"randart_able"}, not_properties={"archery_ammo", "unique"}, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
		art = game.state:generateRandart{base=o, lev=level, }

		local stats = {Stats.STAT_CUN, Stats.STAT_CON, Stats.STAT_STR, Stats.STAT_WIL, Stats.STAT_DEX, Stats.STAT_MAG}
		local stat1 = rng.tableRemove(stats)
		local stat2 = rng.tableRemove(stats)
		local change = rng.range(art.material_level or 1, (art.material_level or 1) * 4)
		table.set(mutation, "wielder", "inc_stats", {} )
		mutation.wielder.inc_stats[stat1] = change
		mutation.wielder.inc_stats[stat2] = -change
	elseif r <= 90 then
		-- Generate a non-weapon with a defensive melee retaliation ego
		do_mutation = true
		mutation.name = "mutation-plagueshell"
		mutation.keywords = {plagueshell=true}
		local o = game.zone:makeEntity(game.level, "object",
			{properties={"randart_able"}, not_properties={"combat", "unique"}, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
		art = game.state:generateRandart{base=o, lev=level, }

		table.set(mutation, "wielder", "on_melee_hit", {
			[DamageType.ITEM_BLIGHT_DISEASE] = resolvers.mbonus_material(30, 20),
			[DamageType.ITEM_DARKNESS_NUMBING] = resolvers.mbonus_material(30, 20),
		})
	else
		-- Generate a weapon that has reduced damage, Void damage type, and guaranteed spell procs
		do_mutation = true
		mutation.name = "mutation-voidweapon"
		mutation.keywords = {voidweapon=true}
		local o = game.zone:makeEntity(game.level, "object",
			{properties={"randart_able", "combat"}, not_properties={"unique"}, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
		art = game.state:generateRandart{base=o, lev=level,}
		if not art.archery_ammo then
			table.set(mutation, "combat", {talent_on_hit = {
				[ActorTalents.T_NETHERBLAST] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20}
			}})

			table.set(mutation, "talent_on_spell", {
				{chance=20, talent=ActorTalents.T_NETHERBLAST, level=resolvers.genericlast(function(e) return e.material_level end)}
			})
		else
			table.set(mutation, "combat", {talent_on_hit = {
				[ActorTalents.T_NETHERBLAST] = {level=resolvers.genericlast(function(e) return e.material_level end), chance=20}
			}})
		end
	end
	if not art then return end
	if do_mutation == true then
		game.zone:applyEgo(art, mutation, "object", true)
		art:resolve()
		art:resolve(nil, true)

		local ng = NameGenerator.new(corrupted_randart_name_rules.dark)
		art.name = ("%s of the Blightspawn"):tformat(ng:generate())
	end
	art:identify(true)
	return art
end
