draw_set_colour(c_white);
draw_set_font(global.font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Draw the background
draw_sprite_ext(sprite_index, image_index, xOrigin, yOrigin, width/sprite_width, height/sprite_height, 0, c_white, 1);

// Draw the talking sprite
draw_sprite(global.speaking_face, 0, xOrigin+op_border, yOrigin+op_border);

// Draw the characters in the current textbox one at a time
draw_text_ext(xOrigin+op_border+32, yOrigin+op_border, string(text_to_write), 1, width);