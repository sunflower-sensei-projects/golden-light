/// General menu option unlocks.
///
/// Each top-level menu option (Sorcery, Faefolk, Items, Status, Party,
/// Settings) has a persistent unlock flag - set once via
/// scr_menu_unlock(), never auto-reverted. The general menu page reads
/// these to decide which icons to actually show, so the icon row/label
/// cluster can shrink or grow as the story progresses without needing
/// every other page to know about unlock state.
///
/// Default state (call scr_menu_unlocks_init() once at game start, or
/// let it lazy-init on first read): Items, Status, and Settings start
/// unlocked since every character always has an inventory and a stat
/// sheet from the very first moment of play. Sorcery, Faefolk, and
/// Party start locked:
///   - Sorcery unlocks when Joshua receives the power of Enoch from
///     the angel in the Tabernacle of the LORD, at the start of the
///     game - call scr_menu_unlock("sorcery") in that scene's script.
///   - Faefolk unlocks when Quartz joins the party, upon first
///     leaving Shalem - call scr_menu_unlock("faefolk") there.
///   - Party unlocks once the roster reaches 5 or more members. This
///     one is NOT a single story-beat call - it's wired directly into
///     addProtagToParty() in scr_party.md, which checks
///     array_length(obj_party_controller._Party) >= 5 every time a
///     member joins and calls scr_menu_unlock("party") once true,
///     since that's the one function every recruitment path goes
///     through regardless of which scene triggers it.

function scr_menu_unlocks_init() {
	if (!variable_global_exists("menu_unlocks")) {
		global.menu_unlocks = {
			sorcery:  false,
			faefolk:  false,
			items:    true,
			status:   true,
			party:    false,
			settings: true
		};
	}
	if (!variable_global_exists("menu_unlock_pending_reveal")) {
		// Tracks which options were unlocked but haven't yet been shown
		// to the player with the "just revealed" animation. Separate
		// from menu_unlocks itself so scr_menu_is_unlocked() stays a
		// pure read - only scr_menu_page_general's enter() consumes
		// (clears) entries here, exactly once, the first time the menu
		// is actually opened after the unlock.
		global.menu_unlock_pending_reveal = {
			sorcery: false, faefolk: false, items: false,
			status: false, party: false, settings: false
		};
	}
}

/// scr_menu_unlock(_key)
/// Call this at the story beat that should reveal an option, e.g.
/// scr_menu_unlock("sorcery") right after Joshua learns Heal in the
/// prologue. Once set, stays set - there is no corresponding "lock"
/// function, since these are meant to be one-way per your design call.
/// Also arms the pending-reveal flag, so the next time the general
/// menu is actually opened, that option plays its "just unlocked"
/// animation once.
function scr_menu_unlock(_key) {
	scr_menu_unlocks_init();
	if (variable_struct_exists(global.menu_unlocks, _key)) {
		var _was_already_unlocked = global.menu_unlocks[$ _key];
		global.menu_unlocks[$ _key] = true;
		if (!_was_already_unlocked) {
			global.menu_unlock_pending_reveal[$ _key] = true;
		}
	} else {
		show_debug_message("scr_menu_unlock: unknown option key '" + string(_key) + "'");
	}
}

/// scr_menu_is_unlocked(_key)
function scr_menu_is_unlocked(_key) {
	scr_menu_unlocks_init();
	return variable_struct_exists(global.menu_unlocks, _key) ? global.menu_unlocks[$ _key] : false;
}

/// scr_menu_consume_pending_reveal(_key)
/// Returns true exactly once per unlock - the first caller after an
/// option unlocks gets true and the flag clears; every call after that
/// (until the next unlock) returns false. scr_menu_page_general's
/// enter() is the only intended caller.
function scr_menu_consume_pending_reveal(_key) {
	scr_menu_unlocks_init();
	if (!variable_struct_exists(global.menu_unlock_pending_reveal, _key)) { return false; }
	var _pending = global.menu_unlock_pending_reveal[$ _key];
	if (_pending) {
		global.menu_unlock_pending_reveal[$ _key] = false;
	}
	return _pending;
}
