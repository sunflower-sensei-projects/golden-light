function scr_execute_ability(_ability_id, _user, _targets) {
	var _ab = global.ability_data[$ _ability_id];
	if (_ab == undefined) {
		show_debug_message("Unknown ability: " + _ability_id);
		return;
	}
	
	// VP cost
	if (struct_exists(_ab, "vp_cost")) {
		_user.vp_current = max(0, _user.vp_current - _ab.vp_cost);	
	}
	
	// User animation
	if (struct_exists(_ab, "anim_user")) {
		_user.anim_state = _ab.anim_user;	
	}
	
	// Apply to each target
	for (var _i = 0; _i < array_length(_targets); _i++) {
		var _t = _targets[_i];
		if (!_t.alive) continue;
		
		switch (_ab.type) {
			
			case "physical":
			case "sorcery":
				var _dmg = _ab.damage_formula(_user, _t);
				_dmg = max(0, scr_apply_element(_dmg, _ab.element, _t));
				_t.hp_current = max(0, _t.hp_current - _dmg);
				_t.anim_state = (_t.hp_current <= 0) ? "down" : "hit";
				if (_t.hp_current <= 0) _t.alive = false;
				scr_spawn_damage_number(_t.screen_x, _t.screen_y, _dmg);
				if (struct_exists(_ab, "status_effect")) {
					if (random(1) < (_ab.status_chance/100)) {
						scr_apply_status(_t, _ab.status_effect, _ab.status_magnitude);
						scr_spawn_status_popup(_t.screen_x, _t.screen_y, _ab.status_effect);
					}
				}
				break;
			
			case "heal":
				var _heal = _ab.heal_formula(_user, _t);
				if (_t.alive) {
					_t.hp_current = min(_t.hp + _heal, _t.hp_max);
				} else {
					_heal = 0;	
				}
				scr_spawn_heal_number(_t.screen_x, _t.screen_y, _heal);
				break;
			
			case "raise":
				var _restore = _ab.heal_formula(_user, _t);
				_t.hp_current = _restore;
				_t.alive = true;
				scr_spawn_heal_number(_t.screen_x, _t.screen_y, _restore);
				break;
			
			case "status":
				if (random(1) < (_ab.status_chance/100)) {
					scr_apply_status(_t, _ab.status_effect, _ab.status_magnitude);
					scr_spawn_status_popup(_t.screen_x, _t.screen_y, _ab.status_effect);
				}
				break;
		}
		
		// Impact sprite on target
		if (struct_exists(_ab, "impact_spr") && _ab.impact_spr != noone && _ab.impact_spr != undefined) {
			var _imp = instance_create_layer(_t.screen_x, _t.screen_y, "Battle_FX", obj_impact_display);
			_imp.sprite_index = _ab.impact_spr;
			_imp.image_index = 0;
			_imp.image_speed = 1;
		}
		
		// SFX
		if (struct_exists(_ab, "sfx") && _ab.sfx != noone && _ab.sfx != undefined) {
			obj_audio_controller.sfx_play(_ab.sfx);	
		}
	}
}

function scr_resolve_targets(_ability_id, _user, _selected) {
	// _selected = the battler that the user manually selected, if applicable
	var _ab = global.ability_data[$ _ability_id];
	var _mgr = obj_battle_controller;
	var _results = [];
	
	switch (_ab.target_mode) {
		case "single_enemy":
		case "single_foe":
			return [_selected];
			
		case "single_ally":
			return [_selected];
		
		case "3_foes":
			// An array with the selected battler and the closest battlers to the right and left, if any exist
			var _living = array_filter(_mgr.enemy_battlers, function(_b) { return _b.alive; });
			var _max = array_length(_living);
			var _sel_ind = array_get_index(_living, _selected);
			array_push(_results, _selected);
			
			// Check to the left
			if (_sel_ind == 0) {
				// The selected is the furthest to the left
			} else if (array_length(_living) <= 1) {
				// There are no other living targets	
			} else {
				array_push(_results, _living[_sel_ind-1]);	
			}
			
			// Check to the right
			if (_sel_ind >= _max) {
				// They are the furthest to the right
			} else if (array_length(_living) <= 1) {
				
			} else {
				array_push(_results, _living[_sel_ind+1]);
			}
			
			return _results;
		
		case "5_foes":
			// Return the selected and the two closest enemies to the right and left, if they exist
			return _results;
		
		case "7_foes":
			// Return the selected and the three closest enemies to the right and left, if they exist
			return _results;
		
		case "all_foes":
			return array_filter(_mgr.enemy_battlers, function(_b) { return _b.alive; });
		
		case "all_allies":
			return array_filter(_mgr.party_battlers, function(_b) { return _b.alive; });
		
		case "self":
			return [_user];
		
		case "all":
			return array_filter(
				array_concat(_mgr.party_battlers, _mgr.enemy_battlers),
				function(_b) { return _b.alive; }
			);
	}
}

function scr_apply_status(_target, _status_effect, _magnitude) {
	// Applies the status to the terget, which is a battler struct
	var _names = struct_get_names(_target.statuses);
	var _contains = array_contains(_names, _status_effect);
	var _i = 0;
	
	switch(_status_effect) {
		
		// These statuses do not overlap
		case "poison":
		case "stun":
		case "silence":
		case "confuse":
		case "curse":
		case "daze":
		case "paralyze":
		case "hex":
		case "doom":
		case "crystal":
		case "afflict":
		case "bushido":
		case "berserk":
		case "charm":
		case "possess":
		case "sleep":
		case "freeze":
		case "burn":
		case "fear":
			if (!_contains) {
				_battler.statuses[$ _status_effect] = _magnitude;
			}
			break;
		
		// These statuses stack up to four times their base value
		case "agi_down":
		case "agi_up":
		case "att_down":
		case "att_up":
		case "def_down":
		case "def_up":
		case "luck_down":
		case "luck_up":
		case "ele_pow_up":
		case "ele_pow_down":
		case "ele_res_up":
		case "ele_res_down":
			if (_contains) {
				_battler.statuses[$ _status_effect] = min(4, _battler.statuses[$ _status_effect] + _magnitude);
			} else {
				_battler.statuses[$ _status_effect] = min(4, _magnitude);
			}
			scr_battler_recalc_stats(_battler);
			break;
		
		// These statuses have special outcomes/conditions
		case "down":
			if (_target.alive) {
				_target.hp_current = 0;
				_target.alive = false;
			}
			break;
			
	}
}

function scr_battler_action_check(_battler) {
	// Called right before a battler acts
	// Checks to see if they can actually do what they selected
	// returns false if they can't do what they selected, true if they can
	
	var _can_act = true;
	var _s_list = struct_get_names(_battler.statuses);
	
	if (!_battler.alive) return false; // Can't act if you're dead
	
	return _can_act;
	
}

function scr_status_tick(_target) {
	// Called at after a battler acts
	// _target is a battler struct
	// First, check to see what statuses they have
	var _list = struct_get_names(_target.statuses);
	var _status = "";
	var _mag = 0;
	var _dmg = 0;
	
	for (var _i = 0; _i < array_length(_list); _i++) {
		if (!_target.alive) break;
		_status = _list[_i];
		_mag = _target.statuses[$ _status];
		switch (_status) {
			case "poison":
				// Deals 10% of the target's max HP as damage
				_dmg = _target.hp_max * 0.10;
				_target.hp_current = max(0, floor(_target.hp_current - _dmg));
				_target.anim_state = (_target.hp_current <= 0) ? "down" : "hit";
				if (_target.hp_current <= 0) _target.alive = false;
				scr_spawn_damage_number(_target.screen_x, _target.screen_y, _dmg);
				_target.statuses[$ "poison"] = _mag - 1;
				break;
			
			case "hex":
				// Deals increasing dark-aligned damage every turn
				// Starts at 60 base damage, increases 1.5x every tick until removed or the target dies
				break;
			
			case "doom":
				// After a count of 3, the target dies instantly (or 500 pure damage for strong foes)
				// Check to see where the count is, if magnitude is on 4, act accordingly
				if (_mag > 3) {
					// Check to see if target is strong_foe
					if (_target.strong_foe) {
						// Target is immune to instant death, apply 500 pure damage instead
						_target.hp_current = max(0, _target.hp_current - 500);
						_target.anim_state = (_target_hp_current <= 0) ? "down" : "hit";
						if (_target.hp_current <= 0) _target.alive = false;
						scr_spawn_damage_number(_target.screen_x, _target.screen_y, 500);
					} else {
						// Target is a party member or a regular foe
						scr_apply_death(_target);
						scr_spawn_status_popup(_target.screen_x, _target.screen_y, "death");
					}
					struct_remove(_target.statuses, "doom");
				} else {
					scr_spawn_status_popup(_target.screen_x, _target.screen_y, "doom");
					_target.statuses[$ "doom"] = _mag + 1;
					
				}
				break;
			
			case "burn":
				// The target takes 10% of their max HP as fire-based damage if they act
				// If they defended, do nothing, but tick down
				break;
			
			case "stun":
				// The target skips their turn, but they just took their turn, so this does nothing here
				// Stun does not stack, so this just gets removed here
				struct_remove(_target.statuses, "stun");
				break;
			
			case "silence": // The target cannot cast spells, does nothing on tick
			case "confuse": // The target does random actions on their turn, does nothing on tick
			case "curse":   // The target may skip their turn or act randomly, does nothing on tick
			case "dazed":   // The target may miss their attack action, does nothing on tick
			case "paralyze":// The target cannot attack, does nothing on tick
			case "crystal": // The target takes double physical damage, does nothing on tick
			case "afflct":  // The target takes double damage from all sources, does nothing on tick
			case "bushido": // The target must attack, and can counterattack, does nothing on tick
			case "berserk": // The target must attack, does nothing on tick
			case "charm":   // The target attacks other foes and can heal the party, does nothing on tick
			case "posses":  // Same as charm, but for party members, does nothing on tick
			case "sleep":   // Same as stun, but can last more than one turn, target wakes when attacked
			case "freeze":  // Same as sleep, but fades when hit with Fire-based damage
			case "fear":    // Silence + Paralyze, does nothing on tick
				_target.statuses[$ _status] = _mag - 1;
				break;
				
		}	
		
		// Remove all statuses with 0 magnitude
		if (_target.statuses[$ _status] == 0) {
			struct_remove(_target.statuses, _status);	
		}
	}
}

function scr_spawn_damage_number(_sx, _sy, _amount) {
	var _inst = instance_create_layer(_sx, _sy - 20, "Battle_UI", obj_battle_number);
	_inst.number = _amount;
	_inst.color = c_red;
	_inst.is_crit = false;
	return _inst;
}

function scr_spawn_heal_number(_sx, _sy, _amount) {
	var _inst = instance_create_layer(_sx, _sy - 20, "Battle_UI", obj_battle_number);
	_inst.number = _amount;
	_inst.color = c_lime;
	_inst.is_crit = false;
	return _inst;
}

function scr_spawn_crit_number(_sx, _sy, _amount) {
	var _inst = instance_create_layer(_sx, _sy - 20, "Battle_UI", obj_battle_number);
	_inst.number = _amount;
	_inst.color = c_yellow;
	_inst.is_crit = true;
	return _inst;
}

function scr_spawn_status_popup(_sx, _sy, _status) {
	var _inst = instance_create_layer(_sx, _sy - 20, "Battle_UI", obj_battle_status);
	_inst.status = _status;
	_inst.status_text = scr_status_display_name(_status);
	_inst.color = scr_status_color(_status);
	return _inst;
}

function scr_status_display_name(_status) {
	switch (_status) {
		case "poison": return "PSN";
		default:       return string_upper(_status);
	}
}

function scr_status_color(_status) {
	switch (_status) {
		case "poison": return make_color_rgb(180, 60, 220);
		default:       return c_white;
	}
}

function scr_apply_death(_target) {
	// This function takes one argument, _target, which is a battler struct
	// Check to see if the battler is a "strong_foe", if it is, deal 500 pure damage instead
	// If it's a regular foe or a party member, check to see if they have anything that could block death
	// If not, just kill them
	var _status_list = struct_get_names(_target.statuses);
	var _strong = _target.strong_foe;
	var _dmg = 500;
	var _resist_list = struct_get_names(_target.status_resist);
	if (_strong) {
		if (_target.alive) {
			_target.hp_current = max(0, floor(_target.hp_current - _dmg));
			_target.anim_state = (_target.hp_current <= 0) ? "down" : "hit";
			scr_spawn_damage_number(_target.screen_x, _target.screen_y, _dmg);
			scr_spawn_status_popup(_target.screen_x, _target.screen_y, "death");
			if (_target.hp_current <= 0) {
				_target.alive = false;	
			}
		}
	} else {
		if (_target.alive) {
			// Check to see if they have any boons or resistances / immunities to instant death
			// Order of operations, immunities block death entirely
			// then, any boons that trigger on death happen, like auto-raise
			if (array_contains(_resist_list, "death")) {
				scr_spawn_status_popup(_target.screen_x, _target.screen_y, "immune");
				_target.anim_state = "idle";
			} else if (array_contains(_status_list, "boon_auto_raise")) {
				// The target gets killed, then raised
				// Play the animation of them being raised
				_target.hp_current = floor(_target.hp_max / 2);
				_target.alive = true;
				_target.statuses = {};
				_target.anim_state = "idle";
				scr_spawn_status_popup(_target.screen_x, _target.screen_y, "death");
			}
		}
	}
}