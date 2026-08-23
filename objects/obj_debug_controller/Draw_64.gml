if (global.debug) {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_colour(c_yellow);
	draw_set_font(global.font);
	
	switch (debug_menu_state) {
		case dState.STATS:
			draw_text(10, 10, "Debug Enabled");
			if (instance_exists(Player)) {
				draw_text(10, 10+(8*1), "Player Z Level: " + string(Player.z_level));
				draw_text(10, 10+(8*2), "Gap hold timer: " + string(Player.gap_hold_timer));
				draw_text(10, 10+(8*3), "Player state: " + string(Player.state));
				draw_text(10, 10+(8*4), "Player is_moving: " + string(Player.is_moving));
			} else {
				draw_text(10, 10+(8*1), "Player Z Level: " + "NO PLAYER");
				draw_text(10, 10+(8*2), "Gap hold timer: " + "NO PLAYER");
				draw_text(10, 10+(8*3), "Player state: " + "NO PLAYER");
				draw_text(10, 10+(8*4), "Player is_moving: " + "NO PLAYER");
			}
			draw_text(10, 10+(8*5), "Current Room: " + room_get_name(room));
			draw_text(10, 10+(8*6), "Current Party: " + string(obj_party_controller._Party));
			draw_text(10, 10+(8*7), "Current Party Size: " + string(array_length(obj_party_controller._Party)));
			break;
		
		case dState.BASE_MENU:
			draw_text(10, 10, "Debug Menu");
			for (_j = 0; _j < array_length(base_menu_options); _j++) {
				draw_text(10, 10+(8*(_j+1)), string(base_menu_options[_j]));
			}
			draw_sprite(spr_textbox_arrow, 0, 4, 10+(8*(index_cur+1))+4);
			break;
			
		case dState.ACTIONS:
			draw_text(10, 10, "Debug Actions");
			for (_j = 0; _j < array_length(actions_menu_options); _j++) {
				draw_text(10, 10+(8*(_j+1)), string(actions_menu_options[_j]));
			}
			draw_sprite(spr_textbox_arrow, 0, 4, 10+(8*(index_cur+1))+4);
			break;
			
		case dState.MAPS:
			draw_text(10, 10, "Debug Map Select");
			for (_j = 0; _j < array_length(maps_menu_options); _j++) {
				draw_text(10, 10+(8*(_j+1)), string(maps_menu_options[_j]));
			}
			draw_sprite(spr_textbox_arrow, 0, 4, 10+(8*(index_cur+1))+4);
			break;
			
		case dState.ITEMS:
			draw_text(10, 10, "Debug Inventory Handling");
			for (_j = 0; _j < array_length(items_menu_options); _j++) {
				draw_text(10, 10+(8*(_j+1)), string(items_menu_options[_j]));
			}
			draw_sprite(spr_textbox_arrow, 0, 4, 10+(8*(index_cur+1))+4);
			break;
			
		case dState.CHARS:
			draw_text(10, 10, "Debug Character Handling");
			for (_j = 0; _j < array_length(chars_menu_options); _j++) {
				draw_text(10, 10+(8*(_j+1)), string(chars_menu_options[_j]));
			}
			draw_sprite(spr_textbox_arrow, 0, 4, 10+(8*(index_cur+1))+4);
			break;
	}
}