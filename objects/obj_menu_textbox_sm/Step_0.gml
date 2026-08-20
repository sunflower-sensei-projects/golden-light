if wait_timer == 0
{
	_back = keyboard_check_pressed(ord("X"));
	_accept = keyboard_check_pressed(ord("Z"));

	if _accept or _back
	{
		global.paused = false;
		if instance_exists(obj_menu_items) {
			obj_menu_items.menu_wait = false;
			obj_menu_items.wait_timer = 5;
		}
		instance_destroy(self);
	}
}