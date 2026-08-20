/// One-shot "reveal" shockwave — a golden ring that expands outward
/// from an icon and fades, played once when a locked option becomes
/// available. Same lightweight pattern as scr_menu_pulse: a small
/// struct with frame state, advanced every step, drawn from whatever
/// frame it's currently on.

/// scr_reveal_init()
function scr_reveal_init() {
	return { frame: 0 };
}

/// scr_reveal_trigger(_reveal)
function scr_reveal_trigger(_reveal) {
	return { frame: 1 };
}

/// scr_reveal_advance(_reveal)
/// Call once per step. Stops advancing (returns to 0/idle) once the
/// effect has finished playing.
function scr_reveal_advance(_reveal) {
	if (_reveal.frame <= 0) { return _reveal; }
	var _next = _reveal.frame + 1;
	if (_next > REVEAL_DURATION_FRAMES()) { _next = 0; }
	return { frame: _next };
}

/// scr_reveal_active(_reveal)
function scr_reveal_active(_reveal) {
	return _reveal.frame > 0;
}

/// scr_reveal_draw(_reveal, _cx, _cy)
/// Draws the expanding ring + icon fade-in at (_cx, _cy) - the center
/// of whatever icon is revealing. Call this INSTEAD of the icon's
/// normal draw call while the reveal is active; once it finishes,
/// go back to drawing the icon normally.
function scr_reveal_draw(_reveal, _cx, _cy) {
	if (_reveal.frame <= 0) { return; }

	var _t = _reveal.frame / REVEAL_DURATION_FRAMES(); // 0..1 progress
	var _ring_radius = lerp(4, 22, _t);
	var _ring_alpha = lerp(1, 0, _t);

	draw_set_alpha(_ring_alpha);
	draw_circle_color(_cx, _cy, _ring_radius, REVEAL_COLOR(), REVEAL_COLOR(), true);
	draw_set_alpha(1);
	// Icon itself fades/scales in underneath the ring rather than
	// popping to full size instantly - drawn by the caller using
	// scr_reveal_icon_alpha/scr_reveal_icon_scale below.
}

/// scr_reveal_icon_alpha(_reveal)
/// Icon fades in from 0 to full opacity over the reveal duration.
function scr_reveal_icon_alpha(_reveal) {
	if (_reveal.frame <= 0) { return 1; }
	return _reveal.frame / REVEAL_DURATION_FRAMES();
}

/// scr_reveal_icon_scale(_reveal, _base_scale)
/// Icon scales in from slightly small to its normal resting scale.
function scr_reveal_icon_scale(_reveal, _base_scale) {
	if (_reveal.frame <= 0) { return _base_scale; }
	var _t = _reveal.frame / REVEAL_DURATION_FRAMES();
	return lerp(_base_scale * 0.5, _base_scale, _t);
}

function REVEAL_DURATION_FRAMES() { return 20; } // ~1/3 second at 60fps - a beat, not a flourish
function REVEAL_COLOR() { return make_color_rgb(228, 199, 122); } // gold, matches the confirm-pulse/accent gold used elsewhere
