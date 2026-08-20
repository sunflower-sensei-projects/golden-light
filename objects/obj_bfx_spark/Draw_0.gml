/// obj_fx_spark :: Draw event

// --- telegraph: brief gathering glow above the target, frames 0-4 ---
if (frame >= 0 && frame <= 4) {
    var _t = frame / 4;
    var _alpha = sin(_t * pi) * 0.6;

    gpu_set_blendmode(bm_add);
    draw_set_alpha(_alpha);
    draw_set_color(c_white);
    draw_circle(target_x, sky_y + 10, 18, false);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// --- bolt strike + flicker ---
var _flickerStart = flicker_start;

if (frame >= strike_start && frame < _flickerStart) {
    var _t = (frame - strike_start + 1) / strike_dur;
    var _visibleCount = max(2, floor(array_length(bolt_points) * _t));

    draw_bolt_partial(bolt_points, _visibleCount, 7, c_aqua, 0.35);
    draw_bolt_partial(bolt_points, _visibleCount, 4, make_color_rgb(63,168,154), 0.9);
    draw_bolt_partial(bolt_points, _visibleCount, 1.6, c_white, 0.95);

    if (_t >= 1) {
        draw_bolt_full(branch_1, 2, c_aqua, 0.6);
        draw_bolt_full(branch_2, 2, c_aqua, 0.6);
    }
} else if (frame >= _flickerStart && frame < _flickerStart + flicker_dur) {
    var _local = frame - _flickerStart;
    var _on = (_local mod 2 == 0);
    var _dim = 1 - (_local / flicker_dur) * 0.7;

    if (_on) {
        draw_bolt_full(bolt_points, 6, c_aqua, 0.3 * _dim);
        draw_bolt_full(bolt_points, 3, make_color_rgb(63,168,154), 0.8 * _dim);
        draw_bolt_full(bolt_points, 1.2, c_white, 0.9 * _dim);
    }
}

// --- impact spark, universal core sprite, teal/white tint, small scale ---
if (core_playing || core_frame < 6) {
    shader_set(shd_elemental_glow);
    shader_set_uniform_f(shader_get_uniform(shd_elemental_glow, "u_tint"), 0.55, 0.95, 0.88); // wind teal-white
    shader_set_uniform_f(shader_get_uniform(shd_elemental_glow, "u_glow"), 1 - (core_frame / 6));

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(core_sprite, floor(core_frame), target_x, target_y - 4,
                    core_scale, core_scale, 0, c_white, 1);
    gpu_set_blendmode(bm_normal);

    shader_reset();
}