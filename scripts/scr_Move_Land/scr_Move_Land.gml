function scr_Move_Land() {
	mov_speed = 0;
	
	anim_dir = scr_Facing_To_Dir(input_x, input_y);
	
	// Hard landing, stagger for a few frames if the vertical fall speed was high enough
	if (land_timer == FALL_LAND_FRAMES) {
		if (fall_vel >= FALL_HURT_VEL) {
			scr_Set_Anim_Once(active_sprites.land_hard, anim_dir, 1.0);
		} else {
			scr_Set_Anim_Once(active_sprites.land_soft, anim_dir, 1.0);
		}
	}
}