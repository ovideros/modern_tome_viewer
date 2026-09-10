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

local CultsDLC = require "mod.class.CultsDLC"

newLore{
	id = "cults-lost-merchant-glyph",
	category = "Forbidden Cults", always_pop = true, not_shareable = true,
	name = _t"Message from the Assassin's Lord",
	lore = function() return ([[My dear %s,

You have come a long way since the days we met. I am proud of you.
I have #{italic}#"found"#{normal}# a strange glyph sequence that to me looks like some kind of code. I have all faith you can figure out its meaning and hopefully use it to further our cause.

%s


Good luck on your future #{italic}#acquisitions of properties#{normal}#.]]):tformat(game.player.name, CultsDLC.effectGlyphsSequence("FONT_SACRIFICE")) end,
}

newLore{
	id = "cults-cultist-unlock-intro",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Introduction",
	lore = _t[[In the Age of Dusk, it seemed that the world was ending to many of Eyal's inhabitants. The destruction caused by the Spellblaze left the land withered and scorched. Food was scarce, disease was rampant and everyone was desperate. For a select few, their salvation came from an unlikely visitor. An entity they simply came to knew as The Teacher visited Eyal from somewhere beyond the stars, emerging from an ancient Sher'tul farportal. It discovered a group of survivors in the depths of Eyal which begged it for knowledge, anything they could use as a weapon against the horrors ravaging their world.

Out of charity and kindness, it agreed to teach them how to wield the power of entropy itself. However, it made it clear to them that this was not a power to be taken lightly and could very well bring about their doom. As desperate as they were, all of them agreed without a second thought, heedless of the consequences it could have.

Hithre was one of The Teacher's pupils, a Shalore who became one of the first to wield entropic magic in the entirety of Eyal.]],
}

newLore{
	id = "cults-cultist-unlock-lesson-1",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Entropic Backlash and Healing",
	lore = _t[[My first lesson to you, my students, is to understand what it means to wield entropy. When using its power, it's impossible to escape its withering touch. Your bodies will suffer from the backlash of your spells and carry a residue of those energies at all times. As such, your ability to recover from wounds and injury will be significantly impaired. However, you can learn to resist this backlash and even manipulate the threads of fate to pass it on to your enemies.

#{italic}#Go check your new spell for detailed information.#{normal}#]],
}
newLore{
	id = "cults-cultist-unlock-lesson-2",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Netherblast",
	lore = _t[[For this exercise, you will learn how to manipulate and direct entropic energies. This spell will be your main defence against your foes and will teach you to manage the backlash from using it. Few beings in existence are capable of defending themselves against the Netherblast, so practice with it frequently until you have perfected it.

#{italic}#Go check your new spell for detailed information.#{normal}#]],
}
newLore{
	id = "cults-cultist-unlock-lesson-3",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Fatebreaker",
	lore = _t[[This spell will be the most important you will learn from me. Fate is a force made up of many threads. Provided that you understand how the threads all connect to each other, you can manipulate it to your own ends. This spell will allow you to pass on doomed threads from you onto your opponents, escaping from your own preordained death. Remember that this spell should not be used lightly and that some threads do not bend to anyone's will, no matter how hard you pull.

The target dummies have been imbued with fake void energies; use your Fatebreaker on them and then use Netherblast on yourself while low on life. This is a difficult exercise, students. Be aware that you are now risking your life if you execute it wrong.

#{italic}#Go check your new spell for detailed information.#{normal}#]],
}
newLore{
	id = "cults-cultist-unlock-lesson-4",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Unravel Existence",
	lore = _t[[The building blocks of all things are held together by innumerable laws. These very laws govern all of reality and are set in stone, in most cases. With proper use of your magic, it's entirely possible to sever these bonds and defy these laws, unraveling your foe's very existence. Not only is your opponent affected by this, but the area around them is too. It creates cracks in reality which allow things to slip through. You must use this moment to call out into the void and bring forth creatures to assist you in battle.

I am somewhat hesitant to teach this spell, but all of you have been performing admirably. You [i]must[/i] not use this spell lightly. Have a clear image in your head of what you wish to summon or you will be putting yourself at the mercy of the void. There are countless entities which live between the stars, many of which are mindless and pitiless things.

Please all focus your attention on the central target dummy. Hithre you will cast Netherblast at it to keep Nihil on it while the other students will use a Dark Whisper spell on it.

#{italic}#Go check your new spells for detailed information.#{normal}#]],
}

newLore{
	id = "cults-cultist-unlock-lesson-4-fail",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Unravel Existence Failure",
	lore = _t[[No, no! Your minds aren't focused enough! I told you that you must have a clear image in your head! Do not let your foolish ambition get the better of you! You can't control what's out there!

...It is too late. Something is coming. Even I do not know what. I knew that this was a mistake.]],
}

newLore{
	id = "cults-cultist-unlock-epilogue",
	category = "Forbidden Cults", always_pop = true,
	name = _t"Lessons of Inevitability - Epilogue",
	lore = _t[[Only one person escaped alive from the summoning of the Unspeakable Thing. She believed that, despite the failure of her fellow students and the horror of what she saw, The Teacher's wisdom still had value in the apocalyptic world created by the Spellblaze. After all, is it not better to know about the horrors out there than it is to be ignorant of their existence? She began to pass on the power of entropy onto others, and they too passed it on. The ones who learned this forbidden lore became known as the Cultists of Entropy.

What became of The Teacher is unknown. Perhaps it didn't survive the encounter with the Unspeakable Thing, or perhaps it returned to its home somewhere far beyond Eyal.]],
}


newLore{
	id = "races-krog",
	category = "races",
	name = _t"Loremaster Greynot's Analysis of the Races - Chapter 12 - Krogs",
	lore = _t[[The krog are perhaps the youngest of the intelligent races of Maj'Eyal, only coming into existence recently. They claim that they were formerly ogres that have had their runes removed, somehow surviving having their runes replaced by a combination of natural infusions and drakes blood. The removal of their runes was orchestrated by the Ziguranth, who apparently decided action needed to be taken to prevent all ogres from being horribly and brutally killed as a result of the Spellhunt, leading to the creation of the krog. The official reasons given by the Ziguranth for this action was that the ogres were unfortunate victims of magic rather then perpetrators of it, and the Ziguranth were just looking to help to free them from the taint of the arcane.

Due to the fact that they were originally ogres, it comes as no surprise that the two races share much with each other. They tend to have similar hair coloring, facial features, and other similar traits. The average krog is a bit shorter then a ogre at 8'2" and perhaps a little leaner, but otherwise the rest of their body dimensions remain the same. One would likely be hard pressed to distinguish a krog from an ogre or vice versa if it wasn't for the heavy tint of greens and browns within their eyes and skin, likely a side effect of whatever natural process the Ziguranth employed to strip them of their runes.

The majority of the krog tend to live in or around the middle of the continent where the heart of Ziguranth territory lies and they have been known to take up arms in service to the anti-magic cause. Indeed one may find that the majority of any Ziguranth Patrol one may encounter is usually made up of krog fighters. All krog seem to demonstrate some connection to nature as well as possessing abilities to combat mages, not to mention harbor a huge hatred towards anyone that deals with magic in any way. Indeed, a krog's disdain for the arcane begs the question if perhaps the Ziguranth did a bit more then just remove the runes from their bodies.

Commonly when they are not in the employ of the Ziguranth, or otherwise answering the call to do battle with a rogue mage, the krog have been known to contract themselves out as laborers to whomever may hire them. Like ogres, krog are also known for having impressive appetites and one can find many krog farmers plowing fields to grow food for themselves to eat. They are also known for their talents in mixing infusions, producing the majority of what one might find in the markets around the continent.

Of course no analysis of the krog would be complete without mentioning the many stories, songs, and artwork that revolve around their many pursuits. A lot of encouragement is directed at younger krogs by their peers to venture out into the world and perform heroic deeds. This course of action seems less to do with valor, glory, or riches; something one might expect of a typical 'adventurer' and more to do with the mistrust that followed them formerly being ogres. In an effort to combat their initial image they had as former ogres, the krog sought to commit themselves to gaining a new image through achievement of impressive feats. To this end they seem to have been rather successful as evidenced by the creation of the many artistic works told about them. ]]}

newLore{
	id = "races-drem",
	category = "races",
	name = _t"Loremaster Greynot's Analysis of the Races - Chapter 13 - Drems",
	lore = _t[[Eyal's underground is abundant with strange, and not particularly wholesome, creatures. Many of them are mindless monstrosities, unable to be reasoned with and best left alone. However, perhaps the most unusual of these creatures are the Drem. For the longest time, Drem were presumed to simply be another form of horror which dwelled in Eyal's underground. The recent emergence of thinking Drem, however, has forced many scholars to reassess their race as a whole.

A Drem is roughly the same height as a Dwarf and has a vaguely similar facial structure as well. This is where the similarities between the two races tend to end. Drem have no distinguishing facial features and are incapable of growing beards like dwarves, instead growing wiry and unkempt patches of hair which vary greatly in thickness. Due to the lack of facial features such as eyes, ears, a mouth and a nose, it is not currently known how a Drem eats or how they sense things around them. The mental faculties of thinking Drem seems to vary wildly from each individual as well. Some are barely more capable of rational thought than feral Drem, while others have gained intellect comparable to the brightest minds of Eyal.

As they have only recently come out of their previously mindless states, the Drem are a people who are completely disconnected with the world around them. They possess no cultural identity or history to fall back on and sit on the precipice between the civilised races of Eyal's surface and the horrors of Eyal's underground. Many suspect that they possess some connection to the dwarves, the prevailing theory being that they are some sort of corrupted offshoot of that proud race. There has been little research into the subject and little evidence found to substantiate these claims, however. What impact the Drem will have on Eyal's future can only be speculated upon at this point.]]}
