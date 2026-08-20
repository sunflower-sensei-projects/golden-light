if (is_grabbed) {
	shader_set(shd_push_grab);
	shader_set_uniform_f(u_push_grab_time, grab_glow_time);
	shader_set_uniform_f(u_push_grab_tint, 1.0, 0.9, 0.6);
	shader_set_uniform_f(u_push_grab_strength, 1.0);
	draw_self();
	shader_reset();
} else {
	draw_self();
}