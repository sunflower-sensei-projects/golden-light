// Key inputs
if wait_timer == 0 and hide_timer == 0 and menu_pause == false
{
	_right = keyboard_check_pressed(vk_right);
	_left = keyboard_check_pressed(vk_left);
	_accept = keyboard_check_pressed(ord("Z"));
	_menu = keyboard_check_pressed(ord("C"));
	_back = keyboard_check_pressed(ord("X"));
}

op_length = array_length(option);

pos += _right - _left;
if pos >= array_length(option[menu_layer])
{
	pos = 0;
}
else if pos < 0
{
	pos = array_length(option[menu_layer]) - 1;
}

// Hitting the back key
if _back
{
	if menu_layer == 1 {
		menu_layer = 0;
		pos = 0;
	}
}

// Accepting the selection
if _accept and menu_enabled
{
	if menu_layer == 0 {
		switch(pos)
		{
			case 0:
				// Fight
				menu_layer = 1;
				break;
			case 1:
				// Switch
				break;
			case 2:
				// Flee
				// battle_flee_attempt();
				end_battle();
				break;
			case 3:
				// Status
				break;
		}
	}
	else if menu_layer == 1 {
		switch(pos)
		{
			case 0:
				// Attack
				menu_enabled = false;
				menu_layer = 0;
				action_attack(obj_battle_protag, obj_battle_enemy, global.protag_buffer[0], global.enemy_buffer[0]);
				break;
			case 1:
				// Sorcery
				battle_actors_return();
				break;
			case 2:
				// Faefolk
				break;
			case 3:
				// Summon
				break;
			case 4:
				// Items
				break;
			case 5:
				// Defend
				break;
		}
	}
}