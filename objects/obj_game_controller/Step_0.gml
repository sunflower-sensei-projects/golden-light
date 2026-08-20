// Check to see if the player is quitting by holding the esc key
if (keyboard_check(vk_escape)) {
	if (!quitting) {
		quitting = true;	
	}
	quit_timer += 1; // Counts up every frame the esc key is held
	
	if (quit_timer >= 60) { // Quits the game after one second
		game_end();	
	}
}
else {
	if (quitting) {
		quitting = false;	
	}
	if (quit_timer > 0) {
		quit_timer = 0;
	}
}