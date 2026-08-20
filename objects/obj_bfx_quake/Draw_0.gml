/// obj_fx_quake :: Draw event

// shockwave ring — same math as the mockup, just drawn with draw_ellipse or a shader
var _start = 10, _dur = 22;
if (frame >= _start && frame <= _start + _dur) {
    var _t = (frame - _start) / _dur;
    var _radius = _t * 170;
    var _alpha = (1 - _t) * 0.5;

    draw_set_alpha(_alpha);
    draw_set_color(c_orange);
    draw_ellipse(target_x - _radius, target_y - _radius * 0.28,
                 target_x + _radius, target_y + _radius * 0.28, true);
    draw_set_alpha(1);
}

// core sprite — this is where shd_elemental_glow gets applied
if (core_playing || core_frame < 6) {
    shader_set(shd_elemental_glow);
    shader_set_uniform_f(shader_get_uniform(shd_elemental_glow, "u_tint"), 0.85, 0.64, 0.29); // earth gold
    shader_set_uniform_f(shader_get_uniform(shd_elemental_glow, "u_glow"), 1 - (core_frame / 6));

    draw_sprite_ext(core_sprite, floor(core_frame), target_x, target_y - 6, 1.6, 1.6, 0, c_white, 1);

    shader_reset();
}

// particle system draws itself automatically once created —
// no manual draw call needed, GM handles it via part_sys depth