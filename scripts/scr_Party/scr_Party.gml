/// scr_Party
/// Roster, character constructor, battle-active helpers.
/// Inventory lives on each character. Equipment slots are references
/// into that inventory, not separate item instances.

#macro PARTY_BATTLE_MAX 4

/// ---------------------------------------------------------------
/// LOOKUP
/// ---------------------------------------------------------------

function scr_Char_Index_By_Name(_name) {
    if (!variable_global_exists("char_index")) return -1;
    if (!variable_struct_exists(global.char_index, _name)) return -1;
    return global.char_index[$ _name];
}

function isInParty(_name) {
    var _mgr = obj_party_controller;
    for (var i = 0; i < array_length(_mgr._Party); i++) {
        if (_mgr._Party[i].char_name == _name) return i;
    }
    return -1; // -1 = not in party (do not use false; 0 is a valid slot)
}

function getProtagData(_protagName) {
    var _i = isInParty(_protagName);
    if (_i < 0) return undefined;
    return obj_party_controller._Party[_i];
}

/// ---------------------------------------------------------------
/// INVENTORY BUILD
/// Starting lists may use "Herb_5" to mean 5x Herb.
/// Equipment names are created as unique instances (never stacked).
/// Consumables with the same name stack into one entry.
/// ---------------------------------------------------------------

function scr_Parse_Item_Token(_token) {
    // Returns { name, amt }
    var _amt = 1;
    var _name = _token;
    
    var _us = string_last_pos("_", _token);
    if (_us > 0) {
        var _tail = string_copy(_token, _us + 1, string_length(_token) - _us);
        if (string_digits(_tail) == _tail && _tail != "") {
            var _base = string_copy(_token, 1, _us - 1);
            if (variable_struct_exists(global.item_index, _base)) {
                _name = _base;
                _amt  = real(_tail);
            }
        }
    }
    
    return { name: _name, amt: _amt };
}

function scr_Inventory_Find(_inv, _item_name, _unequipped_only) {
    for (var i = 0; i < array_length(_inv); i++) {
        if (_inv[i].item_name != _item_name) continue;
        if (_unequipped_only && _inv[i].item_equipped) continue;
        return _inv[i];
    }
    return undefined;
}

function buildInventory(_item_name_list) {
    if (!is_array(_item_name_list)) return [];
    
    var _item_list = [];
    
    for (var i = 0; i < array_length(_item_name_list); i++) {
        var _tok  = scr_Parse_Item_Token(_item_name_list[i]);
        var _name = _tok.name;
        var _amt  = _tok.amt;
        
        if (!variable_struct_exists(global.item_index, _name)) {
            show_debug_message("buildInventory: unknown item '" + string(_name) + "'");
            continue;
        }
        
        var _temp = new new_item(_name);
        
        if (_temp.item_type == "consume") {
            var _existing = scr_Inventory_Find(_item_list, _name, false);
            if (_existing != undefined) {
                _existing.item_amt_held += _amt;
            } else {
                _temp.item_amt_held = _amt;
                array_push(_item_list, _temp);
            }
        } else {
            // Equipment / key / misc: one instance per token
            for (var n = 0; n < _amt; n++) {
                array_push(_item_list, (n == 0) ? _temp : new new_item(_name));
            }
        }
    }
    
    return _item_list;
}

/// Bind an equipment slot to an existing inventory instance.
/// If the named item is not in the bag, create it, add it, then bind.
function scr_Bind_Equip_Slot(_inv, _item_name) {
    if (!is_string(_item_name) || _item_name == "") return undefined;
    
    var _item = scr_Inventory_Find(_inv, _item_name, true);
    if (_item == undefined) {
        if (!variable_struct_exists(global.item_index, _item_name)) {
            show_debug_message("scr_Bind_Equip_Slot: unknown item '" + _item_name + "'");
            return undefined;
        }
        _item = new new_item(_item_name);
        array_push(_inv, _item);
    }
    
    _item.item_equipped = true;
    return _item;
}

function scr_Names_To_Array(_name_array, _dataset, _lookup_index) {
    // Always returns an array (empty if nothing matched).
    var _out = [];
    if (!is_array(_name_array)) return _out;
    
    for (var i = 0; i < array_length(_name_array); i++) {
        var _n = _name_array[i];
        if (variable_struct_exists(_lookup_index, _n)) {
            array_push(_out, _dataset[_lookup_index[$ _n]]);
        }
    }
    return _out;
}

/// ---------------------------------------------------------------
/// CHARACTER CONSTRUCTOR
/// ---------------------------------------------------------------

function new_character(_name) constructor {
    var _index = scr_Char_Index_By_Name(_name);
    if (_index < 0) {
        show_debug_message("new_character: '" + string(_name) + "' not in char_index");
        // Leave a marked-invalid object so callers can detect failure
        char_name   = "";
        actor_type  = "invalid";
        exit;
    }
    
    var _src = global.char_data[_index];
    
    char_name   = _src.name;
    actor_type  = "protag";
    creature_type = "human";
    
    char_hp_max     = _src.char_hp_max;
    char_hp_current = char_hp_max;
    char_vp_max     = _src.char_vp_max;
    char_vp_current = char_vp_max;
    
    char_level = _src.char_level;
    char_exp   = 0;
    char_class = _src.char_class;
    
    statuses      = [];
    status_resist = {};
    downed        = false;
    
    attack  = _src.char_attack;
    defense = _src.char_defense;
    agility = _src.char_agility;
    luck    = _src.char_luck;
    
    ele_level_earth = variable_struct_exists(_src, "ele_level_earth") ? _src.ele_level_earth : 0;
    ele_level_fire  = variable_struct_exists(_src, "ele_level_fire")  ? _src.ele_level_fire  : 0;
    ele_level_water = variable_struct_exists(_src, "ele_level_water") ? _src.ele_level_water : 0;
    ele_level_wind  = variable_struct_exists(_src, "ele_level_wind")  ? _src.ele_level_wind  : 0;
    
    ele_earth_pow = _src.ele_power_earth;
    ele_fire_pow  = _src.ele_power_fire;
    ele_water_pow = _src.ele_power_water;
    ele_wind_pow  = _src.ele_power_wind;
    ele_earth_res = _src.ele_resist_earth;
    ele_fire_res  = _src.ele_resist_fire;
    ele_water_res = _src.ele_resist_water;
    ele_wind_res  = _src.ele_resist_wind;
    
    growth_max_hp  = variable_struct_exists(_src, "growth_max_hp")  ? _src.growth_max_hp  : [];
    growth_max_vp  = variable_struct_exists(_src, "growth_max_vp")  ? _src.growth_max_vp  : [];
    growth_attack  = variable_struct_exists(_src, "growth_attack")  ? _src.growth_attack  : [];
    growth_defense = variable_struct_exists(_src, "growth_defense") ? _src.growth_defense : [];
    growth_agility = variable_struct_exists(_src, "growth_agility") ? _src.growth_agility : [];
    growth_luck    = variable_struct_exists(_src, "growth_luck")    ? _src.growth_luck    : [];
    
    char_sorceries = scr_Names_To_Array(
        _src.char_starting_sorceries, global.sorcery_data, global.sorcery_index
    );
    
    // Faefolk stay as name strings for now (data objects exist in global.fae_data)
    char_feyfolk = is_array(_src.char_starting_feyfolk) ? _src.char_starting_feyfolk : [];
    
    inventory = buildInventory(_src.char_starting_inventory);
    
    eq_helm   = scr_Bind_Equip_Slot(inventory, _src.eq_helm);
    eq_shirt  = scr_Bind_Equip_Slot(inventory, _src.eq_shirt);
    eq_armor  = scr_Bind_Equip_Slot(inventory, _src.eq_armor);
    eq_weapon = scr_Bind_Equip_Slot(inventory, _src.eq_weapon);
    eq_shield = scr_Bind_Equip_Slot(inventory, _src.eq_shield);
    eq_boots  = scr_Bind_Equip_Slot(inventory, _src.eq_boots);
    eq_acc1   = scr_Bind_Equip_Slot(inventory, _src.eq_acc1);
    eq_acc2   = scr_Bind_Equip_Slot(inventory, _src.eq_acc2);
    
    eq_misc = [];
    if (is_array(_src.eq_misc)) {
        for (var m = 0; m < array_length(_src.eq_misc); m++) {
            var _misc_item = scr_Bind_Equip_Slot(inventory, _src.eq_misc[m]);
            if (_misc_item != undefined) array_push(eq_misc, _misc_item);
        }
    }
    
    if (variable_struct_exists(_src, "char_sprite")) {
        stand_spr = asset_get_index(_src.char_sprite);
    } else {
        stand_spr = -1;
    }
}

/// ---------------------------------------------------------------
/// ROSTER
/// _Party[0]     = field leader
/// _Party[0..3]  = battle-active (if present)
/// _Party[4+]    = reserve / bench
/// ---------------------------------------------------------------

function addProtagToParty(_protagName) {
    if (scr_Char_Index_By_Name(_protagName) < 0) {
        show_debug_message("addProtagToParty: unknown character '" + string(_protagName) + "'");
        return -1;
    }
    if (isInParty(_protagName) >= 0) {
        show_debug_message("addProtagToParty: '" + _protagName + "' is already in the party");
        return -2;
    }
    
    var _protagData = new new_character(_protagName);
    if (_protagData.actor_type == "invalid") return -1;
    
    array_push(obj_party_controller._Party, _protagData);
    
    if (array_length(obj_party_controller._Party) >= 5) {
        scr_menu_unlock("party");
    }
    
    return 0;
}

function removeProtagFromParty(_protagName) {
    var _i = isInParty(_protagName);
    if (_i < 0) return;
    array_delete(obj_party_controller._Party, _i, 1);
    scr_Party_Update_Leader();
}

function moveProtag(_protagName, _newSlot) {
    var _mgr = obj_party_controller;
    var _i = isInParty(_protagName);
    if (_i < 0) return;
    
    _newSlot = clamp(_newSlot, 0, array_length(_mgr._Party) - 1);
    var _temp = _mgr._Party[_i];
    array_delete(_mgr._Party, _i, 1);
    array_insert(_mgr._Party, _newSlot, _temp);
    scr_Party_Update_Leader();
}

function scr_Party_Set_Leader(_protagName) {
    moveProtag(_protagName, 0);
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

function scr_Party_Size() {
    return array_length(obj_party_controller._Party);
}

/// ---------------------------------------------------------------
/// BATTLE ROSTER
/// ---------------------------------------------------------------

function scr_Party_Battle_Count() {
    return min(PARTY_BATTLE_MAX, scr_Party_Size());
}

function scr_Party_Get_Battler(_slot) {
    // _slot is 0..3
    if (_slot < 0 || _slot >= scr_Party_Battle_Count()) return undefined;
    return obj_party_controller._Party[_slot];
}

function scr_Party_Is_Battler(_name) {
    var _i = isInParty(_name);
    return (_i >= 0 && _i < PARTY_BATTLE_MAX);
}

function scr_Party_Get_Reserve() {
    var _mgr = obj_party_controller;
    var _out = [];
    for (var i = PARTY_BATTLE_MAX; i < array_length(_mgr._Party); i++) {
        array_push(_out, _mgr._Party[i]);
    }
    return _out;
}

/// Swap a reserve member into a battle slot.
/// Used by the Party menu and by the battle Swap command.
function scr_Party_Swap_Battler(_battle_slot, _reserve_name) {
    var _mgr = obj_party_controller;
    if (_battle_slot < 0 || _battle_slot >= PARTY_BATTLE_MAX) return false;
    if (_battle_slot >= array_length(_mgr._Party)) return false;
    
    var _res_i = isInParty(_reserve_name);
    if (_res_i < PARTY_BATTLE_MAX) return false; // already a battler, or not in party
    
    var _temp = _mgr._Party[_battle_slot];
    _mgr._Party[_battle_slot] = _mgr._Party[_res_i];
    _mgr._Party[_res_i] = _temp;
    
    if (_battle_slot == 0) scr_Party_Update_Leader();
    return true;
}

/// Called when a battler is downed. If a living reserve exists,
/// that reserve takes the downed battler's slot and the downed
/// member is moved to the end of the roster.
function scr_Party_Auto_Replace_Downed(_downed_name) {
    var _mgr = obj_party_controller;
    var _down_i = isInParty(_downed_name);
    if (_down_i < 0 || _down_i >= PARTY_BATTLE_MAX) return false;
    
    var _replace_i = -1;
    for (var i = PARTY_BATTLE_MAX; i < array_length(_mgr._Party); i++) {
        if (!_mgr._Party[i].downed && _mgr._Party[i].char_hp_current > 0) {
            _replace_i = i;
            break;
        }
    }
    if (_replace_i < 0) return false;
    
    var _downed = _mgr._Party[_down_i];
    _downed.downed = true;
    
    _mgr._Party[_down_i] = _mgr._Party[_replace_i];
    array_delete(_mgr._Party, _replace_i, 1);
    array_push(_mgr._Party, _downed);
    
    if (_down_i == 0) scr_Party_Update_Leader();
    return true;
}

function scr_Party_Clear() {
    obj_party_controller._Party = [];
}