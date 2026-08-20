if menu_enabled == true and hide_timer == 0 {
	draw_set_colour(c_white);
	draw_set_font(global.font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	// Draw the background
	draw_sprite_ext(sprite_index, image_index, xOrigin, yOrigin, width/sprite_width, height/sprite_height, 0, c_white, 1);

	// Draw the options
	if menu_layer == 0 {
		if pos != 0 { draw_sprite(spr_option_fight, 0, xOrigin-112, yOrigin+32) };
		if pos != 1 { draw_sprite(spr_option_switch, 0, xOrigin-80, yOrigin+32) };
		if pos != 2 { draw_sprite(spr_option_flee, 0, xOrigin-48, yOrigin+32) };
		if pos != 3 { draw_sprite(spr_option_settings, 0, xOrigin-16, yOrigin+32) };
	}
	else if menu_layer == 1 {
		if pos != 0 { draw_sprite(spr_option_attack, 0, xOrigin-176, yOrigin+32) };
		if pos != 1 { draw_sprite(spr_option_psynergy, 0, xOrigin-144, yOrigin+32) };
		if pos != 2 { draw_sprite(spr_option_djinni, 0, xOrigin-112, yOrigin+32) };
		if pos != 3 { draw_sprite(spr_option_summon, 0, xOrigin-80, yOrigin+32) };
		if pos != 4 { draw_sprite(spr_option_items, 0, xOrigin-48, yOrigin+32) };
		if pos != 5 { draw_sprite(spr_option_defend, 0, xOrigin-16, yOrigin+32) };
	}

	// Draw the selection text
	draw_text(xOrigin+op_border+2, yOrigin+op_border+2, option[menu_layer][pos]);

}