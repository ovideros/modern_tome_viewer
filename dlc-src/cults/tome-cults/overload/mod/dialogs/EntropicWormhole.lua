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
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local Image = require "engine.ui.Image"
local NumberSlider = require "engine.ui.NumberSlider"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, _t"Entropic Wormhole", game.w * 0.8, game.h * 0.8)

	self:generateList()

	self.__current_handicap = 200
	self.c_handicap = NumberSlider.new{title=_t"Handicap: ", w=self.iw - 10, max=1200, min=100, value=200, on_change = function(v) self.__current_handicap = v end}

	self.c_list = ListColumns.new{width=math.floor(self.iw - 10), height=self.ih - 10 - self.c_handicap.h, scrollbar=true, sortable=true, columns={
		{name=_t"Player", width=15, display_prop="player", sort="player"},
		{name=_t"Character", width=45, display_prop="character", sort="character"},
		{name=_t"Status", width=40, display_prop="addons_status", sort="addons_status"},
	}, list=self.list, fct=function(item) self:importCharball(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_handicap},
		{left=0, top=self.c_handicap, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI()
	self:select(self.list[1])

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:generateList()
	profile.chat:selectChannel("tome")

	local ownaddons = {}
	for addon, data in pairs(game.__mod_info.addons) do
		if not data.cheat_only then ownaddons[addon] = true end
	end
	local oM, om, op = game.__mod_info.version[1], game.__mod_info.version[2], game.__mod_info.version[3]

	-- For testing	
	-- ownaddons = {['items-vault']=true, possessors=true}
	-- oM, om, op = 1, 5, 5

	-- Makes up the list
	local list = {}
	for login, user in pairs(profile.chat.channels.tome.users) do
		local _, _, M, m, p, saddons = user.module:find("^tome%-(%d+)%.(%d+)%.(%d+) %[([^]]*)%]$")
		M = tonumber(M)
		m = tonumber(m)
		p = tonumber(p)
		if M == oM and m == om and p == op and saddons and user.valid == "validate" and user.current_char_data and user.current_char_data.uuid then
			local addons = {}
			print(M, m, p, addons)
			for addon in saddons:gmatch("tome%-([^;]+)%-(%d+)%.(%d+)%.(%d+)") do
				print("", addon)
				addons[addon] = true
			end
			local cmp = table.compareKeys(ownaddons, addons)

			-- Discard users with addons we do not have
			if not next(cmp.right) or true then
				local status
				if next(cmp.right) then -- this one is only for testing
					status = "#LIGHT_RED#Uses the different DLCs/addons than you do."
				elseif not next(cmp.left) then
					status = "#LIGHT_GREEN#Uses the same DLCs/addons as you do."
				else
					status = "#YELLOW#You use more DLCs/addons, this character may or may not work."
				end
				list[#list+1] = { player=user.name, character=user.current_char, id=user.id, uuid=user.current_char_data.uuid, addons_status=status }
			end
		end
	end
	-- Add known artifacts
	table.sort(list, function(a, b) return a.character < b.character end)
	self.list = list
end

function _M:select(item)
	if item then
	end
end

function _M:importCharball(item)
	if not item or not item.uuid then return false end
	local ok = false

	print(pcall(function()
		local data = profile:getCharball(item.id, item.uuid)
		local f = fs.open("/charballs/__import.charball", "w")
		f:write(data)
		f:close()

		savefile_pipe:ignoreSaveToken(true)
		local ep = savefile_pipe:doLoad("__import", "entity", "engine.CharacterBallSave", "__import")
		savefile_pipe:ignoreSaveToken(false)
		for a, _ in pairs(ep and ep.members and ep.members or {}) do
			if a.__CLASSNAME == "mod.class.Player" then
				game:unregisterDialog(self)
				if not config.settings.cheat then game:saveGame() end -- Annoying for testing, safer for players
				game:chronoClone("multiverse_fight")
				game:changeLevel(1, "cults+fortress-arena", {direct_switch=true, keep_chronoworlds=true})

				local spot = game.level:pickSpot{type="spawn", subtyp="entropic"}

				a = self:createFoe(a, self.__current_handicap)
				game.zone:addEntity(game.level, a, "actor", spot.x, spot.y)
				ok = true return
			end
		end
	end))
	if ok then return true end

	if game._chronoworlds and game._chronoworlds.multiverse_fight then
		require("mod.class.CultsDLC").backFromSMACK(_t"Entropic Wormhole failure", _t[[The wormwhole failed to latch on a timeline, you should retry an other one.

#{italic}##GREY#The character you tried to download either contained errors, was somehow corrupt or failed to load. Possible reasons are numerous and could be related to addons. Please simply try an other one.#{normal}#]])
	else
		Dialog:simpleLongPopup(_t"Entropic Wormhole failure", _t[[The wormwhole failed to latch on a timeline, you should retry an other one.

#{italic}##GREY#The character you tried to download either contained errors, was somehow corrupt or failed to load. Possible reasons are numerous and could be related to addons. Please simply try an other one.#{normal}#]], 500)
	end

	return false
end

function _M:difficultyValid(p, a)
	if not p.descriptor then return false end
	if not a.descriptor then return false end
	if not p.descriptor.difficulty == "Easy" then return false end -- Whatever, achievements dont work for Easy
	if p.descriptor.difficulty == a.descriptor.difficulty then return true end -- Fight your own, fine

	local checks = {
		Normal = { "Nightmare", "Insane", "Madness" },
		Nightmare = { "Insane", "Madness" },
		Insane = { "Madness" },
	}
	if not checks[p.descriptor.difficulty] then return false end -- WTF ?
	local check = table.reverse(checks[p.descriptor.difficulty])
	if check[a.descriptor.difficulty] then return true end
	return false -- too bad
end

function _M:createFoe(a, handicap)
	local p = game:getPlayer(true)

	mod.class.NPC.castAs(a)
	engine.interface.ActorAI.init(a, a)
	a.quests = {}
	a.ai = "tactical"
	a.ai_state = {talent_in=1}
	a.no_drops = true
	a.keep_inven_on_death = false
	a.exp_worth = 0
	a.energy.value = 0
	a.player = nil
	a.level = a.level or 1
	a.__diff_ok = self:difficultyValid(p, a)
	a.__entropic_handicap = handicap
	a.faction = "enemies"
	a.on_die = function(self) game:onTickEnd(function()
		game:chronoRestore("multiverse_fight", true)
		local p = game:getPlayer(true)
		if self.__entropic_handicap >= 800 and self.level >= p.level and self.level >= 50 and self.__diff_ok then
			world:gainAchievement("CULTS_ENTROPIC_HANDICAP_800", p)
		elseif self.__entropic_handicap >= 400 and self.level >= p.level and self.level >= 40 and self.__diff_ok then
			world:gainAchievement("CULTS_ENTROPIC_HANDICAP_400", p)
		elseif self.__entropic_handicap >= 200 and self.level >= p.level and self.level >= 30 and self.__diff_ok then
			world:gainAchievement("CULTS_ENTROPIC_HANDICAP_200", p)
		end
		Dialog:simpleLongPopup(_t"S.M.A.C.K", (_t[[As your foe crumbles Yiilkgur's safety protocols activate and pull you out of the arena.
You have defeated #CRIMSON#%s#LAST#, congratulations!]]):format(self.name), 500)
	end) end

	a:removeEffectsFilter(a, function() return true end, 9999, true, true) -- Remove all buff/debuff, but keep sustains
	a.max_life = a.max_life * a.__entropic_handicap / 100
	a:resetToFull()
	a.inc_damage.all = (a.inc_damage.all or 0) + (a.__entropic_handicap - 100) / 3

	-- We can get wild with the player to protect it from death as we already are in a chronoclone that will always end up discarded
	p.die = function(self)
		require("mod.class.CultsDLC").backFromSMACK("S.M.A.C.K", [[Yiilkgur's safety protocols activate as you fall lifeless, restoring the timeline.
You have lost your fight.]])
	end
	p:removeEffectsFilter(p, function() return true end, 9999, true, true) -- Remove all buff/debuff, but keep sustains
	p:setEffect(p.EFF_SMACK_ENTROPIC_WORMHOLE, 665, {})
	p:resetToFull()

	return a
end
