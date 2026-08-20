/// obj_fx_ignite :: Draw event

// --- scorch telegraph ---
if (frame >= 0) {
    var _t = min(frame / 8, 1);
    var _fadeStart = 50;
    var _alpha = (frame < _fadeStart) ? 0.55 * _t : max(0, 0.55 - (frame - _fadeStart) * 0.01);

    draw_set_alpha(_alpha);
    draw_set_color(c_black);
    draw_ellipse(target_x - 26 * _t, target_y + 4 - 7 * _t,
                 target_x + 26 * _t, target_y + 4 + 7 * _t, false);
    draw_set_alpha(1);
}

// --- flame column: drawn as a triangle-strip gradient, no sprite needed ---
var _local = frame - col_start;
var _total = col_rise + col_sustain + col_fall;

if (_local >= 0 && _local <= _total) {
    var _height, _colAlpha;

    if (_local < col_rise) {
        var _rt = _local / col_rise;
        _height = _rt * 50;
        _colAlpha = _rt;
    } else if (_local < col_rise + col_sustain) {
        var _st = (_local - col_rise) / col_sustain;
        _height = 50 + sin(_st * pi * 10) * 4; // flicker
        _colAlpha = 1;
    } else {
        var _ft = (_local - col_rise - col_sustain) / col_fall;
        _height = 50 * (1 - _ft);
        _colAlpha = 1 - _ft;
    }

    gpu_set_blendmode(bm_add);
    draw_set_alpha(_colAlpha);

    // three offset tongues: wide red base, mid orange, thin yellow tip
    draw_flame_tongue(target_x, target_y, _height, 12, c_red, frame, 0);
    draw_flame_tongue(target_x, target_y, _height, 8, c_orange, frame, 1.3);
    draw_flame_tongue(target_x, target_y, _height, 4,  c_yellow, frame, 2.1);

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

// --- core sprite, palette-shifted via shader ---
if (core_playing || core_frame < 6) {
    shader_set(shd_elemental_glow);
    shader_set_uniform_f(shader_get_uniform(shd_elemental_glow, "u_tint"), 0.97, 0.76, 0.29); // fire orange
    shader_set_uniform_f(shader_get_uniform(shd_elemental_glow, "u_glow"), 1 - (core_frame / 6));

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(core_sprite, floor(core_frame), target_x, target_y - 15, 0.8, 0.8, spark_rot, c_white, 1);
    gpu_set_blendmode(bm_normal);

    shader_reset();
}

// particle system draws itself automatically