// Draw the background
draw_set_colour(c_white);
draw_set_font(global.font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_sprite_ext(sprite_index, image_index, xOrigin, yOrigin, width/sprite_width, height/sprite_height, 0, c_white, 1);

// Draw the health and mana bars
draw_sprite_ext(spr_healthbar_back, 0, xOrigin - (op_border + 12), yOrigin - (op_border + 4 + op_space), 20, 1, 0, c_white, 1);
draw_sprite_ext(spr_healthbar_back, 0, xOrigin - (op_border + 12), yOrigin - (op_border + 4 + op_space*2), 20, 1, 0, c_white, 1);

// Draw the stats
for (var _i = 0; _i < party_size; _i++)
{
	_Char = obj_party_controller._Party[_i]
	draw_text(xOrigin+op_border, yOrigin+op_border, _Char.char_name);
	draw_sprite_ext(spr_healthbar_top, 0, xOrigin + op_border + 12, yOrigin + op_border + 4 + op_space, (_Char.char_hp_current / _Char.char_hp_max)*20, 1, 0, c_white, 1);
	draw_text(xOrigin+op_border, yOrigin+op_border + op_space, "HP "+string(_Char.char_hp_current));
	draw_sprite_ext(spr_healthbar_top, 0, xOrigin + op_border + 12, yOrigin + op_border + 4 + op_space*2, (_Char.char_vp_current / _Char.char_vp_max)*20, 1, 0, c_white, 1);
	draw_text(xOrigin+op_border, yOrigin+op_border + op_space*2, "VP "+string(_Char.char_vp_current));
}

// Draw the elemental icons
//draw_sprite(spr_UI_earth_icon, 0, xOrigin + op_border + 4, yOrigin + op_border + 4);
//draw_sprite(spr_UI_fire_icon, 0, xOrigin + op_border + 12, yOrigin + op_border + 4);
//draw_sprite(spr_UI_water_icon, 0, xOrigin + op_border + 4, yOrigin + op_border + 12);
//draw_sprite(spr_UI_wind_icon, 0, xOrigin + op_border + 12, yOrigin + op_border + 12);

// Draw the available faefolk