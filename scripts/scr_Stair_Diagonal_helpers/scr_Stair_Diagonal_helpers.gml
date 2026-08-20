/// scr_Stair_Diagonal_Get_Progress(_stair, _px)  [REWRITTEN - x-based]
///
/// Simplified from the original angle/length/width design, now that
/// the stair's shape is defined by its actual collision mask (per your
/// confirmation you can set a precise custom mask) rather than
/// separate width/length parameters. Progress is now PURELY a function
/// of world x position, linearly interpolated between two endpoints
/// stored on the stair instance itself:
///
///   x_bottom - world x of the bottom/progress-0 end of the stair
///   x_top    - world x of the top/progress-1 end of the stair
///
/// Works for either orientation automatically (stairs rising to the
/// left, like your screenshot, OR rising to the right) since the
/// interpolation naturally handles x_top being less than OR greater
/// than x_bottom - no separate "rise_dir angle" needed.
function scr_Stair_Diagonal_Get_Progress(_stair, _px) {
	if (_stair.x_top == _stair.x_bottom) return 0; // safety guard against divide-by-zero if misconfigured
	return clamp((_px - _stair.x_bottom) / (_stair.x_top - _stair.x_bottom), 0, 1);
}

/// scr_Player_Start_Stair_Fall(_progress)
///
/// Triggers an IMMEDIATE fall (no wobble/delay, per your confirmation
/// - bypasses pState.SLOPE_SLIP entirely, enters pState.FALL directly).
/// Fall distance/duration is proportional to how far up the stair the
/// player was (_progress) when they stepped off the mask sideways or
/// downward.
function scr_Player_Start_Stair_Fall(_progress) {
	fall_vel = _progress * FALL_STAIR_VEL_PER_PROGRESS;
	fall_x_vel = input_x * mov_speed * 0.5; // same carry-over convention SLOPE_SLIP already uses
	fall_from_slope = false; // this ISN'T a slope fall - distinguishes the two origins
	fall_from_stair = true;
	fall_steerable = true;   // enables the mid-air steering extension in pState.FALL
	z_height = 0;            // no longer partway up anything once falling - avoids a stray z_height value lingering into the landed state
	
	state = pState.FALL;
	scr_Player_On_Enter_State();
}
