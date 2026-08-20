/// scr_menu_page_sorcery(_mgr)
///
/// Out-of-battle sorcery menu: character -> spell grid -> View/Use.
/// Reuses the Items panel geometry (character list + status + item
/// grid layout translates directly) since visually it's the same
/// shape of screen. Only Field/Both use_zone spells are usable here;
/// Battle-only spells still show but "Use" is disabled.
function scr_menu_page_sorcery(_mgr) {
	var _page = {
		name: "sorcery",
		mgr: _mgr,
		level: 0,          // 0=char select, 1=spell grid, 2=view/use popup, 3=ally target picker
		char_select: 0,
		spell_select_index: 0,
		select_option_index: 0, // 0=View, 1=Use
		target_pick_index: 0,
		layout: scr_menu_layout().items, // shared geometry with Items

		enter: function(_param) {
			var _party_size = array_length(mgr._Party);
			if (char_select >= _mgr._party_size) { char_select = 0; }
		},

		step: function(_input) {
			var _L = self.layout;
			var _party_size = array_length(mgr._Party);

			if (level == 0) {
				var _nav = scr_menu_grid_nav(char_select, _mgr._party_size, _mgr._party_size, _input.right, _input.left, false, false);
				char_select = _nav.index;

				if (_input.back) { return "pop"; }

				if (_input.accept) {
					var _known = mgr._Party[char_select].char_sorceries;
					if (array_length(_known) > 0) {
						level = 1;
						spell_select_index = 0;
					}
				}
				return undefined;
			}

			if (level == 1) {
				var _known = mgr._Party[char_select].char_sorceries;
				var _count = array_length(_known);
				var _nav = scr_menu_grid_nav(spell_select_index, _count, _L.grid_cols, _input.right, _input.left, _input.up, _input.down);
				spell_select_index = _nav.index;

				if (_input.back) { level = 0; return undefined; }

				if (_input.accept) {
					select_option_index = 0;
					level = 2;
				}
				return undefined;
			}

			if (level == 2) {
				var _nav = scr_menu_grid_nav(select_option_index, 2, 2, _input.right, _input.left, false, false);
				select_option_index = _nav.index;

				if (_input.back) { level = 1; return undefined; }

				if (_input.accept) {
					var _sorc = mgr._Party[char_select].char_sorceries[spell_select_index];
					var _caster = mgr._Party[char_select];
					if (select_option_index == 1 && sorcery_usable_here(_sorc, _caster)) {
						if (scr_target_needs_picker(_sorc.target, "field")) {
							target_pick_index = 0;
							level = 3;
						} else {
							var _targets = scr_resolve_targets_auto(_caster, mgr, _sorc.target, "field", undefined);
							cast_sorcery(_caster, _sorc, _targets);
							level = 1;
						}
					}
					// select_option_index == 0 (View) intentionally does
					// nothing but leave the tooltip panel showing the
					// description - no separate details screen needed
					// unless you want one later.
				}
				return undefined;
			}

			if (level == 3) {
				var _party_size = array_length(mgr._Party);
				var _nav = scr_menu_grid_nav(target_pick_index, _party_size, _party_size, _input.right, _input.left, false, false);
				target_pick_index = _nav.index;

				if (_input.back) { level = 2; return undefined; }

				if (_input.accept) {
					var _sorc = mgr._Party[char_select].char_sorceries[spell_select_index];
					var _caster = mgr._Party[char_select];
					var _target = mgr._Party[target_pick_index];
					cast_sorcery(_caster, _sorc, [_target]);
					level = 1;
				}
				return undefined;
			}

			return undefined;
		},

		get_cursor: function() {
			var _L = self.layout;
			if (level == 0) {
				return { x: 16 + (32 * char_select), y: 28 };
			}
			if (level == 1) {
				var _nav = scr_menu_grid_nav(spell_select_index, 999999, _L.grid_cols, false, false, false, false);
				return {
					x: _L.inventory.x + 32 + (_L.cell * _nav.col),
					y: _L.inventory.y + 16 + (_L.cell * _nav.row)
				};
			}
			if (level == 2) {
				return { x: _L.inventory.x + 11 + (48 * select_option_index), y: 35 };
			}
			if (level == 3) {
				return { x: 16 + (32 * target_pick_index), y: 28 };
			}
			return undefined;
		},

		draw_gui: function() {
			var _L = self.layout;
			var _char = mgr._Party[char_select];
			var _known = _char.char_sorceries;
			var _count = array_length(_known);
			var _party_size = array_length(mgr._Party);

			// Character panel
			draw_sprite_ext(spr_menu_window, 0, _L.char_panel.x, _L.char_panel.y, _L.char_panel.w / sprite_get_width(spr_menu_window), _L.char_panel.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			for (var _i = 0; _i < _party_size; _i++) {
				var _pc = mgr._Party[_i];
				var _sp = struct_get(mgr.char_sprites, _pc.char_name).idle;
				var _yoff = (char_select == _i) ? _L.char_panel.y + 5 : _L.char_panel.y;
				draw_sprite(_sp, 0, 16 + (32 * _i), 32 + _yoff);
			}

			// Status panel (VP is the important stat here)
			draw_sprite_ext(spr_menu_window, 0, _L.status_panel.x, _L.status_panel.y, _L.status_panel.w / sprite_get_width(spr_menu_window), _L.status_panel.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _sx = 8;
			var _sy = _L.status_panel.y + 8;
			draw_text(_sx, _sy, _char.char_name);
			draw_text(_sx, _sy + 16, "VP " + string(_char.char_vp_current) + " / " + string(_char.char_vp_max));

			// Question panel
			draw_sprite_ext(spr_menu_window, 0, _L.question.x, _L.question.y, _L.question.w / sprite_get_width(spr_menu_window), _L.question.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			if (level == 0) { draw_text(_L.question.x + 12, _L.question.y + 12, "Whose sorcery?"); }
			else { draw_text(_L.question.x + 12, _L.question.y + 12, "Which sorcery?"); }

			// Spell grid panel
			draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, _L.inventory.y, _L.inventory.w / sprite_get_width(spr_menu_window), _L.inventory.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _i = 0;
			for (var _row = 0; _row < _L.grid_rows; _row++) {
				for (var _col = 0; _col < _L.grid_cols; _col++) {
					if (_i < _count) {
						var _sorc = _known[_i];
						var _ix = _L.inventory.x + 32 + (_L.cell * _col);
						var _iy = _L.inventory.y + 16 + (_L.cell * _row);
						if (!is_struct(_sorc)) {
							show_debug_message("char_sorceries[" + string(_i) + "] is not a struct - value: " + string(_sorc) + " type: " + typeof(_sorc));
						} else if (!variable_struct_exists(_sorc, "sprite")) {
							show_debug_message("char_sorceries[" + string(_i) + "] struct has no 'sprite' field. Fields: " + string(variable_struct_get_names(_sorc)));
						} else {
							show_debug_message("char_sorceries[" + string(_i) + "].sprite = " + string(_sorc.sprite) + " type: " + typeof(_sorc.sprite));
						}
						draw_sprite(asset_get_index(_sorc.sprite), 0, _ix, _iy);
						if (!sorcery_usable_here(_sorc, _char)) {
							draw_sprite_ext(asset_get_index(_sorc.sprite), 0, _ix, _iy, 1, 1, 0, c_gray, 0.5);
						}
						_i += 1;
					}
				}
			}

			// Tooltip panel - description + VP cost
			draw_sprite_ext(spr_menu_window, 0, _L.tooltip.x, _L.tooltip.y, _L.tooltip.w / sprite_get_width(spr_menu_window), _L.tooltip.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			if (level >= 1 && _count > 0) {
				var _sorc = _known[spell_select_index];
				draw_text_ext(_L.tooltip.x + 12, _L.tooltip.y + 12, _sorc.description, 8, _L.tooltip.w - 14);
			}

			// Coins-row equivalent: VP cost readout
			draw_sprite_ext(spr_menu_window, 0, _L.coins.x, _L.coins.y, _L.coins.w / sprite_get_width(spr_menu_window), _L.coins.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			if (level >= 1 && _count > 0) {
				var _sorc = _known[spell_select_index];
				draw_text(16, _L.coins.y + 12, "VP Cost: " + string(_sorc.vp_cost));
			}

			// View/Use popup
			if (level == 2 && _count > 0) {
				var _sorc = _known[spell_select_index];
				draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, 0, _L.tooltip.w / sprite_get_width(spr_menu_window), 72 / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
				draw_sprite(asset_get_index(_sorc.sprite), 0, _L.inventory.x + 9, 9);
				draw_text(_L.inventory.x + 27, 14, _sorc.name);

				draw_action_label(_L.inventory.x + 11, 35, "View", true);
				draw_action_label(_L.inventory.x + 59, 35, "Use", sorcery_usable_here(_sorc, _char));
			}

			// Ally target picker (level 3) - reuses the question panel to
			// prompt, and highlights the character strip like level 0
			// does, so the player picks a target the same way they'd
			// pick whose spell list to open.
			if (level == 3) {
				draw_text(_L.question.x + 12, _L.question.y + 12, "Use on whom?");
			}
		}
	};

	return _page;
}

/// cast_sorcery(_caster, _sorc, _targets)
/// Spends VP and dispatches the sorcery's effect. Shared entry point
/// so both the auto-resolved-target path and the picked-target path
/// go through the same VP-spend + dispatch logic exactly once.
function cast_sorcery(_caster, _sorc, _targets) {
	_caster.char_vp_current = max(0, _caster.char_vp_current - _sorc.vp_cost);

	var _context = {
		zone: "field",
		power: _sorc.power,
		source: _sorc
	};

	scr_effect_dispatch(_sorc.effect, _caster, _targets, _context);
}

/// sorcery_usable_here(_sorc, _char)
/// True if this spell can be cast from the field menu right now: its
/// use_zone allows field use, and the character has enough VP.
function sorcery_usable_here(_sorc, _char) {
	var _zone_ok = (_sorc.use_zone == "Field" || _sorc.use_zone == "Both");
	var _vp_ok = (_char.char_vp_current >= _sorc.vp_cost);
	return _zone_ok && _vp_ok;
}
