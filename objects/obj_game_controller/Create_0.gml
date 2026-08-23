/// obj_game_controller Create
/// This is the prime persistent object. Created in rm_init.

persistent = true;

// Quit handling
quit_timer = 0;
quitting   = false;

// Boot state
boot_failed = false;
boot_errors = [];

enum gState {
	INIT, TITLE, OVERWORLD, BATTLE
};

// Core globals
global.last_room         = -1;
global.resetPlayer       = false;
global.max_z_level       = 4;
global.menu_open         = false;
global.paused            = false;
global.battle_log        = [];
global.battle_log_buffer = [];
global.game_state        = gState.INIT;

// Data containers (filled by boot loader)
global.char_data = [];    global.char_index = {};
global.enemy_data = [];   global.enemy_index = {};
global.item_data = [];    global.item_index = {};
global.sorcery_data = []; global.sorcery_index = {};
global.ability_data = []; global.ability_index = {};
global.fae_data = [];     global.fae_index = {};
global.summon_data = [];  global.summon_index = {};

// Other Globals
global.char_invs = [];
global.item_max = 0;
global.coins = 0;

// Font
global.font = font_add_sprite_ext(
    spr_font,
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?()abcdefghijklmnopqrstuvwxyz.@/:0123456789-_~#|,';\"&$%^+=<>[]",
    false, -2
);

// ========== BOOT SEQUENCE ==========
var _result = scr_Boot_Load_All_Data();

if (_result.success) {
    // Create other persistent managers
    if (!instance_exists(obj_party_controller)) {
        instance_create_depth(0, 0, 0, obj_party_controller);
    }
    if (!instance_exists(obj_menu_controller)) {
        instance_create_depth(0, 0, 0, obj_menu_controller);
    }
    if (!instance_exists(obj_audio_controller)) {
		instance_create_depth(0, 0, 0, obj_audio_controller);	
	}
	if (!instance_exists(obj_debug_controller)) {
		instance_create_depth(0, 0, 0, obj_debug_controller);	
	}
    
    room_goto(rm_title);
} else {
    boot_failed = true;
    boot_errors = _result.errors;
}

// HELPER FUNCTIONS
function new_game() {
    global.coins = 0;
    
    scr_Party_Clear();
    
    var _result = addProtagToParty("Joshua");
    if (_result != 0) {
        show_debug_message("CRITICAL: Failed to create starting character Joshua");
        return;
    }
    
    show_debug_message("New Game started. Party size: " + string(scr_Party_Size()));
    
    room_goto(rm_large_int_test); // Change to Joshua's house later
}