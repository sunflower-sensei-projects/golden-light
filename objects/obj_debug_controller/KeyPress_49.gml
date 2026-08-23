switch (debug_menu_state) {
	case dState.OFF:
		debug_menu_state = dState.STATS;
		index_cur = 0;
		index_max = 0;
		global.debug = true;
		break;
	
	case dState.STATS:
		debug_menu_state = dState.BASE_MENU;
		global.paused = true;
		index_cur = 0;
		index_max = array_length(base_menu_options)-1;
		break;
	
	case dState.BASE_MENU:
	case dState.ACTIONS:
	case dState.CHARS:
	case dState.ITEMS:
	case dState.MAPS:
		debug_menu_state = dState.OFF;
		index_cur = 0;
		index_max = 0;
		global.debug = false;
		break;
}