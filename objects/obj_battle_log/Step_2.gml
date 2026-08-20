if wait_timer > 0
{
	wait_timer -= 1;
}

if char_index < max_chars
{
	text_to_write += text_buffer_array[char_index];
	char_index += 1;
	can_continue = false;
}
else if char_index == max_chars
{
	if can_continue == false {
		done_writing = true;
		can_continue = true;
	}
}