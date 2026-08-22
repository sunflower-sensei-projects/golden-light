/// Draw GUI – only used when boot fails
if (boot_failed) {

draw_set_color(c_black);
draw_set_alpha(0.85);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

draw_set_font(global.font);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_red);
draw_text(display_get_gui_width() * 0.5, 80, "INITIALIZATION FAILED");

draw_set_color(c_white);
draw_set_halign(fa_left);
var _y = 140;
for (var i = 0; i < array_length(boot_errors); i++) {
    draw_text(80, _y, "• " + boot_errors[i]);
    _y += 28;
}

draw_set_halign(fa_center);
draw_set_color(c_yellow);
draw_text(display_get_gui_width() * 0.5, display_get_gui_height() - 80,
    "Check the datafiles folder and restart the game.\nPress ESC to quit.");
};
	
if (quitting) {
	draw_set_colour(c_white);
	draw_set_font(global.font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_colour(0, 0, "Quitting...", c_white, c_white, c_white, c_white, quit_timer/60);
}