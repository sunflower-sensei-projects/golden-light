/// obj_menu_controller - Draw GUI Event

if (!is_open) { exit; }

draw_set_colour(c_white);
draw_set_font(global.font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Draw every page currently on the stack, bottom to top, so a pushed
// submenu renders on top of (not instead of) its parent. Matches how
// e.g. the item-options popup used to draw over the item grid rather
// than replacing it.
var _len = array_length(global.menu_stack);
for (var _i = 0; _i < _len; _i++) {
	var _page = global.menu_stack[_i];
	if (variable_struct_exists(_page, "draw_gui")) {
		_page.draw_gui();
	}
}
