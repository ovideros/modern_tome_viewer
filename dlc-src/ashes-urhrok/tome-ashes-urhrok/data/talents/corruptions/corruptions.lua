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

-- Demonologist
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/demon-seeds", name = _t("demon seeds", "talent type"), description = _t"Demon seeds powers can not be learnt, they must be used from demon seeds attached to your equipment." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/demonic-pact", name = _t("demonic pact", "talent type"), description = _t"Bind and use demons to do your bidding." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/infernal-combat", name = _t("infernal combat", "talent type"), description = _t"Imbue your melee attacks with lethal demonic powers." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/doom-shield", name = _t("doom shield", "talent type"), description = _t"Imbue yourself with the forces of Mal'Rok, the demon's homeworld, to protect and enhance." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, generic = true, type="corruption/black-magic", name = _t("black-magic", "talent type"), description = _t"That Old Black Magic." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, min_lev = 10, type="corruption/doom-covenant", name = _t("doom covenant", "talent type"), description = _t"Control darkness to crush your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, min_lev = 10, type="corruption/spellblaze", name = _t("spellblaze", "talent type"), description = _t"Use the very power of the Spellblaze to destroy your foes." }

--Doombringer
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/brutality", name = _t("brutality", "talent type"), description = _t"Devastating two-handed physical attacks fueled by demonic power." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/torture", name = _t("torture", "talent type"), description = _t"Cripple your enemies with vicious two-handed attacks." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/wrath", name = _t("wrath", "talent type"), min_lev=10 ,description = _t"Destroy your enemies with intense two-handed physical attacks fueled by demonic power." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/fearfire", name = _t("Fearfire", "talent type"), min_lev=10 ,description = _t"Call upon the flames of the Fearscape, incinerating all." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/heart-of-fire", name = _t("Heart of Fire", "talent type"),description = _t"Fire is your lifeblood; it revitalizes you as it burns your foes." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, generic = true,type="corruption/demonic-strength", name = _t("demonic strength", "talent type"),  description = _t"Infuse your body with the power of Demons." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, generic = true, type="corruption/oppression", name = _t("Oppression", "talent type"),description = _t"Make your blows terrify your foes and manipulate their fear." }

damDesc = Talents.main_env.damDesc
corrs_req1 = Talents.main_env.corrs_req1
corrs_req2 = Talents.main_env.corrs_req2
corrs_req3 = Talents.main_env.corrs_req3
corrs_req4 = Talents.main_env.corrs_req4
corrs_req5 = Talents.main_env.corrs_req5

corrs_req_high1 = Talents.main_env.corrs_req_high1
corrs_req_high2 = Talents.main_env.corrs_req_high2
corrs_req_high3 = Talents.main_env.corrs_req_high3
corrs_req_high4 = Talents.main_env.corrs_req_high4
corrs_req_high5 = Talents.main_env.corrs_req_high5

str_corrs_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_corrs_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_corrs_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_corrs_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_corrs_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

str_corrs_req_high1 = {
	stat = { str=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
str_corrs_req_high2 = {
	stat = { str=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
str_corrs_req_high3 = {
	stat = { str=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
str_corrs_req_high4 = {
	stat = { str=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
str_corrs_req_high5 = {
	stat = { str=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

function setupDemonSummon(self, m, x, y)
	if m.ai ~= "summoned" and m.ai ~= "party_member" then
		m.ai_real = m.ai
		m.ai = "summoned"
	end

	m.summoner = self
	m.summoner_gain_exp = true
	m.demonic_summon = true
	m.dead = nil
	m.dead_by_unsummon = nil
	m:removeEffectsFilter(m, function() return true end, 9999, true, true)

	m.life_regen = 0

	m:setPersonalReaction(self, 100)
	m.never_anger = 1
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.no_inventory_access = true
	m.no_points_on_levelup = true
	m.minion_be_nice = 1
	m.from_doom_concordat = nil
	m.save_hotkeys = true
	m.ai_state = m.ai_state or {}
	m.ai_state.tactic_leash = 100
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	if game.party:hasMember(self) then
		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control="no",
			type="summon",
			title=_t"Demon",
			orders = {target=true, leash=true, anchor=true, talents=true},
		})
	end
	-- m:resolve() m:resolve(nil, true)
	game.zone:addEntity(game.level, m, "actor", x, y)
	if core.shader.active(4) then
		game.level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=1.5, life=30, img="felfire_03"}, {type="firesurge"})
	else
		game.level.map:particleEmitter(x, y, 1, "circle", {oversize=1.7, a=100, limit_life=12, shader=true, appear=12, speed=2, img="demon_flames_circle", radius=0})
	end

	if self.player then world:gainAchievement("ASHES_FULL_PARTY", self) end

	-- Remove seed on death
	m.on_die = function(self)
		if not self.summoner then return end
		if self.summoner:knowTalent(self.summoner.T_SUFFUSE_LIFE) then self.summoner:callTalent(self.summoner.T_SUFFUSE_LIFE, "onDemonHeal", self) end
	end
	if self:knowTalent(self.T_SUFFUSE_LIFE) then self:callTalent(self.T_SUFFUSE_LIFE, "onDemonHeal", m) end
end

-- local nt = newTalent
-- local nb=0
-- newTalent = function(...) nb=nb+1 return nt(...) end
load("/data-ashes-urhrok/talents/corruptions/demon-seeds.lua")
load("/data-ashes-urhrok/talents/corruptions/demonic-pact.lua")
load("/data-ashes-urhrok/talents/corruptions/infernal-combat.lua")
load("/data-ashes-urhrok/talents/corruptions/doom-shield.lua")
load("/data-ashes-urhrok/talents/corruptions/doom-covenant.lua")
load("/data-ashes-urhrok/talents/corruptions/spellblaze.lua")
load("/data-ashes-urhrok/talents/corruptions/black-magic.lua")

load("/data-ashes-urhrok/talents/corruptions/demonic-strength.lua")
load("/data-ashes-urhrok/talents/corruptions/brutality.lua")
load("/data-ashes-urhrok/talents/corruptions/wrath.lua")
load("/data-ashes-urhrok/talents/corruptions/torture.lua")
load("/data-ashes-urhrok/talents/corruptions/fearfire.lua")
load("/data-ashes-urhrok/talents/corruptions/heart-of-fire.lua")
load("/data-ashes-urhrok/talents/corruptions/oppression.lua")

load("/data-ashes-urhrok/talents/corruptions/npcs.lua")
-- print("===", nb)
-- os.crash()