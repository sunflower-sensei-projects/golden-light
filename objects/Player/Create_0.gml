/// @description Initialization

// State enum
enum pState {
	IDLE, WALK, RUN, PUSH,
	STAIR, LADDER, 
	SLOPE_SLIP, FALL, LAND,
	INTERACT,
	JUMP, SORCERY,
	SORCERY_AIM, SORCERY_RESOLVE
}

state = pState.IDLE;
prev_state = pState.IDLE;

// Movement
mov_speed = 0;
dir       = 0; // 360-degree facing direction
z_level   = 0; // Current Z-level in pseudo-3D space
px = x; // Exact floating-point X-coordinate
py = y; // Exact floating-point Y-coordinate
is_moving = false;

// --- Jump ---
// Mirrors the shape of the existing Stair block (progress + dir), since
// a jump is also a fixed-duration, animation-driven traversal across a
// known start/end point rather than free physics.
gap_hold_timer  = 0;      // frames the player has held a direction facing a valid gap (see GAP_HOLD_FRAMES)
gap_hold_dir    = -1;     // which dir the hold-timer is currently counting for; -1 = not holding toward any gap
jump_progress   = 0;      // 0-1, how far through the current jump arc
jump_dir        = 0;      // raw 360-degree `dir` at jump start (NOT the 8-way anim_dir bucket - see note in scr_Player_State_Machine's JUMP entry hook)
jump_start_x    = 0;
jump_start_y    = 0;
jump_end_x      = 0;
jump_end_y      = 0;
jump_arc_height = 12;     // Peak pixel height of the arc, purely visual (draw-time y offset)
jump_speed      = JUMP_SPEED; // progress gained per frame, e.g. 1/20 for a 20-frame hop

// Slopes
fall_vel        = 0; // Downward velocity while falling
fall_x_vel      = 0; // Horizontal carry-over from movement before the fall
land_timer      = 0; // Countdown for landing recovery
slip_timer      = 0; // Countdown for wobble before slipping
fall_from_slope = false; // Flag for when the player lands

// Interaction
interact_target = noone;
interact_locked = false;

// Push
push_target = noone;
push_dir = 0; // 0 = Not pushing, 1 = Right/Left, 2 = Up/Down

// --- Field Sorcery cast (overworld) ---
// Mirrors the shape of the existing Interact/Push blocks. This does NOT
// handle sorcery *selection* (that's the field-cast menu, not yet
// uploaded) - by the time the player enters pState.SORCERY, the tag and
// caster are already decided and this is purely "play the cast, resolve
// the effect, return control."
sorcery_tag       = "";     // effect tag string, e.g. "push_object", "quake_topple"
sorcery_caster    = noone;  // party member struct actually casting (for VP cost, sprite, etc.)
sorcery_target    = noone;  // instance the sorcery is aimed at, or noone for an untargeted cast
sorcery_lock_end  = -1;     // frame (via anim_lock_end-style countdown) when the cast animation finishes
sorcery_resolved  = false;  // guards against the effect firing more than once during the locked animation

// --- Field Push (Move psynergy) specific ---
// Push is the one field sorcery that isn't a single-frame effect - see
// pState.SORCERY_AIM / pState.SORCERY_RESOLVE in scr_Player_State_Machine
// and 10_scr_field_push.gml for the full three-phase flow.
sorcery_push_target  = noone; // the grabbed object, valid during AIM and RESOLVE
sorcery_push_dir     = -1;    // chosen push direction (0/90/180/270), set when AIM completes
push_resolve_started = false; // guards the one-time destination check at the start of RESOLVE
push_resolve_failed  = false; // true if the last push attempt was blocked (for feedback/SFX - not currently read elsewhere, safe to check in Draw/Step if you want a "clank" sound on failure)
push_resolve_phase   = PUSH_PHASE_SLIDE; // PUSH_PHASE_SLIDE or PUSH_PHASE_FALL - see 10_scr_field_push.gml
push_resolve_falls   = false; // true if the destination tile is a TAG_CLIFF_EDGE - object slides on, then falls
push_fall_to_z_level = 0;     // the z_level the object will land at, read from the TAG_CLIFF_EDGE marker
push_fall_timer      = 0;     // frames into the fall/land sequence (see PUSH_FALL_FRAMES / PUSH_FALL_LAND_FRAMES)
push_fall_landed     = false; // guards the one-time landing update (z_level snap + pillar top_z_level fix-up) to fire exactly once
push_tween_start_x   = 0;
push_tween_start_y   = 0;
push_tween_end_x     = 0;
push_tween_end_y     = 0;
push_tween_progress  = 0;     // 0-1, how far through the slide tween

// --- Climbing
climb_target_x = 0; // The climbable object's own x-position, player locks to this

// Diagonal stair system
z_height = 0;

// Fall origin tracking
fall_from_stair = false;
fall_steerable = false;

// Animations
anim_dir = 0; // 0 = down, 1 = down-right, 2 = right, 3 = up-right, etc.
anim_locked = false; // When true, current animation plays to the end before state change
anim_lock_end = -1;  // The frame on which the lock is released
active_sprites = undefined;
scr_Player_Refresh_Sprites();

doOnce = false;