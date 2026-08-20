function loadEnemyData(){
	var _enemyBuffer = buffer_load("enemies.json");
	var _string = buffer_read(_enemyBuffer, buffer_string);
	buffer_delete(_enemyBuffer);
	
	var _data = json_parse(_string);
	
	var _enemies = variable_struct_get(_data, "enemies");
	var _bosses = variable_struct_get(_data, "bosses");
	
	global.enemy_data = array_concat(_enemies, _bosses);
	global.enemy_index = buildIndex(global.enemy_data);
	
	return 0;
}

function scr_char_get_stat(_type, _name, _stat) {
	if _type == "protag" {
		// Get the stats from the obj_party_controller
		var _temp = isInParty(_name);
		if _temp != false {
			if (_stat != "strong_foe") {
				return obj_party_controller._Party[_temp]._stat;
			} else {
				return false;	
			}
		} else {
			return undefined;	
		}
	} else if _type == "enemy" {
		var _names = struct_get_names(global.enemy_index);
		var _i = 0;
		if array_contains(_names, _name) {
			_i = struct_get(global.enemy_index, _name);
			return variable_struct_get(global.enemy_data[_i], _stat);
		} else {
			return undefined;	
		}
	}
}
function new_enemy(_name) constructor
{
	// Find the index of the item in the index struct
	var _names = struct_get_names(global.enemy_index);
	var _index = 0;
	if array_contains(_names, _name)
	{
		_index = struct_get(global.enemy_index, _name);
	}
	
	char_name = _name;
	actor_type = "enemy";
	
	char_hp_max = variable_struct_get(global.enemy_data[_index], "enemy_hp");
	char_hp_current = char_hp_max;
	char_vp_max = variable_struct_get(global.enemy_data[_index], "enemy_vp");
	char_vp_current = char_vp_max;
	
	statuses = {};
	
	char_level = 0;
	char_exp = 0;
	char_class = undefined;

	attack = variable_struct_get(global.enemy_data[_index], "enemy_attack");
	defense = variable_struct_get(global.enemy_data[_index], "enemy_defense");
	agility = variable_struct_get(global.enemy_data[_index], "enemy_agility");
	luck = variable_struct_get(global.enemy_data[_index], "enemy_luck");

	ele_earth_pow = variable_struct_get(global.enemy_data[_index], "enemy_ele_earth_pow");
	ele_earth_res = variable_struct_get(global.enemy_data[_index], "enemy_ele_earth_res");
	ele_fire_pow = variable_struct_get(global.enemy_data[_index], "enemy_ele_fire_pow");
	ele_fire_res = variable_struct_get(global.enemy_data[_index], "enemy_ele_fire_res");
	ele_water_pow = variable_struct_get(global.enemy_data[_index], "enemy_ele_water_pow");
	ele_water_res = variable_struct_get(global.enemy_data[_index], "enemy_ele_water_res");
	ele_wind_pow = variable_struct_get(global.enemy_data[_index], "enemy_ele_wind_pow");
	ele_wind_res = variable_struct_get(global.enemy_data[_index], "enemy_ele_wind_res");
	
	faefolk = variable_struct_get(global.enemy_data[_index], "enemy_faefolk");
	inventory = variable_struct_get(global.enemy_data[_index], "enemy_items");
	skills = variable_struct_get(global.enemy_data[_index], "enemy_skills");
	eq_helm = undefined;
	eq_shirt = undefined;
	eq_armor = undefined;
	eq_shield = undefined;
	eq_boots = undefined;
	eq_acc1 = undefined;
	eq_acc2 = undefined;
	eq_misc = undefined;
	eq_weapon = undefined;
	
	status_resist = variable_struct_get(global.enemy_data[_index], "status_resist");
	strong_foe = variable_struct_get(global.enemy_data[_index], "strong_foe");
	enemy_ai = variable_struct_get(global.enemy_data[_index], "enemy_ai");
	creature_type = variable_struct_get(global.enemy_data[_index], "creature_type");
	
	// Check to see if the enemy entity has a single sprite or a list of different sprites
	if variable_struct_exists(global.enemy_data[_index], "enemy_sprite") {
		standing_spr = asset_get_index(variable_struct_get(global.enemy_data[_index], "enemy_sprite"));
		attack_sprite1 = standing_spr;
		attack_sprite2 = standing_spr;
		hurt_sprite = standing_spr;
		cast_sprite = standing_spr;
		enemy_type = "regular";
	}
	else {
		standing_spr = asset_get_index(variable_struct_get(global.enemy_data[_index], "enemy_standing_sprite"));
		attack_sprite1 = asset_get_index(variable_struct_get(global.enemy_data[_index], "enemy_attack_sprite1"));
		attack_sprite2 = asset_get_index(variable_struct_get(global.enemy_data[_index], "enemy_attack_sprite2"));
		hurt_sprite = asset_get_index(variable_struct_get(global.enemy_data[_index], "enemy_hurt_sprite"));
		cast_sprite = asset_get_index(variable_struct_get(global.enemy_data[_index], "enemy_cast_sprite"));
		enemy_type = "boss";
	}
}

function add_enemy_to_buffer(_name) {
	// Adds an enemy to the next battle's enemy buffer
	// First, check to see if the name is in the enemy index
	var _names = struct_get_names(global.enemy_index);
	var _index = 0;
	
	if array_contains(_names, _name) {
		_index = struct_get(global.enemy_index, _name);
	}
	
	// Get the enemy data to send to the buffer
	var enemy_data = new new_enemy(_name);
	array_push(global.enemy_buffer, enemy_data);
}

function battle_transition(_x, _y) {
	// Pause the game
	if global.paused == false {
		global.paused = true;
	}
	
	// Spawn the battle transition object on the x,y coordinates
	instance_create_depth(_x, _y, -100, obj_battle_transition);
}

function attack_animation(_battleActor, _targetx, _targety) {
	_battleActor.sprite_index = _battleActor.attack_sprite;
	_battleActor._targetx = _targetx;
	_battleActor._targety = _targety;
	show_debug_message("Target x,y: "+string(_targetx)+","+string(_targety));
	var _dist = point_distance(_battleActor.x, _battleActor.y, _targetx, _targety);
	show_debug_message("Distance: "+string(_dist));
	
	var max_jump_height = 75;  //displacement in pixels
	var jump_time = 25;        //in frames
	
	_battleActor.hsp = _dist/jump_time;
	show_debug_message("hsp: "+string(_dist/jump_time));
	_battleActor.vsp = -10;
	show_debug_message("vsp: "+string(-8));
	
	//calculations
	var jump_to_peak_time = jump_time / 2;
	var jumpsp = max_jump_height / ( (jump_to_peak_time + 1) / 2);
	_battleActor.grav = jumpsp / jump_to_peak_time;
	show_debug_message("grav: "+string(jumpsp/jump_to_peak_time));
	
	_battleActor.attack = true;
	
	return 0;
}

function action_attack(_attackActor, _targetActor, _attacker, _defender) {
	// This will go through the whole routine of the attacker attacking the target, animation, damage calc, and message print
	// _attacker and _defender are the actual instantiated objects which contain the associated data
	
	// First up, write "[_attacker name] attacks!" to the battle log
	var attacker_name = getActorName(_attacker);
	write_to_battle_log(string(attacker_name)+" attacks!");
	
	// Then, attack animation
	attack_animation(_attackActor, _targetActor.x, _targetActor.y);
	
	// Then, damage calculations
	var damage_dealt = 0;
	var _attName = "";
	if _defender.actor_type == "enemy" {
		if _attacker.actor_type == "enemy" {
			// One enemy attacking another (due to confusion or something)
			damage_dealt = _attacker.attack - _defender.defense;
			_defender.enemy_hp -= damage_dealt;
			_attName = _attacker.enemy_name;
		}
		else if _attacker.actor_type == "protag" {
			// A party member attacking an enemy
			damage_dealt = _attacker.attack - _defender.defense;
			_defender.enemy_hp -= damage_dealt;
			_attName = _attacker.char_name;
		}
	}
	else if _defender.actor_type == "protag" {
		if _attacker.actor_type == "enemy" {
			// An enemy attacking a party member
			damage_dealt = _attacker.attack - _defender.defense;
			_defender.char_hp_current -= damage_dealt;
			_attName = _attacker.enemy_name;
		}
		else if _attacker.actor_type == "protag" {
			// A party member attacking another party member
			damage_dealt = _attacker.attack - _defender.defense;
			_defender.char_hp_current -= damage_dealt;
			_attName = _attacker.char_name;
		}
	}
	
	// Then, print the resulting message to the battle log
	write_to_battle_log(string(_attName)+" deals "+string(damage_dealt)+" damage!");
}

function battle_actor_hurt(_battleActor, _intensity) {
	// Controls how the attacked actor gets knocked back
	
	// Check to see what sprite to use for getting hurt, then switch to that
	_battleActor.sprite_index = _battleActor.hurt_sprite;
	_battleActor.image_index = 0;
	
	// Flash the sprite white
	_battleActor.sprite_flash_timer = 5;
	
	// Now get knocked back by the intensity
	_battleActor._targetx = _battleActor.x - _intensity;
	_battleActor._targety = _battleActor.y;
	
	_battleActor.hsp = _intensity/5;

	_battleActor.hurt = true;
}

function battle_actor_return(_actor) {
	// Moves the actor to its origin point
	_actor.x = _actor.xOrigin;
	_actor.y = _actor.yOrigin;
	_actor.hsp = 0;
	_actor.vsp = 0;
	_actor.jump = false;
	_actor.grav = 0;
	
	_actor.sprite_index = _actor.standing_sprite;
}

function battle_actors_return() {
	// Returns all actors to their default locations and resets their animations to standing default
	var allBuffer = array_concat(obj_battle_controller.enemy_actor_buffer, obj_battle_controller.protag_actor_buffer);
	var buffLen = array_length(allBuffer);
	var _actor = 0;
	
	for(var _i = 0; _i < buffLen; _i++) {
		_actor = allBuffer[_i];
		battle_actor_return(_actor);
	}
}

function write_to_battle_log(_text) {
	show_debug_message(_text);
	array_push(global.battle_log_buffer, _text);
	
	if instance_exists(obj_battle_log) == false {
		instance_create_depth(0,0,-100,obj_battle_log);
	}
}

function end_battle() {
	// This function cleans up the battle room and resets all the battle controller stuff
	show_debug_message("Running end_battle script!");
	instance_destroy(obj_battle_log);
	instance_destroy(obj_battle_actor);
	instance_destroy(obj_battle_protag);
	instance_destroy(obj_battle_enemy);
	instance_destroy(obj_menu_battle);
	instance_destroy(obj_menu_battle_status);
	global.player_battle = false;
	global.enemy_buffer = [];
	room = global.last_room;
	global.resetPlayer = true;
	global.paused = false;
	
	return 0;
}

function scr_make_battler(_name, _is_party, _slot_index) {
	var _slot = _is_party
		? obj_battle_controller.party_slots[_slot_index]
		: obj_battle_controller.enemy_slots[_slot_index];
	var _type = _is_party ? "protag" : "enemy";

	return {
		// identity
		name  : _name,
		is_party : _is_party,
		
		// floor position
		floor_x : _slot.fx,
		floor_z : _slot.fz,
		
		// screen position
		screen_x : 0,
		screen_y : 0,
		depth    : 0,
		
		// stats
		hp_current            : scr_char_get_stat(_type, _name, "char_hp_current"),
		hp_max                : scr_char_get_stat(_type, _name, "char_hp_max"),
		vp_current            : scr_char_get_stat(_type, _name, "char_vp_current"),
		vp_max                : scr_char_get_stat(_type, _name, "char_vp_max"),
		attack_orig           : scr_char_get_stat(_type, _name, "attack"),
		attack_current        : scr_char_get_stat(_type, _name, "attack"),
		defense_orig          : scr_char_get_stat(_type, _name, "defense"),
		defense_current       : scr_char_get_stat(_type, _name, "defense"),
		agility_orig          : scr_char_get_stat(_type, _name, "agility"),
		agility_current       : scr_char_get_stat(_type, _name, "agility"),
		luck_orig             : scr_char_get_stat(_type, _name, "luck"),
		luck_current          : scr_char_get_stat(_type, _name, "luck"),
		ele_power_earth_orig  : scr_char_get_stat(_type, _name, "ele_earth_pow"),
		ele_power_fire_orig   : scr_char_get_stat(_type, _name, "ele_fire_pow"),
		ele_power_water_orig  : scr_char_get_stat(_type, _name, "ele_water_pow"),
		ele_power_wind_orig   : scr_char_get_stat(_type, _name, "ele_wind_pow"),
		ele_resist_earth_orig : scr_char_get_stat(_type, _name, "ele_earth_res"),
		ele_resist_fire_orig  : scr_char_get_stat(_type, _name, "ele_fire_res"),
		ele_resist_water_orig : scr_char_get_stat(_type, _name, "ele_water_res"),
		ele_resist_wind_orig  : scr_char_get_stat(_type, _name, "ele_wind_res"),
		ele_power_earth       : scr_char_get_stat(_type, _name, "ele_earth_pow"),
		ele_power_fire        : scr_char_get_stat(_type, _name, "ele_fire_pow"),
		ele_power_water       : scr_char_get_stat(_type, _name, "ele_water_pow"),
		ele_power_wind        : scr_char_get_stat(_type, _name, "ele_wind_pow"),
		ele_resist_earth      : scr_char_get_stat(_type, _name, "ele_earth_res"),
		ele_resist_fire       : scr_char_get_stat(_type, _name, "ele_fire_res"),
		ele_resist_water      : scr_char_get_stat(_type, _name, "ele_water_res"),
		ele_resist_wind       : scr_char_get_stat(_type, _name, "ele_wind_res"),
		
		status_resist : scr_char_get_stat(_type, _name, "status_resist"),
		strong_foe : scr_char_get_stat(_type, _name, "strong_foe"),
		creature_type : scr_char_get_stat(_type, _name, "creature_type"),
		
		// Stat buffs/debuffs
		attack_stage: 0,
		defense_stage: 0,
		agility_stage: 0,
		luck_stage: 0,
		accuracy_stage: 0,
		evasion_stage: 0,
		ele_power_earth_stage: 0,
		ele_resist_earth_stage: 0,
		ele_power_fire_stage: 0,
		ele_resist_fire_stage: 0,
		ele_power_water_stage: 0,
		ele_resist_water_stage: 0,
		ele_power_wind_stage: 0,
		ele_resist_wind_stage: 0,
		
		// Whether or not the battler is alive
		alive      : true,
		
		// Sprite state
		sprite : scr_char_get_battle_sprite(_name),
		anim_state : "idle", // "idle", "attack", "cast", "hurt", "down"
		image_index: 0,
		image_speed: 0.15,
		
		//action queue for this battler's turn
		action: undefined
	};
}

function scr_battle_project_all() {
	var _all = array_concat(obj_battle_controller.party_battlers, obj_battle_controller.enemy_battlers);
	for (var _i = 0; _i < array_length(_all); _i++) {
		var _b = _all[_i];
		var _p = scr_Battle_Project(_b.floor_x, _b.floor_z);
		_b.screen_x = _p.x;
		_b.screen_y = _p.y;
		_b.depth = _p.depth;
	}
}

function scr_array_sort_depth(_arr) {
	var _n = array_length(_arr);
	for (var _i = 1; _i < _n; _i++) {
		var _key = _arr[_i];
		var _j = _i - 1;
		while (_j >= 0 && _arr[_j].depth < _key.depth) {
			_arr[_j + 1] = _arr[_j];
			_j--;
		}
		_arr[_j + 1] = _key;
	}
}

function battle_begin(_encounter_ID, _trigger_type) {
	// _trigger_type: "random" or "event"
	
	// Lock overworld player
	Player.interact_locked = true;
	Player.state = pState.INTERACT;
	
	// Stop overworld music, push battle track
	obj_audio_controller.bgm_push(bgm_battle, 0);
	obj_audio_controller.bgm_stinger(sting_battle_start);
	
	// Build party battlers from the current party, grabbing the first four
	obj_battle_controller.party_battlers = [];
	for (var _i = 0; _i < array_length(obj_party_controller._Party); _i++) {
		var _char = obj_party_controller._Party[_i];
		array_push(obj_battle_controller.party_battlers, scr_make_battler(_char, true, _i));
	}
	
	// Build the enemy battlers from the encounter data
	obj_battle_controller.enemy_battlers = [];
	var _enemies = scr_get_encounter_enemies(_encounter_ID);
	for (var _i = 0; _i < array_length(_enemies); _i++) {
		array_push(obj_battle_controller.enemy_battlers, scr_make_battler(_enemies[_i], false, _i));	
	}
	
	// Start floor at original angle
	obj_battle_controller.battle_angle = 0;
	
	// Build turn queue
	scr_build_turn_queue();
	
	// Transition to the battle room
	room_goto(rm_battle);
	obj_battle_controller.battle_state = eBattleState.ENTER;
	obj_battle_controller.last_state = eBattleState.ENTER;
}

function scr_battle_enter() {
	// Play the entry animation (e.g. party leaps into the fight and the camera transition opens)
	// When finished, start with the player turn
	obj_battle_controller.last_state = obj_battle_controller.battle_state;
	obj_battle_controller.battle_state = eBattleState.PLAYER_TURN;
}

function scr_battle_end() {
	// This is called when the battle ends when the battle is over
	// Check to make sure the state of the battle to see if the player won or lost
	var _state = obj_battle_controller.battle_state;
	if (_state == eBattleState.WIN) {
		// If WIN, play fanfare, give EXP and loot, then move to battle exit
		scr_battle_exit();
	} else if (_state == eBattleState.LOSE) {
		// If LOSE, fade out and move to the game over screen
	}
}

function scr_battle_exit() {
	// Restore the overworld state
	obj_audio_controller.bgm_pop(60);
	Player.interact_locked = false;
	Player.state = pState.IDLE;
	room_goto(global.last_room);
}

function scr_build_turn_queue() {
	// Called after the player inputs commands for the party
	// Builds the order of combat for this round
	var _mgr = obj_battle_controller;
	var _all = array_concat(_mgr.party_battlers, _mgr.enemy_battlers);
	
	// Sort by agility
	var _n = array_length(_all);
	for (var _i = 1; _i < _n; _i++) {
		var _key = _all[_i];
		var _j = _i - 1;
		while (_j >= 0 && _all[_j].agility < _key.agility) {
			_all[_j + 1] = _all[_j];
			_j--;
		}
		_all[_j + 1] = _key;
	}
	
	_mgr.turn_queue = _all;
}

function scr_next_turn() {
	// Called when the battle passes to the next turn
	// Performs clean-up, removes downed enemies from the battler list, then passes to player control
}

function scr_battle_player_turn(_protags) {
	// Called when the round starts, giving the player control to access the menu and make selections
	// When done, passes to the ACTION phase
	var _alive = _protags;
}

function scr_battle_enemy_turn(_enemies) {
	// Called when it's the enemy's turn to decide what to do
	// Depends on the AI that the enemies have
}

function scr_battle_tick_summon() {
	var _mgr = obj_battle_controller;
	if (_mgr.summon_current_action == undefined) {
		if (array_length(_mgr.summon_queue) == 0) {
			scr_summon_end();
			return;
		}
		_mgr.summon_current_action = array_shift(_mgr.summon_queue);
		if (struct_exists(_mgr.summon_current_action, "start")) {
			_mgr.summon_current_action.start();	
		}
	}
	
	var _done = _mgr.summon_current_action.tick();
	if (_done) {
		_mgr.summon_current_action = undefined;
	}
}

function scr_summon_end() {
	// Cinematic completely finished, so restore battle state
	var _mgr = obj_battle_controller;
	_mgr.summon_data_active = undefined;
	_mgr.summon_targets = [];
	
	// Check to see if the battle is over due to the summon's effects
	if (scr_battle_check_win()) {
		_mgr.battle_state = eBattleState.WIN;	
	} else if (scr_battle_check_lose()) {
		_mgr.battle_state = eBattleState.LOSE;	
	} else {
		scr_next_turn();	
	}
}

function scr_battle_tick_action() {
		
}

function scr_make_battle_action(_user, _ability_id, _targets, _damage_frame) {
	return {
		user: _user,
		ability_id: _ability_id,
		targets: _targets,
		damage_frame: _damage_frame
	};
}

function scr_execute_battle_action(_action) {
	// _action = struct generated from scr_make_battle_action
	
	var _queue = [
		cs_ability(_action.user, _action.ability_id, _action.targets, _action.damage_frame),
		cs_wait(15)
	];
	
	// Feed into the battle animation state
	obj_battle_controller.action_queue = _queue;
	obj_battle_controller.battle_state = eBattleState.ACTION;
}

function scr_battle_use_summon(_summon_id, _targets, _caster) {
	var _mgr = obj_battle_controller;
	_mgr.summon_data_active = global.summon_data[$ _summon_id];
	_mgr.summon_targets = _targets;
	
	_mgr.battle_state = eBattleState.SUMMON;
	
	// Freeze everything
	scr_battle_set_all_anim("idle", 0);
	
	// Build and play the summon queue
	_mgr.action_queue = scr_build_summon_queue(_mgr.summon_data_active, _mgr.summon_targets, _caster.hp_current);
}

function scr_build_summon_queue(_data, _targets, _caster_hp) {
	return [
	
		// -- Phase 1: Setup -------
		//  Rotate the battle floor so the attack lands and remove the party sprites
		cs_battle_rotate_to(0, 30),
		
		// Brief pause to let the summon appear
		cs_wait(20),
		
		// Play the animation
		cs_summon_anim(_data, _targets, _caster_hp),
		
		// Wait for the animation to end
		cs_wait(30),
		
		// Then, return to the battle
		cs_battle_rotate_to(obj_battle_controller.target_angle, 40),
		
		// Restore battler animations
		cs_battle_restore_anims(),
		
		// Small pause before the actors get hurt
		cs_wait(20)
	];	
}

function scr_summon_apply_damage(_data, _targets, _caster_hp) {
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		if (!_t.alive) continue;
		
		// Get the base damage
		var _base = _data.base_damage;
		var _dmg = floor(_base + (_caster_hp * _data.hp_mult));
		
		// Apply the elemental resistance
		var _final = scr_calculate_damage(_dmg, _data.element, _t);
		
		// If no damage is dealt, play the "tink" sound and animate the target to show they took no damage
		if _final == 0 {
			// No damage was dealt
			_t.anim_state = "tink";
			sfx_play(sfx_no_damage);
		} else {
			// Apply hurt animation and hit sound
			sfx_play(sfx_hit);
			_t.anim_state = "hit";
		}
		
		if (_t.hp <= 0) {
			_t.alive = false;
			_t.anim_state = "down";
		}
		
		// Show damage numbers
		scr_spawn_damage_number(_t.screen_x, _t.screen_y, _final);
	}
}

function scr_battler_recalc_stats(_battler) {
	// This function is called whenever stats would change in a battle
	// Set the stats to their original values, then recalculate the stat boosts / debuffs
	
}