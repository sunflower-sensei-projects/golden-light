// global.font_main = font_add_sprite(spr_main_font, 32, true, 1);
mapstr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?()abcdefghijklmnopqrstuvwxyz.@/:0123456789-_~#|,';\"&$%^+=<>[]";
global.font_main = font_add_sprite_ext(spr_font, mapstr, true, 0);

draw_set_font(global.font_main);
draw_set_valign(fa_top);
draw_set_halign(fa_left);

global.paused = false;
global.sm_text_buffer = "";
global.text_buffer = [];