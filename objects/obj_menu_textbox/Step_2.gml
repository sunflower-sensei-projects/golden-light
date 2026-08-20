if wait_timer > 0
{
	wait_timer -= 1;
}
if char_index < max_chars
{
	char_index += 1;
	text_to_write += text_buffer_array[textbox_index][char_index];
	can_continue = false;
}
else if done_writing == false
{
	done_writing = true;
	can_continue = true;
}