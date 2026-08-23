function scr_Check_Terrain(_tag) {
    return instance_place(x, y, _tag) != noone;
}

function scr_Get_Terrain_Instance(_tag) {
	// Returns the instance of a terrain object
	// For getting its position, etc.
	return instance_place(x, y, asset_get_index(_tag));
}

function scr_Find_Interact_Target() {
    var _range   = 24;
    var _front_x = x + lengthdir_x(_range, dir);
    var _front_y = y + lengthdir_y(_range, dir);
    
    if (!object_exists(TAG_INTERACT)) return noone;
    
    var _inst = instance_nearest(_front_x, _front_y, TAG_INTERACT);
    if (_inst == noone) return noone;
    if (point_distance(x, y, _inst.x, _inst.y) > _range) return noone;
    return _inst;
}

function scr_Find_Pushover() {
	// Check to see if the player is moving into a pushable object right now
	var _check_x = x + input_x * 1;
	var _check_y = y + input_y * 1;
	var _inst = instance_place(_check_x, _check_y, obj_pushable);
	if (_inst != noone) {
		// Lock push axis to dominant axis
		push_axis = (abs(input_x) >= abs(input_y)) ? 1 : 2;
	}
	return _inst;
}

function scr_Is_Pushing(_target) {
	if (!instance_exists(_target)) return false;
	if (push_axis == 1 && input_x == 0) return false;
	if (push_axis == 2 && input_y == 0) return false;
	var _check_x = x + input_x * 8;
	var _check_y = y + input_y * 8;
	return instance_place(_check_x, _check_y, _target) != noone;
}

function scr_Move_And_Collide(_mx, _my) {
	px += _mx;
	py += _my;
	
	// Round to integers for collsion and movement
	var _nx = round(px);
	var _ny = round(py);
	
	var _moved_x = false;
	var _moved_y = false;
	
	if (!player_check_collision(x + _mx, y, obj_collision_parent)
		&& !player_check_collision(x + _mx, y, obj_terrain_gap)) {
		x += _mx;
		_moved_x = (_mx != 0);
	} else {
		px = x;
	}
	
	if (!player_check_collision(x, y + _my, obj_collision_parent)
		&& !player_check_collision(x, y + _my, obj_terrain_gap)) {
		y += _my;
		_moved_y = (_my != 0);
	} else {
		py = y;
	}
	
	return _moved_x || _moved_y;
}

function player_check_collision(_x, _y, _object) {
	// This functions the same as place_meeting, but takes z-level into consideration
	var _inst = instance_position(_x, _y, _object);
	
	if (_inst == noone) return false;
	
	if (place_meeting(_x, _y, _inst)) {
		if (variable_instance_exists(_inst, "z_level")) {
			if (_inst.z_level == Player.z_level) {
				return true;	
			}
		}
	}
	return false;
}