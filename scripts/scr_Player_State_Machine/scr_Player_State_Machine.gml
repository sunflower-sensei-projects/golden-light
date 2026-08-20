/// scr_Player_State_Machine (UPDATED)
///
/// Changes from your original, all additive:
///   1. IDLE/WALK/RUN gains a Jump check - REVISED per your Golden Sun
///      clarification: jump is NOT a button-triggered ability. It's
///      baseline movement, matching Golden Sun exactly:
///        - Player holds a direction that's facing a one-tile gap
///          (works during both WALK and RUN)
///        - After a short hold threshold (GAP_HOLD_FRAMES), the jump
///          triggers automatically - no separate button
///        - Width is never tracked as a property. The landing check is
///          hardcoded to exactly one tile of distance, so a 2-tile gap
///          simply never finds a landing spot there and never becomes
///          jumpable - no width math, no per-object flag
///        - If anything solid occupies the gap tile (an ice pillar,
///          etc.), scr_Find_Jump_Gap's own instance_place obstruction
///          check fails and the gap is just reported as impassable -
///          player never attempts the jump, per your answer
///        - z_level-filtered throughout, per your answer
///   2. New pState.JUMP case - runs the arc, returns to IDLE on land.
///   3. New pState.SORCERY case - plays the cast lock, resolves the
///      effect exactly once via scr_field_sorcery_dispatch, returns to
///      IDLE. Entering this state is NOT handled here - that's the job
///      of whatever calls scr_Player_Start_Field_Sorcery(...) from the
///      field-cast menu once it exists.
///   4. scr_Player_On_Enter_State gains JUMP and SORCERY entry hooks.

function scr_Player_State_Machine(){
	var _new_state = state;
	
	switch (state) {
		
		// -- IDLE / WALK / RUN --------------------------------------------
		case pState.IDLE:
		case pState.WALK:
		case pState.RUN:
			// Interaction check
			if (input_interact) {
				interact_target = scr_Find_Interact_Target();
				if (interact_target != noone) {
					_new_state = pState.INTERACT;
					break;
				}
			}
			
			// Slope check
			if (scr_Check_Terrain(TAG_SLOPE)) {
				slip_timer = SLOPE_SLIP_DELAY;
				fall_from_slope = true;
				_new_state = pState.SLOPE_SLIP;
				break;
			}
			
			// Push check
			if (input_any) {
				push_target = scr_Find_Pushover();
				if (push_target != noone) {
					_new_state = pState.PUSH;
					break;
				}
			}
			
			// Jump check
			if (input_any) {
				var _gap = scr_Find_Jump_Gap();
				// TEMP DEBUG - remove after diagnosing the repeat-jump-
				// while-holding-run bug
				show_debug_message("JUMP CHECK - state: " + string(state) + " | prev_state: " + string(prev_state) + " | gap found: " + string(!is_undefined(_gap)) + " | gap_hold_dir: " + string(gap_hold_dir) + " | gap_hold_timer: " + string(gap_hold_timer) + " | anim_locked: " + string(anim_locked));
				if (!is_undefined(_gap)) {
					if (gap_hold_dir != _gap.dir) {
						gap_hold_dir = _gap.dir;
						gap_hold_timer = 0;
					}
					gap_hold_timer++;
					
					if (gap_hold_timer >= GAP_HOLD_FRAMES) {
						jump_dir      = _gap.dir;
						jump_start_x  = x;
						jump_start_y  = y;
						jump_end_x    = _gap.land_x;
						jump_end_y    = _gap.land_y;
						jump_progress = 0;
						gap_hold_timer = 0;
						gap_hold_dir   = -1;
						_new_state = pState.JUMP;
						break; // the ONLY branch that should short-circuit the rest of the switch
					}
				} else {
					gap_hold_timer = 0;
					gap_hold_dir = -1;
					// no break - fall through to the terrain-check block below,
					// which will correctly set WALK/RUN based on input_run
				}
			} else {
				// Not holding a direction - reset so a released-then-
				// re-pressed input always needs the full hold again,
				// matching Golden Sun rather than letting a tap-tap-tap
				// cheese the timer via partial holds.
				gap_hold_timer = 0;
				gap_hold_dir = -1;
				// no break - fall through; the terrain-check block's own
				// `!input_any` check below will correctly set IDLE
			}
			
			// Terrain checks
			var _on_stair = scr_Check_Terrain(TAG_STAIR_UP) || scr_Check_Terrain(TAG_STAIR_DN);
			var _on_climbable = scr_Check_Terrain(TAG_CLIMBABLE);
			var _on_slope = scr_Check_Terrain(TAG_SLOPE);
			
			if (_on_climbable && (input_y != 0)) {
				climb_target_x = scr_Climb_Get_Target_X();
				_new_state = pState.LADDER;
			} else if (_on_stair && input_any) {
				_new_state = pState.STAIR;
				stair_progress = 0;
				stair_dir = scr_Check_Terrain(TAG_STAIR_UP) ? 1 : -1;
			} else if (!input_any) {
				_new_state = pState.IDLE;
			} else if (input_run) {
				_new_state = pState.RUN;
			} else {
				_new_state = pState.WALK;	
			}
			break;
			
		// -- STAIRS --------------------------------------------------------------------------
		case pState.STAIR:
			if (!scr_Check_Terrain(TAG_STAIR_UP) && !scr_Check_Terrain(TAG_STAIR_DN)) {
				_new_state = input_any ? pState.WALK : pState.IDLE;
				break;
			}
			if (!input_any) {
				_new_state = pState.IDLE;
				break;
			}
			
			var _stair_dx = input_x * mov_speed;
			var _stair_dy = input_y * mov_speed;
			if (!place_meeting(x + _stair_dx, y, obj_collision_parent)) x += _stair_dx;
			if (!place_meeting(x, y + _stair_dy, obj_collision_parent)) y += _stair_dy;
			px = x;
			py = y;
			
			stair_progress += mov_speed / stair_step_h;
			if (stair_progress >= 1) {
				stair_progress -= 1;
				y -= stair_dir * stair_step_h;
				py = y;
			}
			break;
		
		// -- LADDER (also serves vines and climbable walls - one shared mechanic) -------------
		case pState.LADDER:
			if (!scr_Check_Terrain(TAG_CLIMBABLE)) {
				_new_state = input_any ? pState.WALK : pState.IDLE;
				break;
			}
			if (input_y == 0) {
				_new_state = pState.IDLE;
				break;
			}

			x = climb_target_x;
			px = x;
			
			var _climb_dy = sign(input_y) * CLIMB_SPEED;
			if (!place_meeting(x, y + _climb_dy, obj_collision_parent)) {
				y += _climb_dy;
				py = y;
			}
			break;
		
		// -- SLOPE SLIP ----------------------------------------------------------------------
		case pState.SLOPE_SLIP:
			slip_timer--;
			if (slip_timer <= 0) {
				// Carry over some horizontal momemntum
				fall_x_vel = input_x * mov_speed * 0.5;
				fall_vel = 0;
				_new_state = pState.FALL;
			}
			
			// If the player also somehow walks off the slope through the wobble, also fall
			if (!scr_Check_Terrain(TAG_SLOPE)) {
				fall_x_vel = input_x * mov_speed * 0.5;
				fall_vel = 0;
				_new_state = pState.FALL;
			}
			
			break;
		
		// -- FALL ----------------------------------------------------------------------------
		case pState.FALL:
			if (fall_steerable) {
				fall_x_vel += input_x * FALL_STEER_STRENGTH;
				fall_x_vel = clamp(fall_x_vel, -FALL_STEER_MAX_VEL, FALL_STEER_MAX_VEL);
			}
			
			// Landing check
			if (scr_Check_Landing()) {
				land_timer = FALL_LAND_FRAMES;
				_new_state = pState.LAND;
			}
			
			break;
		
		// -- LAND ----------------------------------------------------------------------------
		case pState.LAND:
			land_timer--;
			if (land_timer <= 0) {
				fall_from_slope = false;
				fall_from_stair = false;
				fall_steerable = false;
				fall_vel = 0;
				fall_x_vel = 0;
				_new_state = pState.IDLE;
			}
			
			break;
		
		// -- PUSH ----------------------------------------------------------------------------
		case pState.PUSH:
			if (!instance_exists(push_target) || !scr_Is_Pushing(push_target)) {
				push_target = noone;
				push_axis = 0;
				_new_state = pState.IDLE;
			}
			break;
		
		// -- JUMP ----------------------------------------------------------------------------
		case pState.JUMP:
			// Animation-locked: movement input is ignored entirely for the
			// duration, same spirit as anim_locked elsewhere. Progress is
			// driven by frames, not input, so the arc always completes.
			//
			// BUGFIX: x/y must be interpolated toward the landing point
			// EVERY frame here - this was previously missing entirely
			// (only the final snap-to-landing existed), which meant the
			// player never actually traveled across the gap: it sat at
			// jump_start_x/y the whole time (only the Draw event's
			// vertical arc offset was visible - "hopping in place"),
			// then teleported to jump_end_x/y the instant jump_progress
			// hit 1. Same lerp pattern already used for the Push tween
			// in scr_Player_Resolve_Push.
			jump_progress += jump_speed;
			
			if (jump_progress >= 1) {
				jump_progress = 1;
				x = jump_end_x;
				y = jump_end_y;
				px = x;
				py = y;
				_new_state = pState.IDLE;
				// TEMP DEBUG - remove after diagnosing the repeat-jump-
				// while-holding-run bug
				show_debug_message("JUMP COMPLETE - gap_hold_timer: " + string(gap_hold_timer) + " | gap_hold_dir: " + string(gap_hold_dir) + " | anim_locked: " + string(anim_locked) + " | input_run: " + string(input_run) + " | input_any: " + string(input_any) + " | input_x: " + string(input_x) + " | input_y: " + string(input_y));
			} else {
				x = lerp(jump_start_x, jump_end_x, jump_progress);
				y = lerp(jump_start_y, jump_end_y, jump_progress);
				px = x;
				py = y;
			}
			break;
		
		// -- SORCERY (field cast) --------------------------------------------------------------
		case pState.SORCERY:
			// Purely a timing gate around the actual effect. The effect
			// itself resolves once, partway through the lock, via
			// scr_field_sorcery_dispatch's return value rather than
			// having the dispatched effect mutate `state` directly -
			// this matters because most sorceries (Quake/Stone/Ignite)
			// really are one-shot and should fall through to IDLE at
			// lock-end like before, but Push is NOT one-shot: its
			// "apply" needs to hand off into pState.SORCERY_AIM
			// instead. Since this switch is already executing against
			// the state value captured at the top of
			// scr_Player_State_Machine, a direct `state = ...` write
			// from inside the dispatched function would get silently
			// overwritten by this case's own `_new_state = pState.IDLE`
			// a few lines below - so dispatch instead RETURNS the state
			// it wants to transition to (or noone to mean "no override,
			// use normal lock-end behavior"), and this case respects
			// that return value as the authority.
			if (!sorcery_resolved && (sorcery_lock_end - anim_lock_frame_counter) >= sorcery_resolve_offset) {
				var _requested_state = scr_field_sorcery_dispatch(sorcery_tag, sorcery_caster, sorcery_target);
				sorcery_resolved = true;
				
				if (_requested_state != noone) {
					_new_state = _requested_state;
					break;
				}
			}
			
			anim_lock_frame_counter++;
			if (anim_lock_frame_counter >= sorcery_lock_end) {
				sorcery_tag = "";
				sorcery_caster = noone;
				sorcery_target = noone;
				sorcery_resolved = false;
				_new_state = pState.IDLE;
			}
			break;
		
		// -- SORCERY_AIM (field Push: waiting for a push direction) ----------------------------
		case pState.SORCERY_AIM:
			// Fully locked (per your answer) except for direction input
			// and the cancel button. Indefinite duration - no timer,
			// just waits.
			if (input_interact) {
				// Cancel: release the grab, no push attempted, return
				// control immediately.
				if (instance_exists(sorcery_push_target)) {
					with (sorcery_push_target) is_grabbed = false;
				}
				sorcery_push_target = noone;
				_new_state = pState.IDLE;
				break;
			}
			
			var _push_dir = scr_Get_Cardinal_Input_Dir(); // returns 0/90/180/270 or -1 if no direction held - see 10_scr_field_push.gml
			if (_push_dir != -1) {
				sorcery_push_dir = _push_dir;
				_new_state = pState.SORCERY_RESOLVE;
			}
			break;
		
		// -- SORCERY_RESOLVE (field Push: tweening the object, or failing) ---------------------
		case pState.SORCERY_RESOLVE:
			// scr_Player_Resolve_Push handles both the collision check
			// AND the tween itself (see 10_scr_field_push.gml) -
			// called every frame of the resolve window so the tween can
			// progress; returns true once the push is fully done
			// (whether it succeeded or failed at the collision check -
			// either way, this state's job is over).
			if (scr_Player_Resolve_Push()) {
				sorcery_push_target = noone;
				sorcery_push_dir = -1;
				_new_state = pState.IDLE;
			}
			break;
		
		// -- INTERACT ------------------------------------------------------------------------
		case pState.INTERACT:
			// Interaction unlocks when the dialogue/event system sets this flag
			if (!interact_locked) {
				interact_target = noone;
				_new_state = pState.IDLE;
			}
			break;
	}
	
	// State change hook
	if (_new_state != state) {
		prev_state = state;
		state = _new_state;
		scr_Player_On_Enter_State();
	}
}

function scr_Player_On_Enter_State() {
	switch(state) {
		case pState.INTERACT:
			// Fire interaction event on target, lock player movement
			interact_locked = true;
			if (instance_exists(interact_target))
				with (interact_target) event_user(0); // targets use event_user(0) for interact
			break;
		case pState.SLOPE_SLIP:
			slip_timer = SLOPE_SLIP_DELAY;
			fall_from_slope = true;
			break;
		case pState.FALL:
			fall_vel = 0;
			fall_x_vel = input_x * mov_speed * 0.5;
			break;
		case pState.LAND:
			land_timer = FALL_LAND_FRAMES;
			break;
		case pState.STAIR:
			stair_progress = 0;
			break;
		case pState.JUMP:
			anim_locked = true;
			// jump_dir is the raw 360-degree `dir` captured at jump start
			// (see scr_Find_Jump_Gap), NOT the 8-way anim_dir bucket your
			// sprites use. If scr_Player_Animate already has a dir ->
			// anim_dir converter, call it here, e.g.:
			//   anim_dir = scr_Dir_To_Anim_Dir(jump_dir);
			// Left as a placeholder pass-through until that converter's
			// name is confirmed - see note in 04_scr_Find_Jump_Gap.gml.
			anim_dir = jump_dir;
			break;
		case pState.SORCERY:
			anim_locked = true;
			anim_lock_frame_counter = 0;
			sorcery_lock_end = sorcery_cast_frames; // set by scr_Player_Start_Field_Sorcery before the state change
			sorcery_resolved = false;
			break;
		case pState.SORCERY_AIM:
			// Fully locked (movement + normal actions), per your answer -
			// only the direction check and cancel button are read while
			// in this state, both handled directly in
			// scr_Player_State_Machine's SORCERY_AIM case rather than
			// through the usual input_any/input_interact movement path.
			anim_locked = true;
			// Trigger the grabbed-object glow (shd_push_grab) - see
			// 11_shd_push_grab_notes.md for the shader itself and the
			// obj_pushable-side Draw event that actually renders it.
			// is_grabbed lives on obj_pushable (inherited by
			// obj_pushable_pillar), reset back to false on both exits
			// from the grab (cancel below, and in
			// scr_Player_Resolve_Push once the push finishes).
			if (instance_exists(sorcery_push_target)) {
				with (sorcery_push_target) {
					is_grabbed = true;
					grab_glow_time = 0;
				}
			}
			break;
		case pState.SORCERY_RESOLVE:
			anim_locked = true;
			push_resolve_started = false;
			push_resolve_failed = false;
			push_tween_progress = 0;
			break;
	}
	
	// JUMP, SORCERY, SORCERY_AIM, and SORCERY_RESOLVE all hold
	// anim_locked for their entire duration (not just a tail-end lock
	// like a normal attack windup), so it's released here rather than
	// via anim_lock_end/frame comparisons used elsewhere for regular
	// animations.
	//
	// IMPORTANT: this checks the NEW `state`, not `prev_state`. Field
	// Push chains through THREE of these locked states in sequence
	// (SORCERY -> SORCERY_AIM -> SORCERY_RESOLVE) before finally
	// landing on IDLE. If this checked prev_state instead, every
	// transition BETWEEN two locked states (e.g. SORCERY entering
	// SORCERY_AIM) would see prev_state also in the locked list and
	// incorrectly clear anim_locked the same frame the switch above
	// just set it - releasing player input control one full phase too
	// early. Checking the new `state` instead means the lock only
	// releases on the actual final transition into a state OUTSIDE
	// this list (normally IDLE).
	var _is_locked_state = (state == pState.JUMP)
	                     || (state == pState.SORCERY)
	                     || (state == pState.SORCERY_AIM)
	                     || (state == pState.SORCERY_RESOLVE);
	if (!_is_locked_state) {
		anim_locked = false;
	}
}