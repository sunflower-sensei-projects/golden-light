/// scr_menu_page_party(_mgr)
///
/// Party reordering: cursor moves over party slots; accept "picks up"
/// the member in that slot (highlighted), moving the cursor again and
/// accepting again "places" them into the new slot, shifting everyone
/// between the old and new position over by one - like sliding a card
/// out of a hand and back in elsewhere. First 4 slots are the active
/// battle party (per your existing rule); slots beyond 4 are reserve.
function scr_menu_page_party(_mgr) {
	var _page = {
		name: "party",
		mgr: _mgr,
		cursor_index: 0,
		held_index: -1,   // -1 = nothing picked up
		layout: scr_menu_layout().party,

		enter: function(_param) {
			var _party_size = array_length(mgr._Party);
			if (cursor_index >= _party_size) { cursor_index = 0; }
		},

		step: function(_input) {
			var _L = self.layout;
			var _party_size = array_length(mgr._Party);
			var _nav = scr_menu_grid_nav(cursor_index, _party_size, _L.cols, _input.right, _input.left, _input.up, _input.down);
			cursor_index = _nav.index;

			if (_input.back) {
				if (held_index != -1) {
					// Cancel the pick-up rather than leaving the menu.
					held_index = -1;
					return undefined;
				}
				return "pop";
			}

			if (_input.accept) {
				if (held_index == -1) {
					held_index = cursor_index;
				}
				else if (held_index == cursor_index) {
					// Placed back where it started - no-op.
					held_index = -1;
				}
				else {
					move_party_member(mgr, held_index, cursor_index);
					held_index = -1;
				}
			}

			return undefined;
		},

		get_cursor: function() {
			var _L = self.layout;
			var _col = cursor_index mod _L.cols;
			var _row = cursor_index div _L.cols;
			return {
				x: _L.slot.x + (_col * (_L.slot.w + _L.slot.gap)) + (_L.slot.w / 2) - 8,
				y: _L.slot.y - 16
			};
		},

		draw_gui: function() {
			var _L = self.layout;
			var _party_size = array_length(mgr._Party);

			for (var _i = 0; _i < _party_size; _i++) {
				var _col = _i mod _L.cols;
				var _row = _i div _L.cols;
				var _sx = _L.slot.x + (_col * (_L.slot.w + _L.slot.gap));
				var _sy = _L.slot.y + (_row * (_L.slot.h + _L.slot.gap));

				draw_sprite_ext(spr_menu_window, 0, _sx, _sy, _L.slot.w / sprite_get_width(spr_menu_window), _L.slot.h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);

				var _char = mgr._Party[_i];
				var _sp = struct_get(mgr.char_sprites, _char.char_name).idle;

				var _alpha = (held_index == _i) ? 0.5 : 1;
				draw_sprite_ext(_sp, 0, _sx + (_L.slot.w / 2) - 8, _sy + (_L.slot.h / 2) - 16, 1, 1, 0, c_white, _alpha);
				draw_text(_sx + 4, _sy + _L.slot.h - 14, _char.char_name);

				// Mark the active-battle-party boundary (first 4 slots).
				if (_i == 3 && _party_size > 4) {
					draw_text(_sx + _L.slot.w + (_L.slot.gap / 2) - 4, _sy, "|");
				}
			}

			if (held_index != -1) {
				draw_text(_L.slot.x, _L.slot.y - 16, "Holding: " + mgr._Party[held_index].char_name);
			} else {
				draw_text(_L.slot.x, _L.slot.y - 16, "Select a member to move.");
			}
		}
	};

	return _page;
}

/// move_party_member(_mgr, _from, _to)
/// Removes the member at _from and reinserts them at _to, shifting
/// everyone between the two positions over by one slot - the "pull a
/// card out, slide it back in elsewhere" behavior described for the
/// Party menu.
function move_party_member(_mgr, _from, _to) {
	var _member = _mgr._Party[_from];
	array_delete(_mgr._Party, _from, 1);
	array_insert(_mgr._Party, _to, _member);
}
