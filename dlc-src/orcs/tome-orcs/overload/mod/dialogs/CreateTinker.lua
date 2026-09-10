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
local ListColumns = require "engine.ui.ListColumns"
local Textbox = require "engine.ui.Textbox"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local Button = require "engine.ui.Button"
local EntityDisplay = require "engine.ui.EntityDisplay"
local Checkbox = require "engine.ui.Checkbox"
local FontPackage = require "engine.FontPackage"
local Object = require "mod.class.Object"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(party, actor)
	self.actor = actor
	self.party = party
	self.search_filter = nil
	self.cur_tier = 1
	Dialog.init(self, _t"Tinkers", game.w * 0.8, game.h * 0.8)

	self.tinkerslist = Object:loadList("/data-orcs/general/objects/tinker.lua")
	self.tinkerslist.__real_type = "object"

	self.c_search = Textbox.new{title=_t"Search: ", text="", chars=30, max_len=60, fct=function() end, on_change=function(text) self:search(text) end}

	self.c_entity = EntityDisplay.new{width=64, height=64}

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 20 - self.c_search.h, scrollbar=true, sortable=true, columns={
		{name=_t"", width={24,"fixed"}, display_prop="", direct_draw=function(item, x, y)
			if core.renderer then
				if item.display_entity then return item.display_entity:getDO(h, h) end
			else
				item.tdef.display_entity:toScreen(nil, x+2, y+2, 20, 20)
			end
		end},
		{name=_t"Tinker", width=45, display_prop="name", sort="sort_name"},
		{name=_t"Slot", width=15, display_prop="slot", sort="slot"},
		{name=_t"School", width=20, display_prop="base_category", sort="base_category"},
		{name=_t"Status", width=20, display_prop="status", sort="status"},
	}, list={}, fct=function(item) self:use(item) end, select=function(item, sel) self:select(item) end}
	
	self:generateList()

	self.c_create = Button.new{text=_t"Create", fct=function() self:create() end}
	self.c_cur_desc = TextzoneList.new{scrollbar=true, width=math.floor(self.iw / 2 - 10), height=self.ih - 200}
	self.c_cur_name = TextzoneList.new{scrollbar=true, width=math.floor(self.iw / 2 - 10), height=64, font={FontPackage:getFont("default"), 48}}
	self.c_cur_tier1 = Checkbox.new{title=_t"Tier 1", default=false, fct=function() end, on_change=function(s) if s then self:selectTier(1) end end}
	self.c_cur_tier2 = Checkbox.new{title=_t"Tier 2", default=false, fct=function() end, on_change=function(s) if s then self:selectTier(2) end end}
	self.c_cur_tier3 = Checkbox.new{title=_t"Tier 3", default=false, fct=function() end, on_change=function(s) if s then self:selectTier(3) end end}
	self.c_cur_tier4 = Checkbox.new{title=_t"Tier 4", default=false, fct=function() end, on_change=function(s) if s then self:selectTier(4) end end}
	self.c_cur_tier5 = Checkbox.new{title=_t"Tier 5", default=false, fct=function() end, on_change=function(s) if s then self:selectTier(5) end end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{left=5, bottom=self.c_search.h - 4, ui=Separator.new{dir="vertical", size=math.floor(self.iw / 2 - 10)}},
		{left=0, bottom=0, ui=self.c_search},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
		{right=5, top=0, ui=self.c_entity},
		{right=5, top=0, ui=self.c_cur_name, hidden=true},
		{right=5, top=self.c_cur_name.h, ui=self.c_cur_desc, hidden=true},
		{right=5, bottom=5, ui=self.c_create, hidden=true},
		{right=self.c_create, bottom=5, ui=self.c_cur_tier5, hidden=true},
		{right=self.c_cur_tier5, bottom=5, ui=self.c_cur_tier4, hidden=true},
		{right=self.c_cur_tier4, bottom=5, ui=self.c_cur_tier3, hidden=true},
		{right=self.c_cur_tier3, bottom=5, ui=self.c_cur_tier2, hidden=true},
		{right=self.c_cur_tier2, bottom=5, ui=self.c_cur_tier1, hidden=true},
	}
	self:setFocus(self.c_search)
	self:setupUI()
	self.c_list:selectColumn(3)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}

	self:select(self.list[1])
end

function _M:select(item)
	if item then
		-- self.c_desc:switchItem(item, item.desc)
	end
end

function _M:use(item)
	if not item then return end
	if self.current_item then self.current_item.color = self.current_item.dcolor end
	self.current_item = item
	item.color = colors.simple(colors.LIGHT_GREEN)

	self.c_entity.entity = item.tdef.display_entity
	self.c_cur_name:switchItem(item, "#LIGHT_BLUE#"..item.name)
	self:getUIElement(self.c_create).hidden = false
	self:getUIElement(self.c_cur_desc).hidden = false
	self:getUIElement(self.c_cur_name).hidden = false

	self:getUIElement(self.c_cur_tier1).hidden = true
	self:getUIElement(self.c_cur_tier2).hidden = true
	self:getUIElement(self.c_cur_tier3).hidden = true
	self:getUIElement(self.c_cur_tier4).hidden = true
	self:getUIElement(self.c_cur_tier5).hidden = true
	if self.party:canMakeTinker(self.actor, self.current_item.id, 1) then self:getUIElement(self.c_cur_tier1).hidden = false if not self.changing_tier then self:selectTier(1) end end
	if self.party:canMakeTinker(self.actor, self.current_item.id, 2) then self:getUIElement(self.c_cur_tier2).hidden = false if not self.changing_tier then self:selectTier(2) end end
	if self.party:canMakeTinker(self.actor, self.current_item.id, 3) then self:getUIElement(self.c_cur_tier3).hidden = false if not self.changing_tier then self:selectTier(3) end end
	if self.party:canMakeTinker(self.actor, self.current_item.id, 4) then self:getUIElement(self.c_cur_tier4).hidden = false if not self.changing_tier then self:selectTier(4) end end
	if self.party:canMakeTinker(self.actor, self.current_item.id, 5) then self:getUIElement(self.c_cur_tier5).hidden = false if not self.changing_tier then self:selectTier(5) end end

	local desc_tier = util.bound(self.cur_tier or 1, item.tdef.base_ml or 1, item.tdef.max_ml or 5)
	if not item.desc[desc_tier] then
		item.desc[desc_tier] = self:getDescription(item.tdef, desc_tier)
	end
	self.c_cur_desc:switchItem(item.desc[desc_tier], item.desc[desc_tier])
end

function _M:selectTier(ml)
	self.c_cur_tier1.checked = false
	self.c_cur_tier2.checked = false
	self.c_cur_tier3.checked = false
	self.c_cur_tier4.checked = false
	self.c_cur_tier5.checked = false
	self.cur_tier = ml
	self["c_cur_tier"..ml].checked = true
	if self.current_item then self.changing_tier = true self:use(self.current_item) self.changing_tier = false end
end

function _M:create()
	if not self.current_item then return end

	self.party:makeTinker(self.actor, self.current_item.id, self.cur_tier)
	game:playSound({"ambient/town/town_large2", vol=300})
	self.actor:talentDialogReturn(true)
	game:unregisterDialog(self)
end

function _M:getDescription(tdef, ml)
	ml = ml or 1
	ml = ml < 1 and 1 or ml
	local str = tstring{}
	str:merge(tdef.desc:toTString())
	str:add(true)
	if tdef.talents then
		str:add(_t"Requires talents:", true)
		for tid, level in pairs(tdef.talents) do
			local color = {"color", "LIGHT_RED"}
			if self.actor:getTalentLevel(tid) >= level then color = {"color", "LIGHT_GREEN"} end
			str:add("- ", color, self.actor:getTalentFromId(tid).name, " (", tostring(level), ")", {"color", "LAST"}, true)
		end
	end
	if tdef.ingredients then
		str:add(_t"Requires ingredients:", true)
		for ing, qty in pairs(tdef.ingredients) do
			local color = {"color", "LIGHT_RED"}
			local amt = 0
			if self.party:hasIngredient(ing..ml, qty) or self.party:hasIngredient(ing, qty) then
				color = {"color", "LIGHT_GREEN" }
				amt = self.party.ingredients[ing..ml] or self.party.ingredients[ing]
			end
			str:add("- ", color, _t((self.party:getIngredient(ing..ml) or self.party:getIngredient(ing)).name), " (", tostring(qty), ")", color, (" (You have: %s)"):tformat(tostring(amt)), {"color", "LAST"}, true)
		end
	end
	if tdef.items then
		local inven = self.actor:getInven("INVEN")
		str:add(_t"Requires items:", true)
		for ing, name in pairs(tdef.items) do
			ing = util.getval(ing, ml)
			name = util.getval(name, ml)
			local color = {"color", "LIGHT_RED"}
			if self.actor:findInInventoryBy(inven, "define_as", ing..ml) or self.actor:findInInventoryBy(inven, "define_as", ing) then color = {"color", "LIGHT_GREEN"} end
			str:add("- ", color, _t(name, "entity name"), {"color", "LAST"}, true)
		end
	end
	if tdef.special then
		str:add(_t"Requires:", true)
		for _, d in ipairs(tdef.special) do
			local color = {"color", "LIGHT_RED"}
			if d.cond(tdef, self.party, self.actor) then color = {"color", "LIGHT_GREEN"} end
			str:add("- ", color, d.desc, {"color", "LAST"}, true)
		end
	end


	local oid = "TINKER_"..tdef.id..ml
	if self.tinkerslist[oid] then
		local o = game.zone:makeEntityByName(game.level, self.tinkerslist, oid)
		if o then
			o.identified = true -- To not trigger unique lore pop
			str:add(true, {"color", "ORANGE"}, {"font", "bold"}, _t"Example Item:", {"font", "italic"}, {"color", "WHITE"}, true)
			str:merge(o:getDesc())
			str:add({"font", "normal"})
		end
	end

	return str
end

function _M:search(text)
	if text == "" then self.search_filter = nil
	else self.search_filter = text end

	self:generateList()
end

function _M:matchSearch(name)
	if not self.search_filter then return true end
	return name:lower():find(self.search_filter:lower(), 1, 1)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	for id, tdef in pairs(self.party.__tinkers_ings or {}) do
		if self.party:knowTinker(id) and self:matchSearch(tdef.name) then
			local slot = "--"
			local upto = 5
			while upto >= 1 and not self.party:canMakeTinker(self.actor, id, upto) do upto = upto - 1 end

			if tdef.display_entity then tdef.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end

			if tdef.fake_slot then
				slot = tdef.fake_slot:lower():gsub('_', ' ')
			end
			local flag = true
			for ml = 1, 5 do
				local oid = "TINKER_"..id..ml
				if self.tinkerslist[oid] then
					local o = self.tinkerslist[oid]
					if o.on_type then
						if o.on_subtype then
							flag = false
							slot = _t(o.on_type).." / ".._t(o.on_subtype) break
						else
							slot = o.on_type break
						end
					elseif o.on_slot then
						flag = false
						slot = _t(o.on_slot, "entity on slot"):lower():gsub('_', ' ') break
					elseif o.slot then
						slot = o.slot:lower():gsub('_', ' '):gsub("body",_t"body") break
					end
				end
			end

			if flag == true then slot = _t(slot) end

			list[#list+1] = {
				id=id,
				sort_name = (upto>0 and 1 or 2)..tdef.name,
				name=tdef.name,
				base_category=tdef.base_category,
				status=upto > 0 and ("create tier( %s )"):tformat(upto) or _t"missing reqs",
				desc={},
				tdef=tdef,
				slot=slot,
				max_ml = upto,
				color = colors.simple(upto > 0 and colors.WHITE or colors.RED),
				dcolor = colors.simple(upto > 0 and colors.WHITE or colors.RED),
			}
		end
	end
	table.sort(list, function(a, b) return a.sort_name < b.sort_name end)
	self.list = list

	self.c_list:setList(list)
end
