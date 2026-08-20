/// Field Push (Move psynergy) support functions.
///
/// Three pieces:
///   1. scr_Find_Push_Target() - the "can I grab something" check.
///   2. scr_Get_Cardinal_Input_Dir() - reads directional input during
///      the aim phase, snapped to one of the 4 compass directions.
///   3. scr_Player_Resolve_Push() - runs the destination check (which
///      can result in BLOCKED, a normal CLEAR slide, or FALLS off a
///      TAG_CLIFF_EDGE marker to a lower z_level) and drives whichever
///      outcome plays out, frame by frame.
///
/// All three run in Player's own context (called via `with (Player)`
/// from the state machine / registry), matching every other finder in
/// this project.
///
/// PUSH_PHASE_SLIDE / PUSH_PHASE_FALL are local sub-phase markers for
/// scr_Player_Resolve_Push's internal bookkeeping (stored on the
/// player as push_resolve_phase) - not pState values, since per your
/// answer the player stays in pState.SORCERY_RESOLVE the whole time
/// regardless of which sub-phase the pushed object is in.
#macro PUSH_PHASE_SLIDE 0
#macro PUSH_PHASE_FALL  1

/// scr_Find_Push_Target()
///
/// Confirmed targeting rules (Golden Sun Move, verified via research):
///   - Range of 2 tiles: the target can be 1 OR 2 tiles away in a
///     straight line (i.e. up to one tile of empty space between
///     caster and target is allowed).
///   - Requires a direct line between caster and target - checked here
///     as "the object is found via instance_place at exactly 1 tile OR
///     exactly 2 tiles along the facing direction," which inherently
///     enforces a straight line (a diagonal or off-axis object simply
///     won't be found by either check).
///   - Target must be at the same z_level as the caster (per your
///     confirmation - same rule as the jump landing check). NOTE: this
///     check was written correctly from the start, but had no real
///     data behind it until obj_pushable actually tracked z_level (see
///     12_obj_pushable_zlevel_notes.md) - before that, `_inst.z_level`
///     would have been undefined and this comparison would have
///     silently misbehaved. Once you add the z_level variable per that
///     note, this check starts working as originally intended with no
///     further changes needed here.
///   - Only obj_pushable_pillar and generic obj_pushable both remain
///     valid Field Push targets (unlike jump's landing check, which
///     deliberately excludes plain obj_pushable - Field Push is a
///     general "move stuff around" tool, not landing-surface-specific,
///     so it should grab anything push-able, crates included).
///
/// Returns an instance or noone.
function scr_Find_Push_Target() {
	// Check 1-tile distance first (more common case - most Move
	// puzzles in Golden Sun involve adjacent objects), fall back to
	// 2-tile if nothing's immediately adjacent.
	var _near_x = x + lengthdir_x(TILE_SIZE, dir);
	var _near_y = y + lengthdir_y(TILE_SIZE, dir);
	var _far_x  = x + lengthdir_x(TILE_SIZE * 2, dir);
	var _far_y  = y + lengthdir_y(TILE_SIZE * 2, dir);

	var _inst = instance_place(_near_x, _near_y, obj_pushable);
	if (_inst == noone) {
		_inst = instance_place(_far_x, _far_y, obj_pushable);
	}

	if (_inst == noone) return noone;
	if (_inst.z_level != z_level) return noone;

	return _inst;
}

/// scr_Get_Cardinal_Input_Dir()
///
/// Reads input_x/input_y (already established elsewhere in this
/// project - see scr_Find_Pushover's use of them) and snaps to one of
/// the 4 compass directions for the push-direction choice. Diagonal
/// input picks whichever axis has the larger magnitude, same
/// dominant-axis convention scr_Find_Pushover already uses for
/// push_axis. Returns -1 if no direction is currently held.
function scr_Get_Cardinal_Input_Dir() {
	if (input_x == 0 && input_y == 0) return -1;

	if (abs(input_x) >= abs(input_y)) {
		return (input_x > 0) ? 0 : 180;   // right : left
	} else {
		return (input_y > 0) ? 90 : 270;  // down : up
	}
}

/// scr_Player_Resolve_Push()
///
/// Called every frame while in pState.SORCERY_RESOLVE. Handles the
/// one-time destination check (first frame only, gated by
/// push_resolve_started), then one of three outcomes:
///
///   1. BLOCKED - something solid at the destination tile. No
///      movement, sorcery ends immediately.
///   2. CLEAR - normal slide tween to the destination tile, exactly as
///      before.
///   3. FALLS - the destination tile is a TAG_CLIFF_EDGE marker (a
///      DIFFERENT marker from TAG_GAP - a player-jumpable gap and a
///      pushable-object cliff edge are deliberately distinct concepts,
///      per your correction). The object first slides normally onto
///      the edge tile (same tween as CLEAR), then drops to the lower
///      z_level the edge marker specifies, with its own brief fall/
///      land animation - mirrors the shape of your player's own
///      pState.FALL/LAND, just simpler (no slope-slip wobble stage,
///      straight into the drop) and living entirely inside this one
///      function rather than as separate pState values, since per
///      your answer the PLAYER stays locked the whole time regardless
///      - there's no reason for the object to need its own parallel
///      state machine when nothing else needs to run concurrently
///      with it.
///
/// Returns true once fully finished (whichever outcome), so the state
/// machine knows to return control to the player.
function scr_Player_Resolve_Push() {
	if (!instance_exists(sorcery_push_target)) {
		return true; // target vanished somehow - bail out cleanly rather than erroring
	}

	if (!push_resolve_started) {
		push_resolve_started = true;
		push_resolve_phase = PUSH_PHASE_SLIDE; // see macro block below

		var _dx = lengthdir_x(TILE_SIZE, sorcery_push_dir);
		var _dy = lengthdir_y(TILE_SIZE, sorcery_push_dir);

		var _blocked = false;
		var _falls   = false;
		var _fall_to_z_level = 0;

		with (sorcery_push_target) {
			// Same collision check style as scr_Move_And_Collide uses
			// for the player - checked against obj_collision_parent, so
			// a sorcery-pushed object respects the same walls/other
			// solid objects everything else does. Also blocked by
			// another obj_pushable sitting in the destination tile,
			// since two pushables shouldn't be able to overlap.
			if (place_meeting(x + _dx, y + _dy, obj_collision_parent)
			|| place_meeting(x + _dx, y + _dy, obj_pushable)) {
				_blocked = true;
			} else {
				// Check for a cliff edge at the destination BEFORE
				// treating it as a normal clear tile - TAG_CLIFF_EDGE
				// is checked here, not folded into the obj_collision_parent
				// check above, since a cliff edge is explicitly NOT
				// solid (the object is meant to pass over it and fall,
				// not be blocked by it).
				var _edge_inst = instance_place(x + _dx, y + _dy, TAG_CLIFF_EDGE);
				if (_edge_inst != noone) {
					_falls = true;
					_fall_to_z_level = _edge_inst.z_level; // the floor BELOW, per the marker's own stored value - see TAG_CLIFF_EDGE macro note
				}

				push_tween_start_x = x;
				push_tween_start_y = y;
				push_tween_end_x   = x + _dx;
				push_tween_end_y   = y + _dy;
			}
		}

		if (_blocked) {
			push_resolve_failed = true;
			with (sorcery_push_target) is_grabbed = false; // glow off - push failed, nothing to slide
			return true; // ends immediately - no tween to run, push attempt failed
		}

		push_resolve_falls = _falls;
		push_fall_to_z_level = _fall_to_z_level;
		push_tween_progress = 0;
	}

	// --- Phase 1: slide onto the destination tile (shared by CLEAR and FALLS) ---
	if (push_resolve_phase == PUSH_PHASE_SLIDE) {
		push_tween_progress += PUSH_TWEEN_SPEED;
		if (push_tween_progress >= 1) {
			push_tween_progress = 1;
			with (sorcery_push_target) {
				x = other.push_tween_end_x;
				y = other.push_tween_end_y;
			}

			if (push_resolve_falls) {
				// Don't clear is_grabbed yet and don't return true -
				// the object has reached the edge tile but isn't done
				// yet, it still needs to fall. Hand off to the fall
				// phase instead of ending here.
				push_resolve_phase = PUSH_PHASE_FALL;
				push_fall_timer = 0;
				push_fall_landed = false;
				with (sorcery_push_target) {
					fall_start_y = y; // for the visual drop offset, see phase 2 below
					fall_z_level_before = z_level; // captured HERE, before z_level changes on landing - see the pillar top_z_level fix-up below
				}
			} else {
				with (sorcery_push_target) is_grabbed = false; // glow off - normal push succeeded, object has settled
				push_resolve_started = false; // reset for next time this sorcery is cast
				return true;
			}
		} else {
			with (sorcery_push_target) {
				x = lerp(other.push_tween_start_x, other.push_tween_end_x, other.push_tween_progress);
				y = lerp(other.push_tween_start_y, other.push_tween_end_y, other.push_tween_progress);
			}
			return false;
		}
	}

	// --- Phase 2: falling (only reached if push_resolve_falls) ---
	// NOTE: this is a plain `if`, not `else if` against phase 1 above -
	// intentional. If the slide completes AND hands off to
	// PUSH_PHASE_FALL within the same call (lines above), execution
	// falls through into this block on that same frame rather than
	// waiting a full frame boundary - the fall's first timer tick
	// happens immediately rather than one frame late. Harmless either
	// way; called out here so it doesn't look like an accidental
	// missing `else`.
	if (push_resolve_phase == PUSH_PHASE_FALL) {
		push_fall_timer++;

		// Simple drop - draw-time-style Y offset that grows then
		// resolves to 0, similar in spirit to jump_arc_height but
		// downward instead of up, and WITHOUT touching the object's
		// actual collision-relevant y until the drop completes (same
		// reasoning as jump: keep the fall's visual motion separate
		// from the position collision cares about, so nothing can clip
		// through geometry mid-fall). If you'd rather this be a purely
		// cosmetic sprite offset handled in the object's own Draw event
		// instead of moving y directly, expose fall_drop_offset as a
		// separate variable and read it there instead - left as a
		// straightforward y-nudge here since pushable objects don't
		// have their own Draw-event complexity yet.
		var _t = push_fall_timer / PUSH_FALL_FRAMES;
		if (_t < 1) {
			with (sorcery_push_target) {
				y = fall_start_y + (_t * TILE_SIZE * 0.5); // small visual drop, tune multiplier to taste
			}
			return false;
		}

		// Landed - snap to final position, update z_level, hold a brief
		// landing recovery beat (mirrors player's land_timer), then done.
		// push_fall_landed guards this block to a ONE-TIME update rather
		// than relying on an exact frame-count match (== is fragile if
		// this function's call cadence ever changes; a dedicated flag
		// is robust against that regardless of timing).
		if (push_fall_timer >= PUSH_FALL_FRAMES && !push_fall_landed) {
			push_fall_landed = true;
			with (sorcery_push_target) {
				y = fall_start_y;
				z_level = other.push_fall_to_z_level;

				// If the fallen object is a pillar, its TOP moved down
				// a floor along with its base - top_z_level needs to
				// shift by the same amount the base's z_level just
				// changed, not be recalculated from scratch (in case a
				// designer set an unusual top_z_level offset for a
				// specific taller/shorter variant - preserving the
				// relative offset is more robust than assuming
				// top_z_level is always exactly base + 1).
				if (id.object_index == obj_pushable_pillar
				|| object_is_ancestor(id.object_index, obj_pushable_pillar)) {
					var _height_offset = top_z_level - fall_z_level_before;
					top_z_level = z_level + _height_offset;
				}
			}
		}

		if (push_fall_timer >= PUSH_FALL_FRAMES + PUSH_FALL_LAND_FRAMES) {
			with (sorcery_push_target) is_grabbed = false; // glow off - object has landed and settled
			push_resolve_started = false;
			push_resolve_falls = false;
			return true;
		}

		return false;
	}

	return false; // unreachable, safety fallback
}
