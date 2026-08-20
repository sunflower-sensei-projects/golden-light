if menu_enabled == true {
	if menu_layer == 0 {
		if pos == 0 { draw_sprite_ext(spr_option_fight, 0, xOrigin-112, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 1 { draw_sprite_ext(spr_option_switch, 0, xOrigin-80, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 2 { draw_sprite_ext(spr_option_flee, 0, xOrigin-48, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 3 { draw_sprite_ext(spr_option_settings, 0, xOrigin-16, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
	}
	else if menu_layer == 1 {
		if pos == 0 { draw_sprite_ext(spr_option_attack, 0, xOrigin-176, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 1 { draw_sprite_ext(spr_option_psynergy, 0, xOrigin-144, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 2 { draw_sprite_ext(spr_option_djinni, 0, xOrigin-112, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 3 { draw_sprite_ext(spr_option_summon, 0, xOrigin-80, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 4 { draw_sprite_ext(spr_option_items, 0, xOrigin-48, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
		else if pos == 5 { draw_sprite_ext(spr_option_defend, 0, xOrigin-16, yOrigin+32, 1.5, 1.5, 0, c_white, 1) }
	}
}