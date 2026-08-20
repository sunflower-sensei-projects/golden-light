// Init
width = 96;
height = 32;

op_border = 5;
op_space = 10;
op_length = 1;

_right = 0;
_left = 0;
_accept = 0;
_menu = 0;
_back = 0;

pos = 0;
menu_layer = 0;

wait_timer = 1;
scale_timer = 0;
menu_pause = false;
menu_enabled = true;
hide_timer = 0;

option[0][0] = "Fight";
option[0][1] = "Switch";
option[0][2] = "Flee";
option[0][3] = "Status";

option[1][0] = "Attack";
option[1][1] = "Sorcery";
option[1][2] = "Faefolk";
option[1][3] = "Summon";
option[1][4] = "Items";
option[1][5] = "Defend";

x_viewport = camera_get_view_x(view_camera[0]);
y_viewport = camera_get_view_y(view_camera[0]);

xOrigin = x_viewport + camera_get_view_width(view_camera[0]) - width;
yOrigin = y_viewport + camera_get_view_height(view_camera[0]) - height;