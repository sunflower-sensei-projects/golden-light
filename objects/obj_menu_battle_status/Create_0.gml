height = 60;

op_border = 8;
op_space = 16;

_back = 0;
_menu = 0;

wait_timer = 1;

party_size = array_length(obj_party_controller._Party);
_Char = 0;

width = ( 48 * party_size ) + 32

x_viewport = camera_get_view_x(view_camera[0]);
y_viewport = camera_get_view_y(view_camera[0]);

view_width = camera_get_view_width(view_camera[0]);
view_height = camera_get_view_height(view_camera[0]);

xOrigin = x_viewport + view_width - width;
yOrigin = y_viewport;