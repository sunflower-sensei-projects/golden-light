/// Confirm pulse - a 1-2 frame scale-pop played on the selected icon
/// the instant accept is pressed. Purely decorative: it never delays
/// the actual action (equip/use/push still happens the same frame),
/// it just adds a satisfying visual beat on top.
///
/// Usage in a page:
///   pulse: scr_pulse_init(),              // field on the page struct
///   ... in step(): if (_input.accept) { pulse = scr_pulse_trigger(pulse); }
///   ... in draw_gui(): var _scale = scr_pulse_scale(pulse);
///                       draw_sprite_ext(icon, 0, x, y, _scale, _scale, 0, c_white, 1);
///   ... in step(), every call: pulse = scr_pulse_advance(pulse);

/// scr_pulse_init()
function scr_pulse_init() {
	return { frame: 0 };
}

/// scr_pulse_trigger(_pulse)
/// Call when accept fires. Starts the pulse from frame 1.
function scr_pulse_trigger(_pulse) {
	return { frame: 1 };
}

/// scr_pulse_advance(_pulse)
/// Call once per step regardless of input, to tick the pulse forward.
/// Stops advancing (stays at 0) once it's finished.
function scr_pulse_advance(_pulse) {
	if (_pulse.frame <= 0) { return _pulse; }
	var _next = _pulse.frame + 1;
	if (_next > PULSE_DURATION_FRAMES()) { _next = 0; }
	return { frame: _next };
}

/// scr_pulse_scale(_pulse)
/// Returns the scale multiplier to draw the selected icon at this
/// frame - 1.0 when idle, briefly larger during the pulse, matching
/// the existing 1.5x "selected" scale already used for the resting
/// highlighted state (so the pulse reads as a little kick on top of
/// that, not a replacement for it).
function scr_pulse_scale(_pulse) {
	if (_pulse.frame <= 0) { return 1.0; }
	// Simple two-frame pop: frame 1 slightly larger than resting
	// selected scale, frame 2 settles back. Tune PULSE_PEAK_SCALE to
	// taste once you've seen it in motion.
	return (_pulse.frame == 1) ? PULSE_PEAK_SCALE() : 1.0;
}

function PULSE_DURATION_FRAMES() { return 2; }
function PULSE_PEAK_SCALE() { return 1.8; } // vs. the existing 1.5x resting-selected scale
