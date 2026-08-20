// This object should be the Prime Object
// It is loaded first, and is never destroyed

// It handles game initialization, saving and loading, and the title screen

// Game Init
// gameInit();

// Quit timer
quit_timer = 0;
quitting = false;

// Other variables
global.last_room = 0;
global.resetPlayer = false;
global.max_z_level = 2;
global.player_last_x = 0;
global.player_last_y = 0;
global.player_last_facing_x = 0;
global.player_last_facing_y = 0;
global.player_last_sprite = 0;
global.player_last_spr_index = 0;
global.player_last_z_level = 0;

global.battle_log = [];
global.battle_log_buffer = [];

global.char_data = [];
global.char_index = [];
global.enemy_data = [];
global.enemy_index = [];
global.ability_data = [];
global.encounter_data = [];
global.item_data = [];
global.sorcery_data = [];
global.fae_data = [];
global.summon_data = [];

// Create and store the font
global.font = font_add_sprite_ext(spr_font, "ABCDEFGHIJKLMNOPQRSTUVWXYZ!?()abcdefghijklmnopqrstuvwxyz.@/:0123456789-_~#|,';\"&$%^+=<>[]", false, -2);


// Other initialization function calls
scr_field_sorcery_registry_init();

/// HELPER FUNCTIONS ///

function new_game() {
	// Called when a new game file is started
}

function new_game_plus() {
	// Called when a new game+ file is started	
}

function save_game(_slot) {
	// Function which saves the volitile game data to a file	
}

function load_game(_slot) {
	// Loads the game save file and returns the game to the saved state	
}

function load_player_data() {
	// Read the character JSON and load the data into memory
	var _charBuffer = buffer_load("chars.json");
	var _string = buffer_read(_charBuffer, buffer_string);
	buffer_delete(_charBuffer);
	
	var _data = json_parse(_string);
	global.char_data = variable_struct_get(_data, "Characters");
	global.char_index = buildIndex(global.char_data);
}

function load_enemy_data() {
	// Read the enemy data JSON and load the data into memory
	var _enemyBuffer = buffer_load("enemies.json");
	var _string = buffer_read(_enemyBuffer, buffer_string);
	buffer_delete(_enemyBuffer);
	
	var _data = json_parse(_string);
	
	var _enemies = variable_struct_get(_data, "enemies");
	var _bosses = variable_struct_get(_data, "bosses");
	
	global.enemy_data = array_concat(_enemies, _bosses);
	global.enemy_index = buildIndex(global.enemy_data);
}

load_ability_data(); // Load the ability data into memory, this overwirtes global.ability_data
load_sorcery_data();

function load_encounter_data() {
	// Read the encounter data JSON and load the data into memory
}

function load_faefolk_data() {
	// Read the Faefolk JSON and load the data into memory
}

function load_summon_data() {
	// Reads the summon JSON and loads the data into memory
}

function load_sorcery_data() {
	// Reads the magic JSON and loads the data into memory
	var _sorcBuffer = buffer_load("magic.json");
	var _string = buffer_read(_sorcBuffer, buffer_string);
	buffer_delete(_sorcBuffer);
	
	var _data = json_parse(_string);
	global.sorcery_data = variable_struct_get(_data, "Sorceries");
	global.sorcery_index = buildIndex(global.sorcery_data);
	show_debug_message("Successfully loaded Sorcery data! Showing "+string(array_length(global.sorcery_data))+" sorceries in memory!");
}