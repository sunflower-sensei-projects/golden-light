/// obj_player — Draw Event (NEW — didn't exist before)
///
/// This is the ONLY thing missing for the jump arc to actually show.
/// Position (x/y) already moves in a perfectly straight line during
/// pState.JUMP (intentional - see scr_Player_State_Machine's JUMP
/// case), so collision never has to deal with curved motion. The
/// visual hop-arc lives entirely here, as a draw-time-only vertical
/// offset, using jump_progress (0-1, already being advanced every
/// frame by the state machine) and jump_arc_height (already declared
/// in player_create.md's jump variable block, just never consumed
/// until now).
///
/// Since you've already wired the jump sprite/animation itself through
/// active_sprites and scr_Player_Animate, this Draw event doesn't need
/// to know or care which sprite is currently active - it just draws
/// whatever sprite_index/image_index scr_Player_Animate already set,
/// at an offset Y position during the arc.

if (state == pState.JUMP) {
	// Sine arc: 0 at takeoff, peaks at the midpoint, back to 0 at
	// landing - standard hop-arc shape, cheap to compute every frame.
	var _arc_offset = sin(jump_progress * pi) * jump_arc_height;

	draw_sprite_ext(
		sprite_index,
		image_index,
		x,
		y - _arc_offset,   // negative = upward in GameMaker's default coordinate space (Y+ is down)
		image_xscale,
		image_yscale,
		image_angle,
		image_blend,
		image_alpha
	);
} else {
	draw_self();
}
