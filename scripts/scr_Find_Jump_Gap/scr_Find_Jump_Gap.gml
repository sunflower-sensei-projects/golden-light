/// scr_Find_Jump_Gap()  [REVISED — supports pushed pillars as landing spots]
///
/// Golden Sun's gap-jump is a hard one-tile-only rule (confirmed: "Isaac
/// can only jump over gaps that are one space in width"). This is NOT
/// implemented as "measure the gap and check if it's <= some width" -
/// there is no width property or measurement anywhere in this function.
/// Instead: the landing check is hardcoded to exactly ONE_TILE distance
/// past the gap. A wider gap simply never has anything at that fixed
/// distance, so it silently fails to qualify - the "only one tile"
/// rule falls out of the check's geometry, not a comparison against a
/// stored width value.
///
/// Also folds in your confirmed rules:
///   - Obstruction blocks the jump entirely: if anything solid occupies
///     the gap tile itself, the gap is reported as not-jumpable, full
///     stop - the player does not attempt the jump.
///   - z_level filtering throughout.
///   - NEW: the landing spot can be EITHER static terrain
///     (obj_terrain_landing) OR a correctly-positioned pushed pillar
///     (obj_pushable_pillar). Landing on a pillar does NOT change the
///     player's z_level - it's purely a widened definition of "what
///     counts as solid ground at this point," evaluated against the
///     PLAYER'S CURRENT z_level, same as static landing terrain. A
///     pillar only counts if its own top_z_level (set on the pillar
///     instance - see 09_obj_pushable_pillar_notes.md) matches the
///     z_level the player is already standing at - this is what makes
///     scenario 3 work: the player pushes the pillar first (while down
///     on the lower floor), then separately climbs a vine to reach the
///     upper floor via the existing obj_level_switch mechanism, and
///     only once standing up there does the pillar (whose top now
///     matches that upper z_level) register as a valid landing target
///     for the gap up there. Nothing here changes z_level - that's
///     still exclusively obj_level_switch's job.
///
/// Returns:
///   undefined                — no valid one-tile jump this way
///   { dir, land_x, land_y }  — jump is valid

function scr_Find_Jump_Gap() {
	var _cardinal_dir = round(dir / 90) * 90;
	if (_cardinal_dir >= 360) _cardinal_dir -= 360; // 315-360 range rounds up to 360, wrap back to 0

	var _gap_x  = x + lengthdir_x(1, _cardinal_dir);
	var _gap_y  = y + lengthdir_y(1, _cardinal_dir);
	var _land_x = x + lengthdir_x(TILE_SIZE, _cardinal_dir);
	var _land_y = y + lengthdir_y(TILE_SIZE, _cardinal_dir);

	// 1. Is there actually a gap here at all?
	var _gap_inst = instance_place(_gap_x, _gap_y, TAG_GAP);
	if (_gap_inst == noone) return undefined;
	if (_gap_inst.z_level != z_level) return undefined;

	// 2. Is the gap tile itself clear? An obstruction (ice pillar, etc.)
	// sitting on the gap blocks the jump outright.
	/*
	if (instance_place(_gap_x, _gap_y, obj_collision_parent) != noone) {
		return undefined;
	}*/

	// 3. Is there solid ground exactly one tile past the gap, AT THE
	// PLAYER'S CURRENT Z_LEVEL? Checks static landing terrain first,
	// then falls back to a positioned pillar - see
	// scr_Get_Surface_Z_Level for how each type reports its z_level.
	var _land_inst = instance_place(_land_x, _land_y, TAG_LANDING);
	if (_land_inst == noone) {
		_land_inst = instance_place(_land_x, _land_y, obj_pushable_pillar);
	}
	if (_land_inst == noone) return undefined;
	if (scr_Get_Surface_Z_Level(_land_inst) != z_level) return undefined;

	return {
		dir: dir,
		land_x: _land_inst.x,
		land_y: _land_inst.y
	};
}

/// scr_Get_Surface_Z_Level(_inst)
///
/// Small shared helper so the landing check doesn't need to know or
/// care whether it found static terrain or a pillar - both just report
/// "what z_level does standing here put you at." Static
/// obj_terrain_landing instances store this as `z_level` (matching the
/// player's own variable name, per your existing terrain object
/// convention). obj_pushable_pillar stores it as `top_z_level` instead
/// (a DIFFERENT variable name, deliberately) - since a pillar's base
/// sits at one z_level but its climbable/landable TOP is a different
/// one, whereas static landing terrain has no such distinction. Keeping
/// the two variable names distinct avoids a pillar's ground-level
/// z_level ever being silently used where its top_z_level was meant,
/// which would be a nasty, hard-to-spot bug if they shared one name.
///
/// If you add more landable-when-positioned object types later
/// (per the header note), give this function one more branch rather
/// than teaching scr_Find_Jump_Gap about each new type directly.
///
/// Uses object_is_ancestor rather than a strict object_index equality
/// check, so this still works correctly if you ever add a variant
/// pillar object that's a CHILD of obj_pushable_pillar (e.g. a
/// special-behavior pillar for one specific puzzle) - a strict `==`
/// check would silently treat that variant as plain static terrain
/// and read the wrong variable (`z_level` instead of `top_z_level`),
/// which would be a quiet, confusing bug to track down later.
function scr_Get_Surface_Z_Level(_inst) {
	if (_inst.object_index == obj_pushable_pillar
	|| object_is_ancestor(_inst.object_index, obj_pushable_pillar)) {
		return _inst.top_z_level;
	}
	return _inst.z_level;
}
