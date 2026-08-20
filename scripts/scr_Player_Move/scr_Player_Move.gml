function scr_Player_Move(){
	switch (state) {
		
		case pState.IDLE:
			mov_speed = 0;
			is_moving = false;
			break;
		
		case pState.WALK:
		case pState.RUN:
			mov_speed = (state == pState.RUN) ? SPEED_RUN : SPEED_WALK;
			var _mx = input_x * mov_speed;
			var _my = input_y * mov_speed;
			is_moving = scr_Move_And_Collide(_mx, _my);
			if (input_any) dir = point_direction(0, 0, input_x, input_y);
			break;
		
		case pState.STAIR:
			scr_Move_Stairs();
			break;
		
		case pState.LADDER:
			scr_Move_Ladder();
			break;
		
		case pState.SLOPE_SLIP:
			scr_Move_Slope_Slip();
			break;
		
		case pState.FALL:
			scr_Move_Fall();
			break;
		
		case pState.LAND:
			scr_Move_Land();
			break;
		
		case pState.PUSH:
			scr_Move_Push();
			break;
		
		case pState.INTERACT:
			mov_speed = 0;
			break;
	}
}