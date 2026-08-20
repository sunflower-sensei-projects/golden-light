/// scr_menu_layout()
/// Single source of truth for panel sizes/positions across all menu
/// pages, in GUI space (top-left origin). Previously these numbers
/// were recomputed inline throughout each object's draw event
/// (e.g. "height[0]+op_border+3+32+56"), which is why layout changes
/// used to require hunting through logic code. Change a value here
/// and every page that reads it updates together.
///
/// GUI size is read live via display_get_gui_width/height rather than
/// hardcoded - this project's GUI size has changed twice already
/// (an obj_game_controller override was setting it, then got
/// removed), and a fixed number here silently goes stale the next
/// time it changes. This recomputes every call rather than caching,
/// so a window resize or fullscreen toggle mid-game won't leave menu
/// panels positioned for a stale size. If this ever shows up as a
/// performance concern (it shouldn't - it's a handful of struct
/// allocations per draw), reintroduce caching keyed on the actual
/// gui_w/gui_h rather than a one-shot static.
function scr_menu_layout() {
	var _gui_w = display_get_gui_width();
	var _gui_h = display_get_gui_height();
	var _border = 5;
	var _space = 2;

	var _L = {
		gui_w: _gui_w,
		gui_h: _gui_h,
		border: _border,
		space: _space,

		// Bottom bar: general menu options (obj_menu_general replacement).
		// Actual position/size is computed in scr_menu_page_general's
		// draw_gui directly from gui_w/gui_h (icon row + label box are
		// centered together as one unit) - this entry is kept only for
		// row_h in case other code wants the bar's height.
		general: {
			row_h: 32
		},

		// Small party status strip shown alongside the general menu.
		// bar_w is wide/prominent per design review - spans most of the
		// cell width rather than the original small 20px segment.
		status_sm: {
			x: _gui_w - 96, y: 0,
			cell_w: 96, cell_h: 60,
			bar_w: 72
		},

		// Items menu panel layout (mirrors original width[]/height[]
		// arrays, rescaled to the real GUI canvas so the question/
		// inventory/tooltip/coins column fills the full width instead
		// of leaving dead space).
		items: {
			char_panel:   { x: 0, y: 0, w: 138, h: 48 },
			status_panel: { x: 0, y: 48, w: 138, h: _gui_h - 48 - 32 },
			question:     { x: 138, y: 0, w: _gui_w - 138, h: 32 },
			inventory:    { x: 138, y: 32, w: _gui_w - 138, h: 128 },
			tooltip:      { x: 138, y: _gui_h - 32 - 48, w: _gui_w - 138, h: 48 },
			coins:        { x: 0, y: _gui_h - 32, w: _gui_w, h: 32 },
			grid_cols: 5,
			grid_rows: 3,
			cell: 32,
			option_cols: 3
		},

		// Sorcery menu shares the Items panel shape (character list +
		// status + spell grid), so it reuses `items` geometry directly.

		// Full status screen (all party members, full stat sheet)
		status_full: {
			portrait: { x: 8, y: 8, w: _gui_w - 16, h: 48 },
			detail:   { x: 8, y: 64, w: _gui_w - 16, h: _gui_h - 64 - 8 }
		},

		// Party reorder screen
		party: {
			slot: { x: 20, y: 40, w: 64, h: 64, gap: 8 },
			cols: 5
		},

		// Settings stub
		settings: {
			panel: { x: 40, y: 30, w: _gui_w - 80, h: _gui_h - 60 }
		}
	};

	return _L;
}
