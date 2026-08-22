/// obj_menu_controller - Step Event

if (open_wait > 0) {
	open_wait -= 1;
}

// --- Opening the menu from the overworld ---
if (!is_open) {
	if (open_wait == 0 && global.game_state == gState.OVERWORLD && keyboard_check_pressed(ord("C"))) {
		is_open = true;
		global.menu_open = true;
		open_wait = OPEN_WAIT_FRAMES;

		scr_menu_stack_clear();
		scr_menu_stack_push(scr_menu_page_general(mgr), undefined);

		if (!instance_exists(obj_menu_pointer)) {
			instance_create_depth(0, 0, -11, obj_menu_pointer);
		}
	}
	exit;
}

// --- Menu is open: block input during debounce, otherwise poll and delegate ---
var _blocked = (open_wait > 0 || instance_exists(obj_menu_textbox_sm));
var _input;
if (_blocked) {
	_input = scr_menu_input_blocked();
	was_blocked = true;
} else {
	if (was_blocked) {
		// Just came out of a blocked period - clear hold counters so a
		// direction held through the block doesn't resume mid-repeat.
		repeat_state = scr_menu_repeat_state_init();
		was_blocked = false;
	}
	_input = scr_menu_input(repeat_state);
}

var _top = scr_menu_stack_peek();

if (is_undefined(_top)) {
	// Stack ran dry (shouldn't normally happen - general menu should
	// always be the floor) - just close.
	is_open = false;
	global.menu_open = false;
	open_wait = OPEN_WAIT_FRAMES;
	exit;
}

// Global "close everything" key, honored at every level.
if (_input.menu) {
	is_open = false;
	global.menu_open = false;
	open_wait = OPEN_WAIT_FRAMES;
	scr_menu_stack_clear();
	exit;
}

// Global "back" - pages can consume this themselves (e.g. to go from
// item-options back to item-grid) by handling _input.back in their own
// step() and NOT requesting a pop; if they don't handle it, popping
// one level is the default. Pages signal "I didn't consume back" by
// returning the string "pop" from step().
var _result = _top.step(_input);

if (_result == "pop") {
	scr_menu_stack_pop();
	if (scr_menu_stack_is_empty()) {
		is_open = false;
		global.menu_open = false;
		open_wait = OPEN_WAIT_FRAMES;
	}
}
else if (is_struct(_result) && variable_struct_exists(_result, "push")) {
	// Pages request pushing a new page by returning { push: page_struct, param: x }
	scr_menu_stack_push(_result.push, _result[$ "param"]);
}
else if (is_struct(_result) && variable_struct_exists(_result, "close_all")) {
	is_open = false;
	global.menu_open = false;
	open_wait = OPEN_WAIT_FRAMES;
	scr_menu_stack_clear();
}

// --- Cursor positioning ---
// The active page (post-transition) reports where the cursor should
// be; the controller is the only place that ever touches
// obj_menu_pointer.x/y now, instead of every menu level hand-computing it.
_top = scr_menu_stack_peek();
if (!is_undefined(_top) && instance_exists(obj_menu_pointer)) {
	var _cursor = (variable_struct_exists(_top, "get_cursor")) ? _top.get_cursor() : undefined;
	if (is_undefined(_cursor)) {
		obj_menu_pointer.visible = false;
	} else {
		obj_menu_pointer.visible = true;
		obj_menu_pointer.x = _cursor.x;
		obj_menu_pointer.y = _cursor.y;
	}
}
