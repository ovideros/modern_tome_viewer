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

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Image = require "engine.ui.Image"
local Button = require "engine.ui.Button"
local ListColumns = require "engine.ui.ListColumns"
local Cults = require("mod.class.CultsDLC")

module(..., package.seeall, class.inherit(Dialog))

local base_explain = _t[[The font of sacrifice allows you to spend gold to reroll specific parts of a random artifact or rare item (you must first unequip it).
Each reroll costs #GOLD#500 gold#LAST# for a lesser ego and #GOLD#1000 gold#LAST# for a greater ego per each time you've rerolled that ego type on the same object.
Lesser and Greater egos can only be rerolled into the same type, and only egos with compatible power sources will be offered.

Note:  Many egos and external talents don't currently display properly but will apply to the item correctly.]]

function _M:init()
	self.actor = game.player
	self:generateItemsList()

	Dialog.init(self, _t"Font of Sacrifice", game.w * 0.5, math.max(450, game.h * 0.4))

	self.c_explain = Textzone.new{width=self.iw, auto_height=true, text=base_explain:format(1000)}

	self.c_items_list = ListColumns.new{width=math.floor(self.iw * 0.5), height=self.ih - self.c_explain.h, scrollbar=true, sortable=true, columns={
		{name=_t"Name", width=70, display_prop="name", sort="name"},
		{name=_t"Properties", width=30, display_prop="nb_egos", sort="nb_egos"},
	}, list=self.items_list, fct=function(item) self:import(item) end, select=function(item) self:showTooltip(item.o:getDesc({do_color=true})) end}

	self.c_reroll = Button.new{text=_t"Reroll properties set", fct=function()
		local o = self.cur_object
		local ego = self.cur_ego
		local cost = self:getRerollCost(o, ego)
		if self.actor.money < self:getRerollCost(o, ego) then
			Dialog:simplePopup(_t"Not enough money", ("You need at least #GOLD#%s gold#LAST# to reroll this item."):tformat(self:getRerollCost(o, ego)))
			return
		end
		Dialog:yesnoPopup(_t"Confirm", ("So you want to spend #GOLD#%s gold#LAST# to reroll this set of properties?"):tformat(self:getRerollCost(o, ego)), function(ret) if ret then
			self:doReroll()
		end end)
	end}

	self.c_egos_list = ListColumns.new{width=math.floor(self.iw * 0.5), height=self.ih - self.c_explain.h - self.c_reroll.h, scrollbar=true, sortable=true, columns={
		{name=_t"Name", width=100, display_prop="name", sort="name"},
	}, list={}, fct=function(item) self:selectEgo(item) end, select=function(item) self:showTooltip(self:getEgoDesc(item.ego)) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_explain},
		{left=0, top=self.c_explain, ui=self.c_items_list},
		{left=self.c_items_list, top=self.c_explain, ui=self.c_egos_list},
		{right=0, bottom=0, ui=self.c_reroll},
	}
	self:setupUI(false, false)

	self:toggleDisplay(self.c_egos_list, false)
	self:toggleDisplay(self.c_reroll, false)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
	self:setFocus(self.c_items_list)

	self.old_zone_level = game.zone.base_level
	self.old_level_level = game.level.level
	self.old_resolver_bonus = resolvers.current_level
	game.zone.base_level = 1
	game.level.level = 70
	resolvers.current_level = 70
end

function _M:unload()
	game.zone.base_level = self.old_zone_level
	game.level.level = self.old_level_level
	resolvers.current_level = self.old_resolver_bonus
end

function _M:getRerollCost(o, ego)
	if ego.greater_ego then
		return 1000 * (o.font_sacrifice_altered_greater or 1)
	else
		return 500 * (o.font_sacrifice_altered_lesser or 1)
	end
end

function _M:generateItemsList()
	local list = {}
	self.actor:inventoryApply(self.actor:getInven("INVEN"), function(inven, item, o)
		if (o.randart or o.rare) and o.ego_list and o.egos and not o.exclude_selective_list then
			local nb_egos = 0
			local valid = true
			for i, ego in ipairs(o.ego_list) do
				local ego = ego[1]

				-- Addon egos (charms) are breaking for some reason
				if ego.addon then
					valid = false
					break
				end

				if ego:isClassName("mod.class.Object") then -- Only for egos, not randart properties
					local ok, err = pcall(self.getEgoDesc, self, ego)
					if ok then
						nb_egos = nb_egos + 1
					elseif config.settings.cheat then
						print("[FontSacrifice] Invalid ego due to getEgoDesc error: ", err)
					end
				end
			end

			if nb_egos > 0 and valid then
				list[#list+1] = {name=o:getName{do_color=true}, nb_egos=nb_egos, o=o}
			end
		end
	end)
	self.items_list = list
	if self.c_items_list then
		self.c_items_list:setList(list)
		self:toggleDisplay(self.c_egos_list, false)
		self:toggleDisplay(self.c_reroll, false)
	end
end

function _M:import(item)
	local o = item.o
	local list = {}
	for i, ego in ipairs(o.ego_list) do
		local ego = ego[1]
		if ego:isClassName("mod.class.Object") then -- Only for egos, not randart properties
			local ok, desc = pcall(self.getEgoDesc, self, ego)
			if ok then
				list[#list+1] = {name=_t(ego.name):trim()..(ego.greater_ego and _t" (Greater)" or ""), pos=i, ego=ego, desc=desc}
			end
		end
	end
	self.c_explain.text = base_explain
	self.c_explain:generate()
	self.c_egos_list:setList(list)
	self.cur_object = o
	self.cur_ego = nil
	self:toggleDisplay(self.c_egos_list, true)
	self:toggleDisplay(self.c_reroll, false)
	self:setFocus(self.c_egos_list)
	for i, itm in ipairs(self.c_items_list.list) do itm.color = colors.simple(colors.WHITE) end
	item.color = colors.simple(colors.LIGHT_GREEN)
	-- self.c_items_list:drawItem(item)
end

-- Note:  There are many egos this currently does not display properly because their resolvers don't show meaningful information pre-resolve
-- This will need to be fixed via an update to the ego code in the engine and largely case by case, but some simpler resolvers are converted here
-- Most of the bugged egos will simply show up as blank not prevent the ego from showing up on the list
function _M:getEgoDesc(ego)

	-- Replaces all non-instant resolvers with a placeholder -999 value so a valid description can be retrieved
	-- This should be safe because were only replacing resolvers for a clone that gets used to get a description, anything weird happening will be cosmetic or just fail the pcall check
	local function convertResolvers(e)
		if type(e) == "table" then
			for k,v in pairs(e) do
				if v and type(v) == "table" and v.__resolve_last then
					e[k] = -999
				else
					convertResolvers(v)
				end
			end
		end
	end

	ego = ego:cloneFull()
	convertResolvers(ego)
	ego:resolve()
	ego:resolve(nil, true)
	ego.identified = true

	local desc = ego:getTextualDesc(nil, self.actor)

	-- Replace the placeholder -999 value, I'm sure theres a nicer way to do this
	desc = tostring(desc)
	desc = desc:gsub("-999", "<variable>")
	desc = desc:toTString()

	-- Cleanup desc
	for i, v in ipairs(desc) do
		local type_text = ("Type: %s / %s"):tformat("####", ""):gsub("####.*", "")
		if type(v) == "string" and v:find("^"..type_text) then
			for j = 1, i + 2 do table.remove(desc, 1) end
			break
		end
	end
	if #desc == 0 then error("empty desc") end

	local power_str = tstring{}
	if ego.power_source then
		if ego.power_source.arcane then power_str:merge((_t"Powered by #VIOLET#arcane forces#LAST#\n"):toTString()) end
		if ego.power_source.nature then power_str:merge((_t"Infused by #OLIVE_DRAB#nature#LAST#\n"):toTString()) end
		if ego.power_source.antimagic then power_str:merge((_t"Infused by #ORCHID#arcane disrupting forces#LAST#\n"):toTString()) end
		if ego.power_source.technique then power_str:merge((_t"Crafted by #LIGHT_UMBER#a master#LAST#\n"):toTString()) end
		if ego.power_source.psionic then power_str:merge((_t"Infused by #YELLOW#psionic forces#LAST#\n"):toTString()) end
		if ego.power_source.unknown then power_str:merge((_t"Powered by #CRIMSON#unknown forces#LAST#\n"):toTString()) end
		ego:triggerHook{"Object:descPowerSource", desc=power_str, object=ego}
	end

	desc = power_str:merge(desc)

	return desc
end

function _M:showTooltip(txt)
	if not txt then
		game.tooltip_x, game.tooltip_y = nil, nil
	else
		game.tooltip_x, game.tooltip_y = 1, 1
		game:tooltipDisplayAtMap(game.w, game.h, txt)
	end
end

function _M:selectEgo(item)
	self.cur_ego = item.ego
	self:toggleDisplay(self.c_reroll, true)
	self:setFocus(self.c_reroll)

	for i, itm in ipairs(self.c_egos_list.list) do itm.color = colors.simple(colors.WHITE) end
	item.color = colors.simple(colors.LIGHT_GREEN)
end

function _M:doReroll()
	if not self.cur_object or not self.cur_ego then return end
	game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
	local o = self.cur_object
	local oldego = self.cur_ego

	local tries = 500
	local lev = 70
	local picked_egos = {}
	local picked_egos_names = {}
	local legos = {}
	game.zone:getEntities(game.level, "object") -- make sure ego definitions are loaded
	-- merge all egos into one list to correctly calculate rarities
	table.append(legos, game.level:getEntitiesList("object/"..o.egos..":prefix") or {})
	table.append(legos, game.level:getEntitiesList("object/"..o.egos..":suffix") or {})
	table.append(legos, game.level:getEntitiesList("object/"..o.egos..":") or {})
	while #picked_egos < 5 and tries > 0 do
		local list = {}
		local ignore_filter = false
		for z = 1, #legos do
			list[#list+1] = legos[z].e
		end
		
		local ef = game.state:egoFilter(game.zone, game.level, "object", "randartego", o, {}, picked_egos, {})

		local powers = {}
		powers.forbid_power_source = game.state:updatePowers(o.forbid_power_source, o.power_source)

		local gr_ego = self.cur_ego.greater_ego
		local filter = function(e) -- check ego definition properties
			if ignore_filter then return true end
			if not ef.special or ef.special(e) then
				if e.exclude_selective_list then return false end
				if gr_ego and not e.greater_ego then return false end
				if not gr_ego and e.greater_ego then return false end
				if picked_egos_names[e.name] then return false end
				if game.zone:getEgoByName(o, e.name) then return false end  -- No adding an already existing ego
				return game.state:checkPowers(powers, e, true) -- check power_source compatibility
			end
		end

		local pick_egos = game.zone:computeRarities("object", list, game.level, filter, nil, nil)
		local ego = game.zone:pickEntity(pick_egos)
		if ego then
			local ego = ego:clone()
			if ego.instant_resolve then ego:resolve(nil, nil, o) end
			if ego.instant_resolve == "last" then ego:resolve(nil, true, o) end
			local ok, desc = pcall(self.getEgoDesc, self, ego)
			if not ok then desc = tstring{""} end

			table.insert(picked_egos, {ego=ego, name=_t(ego.name):trim()..(ego.greater_ego and _t" (Greater)" or ""), desc=desc})
			picked_egos_names[ego.name] = true
			print(" ** selected ego", ego.name, (ego.greater_ego and "(greater)" or "(normal)"), ego.power_source and table.concat(table.keys(ego.power_source), ","))
		end
		tries = tries - 1
	end
	if #picked_egos <= 0 then return end
	local egopicker = Dialog.new(_t"Select a properties set", game.w * 0.4, game.h * 0.3)
	local desc = TextzoneList.new{width=egopicker.iw * 0.6, height=egopicker.ih, pingpong=20, no_color_bleed=true}
	local list = ListColumns.new{width=math.floor(egopicker.iw * 0.4), height=egopicker.ih, scrollbar=true, sortable=true, columns={
		{name=_t"Name", width=100, display_prop="name", sort="name"},
	}, list=picked_egos, fct=function(item)
		Dialog:yesnoPopup(_t"Confirm", ('Select properties set #{bold}#"%s"#{normal}# ?'):tformat(item.name), function(ret) if ret then
			self:executeEgoSwitch(o, oldego, item.ego)
			game:unregisterDialog(egopicker)
		end end)
	end, select=function(item)
		desc:switchItem(item, item.desc)
	end}
	egopicker:loadUI{
		{left=0, top=0, ui=list},
		{right=0, top=0, ui=desc},
	}
	egopicker:setupUI(false, false)
	game:registerDialog(egopicker)
end

function _M:executeEgoSwitch(o, oldego, newego)
	local oldlesser = o.font_sacrifice_altered_lesser or 1
	local oldgreater = o.font_sacrifice_altered_greater or 1

	local oldo = o:cloneFull()
	local cost = self:getRerollCost(o, oldego)
	local ok, err = pcall(game.zone.applyEgo, game.zone, o, newego, "object", true)
	if ok then
		game.zone:removeEgo(o, oldego)
		o:resolve()
		o:resolve(nil, true)
		o:identify(true)
		o.cost = 0 -- Avoid possible cheese. Cheese is only for french people!
		o.special = true -- Forbid item vaulting it
		self.actor:incMoney(-cost)
		if oldego.greater_ego then
			-- Reapplying egos loses information on the base object so we have to replace both counts
			o.font_sacrifice_altered_greater = oldgreater + 1
			o.font_sacrifice_altered_lesser = oldlesser
		else
			o.font_sacrifice_altered_greater = oldgreater
			o.font_sacrifice_altered_lesser = oldlesser + 1
		end
		self:generateItemsList()
		self:setFocus(self.c_items_list)
	else
		Dialog:simplePopup(_t"Error!", _t"The gizmocombobulator of the font seems to have failed, you have not been billed.")
	end
end
