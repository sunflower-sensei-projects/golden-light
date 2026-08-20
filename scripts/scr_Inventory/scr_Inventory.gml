function addItem(_CharID, _itemName, _amt){
	show_debug_message("Starting addItem script.");
	var _len = array_length(global.char_invs[_CharID]);
	if _len < global.item_max
	{
		if inInventory(_CharID, _itemName) == true and getItemType(_itemName) == "consume" {
			for ( var _i = 0; _i < array_length(global.char_invs[_CharID]); _i++ )
			{
				if global.char_invs[_CharID][_i].item_name == _itemName
				{
					global.char_invs[_CharID][_i].item_amt_held += _amt;
					break;
				}
			}
			return 0;
		}
		else {
			var _item = pointer_null;
			for ( var _i = 0; _i < _amt; _i++ ) {
				_item = new new_item(_itemName);
				array_push(global.char_invs[_CharID], _item);
				show_debug_message("Successfully added "+string(_itemName)+" to inventory");
			}
			return 0;
		}
	}
	else
	{
		return -1;
	}
}

function addItemParty(_PartyInvArray, _itemName, _amt){
	show_debug_message("Starting addItemParty script.");
	var _partyLen = array_length(_PartyInvArray);
	var _invLen = 0;
	var _check = 0;
	for ( var _i = 0; _i < _partyLen; _i++ )
	{
		show_debug_message("Party index: "+string(_i));
		_invLen = array_length(_PartyInvArray[_i]);
		show_debug_message("Inventory length: "+string(_invLen));
		if _invLen < global.item_max
		{
			_check = addItem(_i, _itemName, _amt);
			if _check == 0
			{
				show_debug_message("Successfully added "+string(_amt)+" "+string(_itemName)+" to "+string(obj_party_controller._Party[_i].char_name)+"'s inventory.");
				show_debug_message(string(obj_party_controller._Party[_i].char_name)+" has "+string(getItemAmount(_i, _itemName))+" "+string(_itemName)+"(s).")
				return 0;
			}
		}
		else
		{
			show_debug_message(obj_party_controller._Party[_i]+"'s inventory is full.");
		}
	}
	show_debug_message("Failed to give "+_itemName+" to party");
	return -1
}

function addCoins(_amt){
	global.coins += _amt;
	return global.coins;
}

function newInventory(){
	var new_inv = [];
	for (var _i = 0; _i < global.item_max; _i++)
	{
		new_inv[_i] = 0;
	}
	array_push(global.char_invs, new_inv);
	
	return 0;
}

function swapInventory(_CharID1, _CharID2){
	var _temp = [];
	_temp = global.char_invs[_CharID1];
	global.char_invs[_CharID1] = global.char_invs[_CharID2];
	global.char_invs[_CharID2] = _temp;
	
	return 0;
}

function delInventory(_CharID){
	if array_length(global.char_invs) > _CharID
	{
		array_delete(global.char_invs, _CharID, 1);
		return 0;
	}
	else
	{
		return -1;
	}
}

function inInventory(_CharID, _itemName){
	if array_length(global.char_invs[_CharID]) > 0
	{
		for ( var _i = 0; _i < array_length(global.char_invs[_CharID]); _i++ )
		{
			if global.char_invs[_CharID][_i].item_name == _itemName
			{
				return true;
			}
		}
		return false;
	}
	else
	{
		return false;
	}
}

function getItemAmount(_i, _itemName) {
	var _Inv = global.char_invs[_i];
	var _amt = 0;
	for (var _j = 0; _j < array_length(_Inv); _j++) {
		if _Inv[_j].item_name == _itemName {
			if _Inv[_j].item_type == "consume" {
				_amt += _Inv[_j].item_amt_held;
			}
			else {
				_amt += 1;
			}
		}
	}
	return _amt;
}

function equipItem(_CharID, _ItemID){
	if array_length(obj_party_controller._Party) >= _CharID
	{
		// Grab the character data from the party array
		_Char = obj_party_controller._Party[_CharID];
		// Grab the item object from the character's inventory
		_Item = global.char_invs[_CharID][_ItemID];
		
		// Unquip the item in the same slot, if one exists
		if _Item.item_type == "weapon" {
			if _Char.eq_weapon != "" {
				_Char.eq_weapon.item_equipped = false;
				
				_Char.attack -= _Char.eq_weapon.weap_attack;
				_Char.defense -= _Char.eq_weapon.weap_defense;
				_Char.agility -= _Char.eq_weapon.weap_agility;
				_Char.luck -= _Char.eq_weapon.weap_luck;
				
				_Char.eq_weapon = _Item;
				_Char.eq_weapon.item_equipped = true;
				
				_Char.attack += _Char.eq_weapon.weap_attack;
				_Char.defense += _Char.eq_weapon.weap_defense;
				_Char.agility += _Char.eq_weapon.weap_agility;
				_Char.luck += _Char.eq_weapon.weap_luck;
			}
			else
			{
				_Char.eq_weapon = _Item;
				_Char.eq_weapon.item_equipped = true;
				
				_Char.attack += _Char.eq_weapon.weap_attack;
				_Char.defense += _Char.eq_weapon.weap_defense;
				_Char.agility += _Char.eq_weapon.weap_agility;
				_Char.luck += _Char.eq_weapon.weap_luck;
			}
		}
		else if _Item.item_type == "armor" {
			if _Char.eq_armor != "" {
				_Char.eq_armor.item_equipped = false;
				
				var _eq = _Char.eq_armor;
				
				_Char.char_hp_max -= _eq.eq_hp_bonus;
				_Char.char_vp_max -= _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
				
				_Char.eq_armor = _Item;
				_Char.eq_armor.item_equipped = true;
				
			}
			else
			{
				_Char.eq_armor = _Item;
				_Char.eq_armor.item_equipped = true;
				
				var _eq = _Char.eq_armor;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "helm" {
			if _Char.eq_helm != "" {
				_Char.eq_helm.item_equipped = false;
				
				var _eq = _Char.eq_helm;
				
				_Char.char_hp_max -= _eq.eq_hp_bonus;
				_Char.char_vp_max -= _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
				
				_Char.eq_helm = _Item;
				_Char.eq_helm.item_equipped = true;
				
			}
			else
			{
				_Char.eq_helm = _Item;
				_Char.eq_helm.item_equipped = true;
				
				var _eq = _Char.eq_helm;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "shield" {
			if _Char.eq_shield != "" {
				_Char.eq_shield.item_equipped = false;
				
				var _uneq = _Char.eq_shield;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack += _uneq.eq_att_bonus;
				_Char.defense += _uneq.eq_def_bonus;
				_Char.agility += _uneq.eq_agi_bonus;
				_Char.luck += _uneq.eq_luck_bonus;
				_Char.ele_earth_pow += _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _uneq.eq_ele_wind_res_bonus;
				
				_Char.eq_shield = _Item;
				_Char.eq_shield.item_equipped = true;
				
				var _eq = _Char.eq_shield;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
			else
			{
				_Char.eq_shield = _Item;
				_Char.eq_shield.item_equipped = true;
				
				var _eq = _Char.eq_shield;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "shirt" {
			if _Char.eq_shirt != "" {
				_Char.eq_shirt.item_equipped = false;
				
				var _uneq = _Char.eq_shirt;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack += _uneq.eq_att_bonus;
				_Char.defense += _uneq.eq_def_bonus;
				_Char.agility += _uneq.eq_agi_bonus;
				_Char.luck += _uneq.eq_luck_bonus;
				_Char.ele_earth_pow += _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _uneq.eq_ele_wind_res_bonus;
				
				_Char.eq_shirt = _Item;
				_Char.eq_shirt.item_equipped = true;
				
				var _eq = _Char.eq_shirt;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
			else
			{
				_Char.eq_shirt = _Item;
				_Char.eq_shirt.item_equipped = true;
				
				var _eq = _Char.eq_shirt;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "boots" {
			if _Char.eq_boots != "" {
				_Char.eq_boots.item_equipped = false;
				
				var _uneq = _Char.eq_boots;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack += _uneq.eq_att_bonus;
				_Char.defense += _uneq.eq_def_bonus;
				_Char.agility += _uneq.eq_agi_bonus;
				_Char.luck += _uneq.eq_luck_bonus;
				_Char.ele_earth_pow += _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _uneq.eq_ele_wind_res_bonus;
				
				_Char.eq_boots = _Item;
				_Char.eq_boots.item_equipped = true;
				
				var _eq = _Char.eq_boots;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
			else
			{
				_Char.eq_boots = _Item;
				_Char.eq_boots.item_equipped = true;
				
				var _eq = _Char.eq_boots;
				
				_Char.char_hp_max += _eq.eq_hp_bonus;
				_Char.char_vp_max += _eq.eq_vp_bonus;
				_Char.attack += _eq.eq_att_bonus;
				_Char.defense += _eq.eq_def_bonus;
				_Char.agility += _eq.eq_agi_bonus;
				_Char.luck += _eq.eq_luck_bonus;
				_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "ring" {
			if _Char.eq_acc1 != "" and _Char.eq_acc2 != "" {
				_Char.eq_acc1.item_equipped = false;
				
				var _uneq = _Char.eq_acc1;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack += _uneq.eq_att_bonus;
				_Char.defense += _uneq.eq_def_bonus;
				_Char.agility += _uneq.eq_agi_bonus;
				_Char.luck += _uneq.eq_luck_bonus;
				_Char.ele_earth_pow += _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow += _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow += _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow += _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res += _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res += _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res += _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res += _uneq.eq_ele_wind_res_bonus;
				
				_Char.eq_acc1 = _Item;
				_Char.eq_acc1.item_equipped = true;
			}
			else if _Char.eq_acc1 == "" {
				_Char.eq_acc1 = _Item;
				_Char.eq_acc1.item_equipped = true;
			}
			else if _Char.eq_acc2 == "" {
				_Char.eq_acc2 = _Item;
				_Char.eq_acc2.item_equipped = true;
			}
			else if _Char.eq_acc1 == "" and _Char.eq_acc2 == "" {
				_Char.eq_acc1 = _Item;
				_Char.ew_acc1.item_equipped = true;
			}
			
			var _eq = _Item;
				
			_Char.char_hp_max += _eq.eq_hp_bonus;
			_Char.char_vp_max += _eq.eq_vp_bonus;
			_Char.attack += _eq.eq_att_bonus;
			_Char.defense += _eq.eq_def_bonus;
			_Char.agility += _eq.eq_agi_bonus;
			_Char.luck += _eq.eq_luck_bonus;
			_Char.ele_earth_pow += _eq.eq_ele_earth_pow_bonus;
			_Char.ele_fire_pow += _eq.eq_ele_fire_pow_bonus;
			_Char.ele_water_pow += _eq.eq_ele_water_pow_bonus;
			_Char.ele_wind_pow += _eq.eq_ele_wind_pow_bonus;
			_Char.ele_earth_res += _eq.eq_ele_earth_res_bonus;
			_Char.ele_fire_res += _eq.eq_ele_fire_res_bonus;
			_Char.ele_water_res += _eq.eq_ele_water_res_bonus;
			_Char.ele_wind_res += _eq.eq_ele_wind_res_bonus;
		}
		else if _Item.item_type == "misc" {
			_Item.item_equipped = true;
			array_push(_Char.eq_misc, _Item);
		}
	}
}

function unequipItem(_CharID, _ItemID) {
	if array_length(obj_party_controller._Party) >= _CharID {
		_Char = obj_party_controller._Party[_CharID];
		_Item = global.char_invs[_CharID][_ItemID];
		
		if _Item.item_type == "weapon" {
			if _Char.eq_weapon != "" {
				_Char.eq_weapon.item_equipped = false;
				
				_Char.attack -= _Char.eq_weapon.weap_attack;
				_Char.defense -= _Char.eq_weapon.weap_defense;
				_Char.agility -= _Char.eq_weapon.weap_agility;
				_Char.luck -= _Char.eq_weapon.weap_luck;
				
				_Char.eq_weapon = "";
			}
		}
		else if _Item.item_type == "armor" {
			if _Char.eq_armor != "" {
				_Char.eq_armor.item_equipped = false;
				_Char.eq_armor = "";
				
				var _uneq = _Item;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack -= _uneq.eq_att_bonus;
				_Char.defense -= _uneq.eq_def_bonus;
				_Char.agility -= _uneq.eq_agi_bonus;
				_Char.luck -= _uneq.eq_luck_bonus;
				_Char.ele_earth_pow -= _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow -= _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow -= _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow -= _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res -= _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res -= _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res -= _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res -= _uneq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "helm" {
			if _Char.eq_helm != "" {
				_Char.eq_helm.item_equipped = false;
				_Char.eq_helm = "";
				
				var _uneq = _Item;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack -= _uneq.eq_att_bonus;
				_Char.defense -= _uneq.eq_def_bonus;
				_Char.agility -= _uneq.eq_agi_bonus;
				_Char.luck -= _uneq.eq_luck_bonus;
				_Char.ele_earth_pow -= _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow -= _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow -= _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow -= _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res -= _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res -= _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res -= _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res -= _uneq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "shield" {
			if _Char.eq_shield != "" {
				_Char.eq_shield.item_equipped = false;
				_Char.eq_shield = "";
				
				var _uneq = _Item;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack -= _uneq.eq_att_bonus;
				_Char.defense -= _uneq.eq_def_bonus;
				_Char.agility -= _uneq.eq_agi_bonus;
				_Char.luck -= _uneq.eq_luck_bonus;
				_Char.ele_earth_pow -= _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow -= _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow -= _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow -= _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res -= _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res -= _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res -= _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res -= _uneq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "shirt" {
			if _Char.eq_shirt != "" {
				_Char.eq_shirt.item_equipped = false;
				_Char.eq_shirt = "";
				
				var _uneq = _Item;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack -= _uneq.eq_att_bonus;
				_Char.defense -= _uneq.eq_def_bonus;
				_Char.agility -= _uneq.eq_agi_bonus;
				_Char.luck -= _uneq.eq_luck_bonus;
				_Char.ele_earth_pow -= _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow -= _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow -= _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow -= _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res -= _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res -= _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res -= _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res -= _uneq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "boots" {
			if _Char.eq_boots != "" {
				_Char.eq_boots.item_equipped = false;
				_Char.eq_boots = "";
				
				var _uneq = _Item;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack -= _uneq.eq_att_bonus;
				_Char.defense -= _uneq.eq_def_bonus;
				_Char.agility -= _uneq.eq_agi_bonus;
				_Char.luck -= _uneq.eq_luck_bonus;
				_Char.ele_earth_pow -= _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow -= _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow -= _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow -= _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res -= _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res -= _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res -= _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res -= _uneq.eq_ele_wind_res_bonus;
			}
		}
		else if _Item.item_type == "ring" {
			// Find out which slot the item is in
			if ( _Char.eq_acc1 != "" ) and ( _Char.eq_acc1 == _Item ) {
				_Char.eq_acc1.item_equipped = false;
				_Char.eq_acc1 = "";
			}
			else if ( _Char.eq_acc2 != "" ) and ( _Char.eq_acc2 == _Item ) {
				_Char.eq_acc2.item_equipped = false;
				_Char.eq_acc2 = "";
			}
			else if ( _Char.eq_acc1 != "" ) and ( _Char.eq_acc2 != "" ) and ( _Char.eq_acc1.item_name == _Char.eq_acc2.item_name == _Item.item_name ) {
				_Char.eq_acc1.item_equipped = false;
				_Char.eq_acc1 = "";
			}
			
			var _uneq = _Item;
				
				_Char.char_hp_max -= _uneq.eq_hp_bonus;
				_Char.char_vp_max -= _uneq.eq_vp_bonus;
				_Char.attack -= _uneq.eq_att_bonus;
				_Char.defense -= _uneq.eq_def_bonus;
				_Char.agility -= _uneq.eq_agi_bonus;
				_Char.luck -= _uneq.eq_luck_bonus;
				_Char.ele_earth_pow -= _uneq.eq_ele_earth_pow_bonus;
				_Char.ele_fire_pow -= _uneq.eq_ele_fire_pow_bonus;
				_Char.ele_water_pow -= _uneq.eq_ele_water_pow_bonus;
				_Char.ele_wind_pow -= _uneq.eq_ele_wind_pow_bonus;
				_Char.ele_earth_res -= _uneq.eq_ele_earth_res_bonus;
				_Char.ele_fire_res -= _uneq.eq_ele_fire_res_bonus;
				_Char.ele_water_res -= _uneq.eq_ele_water_res_bonus;
				_Char.ele_wind_res -= _uneq.eq_ele_wind_res_bonus;
		}
		else if _Item.item_type == "misc" {
			_Item.item_equipped = false;
			var _f = function(_e, _i) { return ( _e.item_name == _Item.item_name ) }
			var _index = array_find_index(_Char.eq_misc, _f);
			array_delete(_Char.eq_misc, _index, 1);
		}
	}
}

function dropItem(_CharID, _ItemID, _amt) {
	_Item = global.char_invs[_CharID][_ItemID];
	if _Item.item_amt_held >= _amt {
		_Item.item_amt_held -= _amt;
		if _Item.item_amt_held > 0 {
			return _Item.item_amt_held;
		}
		else if _Item.item_amt_held == 0 {
			array_delete(global.char_invs[_CharID], _ItemID, 1);
			return 0;
		}
	}
	else {
		return -1;
	}
}