function loadCharData(){
	var _charBuffer = buffer_load("chars.json");
	var _string = buffer_read(_charBuffer, buffer_string);
	buffer_delete(_charBuffer);
	
	var _data = json_parse(_string);
	global.char_data = variable_struct_get(_data, "Characters");
	global.char_index = buildIndex(global.char_data);
	
	return 0;
}

function new_character(_name) constructor
{
	// Find the index of the character in the index struct
	var _names = struct_get_names(global.char_index);
	var _index = 0;
	if array_contains(_names, _name)
	{
		_index = struct_get(global.char_index, _name);
	}
	char_name = variable_struct_get(global.char_data[_index], "name");
	actor_type = "protag";
	char_hp_max = variable_struct_get(global.char_data[_index], "char_hp_max");
	char_hp_current = char_hp_max;
	char_vp_max = variable_struct_get(global.char_data[_index], "char_vp_max");
	char_vp_current = char_vp_max;
	char_level = variable_struct_get(global.char_data[_index], "char_level");
	char_exp = 0;
	char_class = variable_struct_get(global.char_data[_index], "char_class");
	statuses = [];
	status_resist = {};
	attack = variable_struct_get(global.char_data[_index], "char_attack");
	defense = variable_struct_get(global.char_data[_index], "char_defense");
	agility = variable_struct_get(global.char_data[_index], "char_agility");
	luck = variable_struct_get(global.char_data[_index], "char_luck");
	ele_earth_pow = variable_struct_get(global.char_data[_index], "ele_power_earth");
	ele_fire_pow = variable_struct_get(global.char_data[_index], "ele_power_fire");
	ele_water_pow = variable_struct_get(global.char_data[_index], "ele_power_water");
	ele_wind_pow = variable_struct_get(global.char_data[_index], "ele_power_wind");
	ele_earth_res = variable_struct_get(global.char_data[_index], "ele_resist_earth");
	ele_fire_res = variable_struct_get(global.char_data[_index], "ele_resist_fire");
	ele_water_res = variable_struct_get(global.char_data[_index], "ele_resist_water");
	ele_wind_res = variable_struct_get(global.char_data[_index], "ele_resist_wind");
	char_feyfolk = variable_struct_get(global.char_data[_index], "char_starting_feyfolk");
	var _sorcs = variable_struct_get(global.char_data[_index], "char_starting_sorceries");
	char_sorceries = names_to_structs(_sorcs, global.sorcery_data, global.sorcery_index);
	var _inv = variable_struct_get(global.char_data[_index], "char_starting_inventory");
	inventory = buildInventory(_inv);
	var _helm = variable_struct_get(global.char_data[_index], "eq_helm");
	if (_helm != "") {
		eq_helm = new new_item(_helm);
	} else {
		eq_helm = undefined;
	}
	var _shirt = variable_struct_get(global.char_data[_index], "eq_shirt");
	if (_shirt != "") {
		eq_shirt = new new_item(_shirt);
	} else {
		eq_shirt = undefined;
	}
	var _armor = variable_struct_get(global.char_data[_index], "eq_armor");
	if (_armor != "") {
		eq_armor = new new_item(_armor);
	} else {
		eq_armor = undefined;	
	}
	var _shield = variable_struct_get(global.char_data[_index], "eq_shield");
	if (_shield != "") {
		eq_shield = new new_item(_shield);
	} else {
		eq_shield = undefined;
	}
	var _boots = variable_struct_get(global.char_data[_index], "eq_boots");
	if (_boots != "") {
		eq_boots = new new_item(_boots);
	} else {
		eq_boots = undefined;
	}
	var _acc1 = variable_struct_get(global.char_data[_index], "eq_acc1");
	if (_acc1 != "") {
		eq_acc1 = new new_item(_acc1);
	} else {
		eq_acc1 = undefined;
	}
	var _acc2 = variable_struct_get(global.char_data[_index], "eq_acc2");
	if (_acc2 != "") {
		eq_acc2 = new new_item(_acc2);
	} else {
		eq_acc2 = undefined;	
	}
	var _misc = variable_struct_get(global.char_data[_index], "eq_misc");
	eq_misc = names_to_structs(_misc, global.item_data, global.item_index);
	var _weap = variable_struct_get(global.char_data[_index], "eq_weapon");
	if (_weap != "") {
		eq_weapon = new new_item(_weap);
	} else {
		eq_weapon = undefined;	
	}
	stand_spr = asset_get_index(variable_struct_get(global.char_data[_index], "char_sprite"));
	creature_type = "human";
}

function addProtagToParty(_protagName) {
	// Add the named protagonist character to the party registry
	_protagData = new new_character(_protagName);
	array_push(obj_party_controller._Party, _protagData);
	
	// Party menu unlocks once the roster reaches 5 or more members -
	// checked here since this is the single place any member actually
	// joins, regardless of which story beat triggered it.
	if (array_length(obj_party_controller._Party) >= 5) {
		scr_menu_unlock("party");
	}
	
	return 0;
}

function removeProtagFromParty(_protagName) {
	// Remove the named protagonist character from the party array
	for (var _i = 0; _i < array_length(_Party); _i++) {
		if (_Party[_i].char_name == _protagName) {
			array_delete(_Party, _i, 1);
			break;
		}
	}
	scr_Party_Update_Leader();
}

function getProtagData(_protagName) {
	for (var _i = 0; _i < array_length(_Party); _i++) {
		if (_Party[_i].char_name == _protagName) {
			return _Party[_i]	
		}
	}
	
	return undefined;
}

function moveProtag(_protagName, _newSlot) {
	var _temp = getProtagData(_protagName);
	if (_temp == undefined) return;
	removeProtagFromParty(_protagName);
	array_insert(_Party, _newSlot, _temp);
	scr_Party_Update_Leader();
}

function scr_Party_Set_Leader(_protagName) {
	var _temp = getProtagData(_protagName);
	if (_temp == undefined) return;
	removeProtagFromParty(_protagName);
	array_insert(_Party, 0, _temp);
	scr_Party_Update_Leader();
}

function scr_Party_Update_Leader() {
	if (instance_exists(Player)) {
		with (Player) scr_Player_Refresh_Sprites();	
	}
}

function scr_Leader_Sprites() {
	var _mgr = obj_party_controller;
	if (array_length(_mgr._Party) == 0) return undefined;
	var _leader = _mgr._Party[0];
	return struct_get(_mgr.char_sprites, _leader.char_name);
}

function isInParty(_name) {
	var _mgr = obj_party_controller;
	for (var _i = 0; _i < array_length(_mgr._Party); _i++) {
		if (_mgr._Party[_i].char_name == _name) {
			return _i;
		}
	return false;
	}
}