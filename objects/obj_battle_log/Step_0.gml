_back = keyboard_check_pressed(ord("X"));
_accept = keyboard_check_pressed(ord("Z"));
_menu = keyboard_check_pressed(ord("C"));

max_chars = array_length(text_buffer_array)-1;
if variable_global_exists("battle_log_buffer") {
	lines_to_write = array_length(global.battle_log_buffer)-1;
}
else {
	lines_to_write = 0;
}

if wait_timer == 0 {
	if _accept { // If the player hits the accept button
		show_debug_message("Accept key hit");
		show_debug_message("Char_index: "+string(char_index));
		show_debug_message("max_chars: "+string(max_chars));
		show_debug_message("current line: "+string(current_line));
		show_debug_message("lines_to_write: "+string(lines_to_write));
		if char_index == max_chars and can_continue == true { // If the current line has been written fully
			// Then, check to see if that was the last line to write
			if current_line == lines_to_write { // That's the last line, close the textbox and return to the battle menu
				// Close the textbox and re-enable the menu
				obj_menu_battle.hide_timer = 5;
				obj_menu_battle.menu_enabled = true;
				global.battle_log_buffer = [];
				battle_actors_return();
				instance_destroy(self);
			}
			else if current_line < lines_to_write { // There's still more to write
				array_push(lines_written_array, text_to_write); // Move the current line to the written array
				current_line += 1;
				char_index = 0; // Move the text index to the first character
				text_buffer_array = stringToArray(global.battle_log_buffer[current_line]); // Get the next line
				text_to_write = ""; // Restart the writing string
				can_continue = false;
			}
			wait_timer += 1;
		}
	}
	
	if _back {
		if char_index < max_chars {
			char_index = max_chars;
			text_to_write = string(global.text_buffer[textbox_index]);
		}
		wait_timer += 1;
	}
	
	if _menu {
		// Nothing yet
	}
}