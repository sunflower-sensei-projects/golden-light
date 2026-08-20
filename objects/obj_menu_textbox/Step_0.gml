_back = keyboard_check_pressed(ord("X"));
_accept = keyboard_check_pressed(ord("Z"));

max_chars = array_length(text_buffer_array[textbox_index])-1;

if wait_timer == 0 {
	if _accept {
		if char_index == max_chars {
			if textbox_index < max_textbox {
				textbox_index += 1;
				char_index = 0;
				text_to_write = string(text_buffer_array[textbox_index][char_index]);
			}
			else if textbox_index == max_textbox {
				global.paused = false;
				instance_destroy(self);
			}
		}
	}
	
	if _back {
		if char_index < max_chars {
			char_index = max_chars;
			text_to_write = string(global.text_buffer[textbox_index]);
		}
		else if char_index == max_chars {
			if textbox_index < max_textbox {
				textbox_index += 1;
				char_index = 0;
				text_to_write = string(text_buffer_array[textbox_index][char_index]);
			}
		}
	}
}