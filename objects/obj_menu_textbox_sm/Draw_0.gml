draw_set_colour(c_white);
draw_set_font(global.font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Draw the background
draw_sprite_ext(sprite_index, image_index, xOrigin, yOrigin, width/sprite_width, height/sprite_height, 0, c_white, 1);

// Draw the characters in the textbox buffer
draw_text_ext(xOrigin+op_border, yOrigin+op_border, global.sm_text_buffer, 12, max_width-16);