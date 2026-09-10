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
local Shader = require "engine.Shader"
local UIBase = require "engine.ui.Base"

module(..., package.seeall, class.make)

function hookLoad()
	local Birther = require "engine.Birther"
	local DamageType = require "engine.DamageType"
	local WorldAchievements = require "mod.class.interface.WorldAchievements"
	local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
	local ActorTalents = require "engine.interface.ActorTalents"
	local ActorResource = require "engine.interface.ActorResource"
	local ActorInventory = require "engine.interface.ActorInventory"
	local ActorAI = require "engine.interface.ActorAI"
	local PartyIngredients = require "mod.class.interface.PartyIngredients"
	local PartyTinker = require "mod.class.interface.PartyTinker"
	local Store = require "mod.class.Store"
	local PartyLore = require "mod.class.interface.PartyLore"

	dofile("/data-orcs/resolvers.lua")
	dofile("/data-orcs/factions.lua")
	DamageType:loadDefinition("/data-orcs/damage_types.lua")

	WorldAchievements:loadDefinition("/data-orcs/achievements/")

	PartyLore:loadDefinition("/data-orcs/lore/lore.lua")

	Store:loadStores("/data-orcs/general/stores/orcs.lua")

	PartyIngredients:loadDefinition("/data-orcs/ingredients.lua")
	PartyTinker:loadDefinition("/data-orcs/tinkers.lua")

	ActorAI:loadDefinition("/data-orcs/ai/")
	
	ActorTalents:loadDefinition("/data-orcs/talents.lua")

	ActorTemporaryEffects:loadDefinition("/data-orcs/timed_effects/physical.lua")
	ActorTemporaryEffects:loadDefinition("/data-orcs/timed_effects/magical.lua")
	ActorTemporaryEffects:loadDefinition("/data-orcs/timed_effects/mental.lua")
	ActorTemporaryEffects:loadDefinition("/data-orcs/timed_effects/other.lua")
	ActorTemporaryEffects:loadDefinition("/data-orcs/timed_effects/floor.lua")

	ActorResource:defineResource(_t"Steam", "steam", ActorTalents.T_STEAM_POOL, "steam_regen", _t"Your reserve of steam. Steam is used to power most technological things. It is very hard to increase your maximum steam, but it regenerates quickly.", nil, nil, {
		color = "#9d80b0#",
		wait_on_rest = true,
		restore_factor = 0.15,
		randomboss_enhanced = true,
		depleted_unsustain = true,
	})
	
	ActorInventory:defineInventory("MECHARACHNID_TAIL", _t"Tail", true, _t"Object held in your tail. It can be a steamgun or steamsaw.", nil, {equipdoll_back="ui/equipdoll/psionic_inv.png"})
	
	ActorInventory.equipdolls.mecharachnid = { w=48, h=48, itemframe="ui/equipdoll/itemframe48.png", itemframe_sel="ui/equipdoll/itemframe-sel48.png", ix=3, iy=3, iw=42, ih=42, doll_x=116, doll_y=168+64 +72,
		list={
			MECHARACHNID_TAIL = {{weight=1, x=48, y=48, subshift="left"}},
			MAINHAND = {{weight=2, x=48, y=120, subshift="left"}},
			OFFHAND = {{weight=3, x=48, y=192, subshift="left"}},
			BODY = {{weight=4, x=48, y=264, subshift="left"}},
			QUIVER = {{weight=5, x=48, y=336, subshift="left"}},
	}}
	
	Birther:loadDefinition("/data-orcs/birth/worlds.lua")
	Birther:loadDefinition("/data-orcs/birth/races/orc.lua")
	Birther:loadDefinition("/data-orcs/birth/races/yeti.lua")
	Birther:loadDefinition("/data-orcs/birth/races/whitehooves.lua")
	Birther:loadDefinition("/data-orcs/birth/classes/wilder.lua")
	Birther:loadDefinition("/data-orcs/birth/classes/tinker.lua")
	Birther:loadDefinition("/data-orcs/birth/classes/empyreal.lua")
end

function hookGameOptionsUIs(self, data)
	data.uis[#data.uis+1] = {name=_t"SteamTech", ui="steam"}
end

function hookInventoryMakeTabs(self, data)
	for i, tab in ipairs(data.tabslist) do if tab.kind == "inscriptions" then
		tab.filter = function(o) return not o.__transmo and (o.type == "scroll" or (o.type == "misc" and o.subtype == "salve")) end
	end end
end

function hookMapGeneratorStaticSubgenRegister(self, data)
	if data.mapfile ~= "wilderness/eyal" or not game:isCampaign("Orcs") then return end

	data.list[#data.list+1] = {
		x = 111, y = 2, w = 58, h = 72, overlay = true,
		generator = "engine.generator.map.Static",
		data = {
			map = "orcs+zones/worldmap",
		},
	}
end

function hookEntityLoadList(self, data)
	if type(game) ~= "table" or not game.state then return end
	if game:isCampaign("Orcs") then
		if data.file == "/data/general/objects/objects.lua" then
			self:loadList("/data-orcs/general/objects/tinker.lua", data.no_default, data.res, data.mod, data.loaded)
		elseif data.file == "/data/zones/wilderness/grids.lua" then
			self:loadList("/data-orcs/zones/wilderness-add/grids.lua", data.no_default, data.res, data.mod, data.loaded)
		end
	elseif game.state.birth.merge_tinkers_data then
		if data.file == "/data/general/objects/objects.lua" then
			self:loadList("/data-orcs/general/objects/generic.lua", data.no_default, data.res, data.mod, data.loaded)
			self:loadList("/data-orcs/general/objects/tinker.lua", data.no_default, data.res, data.mod, data.loaded)
			self:loadList("/data-orcs/general/objects/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
		elseif data.file == "/data/zones/wilderness/grids.lua" then
			self:loadList("/data-orcs/zones/wilderness-add/grids.lua", data.no_default, data.res, data.mod, data.loaded)
		end
	else
		if data.file == "/data/general/objects/world-artifacts.lua" then
			self:loadList("/data-orcs/general/objects/generic-world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
		end
	end

	if data.file == "/data/general/npcs/snake.lua" then
		self:loadList("/data-orcs/general/npcs/snake-add.lua", data.no_default, data.res, data.mod, data.loaded)
	end
	if data.file == "/data/general/npcs/plant.lua" then
		self:loadList("/data-orcs/general/npcs/plant-add.lua", data.no_default, data.res, data.mod, data.loaded)
	end

	if data.file == "/data/general/encounters/maj-eyal.lua" and game:isCampaign("Maj'Eyal") then
		self:loadList("/data-orcs/general/encounters/maj-eyal.lua", data.no_default, data.res, data.mod, data.loaded)
	end

	if data.file == "/data/general/npcs/horror.lua" then --A little bit of extra torment...
		self:loadList("/data-orcs/general/npcs/horror.lua", data.no_default, data.res, data.mod, data.loaded)
	end

	if data.file == "/data/zones/infinite-dungeon/grids.lua" then --A little bit of extra torment...
		self:loadList("/data-orcs/general/grids/slumbering_cave.lua", data.no_default, data.res, data.mod, data.loaded)
		self:loadList("/data-orcs/general/grids/manacave.lua", data.no_default, data.res, data.mod, data.loaded)
		self:loadList("/data-orcs/general/grids/mechwall.lua", data.no_default, data.res, data.mod, data.loaded)
		self:loadList("/data-orcs/general/grids/mechstone.lua", data.no_default, data.res, data.mod, data.loaded)
		self:loadList("/data/general/grids/psicave.lua", data.no_default, data.res, data.mod, data.loaded)
	end
end

function hookMinimalistLoad(self, data)
--	self.TOOLTIP_STEAM = TOOLTIP_STEAM
	local UIBase = require "engine.ui.Base"
	if UIBase.ui ~= "steam" then return end
	data.alterlocal("pf_bg", {core.display.loadImage("/data-orcs/gfx/ui/playerframe/back.png"):glTexture()})
	data.alterlocal("pf_bg_x", -25)
	data.alterlocal("pf_bg_y", -14)
	data.alterlocal("pf_attackdefend_x", 1)
	data.alterlocal("pf_attackdefend_y", -8)
	data.alterlocal("pf_attack", {core.display.loadImage("/data-orcs/gfx/ui/playerframe/attack.png"):glTexture()})
	data.alterlocal("pf_defend", {core.display.loadImage("/data-orcs/gfx/ui/playerframe/defend.png"):glTexture()})
	data.alterlocal("pf_mtx_x", 8)
	data.alterlocal("pf_mtx_y", 0)

	data.alterlocal("hk1", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_1.png"):glTexture()})
	data.alterlocal("hk2", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_2.png"):glTexture()})
	data.alterlocal("hk3", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_3.png"):glTexture()})
	data.alterlocal("hk4", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_4.png"):glTexture()})
	data.alterlocal("hk5", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_5.png"):glTexture()})
	data.alterlocal("hk6", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_6.png"):glTexture()})
	data.alterlocal("hk7", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_7.png"):glTexture()})
	data.alterlocal("hk8", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_8.png"):glTexture()})
	data.alterlocal("hk9", {core.display.loadImage("/data-orcs/gfx/ui/hotkeys/hotkey_9.png"):glTexture()})

	data.alterlocal("mm_bg", {core.display.loadImage("/data-orcs/gfx/ui/minimap/back.png"):glTexture()})
	data.alterlocal("mm_bg_x", 5)
	data.alterlocal("mm_bg_y", -4)
	data.alterlocal("mm_comp", {core.display.loadImage("/data/gfx/shockbolt/invis.png"):glTexture()})
	data.alterlocal("mm_shadow", {core.display.loadImage("/data-orcs/gfx/ui/minimap/shadow.png"):glTexture()})
	data.alterlocal("mm_transp", {core.display.loadImage("/data-orcs/gfx/ui/minimap/transp.png"):glTexture()})
end

function hookCharacterSheetAttackPower(self, data)
	local player, actor_to_compare = data.player, data.actor_to_compare
	if player:knowTalent(player.T_STEAM_POOL) then
		local w, h = data.w, data.h
		local s = self.c_desc.s
		local compare_fields = data.compare_fields
		local text, color
		h = h + self.font_h
		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Steam:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSteampower() end, "%3d", "%+.0f")
		self:mouseTooltip(self.TOOLTIP_STEAMPOWER, s:drawColorStringBlended(self.font, ("Steampower: #00ff00#%s"):tformat(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSteamCrit() end, "%d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_STEAM_CRIT, s:drawColorStringBlended(self.font,  ("Crit. chance: #00ff00#%s"):tformat(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		color = 1/player:combatSteamSpeed()
		color = color >= 1 and "#LIGHT_GREEN#" or "#LIGHT_RED#"
		text = compare_fields(player, actor_to_compare, function(actor, ...) return 1/actor:combatSteamSpeed() end, color.."%.1f%%", "%+.1f%%", 100)
		self:mouseTooltip(self.TOOLTIP_STEAM_SPEED, s:drawColorStringBlended(self.font, ("Steam speed : #00ff00#%s"):tformat(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		data.w, data.h = w, h
		return true
	end
end

function hookObjectDescPowerSource(self, data)
	if self.power_source.steam then data.desc:add(_t"Powered by ", {"color", "b6bd69"}, _t"steamtech", {"color", "LAST"}, true) end
end

function hookObjectDescWielder(self, data)
	data.compare_scaled(data.w, data.compare_with, data.field, "combat_steampower", {"combatSteampower"}, _t"%+d #LAST#(%+d eff.)", _t"Steampower: ")
	data.compare_fields(data.w, data.compare_with, data.field, "combat_steamcrit", "%+d%%", _t"Steam crit. chance: ")
	data.compare_fields(data.w, data.compare_with, data.field, "combat_steamspeed", "%+d%%", _t"Steamtech Speed: ", 100)
	data.compare_fields(data.w, data.compare_with, data.field, "steam_regen", "%+.2f", _t"Steam each turn: ")
	data.compare_fields(data.w, data.compare_with, data.field, "max_steam", "%+.2f", _t"Maximum steam: ")
end

function hookupdateModdableTileWeapon(self, data)
	if data.front and self.steam_using_heavy_weapon then
		local base = data.base
		local add = data.add

		if self.steam_using_heavy_weapon == "flamethrower" then
			add[#add+1] = {image = base.."right_flamethrower.png", auto_tall=1}
		elseif self.steam_using_heavy_weapon == "shockstaff" then
			add[#add+1] = {image = base.."right_shockstaff.png", auto_tall=1}
		elseif self.steam_using_heavy_weapon == "boltgun" then
			add[#add+1] = {image = base.."right_boltgun.png", auto_tall=1}
		end
		data.replace = true
	end
end

function hookupdateModdableTileBack(self, data)
	local base = data.base
	local add = data.add
	local nb = self:attr("steam_generator_nb")

	if nb == 1 then
		add[#add+1] = {image = base.."left_steampack_back.png", auto_tall=1}
	elseif nb == 2 then
		add[#add+1] = {image = base.."left_steampack_back.png", auto_tall=1}
		add[#add+1] = {image = base.."right_steampack_back.png", auto_tall=1}
	end
	self:updateSteamGeneratorParticles()

	if self.using_steam_rocketpod then
		add[#add+1] = {image = base.."rocket_pod.png", auto_tall=1}
	end
end
function hookupdateModdableTileMiddle(self, data)
	local base = data.base
	local add = data.add

	if self.using_steam_exoskeleton then
		add[#add+1] = {image = base.."exoskeleton.png", auto_tall=1}
	end
end
function hookupdateModdableTileFront(self, data)
	local base = data.base
	local add = data.add

	-- Do not show straps with a power armour
	local nb = not self:attr("suppress_steam_generator_straps") and self:attr("steam_generator_nb")
	if nb == 1 then
		add[#add+1] = {image = base.."left_steampack_front.png", auto_tall=1}
	elseif nb == 2 then
		add[#add+1] = {image = base.."left_steampack_front.png", auto_tall=1}
		add[#add+1] = {image = base.."right_steampack_front.png", auto_tall=1}
	end

	if self:attr("arcane_dynamo") then
		add[#add+1] = {image = base.."arcane_dynamo.png", auto_tall=1}
	end
end

function hookActorActBase(self, data)
	if self:knowTalent(self.T_POLARIZATION) then
		local t = self:getTalentFromId(self.T_POLARIZATION)
		t.do_polarize(self, t)
	end
	if self:knowTalent(self.T_CELESTIAL_ACCELERATION) then
		local t = self:getTalentFromId(self.T_CELESTIAL_ACCELERATION)
		t.do_accelerate(self, t)
	end
end


function hookActorPreUseTalent(self, data)
	--this is here to make sure stuff like plasma bolt remains consistent
	if data.t.is_spell and self.mirror_self and not self.mirror_self.dead then
		local e = self.mirror_self
		e.positive = self.positive
		e.negative = self.negative
		e.mana = self.mana
		e.stamina = self.stamina
		e.vim = self.vim
	end

	-- Prevent shooting with a heavy weapons
	if data.t.id == self.T_SHOOT and self:attr("steam_using_heavy_weapon") then
		if not data.silent then game.logPlayer(self, "You may not shoot while using a heavy weapon.") end
		return true
	end
end

function hookActorPostUseTalent(self, data)
	local ab = data.t
	if ab.is_spell and self.mirror_self and not self.mirror_self.dead then
		local e = self.mirror_self
		if e:knowTalent(ab) then --only spell they shouldn't know is mirror self
			local tx, ty, target = self:getTarget()
			e:forceUseTalent(ab.id, {force_target={x=tx, y=ty}, ignore_ressources = true, ignore_cd = true, ignore_energy = true, no_equilibrium_fail = true, no_equilibrium_fail = true})
		end
	end
end

function hookDamageProjectorBase(self, data)
	local invertPairs = {
		["LIGHT"] = DamageType.DARKNESS,
		["DARKNESS"] = DamageType.LIGHT,
		["HOLY_LIGHT"] = DamageType.DARKNESS,
		["BLAZINGLIGHT"] = DamageType.SHIFTINGSHADOWS,
		["SHIFTINGSHADOWS"] = DamageType.BLAZINGLIGHT,
		["MINION_DARKNESS"] = DamageType.LIGHT,
		["RIGOR_MORTIS"] = DamageType.LIGHT,
		["ABYSSAL_SHROUD"] = DamageType.LIGHT,
	}
	
	
	if self.invert_light_dark and data.dam > 0 then
		
		local newType = invertPairs[DamageType:get(data.type).type]
		--game.logSeen(self, "%s deals %s damage, converted to %s!", self.name:capitalize(), DamageType:get(data.type).type, DamageType:get(newType).type)
		if newType then
			local old = self.invert_light_dark
			self.invert_light_dark = false
			data.stop = DamageType:get(newType).projector(data.src, data.x, data.y, newType, data.tmp or data.dam, {},data.no_martyr or false) --DamageProjector why you no pass no_martyr/tmp
			self.invert_light_dark = old
			data.dam = 0
			return true
		end
	end
end

function hookDamageProjectorFinal(self, data)
	local target = game.level.map(data.x, data.y, engine.Map.ACTOR)
	if target and target:hasEffect(target.EFF_TWILIT_ECHOES) and (data.type == DamageType.LIGHT or data.type == DamageType.DARKNESS) and data.dam >= 1 then
		local e = target:hasEffect(target.EFF_TWILIT_ECHOES)
		local def = target.tempeffect_def[target.EFF_TWILIT_ECHOES]
		def.doEcho(data.type, data.dam, e, target, data.src, data.x, data.y)
	end
end

function hookFactionSetReaction(self, data)
	if data.f1 == "kaltor-shop" and data.reaction < 0 then
		local p = game:getPlayer(true)
		if p:hasQuest("orcs+kaltor-shop") then p:hasQuest("orcs+kaltor-shop"):attacked() end
	end
end

function hookZoneLoadEvents(self, data)
	if data.zone == "infinite-dungeon" then
		data.events[#data.events+1] = {name="orcs+AAA", minor=true, percent=10}
	end
end

function hookEscortAssign(self, data)
	if not profile.mod.allow_build.orcs_tinker_eyal then return end
	local player = game:getPlayer(true)
	if player:knowTalentType("steamtech/physics") or player:knowTalentType("steamtech/chemistry") then return end

	local Talents = require("engine.interface.ActorTalents")
	local Stats = require("engine.interface.ActorStats")

	-- while #data.possible_types > 0 do table.remove(data.possible_types) end -- for debug only
	data.possible_types.steamtech = {
		chance = 50, unique = true,
		classes = {"Sawbutcher", "Gunslinger", "Annihilator"},
		escort = {
			name=_t"lost tinker", random="female",
			text = _t[[Please help me! I am afraid I lost myself in this place while testing some new steamtech. I know there is a recall portal left around here by a friend, but I have fought too many battles, and I fear I will not make it. Would you help me?]],
			actor = {
				name = _t"%s, the experimenting tinker",
				type = "humanoid", subtype = "human", image = "player/higher_female.png",
				display = "@", color=colors.AQUAMARINE,
				desc = _t[[She looks tired and wounded.]],
				autolevel = "rogue",
				ai = "escort_quest", ai_state = { talent_in=4, },
				stats = { str=8, dex=7, mag=18, con=12 },

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
				resolvers.equip{ {type="weapon", subtype="sword", autoreq=true} },
				resolvers.talents{ [Talents.T_PULSE_DETONATOR]=1, },
				lite = 4,
				rank = 2,
				exp_worth = 1,
				antimagic_ok = true,

				max_life = 50, life_regen = 0,
				life_rating = 11,
				combat_armor = 3, combat_def = 3,
				inc_damage = {all=-50},
			},
		},
	}
end

function hookEscortReward(self, data)
	local Talents = require("engine.interface.ActorTalents")
	local Stats = require("engine.interface.ActorStats")
	data.reward_types.steamtech = {
		special = {
			{
				desc = _t"[Ask where to learn tinkers crafting]",
				tooltip = _t"Reveal the location of a teacher.",
				action=function(npc, player, on_chose)
					if game:isCampaign("Maj'Eyal") then
						require("engine.ui.Dialog"):simplePopup(_t"Tinker's Master", _t"She points a location on your map, in a remote area to the north.")

						game:onLevelLoad("wilderness-1", function(zone, level, data)
							local list = mod.class.Encounter:loadList("/data-orcs/general/encounters/maj-eyal.lua")
							local e = list.TINKER_CAVE

							local where = e.immediate.force_spot
							e:on_encounter_execute(where or player)
						end)
					-- For the Infinite Dungeon and such
					else
						require("engine.ui.Dialog"):simplePopup(_t"Tinker's Master", _t"You are given a strange metal contraption, explaining that using it will transport you to tinker's cave.")
						local base_list = require("mod.class.Object"):loadList("/data-orcs/general/objects/special-misc.lua")
						base_list.__real_type = "object"
						local o = game.zone:makeEntityByName(game.level, base_list, "TINKER_CAVE_TELEPORTER")
						if o then
							o:identify(true)
							player:addObject(player.INVEN_INVEN, o)
						end
					end
					on_chose(npc, player, "special", nil, nil, _t"gained knowledge of tinker technology")
				end,
			},
		},
		talents = {
			[Talents.T_INNOVATION] = 1,
			[Talents.T_LAST_ENGINEER_STANDING] = 1,
			[Talents.T_CRAFTS_EYE] = 1,
			[Talents.T_ENDLESS_ENDURANCE] = 1,
		},										
		stats = {
			[Stats.STAT_CUN] = 5,
			[Stats.STAT_DEX] = 5,
		},
	}
end

function hookChatLoad(self, data)
	if self.name ~= "last-hope-lost-merchant" then return end
	if not game.state.birth.merge_tinkers_data then return end
	if not self:get("make") then return end

	local bases = {
		"voratun steamsaw",
		"voratun steamgun",
	}

	local l = self:get("make").answers
	table.insert(l, {_t"Steamtech", action=function(npc, player)
		local l = {{_t"I've changed my mind.", jump = "welcome"}}
		self:addChat{ id="makereal",
			text = _t[[Which kind of item would you like ?]],
			answers = l,
		}

		for i, name in ipairs(bases) do
			local dname = nil
			if type(name) == "table" then name, dname = name[1], name[2] end
			local not_ps, force_themes
			not_ps = game.state:attrPowers(player) -- make sure randart is compatible with player
			if not_ps.arcane then force_themes = {'antimagic'} end
			
			local o, ok
			local tries = 100
			repeat
				o = game.zone:makeEntity(game.level, "object", {name=name, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
				if o then ok = true end
				if o and not game.state:checkPowers(player, o, nil, "antimagic_only") then
					ok = false o = nil 
				end
				tries = tries - 1
			until ok or tries < 0
			if o then
				if not dname then dname = o:getName{force_id=true, do_color=true, no_count=true}
				else dname = "#B4B4B4#"..o:getDisplayString()..dname.."#LAST#" end
				l[#l+1] = {dname, action=function(npc, player)
					local art, ok
					local nb = 0
					repeat
						art = game.state:generateRandart{base=o, lev=70, egos=4, force_themes=force_themes, forbid_power_source=not_ps}
						if art then ok = true end
						if art and not game.state:checkPowers(player, art, nil, "antimagic_only") then
							ok = false
						end
						nb = nb + 1
						if nb == 40 then break end
					until ok
					if art and nb < 40 then
						art:identify(true)
						player:addObject(player.INVEN_INVEN, art)
						player:incMoney(-4000)
						game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
						if not config.settings.cheat then game:saveGame() end

						self:addChat{ id="naming",
							text = ("Do you want to name your item?\n%s"):tformat(tostring(art:getTextualDesc())),
							answers = {
								{_t"Yes, please.", action=function(npc, player)
									local d = require("engine.dialogs.GetText").new(_t"Name your item", _t"Name", 2, 40, function(txt)
										art.name = txt:removeColorCodes():gsub("#", " ")
										game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true})
									end, function() game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true}) end)
									game:registerDialog(d)
								end},
								{_t"No thanks.", action=function() game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true}) end},
							},
						}
						return "naming"
					else
						self:addChat{ id="oups",
							text = _t"Oh I am sorry, it seems we could not make the item your require.",
							answers = {
								{_t"Oh, let's try something else then.", jump="make"},
								{_t"Oh well, maybe later then."},
							},
						}
						return "oups"
					end
				end}
			end
		end

		return "makereal"
	end})
end

function hookBirtherDonatorTiles(self, data)
	data.list[#data.list+1] = "npc/giant_yeti_astral_infused_yeti.png"
	data.list[#data.list+1] = "npc/giant_yeti_attack_yeti.png"
	data.list[#data.list+1] = "npc/giant_yeti_captured_yeti_behemoth.png"
	data.list[#data.list+1] = "npc/giant_yeti_guard_yeti.png"
	data.list[#data.list+1] = "npc/giant_yeti_half_mechanized_yeti.png"
	data.list[#data.list+1] = "npc/giant_yeti_pet_yeti.png"
	data.list[#data.list+1] = "npc/giant_yeti_yeti.png"
	data.list[#data.list+1] = "npc/giant_yeti_yeti_cub.png"
	data.list[#data.list+1] = "npc/giant_yeti_yeti_demolisher.png"
	data.list[#data.list+1] = "npc/giant_yeti_yeti_warrior.png"
	data.list[#data.list+1] = "npc/giant_yeti_yeti_patriarch.png"
	data.list[#data.list+1] = "npc/humanoid_elf_elven_astromancer.png"
	data.list[#data.list+1] = "npc/humanoid_elf_star_gazer.png"
	data.list[#data.list+1] = "npc/humanoid_elf_sunwall_vindicator.png"
	data.list[#data.list+1] = "npc/humanoid_halfling_halfling_pyremaster.png"
	data.list[#data.list+1] = "npc/humanoid_halfling_mindwall.png"
	data.list[#data.list+1] = "npc/humanoid_human_astral_conjurer.png"
	data.list[#data.list+1] = "npc/humanoid_human_crimson_templar_john.png"
	data.list[#data.list+1] = "npc/humanoid_human_maltoth_the_mad.png"
	data.list[#data.list+1] = "npc/humanoid_human_outpost_leader_john.png"
	data.list[#data.list+1] = "npc/humanoid_human_sun_paladin_recruit.png"
	data.list[#data.list+1] = "npc/humanoid_human_sunwall_guard.png"
	data.list[#data.list+1] = "npc/humanoid_shalore_shalore_liberator.png"
	data.list[#data.list+1] = "npc/humanoid_orc_orc_guard.png"
	data.list[#data.list+1] = "npc/humanoid_orc_orc_gunslinger.png"
	data.list[#data.list+1] = "npc/undead_ghost_necropsych_s_ghost.png"
	data.list[#data.list+1] = "npc/undead_minotaur_nektosh_the_one_horned.png"
	data.list[#data.list+1] = "npc/undead_minotaur_whitehoof_ghoul.png"
	data.list[#data.list+1] = "npc/undead_minotaur_whitehoof_hailstorm.png"
	data.list[#data.list+1] = "npc/undead_minotaur_whitehoof_invoker.png"
	data.list[#data.list+1] = "npc/undead_minotaur_whitehoof_maulotaur.png"
	if profile.mod.allow_build.cosmetic_gunsnake then data.list[#data.list+1] = "npc/animal_snake_gunsnake.png" end
	if profile.mod.allow_build.cosmetic_sawtree then data.list[#data.list+1] = "npc/immovable_plants_sawtree.png" end
end

function hookInfiniteDungeonGetGrids(self, data)
	-- TODO maybe we should give them 'desc' field
	data.grids[#data.grids+1] = {id_grids_name="corruptedcave", floor="CORRUPTEDCAVEFLOOR", wall="CORRUPTEDCAVEWALL", door="CORRUPTEDCAVE_DOOR", down="CORRUPTEDCAVE_LADDER_DOWN"}
	data.grids[#data.grids+1] = {id_grids_name="mechstone", floor="MECHSTONE_FLOOR", wall="MECHSTONE_WALL", door="MECHSTONE_DOOR", down="MECHSTONE_DOWN"}
	data.grids[#data.grids+1] = {id_grids_name="mechwall", floor="MECH_FLOOR", wall="MECH_WALL", door="MECH_DOOR", down="MECH_DOWN"}
	data.grids[#data.grids+1] = {id_grids_name="manacave", floor="MANACAVE_GROUND", wall="MANACAVE", door="MANACAVE_DOOR", down="MANACAVE_DOWN"}
	data.grids[#data.grids+1] = {id_grids_name="psicave", floor="PSYCAVEFLOOR", wall="PSYCAVEWALL", door="PSYCAVE_DOOR", down="PSYCAVE_LADDER_DOWN"}
end

function hookPossessorBirthBodies(self, data)
	if data.desc.subrace == "Orc" then
		data.extra_types.giant = true
		local m = {name="yeti warrior", base_list="mod.class.NPC:/data-orcs/general/npcs/yeti.lua"}
		if m then data.bodies[#data.bodies+1] = m end
		return true
	elseif data.desc.subrace == "Kruk Yeti" then
		data.extra_types.giant = true
		local m = {name="steam giant berserker", base_list="mod.class.NPC:/data-orcs/general/npcs/steam-giant-warrior.lua"}
		if m then data.bodies[#data.bodies+1] = m end
		return true
	elseif data.desc.subrace == "Whitehoof" then
		data.extra_types.giant = true
		local m = {name="steam giant berserker", base_list="mod.class.NPC:/data-orcs/general/npcs/steam-giant-warrior.lua"}
		if m then data.bodies[#data.bodies+1] = m end
		return true
	end
end

function hookPossessorBodySnatcherSetupBody(self, data)
	data.body.tinker_mecharachnid = nil
end
