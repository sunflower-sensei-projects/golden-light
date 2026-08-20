function scr_Move_Slope_Slip() {
	// Player is frozen, playing wobble animation
	// Small visual nudge towards the slope
	mov_speed = 0;
	
	var _nudge = (SLOPE_SLIP_DELAY - slip_timer) / SLOPE_SLIP_DELAY;
	y += _nudge * 0.8;
	
	// Moake sure to lock movement controls
}