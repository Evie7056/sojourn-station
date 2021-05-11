//basic xenomorph mob, used as a glass cannon kind of fodder
var/datum/xenomorph/xenomorph_ai

/mob/living/carbon/superior_animal/xenomorph
	name = "drone"
	desc = "A basic xenomorph drone, all slime, teeth, and claws. Looking at it unnerves you..."
	icon = 'icons/mob/Xenos_48x48.dmi'
	icon_state = "drone"
	icon_living = "drone"
	icon_dead = "drone_dead"
	icon_rest = "drone_stunned"
	icon_gib = "drone_gibbed"
	pass_flags = PASSTABLE

	mob_size = MOB_LARGE
	viewRange = 12

	maxHealth = 30
	health = 30
	randpixel = 0
	gibspawner = /obj/effect/gibspawner/xenomorph
	attack_sound = list('sound/xenomorph/alien_claw_flesh1.ogg', 'sound/xenomorph/alien_claw_flesh2.ogg', 'sound/xenomorph/alien_claw_flesh3.ogg')
	attack_sound_chance = 100
	speak_emote = list("hisses", "screeches", "trills")
	emote_see = list("flexes and unflexes its claws.", "whips its tails about wildly!", "drips saliva onto the ground.")
	speak_chance = 5
	deathmessage = "lets out a shrill scream as it dies!"
	overkill_gib = 20
	overkill_dust = 20

	move_to_delay = 4
	turns_per_move = 12
	see_in_dark = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/xenomeat
	meat_amount = 3
	leather_amount = 0
	bones_amount = 0
	stop_automated_movement_when_pulled = 0

	melee_damage_lower = 10
	melee_damage_upper = 15
	can_burrow = FALSE
	acceptableTargetDistance = 5
	flash_resistances = 50 //No eyes.

	min_breath_required_type = 0
	min_air_pressure = 0 //below this, brute damage is dealt
	min_breath_poison_type = 0

	var/poison_per_bite = 0
	var/poison_type = "xenotoxin"
	pass_flags = PASSTABLE
	faction = "xenomorph"

	fleshcolor = "#00ff00"
	bloodcolor = "#00ff00"

/mob/living/carbon/superior_animal/xenomorph/slip(var/slipped_on,stun_duration=8)
	return FALSE
//Xenos can't be slipped but can be flashed, after all, secondary senses like thermal vision are usually easily overloaded by lights.

/mob/living/carbon/superior_animal/xenomorph/New()
	..()
	if(!icon_living)
		icon_living = icon_state
	if(!icon_dead)
		icon_dead = "[icon_state]_dead"

	objectsInView = new

	verbs -= /mob/verb/observe
	pixel_x = -14
	pixel_y = 0

/mob/living/carbon/superior_animal/xenomorph/hunter/New()
	..()
	if(!icon_living)
		icon_living = icon_state
	if(!icon_dead)
		icon_dead = "[icon_state]_dead"

	objectsInView = new

	verbs -= /mob/verb/observe
	pixel_x = 0
	pixel_y = 0

/mob/living/carbon/superior_animal/xenomorph/attack_hand(mob/living/carbon/M as mob)
	..()
	var/mob/living/carbon/human/H = M

	switch(M.a_intent)
		if (I_HELP)
			help_shake_act(M)

		if (I_GRAB)
			if(!weakened)
				M.visible_message("\red [src] breaks the grapple and impales [M] with its tail!")
				M.adjustBruteLoss(50)
				M.Weaken(3)
				return 1
			else
				if(M == src || anchored)
					return 0
				for(var/obj/item/weapon/grab/G in src.grabbed_by)
					if(G.assailant == M)
						to_chat(M, SPAN_NOTICE("You already grabbed [src]."))
						return

				var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
				if(buckled)
					to_chat(M, SPAN_NOTICE("You cannot grab [src], \he is buckled in!"))
				if(!G) //the grab will delete itself in New if affecting is anchored
					return

				M.put_in_active_hand(G)
				G.synch()
				LAssailant = M

				M.do_attack_animation(src)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				visible_message(SPAN_WARNING("[M] has grabbed [src] passively!"))

				return 1

		if (I_DISARM)
			if (!weakened && (prob(10 + (H.stats.getStat(STAT_ROB) * 0.1))))
				M.visible_message("\red [M] has knocked \the [src] over!")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				Weaken(3)

				return 1
			else
				M.visible_message("\red [M] gets impaled by \the [src]'s tail!")
				M.adjustBruteLoss(50)
				M.Weaken(3)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			M.do_attack_animation(src)

		if (I_HURT)
			var/damage = 3
			if ((stat == CONSCIOUS) && prob(10))
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				M.visible_message("\red [M] missed \the [src]")
			else
				if (istype(H))
					damage += max(0, (H.stats.getStat(STAT_ROB) / 10))
					if (HULK in H.mutations)
						damage *= 2

				playsound(loc, "punch", 25, 1, -1)
				M.visible_message("\red [M] has punched \the [src]")

				adjustBruteLoss(damage)
				updatehealth()
				M.do_attack_animation(src)

				return 1