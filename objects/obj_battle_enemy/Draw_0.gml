if sprite_flash_timer > 0 {
	gpu_set_fog(true, c_white, 0, 0);
	draw_sprite_ext(sprite_index, image_index, self.x, self.y, sprite_scale, sprite_scale, 0, c_white, 1);
	gpu_set_fog(false, c_white, 0, 0);
	sprite_flash_timer -= 1;
}
else {
	draw_sprite_ext(sprite_index, image_index, self.x, self.y, sprite_scale, sprite_scale, 0, c_white, 1);
}