if (global.debug) {
	draw_set_colour(c_gray);
	draw_arrow(Player.x, Player.y, _gap_x, _gap_y, 3);
	draw_set_colour(c_orange);
	draw_arrow(Player.x, Player.y, _land_x, _land_y, 1);	
}