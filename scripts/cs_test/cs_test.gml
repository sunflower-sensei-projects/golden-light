function cs_test() {
	obj_cutscene_controller.play([
		
		cs_lock_player(),
		
		// Ariadne walks up to the player
		cs_move_to(obj_ariadne_npc, Player.x + 32, Player.y, 2),
		
		// Both characters face each other
		cs_parallel( 
			[ cs_face(Player         , 6) ], // Player faces left = 6
			[ cs_face(obj_ariadne_npc, 2) ]  // Ariadne faces right = 2
		),
		
		cs_wait(20),
		
		cs_dialogue("Ariadne", "I'm joining your cr3w, nigga."),
		cs_dialogue("Joshua" , "Based."),
		cs_dialogue("Ariadne", "Okay, that's enough cringe."),
		
		cs_wait(20),
		
		// Ariadne joins the party, play fanfare
		cs_add_party_member("Ariadne"),
		
		cs_wait(15),
		
		cs_unlock_player()
	]);
}