function gameInit(){
	// This function initializes the game for first-time playing
	
	// Set all the global settings variables
	scr_Macros();
	
	// Add the player "Joshua" to the party registry
	var _check = 0;
	_check = addProtagToParty("Joshua");
	
	if _check == 0 {
		show_debug_message("Successfully added Joshua to the party!")	
	}
	else {
		show_debug_message("Failed to add Joshua to the party.");
		show_debug_message("Hard quitting game with error: failure to add player to game")
		game_end();
	}
}