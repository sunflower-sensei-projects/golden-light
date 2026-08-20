if (global.debug) {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_yellow);
	draw_set_font(global.font);
	draw_text(10, 10, "Debug Enabled");
	draw_text(10, 10+(8*1), "Player Z Level: " + string(Player.z_level));
	draw_text(10, 10+(8*2), "Gap hold timer: " + string(Player.gap_hold_timer));
	draw_text(10, 10+(8*3), "Player state: " + string(Player.state));
	draw_text(10, 10+(8*4), "Player is_moving: " + string(Player.is_moving));
}