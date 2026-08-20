function scr_Check_Landing() {
	// Checks one pixel below the player's feet for solid ground
	// Adjust the Y offset to match the sprite's anchor point
	return place_meeting(x, y + 1, obj_wall)
		|| place_meeting(x, y + 1, obj_floor);
}