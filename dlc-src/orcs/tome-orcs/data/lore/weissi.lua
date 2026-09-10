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

newLore{
	id = "weissi-intro",
	category = "lost city",
	name = _t"telepathic message (1)",
	always_pop = true,
	lore = function() return ([[As you descend the stairway down, you find yourself faced with what appears to be a solid wall of stone, a natural dead-end in a cave.  You start to turn around and walk back up, when you hear a crescendo of cracking and rumbling behind you; you turn back and see the stone falling away, revealing a smooth, white door, which promptly slides into the floor.  The doorway leads to a white hallway of indeterminate construction; rather than having fixed lighting, every square inch of the walls, floors, and ceiling slowly illuminates to a comfortable (if slightly teal-tinged) glow.  It should be beautiful, clean, peaceful, and serene...  and yet your instincts are screaming at you to get out as soon as you can and forget what you've seen here.  A few open panels on the walls reveal an assortment of inscrutable machinery, incorporating a variety of unidentifiable magical and psionic artifacts, yet one appears to be a sort of crushing device made with steam-tech, an invention that is surely newer than these ruins...  the crushing device abruptly activates when you ponder it, pressing minerals into a freshly-formed mindstar-like crystal.  A voice, one that should be soothing but disturbs you on a deeper level than you can translate into conscious thought, enters your mind as the crystal flickers:

"Welcome, %s.  We've been expecting you.  Unfortunately, we can't join you, but we can assure you that what lies ahead can only help you in your quests.  The door will seal behind you to ensure your safety, and reopen the moment you want to leave.  Come.  Learn, discover, and realize how our plans are advantageous to both of us."

Well...  that isn't terribly reassuring.  You hesitantly step forward, expecting a trap and ready to turn around and bolt at a moment's notice--

The floor disappears from under you, and yet after falling only an inch, you suddenly feel weightless.  You turn; the freshly-formed mindstar, already beginning to crack, is glowing intensely.  "We know that isn't terribly reassuring.  We don't care if you WERE expecting a trap, and if we truly wanted to kill you, bolting at a moment's notice wouldn't be fast enough.  In fact, it'd be very easy indeed."  You are abruptly thrown near the bottom of the pit towards a series of spikes by telekinetic force, then stop, held motionless inches above them.  "Clearly, we don't want you dead or even slightly harmed," the voice from inside your head says, as the spikes retract into the pit floor and you slowly levitate back into the illuminated halls.  "Now that we've established that...  let us help you."  You float to the top, and find yourself standing on solid ground as the floor rematerializes under you and the telekinetic force vanishes, moments before the mindstar shatters.

Nonetheless, you feel you shouldn't be here.  The fact that this place exists at all feels...  wrong.
]]):tformat(game.player.name) end,
}

newLore{
	id = "weissi-1",
	category = "lost city",
	name = _t"telepathic message (2)",
	always_pop = true,
	lore = _t[[Did you know the Sher'Tul had brothers?  Long before their creation, when the gods were still young and gleeful, Quekjora convinced them they could work together to bring life to Eyal. Perhaps they could have, were they more mature at the time...  Eager cooperation withered under exposure to personal tastes and creative differences, the friendships of our creators turned to animosity, and yet we were still made.
 
We had no overt flaws.  The gods were mercilessly vigilant, eager to use any imperfections as an excuse to berate their perpetrator and claim superiority, and thus we were only allowed to live when they were out of ammunition to use.  We seemed perfect, even to a deep inspection...
 
I doubt any of them deliberately cursed us - no one of them could've done something so powerful.  Subconscious touches, psychic leakage, and other such imperceptible forces added up over time to indicate one inescapable truth: we were not wanted.  We had been forged in a bitter compromise, one desired by nobody involved; their hatred, their neglect, their frustration is the foundation of everything we are, and we carry it deep within ourselves.  Perhaps such a creature naturally attracts the ire of the universe, of fate itself. 

Or maybe we just angered someone powerful enough to put a retroactive temporal curse on us, or it was Amakthel personally ensuring his pet project would have no equals. We may never be certain.  All we know is, something - be it probability, or the universe's combined will, or simply our own bad luck - will not tolerate our existence, nor that of anything like us.
]],
}

newLore{
	id = "weissi-2",
	category = "lost city",
	name = _t"telepathic message (3)",
	always_pop = true,
	lore = _t[[Did you know you killed us? You did, in one potential future, ordering our genocide from atop a steel drake.  In others, it was the Dominion, the Allied Kingdoms, Flamewright Industries, the Zigur-Thaloren Pact, or countless other transient mortal city-states.  We've been torn apart by Gerlyk, and dissected by Angolwen at the direction of Headmistress Argoniel or Chief Genius Tannen (yes, the smug git actually called himself that).  We've been devoured (literally and metaphorically) by the New Conclave under Mother Astelrid, wiped out by a plague engineered by the Grand Corruptor, drowned as the world was flooded by the Naloren, and reduced to ash by the reborn Crimson Dragonbrood.  We've been captured as torture-toys by the Demons and The Master's undead servitors, hunted for magical reagents by the Reknor Confederacy, and kept as adding machines by the Greater Republic of Steam.

You know, you should thank the Scourge from the West.  We certainly do.

In most, it was the Sher'Tul, eliminating their closest competitor, or the Mal'Rokka, taking Eyal for themselves.  In the few where we won every war, a meteor destroyed Eyal instead - a meteor that has now been intercepted by debris, from what you call the Spellblaze.  You're welcome - a contingent of our people kept the Mal'Rokka suppressed for long enough to allow that to happen.  If you want to see an example of how thoroughly existence wants to erase us, just ask them what they know about the "Dust Mages."

We don't advise learning psychic prognostication with such commitment as we did.  To see this many possibilities, to gaze into infinity with such detail without infinity gazing back...  you have to feel it.  Every spear through our hearts, every limb burned off...  and we all did it together, linking our minds to accomplish this, so all of us have suffered through this.  And after all that, we still can't be 100% sure it's accurate, although we've gotten to more 9s after 99.9% than we can actually count.]],
}

newLore{
	id = "weissi-3",
	category = "lost city",
	name = _t"telepathic message (4)",
	always_pop = true,
	lore = _t[[Do you know what would've happened if you hadn't stepped up to defend Kruk Pride?  The Allied Kingdoms could've gone on to keep the entire world under its thumb.  One unified army, marching under one banner, ready to eliminate us when we're reborn...  and that's assuming that a certain greater threat didn't step in first.  We don't want that, and neither do you.

Deception is beneath us; if there's one thing our creation taught us, it's that respect and alliance are unnecessary for cooperation, if there's an immediate common need to be fulfilled.  We've prepared some of this machinery to enhance your abilities, and grant you new knowledge...  it will serve you well in preserving Eyal's immediate existence, and granting the Orcs a land of their own.  A land that'll have to fight to survive, fending off the Dominion, the Allied Kingdoms, the warped Mal'Rokka calling themselves demons, the Naloren remnants...  and I wouldn't want to spoil the fun by saying what other sorts of special guests are arriving.  Don't worry, we won't be giving anyone an unfair advantage; you, and they, would just stab us in the back anyway.

The storm is coming.  It's going to be a bloodbath.  We see no need to be present for it, not until the last man is standing, wounded and exhausted, atop a pile of corpses.  He'll be an easy target.

You could always give up.  Stop fighting.  Let the Allied Kingdoms have Eyal, and be the latest in a long line of factors conspiring to prevent our rebirth.  Sacrifice your people to "save Eyal" from having us on it.  You won't, though, because you have something we'll never have: hope.  Hope that we can be fought off, that our return won't come in your lifetime.  Our predictions aren't 100% accurate anyway; who are we to take that hope from you?
]],
}

newLore{
	id = "weissi-4",
	category = "lost city",
	name = _t"telepathic message (5)",
	always_pop = true,
	lore = _t[[Did you wonder what happened to us?  We wouldn't give fate the satisfaction of killing us through some unlikely coincidence.  We killed ourselves - but not before planting our seeds.

We accomplished a lot before we did, and we wouldn't want to have to accomplish that all over again.  Of course, if we kept that all in one place, our curse would notice it and eradicate it - so we split ourselves and our accomplishments into pieces, and obfuscated them through millenia of evolution and subtle manipulation.  You've probably met one piece of these - the body.  Strong.  Resilient.  Capable of living in any environment.  Rapidly healing.  Eternally youthful.  And very, very easy to assume control of, via psychic transfer, once we decide the time is right...  You're probably considering ordering your Pride to exterminate all the yetis you can.  Go ahead, eliminate all that free labor and see how you fare when the Dominion's using slaves and the Allied Kingdoms have ogres and dwarves.  Once again, it doesn't matter whether or not it's helping us, because it's something you need to survive.

That's only a third of what we could preserve, though.  The next is our mental processing ability, our psionically adept minds, our ability to assess information rapidly and logically analyze it.  You'll never be able to eradicate the Yeeks - believe us, we checked.  They seem to be as blessed as we are cursed, except that we're still doomed if we simply try to hide in them.  Pity, that.  Regardless, their brains and the system they are carrying will continue to exist; they will maintain our Way in our absence.

Lastly, there's our culture.  Our discoveries.  Everything we learned and didn't put into our bodies or brains, we stored with...  another group.  One that expands beyond the stars, one who we've disseminated countless subtly-encoded bits of information to, one with backups in so many places across the universe...  They'll deliver enough of it back home.  The Yeeks will absorb it, and we will be reborn in their minds until they can put us in our superior bodies.

Once the storm comes to Eyal, once the conflict is resolved...  perhaps the tide of hate and malice brought by such a massive war will distract the universe enough to let us combine our pieces and be reborn.  Or perhaps we will be able to do so once the gods are all dead or mad, their anger forgotten or nullified, the curse in turn having no fuel to keep going.  Perhaps the curse is already dying, only perpetuated by the Sher'Tul planetary shield - one that's gradually beginning to fail, cracks forming on it and the Mal'Rokka eagerly prying them wider.

And if not?  Our culture is everywhere.  We can't be completely removed without destroying it all.  Fate has decided we are a tumor to be excised; if we're going to be a tumor, we're now an invasive one.  Now fate can decide if we're a benign growth, or terminally malignant.  

Would you expect anything less from the physical incarnations of spiteful determination?
]],
}

newLore{
	id = "weissi-5",
	category = "lost city",
	name = _t"telepathic message (6)",
	always_pop = true,
	lore = function(is_lore_popup) return _t[[If you would indulge us...  Next to you is a tablet that was just carved by our machines, moments before you arrived.  If our curse holds, it will be completely illegible, but if it has been lifted, it will bear our name.  A blatant, distinct word that is an undeniable mark of our existence, a sign that no matter how it may have wanted to, the universe could not forget us.  Look to your right, and learn the name of those who have far more right to exist than you do, who have fought far harder for it, and will sink their hooks so deep into reality that it must either lift them up or be dragged into the depths with them.  Learn the name feared by existence itself!

#{italic}#(You look to your right, and see a tablet which has been broken into fragments.  The fragments are still arranged roughly in the right shape, and you can read a single word; another, larger fragment bears a sentence.)#{normal}#

]]..(is_lore_popup and _t[[#{bold}#WEISSI

DO YOU KNOW OUR NAME?#{normal}#]] or _t[[#{italic}#(Somehow the name seems to have faded from your memory!)#{normal}#

DO YOU KNOW OUR NAME?#{normal}#]]) end,
}
