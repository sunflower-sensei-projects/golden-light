/// scr_Find_Facing_Object(_obj_type, _range)
///
/// General-purpose "what am I facing" lookup for field sorceries,
/// modeled directly on your existing scr_Find_Interact_Target:
///
///   function scr_Find_Interact_Target() {
///       var _range = 24;
///       var _front_x = x + lengthdir_x(_range, dir);
///       var _front_y = y + lengthdir_y(_range, dir);
///       return instance_nearest(_front_x, _front_y, obj_interactable);
///   }
///
/// Same shape, just parameterized on object type and range so Quake/
/// Stone/Ignite/(future sorceries) don't each need their own
/// hand-copied version. Belongs in scr_terrain_helpers.md alongside
/// scr_Find_Interact_Target/scr_Find_Pushover, not in the field sorcery
/// registry file - it's a general lookup utility, not sorcery-specific
/// logic. Moving it there also means scr_Find_Interact_Target itself
/// could eventually be rewritten as a 1-line call to this
/// (scr_Find_Facing_Object(obj_interactable, 24)) if you want to
/// de-duplicate later - not changing that script now since it works
/// and isn't part of this task.
///
/// Returns an instance or noone, exactly like instance_nearest does on
/// its own when nothing's found within the room (instance_nearest
/// doesn't respect range by itself - see note below).

function scr_Find_Facing_Object(_obj_type, _range) {
	var _front_x = x + lengthdir_x(_range, dir);
	var _front_y = y + lengthdir_y(_range, dir);
	var _inst = instance_nearest(_front_x, _front_y, _obj_type);

	if (_inst == noone) return noone;

	// NOTE: instance_nearest finds the closest instance of _obj_type
	// ANYWHERE in the room relative to (_front_x, _front_y) - it does
	// NOT clip to _range. Your original scr_Find_Interact_Target has
	// this same characteristic (the comment there even flags it:
	// "Maybe tighten this with a distance check"). For interact targets
	// at 24px this rarely matters since interactables are usually
	// sparse and close, but Stone's 200px range makes a false-positive
	// far more likely (e.g. finding a stoneable switch on the other
	// side of the room with nothing actually in front of the player).
	// Adding the distance clamp here rather than leaving it as an open
	// question a second time:
	if (point_distance(x, y, _inst.x, _inst.y) > _range) {
		return noone;
	}

	return _inst;
}
