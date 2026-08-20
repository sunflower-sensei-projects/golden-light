/// obj_menu_controller - Create Event
///
/// Single persistent instance. Owns the menu stack, input polling,
/// open/close debounce, and cursor positioning. Create this once
/// (e.g. in the game's init room) and never destroy it - it just sits
/// idle with an empty stack when the menu is closed.

scr_menu_stack_init();
scr_effect_registry_init();
scr_panel_hue_init();
scr_menu_unlocks_init();

is_open = false;
open_wait = 0;      // frames to ignore input after opening/closing (debounce)
OPEN_WAIT_FRAMES = 5;

// Convenience: other systems can check global.menu_open exactly like
// before, so overworld movement / interaction code doesn't need to change.
global.menu_open = false;

// Party manager reference, used by nearly every page.
mgr = obj_party_controller;

// Held-direction autorepeat tracking - see scr_menu_input.
repeat_state = scr_menu_repeat_state_init();
was_blocked = false;
