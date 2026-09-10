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

--- Moddable Image based on material level
function resolvers.orcs_moddable_tile(image, values)
	return {__resolver="orcs_moddable_tile", image}
end
function resolvers.calc.orcs_moddable_tile(t, e)
	local slot = t[1]
	local r, r2, rb
	
	if slot == "steamsaw" then
		rb = {"%s_steamsaw_back_iron", "%s_steamsaw_back_steel", "%s_steamsaw_back_dsteel", "%s_steamsaw_back_stralite", "%s_steamsaw_back_voratun"}
		r = {"%s_steamsaw_front_iron", "%s_steamsaw_front_steel", "%s_steamsaw_front_dsteel", "%s_steamsaw_front_stralite", "%s_steamsaw_front_voratun"}
	elseif slot == "steamgun" then
		rb = {"%s_steamgun_back_iron", "%s_steamgun_back_steel", "%s_steamgun_back_dsteel", "%s_steamgun_back_stralite", "%s_steamgun_back_voratun"}
		r = {"%s_steamgun_front_iron", "%s_steamgun_front_steel", "%s_steamgun_front_dsteel", "%s_steamgun_front_stralite", "%s_steamgun_front_voratun"}
	elseif slot == "leather_hat" then r = {"gunslinger_hat_rough", "gunslinger_hat_rough", "gunslinger_hat_hardened","gunslinger_hat_rough", "gunslinger_hat_drakeskin"}
	end

	local ml = e.material_level or 1
	r = r[util.bound(ml, 1, #r)]
	if r2 then
		r2 = r2[util.bound(ml, 1, #r2)]
		e.moddable_tile2 = r2
	end
	if rb then
		rb = rb[util.bound(ml, 1, #rb)]
		e.moddable_tile_back = rb
	end
	if type(r) == "string" then return r else e.moddable_tile_big = true return r[1] end
end

--- Salves resolver
function resolvers.medical_salves(desc, cd, fct)
	return {__resolver="medical_salves", desc, cd, fct}
end
function resolvers.calc.medical_salves(tt, e)
	local cd = tt[2]
	e.max_power = cd
	e.power = e.max_power
	e.use_power = {name=tt[1], power=cd, use=tt[3], __no_merge_add=true}
	e.talent_cooldown = "T_GLOBAL_MEDICAL_CD"
	e.is_medical_salve = true
	e.unaffected_device_mastery = 1

	e.special_desc = function(self, who) local data = who:getMedicalInjector() if data then 
		return ("Using medical injector with %d%% efficiency and %d%% cooldown modifier."):tformat((data.power or 100) + (data.inc_stat or 0), data.cooldown_mod or 100)
	else
		return _t"No medical injector available, values are indicative only."
	end end

	return
end

-- Racials
resolvers.racials_defs.yeti = {
	T_ALGID_RAGE = {last=10, base=0, every=4, max=5},
	T_THICK_FUR = {last=20, base=0, every=4, max=5},
	T_RESILIENT_BODY = {last=40, base=0, every=4, max=5},
--	T_MINDWAVE = {last=30, base=0, every=4, max=5}, not allowed as this is more of an orc mindhacker thing
}
resolvers.racials_defs.undead_minotaur = {
	T_WHITEHOOVES = {last=10, base=0, every=4, max=5},
	T_DEAD_HIDE = {last=15, base=0, every=4, max=5},
	T_LIFELESS_RUSH = {last=20, base=0, every=4, max=5},
	T_ESSENCE_DRAIN = {last=30, base=0, every=4, max=5},
}

--- Schematics
function resolvers.learn_schematic(id)
	return {__resolver="learn_schematic", id}
end
function resolvers.calc.learn_schematic(tt, e)
	if game.party then
		game.party:learnTinker(tt[1])
	end
	return
end