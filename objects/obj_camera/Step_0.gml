// obj_camera — Step Event

if (!instance_exists(follow_target)) {
    follow_target = instance_find(Player, 0);
    if (!instance_exists(follow_target)) exit;
    cam_x = follow_target.x;
    cam_y = follow_target.y;
}

var _vw     = camera_get_view_width(view_camera[0]);
var _vh     = camera_get_view_height(view_camera[0]);
var _view_x = 0;
var _view_y = 0;

switch (cam_mode) {

    case eCamMode.FOLLOW:
        var _tx = follow_target.x;
        var _ty = follow_target.y;

        var _dx = _tx - cam_x;
        var _dy = _ty - cam_y;

        if (abs(_dx) > deadzone_w) {
            cam_x = lerp(cam_x, _tx - sign(_dx) * deadzone_w, smoothing);
        }
        if (abs(_dy) > deadzone_h) {
            cam_y = lerp(cam_y, _ty - sign(_dy) * deadzone_h, smoothing);
        }

        _view_x = cam_x - _vw / 2;
        _view_y = cam_y - _vh / 2;

        // Clamp or center per axis
        _view_x = (room_width  > _vw)
            ? clamp(_view_x, 0, room_width  - _vw)
            : (room_width  - _vw) / 2;
        _view_y = (room_height > _vh)
            ? clamp(_view_y, 0, room_height - _vh)
            : (room_height - _vh) / 2;
        break;

    case eCamMode.FIXED:
        // Always centered on room — player can walk freely, camera never moves
        _view_x = (room_width  - _vw) / 2;
        _view_y = (room_height - _vh) / 2;
        break;

    case eCamMode.SNAP:
        // Instant follow — no lerp, no deadzone
        cam_x   = follow_target.x;
        cam_y   = follow_target.y;
        _view_x = cam_x - _vw / 2;
        _view_y = cam_y - _vh / 2;

        _view_x = (room_width  > _vw)
            ? clamp(_view_x, 0, room_width  - _vw)
            : (room_width  - _vw) / 2;
        _view_y = (room_height > _vh)
            ? clamp(_view_y, 0, room_height - _vh)
            : (room_height - _vh) / 2;
        break;
}

camera_set_view_pos(view_camera[0], _view_x, _view_y);

show_debug_message(
    "mode: "      + string(cam_mode)
    + " | cam_x: "  + string(cam_x)
    + " | cam_y: "  + string(cam_y)
    + " | vw: "     + string(_vw)
    + " | vh: "     + string(_vh)
    + " | room w: " + string(room_width)
    + " | room h: " + string(room_height)
    + " | view x: " + string(camera_get_view_x(view_camera[0]))
    + " | view y: " + string(camera_get_view_y(view_camera[0]))
    + " | player: " + (instance_exists(Player) ? string(Player.x) + "," + string(Player.y) : "NONE")
);