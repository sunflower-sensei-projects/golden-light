queue          = [];
current_action = undefined;
is_playing     = false;

// Begin playing a cutscene (an array of action structs)
function play(_actions) {
	queue = array_clone(_actions);
	is_playing = true;
	scr_advance_queue();
}

// Stop and clear everything
function stop() {
	queue = [];
	current_action = undefined;
	is_playing = false;
	
	// Return control to the Player
	if (instance_exists(Player)) {
		Player.interact_locked = false;
		Player.state = pState.IDLE;
	}
}

function scr_advance_queue() {
	if (array_length(queue) == 0) {
		stop();
		return;
	}
	current_action = array_shift(queue); // pop from the front
	if (struct_exists(current_action, "start")) {
		current_action.start();	
	}
}