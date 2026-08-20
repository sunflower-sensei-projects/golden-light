/// Panel hue system.
///
/// One global setting (global.settings_panel_hue, 0-255) drives every
/// panel's color across the whole menu system. Only hue rotates -
/// saturation and lightness (well, GML's HSV equivalent: saturation
/// and value) stay fixed - so every one of the 256 positions still
/// reads as "the same UI, recolored" rather than 256 independently
/// good-or-bad designs. Default value reproduces the original approved
/// blue almost exactly, so a player who never touches the setting sees
/// no visible change from what's already shipped.
///
/// GML's make_color_hsv takes all three channels on a 0-255 scale
/// already, which happens to line up exactly with the slider's own
/// 0-255 range - no conversion math needed for the hue axis itself.

/// scr_panel_hue_default()
/// The hue index that reproduces the current shipped blue. Tuned by
/// eye against the mockup - adjust this single number if the "no
/// change" default ever needs to shift.
function scr_panel_hue_default() {
	return 142;
}

/// scr_panel_hue_init()
/// Call once at game start (alongside other global settings init) if
/// no saved value exists yet.
function scr_panel_hue_init() {
	if (!variable_global_exists("settings_panel_hue")) {
		global.settings_panel_hue = scr_panel_hue_default();
	}
}

/// scr_panel_hue_set(_index)
/// Clamps and stores a new hue value. Call this from the Settings
/// page's slider handling - every panel reads global.settings_panel_hue
/// directly on its next draw, so there's no separate "apply" step.
function scr_panel_hue_set(_index) {
	global.settings_panel_hue = clamp(_index, 0, 255);
}

/// scr_panel_tint()
/// Returns the color every panel should blend spr_menu_window with,
/// derived from the current hue at fixed saturation/value. This is
/// the single call site every page's draw_gui should use in place of
/// the hardcoded c_white blend argument.
function scr_panel_tint() {
	var _hue = variable_global_exists("settings_panel_hue") ? global.settings_panel_hue : scr_panel_hue_default();
	// Saturation/value tuned to land close to the original panel blue
	// at the default hue - same fixed values used by every hue choice.
	return make_color_hsv(_hue, 148, 190);
}

/// scr_panel_border_tint()
/// A desaturated, brighter variant for panel borders - keeps borders
/// reading as "light trim" rather than a saturated colored outline at
/// every hue, matching how the original white border worked regardless
/// of panel fill color.
function scr_panel_border_tint() {
	var _hue = variable_global_exists("settings_panel_hue") ? global.settings_panel_hue : scr_panel_hue_default();
	return make_color_hsv(_hue, 40, 250);
}
