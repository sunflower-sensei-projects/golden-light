width = 360;
height = 64;

op_border = 8;
op_space = 16;

_back = 0;
_accept = 0;

wait_timer = 1;

x_viewport = camera_get_view_x(view_camera[0]);
y_viewport = camera_get_view_y(view_camera[0]);

view_width = camera_get_view_width(view_camera[0]);
view_height = camera_get_view_height(view_camera[0]);

xOrigin = x_viewport + view_width - width;
yOrigin = y_viewport;

textbox_index = 0;
char_index = 0;
text_buffer_array = convertTextBuffer(global.text_buffer);
text_to_write = string(text_buffer_array[textbox_index][char_index]);
done_writing = false;
can_continue = false;
text_on_bottom = true;

max_chars = 0;
max_textbox = 0;