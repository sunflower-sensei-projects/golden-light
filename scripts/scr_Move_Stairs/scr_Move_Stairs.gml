function scr_Move_Stairs(){
	// Which axis is the stair aligned to?
	// We'll split the movement into horizontal slide + depth (Isometric Y-axis) + vertical offset.
	
	var _facing_up = scr_Check_Terrain(TAG_STAIR_UP);
	var _climb_dir = _facing_up ? -1 : 1; // -1 = ascendine, 1 = descending
	
	// Determine if the player is moving into the stairs
	// For isometric stairs, that's typically up/down on the iso Y-axis
	
	var _pressing_into = (_facing_up && input_y < 0) || (!_facing_up && input_y > 0) || (input_x != 0);
	
	if (!_pressing_into) {
		mov_speed = 0;
		return;
	}
	
	mov_speed = stair_speed;
	
	// Advance progress through the current step (0 -> 1)
	stair_progress += mov_speed / stair_step_h;
	
	// Each full step, snap the player to the next stair level
	if (stair_progress >= 1) {
		stair_progress -= 1;
		
		// Advance one "step" in iso space
		// Horizontal movement along the stair direction
		x += stair_dir * stair_step_h * 0.5; // Edit this to match stair dimensions
		// Adjust iso depth so the player renders above/below correctly
		iso_depth += stair_dir * stair_step_h;
	}
	
	// Smooth visual movement between steps, interpolate between current and next step
	var _step_frac = stair_progress;
	
	// Move smoothly along the stair path
	var _stair_vx = input_x * mov_speed * 0.6; // Lateral drift along the stairs
	var _stair_vy = _climb_dir * mov_speed;    // Main climb direction
	
	// Pixel movement with collision
	x += _stair_vx;
	y += _stair_vy;
	
	// Optionally, bob the sprite a bit to emulate "stepping"
	// image_yscale = 1 + sin(_step_frac * pi) * 0.04;
}