draw_set_colour(c_white);
draw_set_font(global.font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Draw the background
draw_sprite_ext(sprite_index, image_index, xOrigin, yOrigin, width/sprite_width, height/sprite_height, 0, c_white, 1);

// Draw the characters in the already written lines all at once
for (_i = 0; _i < array_length(lines_written_array); _i++) {
	draw_text_ext(xOrigin+op_border, yOrigin+op_border+(8*array_length(lines_written_array)*_i), string(lines_written_array[_i]), 1, width);
}

// Draw the characters in the writing line one at a time
draw_text_ext(xOrigin+op_border, yOrigin+op_border+(8*array_length(lines_written_array)), string(text_to_write), 1, width);

// If you can continue the log, draw the sprite for the text arrow
if can_continue == true {
	draw_sprite(spr_textbox_arrow, image_index, xOrigin+op_border+string_width(text_to_write)+4, yOrigin+op_border+(8*array_length(lines_written_array))+4);
}