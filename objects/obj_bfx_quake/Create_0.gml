/// obj_fx_quake :: Create event

target_x = 0; // or set via variable_instance before instance_create
target_y = 0;

frame = 0;
phase = "telegraph"; // telegraph -> impact -> settle -> done

// one persistent particle system for this effect instance
part_sys = part_system_create();
part_system_depth(part_sys, depth - 1); // draw above ground, below UI

// --- particle types, built once, cached in a script or Create ---
pt_crack   = part_type_create();
part_type_shape(pt_crack, pt_shape_line);
part_type_size(pt_crack, 1, 2, 0, 0);
part_type_color1(pt_crack, c_yellow);
part_type_alpha3(pt_crack, 1, 0.6, 0);
part_type_speed(pt_crack, 3, 6, -0.15, 0);
part_type_direction(pt_crack, 0, 360, 0, 0);
part_type_life(pt_crack, 10, 16);

pt_debris  = part_type_create();
part_type_shape(pt_debris, pt_shape_square);
part_type_size(pt_debris, 0.12, 0.22, 0, 0);
part_type_color2(pt_debris, c_orange, c_black);
part_type_alpha3(pt_debris, 1, 1, 0);
part_type_speed(pt_debris, 2, 5, -0.05, 0.3);
part_type_direction(pt_debris, 45, 135, 0, 10);
part_type_gravity(pt_debris, 0.12, 270);
part_type_orientation(pt_debris, 0, 360, -8, 8, 1);
part_type_life(pt_debris, 28, 45);

pt_dust    = part_type_create();
part_type_shape(pt_dust, pt_shape_cloud);
part_type_size(pt_dust, 0.8, 2.2, 0.02, 0);
part_type_color1(pt_dust, c_gray);
part_type_alpha3(pt_dust, 0, 0.5, 0);
part_type_speed(pt_dust, 0.15, 0.5, -0.02, 0);
part_type_direction(pt_dust, 0, 180, 0, 0);
part_type_life(pt_dust, 45, 75);

// emitters — reusable "spawn points" bound to this system
emit_crack  = part_emitter_create(part_sys);
emit_debris = part_emitter_create(part_sys);
emit_dust   = part_emitter_create(part_sys);

// screen shake + flash hooks
shake_amt = 0;
flash_alpha = 0;

// the one hand-drawn asset
core_sprite = spr_bfx_hitspark_strike; // 6-frame strip
core_playing = false;
core_frame = 0;