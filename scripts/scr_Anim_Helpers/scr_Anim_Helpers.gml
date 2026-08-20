function scr_Set_Anim(_spr, _dir, _spd) {
	// Set the sprite direction and speed
	// Direction assumes the sprite strips are orderedlike so:
	// 0=down, 1=down-right, 2=right, 3=up-right, 4=up, 5=up-left, 6=left, 7=down-left
	// Adjust the frame count to match what's in the animation
	var _frame_count = sprite_get_number(_spr) / 8; // Assumes 8 directions
	var _offset      = _dir * _frame_count;
	
	if (sprite_index != _spr) {
		sprite_index = _spr;
		image_index = _offset;
	}
	
	image_speed = _spd;
	
	// Clamp playback within this direction's frame range
	if (image_index < _offset || image_index >= _offset + _frame_count) {
		image_index = _offset;	
	}
}

function scr_Set_Anim_Once(_spr, _dir, _spd) {
	// Play an animation once and hold the last frame
	var _frame_count = sprite_get_number(_spr) / 8;
	var _offset      = _dir * _frame_count;
	var _last_frame  = _offset + _frame_count - 1;
	
	if (sprite_index != _spr || image_index < _offset) {
		sprite_index = _spr;
		image_index = _offset;
		image_speed = _spd;
	}
	
	// Freeze on the last frame
	if (image_index >= _last_frame) {
		image_index = _last_frame;
		image_speed = 0;
	}
}

function scr_Facing_To_Dir(_ix, _iy) {
	// Returns 0–7 clockwise from down
    // 0=down, 1=down-right, 2=right, 3=up-right, 4=up, 5=up-left, 6=left, 7=down-left
    if (_ix == 0 && _iy == 0) return anim_dir; // preserve last dir when idle
	
	// remap to our animation sprite strip order
	// Results in 0-7, which is mapped to the strip order indices
	if (_ix == 0 && _iy > 0) return DIR_DOWN; // No X, positive Y = Down
	if (_ix > 0 && _iy > 0)  return DIR_DOWN_RIGHT; // Positive X, positive Y = Down + Right
    if (_ix > 0 && _iy == 0) return DIR_RIGHT; // No Y, positive X = Right
	if (_ix > 0 && _iy < 0)  return DIR_UP_RIGHT; // Positive X, negative Y = Up + Right
	if (_ix == 0 && _iy < 0) return DIR_UP; // No X, negative Y = Up
	if (_ix < 0 && _iy < 0)  return DIR_UP_LEFT; // Negative X, negative Y = UP + Left
	if (_ix < 0 && _iy == 0) return DIR_LEFT; // Negative X, no Y = Left
	if (_ix < 0 && _iy > 0)  return DIR_DOWN_LEFT; // Negative X, positive Y = Down + Left
	
    return anim_dir; // Default
}

function scr_battle_set_all_anim(_state, _spd) {
	var _mgr = obj_battle_controller;
	var _all = array_concat(
		_mgr.party_battlers,
		_mgr.enemy_battlers
	);
	for (var _i = 0; _i < array_length(_all); _i++) {
		var _b = _all[_i];
		if (!_b.alive) continue;
		_b.anim_state = _state;
		_b.image_speed = _spd;
	}
}