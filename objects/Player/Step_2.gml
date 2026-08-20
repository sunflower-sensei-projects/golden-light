// Use End Step so this runs after all movement is resolved

var _vw  = camera_get_view_width(view_camera[0]);
var _vh  = camera_get_view_height(view_camera[0]);

var _cx  = round(x) - _vw / 2;
var _cy  = round(y) - _vh / 2;

// Clamp to room bounds if room is larger than viewport
if (room_width > _vw) {
    _cx = clamp(_cx, 0, room_width - _vw);
} else {
    _cx = (room_width - _vw) / 2;
}

if (room_height > _vh) {
    _cy = clamp(_cy, 0, room_height - _vh);
} else {
    _cy = (room_height - _vh) / 2;
}

camera_set_view_pos(view_camera[0], _cx, _cy);