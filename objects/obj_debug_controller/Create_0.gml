global.debug = false;

_cardinal_dir = 0;
_gap_x  = 0;
_gap_y  = 0;
_land_x = 0;
_land_y = 0;

enum dState {
	OFF, STATS, BASE_MENU, ACTIONS, MAPS, ITEMS, CHARS
}

debug_menu_state = dState.OFF;

_up = 0;
_down = 0;
_accept = 0;
_back = 0;

base_menu_options = ["Actions", "Maps", "Items", "Characters"];
actions_menu_options = ["Start New Game", "Go to battle"];
maps_menu_options = [];
_j = 0;
items_menu_options = ["Add Item to Character", "Remove Item from Character"];
chars_menu_options = ["Add Character to Party", "Remove Character to Party", "Edit Stats", "Edit Equipment", "Edit Faefolk", "Change Class", "Edit Sorceries"];

index_cur = 0;
index_max = 0;