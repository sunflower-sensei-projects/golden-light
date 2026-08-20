function cs_lock_player() {
	// Locks the player during the cutscene (always run at the top of the event)
	return {
		start: function() {
			Player.interact_locked = true;
			Player.state = pState.INTERACT;
		},
		tick: function() { return true; } // instant
	};
}

function cs_unlock_player() {
	// Unlocks the player (always run last)
	return {
		start: function() {
			Player.interact_locked = false;
			Player.state = pState.IDLE;
		},
		tick: function() { return true; }
	};
}

function cs_wait(_frames) {
	// Wait a number of frames
	return {
		timer: _frames,
		start: function() { timer = other.timer; },
		tick: function() {
			timer--;
			return (timer <= 0);
		}
	};
}

function cs_move_to(_inst, _tx, _ty, _spd) {
	// Move an instance to a target position at a given speed
	return {
		inst: _inst,
		tx: _tx,
		ty: _ty,
		spd: _spd,
		start: function() {},
		tick: function() {
			if (!instance_exists(inst)) return true;
			var _dist = point_distance(inst.x, inst.y, tx, ty);
			if (_dist <= spd) {
				inst.x = tx;
				inst.y = ty;
				return true;
			}
		}
	};
}

function cs_face(_inst, _dir) {
	// Make an instance face a direction (sets anim_dir instantly)
	return {
		inst: _inst,
		dir: _dir,
		start: function() {
			if (instance_exists(inst)) inst.anim_dir = dir;
		},
		tick: function() { return true; }
	};
}

function cs_dialogue(_speaker, _text) {
	// Show a dialogue box - integrates with your dialogue system
	// Advances when the player dismisses the box (dialogue_done flag)
	return {
		speaker: _speaker,
		text: _text,
		start: function() {
			// Hook this into however you display dialogue
			// e.g. obj_dialogue.show(speaker, text);
			obj_dialogue_box.show(speaker, text);
		},
		tick: function() {
			// Dialogue system sets this when the box is dismissed
			return obj_dialogue_box.is_done;
		}
	};
}

function cs_play_anim(_inst, _spr, _spd) {
	// Play an animation once and wait for it to finish
	return {
		inst: _inst,
		spr: _spr,
		spd: _spd,
		start: function() {
			if (!instance_exists(inst)) return;
			inst.sprite_index = spr;
			inst.image_index = 0;
			inst.image_speed = spd;
		},
		tick: function() {
			if (!instance_exists(inst)) return true;
			return (inst.image_index >= sprite_get_number(inst.sprite_index) - 1);
		}
	};
}

function cs_parallel(_actions_a, _actions_b) {
	// Run two action arrays in parallel
	// This advances when they both finish
	return {
		runner_a: _actions_a,
		runner_b: _actions_b,
		done_a: false,
		done_b: false,
		idx_a: 0,
		idx_b: 0,
		cur_a: undefined,
		cur_b: undefined,
		start: function() {
			cur_a = (array_length(runner_a) > 0) ? runner_a[0] : undefined;
			cur_b = (array_length(runner_b) > 0) ? runner_b[0] : undefined;
			if (cur_a != undefined && struct_exists(cur_a, "start")) cur_a.start();
			if (cur_b != undefined && struct_exists(cur_b, "start")) cur_b.start();
		},
		tick: function() {
			// Tick sequence A
			if (!done_a && cur_a != undefined) {
				if (cur_a.tick()) {
					idx_a++;
					if (idx_a >= array_length(runner_a)) {
						done_a = true;	
					} else {
						cur_a = runner_a[idx_a];
						if (struct_exists(cur_a, "start")) cur_a.start();
					}
				}
			} else { done_a = true; }
			
			// Tick sequence B
			if (!done_b && cur_b != undefined) {
				if (cur_b.tick()) {
					idx_b++;
					if (idx_b >= array_length(runner_b)) {
						done_b = true;	
					} else {
						cur_b = runner_b[idx_b];
						if (struct_exists(cur_b, "start")) cur_b.start();
					}
				}
			} else { done_b = true; }
			
			return (done_a && done_b);
		},
	};
}

function cs_add_party_member(_protagName) {
	// Add a party member mid-cutscene
	return {
		protagName: _protagName,
		start: function() { addProtagToParty(protagName); },
		tick: function() { return true; }
	};
}

function cs_set_party_leader(_protagName) {
	return {
		protagName: _protagName,
		start: function() { scr_Party_Set_Leader(protagName); },
		tick: function() { return true; }
	};
}

function cs_summon_anim(_data, _targets, _caster_hp) {
		return {
			data: _data,
			targets: _targets,
			inst: undefined,
			frame_count: 0,
			damage_dealt: false,
			done: false,
			caster_hp: _caster_hp,
			
			start: function() {
				// Spawn a dedicated draw instance for the summon
				// position at the screen center, since it's a full screen cinematic
				inst = instance_create_layer(
					room_width / 2,
					room_height / 2,
					"Battle_FX",
					obj_summon_display
				);
				inst.sprite_index = data.sprite_summon;
				inst.image_index = 0;
				inst.image_speed = 1;
				frame_count = sprite_get_number(data.sprite_summon);
				damage_dealt = false;
			},
			
			tick: function() {
				if (!instance_exists(inst)) return true;
				
				var _frame = floor(inst.image_index);
				
				// Apply damage at the impact frame
				if (!damage_dealt && _frame >= data.damage_frame) {
					damage_dealt = true;
					scr_summon_apply_damage(data, targets, caster_hp);
					
					// Spawn impact sprites on each target at their screen positions
					for (var _i = 0; _i < array_length(targets); _i++) {
						var _t = targets[_i];
						var _imp = instance_create_layer(
							_t.screen_x, _t.screen_y,
							"Battle_FX", obj_impact_display
						);
						_imp.sprite_index = data.sprite_impact;
						_imp.image_index = 0;
						_imp.image_speed = 1;
					}
				}
				
				// Done when animation reaches last frame
				if (_frame >= frame_count - 1) {
					instance_destroy(inst);
					inst = undefined;
					return true;
				}
				
				return false;
			}
		};
}

function cs_battle_music_push(_track) {
	return {
		track: _track,
		start: function() { obj_audio_controller.bmg_push(track, 0); },
		tick: function() { return true; }
	};	
}

function cs_battle_music_pop(_fade_frames) {
	return {
		fade_frames: _fade_frames,
		start: function() { obj_audio_controller.bgm_pop(fade_frames); },
		tick: function() { return true; }
	};	
}

function cs_battle_rotate_to(_angle, _duration) {
	return {
		angle: _angle,
		duration: _duration,
		done: false,
		start: function() {
			obj_battle_controller.scr_battle_rotate_to(angle, duration);
		},
		tick: function() {
			// Wait for the rotation to finish
			return !obj_battle_controller.rotating;
		}
	};	
}

function cs_battle_restore_anim() {
	return {
		start: function() { scr_battle_set_all_anim("idle", 0.15); },
		tick: function() { return true; }
	};	
}

function cs_ability(_user, _ability_id, _targets, _damage_frame=0) {

	return {
		user: _user,
		ability_id: _ability_id,
		targets: _targets,
		damage_frame: _damage_frame,
		ab: global.ability_data[$ _ability_id],
		inst: undefined,
		fired: false,
		
		start: function() {
			fired = false;
			// Play user animation
			if (user != noone) user.anim_state = ab.anim_user;
			
			// Spawn the ability's own animation sprite, if it has one
			if (struct_exists(ab, "anim_spr") && ab.anim_spr != noone) {
				inst = instance_create_layer(
					room_width / 2, room_height / 2,
					"Battle_FX", obj_ability_display
				);
				inst.sprite_index = ab.anim_apr;
				inst.image_index = 0;
				inst.image_speed = 1;
			}
		},
		
		tick: function() {
			var _frame = instance_exists(inst) ? floor(inst.image_index) : damage_frame;
			
			// Fire ability on the damage frame
			if (!fired && _frame >= damage_frame) {
				fired = true;
				scr_execute_ability(ability_id, user, targets);
			}
			
			// Done when sprite finishes (or immediately if no sprite)
			if (!instance_exists(inst)) return fired;
			if (floor(inst.image_index) <= sprite_get_number(inst.sprite_index) - 1) {
				instance_destroy(inst);
				return true;
			}
			return false;
		}
	};
}