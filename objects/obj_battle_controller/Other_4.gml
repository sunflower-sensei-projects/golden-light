if room == rm_battle
{
	// We just flipped to the battle screen
	global.player_battle = true;
	player_turn = true;
	enemy_turn = false;
	enemy_actor_buffer = [];
	protag_actor_buffer = [];
	global.enemy_index = 0;
	global.protag_index = 0;
	global.protag_buffer = [];
	global.battle_log_buffer = [];
	global.battle_log = [];
	instance_create_depth(0,0,-100,obj_menu_battle_status);
	instance_create_depth(0,0,-100,obj_menu_battle);
	
	x_viewport = camera_get_view_x(view_camera[0]);
	y_viewport = camera_get_view_y(view_camera[0]);
	
	// Create the enemy actor(s)
	var _enemy = 0;
	var _enemyData = 0;
	for(var e = 0; e < array_length(global.enemy_buffer); e += 1){
		show_debug_message("Enemy buffer: ");
		show_debug_message(string(global.enemy_buffer));
		_enemyData = global.enemy_buffer[e];
		_enemy = instance_create_depth(enemy_xpos+(e*25), enemy_ypos, 20, obj_battle_enemy);
		_enemy.xOrigin = enemy_xpos;
		_enemy.yOrigin = enemy_ypos;
		
		if _enemyData.enemy_type == "regular" {
			_enemy.standing_sprite = _enemyData.enemy_sprite;
			_enemy.attack_sprite = _enemyData.enemy_sprite;
			_enemy.attack_sprite_2 = _enemyData.enemy_sprite;
			_enemy.hurt_sprite = _enemyData.enemy_sprite;
			_enemy.cast_sprite = _enemyData.enemy_sprite;
		}
		else if _enemyData.enemy_type == "boss" {
			_enemy.standing_sprite = _enemyData.enemy_standing_sprite;
			_enemy.attack_sprite = _enemyData.enemy_attack_sprite1;
			_enemy.attack_sprite_2 = _enemyData.enemy_attack_sprite2;
			_enemy.hurt_sprite = _enemyData.enemy_hurt_sprite;
			_enemy.cast_sprite = _enemyData.enemy_cast_sprite;
		}
		else {
			_enemy.standing_sprite = spr_b_ERROR;
			_enemy.attack_sprite = spr_b_ERROR;
			_enemy.attack_sprite_2 = spr_b_ERROR;
			_enemy.hurt_sprite = spr_b_ERROR;
			_enemy.cast_sprite = spr_b_ERROR;
		}
		_enemy.sprite_index = _enemy.standing_sprite;
		
		array_push(enemy_actor_buffer, _enemy);
	}
	
	// Create the party member actor(s)
	var _protag = 0;
	var _protagData = 0;
	for(var p = 0; p < array_length(obj_party_controller._Party) and p <= 4; p += 1){
		_protagData = obj_party_controller._Party[p];
		array_push(global.protag_buffer, obj_party_controller._Party[p]);
		_protag = instance_create_depth(protag_xpos+(p*25), protag_ypos, 0, obj_battle_protag);
		_protag.xOrigin = protag_xpos;
		_protag.yOrigin = protag_ypos;
		array_push(protag_actor_buffer, _protag);
	}
}
else
{
	global.player_battle = false;
}