/*
_cardinal_dir = round(Player.dir / 90) * 90;
if (_cardinal_dir >= 360) _cardinal_dir -= 360; // 315-360 range rounds up to 360, wrap back to 0

_gap_x  = Player.x + lengthdir_x(1, _cardinal_dir);
_gap_y  = Player.y + lengthdir_y(1, _cardinal_dir);
_land_x = Player.x + lengthdir_x(TILE_SIZE, _cardinal_dir);
_land_y = Player.y + lengthdir_y(TILE_SIZE, _cardinal_dir);
*/

_up = keyboard_check_pressed(vk_up);
_down = keyboard_check_pressed(vk_down);
_accept = keyboard_check_pressed(ord("Z"));
_back = keyboard_check_pressed(ord("X"));

if (_up) {
	if (index_cur == 0) {
		index_cur = index_max;	
	} else {
		index_cur -= 1;	
	}
}
else if (_down) {
	if (index_cur == index_max) {
		index_cur = 0;	
	} else {
		index_cur += 1;	
	}
}
else if (_accept || _back) {
	switch (debug_menu_state) {
		case dState.BASE_MENU:
			if (_accept) {
				if (index_cur == 0) { // Actions
					debug_menu_state = dState.ACTIONS;
					index_cur = 0;
					index_max = array_length(actions_menu_options)-1;
				}
				else if (index_cur == 1) { // Maps
					maps_menu_options = [];
					for (var _i = room_first; _i <= room_last; _i++) {
						if (room_exists(_i)) {
							array_push(maps_menu_options, room_get_name(_i));	
						}
					}
					debug_menu_state = dState.MAPS;
					index_cur = 0;
					index_max = array_length(maps_menu_options)-1;
				}
				else if (index_cur == 2) { // Items
					debug_menu_state = dState.ITEMS;
					index_cur = 0;
					index_max = array_length(items_menu_options)-1;
				}
				else if (index_cur == 3) { // Characters
					debug_menu_state = dState.CHARS;
					index_cur = 0;
					index_max = array_length(chars_menu_options)-1;
				}
			}
			else if (_back) {
				debug_menu_state = dState.STATS;
				index_cur = 0;
				index_max = 0;
			}
			break;
		
		case dState.ACTIONS:
			if (_accept) {
				if (index_cur == 0) { // Start New Game
					obj_game_controller.new_game();
				}
				else if (index_cur == 1) { // Go to Battle
					room_goto(rm_battle);
				}
			}
			else if (_back) {
				debug_menu_state = dState.BASE_MENU;
				index_cur = 0;
				index_max = array_length(base_menu_options)-1;
			}
			break;
		
		case dState.MAPS:
			if (_accept) {
				room_goto(asset_get_index(maps_menu_options[index_cur]));
			}
			else if (_back) {
				debug_menu_state = dState.BASE_MENU;
				index_cur = 0;
				index_max = array_length(base_menu_options)-1;
			}
			break;
		
		case dState.ITEMS:
			if (_accept) {
				
			}
			else if (_back) {
				debug_menu_state = dState.BASE_MENU;
				index_cur = 0;
				index_max = array_length(base_menu_options)-1;
			}
			break;
		
		case dState.CHARS:
			if (_accept) {
				
			}
			else if (_back) {
				debug_menu_state = dState.BASE_MENU;
				index_cur = 0;
				index_max = array_length(base_menu_options)-1;
			}
			break;
	}
}