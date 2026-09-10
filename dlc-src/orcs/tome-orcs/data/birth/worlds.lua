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

local default_eyal_descriptors = Birther.default_eyal_descriptors

local default_orc_descriptors = function(add)
	local base = {

	race =
	{
		__ALL__ = "disallow",
		Orc = "allow",
		Yeti = "allow",
		MinotaurUndead = "allow",
	},

	class =
	{
		__ALL__ = "disallow",
		Tinker = "allow",
		Warrior = "allow",
	},
}

	for name, what in pairs(default_eyal_descriptors{}.class) do base.class[name] = what end

	if add then table.merge(base, add) end
	return base
end

-- Player worlds/campaigns
newBirthDescriptor{
	type = "world",
	name = "Orcs",
	display_name = _t"Orcs: Embers of Rage",
--	locked = function() return profile.mod.allow_build.campaign_orc and true or "hide" end,
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.campaign == "Orcs",
	desc =
	{
		_t"The Prides lie in ruins!",
		_t"The Sorcerers have been defeated!",
		_t"Orcs in all Var'Eyal are in dismay, hunted by the Sunwall and their newfound allies from the west.",
		_t"The Scourge from the West is back in the west, but her legacy stays strong: the orc race is once again upon the brink of destruction!",
		_t"But not all hope is lost.",
		_t"On the isolated Clork Peninsula lies the fifth pride: Kruk's Pride; unseen and unharmed by the Scourge.",
		_t"Yet not all is great there either, the Sunwall offensive has set up an outpost blocking the way to the mainland.",
		_t"But the worst threat comes from the peninsula itself, the main inhabitants are not the orcs, but the Atmos Tribe.",
		_t"A civilization of steam giants whose mastery of steamtech makes them incredible foes.",
		_t"Play an orc, prove your worth! Use steamtech against the giants, reclaim the far east and free it from Sunwall scum!",
		_t"Craft your own steamsaws, rocket boots, steam powered armours, and all kind of steamy technology!",
		_t"This is your destiny! For Garkul's Legacy, for the Glory of the Pride!",
	},
	descriptor_choices = default_orc_descriptors{},
	copy = {
		calendar = "orc", calendar_start_year = 124, calendar_start_day = 62,
		resolvers.inventory{ id=true, 
			{defined="APE", base_list="mod.class.Object:/data-orcs/general/objects/quest-artifacts.lua"},
		},
	},
	game_state = {
		exp_multiplier = 2.5,
		campaign_name = "orcs",
		__allow_rod_recall = true,
		__allow_transmo_chest = false,
		grab_online_event_zone = function() return "wilderness-1" end,
		grab_online_event_spot = function(zone, level)
			local find = {type="world-encounter", subtype="var-eyal"}
			local where = game.level:pickSpotRemove(find)
			while where and (game.level.map:checkAllEntities(where.x, where.y, "block_move") or not game.level.map:checkAllEntities(where.x, where.y, "can_encounter")) do where = game.level:pickSpotRemove(find) end
			local x, y = mod.class.Encounter:findSpot(where)
			return x, y
		end,
	},
	game_state_execute = function()
		-- Ureslak is considered dead
		game.uniques["mod.class.NPC/Ureslak the Prismatic"] = 1
		game.uniques["mod.class.NPC/Khulmanar, General of Urh'Rok"] = 1
	end,
}

getBirthDescriptor("world", "Maj'Eyal").descriptor_choices.class.Tinker = "allow"
if getBirthDescriptor("world", "TarEyal") then getBirthDescriptor("world", "TarEyal").descriptor_choices.class.Tinker = "allow" end
getBirthDescriptor("world", "Infinite").descriptor_choices.class.Tinker = "allow"
getBirthDescriptor("world", "Arena").descriptor_choices.class.Tinker = "allow"
if profile.mod.allow_build.orcs_tinker_eyal then
	getBirthDescriptor("subclass", "Adventurer").game_state = getBirthDescriptor("subclass", "Adventurer").game_state or {}
	getBirthDescriptor("subclass", "Adventurer").game_state.merge_tinkers_data = true
	local c = getBirthDescriptor("subclass", "Adventurer").copy
	c[#c+1] = resolvers.inventorybirth{ id=true, transmo=true, 
		{type="weapon", subtype="steamsaw", name="iron steamsaw", base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", autoreq=true, ego_chance=-1000},
		{type="weapon", subtype="steamsaw", name="iron steamsaw", base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", autoreq=true, ego_chance=-1000},
		{type="weapon", subtype="steamgun", name="iron steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000},
		{type="weapon", subtype="steamgun", name="iron steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000},
		{type="scroll", subtype="implant", name="steam generator implant", base_list="mod.class.Object:/data-orcs/general/objects/inscriptions.lua", autoreq=true, ego_chance=-1000},
		{type="scroll", subtype="implant", name="medical injector implant", base_list="mod.class.Object:/data-orcs/general/objects/inscriptions.lua", autoreq=true, ego_chance=-1000},
		{type="scroll", subtype="implant", name="medical injector implant", base_list="mod.class.Object:/data-orcs/general/objects/inscriptions.lua", autoreq=true, ego_chance=-1000},
	}
	c[#c+1] = resolvers.inventory{ id=true, 
		{defined="APE", base_list="mod.class.Object:/data-orcs/general/objects/quest-artifacts.lua"},
	}
end
getBirthDescriptor("world", "Infinite").descriptor_choices.race.Orc = "allow"
getBirthDescriptor("world", "Infinite").descriptor_choices.race.Yeti = "allow"
getBirthDescriptor("world", "Infinite").descriptor_choices.race.MinotaurUndead = "allow"
getBirthDescriptor("world", "Arena").descriptor_choices.race.Orc = "allow"
getBirthDescriptor("world", "Arena").descriptor_choices.race.Yeti = "allow"
getBirthDescriptor("world", "Arena").descriptor_choices.race.MinotaurUndead = "allow"

---------------------------------------------------------------------------------
-- Let the classes be show in orcs campaign as locked
---------------------------------------------------------------------------------

local affected_subclass = {}
for i, bdata in ipairs(Birther.birth_descriptor_def.class) do
	local old_lock = bdata.locked
	if not old_lock then old_lock = function() return true end end

	local allow = false
	if bdata.name == "Warrior" then allow = true
	elseif bdata.name == "Mage" and profile.mod.allow_build.orcs_campaign_mage then allow = true
	elseif bdata.name == "Rogue" and profile.mod.allow_build.orcs_campaign_rogue then allow = true
	elseif profile.mod.allow_build.orcs_campaign_all_classes then allow = true end

	if not allow then
		bdata.locked = function(birther)
			if birther:isDescriptorSet("world", "Orcs") then return false
			else return old_lock(birther) end
		end
		local old_lock_desc = bdata.locked_desc
		bdata.locked_desc = function(birther)
			if birther:isDescriptorSet("world", "Orcs") then return util.getval(old_lock_desc, birther) or "Once freed, twice shy."
			else return util.getval(old_lock_desc, birther) end
		end
		for name, _ in pairs(bdata.descriptor_choices.subclass) do
			affected_subclass[name] = bdata.name
		end
	end
end

for i, bdata in ipairs(Birther.birth_descriptor_def.subclass) do if affected_subclass[bdata.name] then
	local old_lock = bdata.locked
	if not old_lock then old_lock = function() return true end end
	local baseclass = affected_subclass[bdata.name]
	bdata.locked = function(birther)
		if birther:isDescriptorSet("world", "Orcs") then
			if baseclass == "Warrior" then return true
			elseif baseclass == "Mage" and profile.mod.allow_build.orcs_campaign_mage then return true
			elseif baseclass == "Rogue" and profile.mod.allow_build.orcs_campaign_rogue then return true end
			return profile.mod.allow_build.orcs_campaign_all_classes and old_lock(birther)
		else return old_lock(birther) end
	end
	local old_lock_desc = bdata.locked_desc
	bdata.locked_desc = function(birther)
		if birther:isDescriptorSet("world", "Orcs") then return util.getval(old_lock_desc, birther) or "Once freed, twice shy."
		else return util.getval(old_lock_desc, birther) end
	end
end end
