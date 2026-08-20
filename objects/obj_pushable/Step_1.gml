if (is_grabbed) {
	grab_glow_time += 1 / 90;
	if (grab_glow_time >= 1) grab_glow_time -= 1;
}