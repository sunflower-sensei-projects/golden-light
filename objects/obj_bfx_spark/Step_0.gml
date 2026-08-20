/// obj_fx_spark :: Step event

frame++;

if (frame == 0 && sky_y == 0) {
    sky_y = target_y - 200; // reasonable default if caller didn't set one
}

if (frame == strike_start) {
    bolt_points = scr_fx_generate_bolt(target_x, sky_y, target_x, target_y, 9);
    branch_1 = scr_fx_generate_branch(bolt_points[3], 4);
    branch_2 = scr_fx_generate_branch(bolt_points[6], 4);
}

if (frame == strike_start + strike_dur - 1) {
    // bolt has just landed — trigger flash + impact spark
    flash_alpha = 0.5;
    core_playing = true;
    core_frame = 0;

    if (instance_exists(obj_camera)) obj_camera.shake_amount = 2; // Spark is light, barely any shake
}

if (core_playing) {
    core_frame += 0.33;
    if (core_frame >= 6) core_playing = false;
}

flash_alpha *= 0.7;

if (frame > 26) {
    instance_destroy();
}