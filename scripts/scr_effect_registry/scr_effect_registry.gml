/// Effect registry + dispatcher.
///
/// One shared system for "what actually happens" when a sorcery is
/// cast, an item is used, or (later) a Faefolk skill triggers. All
/// three carry an `effect` tag string on their data (e.g. "heal_flat")
/// naming a *behavior*, not a specific number - the magnitude comes
/// from the source's own `power`/`vp_cost`/etc fields via `context`,
/// so "heal 30" and "heal 70" are the same function with a different
/// context.power, not two different tags.
///
/// Effect function signature (always the same, regardless of source):
///   effect_fn(_caster, _targets, _context)
///     _caster  - the character struct performing the action
///     _targets - array of character (or enemy) structs being affected
///     _context - struct with at minimum:
///                  { zone: "field" | "battle", power: number,
///                    source: the sorcery/item/fae struct itself }
///
/// Call scr_effect_registry_init() once at game start (same place you'd
/// init global.char_invs etc). Call scr_effect_dispatch(...) any time
/// something needs to actually happen.

function scr_effect_registry_init() {
	global.effects = {};

	global.effects[$ "heal_flat"]      = effect_heal_flat;
	global.effects[$ "heal_percent"]   = effect_heal_percent;
	global.effects[$ "damage_flat"]    = effect_damage_flat;
	global.effects[$ "restore_vp"]     = effect_restore_vp;
	global.effects[$ "cure_status"]    = effect_cure_status;
	global.effects[$ "revive"]         = effect_revive;

	// Add one line per new effect here. Never touch existing lines or
	// existing effect functions to add a new one.
}

/// scr_effect_dispatch(_tag, _caster, _targets, _context)
/// Looks up and calls the effect function for _tag. Returns true if an
/// effect ran, false if the tag wasn't found (logged, not crashed -
/// a missing effect tag shouldn't hard-crash the menu).
function scr_effect_dispatch(_tag, _caster, _targets, _context) {
	if (!variable_struct_exists(global.effects, _tag)) {
		show_debug_message("scr_effect_dispatch: unknown effect tag '" + string(_tag) + "'");
		return false;
	}
	var _fn = global.effects[$ _tag];
	_fn(_caster, _targets, _context);
	return true;
}

// ---------------------------------------------------------------------
// Effect functions. Each one is intentionally small and zone-agnostic
// where possible - "heal" is "heal" whether it came from a spell, a
// potion, or (eventually) a Faefolk skill. Zone is only checked where
// presentation genuinely differs (see effect_heal_flat below).
// ---------------------------------------------------------------------

function effect_heal_flat(_caster, _targets, _context) {
	var _amount = _context.power;
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		_t.char_hp_current = min(_t.char_hp_max, _t.char_hp_current + _amount);
	}

	// Presentation only differs by zone - the effect itself doesn't.
	if (_context.zone == "field") {
		smallTextbox(healed_message(_targets, _amount));
	}
	// Battle-zone feedback (damage numbers, flash, etc.) is handled by
	// the battle system's own animation queue, not here.
}

function effect_heal_percent(_caster, _targets, _context) {
	var _pct = _context.power; // e.g. 50 = heal 50% of max HP
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		var _amount = floor(_t.char_hp_max * (_pct / 100));
		_t.char_hp_current = min(_t.char_hp_max, _t.char_hp_current + _amount);
	}
	if (_context.zone == "field") {
		smallTextbox(healed_message(_targets, undefined));
	}
}

function effect_damage_flat(_caster, _targets, _context) {
	var _amount = _context.power;
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		_t.char_hp_current = max(0, _t.char_hp_current - _amount);
	}
	// Field use of a damage effect would be unusual (use_zone should
	// normally gate this to "Battle" only), but the function itself
	// doesn't need to care why it was called.
}

function effect_restore_vp(_caster, _targets, _context) {
	var _amount = _context.power;
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		_t.char_vp_current = min(_t.char_vp_max, _t.char_vp_current + _amount);
	}
	if (_context.zone == "field") {
		smallTextbox("VP restored.");
	}
}

function effect_cure_status(_caster, _targets, _context) {
	// Assumes a char_status array/flag structure exists on the
	// character struct - adjust field name once your status-effect
	// system is built. Left intentionally minimal since that system
	// doesn't exist yet per your note.
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		if (variable_struct_exists(_t, "char_status")) {
			_t.char_status = [];
		}
	}
	if (_context.zone == "field") {
		smallTextbox("Status cured.");
	}
}

function effect_revive(_caster, _targets, _context) {
	var _pct = _context.power; // percent of max HP to revive at
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		if (_t.char_hp_current <= 0) {
			_t.char_hp_current = max(1, floor(_t.char_hp_max * (_pct / 100)));
		}
	}
	if (_context.zone == "field") {
		smallTextbox("Revived.");
	}
}

/// healed_message(_targets, _amount)
/// Small helper so heal effects don't each hand-build a string; single
/// vs multi target reads differently ("Joshua healed 70 HP." vs "Party
/// healed.").
function healed_message(_targets, _amount) {
	if (array_length(_targets) == 1) {
		var _name = _targets[0].char_name;
		return is_undefined(_amount) ? (_name + " healed.") : (_name + " healed " + string(_amount) + " HP.");
	}
	return "Party healed.";
}
