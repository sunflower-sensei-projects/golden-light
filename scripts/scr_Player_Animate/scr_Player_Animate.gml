function scr_Player_Animate() {
	
	// Safety check - no sprites assigned yet
	if (active_sprites == undefined) return;
	var _s = active_sprites; // Shorthand
	
	// Update facing direction from movement input
	// Only update when actually moving, preserve last facing when idle
	if (input_any && state != pState.SLOPE_SLIP
				  && state != pState.FALL
				  && state != pState.LAND
				  && state != pState.INTERACT) {
		anim_dir = scr_Facing_To_Dir(input_x, input_y);
	}
	
	// Release animation lock when then sprite reaches the lock frame
	if (anim_locked && image_index >= anim_lock_end) {
		anim_locked = false;	
	}
	
	if (anim_locked) return;
	
	switch (state) {
		case pState.IDLE:
			scr_Set_Anim(_s.idle, anim_dir, 0.15);
			break;
		
		case pState.WALK:
			if (is_moving) {
				scr_Set_Anim(_s.walk, anim_dir, 1);
			} else {
				scr_Set_Anim(_s.idle, anim_dir, 0.15);
			}
			break;
		
		case pState.RUN:
			if (is_moving) {
				scr_Set_Anim(_s.run, anim_dir, 0.35);
			} else {
				scr_Set_Anim(_s.idle, anim_dir, 0.15);
			}
			break;
		
		case pState.STAIR:
			scr_Set_Anim(_s.walk, anim_dir, SPEED_STAIR / stair_step_h);
			break;
		
		case pState.LADDER:
			var _ladder_spd = (input_y != 0) ? 0.2 : 0;
			scr_Set_Anim(_s.climb, anim_dir, _ladder_end);
			break;
		
		case pState.SLOPE_SLIP:
			// Using set_anim_once makes it so the animation doesn't restart
			scr_Set_Anim_Once(_s.slip, anim_dir, 0.1);
			break;
		
		case pState.FALL:
			scr_Set_Anim(_s.fall, anim_dir, 0.15);
			break;
		
		case pState.LAND:
			if (land_timer == FALL_LAND_FRAMES) {
				if (fall_vel >= FALL_HURT_VEL) {
					scr_Set_Anim_Once(_s.land_hard, anim_dir, 1.0);	
				} else {
					scr_Set_Anim_Once(_s.land_soft, anim_dir, 1.0);	
				}
			}
			break;
			
		case pState.PUSH:
			scr_Set_Anim(_s.push, anim_dir, 0.10);
			break;
		
		case pState.INTERACT:
			if (instance_exists(interact_target)) {
				anim_dir = scr_Facing_To_Dir(interact_target.x - x, interact_target.y - y);	
			}
			scr_Set_Anim(_s.idle, anim_dir, 0.1);
			break;
		
		case pState.JUMP:
			scr_Set_Anim_Once(_s.jump, anim_dir, 1);
			break;
	}
}