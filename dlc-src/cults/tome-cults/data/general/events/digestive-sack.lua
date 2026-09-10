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

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local imagekind
if zone.short_name == "cults+maggot" then
	imagekind = "maggot"
elseif zone.short_name == "cults+godfeaster" then
	imagekind = "godfeaster"
else
	imagekind = rng.percent(50) and "maggot" or "godfeaster"
end

local o
local r = rng.range(0, 99)
if r < 10 then
	o = game.state:generateRandart{lev=resolvers.current_level+10}
elseif r < 40 then
	o = game.zone:makeEntity(game.level, "object", {tome={double_greater=1}}, nil, true)
else
	o = game.zone:makeEntity(game.level, "object", {tome={greater_normal=1}}, nil, true)
end

if rng.percent(50) and o.wielder then
	local r = rng.range(0, 99)
	if r < 20 then
		o.wielder.inc_damage = o.wielder.inc_damage or {}
		o.wielder.inc_damage[engine.DamageType.BLIGHT] = (o.wielder.inc_damage[engine.DamageType.BLIGHT] or 0) + 10
		o.desc = (o.desc or "") .. _t"\n#DARK_SEA_GREEN#It was corrupted by the digestive sack."
	elseif r < 50 then
		o.wielder.resists = o.wielder.resists or {}
		o.wielder.resists[engine.DamageType.BLIGHT] = (o.wielder.resists[engine.DamageType.BLIGHT] or 0) + 10
		o.desc = (o.desc or "") .. _t"\n#DARK_SEA_GREEN#It was hardened by the digestive sack."
	else
		o.wielder.disease_immune = (o.wielder.disease_immune or 0) + 0.15
		o.desc = (o.desc or "") .. _t"\n#DARK_SEA_GREEN#It was changed by the digestive sack."
	end
end

r = 99 - r 
local ms
if rng.percent(r * 2) then
	local elitedata = {}
	if rng.percent(50) then
		elitedata = {name_scheme = _t"corrupted #base#", force_classes = {
			[rng.table{"Cultist of Entropy", "Writhing One", "Reaver", "Corruptor"}] = true,
		}}
	end

	ms = {}
	r = rng.range(0, 99)
	if r < 8 or true then
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_boss=elitedata}, nil, true)
	elseif r < 25 then
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_elite=elitedata}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_elite=elitedata}, nil, true)
	elseif r < 60 then
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_elite=elitedata}, nil, true)
	else
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
	end
end 

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = _t"giant digestive sack"
g.display='~' g.color_r=255 g.color_g=215 g.color_b=0 g.notice = true
g.always_remember = true g.special_minimap = {b=150, g=50, r=90}
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/"..imagekind.."/giant_digestive_sack_closed.png", z=5}
end
g:altered()
g.special = true
g.chest_item = o
g.chest_guards = ms
g.digestive_sack_imagekind = imagekind
g.block_move = function(self, x, y, who, act, couldpass)
	if not who or not who.player or not act then return false end
	if self.chest_opened then return false end

	require("engine.ui.Dialog"):yesnoPopup(_t"Giant Digestive Sack", _t"Open the sack?", function(ret) if ret then
		self.chest_opened = true
		if self.chest_item then
			game.zone:addEntity(game.level, self.chest_item, "object", x, y)
			game.logSeen(who, "#DARK_SEA_GREEN#An object rolls from the sack!")
			if self.chest_guards then
				for _, m in ipairs(self.chest_guards) do
					if game.level.data and game.level.data.special_level_faction then
						m.faction = game.level.data.special_level_faction
					end
					local mx, my = util.findFreeGrid(x, y, 5, true, {[engine.Map.ACTOR]=true})
					if mx then game.zone:addEntity(game.level, m, "actor", mx, my) end
				end
				game.logSeen(who, "#DARK_SEA_GREEN#A not yet digested foe burst out from the sack!")
			end
		end
		self.chest_item = nil
		self.chest_guards = nil
		self.block_move = nil
		self.special = nil
		self.autoexplore_ignore = true
		self.name = _t"giant digestive sack (opened)"

		if self.add_displays and self.add_displays[1] then 
			self.add_displays[1].image = "terrain/"..self.digestive_sack_imagekind.."/giant_digestive_sack_open.png"
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
		end

		if who:canBe("disease") and rng.percent(30) then
			local diseases = {{who.EFF_WEAKNESS_DISEASE, "str"}, {who.EFF_ROTTING_DISEASE, "con"}, {who.EFF_DECREPITUDE_DISEASE, "dex"}}
			local dur = rng.range(10, 15)
			local damage = who.max_life / 2 / dur
			local dispower = 3 + game.zone.base_level + game.level.level
			local disease = rng.table(diseases)
			game.logSeen(who, "#DARK_SEA_GREEN#Sickening fumes emanates from the sack as it opens!")
			who:setEffect(disease[1], dur, {src=self, dam=damage, [disease[2]]=dispower}) -- No save check, not a bug
		end
	end end, _t"Open", _t"Leave")

	return false
end
game.zone:addEntity(game.level, g, "terrain", x, y)
print("[EVENT] digestive-sack placed at ", x, y)
return true
