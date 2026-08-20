/// scr_Player_Diagonal_Stair_Check()  [REWRITTEN]
///
/// Redesigned after seeing an actual screenshot of the staircase art -
/// my first version was wrong in a fundamental way: it assumed the
/// player's on-screen movement stays flat/normal 2D walking while a
/// separate "height" value is faked for draw-depth only. Your actual
/// staircase needs REAL diagonal on-screen movement - pressing left
/// visibly moves the player up-and-left, following the stair's art.
///
/// Confirmed design (from our conversation):
///   - Horizontal input (left/right) is OVERRIDDEN into diagonal
///     movement at a 1:1 ratio (equal horizontal and vertical
///     displacement each frame), at SPEED_STAIR (0.8) instead of
///     normal mov_speed - reusing the stair_speed variable/macro that
///     already existed in player_create.md but was never consumed
///     anywhere until now.
///   - Vertical input (up/down) is NOT overridden at all - it's
///     ordinary movement, completely untouched by this script. "Up"
///     naturally gets blocked by the staircase's own riser/wall
///     geometry (existing collision, no new code). "Down" lets the
///     player walk toward the edge of their current step; when they
///     exit the stair's actual collision mask while still partway up
///     (z_height between 0 and 1), that's detected below and triggers
///     a fall.
///   - This relies on obj_terrain_stair_diagonal having a PRECISE
///     collision mask matching the real staircase silhouette
///     (confirmed you can set this in the sprite editor) - NOT a
///     simple rectangle. A rectangle would let the player walk much
///     too far down from a high step before falling, since a
///     rectangle doesn't narrow the way a real staircase does. This
///     script relies entirely on instance_place's mask-accurate
///     detection for "am I still on the stair" - no separate
///     tread-depth or footprint-width math needed at all.
///
/// Called once per Step, AFTER scr_Player_Move (see wiring note in
/// 23_diagonal_stair_notes.md) - same position as before, since it
/// still needs to react to whatever movement already happened this
/// frame (either to override it, if horizontal, or just read the
/// result, if vertical).

function scr_Player_Diagonal_Stair_Check() {
	var _stair = instance_place(x, y, TAG_STAIR_DIAGONAL);
	
	if (_stair == noone) {
		// Not currently on any diagonal stair. If z_height was
		// fractional (partway up) last frame, this frame's normal
		// movement (whatever scr_Player_Move already did) carried the
		// player off the stair's mask entirely - trigger a fall,
		// proportional to how high up they were.
		if (z_height > 0.02 && z_height < 0.98) {
			scr_Player_Start_Stair_Fall(z_height);
		} else {
			// Reached a natural endpoint (top or bottom of the stair,
			// z_height was already ~0 or ~1) - not a fall, just a
			// normal exit onto ordinary floor. Reset cleanly.
			z_height = 0;
		}
		return;
	}
	
	// On the stair. Only override movement if this frame's input was
	// primarily horizontal - vertical-only input passes through
	// untouched, per the design above.
	if (input_x != 0 && input_y == 0) {
		// Undo whatever scr_Player_Move already applied this frame
		// (full mov_speed horizontal displacement) and replace it with
		// a controlled 1:1 diagonal step at stair_speed instead. Using
		// xprevious/yprevious (GameMaker's built-in last-frame position
		// trackers) rather than needing any change to scr_Player_Move
		// itself - this script corrects the frame's outcome after the
		// fact rather than intercepting movement at its source.
		var _input_dir = sign(input_x);
		var _ascending = (_input_dir == _stair.rise_dir_x); // moving in the direction that increases progress (toward x_top)
		
		var _dx = _input_dir * SPEED_STAIR;
		var _dy = _ascending ? -SPEED_STAIR : SPEED_STAIR; // ascending = up = negative y; descending = down = positive y
		
		var _new_x = xprevious + _dx;
		var _new_y = yprevious + _dy;
		
		// Collision-checked against obj_wall - this is what naturally
		// stops upward movement at the top of the stair (the riser/
		// wall geometry already placed in your tileset), no special
		// "top of stair" detection needed in code at all.
		if (!place_meeting(_new_x, y, obj_collision_parent)) {
			x = _new_x;
			px = x;
		}
		if (!place_meeting(x, _new_y, obj_collision_parent)) {
			y = _new_y;
			py = y;
		}
	}
	// else: vertical-only (or no) input - leave whatever
	// scr_Player_Move already did completely alone.
	
	z_height = scr_Stair_Diagonal_Get_Progress(_stair, x);
	
	// z_level snap at the ends - unchanged from the original design,
	// still only fires while actively moving along the rise axis, at
	// the exact progress extremes.
	if (z_height >= 1 && z_level == _stair.z_level_bottom) {
		z_level = _stair.z_level_bottom + 1;
	} else if (z_height <= 0 && z_level == _stair.z_level_bottom + 1) {
		z_level = _stair.z_level_bottom;
	}
}
