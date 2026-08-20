/// obj_fx_ignite :: Step event

frame++;

// --- scripted spawn points ---
if (frame == 0) {
    flash_alpha = 0.1;
}

if (frame == col_start) {
    flash_alpha = 0.3;
    core_playing = true;
    core_frame = 0;
}

// sparks burst during ignition + early sustain
if (frame >= 8 && frame <= 40 && (frame mod 3 == 0)) {
    part_emitter_region(part_sys, emit_spark, target_x - 3, target_x + 3, target_y, target_y, ps_shape_rectangle, ps_distr_linear);
    part_emitter_burst(part_sys, emit_spark, pt_spark, 4);
}

// embers spray continuously through sustain
if (frame >= 10 && frame <= 42 && (frame mod 4 == 0)) {
    part_emitter_region(part_sys, emit_ember, target_x - 10, target_x + 10, target_y - 20, target_y, ps_shape_rectangle, ps_distr_linear);
    part_emitter_burst(part_sys, emit_ember, pt_ember, 2);
}

// smoke kicks in once the flame is collapsing
if (frame == col_start + col_rise + col_sustain) {
    part_emitter_region(part_sys, emit_smoke, target_x - 8, target_x + 8, target_y - 30, target_y - 10, ps_shape_rectangle, ps_distr_linear);
    part_emitter_burst(part_sys, emit_smoke, pt_smoke, 6);
}

// core sprite frame advance
if (core_playing) {
    core_frame += 1.5;
    if (core_frame >= 6) core_playing = false;
}

flash_alpha *= 0.82;

// cleanup
if (frame > 100) {
    part_system_destroy(part_sys);
    instance_destroy();
}