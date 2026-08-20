z_level = 0; // set per-instance in the room editor to match its starting floor
fall_start_y = 0;
fall_z_level_before = 0;
push_weight = 60; // Weight = number of frames it takes to push one tile

is_grabbed = false;
grab_glow_time = 0;
u_push_grab_time     = shader_get_uniform(shd_push_grab, "u_time");
u_push_grab_tint     = shader_get_uniform(shd_push_grab, "u_tint");
u_push_grab_strength = shader_get_uniform(shd_push_grab, "u_glow_strength");