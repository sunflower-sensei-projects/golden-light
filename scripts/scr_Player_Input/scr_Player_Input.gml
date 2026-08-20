function scr_Player_Input(){
	// Raw axis input
	var _ix = (keyboard_check(vk_right) || keyboard_check(ord("D")))
			- (keyboard_check(vk_left)  || keyboard_check(ord("A")));
	var _iy = (keyboard_check(vk_down)  || keyboard_check(ord("S")))
			- (keyboard_check(vk_up)    || keyboard_check(ord("W")));
	
	// Normalize the diagonal input
	var _len = sqrt(_ix*_ix + _iy*_iy);
	if (_len > 0) {
		input_x = _ix / _len;
		input_y = _iy / _len;
	} else {
		input_x = 0;
		input_y = 0;
	}
	
	if (global.menu_open) {
		input_x = 0;
		input_y = 0;
		_len = 0;
		
		input_run = false;
		input_interact = false;
		input_any = (_len > 0);
	} else {
		input_run = keyboard_check(KEY_RUN);
		input_interact = keyboard_check(KEY_INTERACT);
		input_any = (_len > 0);
	}
	
	input_menu = keyboard_check(KEY_MENU);
}