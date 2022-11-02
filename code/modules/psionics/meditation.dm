/obj/item/organ/internal/psionic_tumor/nano_ui_interact(mob/user, ui_key = "meditation", datum/nanoui/ui = null) // I don't like ui work; I don't like ui work; I don't like ui work

//Psionic meditation (I'm trying get this to work, okay?)
/obj/item/organ/internal/psionic_tumor/proc/meditation()
	set category = "Psionic powers"
	set name = "Psionic Meditation (0)"
	set desc = "Clear you mind of all thoughts and emerging deep into your subconsciousness. This will allow you to deepen your connection to your Psionic Tumor, giving you more potent power in return."
	psi_point_cost = 0

	to_chat(owner, "You meditate. This helps you grow.")
