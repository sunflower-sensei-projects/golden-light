/// scr_menu_page_faefolk(_mgr)
///
/// PLACEHOLDER STRUCTURE - you haven't given me a Faefolk data shape
/// yet, so this assumes `_char.char_faefolk` is an array of structs
/// with at minimum { name, sprite, description }, mirroring how
/// sorceries are attached to a character. Swap the field names below
/// once you confirm the real struct - the grid-nav/cursor/draw
/// scaffolding won't need to change, just the field lookups.
function scr_menu_page_faefolk(_mgr) {
	var _page = {
		name: "faefolk",
		mgr: _mgr,
		level: 0,        // 0=char select, 1=faefolk grid
		char_select: 0,
		fae_select_index: 0,
		layout: scr_menu_layout().items,

		enter: function(_param) {
			var _party_size = array_length(mgr._Party);
			if (char_select >= _party_size) { char_select = 0; }
		},

		step: function(_input) {
			var _L = self.layout;
			var _party_size = array_length(mgr._Party);

			if (level == 0) {
				var _nav = scr_menu_grid_nav(char_select, _party_size, _party_size, _input.right, _input.left, false, false);
				char_select = _nav.index;

				if (_input.back) { return "pop"; }

				if (_input.accept) {
					// NOTE: assumes char_faefolk field name - adjust once confirmed.
					var _fae = mgr._Party[char_select].char_faefolk;
					if (!is_undefined(_fae) && array_length(_fae) > 0) {
						level = 1;
						fae_select_index = 0;
					}
				}
				return undefined;
			}

			if (level == 1) {
				var _fae = mgr._Party[char_select].char_faefolk;
				var _count = array_length(_fae);
				var _nav = scr_menu_grid_nav(fae_select_index, _count, _L.grid_cols, _input.right, _input.left, _input.up, _input.down);
				fae_select_index = _nav.index;

				if (_input.back) { level = 0; return undefined; }
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
				var _nav = scr_menu_grid_nav(fae_select_index, 999999, _L.grid_cols, false, false, false, false);
				return {
					x: _L.inventory.x + 32 + (_L.cell * _nav.col),
					y: _L.inventory.y + 16 + (_L.cell * _nav.row)
				};
			}
			return undefined;
		},

		draw_gui: function() {
			var _L = self.layout;
			var _party_size = array_length(mgr._Party);

			draw_sprite_ext(spr_menu_window, 0, _L.char_panel.x, _L.char_panel.y, _L.char_panel.w / sprite_get_width(spr_menu_window), _L.char_panel.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			for (var _i = 0; _i < _party_size; _i++) {
				var _pc = mgr._Party[_i];
				var _sp = struct_get(mgr.char_sprites, _pc.char_name).idle;
				var _yoff = (char_select == _i) ? _L.char_panel.y + 5 : _L.char_panel.y;
				draw_sprite(_sp, 0, 16 + (32 * _i), 32 + _yoff);
			}

			draw_sprite_ext(spr_menu_window, 0, _L.question.x, _L.question.y, _L.question.w / sprite_get_width(spr_menu_window), _L.question.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			draw_text(_L.question.x + 12, _L.question.y + 12, (level == 0) ? "Whose Faefolk?" : "Bonded Faefolk");

			draw_sprite_ext(spr_menu_window, 0, _L.inventory.x, _L.inventory.y, _L.inventory.w / sprite_get_width(spr_menu_window), _L.inventory.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			var _fae = mgr._Party[char_select].char_faefolk;
			if (!is_undefined(_fae)) {
				var _count = array_length(_fae);
				var _i = 0;
				for (var _row = 0; _row < _L.grid_rows; _row++) {
					for (var _col = 0; _col < _L.grid_cols; _col++) {
						if (_i < _count) {
							var _ix = _L.inventory.x + 32 + (_L.cell * _col);
							var _iy = _L.inventory.y + 16 + (_L.cell * _row);
							draw_sprite(asset_get_index(_fae[_i].sprite), 0, _ix, _iy);
							_i += 1;
						}
					}
				}
			}

			draw_sprite_ext(spr_menu_window, 0, _L.tooltip.x, _L.tooltip.y, _L.tooltip.w / sprite_get_width(spr_menu_window), _L.tooltip.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			if (level == 1 && !is_undefined(_fae) && array_length(_fae) > 0) {
				draw_text_ext(_L.tooltip.x + 12, _L.tooltip.y + 12, _fae[fae_select_index].description, 8, _L.tooltip.w - 14);
			}
		}
	};

	return _page;
}
