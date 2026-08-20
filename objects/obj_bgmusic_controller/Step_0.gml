/// @description Play BG Music

if current_bgmusic != global.new_bgmusic
{
	audio_stop_sound(current_bgmusic);
	audio_play_sound(global.new_bgmusic, 100, true);
	current_bgmusic = global.new_bgmusic;
}