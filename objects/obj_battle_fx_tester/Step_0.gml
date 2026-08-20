// ============================================================
// Step Event
// ============================================================

if (input_delay > 0) {
	input_delay--;
}

var _up = keyboard_check_pressed(vk_up);
var _down = keyboard_check_pressed(vk_down);
var _left = keyboard_check(vk_left);
var _right = keyboard_check(vk_right);
var _cast = keyboard_check_pressed(ord("Z"));
var _clear = keyboard_check_pressed(ord("R"));
var _shift = keyboard_check(vk_shift);

// menu navigation (Up/Down), only on fresh press
if (_up) {
	selected -= 1;
	
	if (selected < 0) selected = array_length(fx_list) - 1;
}
if (_down) {
	selected += 1;
	
	if (selected >= array_length(fx_list)) selected = 0;
}

// marker movement — hold Shift + Left/Right/Up/Down for finer control
var _moveSpeed = _shift ? 1 : 4;
if (_left) marker_x -= _moveSpeed;
if (_right) marker_x += _moveSpeed;
if (keyboard_check(vk_up) && _shift) marker_y -= _moveSpeed;
if (keyboard_check(vk_down) && _shift) marker_y += _moveSpeed;

// cast selected effect at marker position
if (_cast) {
	var _entry = fx_list[selected];
	
	if (_entry.obj != -1 && _entry.obj != undefined) {
		active_fx = instance_create_layer(marker_x, marker_y, "Effects", _entry.obj);
		active_fx.target_x = marker_x;
		active_fx.target_y = marker_y;

		// Spark needs a sky reference point — give it one relative to the marker
		if (variable_instance_exists(active_fx, "sky_y")) {
			active_fx.sky_y = marker_y - 200;
		}
	} else {
		show_debug_message("FX Debug Menu: object for '" + _entry.name + "' not found — check the object name exists in your project.");
	}
}

// clear all active fx instances currently in the room (handy if one gets stuck mid-animation)
if (_clear) {
	if (instance_exists(obj_bfx_quake)) { with (obj_bfx_quake) instance_destroy(); }
	if (instance_exists(obj_bfx_ignite)) { with (obj_bfx_ignite) instance_destroy(); }
	if (instance_exists(obj_bfx_spark)) { with (obj_bfx_spark) instance_destroy(); }
	// add additional obj_fx* types here as you create them
}