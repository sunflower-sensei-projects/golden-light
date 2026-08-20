max_width = 80;
op_length = string_width(global.sm_text_buffer);
height = 0;
width = 64;

op_border = 8;
op_space = 2;

//lines = ( op_length div ( max_width-8 ) ) + 1;
lines = ( string_height_ext(global.sm_text_buffer,12,max_width-16) div 12 ) + 1;

if lines > 1
{
	width = max_width;
	height = ( 12*lines ) + ( op_border + 4 );
}
else if lines == 1
{
	width = op_length + (op_border*2);
	height = 24;
}

show_debug_message("Small Textbox created. Output text:");
show_debug_message(string(global.sm_text_buffer));
show_debug_message("Number of lines: "+string(lines));
show_debug_message("Window width: "+string(width)+", Window height: "+string(height));

_back = 0;
_accept = 0;

wait_timer = 1;

x_viewport = camera_get_view_x(view_camera[0]);
y_viewport = camera_get_view_y(view_camera[0]);

view_width = camera_get_view_width(view_camera[0]);
view_height = camera_get_view_height(view_camera[0]);

xOrigin = x_viewport + (view_width/2) - (width/2);
yOrigin = y_viewport + (view_height/2);