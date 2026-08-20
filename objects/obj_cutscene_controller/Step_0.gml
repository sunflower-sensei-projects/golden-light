if (!is_playing || current_action == undefined) exit;

var _done = current_action.tick();

if (_done) {
	scr_advance_queue();	
}