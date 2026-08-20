// ============================================================
// Draw GUI Event (put this code in the Draw GUI event, not Draw,
// so the menu stays fixed on screen regardless of camera/room position)
// ============================================================

draw_set_font(global.font); // default font; swap to global.font if you want it styled to match your game
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// background panel
draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(menu_x - 8, menu_y - 8, menu_x + 180, menu_y + (array_length(fx_list) * row_height) + 70, false);
draw_set_alpha(1);

// title
draw_set_color(c_white);
draw_text(menu_x, menu_y, "FX DEBUG MENU");

// effect list
for (var i = 0; i < array_length(fx_list); i++) {
	var _yPos = menu_y + 20 + (i * row_height);
	var _isSelected = (i == selected);

	draw_set_color(_isSelected ? c_yellow : c_white);
	var _prefix = _isSelected ? "> " : "  ";
	draw_text(menu_x, _yPos, _prefix + fx_list[i].name);
}

// controls reminder
var _controlsY = menu_y + 20 + (array_length(fx_list) * row_height) + 10;
draw_set_color(c_gray);
draw_text(menu_x, _controlsY, "Up/Down: select");
draw_text(menu_x, _controlsY + 12, "Left/Right: move marker");
draw_text(menu_x, _controlsY + 24, "Shift+arrows: fine move / Y-axis");
draw_text(menu_x, _controlsY + 36, "Z: cast R: clear all");