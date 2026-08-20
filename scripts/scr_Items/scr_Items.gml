function buildIndex(_structArray)
{
	var _index = {};
	var _len = array_length(_structArray);
	var _name = "";
	
	for (var _i = 0; _i < _len; _i++)
	{
		_name = variable_struct_get(_structArray[_i], "name")
		struct_set(_index, _structArray[_i].name, _i);
	}
	
	return _index;
}

function loadItemData(){
	var _itemBuffer = buffer_load("items.json");
	var _string = buffer_read(_itemBuffer, buffer_string);
	buffer_delete(_itemBuffer);
	
	var _data = json_parse(_string);
	
	var _items = variable_struct_get(_data, "Items");
	var _weapons = variable_struct_get(_data, "Weapons");
	var _armors = variable_struct_get(_data, "Armor");
	var _helms = variable_struct_get(_data, "Helms");
	var _shields = variable_struct_get(_data, "Shields");
	var _shirts = variable_struct_get(_data, "Shirts");
	var _boots = variable_struct_get(_data, "Boots");
	var _rings = variable_struct_get(_data, "Rings");
	var _misc_eqs = variable_struct_get(_data, "Misc");
	
	global.item_data = array_concat(_items, _weapons, _armors, _helms, _shields, _shirts, _boots, _rings, _misc_eqs);
	global.item_index = buildIndex(global.item_data);
	
	return 0;
}

function getItemSprite(_isItem){
	show_debug_message("Starting getItemSprite script");
	if _isItem != ""
	{
		// Check to make sure the item is even in the index
		var _names = struct_get_names(global.item_index);
		show_debug_message("List of names present in the item_index: "+string(_names));
		if array_contains(_names, _isItem)
		{
			// Now look for it
			var _index = struct_get(global.item_index, _isItem);
			// Get the sprite_index value from the correct element
			var _sprite = asset_get_index(struct_get(global.item_data[_index], "item_sprite"));
			show_debug_message("Item '"+string(_isItem)+"' is present in the list. Returning '"+string(_sprite)+"'");
			return _sprite;
		}
		else
		{
			show_debug_message("Item '"+string(_isItem)+"' is not present in _names, returning 0");
			return 0;
		}
	}
	else
	{
		show_debug_message("_isItem is equal to '', returning 0");
		return 0;
	}
}

function getItemDesc(_isItem){
	if _isItem != ""
	{
		var _names = struct_get_names(global.item_index);
		if array_contains(_names, _isItem)
		{
			var _index = struct_get(global.item_index, _isItem);
			var _desc = struct_get(global.item_data[_index], "item_desc");
			return _desc
		}
		else
		{
			return "";
		}
	}
	else
	{
		return "";
	}
}

function new_item(_name) constructor
{
	// Find the index of the item in the index struct
	var _names = struct_get_names(global.item_index);
	var _index = 0;
	if array_contains(_names, _name)
	{
		_index = struct_get(global.item_index, _name);
	}
	item_name = variable_struct_get(global.item_data[_index], "name");
	item_type = variable_struct_get(global.item_data[_index], "item_type");
	item_sprite = asset_get_index(variable_struct_get(global.item_data[_index], "item_sprite"));
	item_desc = variable_struct_get(global.item_data[_index], "item_desc");
	item_value = variable_struct_get(global.item_data[_index], "item_value");
	item_use_loc = "none";
	item_equipped = false;
	item_can_drop = true;
	
	// Item types are: "consume", "weapon", "armor", "helm", "shield", "shirt", "boots", "ring", "misc", and "key"
	if item_type == "consume"
	{
		item_target = variable_struct_get(global.item_data[_index], "item_target");
		item_use_loc = variable_struct_get(global.item_data[_index], "item_use_loc");
		item_restore_hp = variable_struct_get(global.item_data[_index], "item_restore_hp");
		item_status_remove = variable_struct_get(global.item_data[_index], "item_status_remove");
		item_status_add = variable_struct_get(global.item_data[_index], "item_status_add");
		item_restore_vp = variable_struct_get(global.item_data[_index], "item_restore_vp")
		item_amt_held = 1;
	}
	else if item_type == "weapon"
	{
		weap_attack = variable_struct_get(global.item_data[_index], "weap_attack");
		weap_type = variable_struct_get(global.item_data[_index], "weapon_type");
		weap_defense = variable_struct_get(global.item_data[_index], "weap_defense");
		weap_agility = variable_struct_get(global.item_data[_index], "weap_agility");
		weap_luck = variable_struct_get(global.item_data[_index], "weap_luck");
		weap_ele_affinity = variable_struct_get(global.item_data[_index], "weap_ele_affinity");
		weap_ele_power = variable_struct_get(global.item_data[_index], "weap_ele_power");
		weap_unleash = variable_struct_get(global.item_data[_index], "weap_unleash");
		weap_unleash_art = variable_struct_get(global.item_data[_index], "weap_unleash_art");
		weap_unleash_rate = variable_struct_get(global.item_data[_index], "weap_unleash_rate");
		weap_unleash_damage_base = variable_struct_get(global.item_data[_index], "weap_unleash_damage_base");
		weap_unleash_damage_mult = variable_struct_get(global.item_data[_index], "weap_unleash_damage_mult");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "armor"
	{
		armor_type = variable_struct_get(global.item_data[_index], "armor_type");
		eq_hp_bonus = variable_struct_get(global.item_data[_index], "eq_hp_bonus");
		eq_vp_bonus = variable_struct_get(global.item_data[_index], "eq_vp_bonus");
		eq_hp_regen = variable_struct_get(global.item_data[_index], "eq_hp_regen");
		eq_vp_regen = variable_struct_get(global.item_data[_index], "eq_vp_regen");
		eq_att_bonus = variable_struct_get(global.item_data[_index], "eq_att_bonus");
		eq_def_bonus = variable_struct_get(global.item_data[_index], "eq_def_bonus");
		eq_agi_bonus = variable_struct_get(global.item_data[_index], "eq_agi_bonus");
		eq_luck_bonus = variable_struct_get(global.item_data[_index], "eq_luck_bonus");
		eq_ele_earth_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_pow_bonus");
		eq_ele_fire_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_pow_bonus");
		eq_ele_water_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_pow_bonus");
		eq_ele_wind_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_pow_bonus");
		eq_ele_earth_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_res_bonus");
		eq_ele_fire_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_res_bonus");
		eq_ele_water_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_res_bonus");
		eq_ele_wind_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_res_bonus");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "helm"
	{
		armor_type = variable_struct_get(global.item_data[_index], "armor_type");
		eq_hp_bonus = variable_struct_get(global.item_data[_index], "eq_hp_bonus");
		eq_vp_bonus = variable_struct_get(global.item_data[_index], "eq_vp_bonus");
		eq_hp_regen = variable_struct_get(global.item_data[_index], "eq_hp_regen");
		eq_vp_regen = variable_struct_get(global.item_data[_index], "eq_vp_regen");
		eq_att_bonus = variable_struct_get(global.item_data[_index], "eq_att_bonus");
		eq_def_bonus = variable_struct_get(global.item_data[_index], "eq_def_bonus");
		eq_agi_bonus = variable_struct_get(global.item_data[_index], "eq_agi_bonus");
		eq_luck_bonus = variable_struct_get(global.item_data[_index], "eq_luck_bonus");
		eq_ele_earth_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_pow_bonus");
		eq_ele_fire_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_pow_bonus");
		eq_ele_water_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_pow_bonus");
		eq_ele_wind_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_pow_bonus");
		eq_ele_earth_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_res_bonus");
		eq_ele_fire_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_res_bonus");
		eq_ele_water_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_res_bonus");
		eq_ele_wind_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_res_bonus");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "shield"
	{
		armor_type = variable_struct_get(global.item_data[_index], "armor_type");
		eq_hp_bonus = variable_struct_get(global.item_data[_index], "eq_hp_bonus");
		eq_vp_bonus = variable_struct_get(global.item_data[_index], "eq_vp_bonus");
		eq_hp_regen = variable_struct_get(global.item_data[_index], "eq_hp_regen");
		eq_vp_regen = variable_struct_get(global.item_data[_index], "eq_vp_regen");
		eq_att_bonus = variable_struct_get(global.item_data[_index], "eq_att_bonus");
		eq_def_bonus = variable_struct_get(global.item_data[_index], "eq_def_bonus");
		eq_agi_bonus = variable_struct_get(global.item_data[_index], "eq_agi_bonus");
		eq_luck_bonus = variable_struct_get(global.item_data[_index], "eq_luck_bonus");
		eq_ele_earth_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_pow_bonus");
		eq_ele_fire_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_pow_bonus");
		eq_ele_water_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_pow_bonus");
		eq_ele_wind_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_pow_bonus");
		eq_ele_earth_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_res_bonus");
		eq_ele_fire_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_res_bonus");
		eq_ele_water_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_res_bonus");
		eq_ele_wind_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_res_bonus");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "shirt"
	{
		eq_hp_bonus = variable_struct_get(global.item_data[_index], "eq_hp_bonus");
		eq_vp_bonus = variable_struct_get(global.item_data[_index], "eq_vp_bonus");
		eq_hp_regen = variable_struct_get(global.item_data[_index], "eq_hp_regen");
		eq_vp_regen = variable_struct_get(global.item_data[_index], "eq_vp_regen");
		eq_att_bonus = variable_struct_get(global.item_data[_index], "eq_att_bonus");
		eq_def_bonus = variable_struct_get(global.item_data[_index], "eq_def_bonus");
		eq_agi_bonus = variable_struct_get(global.item_data[_index], "eq_agi_bonus");
		eq_luck_bonus = variable_struct_get(global.item_data[_index], "eq_luck_bonus");
		eq_ele_earth_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_pow_bonus");
		eq_ele_fire_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_pow_bonus");
		eq_ele_water_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_pow_bonus");
		eq_ele_wind_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_pow_bonus");
		eq_ele_earth_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_res_bonus");
		eq_ele_fire_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_res_bonus");
		eq_ele_water_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_res_bonus");
		eq_ele_wind_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_res_bonus");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "boots"
	{
		armor_type = variable_struct_get(global.item_data[_index], "armor_type");
		eq_hp_bonus = variable_struct_get(global.item_data[_index], "eq_hp_bonus");
		eq_vp_bonus = variable_struct_get(global.item_data[_index], "eq_vp_bonus");
		eq_hp_regen = variable_struct_get(global.item_data[_index], "eq_hp_regen");
		eq_vp_regen = variable_struct_get(global.item_data[_index], "eq_vp_regen");
		eq_att_bonus = variable_struct_get(global.item_data[_index], "eq_att_bonus");
		eq_def_bonus = variable_struct_get(global.item_data[_index], "eq_def_bonus");
		eq_agi_bonus = variable_struct_get(global.item_data[_index], "eq_agi_bonus");
		eq_luck_bonus = variable_struct_get(global.item_data[_index], "eq_luck_bonus");
		eq_ele_earth_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_pow_bonus");
		eq_ele_fire_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_pow_bonus");
		eq_ele_water_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_pow_bonus");
		eq_ele_wind_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_pow_bonus");
		eq_ele_earth_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_res_bonus");
		eq_ele_fire_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_res_bonus");
		eq_ele_water_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_res_bonus");
		eq_ele_wind_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_res_bonus");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "ring"
	{
		eq_hp_bonus = variable_struct_get(global.item_data[_index], "eq_hp_bonus");
		eq_vp_bonus = variable_struct_get(global.item_data[_index], "eq_vp_bonus");
		eq_hp_regen = variable_struct_get(global.item_data[_index], "eq_hp_regen");
		eq_vp_regen = variable_struct_get(global.item_data[_index], "eq_vp_regen");
		eq_att_bonus = variable_struct_get(global.item_data[_index], "eq_att_bonus");
		eq_def_bonus = variable_struct_get(global.item_data[_index], "eq_def_bonus");
		eq_agi_bonus = variable_struct_get(global.item_data[_index], "eq_agi_bonus");
		eq_luck_bonus = variable_struct_get(global.item_data[_index], "eq_luck_bonus");
		eq_ele_earth_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_pow_bonus");
		eq_ele_fire_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_pow_bonus");
		eq_ele_water_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_pow_bonus");
		eq_ele_wind_pow_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_pow_bonus");
		eq_ele_earth_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_earth_res_bonus");
		eq_ele_fire_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_fire_res_bonus");
		eq_ele_water_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_water_res_bonus");
		eq_ele_wind_res_bonus = variable_struct_get(global.item_data[_index], "eq_ele_wind_res_bonus");
		item_use_target = variable_struct_get(global.item_data[_index], "eq_use_target");
		item_use_loc = variable_struct_get(global.item_data[_index], "eq_use_loc");
		item_use_restore_hp = variable_struct_get(global.item_data[_index], "eq_use_restore_hp");
		item_use_restore_vp = variable_struct_get(global.item_data[_index], "eq_use_restore_vp");
		item_use_status_remove = variable_struct_get(global.item_data[_index], "eq_use_status_remove");
		item_use_status_add = variable_struct_get(global.item_data[_index], "eq_use_status_add");
		item_can_drop = variable_struct_get(global.item_data[_index], "item_can_drop");
	}
	else if item_type == "misc"
	{
		
	}
	else if item_type == "key"
	{
		
	}
}

function canUseItem(_item){
	if global.player_battle == true
	{
		if _item.item_use_loc == "battle" or _item.item_use_loc == "both"
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		if _item.item_use_loc == "field" or _item.item_use_loc == "both"
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}

function canEquipItem(_item){
	if _item.item_type == "consume" or _item.item_type == "key"
	{
		return false;
	}
	else
	{
		return true;
	}
}

function canDropItem(_item) {
	return _item.item_can_drop;
}

function getItemType(_itemName) {
	if _itemName != ""
	{
		var _names = struct_get_names(global.item_index);
		if array_contains(_names, _itemName)
		{
			var _index = struct_get(global.item_index, _itemName);
			var _type = struct_get(global.item_data[_index], "item_type");
			return _type;
		}
		else
		{
			return "";
		}
	}
	else
	{
		return "";
	}
}

function buildInventory(_item_name_list) {
	// Takes an array of item name strings and converts them to an array of item objects
	if (array_length(_item_name_list) == 0) return [];
	
	var _item_list = [];
	var _new_item = undefined;
	
	for (var _i = 0; _i < array_length(_item_name_list); _i++) {
		_new_item = new new_item(_item_name_list[_i]);
		array_push(_item_list, _new_item);
	}
	
	return _item_list;
}