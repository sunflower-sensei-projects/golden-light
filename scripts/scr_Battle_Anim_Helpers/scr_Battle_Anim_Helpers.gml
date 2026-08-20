/// scr_draw_flame_tongue(x, y, height, width, color, frame, flick_offset)
function draw_flame_tongue(_x, _y, _height, _width, _color, _frame, _flickOffset) {
    var _wobble = sin(_frame * 0.3 + _flickOffset) * 4;
    var _segments = 8;

    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i <= _segments; i++) {
        var _t = i / _segments;
        // taper width to a point at the top, bow sideways via _wobble at mid-height
        var _curW = lerp(_width, 0, _t * _t);
        var _bow = sin(_t * pi) * _wobble;
        var _py = _y - _height * _t;
        var _px = _x + _bow;

        var _alpha = 1 - _t * 0.85; // fades toward the tip
        draw_vertex_color(_px - _curW * 0.5, _py, _color, _alpha);
        draw_vertex_color(_px + _curW * 0.5, _py, _color, _alpha);
    }
    draw_primitive_end();
}

/// scr_draw_bolt_partial(points, count, width, color, alpha)
function draw_bolt_partial(_points, _count, _width, _color, _alpha) {
    if (_count < 2) return;
    draw_set_alpha(_alpha);
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < _count - 1; i++) {
        draw_line_width_color(_points[i].x, _points[i].y, _points[i+1].x, _points[i+1].y,
                              _width, _color, _color);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

/// scr_draw_bolt_full(points, width, color, alpha)
function draw_bolt_full(_points, _width, _color, _alpha) {
    draw_bolt_partial(_points, array_length(_points), _width, _color, _alpha);
}