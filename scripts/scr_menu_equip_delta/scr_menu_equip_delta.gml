/// scr_equip_slot_map()
/// Maps an item_type string to the character's equipped-slot variable
/// name, and to the item's bonus field prefix. One table instead of
/// eight copy-pasted if/else branches. Add new equip types here only.
function scr_equip_slot_map() {
	static _map = undefined;
	if (is_undefined(_map)) {
		_map = {
			weapon: "eq_weapon",
			armor:  "eq_armor",
			helm:   "eq_helm",
			shield: "eq_shield",
			shirt:  "eq_shirt",
			boots:  "eq_boots"
			// "ring" is handled separately below (two accessory slots)
		};
	}
	return _map;
}

/// scr_get_equip_bonuses(_item)
/// Reads an item's stat bonus fields into a consistent struct shape,
/// regardless of whether it's a weapon (weap_*) or gear (eq_*_bonus).
/// Non-equippable / misc items return all zeroes.
function scr_get_equip_bonuses(_item) {
	if (is_undefined(_item)) {
		return { hp: 0, vp: 0, attack: 0, defense: 0, agility: 0, luck: 0 };
	}
	if (_item.item_type == "weapon") {
		return {
			hp: 0, vp: 0,
			attack:  _item.weap_attack,
			defense: _item.weap_defense,
			agility: _item.weap_agility,
			luck:    _item.weap_luck
		};
	}
	// All other equip types (armor/helm/shield/shirt/boots/ring) share
	// the eq_*_bonus naming convention.
	return {
		hp:      variable_struct_exists(_item, "eq_hp_bonus")   ? _item.eq_hp_bonus   : 0,
		vp:      variable_struct_exists(_item, "eq_vp_bonus")   ? _item.eq_vp_bonus   : 0,
		attack:  variable_struct_exists(_item, "eq_att_bonus")  ? _item.eq_att_bonus  : 0,
		defense: variable_struct_exists(_item, "eq_def_bonus")  ? _item.eq_def_bonus  : 0,
		agility: variable_struct_exists(_item, "eq_agi_bonus")  ? _item.eq_agi_bonus  : 0,
		luck:    variable_struct_exists(_item, "eq_luck_bonus") ? _item.eq_luck_bonus : 0
	};
}

/// scr_menu_equip_delta(_char, _item)
///
/// Given a character and a candidate item, returns what the character's
/// stats WOULD be if that item were equipped (swapping out whatever
/// currently occupies that slot). Replaces the ~150 line block of
/// copy-pasted per-slot branches that used to live in obj_menu_items
/// menu_level == 1's accept handler.
///
/// Returns a struct: { hp, vp, attack, defense, agility, luck }
/// matching char_new_* naming used by the draw code.
function scr_menu_equip_delta(_char, _item) {
	// Not equippable, or already equipped (no change to preview) -
	// just mirror current stats.
	if (canEquipItem(_item) == false || _item.item_equipped == true) {
		return {
			hp: _char.char_hp_max, vp: _char.char_vp_max,
			attack: _char.attack, defense: _char.defense,
			agility: _char.agility, luck: _char.luck
		};
	}

	var _new_bonus = scr_get_equip_bonuses(_item);
	var _old_item = undefined;

	if (_item.item_type == "ring") {
		// Two accessory slots - compare against whichever is filled,
		// preferring the first empty slot (matches old behavior: new
		// ring goes in acc1 if empty, else acc2 if empty, else
		// replaces acc1).
		if (_char.eq_acc1 == "") {
			_old_item = undefined;
		} else if (_char.eq_acc2 == "") {
			_old_item = undefined;
		} else {
			_old_item = _char.eq_acc1;
		}
	}
	else if (_item.item_type == "misc") {
		_old_item = undefined; // misc items never equip; no change
		_new_bonus = { hp: 0, vp: 0, attack: 0, defense: 0, agility: 0, luck: 0 };
	}
	else {
		var _map = scr_equip_slot_map();
		if (variable_struct_exists(_map, _item.item_type)) {
			var _slot_var = _map[$ _item.item_type];
			var _current = variable_struct_get(_char, _slot_var);
			_old_item = (_current == "") ? undefined : _current;
		}
	}

	var _old_bonus = scr_get_equip_bonuses(_old_item);

	return {
		hp:      _char.char_hp_max - _old_bonus.hp      + _new_bonus.hp,
		vp:      _char.char_vp_max - _old_bonus.vp      + _new_bonus.vp,
		attack:  _char.attack      - _old_bonus.attack  + _new_bonus.attack,
		defense: _char.defense     - _old_bonus.defense + _new_bonus.defense,
		agility: _char.agility     - _old_bonus.agility + _new_bonus.agility,
		luck:    _char.luck        - _old_bonus.luck    + _new_bonus.luck
	};
}
