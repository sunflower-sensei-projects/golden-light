/// scr_menu_input(_repeat_state)
/// Single input poll for the whole menu system, with held-direction
/// autorepeat. Called once per step by obj_menu_controller; the
/// resulting struct is handed down to whatever page is on top of the
/// stack.
///
/// _repeat_state is a small struct the controller owns and passes in
/// each call (see scr_menu_repeat_state_init) - autorepeat needs to
/// track how many frames a direction has been held, which has to
/// persist across frames, so it can't live inside this function itself.
///
/// Autorepeat timing: first move fires immediately on press (frame 0).
/// If held, nothing fires again until REPEAT_DELAY frames have passed
/// (a deliberate pause so a single tap never accidentally double-fires),
/// then it fires every REPEAT_INTERVAL frames until released. Only
/// affects right/left/up/down - accept/back/menu stay single-fire,
/// since autorepeating a "confirm" or "close menu" button is exactly
/// the kind of thing that causes accidental double-actions.
///
/// Keybinds match the original objects: arrows to navigate, Z to
/// accept, X to go back, C to open/close the menu entirely.
function scr_menu_input(_repeat_state) {
	return {
		right:  scr_menu_dir_held(_repeat_state, "right", vk_right),
		left:   scr_menu_dir_held(_repeat_state, "left", vk_left),
		up:     scr_menu_dir_held(_repeat_state, "up", vk_up),
		down:   scr_menu_dir_held(_repeat_state, "down", vk_down),
		accept: keyboard_check_pressed(ord("Z")),
		back:   keyboard_check_pressed(ord("X")),
		menu:   keyboard_check_pressed(ord("C"))
	};
}

/// scr_menu_repeat_state_init()
/// Call once (e.g. in obj_menu_controller's Create event) to build the
/// autorepeat tracking struct. Store the result and pass it into
/// scr_menu_input every step.
function scr_menu_repeat_state_init() {
	return {
		right: 0, left: 0, up: 0, down: 0,
		REPEAT_DELAY: 18,    // frames to hold before autorepeat kicks in (~300ms at 60fps)
		REPEAT_INTERVAL: 6   // frames between repeats once active (~100ms at 60fps)
	};
}

/// scr_menu_dir_held(_state, _key_name, _vk)
/// Internal helper - advances one direction's hold counter and returns
/// true on the frames it should count as a "move" (initial press, plus
/// autorepeat pulses after the delay).
function scr_menu_dir_held(_state, _key_name, _vk) {
	var _held = keyboard_check(_vk);

	if (!_held) {
		_state[$ _key_name] = 0;
		return false;
	}

	var _frames = _state[$ _key_name] + 1;
	_state[$ _key_name] = _frames;

	if (_frames == 1) {
		return true; // initial tap
	}
	if (_frames <= _state.REPEAT_DELAY) {
		return false; // held, but still in the pre-repeat pause
	}
	// Past the delay - fire every REPEAT_INTERVAL frames.
	return ((_frames - _state.REPEAT_DELAY) mod _state.REPEAT_INTERVAL) == 0;
}

/// scr_menu_input_blocked()
/// Returns an all-false input struct. Used while a textbox is open or
/// during the post-open debounce window, same purpose as the old
/// wait_timer / menu_wait checks scattered through every object.
function scr_menu_input_blocked() {
	return {
		right: false, left: false, up: false, down: false,
		accept: false, back: false, menu: false
	};
}
