// Stinger is finished, restore BGM
if (audio_is_playing(bgm_instance)) {
	audio_sound_gain(bgm_instance, vol_bgm, 300);	
}