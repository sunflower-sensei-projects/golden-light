/// Target resolution.
///
/// Sorceries/items carry a `target` string (Ally, Enemy, Self,
/// AllAllies, AllEnemies, Any). This turns that string into either:
///   (a) a resolved array of targets immediately (Self, AllAllies), or
///   (b) a signal that the menu needs to ask "Who?" first (Ally, Enemy,
///       Any as single-target values)
///
/// Field (out-of-battle) use only ever has allies to pick from - there
/// is no enemy party outside battle. So in the field, "Enemy" and "Any"
/// both collapse to "pick one ally" for now; battle code will pass its
/// own enemy list in via _context when this same resolver is reused there.

/// scr_target_needs_picker(_target_type, _zone)
/// True if the menu must prompt for a specific target before dispatch;
/// false if the target list can be resolved automatically.
function scr_target_needs_picker(_target_type, _zone) {
	switch (_target_type) {
		case "Self":
		case "AllAllies":
			return false;
		case "AllEnemies":
			// Field zone never has an enemy party to auto-target - this
			// combination shouldn't occur if use_zone is set correctly,
			// but resolve to "no targets" rather than crash if it does.
			return (_zone == "battle");
		case "Ally":
		case "Enemy":
		case "Any":
			return true;
	}
	return true; // unknown target type - be safe, ask rather than guess
}

/// scr_resolve_targets_auto(_caster, _mgr, _target_type, _zone, _battle_context)
/// Resolves the targets that DON'T need an interactive picker. Returns
/// an array (possibly empty). Call scr_target_needs_picker first to
/// know whether you should be calling this or opening a picker instead.
function scr_resolve_targets_auto(_caster, _mgr, _target_type, _zone, _battle_context) {
	switch (_target_type) {
		case "Self":
			return [_caster];
		case "AllAllies":
			return array_flat_copy(_mgr._Party);
		case "AllEnemies":
			if (_zone == "battle" && !is_undefined(_battle_context) && variable_struct_exists(_battle_context, "enemies")) {
				return array_flat_copy(_battle_context.enemies);
			}
			return [];
	}
	return [];
}

/// array_flat_copy(_arr)
/// Shallow copy helper - targets get passed around and we don't want
/// effect functions accidentally holding a live reference to the
/// party array itself.
function array_flat_copy(_arr) {
	var _out = [];
	for (var _i = 0; _i < array_length(_arr); _i++) {
		array_push(_out, _arr[_i]);
	}
	return _out;
}
