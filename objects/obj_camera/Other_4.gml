// obj_camera — Room Start Event
follow_target = instance_find(Player, 0);

if (instance_exists(follow_target)) {
    // Always snap to player on room entry regardless of mode
    // so lerp doesn't slide in from the previous room's position
    cam_x = follow_target.x;
    cam_y = follow_target.y;

    var _vw = camera_get_view_width(view_camera[0]);
    var _vh = camera_get_view_height(view_camera[0]);
    camera_set_view_pos(
        view_camera[0],
        cam_x - _vw / 2,
        cam_y - _vh / 2
    );
}