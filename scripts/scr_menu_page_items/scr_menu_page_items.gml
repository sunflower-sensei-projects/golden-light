/// scr_menu_page_items(_mgr)
///
/// Replaces obj_menu_items. Internal drill-down (character -> item ->
/// action -> drop-qty -> confirm) is kept as page-internal `level`
/// state, same concept as the original menu_level, but grid navigation
/// and equip-delta math are now delegated to shared scripts instead of
/// being hand-written per level.
function scr_menu_page_items(_mgr) {
	var _page = {
		name: "items",
		mgr: _mgr,
		level: 0,          // 0=char select, 1=item grid, 2=action menu, 3=drop qty, 4=confirm drop, 5=ally target picker
		char_select: 0,
		item_select_index: 0,
		select_option_index: 0,
		item_drop_amt: 1,
		drop_item: false,
		target_pick_index: 0,
		char_new: { hp: 0, vp: 0, attack: 0, defense: 0, agility: 0, luck: 0 },
		layout: scr_menu_layout().items,

		enter: function(_param) {
			// Refresh in case an item was dropped/consumed while a
			// deeper level was open, or on first entry.
			if (char_select >= _mgr._party_size) { char_select = 0; }

			var _inv_len = array_length(global.char_invs[char_select]);
			if (item_select_index >= _inv_len) {
				item_select_index = max(0, _inv_len - 1);
			}
		},

		step: function(_input) {
			var _L = self.layout;

			if (level == 0) {
				var _nav = scr_menu_grid_nav(char_select, _mgr._party_size, _mgr._party_size, _input.right, _input.left, false, false);
				char_select = _nav.index;

				if (_input.back) { return "pop"; }

				if (_input.accept) {
					if (array_length(global.char_invs[char_select]) > 0) {
						level = 1;
						item_select_index = 0;
					}
				}
				return undefined;
			}

			if (level == 1) {
				var _inv = global.char_invs[char_select];
				var _item_max = array_length(_inv);
				var _nav = scr_menu_grid_nav(item_select_index, _item_max, _L.grid_cols, _input.right, _input.left, _input.up, _input.down);
				item_select_index = _nav.index;

				if (_input.back) { level = 0; return undefined; }

				if (_input.accept) {
					select_option_index = 0;
					var _item = _inv[item_select_index];
					var _char = mgr._Party[char_select];
					char_new = scr_menu_equip_delta(_char, _item);
					level = 2;
				}
				return undefined;
			}

			if (level == 2) {
				var _nav = scr_menu_grid_nav(select_option_index, 6, _L.option_cols, _input.right, _input.left, _input.up, _input.down);
				select_option_index = _nav.index;

				if (_input.back) { level = 1; return undefined; }

				if (_input.accept) {
					var _item = global.char_invs[char_select][item_select_index];
					var _user = mgr._Party[char_select];
					switch (select_option_index) {
						case 0: // Use
							if (canUseItem(_item)) {
								if (scr_target_needs_picker(_item.target, "field")) {
									target_pick_index = 0;
									level = 5;
								} else {
									var _targets = scr_resolve_targets_auto(_user, mgr, _item.target, "field", undefined);
									use_item(_user, char_select, item_select_index, _targets);
									level = 1;
								}
							}
							break;
						case 1: // Equip
							if (canEquipItem(_item) && _item.item_equipped == false) {
								equipItem(char_select, item_select_index);
								smallTextbox("Equipped");
							}
							break;
						case 2: // Details
							break;
						case 3: // Give
							break;
						case 4: // Unequip
							if (canEquipItem(_item) && _item.item_equipped == true) {
								unequipItem(char_select, item_select_index);
								smallTextbox("Unequipped");
							}
							break;
						case 5: // Drop
							if (canDropItem(_item)) {
								item_drop_amt = 1;
								if (_item.item_type == "consume" && _item.item_amt_held > 1) {
									level = 3;
								} else {
									level = 4;
								}
							}
							break;
					}
				}
				return undefined;
			}

			if (level == 5) {
				var _party_size = array_length(mgr._Party);
				var _nav = scr_menu_grid_nav(target_pick_index, _mgr._party_size, _mgr._party_size, _input.right, _input.left, false, false);
				target_pick_index = _nav.index;

				if (_input.back) { level = 2; return undefined; }

				if (_input.accept) {
					var _user = mgr._Party[char_select];
					var _target = mgr._Party[target_pick_index];
					use_item(_user, char_select, item_select_index, [_target]);
					// Using the item may have emptied the slot entirely
					// (last stack consumed) - re-clamp same as enter() does.
					var _inv_len = array_length(global.char_invs[char_select]);
					if (item_select_index >= _inv_len) {
						item_select_index = max(0, _inv_len - 1);
					}
					level = (_inv_len > 0) ? 1 : 0;
				}
				return undefined;
			}

			if (level == 3) {
				var _item = global.char_invs[char_select][item_select_index];
				if (_input.right) {
					item_drop_amt = (item_drop_amt < _item.item_amt_held) ? item_drop_amt + 1 : 1;
				}
				if (_input.left) {
					item_drop_amt = (item_drop_amt > 1) ? item_drop_amt - 1 : _item.item_amt_held;
				}
				if (_input.accept) { level = 4; }
				if (_input.back) { level = 2; }
				return undefined;
			}

			if (level == 4) {
				if (_input.up || _input.down) {
					drop_item = !drop_item;
				}
				if (_input.accept) {
					if (drop_item) {
						var _check = dropItem(char_select, item_select_index, item_drop_amt);
						smallTextbox("Dropped.");
						drop_item = false;
						if (_check > 0) {
							level = 2;
						} else {
							item_select_index = 0;
							select_option_index = 0;
							level = (array_length(global.char_invs[char_select]) > 0) ? 1 : 0;
						}
					} else {
						level = 2;
					}
				}
				if (_input.back) { level = 3; }
				return undefined;
			}

			return undefined;
		},

		get_cursor: function() {
			var _L = self.layout;
			if (level == 0) {
				return { x: 16 + _L.char_panel.x + (32 * char_select), y: 28 + _L.char_panel.y };
			}
			if (level == 1) {
				var _nav = scr_menu_grid_nav(item_select_index, 999999, _L.grid_cols, false, false, false, false);
				return {
					x: _L.inventory.x + 32 + (_L.cell * _nav.col),
					y: _L.inventory.y + 16 + (_L.cell * _nav.row)
				};
			}
			if (level == 2) {
				var _nav = scr_menu_grid_nav(select_option_index, 999999, _L.option_cols, false, false, false, false);
				return {
					x: _L.inventory.x + 11 + (48 * _nav.col),
					y: 35 + (16 * _nav.row)
				};
			}
			if (level == 3) {
				return { x: _L.inventory.x + 11 + string_width("Drop: "), y: 52 };
			}
			if (level == 4) {
				var _y = drop_item ? (64 + 14 + 16) : (64 + 14 + 40);
				return { x: _L.inventory.x + 11 + 16, y: _y };
			}
			if (level == 5) {
				return { x: 16 + (32 * target_pick_index), y: 28 };
			}
			return undefined;
		},

		draw_gui: function() {
			var _L = self.layout;
			var _char = mgr._Party[char_select];
			var _inv = global.char_invs[char_select];
			var _inv_len = array_length(_inv);
			var _party_size = array_length(mgr._Party);

			// Character panel
			draw_sprite_ext(spr_menu_window, 0, _L.char_panel.x, _L.char_panel.y, _L.char_panel.w / sprite_get_width(spr_menu_window), _L.char_panel.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			for (var _i = 0; _i < _party_size; _i++) {
				var _pc = mgr._Party[_i];
				var _sp = struct_get(mgr.char_sprites, _pc.char_name).idle;
				var _yoff = (char_select == _i) ? _L.char_panel.y + 5 : _L.char_panel.y;
				draw_sprite(_sp, 0, 16 + (32 * _i), 32 + _yoff);
			}

			// Status panel
			draw_sprite_ext(spr_menu_window, 0, _L.status_panel.x, _L.status_panel.y, _L.status_panel.w / sprite_get_width(spr_menu_window), _L.status_panel.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _faces = struct_get(mgr.face_sprites, _char.char_name);
			var _sx = 5 + 3;
			var _sy = _L.status_panel.y + 5 + 3;
			draw_sprite(_faces.idle, 0, _sx, _sy);
			draw_text(_sx + 32, _sy, _char.char_name);
			draw_text(_sx + 48, _sy + 16, "Lv " + string(_char.char_level));

			if (level == 0) {
				draw_text(_sx, _sy + 32, string(_char.char_class));
				draw_text(_sx, _sy + 40, "HP " + string(_char.char_hp_current) + " / " + string(_char.char_hp_max));
				draw_text(_sx, _sy + 48, "VP " + string(_char.char_vp_current) + " / " + string(_char.char_vp_max));
				draw_text(_sx, _sy + 64, "Exp");
				draw_text(_sx, _sy + 72, string(_char.char_exp));
			}
			else {
				draw_stat_row(_sx, _sy + 32, "HP", _char.char_hp_max, (level >= 2) ? char_new.hp : _char.char_hp_max, level >= 2);
				draw_stat_row(_sx, _sy + 48, "VP", _char.char_vp_max, (level >= 2) ? char_new.vp : _char.char_vp_max, level >= 2);
				draw_stat_row(_sx, _sy + 64, "Attack", _char.attack, (level >= 2) ? char_new.attack : _char.attack, level >= 2);
				draw_stat_row(_sx, _sy + 80, "Defense", _char.defense, (level >= 2) ? char_new.defense : _char.defense, level >= 2);
				draw_stat_row(_sx, _sy + 96, "Agility", _char.agility, (level >= 2) ? char_new.agility : _char.agility, level >= 2);
				draw_stat_row(_sx, _sy + 112, "Luck", _char.luck, (level >= 2) ? char_new.luck : _char.luck, level >= 2);
			}

			// Question panel
			draw_sprite_ext(spr_menu_window, 0, _L.question.x, _L.question.y, _L.question.w / sprite_get_width(spr_menu_window), _L.question.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			if (level == 0) { draw_text(_L.question.x + 12, _L.question.y + 12, "Whose item?"); }
			else if (level == 1) { draw_text(_L.question.x + 12, _L.question.y + 12, "Which item?"); }

			// Inventory grid panel
			draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, _L.inventory.y, _L.inventory.w / sprite_get_width(spr_menu_window), _L.inventory.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _item_i = 0;
			for (var _row = 0; _row < _L.grid_rows; _row++) {
				for (var _col = 0; _col < _L.grid_cols; _col++) {
					if (_item_i < _inv_len) {
						var _it = _inv[_item_i];
						var _ix = _L.inventory.x + 32 + (_L.cell * _col);
						var _iy = _L.inventory.y + 16 + (_L.cell * _row);
						draw_sprite(_it.item_sprite, 0, _ix, _iy);
						if (_it.item_equipped) {
							draw_sprite(spr_item_UI_eq, 0, _ix + 8, _iy + 8);
						} else if (_it.item_type == "consume" && _it.item_amt_held > 1) {
							draw_sprite(spr_item_UI_num, _it.item_amt_held - 1, _ix + 11, _iy + 11);
						}
						_item_i += 1;
					}
				}
			}

			// Tooltip panel
			draw_sprite_ext(spr_menu_window, 0, _L.tooltip.x, _L.tooltip.y, _L.tooltip.w / sprite_get_width(spr_menu_window), _L.tooltip.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			if ((level == 1 || level == 2) && _inv_len > 0) {
				draw_text_ext(_L.tooltip.x + 12, _L.tooltip.y + 12, string(_inv[item_select_index].item_desc), 8, _L.tooltip.w - 14);
			}

			// Coins panel
			draw_sprite_ext(spr_menu_window, 0, _L.coins.x, _L.coins.y, _L.coins.w / sprite_get_width(spr_menu_window), _L.coins.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			draw_text(16, _L.coins.y + 12, string(global.coins) + " Coins");
			if (level >= 2 && _inv_len > 0) {
				var _held = (_inv[item_select_index].item_type == "consume") ? string(_inv[item_select_index].item_amt_held) : "1";
				draw_text(16 + 120, _L.coins.y + 12, "Held: " + _held);
			}

			// Action popup (level 2)
			if (level == 2 && _inv_len > 0) {
				var _it = _inv[item_select_index];
				draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, 0, _L.tooltip.w / sprite_get_width(spr_menu_window), 72 / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
				draw_sprite(_it.item_sprite, 0, _L.inventory.x + 9, 9);
				draw_text(_L.inventory.x + 27, 14, string(_it.item_name));

				draw_action_label(_L.inventory.x + 11, 35, "Use", canUseItem(_it));
				draw_action_label(_L.inventory.x + 59, 35, "Equip", canEquipItem(_it) && !_it.item_equipped);
				draw_text(_L.inventory.x + 107, 35, "Details");
				draw_action_label(_L.inventory.x + 11, 51, "Give", array_length(global.char_invs) > 1);
				draw_action_label(_L.inventory.x + 59, 51, "Unequip", canEquipItem(_it) && _it.item_equipped);
				draw_action_label(_L.inventory.x + 107, 51, "Drop", canDropItem(_it));
			}

			// Drop-quantity popup (level 3)
			if (level == 3 && _inv_len > 0) {
				var _it = _inv[item_select_index];
				draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, 0, _L.tooltip.w / sprite_get_width(spr_menu_window), 72 / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
				draw_sprite(_it.item_sprite, 0, _L.inventory.x + 9, 9);
				draw_text(_L.inventory.x + 27, 14, string(_it.item_name));
				draw_text(_L.inventory.x + 11, 40, "Left: " + string(_it.item_amt_held - item_drop_amt));
				draw_text(_L.inventory.x + 11, 48, "Drop: " + string(item_drop_amt));
				for (var _k = 0; _k < 30; _k++) {
					var _spr = spr_UI_item_count_b;
					if (_k < item_drop_amt) { _spr = spr_UI_item_count_c; }
					else if (_k < _it.item_amt_held) { _spr = spr_UI_item_count_a; }
					draw_sprite(_spr, 0, _L.inventory.x + 67 + (2 * _k), 48);
				}
			}

			// Confirm-drop popup (level 4)
			if (level == 4) {
				draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, 64, 128 / sprite_get_width(spr_menu_window), 80 / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
				draw_text(_L.inventory.x + 27, 78, "Really drop?");
				draw_text(_L.inventory.x + 27, 94, "Yes");
				draw_text(_L.inventory.x + 27, 118, "No");
			}

			// Ally target picker (level 5)
			if (level == 5) {
				draw_text(_L.question.x + 12, _L.question.y + 12, "Use on whom?");
			}
		}
	};

	return _page;
}

/// use_item(_user, _char_index, _item_index, _targets)
///
/// Shared entry point for actually using an item - handles the
/// consumption side (stack decrement, or durability roll for
/// non-consumables) and dispatches the item's effect through the same
/// registry sorceries use.
///
/// NOTE: durability/breakage isn't built yet per your notes - the
/// non-consumable branch is written but gated so it's a no-op until
/// an item struct actually has a durability field. Nothing needs to
/// change here when you add it beyond filling in that branch's roll.
function use_item(_user, _char_index, _item_index, _targets) {
	var _item = global.char_invs[_char_index][_item_index];

	var _context = {
		zone: "field",
		power: _item.power,
		source: _item
	};

	scr_effect_dispatch(_item.effect, _user, _targets, _context);

	if (_item.item_type == "consume") {
		_item.item_amt_held -= 1;
		if (_item.item_amt_held <= 0) {
			array_delete(global.char_invs[_char_index], _item_index, 1);
		}
	}
	else if (variable_struct_exists(_item, "durability")) {
		// Placeholder for the damage-roll-on-use system described:
		// roll against the item's durability; on failure, mark it
		// broken so canUseItem() can gate it out until repaired.
		// Left unimplemented until the durability field/roll rules exist.
	}
	// Non-consumable items without a durability field (current state):
	// using them has no stock/durability cost, matching today's rules.
}

/// draw_stat_row(x, y, label, current, projected, show_delta)
/// Small helper replacing the six copy-pasted "draw stat + maybe draw
/// an up/down arrow with the projected value" blocks per stat.
function draw_stat_row(_x, _y, _label, _current, _projected, _show_delta) {
	draw_text(_x, _y, _label);
	draw_text(_x + 48, _y, string(_current));
	if (_show_delta && _projected != _current) {
		var _arrow = (_projected > _current) ? spr_UI_increase_arrow : spr_UI_decrease_arrow;
		var _ax = _x + 48 + string_width(string(_current)) + 8;
		draw_sprite(_arrow, 0, _ax, _y);
		draw_text(_ax + 16, _y, string(_projected));
	}
}

/// draw_action_label(x, y, text, enabled)
/// Replaces the repeated draw_text_ext_color white/gray branch pairs
/// in the item action popup.
function draw_action_label(_x, _y, _text, _enabled) {
	var _col = _enabled ? c_white : c_gray;
	draw_text_ext_color(_x, _y, _text, 0, 48, _col, _col, _col, _col, 1);
}
