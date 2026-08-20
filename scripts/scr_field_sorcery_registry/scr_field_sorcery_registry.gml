/// Field sorcery registry + dispatcher.
///
/// Deliberately parallels scr_effect_registry.gml's shape: a global
/// lookup table keyed by tag string, one shared dispatch function, and
/// small standalone handler functions. Kept SEPARATE from
/// global.effects/scr_effect_dispatch rather than merged into it,
/// because field sorceries and battle/item effects answer different
/// questions:
///   - Battle/item effects (scr_effect_dispatch) always resolve
///     immediately against a known target list and answer "what
///     stat/HP/status change happens."
///   - Field sorceries answer "is there something in front of the
///     player this tool can affect, and if so, what happens to THAT
///     OBJECT" - the target is usually an instance in the room (a
///     boulder, a switch, a wall), not a character struct, and half
///     the job is the can-I-use-this-here check before anything fires.
/// If a sorcery is genuinely identical in the field and in battle
/// (e.g. a heal spell also usable as a field heal), its field handler
/// can just call scr_effect_dispatch internally against a single-
/// element target array (e.g. [caster]) rather than duplicating the
/// heal logic here - none of the four examples below need this, but
/// it's the pattern to reach for once you add a field-usable heal/
/// status sorcery.
///
/// Call scr_field_sorcery_registry_init() once at game start, same
/// place as scr_effect_registry_init(). Call
/// scr_Player_Start_Field_Sorcery(_tag, _caster) from the field-cast
/// menu once it exists - that's the actual entry point; everything
/// else here is support for it.

function scr_field_sorcery_registry_init() {
	global.field_sorceries = {};

	// Each entry: { can_use: function(_caster), apply: function(_caster, _target) }
	// can_use does the "is there a valid thing to affect" check AND
	// returns the target it found (or noone), so scr_Player_Start_Field_Sorcery
	// doesn't have to re-derive it - one lookup, not two.

	global.field_sorceries[$ "push_object"]   = { can_use: fs_can_push,   apply: fs_apply_push };
	global.field_sorceries[$ "quake_topple"]  = { can_use: fs_can_quake,  apply: fs_apply_quake };
	global.field_sorceries[$ "stone_trigger"] = { can_use: fs_can_stone,  apply: fs_apply_stone };
	global.field_sorceries[$ "ignite_burn"]   = { can_use: fs_can_ignite, apply: fs_apply_ignite };

	// Add one line per new field sorcery here, plus its can_use/apply
	// pair below. Never touch existing lines to add a new one - same
	// rule as the battle effect registry.
}

/// scr_field_sorcery_can_use(_tag, _caster)
/// Read-only check - does NOT mutate anything. Used by the field-cast
/// menu to gray out sorceries that have nothing to affect right now,
/// and internally by scr_Player_Start_Field_Sorcery to find the target.
/// Returns the target instance (or noone) rather than a bare bool, so
/// a single call serves both "can I?" and "affect what?".
function scr_field_sorcery_can_use(_tag, _caster) {
	if (!variable_struct_exists(global.field_sorceries, _tag)) {
		show_debug_message("scr_field_sorcery_can_use: unknown field sorcery tag '" + string(_tag) + "'");
		return noone;
	}
	var _entry = global.field_sorceries[$ _tag];
	return _entry.can_use(_caster);
}

/// scr_field_sorcery_dispatch(_tag, _caster, _target)
/// Actually applies the effect. Called once, from pState.SORCERY partway
/// through the cast lock (see scr_Player_State_Machine) - never call
/// this directly from the menu, go through
/// scr_Player_Start_Field_Sorcery so the cast animation always plays.
///
/// Returns whatever the handler's `apply` function returns:
///   - `noone` for a normal one-shot sorcery (Quake/Stone/Ignite) -
///     tells scr_Player_State_Machine "no state override, just fall
///     through to lock-end -> IDLE like usual."
///   - a pState value (e.g. pState.SORCERY_AIM) for a multi-phase
///     sorcery like Push, which needs to hand off into a different
///     state instead of ending immediately. See the SORCERY case's
///     header comment in scr_Player_State_Machine for why this has to
///     be a return value rather than `apply` writing to `state`
///     directly.
function scr_field_sorcery_dispatch(_tag, _caster, _target) {
	if (!variable_struct_exists(global.field_sorceries, _tag)) {
		show_debug_message("scr_field_sorcery_dispatch: unknown field sorcery tag '" + string(_tag) + "'");
		return noone;
	}
	var _entry = global.field_sorceries[$ _tag];
	return _entry.apply(_caster, _target);
}

/// scr_Player_Start_Field_Sorcery(_tag, _caster)
///
/// THE entry point for the field-cast menu to call once it exists.
/// Confirms a valid target exists, sets up the player's sorcery_* state
/// (mirrors scr_Player_Start_Push/however the existing Push trigger
/// stages its own target before entering pState.PUSH), then hands off
/// to the state machine. Returns true/false so the menu can show a
/// "nothing happens" message on failure without changing player state.
function scr_Player_Start_Field_Sorcery(_tag, _caster) {
	// fs_can_push/fs_can_quake/etc. each already wrap their body in
	// with (Player) { ... } internally to reach x/y/dir - see the
	// handlers below - so this can call scr_field_sorcery_can_use
	// directly from whatever context the menu is in (no with-block
	// needed here); the finder functions handle jumping into Player's
	// context themselves.
	var _target = scr_field_sorcery_can_use(_tag, _caster);
	if (_target == noone) {
		return false;
	}

	with (Player) {
		sorcery_tag    = _tag;
		sorcery_caster = _caster;
		sorcery_target = _target;
		sorcery_cast_frames    = SORCERY_CAST_FRAMES;   // total lock duration, macro - tune per-sorcery later if needed
		sorcery_resolve_offset = SORCERY_RESOLVE_OFFSET; // frames before lock-end that the effect actually fires
		state = pState.SORCERY;
		scr_Player_On_Enter_State();
	}
	return true;
}

// ---------------------------------------------------------------------
// Field sorcery handlers.
//
// REVISED to match your real scr_terrain_helpers.md:
//   - scr_Find_Pushover() checks a FIXED 8px lookahead based on
//     input_x/input_y (i.e. it only finds a pushover while the player
//     is actively walking into one) and looks for obj_pushable
//     specifically via instance_place.
//   - scr_Find_Interact_Target() instead projects lengthdir_x/y(_range, dir)
//     off the player's facing angle and uses instance_nearest against
//     obj_interactable - a facing-based lookahead independent of
//     current input, which is the better template for sorcery casts
//     (you should be able to stand still, face a target, and cast -
//     not have to be actively walking into it, since that's specific
//     to the walk-into-it Push trigger, not how a deliberate spell
//     cast should feel).
//
// So: fs_can_push below reuses scr_Find_Pushover as-is (field-cast
// Push targets the same walk-in-range check as body-push - it's the
// SAME sorcery, just also invocable through the menu rather than only
// by bumping into something). The other three (Quake/Stone/Ignite)
// use a NEW shared helper, scr_Find_Facing_Object(_obj_type, _range),
// modeled directly on scr_Find_Interact_Target's lengthdir + instance_nearest
// pattern, since there's no reason to invent a different lookup shape
// when a working one-object-type-parameterized version of yours
// already exists in spirit.
// ---------------------------------------------------------------------

function fs_can_push(_caster) {
	// REVISED - real Golden Sun Move targeting, not the walk-in-range
	// scr_Find_Pushover check anymore. Confirmed from research: Move
	// has a range of two tiles (one tile of space allowed between
	// caster and target), requires a direct line between them, and the
	// target must be at the same elevation (z_level) as the caster.
	// This is now its own facing-based lookup rather than reusing
	// scr_Find_Facing_Object, because it needs to try TWO distances (1
	// tile and 2 tiles away) rather than one fixed range, and needs the
	// z_level check scr_Find_Facing_Object doesn't currently do.
	with (Player) {
		return scr_Find_Push_Target();
	}
}

function fs_apply_push(_caster, _target) {
	// REVISED - Field Push is no longer a single-frame effect. It's a
	// three-phase interaction (grab -> aim -> resolve), so "apply"
	// itself doesn't move anything - it stages the grabbed target and
	// returns pState.SORCERY_AIM to tell scr_Player_State_Machine's
	// SORCERY case to hand off there instead of falling through to
	// IDLE at lock-end. The actual movement happens later, once the
	// player picks a direction (see pState.SORCERY_AIM /
	// scr_Player_Resolve_Push in 10_scr_field_push.gml).
	with (Player) {
		sorcery_push_target = _target;
	}
	return pState.SORCERY_AIM;
}

function fs_can_quake(_caster) {
	with (Player) {
		return scr_Find_Facing_Object(obj_quakeable, 24);
	}
}

function fs_apply_quake(_caster, _target) {
	with (_target) {
		event_user(1); // convention: event_user(1) = "quake" reaction on the target object
	}
	return noone; // one-shot effect, no state override - normal lock-end -> IDLE applies
}

function fs_can_stone(_caster) {
	// Stone is meant to be RANGED (line-of-sight to a distant
	// switch/target per the design doc), so it gets a longer lookahead
	// than Quake/Ignite's close-range checks - same
	// scr_Find_Facing_Object helper, just a bigger _range. This is a
	// straight-line check only (matches instance_nearest's behavior),
	// not a true raycast that stops at the first wall in the way - if
	// you want Stone blocked by intervening obj_collision_parent
	// instances, that's a small addition to scr_Find_Facing_Object
	// (a collision_line_exists check between the player and the found
	// target) once you confirm you want that.
	with (Player) {
		return scr_Find_Facing_Object(obj_stoneable, 200);
	}
}

function fs_apply_stone(_caster, _target) {
	with (_target) {
		event_user(2); // convention: event_user(2) = "stone hit" reaction
	}
	return noone;
}

function fs_can_ignite(_caster) {
	with (Player) {
		return scr_Find_Facing_Object(obj_ignitable, 24);
	}
}

function fs_apply_ignite(_caster, _target) {
	with (_target) {
		event_user(3); // convention: event_user(3) = "ignite" reaction
	}
	return noone;
}
