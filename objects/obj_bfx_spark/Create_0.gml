/// obj_fx_spark :: Create event

target_x = 0; // set by caller
target_y = 0;
sky_y = 0;    // set by caller, or default below

frame = 0;
flash_alpha = 0;

// bolt geometry — generated once per cast so each Spark looks slightly different
bolt_points = [];
branch_1 = [];
branch_2 = [];

// timing
strike_start = 4;
strike_dur = 3;
flicker_start = strike_start + strike_dur; // 7
flicker_dur = 6;

// core sprite (same universal spark asset used by Quake/Ignite)
core_sprite = spr_bfx_hitspark_strike;
core_playing = false;
core_frame = 0;
core_scale = 0.55; // smaller than Quake/Ignite — Spark is a low-tier spell

// --- generate the jagged path from sky to target ---
function scr_fx_generate_bolt(_x1, _y1, _x2, _y2, _segs) {
    var _points = [];
    for (var i = 0; i <= _segs; i++) {
        var _t = i / _segs;
        var _y = lerp(_y1, _y2, _t);
        var _spread = 1 - abs(_t - 0.5) * 1.2; // pinch toward both ends, wider in middle
        var _xOff = random_range(-26, 26) * _spread;
        array_push(_points, { x: _x1 + _xOff, y: _y });
    }
    // force exact start/end so it always connects cleanly
    _points[0].x = _x1;
    _points[array_length(_points) - 1].x = _x2;
    return _points;
}

function scr_fx_generate_branch(_fromPoint, _segs) {
    var _points = [{ x: _fromPoint.x, y: _fromPoint.y }];
    var _dir = choose(-1, 1);
    for (var i = 1; i <= _segs; i++) {
        var _prev = _points[i - 1];
        array_push(_points, {
            x: _prev.x + _dir * random(14),
            y: _prev.y + random_range(4, 12)
        });
    }
    return _points;
}