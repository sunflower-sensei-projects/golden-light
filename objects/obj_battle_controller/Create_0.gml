// Keep track of where the player is, in battle or in the field
global.player_battle = false;

// What background to use for the battle
global.battle_bg = spr_battlebg_test;

// Enemy Buffer
global.enemy_index = 0;
global.enemy_buffer = [];

// Protag Buffer
global.protag_index = 0;
global.protag_buffer = [];

// Battle Log
global.battle_log_buffer = [];
global.battle_log = [];

// Actor Buffers
enemy_actor_buffer = [];
protag_actor_buffer = [];

// Other variables
set_bg = false;

x_viewport = camera_get_view_x(view_camera[0]);
y_viewport = camera_get_view_y(view_camera[0]);

// Load the enemy data into memory
_check = loadEnemyData();
if _check == 0
{
	show_debug_message("Enemy data successfully loaded.");
}
else
{
	show_debug_message("Enemy data failed to load.");
}

// Floor transform
battle_angle = 0; // current rotation in degrees
target_angle = 0; // angle we're rotating to
floor_tilt   = 0; // vertical squash factor
floor_scale  = 0; // world units to pixels
battle_center_x = room_width / 2;
battle_center_y = room_width / 2 + 40;

// Rotation tweening
rotating        = false;
rotate_duration = 45; // frames for a full rotation step
rotate_timer    = 0;
rotate_from     = 0;

// Battle state
enum eBattleState {
	ENTER,         // Transition in from the overworld
	PLAYER_TURN,   // Phase where the player makes decisions and selects actions
	ENEMY_TURN,    // Brief phase after the player makes their decisions, enemies make theirs
	ACTION,        // This is the phase where battlers do their actions
	ANIMATION,     // Someone is playing an attack/spell/item animation, goes back to action
	SUMMON,        // Someone is using a summon, goes back to action
	ROTATE,        // Floor is rotating
	WIN,           // Player wins the battle, getting XP and loot
	LOSE,          // Player has lost, plays the game over screen or whatever
	EXIT           // Transition back to the overworld
}
battle_state = eBattleState.ENTER;
last_state = undefined;
action_queue = [];

// Battle Menu state
enum eMenuStage {
	ROOT,    // Attack/Sorcery/Faefolk/Summon/Item/Defend/Party
	SUB,     // List of Sorceries, Faefolk, Items, or Summons
	TARGET   // Selecting target(s)
}
command_queue = [];     // Once slot per party_battlers index
command_char_index = 0; // whose turn it is in the command phase

// Combatant lists
party_battlers = [];  // array of protag battler structs
enemy_battlers = [];  // array of enemy battler structs

// Turn queue
turn_count = 0;
turn_queue = [];
active_battler = undefined;

// Floor positions
party_slots = [
	{ fx: -120, fz:  0  },
	{ fx: -120, fz:  40 },
	{ fx: -160, fz:  20 },
	{ fx: -160, fz: -20 }
];
enemy_slots = [
	{ fx: 120, fz:  0 },
	{ fx: 120, fz:  40 },
	{ fx: 160, fz:  20 },
	{ fx: 160, fz: -20 }
];

// Summon info
summon_current_action = undefined;
summon_data_active    = undefined;
summon_targets        = [];

/// HELPER FUNCTIONS ///
function scr_battle_rotate_to(_angle, _duration) {
	if (rotating) return; // ignore if already rotating
	rotate_from = battle_angle;
	target_angle = _angle;
	rotate_duration = _duration ?? 45;
	rotate_timer = 0;
	rotating = true;
	battle_state = eBattleState.ROTATE;
}

function scr_battle_rotate_delta(_delta, _duration) {
	// Rotate by a relative angle
	scr_battle_rotate_to(battle_angle + _delta, _duration);	
}

function scr_battle_tick_rotation() {
	// Called every step while in the ROTATE state
	rotate_timer++;
	var _t = rotate_timer / rotate_duration;
	
	// Ease in and out for a satisfying motion
	var _ease = _t > 0.5
		? 4 * _t * _t * _t
		: 1 - power(-2 * _t + 2, 3) / 2;
	
	battle_angle = lerp(rotate_from, target_angle, _ease);
	
	if (rotate_timer >= rotate_duration) {
		battle_angle = target_angle;
		rotating = false;
		// Return to previous state
		battle_state = last_state;
	}
}