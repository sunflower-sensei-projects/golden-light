/// obj_fx_quake :: Step event

frame++;

switch (frame) {
    case 0:
        part_emitter_region(part_sys, emit_crack, target_x-10, target_x+10, target_y, target_y, ps_shape_rectangle, ps_distr_linear);
        part_emitter_burst(part_sys, emit_crack, pt_crack, 24);
        break;

    case 10:
        part_emitter_region(part_sys, emit_debris,
			target_x - 5, target_x + 5, target_y, target_y - 5,
			ps_shape_rectangle, ps_distr_gaussian);
		part_emitter_burst(part_sys, emit_debris, pt_debris, 16);

		part_emitter_region(part_sys, emit_dust,
			target_x - 15, target_x + 15, target_y, target_y - 5,
			ps_shape_ellipse, ps_distr_linear);
		part_emitter_burst(part_sys, emit_dust, pt_dust, 10);

		core_playing = true;
		core_frame = 0;
		shake_amt = 6;
		flash_alpha = 0.35;

		if (instance_exists(obj_camera)) obj_camera.shake_amount = shake_amt;
        break;

    case 40:
        part_emitter_burst(part_sys, emit_dust, pt_dust, 6);
        break;
}

// core sprite frame advance (6 frames over ~18 steps, matches mockup pacing)
if (core_playing) {
    core_frame += 1;
    if (core_frame >= 6) core_playing = false;
}

// decay shake/flash
shake_amt *= 0.88;
flash_alpha *= 0.8;

// cleanup
if (frame > 110) {
    part_system_destroy(part_sys);
    instance_destroy();
}