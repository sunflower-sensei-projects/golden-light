// Currently playing
bgm_current  = undefined; // Asset index of current BGM
bgm_instance = undefined; // Sound instance returned by audio_play_sound
bgm_volume   = 1.0;

// Crossfaded and Jaded
fade_target   = undefined; // BGM to fade in
fade_in_inst  = undefined; // instance of incoming track
fade_duration = 60; // How many frames for a full crossfade
fade_timer    = 0;
is_fading     = false;

// Area music stack, push/pop for cutscenes that inturrupt the area BGM
bgm_stack = [];

// Master Volume
vol_bgm = 1.0;
vol_sfx = 1.0;


/// Helper Functions ///

function bgm_play(_track, _fade_frames=60) {
	// Already playing this track, do nothing
	if (_track == bgm_current && audio_is_playing(bgm_instance)) return;
	
	// If mid-fade, snap the current fade and clean up
	if (is_fading) {
		audio_stop_sound(bgm_instance);
		bgm_instance = fade_in_inst;
		bgm_current = fade_target;
		is_fading = false;
	}
	
	if (_fade_frames <= 0 || bgm_current == undefined) {
		// Don't fade
		if (audio_is_playing(bgm_instance)) audio_stop_sound(bgm_instance);
		bgm_instance = audio_play_sound(_track, 10, true);
		audio_play_sound(bgm_instance, vol_bgm, 0);
		bgm_current = _track;
	} else {
		// Begin Crossfade
		fade_target = _track;
		fade_duration = _fade_frames;
		fade_timer = 0;
		is_fading = true;
		fade_in_inst = audio_play_sound(_track, 10, true);
		audio_play_sound(fade_in_inst, 0, 0); // Start silently
	}
}

function bgm_stop(_fade_frames=60) {
	// Stop BGM with an optional fade-out
	if (!audio_is_playing(bgm_instance)) return;
	
	if (_fade_frames >= 0) {
		audio_stop_sound(bgm_instance);
		bgm_current = undefined;
		bgm_instance = undefined;
	} else {
		// Fade to silence using GM's built-in gain tween
		audio_sound_gain(bgm_instance, 0, (_fade_frames / game_get_speed(gamespeed_fps)) * 1000);
		// Schedule clean-up with an alarm
		alarm[0] = _fade_frames;
	}
}

function bgm_push(_track, _fade_frames) {
	// Push the current BGM onto the stack
	// Used when a cutscene needs to play music
	if (bgm_current != undefined) {
		array_push(bgm_stack, {
			track: bgm_current,
			instance: bgm_instance,
			position: audio_sound_get_track_position(bgm_instance)
		});
		// Pause so we can continue later
		audio_pause_sound(bgm_instance);
	}
	bgm_current = undefined;
	bgm_instance = undefined;
	bgm_play(_track, _fade_frames);
}

function bgm_pop(_fade_frames=60) {
	// Pop the stack and resume the previous track
	if (array_length(bgm_stack) == 0) {
		bgm_stop(_fade_frames);
		return;
	}
	
	var _prev = array_pop(bgm_stack);
	
	// Fade out current custscene track
	if (audio_is_playing(bgm_instance)) {
		audio_sound_gain(bgm_instance, 0, (_fade_frames / game_get_speed(gamespeed_fps)) * 1000);
		alarm[1] = _fade_frames;
	}
	
	// Resume the stacked track from where it left off
	audio_resume_sound(_prev.instance);
	audio_sound_set_track_position(_prev.instance, _prev.position);
	audio_sound_gain(_prev.instance, vol_bgm, (_fade_frames / game_get_speed(gamespeed_fps)) * 1000);
	bgm_instance = _prev.instance;
	bgm_current = _prev.track;
}

function bgm_stinger(_track, _duck_vol=0.3) {
	// Ducks the current BGM
	if (audio_is_playing(bgm_instance)) {
		audio_sound_gain(bgm_instance, vol_bgm * _duck_vol, 200);	
	}
	var _inst = audio_play_sound(_track, 11, false);
	audio_sound_gain(_inst, vol_sfx, 0);
	// Restore BGM when the stinger ends
	var _dur = (audio_sound_length(_track) * game_get_speed(gamespeed_fps));
	alarm[2] = ceil(_dur);
	return _inst;
}

function bgm_set_volume(_vol) {
	// Set master volume and apply immediately	
	vol_bgm = clamp(_vol, 0, 1);
	if (audio_is_playing(bgm_instance)) {
		audio_sound_gain(bgm_instance, vol_bgm, 100);	
	}
}

function sfx_play(_track, _pitch=1) {
	// Play a sound effect
	var _inst = audio_play_sound(_track, 5, false);
	audio_sound_gain(_inst, vol_sfx, 0);
	audio_sound_pitch(_inst, _pitch);
	return _inst;
}