function scr_Move_Push(){
	if (!instance_exists(push_target)) return;
	
	// Lock the push to one axis, no diagonal allowed
	var _mx = 0;
	var _my = 0;
	
	if (push_axis == 1) {
		_mx = input_x * SPEED_PUSH;
	} else {
		_my = input_y * SPEED_PUSH;	
	}
	
	// Move the block the same amount (block calculates its own collision)
	with (push_target) {
		var _bx = _mx;
		var _by = _my;
		// Block collision against walls
		if (place_meeting(x + _bx, y, obj_collision_parent)) _bx = 0;
		if (place_meeting(x, y + _by, obj_collision_parent)) _by = 0;
		x += _bx;
		y += _by;
	}
	
	// Move the player
	scr_Move_And_Collide(_mx, _my);
	
	// If block can't move, player can't either, but that's already handled by the move_and_collide script
}