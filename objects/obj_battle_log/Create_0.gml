height = 64;

op_border = 8;
op_space = 16;

_back = 0;
_accept = 0;
_menu = 0;

wait_timer = 1;

x_viewport = camera_get_view_x(view_camera[0]);
y_viewport = camera_get_view_y(view_camera[0]);

view_width = camera_get_view_width(view_camera[0]);
view_height = camera_get_view_height(view_camera[0]);

width = view_width;

xOrigin = x_viewport;
yOrigin = y_viewport + view_height - height;

char_index = 0; // What character the current line is on
if variable_global_exists("battle_log_buffer") {
	text_buffer_array = stringToArray(global.battle_log_buffer[0]); // This array holds all the characters of the current line
}
else {
	text_buffer_array = [];
}
// Check to make sure there's something to write at all, if not, kill the box
/*
if array_length(global.battle_log_buffer) > 0 {
	text_buffer_array = stringToArray(global.battle_log_buffer[0]);
}
else
{
	instance_destroy(self);
}
*/

lines_written_array = []; // This array holds the lines that have already been written as strings
text_to_write = ""; // This string is what the line currently looks like
done_writing = false;
can_continue = false;

max_chars = 0;
lines_to_write = 0;
current_line = 0;

_i = 0;

show_debug_message(string(global.battle_log_buffer));