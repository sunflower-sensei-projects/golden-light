function scr_Move_Fall() {
	// Gravity
	fall_vel = min(fall_vel + FALL_GRAVITY, FALL_MAX);
	
	// Very limited air control, player can slightly steer in the air
	var _air_control = 0.3;
	fal_x_vel = lerp(fall_x_vel, input_x * mov_speed * _air_control, 0.1);
	
	// Move vertically
	var _move_y = fall_vel;
	var _move_X = fall_x_vel;
	
	// Horizontal collision
	if (!place_meeting(x + _move_x, y, obj_wall)) x += _move_x;
	
	// Vertical movement
	y += _move_y;
	
	// Update iso depth as the player falls
	iso_depth = 0; // resets the depth during free-fall
}