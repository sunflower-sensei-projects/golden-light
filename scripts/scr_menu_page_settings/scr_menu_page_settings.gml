/// scr_menu_page_settings(_mgr)
///
/// Settings screen. Currently one control: Panel Hue, a 0-255 slider
/// that recolors every menu panel across the whole system live (see
/// scr_panel_hue.gml). Structured so additional settings can be added
/// as more rows in the same list/step pattern later.
function scr_menu_page_settings(_mgr) {
	var _page = {
		name: "settings",
		mgr: _mgr,
		layout: scr_menu_layout().settings,
		HUE_NUDGE: 4, // per-input-event change in scr_menu_grid_nav terms; autorepeat handles the rest

		enter: function(_param) {
			scr_panel_hue_init();
		},

		step: function(_input) {
			if (_input.back) { return "pop"; }

			// Left/right directly adjust the hue value - this isn't a
			// grid-nav case (there's only one row/one value), so it's
			// handled directly rather than through scr_menu_grid_nav.
			// _input.right/left are already autorepeat-aware (see
			// scr_menu_input), so holding the direction scrubs smoothly.
			if (_input.right) {
				scr_panel_hue_set(global.settings_panel_hue + HUE_NUDGE);
			}
			if (_input.left) {
				scr_panel_hue_set(global.settings_panel_hue - HUE_NUDGE);
			}

			return undefined;
		},

		get_cursor: function() {
			return undefined;
		},

		draw_gui: function() {
			var _L = self.layout;
			var _tint = scr_panel_tint();
			var _border = scr_panel_border_tint();

			draw_sprite_ext(spr_menu_window, 0, _L.panel.x, _L.panel.y, _L.panel.w / sprite_get_width(spr_menu_window), _L.panel.h / sprite_get_height(spr_menu_window), 0, _tint, 1);
			draw_text(_L.panel.x + 16, _L.panel.y + 16, "Settings");

			// --- Panel Hue row ---
			var _row_y = _L.panel.y + 48;
			draw_text(_L.panel.x + 16, _row_y, "Panel Hue");

			var _track_x = _L.panel.x + 16;
			var _track_y = _row_y + 20;
			var _track_w = _L.panel.w - 32;
			var _track_h = 10;

			// Full spectrum reference strip so the player can see where
			// on the wheel they currently sit, not just the resulting
			// panel color - drawn as a sequence of thin colored bars
			// across the full hue range.
			var _steps = 64;
			var _step_w = _track_w / _steps;
			for (var _i = 0; _i < _steps; _i++) {
				var _step_hue = (_i / _steps) * 255;
				var _col = make_color_hsv(_step_hue, 200, 220);
				draw_rectangle_color(
					_track_x + (_i * _step_w), _track_y,
					_track_x + ((_i + 1) * _step_w), _track_y + _track_h,
					_col, _col, _col, _col, false
				);
			}
			draw_rectangle_color(_track_x, _track_y, _track_x + _track_w, _track_y + _track_h, _border, _border, _border, _border, true);

			// Thumb position
			var _thumb_x = _track_x + (global.settings_panel_hue / 255) * _track_w;
			draw_line_width_color(_thumb_x, _track_y - 3, _thumb_x, _track_y + _track_h + 3, 3, c_white, c_white);

			draw_text(_track_x, _track_y + _track_h + 10, string(global.settings_panel_hue) + " / 255");

			draw_text(_L.panel.x + 16, _L.panel.y + _L.panel.h - 36, "Left/Right to adjust. Changes apply immediately.");
			draw_text(_L.panel.x + 16, _L.panel.y + _L.panel.h - 20, "Press X to go back.");
		}
	};

	return _page;
}
