if (quitting) {
	draw_set_colour(c_white);
	draw_set_font(global.font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_colour(0, 0, "Quitting...", c_white, c_white, c_white, c_white, quit_timer/60);
}