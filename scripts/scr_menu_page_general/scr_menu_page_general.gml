/// scr_menu_page_general(_mgr)
///
/// Replaces obj_menu_general + obj_menu_status_sm as a single page
/// struct. This is always the bottom of the stack - popping it closes
/// the whole menu (the controller handles that when the stack empties).
///
/// Options are filtered against scr_menu_is_unlocked() every time the
/// page is entered (first open, and every time a pushed submenu is
/// popped back to this page) - so if something gets unlocked while a
/// submenu was open, the icon row picks it up the moment control
/// returns here, without needing the submenu to know anything about
/// unlock state itself.
function scr_menu_page_general(_mgr) {
	// Full catalog of possible options, in canonical order. `key`
	// matches scr_menu_unlocks' field names. `open` builds the page to
	// push - kept as a function reference so building six page structs
	// up front (most of which may be locked) never happens.
	var _catalog = [
		{ key: "sorcery",  label: "Sorcery",  icon: spr_option_sorcery_beta,  open: function(_m) { return scr_menu_page_sorcery(_m); } },
		{ key: "faefolk",  label: "Faefolk",  icon: spr_option_faefolk_beta,  open: function(_m) { return scr_menu_page_faefolk(_m); } },
		{ key: "items",    label: "Items",    icon: spr_option_items_beta,    open: function(_m) { return scr_menu_page_items(_m); } },
		{ key: "status",   label: "Status",   icon: spr_option_status_beta,   open: function(_m) { return scr_menu_page_status(_m); } },
		{ key: "party",    label: "Party",    icon: spr_option_party_beta,    open: function(_m) { return scr_menu_page_party(_m); } },
		{ key: "settings", label: "Settings", icon: spr_option_settings_beta, open: function(_m) { return scr_menu_page_settings(_m); } }
	];

	var _page = {
		name: "general",
		mgr: _mgr,
		pos: 0,
		catalog: _catalog,
		visible: [],  // filtered subset of catalog - rebuilt in enter()
		layout: scr_menu_layout(),
		pulse: scr_pulse_init(),
		reveals: {},  // key -> reveal struct, only populated for options currently mid-animation

		enter: function(_param) {
			// Rebuild the visible list from current unlock state every
			// time this page becomes the active one - covers both first
			// open and returning here after a submenu closes.
			visible = [];
			for (var _i = 0; _i < array_length(catalog); _i++) {
				var _entry = catalog[_i];
				if (scr_menu_is_unlocked(_entry.key)) {
					array_push(visible, _entry);
					// Arm the reveal animation only once - consuming the
					// pending flag here means a second enter() (e.g.
					// backing out of a submenu 10 frames later) won't
					// re-trigger it, since scr_menu_consume_pending_reveal
					// already cleared the flag on the first call.
					if (scr_menu_consume_pending_reveal(_entry.key)) {
						reveals[$ _entry.key] = scr_reveal_trigger(scr_reveal_init());
					}
				}
			}
			if (pos >= array_length(visible)) {
				pos = 0;
			}
		},

		step: function(_input) {
			pulse = scr_pulse_advance(pulse);

			// Advance any in-progress reveal animations and drop them
			// once finished, so draw_gui only ever iterates active ones.
			var _keys = variable_struct_get_names(reveals);
			for (var _k = 0; _k < array_length(_keys); _k++) {
				var _key = _keys[_k];
				reveals[$ _key] = scr_reveal_advance(reveals[$ _key]);
				if (!scr_reveal_active(reveals[$ _key])) {
					variable_struct_remove(reveals, _key);
				}
			}

			var _op_len = array_length(visible);
			if (_op_len <= 0) {
				// Nothing unlocked yet - shouldn't normally happen since
				// Items/Status/Settings default to unlocked, but guard
				// against an empty menu locking the player out entirely.
				if (_input.back) { return "pop"; }
				return undefined;
			}

			var _nav = scr_menu_grid_nav(pos, _op_len, _op_len, _input.right, _input.left, false, false);
			pos = _nav.index;

			if (_input.accept) {
				pulse = scr_pulse_trigger(pulse);
				return { push: visible[pos].open(mgr) };
			}

			// _input.back on the root page closes the whole menu, same
			// as the old "_back or _menu -> instance_destroy" behavior.
			if (_input.back) {
				return "pop";
			}

			return undefined;
		},

		get_cursor: function() {
			// The general menu's own option highlight is drawn via the
			// sprite-swap technique from the original (scaled-up sprite
			// for the selected option), not the shared arrow pointer, so
			// no cursor position is reported here.
			return undefined;
		},

		draw_gui: function() {
			var _L = self.layout;
			var _icon_w = 32;
			var _icon_count = array_length(visible);

			if (_icon_count <= 0) { return; } // nothing unlocked - draw nothing rather than an empty frame

			var _icons_w = _icon_w * _icon_count;
			var _label_w = 128;
			var _row_h = 32;
			var _total_w = _icons_w + _label_w;

			// Whole cluster (icons + label) centered horizontally at the
			// bottom of the screen, as one unit. Recomputed from the
			// CURRENT visible count every frame, so the cluster re-centers
			// automatically as options unlock over the course of the game
			// - no separate resize step needed anywhere else.
			var _row_x = (_L.gui_w - _total_w) / 2;
			var _row_y = _L.gui_h - _row_h;

			// Icon row background
			draw_sprite_ext(spr_menu_window, 0, _row_x, _row_y, _icons_w / sprite_get_width(spr_menu_window), _row_h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);

			var _pulse_scale = scr_pulse_scale(pulse);
			for (var _i = 0; _i < _icon_count; _i++) {
				var _ix = _row_x + (_i * _icon_w);
				var _iy = _row_y;
				var _entry = visible[_i];
				var _has_reveal = variable_struct_exists(reveals, _entry.key);
				var _reveal = _has_reveal ? reveals[$ _entry.key] : undefined;

				var _base_scale = (_i == pos) ? 1.5 : 1.0;
				if (_i == pos && _pulse_scale > 1.0) {
					// Resting selected scale is 1.5x; the pulse briefly
					// pushes past that on the exact frame of confirm, then
					// settles back to the normal 1.5x resting state.
					_base_scale = _pulse_scale;
				}

				if (_has_reveal) {
					// Mid-reveal: icon fades/scales in under an expanding
					// gold ring instead of drawing at full opacity/scale
					// immediately - this is the one place motion is used
					// outside the confirm-pulse, and only plays once per
					// option, ever.
					var _cx = _ix + (_icon_w / 2);
					var _cy = _iy + (_icon_w / 2);
					scr_reveal_draw(_reveal, _cx, _cy);

					var _reveal_scale = scr_reveal_icon_scale(_reveal, _base_scale);
					var _reveal_alpha = scr_reveal_icon_alpha(_reveal);
					draw_sprite_ext(_entry.icon, 0, _ix, _iy, _reveal_scale, _reveal_scale, 0, c_white, _reveal_alpha);
				} else if (_i == pos) {
					draw_sprite_ext(_entry.icon, 0, _ix, _iy, _base_scale, _base_scale, 0, c_white, 1);
				} else {
					draw_sprite(_entry.icon, 0, _ix, _iy);
				}
			}

			// Label box sits to the right of the icon row, same row -
			// not stacked above it.
			var _label_x = _row_x + _icons_w;
			draw_sprite_ext(spr_menu_window, 0, _label_x, _row_y, _label_w / sprite_get_width(spr_menu_window), _row_h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);
			draw_text(_label_x + _L.border + 2, _row_y + _L.border, visible[pos].label);

			// --- Party status strip (formerly obj_menu_status_sm) ---
			var _s = _L.status_sm;
			var _party_size = array_length(mgr._Party);
			var _strip_w = _s.cell_w * _party_size;

			draw_sprite_ext(spr_menu_window, 0, _L.gui_w - _strip_w, 0, _strip_w / sprite_get_width(spr_menu_window), _s.cell_h / sprite_get_height(spr_menu_window), 0, scr_panel_tint(), 1);

			for (var _i = 0; _i < _party_size; _i++) {
				var _char = mgr._Party[_i];
				var _cx = _L.gui_w - _strip_w + _L.border + (_s.cell_w * _i);
				var _cy = _L.border;

				draw_text(_cx, _cy, _char.char_name);
				draw_sprite_ext(spr_healthbar_back, 0, _cx + 12, _cy + 16, _s.bar_w, 1, 0, c_white, 1);
				draw_sprite_ext(spr_healthbar_top, 0, _cx + 12, _cy + 16, (_char.char_hp_current / _char.char_hp_max) * _s.bar_w, 1, 0, c_white, 1);
				draw_text(_cx, _cy + 16, "HP " + string(_char.char_hp_current));

				draw_sprite_ext(spr_healthbar_back, 0, _cx + 12, _cy + 32, _s.bar_w, 1, 0, c_white, 1);
				draw_sprite_ext(spr_healthbar_top, 0, _cx + 12, _cy + 32, (_char.char_vp_current / _char.char_vp_max) * _s.bar_w, 1, 0, c_white, 1);
				draw_text(_cx, _cy + 32, "VP " + string(_char.char_vp_current));
			}
		}
	};

	return _page;
}
