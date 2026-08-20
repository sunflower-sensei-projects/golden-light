if wait_timer == 0
{
	Player.sprite_index = spr_isaac_stand_d;
	Player.image_speed = 0;
	Player.image_index = 0;
	Player.facing_x = 0;
	Player.facing_y = 1;
	instance_destroy(self);
}