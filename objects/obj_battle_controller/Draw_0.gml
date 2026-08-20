// Draw floor
scr_battle_draw_floor();

// Sort battlers by depth, from furthest to closest
var _all = array_concat(party_battlers, enemy_battlers);
var _sorted = array_create(array_length(_all));
array_copy(_sorted, 0, _all, 0, array_length(_all));
scr_array_sort_depth(_sorted);

for (var _i = 0; _i < array_length(_sorted); _i++) {
	var _b = _sorted[_i];
	if (!_b.alive) continue;
	draw_sprite_ext(
		_b.sprite,
		_b.image_index,
		_b.screen_x,
		_b.screen_y,
		1, 1, 0,
		c_white, 1
	);
}

// Draw the UI after that, on top
scr_battle_draw_UI();