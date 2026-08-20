/// obj_fx_ignite :: Create event

target_x = x; // set by the caller after instance_create_layer
target_y = y;

frame = 0;
phase = "telegraph"; // telegraph -> ignition -> sustain -> collapse -> done

flash_alpha = 0;

// --- particle system for this effect instance ---
part_sys = part_system_create();
part_system_depth(part_sys, depth - 1);

// sparks: thin fast streaks shooting up right at ignition
pt_spark = part_type_create();
part_type_shape(pt_spark, pt_shape_spark);
part_type_size(pt_spark, 0.06, 0.1, 0.01, 0);
part_type_color1(pt_spark, c_yellow);
part_type_alpha3(pt_spark, 1, 0.8, 0);
part_type_speed(pt_spark, 2, 4, -0.1, 0);
part_type_direction(pt_spark, 80, 100, 0, 0); // upward cone (GM: 0=right, 90=up)
part_type_life(pt_spark, 8, 14);
part_type_blend(pt_spark, true); // additive

// embers: glowing orbs that rise, wobble, and fade — the main sustain visual
pt_ember = part_type_create();
part_type_shape(pt_ember, pt_shape_flare);
part_type_size(pt_ember, 0.06, 0.14, 0.002, 0);
part_type_color2(pt_ember, c_yellow, c_orange);
part_type_alpha3(pt_ember, 1, 1, 0);
part_type_speed(pt_ember, 1.2, 2.6, -0.02, 0.05); // negative = decelerates as it rises
part_type_direction(pt_ember, 80, 100, 0, 10); // mostly straight up, slight spread
part_type_gravity(pt_ember, -0.02, 90); // gentle negative gravity = keeps drifting up
part_type_life(pt_ember, 35, 60);
part_type_blend(pt_ember, true);

// smoke: soft, slow, non-additive puffs that linger after the flame dies
pt_smoke = part_type_create();
part_type_shape(pt_smoke, pt_shape_cloud);
part_type_size(pt_smoke, 0.6, 1.3, 0.015, 0);
part_type_color1(pt_smoke, c_gray);
part_type_alpha3(pt_smoke, 0, 0.25, 0);
part_type_speed(pt_smoke, 0.2, 0.5, -0.01, 0);
part_type_direction(pt_smoke, 80, 100, 0, 15);
part_type_life(pt_smoke, 50, 80);
part_type_blend(pt_smoke, false);

emit_spark = part_emitter_create(part_sys);
emit_ember = part_emitter_create(part_sys);
emit_smoke = part_emitter_create(part_sys);

// core sprite (same asset as Quake, palette-shifted via shader)
core_sprite = spr_bfx_hitspark_strike;
core_playing = false;
core_frame = 0;
spark_rot = random(360); // Random rotation angle for hitspark

// flame column timing (mirrors the mockup's rise/sustain/fall)
col_start = 6;
col_rise = 8;
col_sustain = 26;
col_fall = 12;