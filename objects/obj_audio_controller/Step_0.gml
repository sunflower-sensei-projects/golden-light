if (is_fading) {
	fade_timer++;
	var _t = fade_timer / fade_duration;
	
	// Smooth ease
	var _ease = 1 - power(1 - _t, 3); // Cubic ease-out
	
	// Fade out current
	if (audio_is_playing(bgm_instance)) {
		audio_sound_gain(bgm_instance, (1 - _ease) * vol_bgm, 0);	
	}
	
	// Fade in incoming
	if (audio_is_playing(fade_in_inst)) {
		audio_sound_gain(fade_in_inst, _ease * vol_bgm, 0);	
	}
	
	if (fade_timer >= fade_duration) {
		// Crossfade complete
		if (audio_is_playing(bgm_instance)) {
			audio_stop_sound(bgm_instance);	
		}
		bgm_instance = fade_in_inst;
		bgm_current  = fade_target;
		fade_in_inst = undefined;
		fade_target  = undefined;
		is_fading    = false;
		fade_timer   = 0;
	}
}