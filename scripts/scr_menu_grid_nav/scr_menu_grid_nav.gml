/// scr_menu_grid_nav(index, count, cols, dir_right, dir_left, dir_up, dir_down)
///
/// Generic wrapping grid-cursor navigation. Replaces the copy-pasted
/// _x_pos / _y_pos tracking that used to be hand-written per menu level
/// in obj_menu_items (character select, item grid, option grid all did
/// their own version of this).
///
/// Params:
///   index      - current selected index (0-based, into a flat list)
///   count      - total number of selectable entries
///   cols       - number of columns in the grid (use `count` for a 1-row menu)
///   dir_right/left/up/down - booleans, this frame's input
///
/// Returns a struct:
///   { index, col, row, row_count, moved }
///
/// Notes:
///   - Left/Right move by 1 and wrap across row/column boundaries.
///   - Up/Down move by `cols` and wrap top<->bottom on the same column,
///     clamping to the last valid index in a short final row.
///   - Does not know about pixel positions at all. Callers turn
///     {col, row} into on-screen coordinates using their own panel
///     origin + cell size, or via scr_menu_cell_to_xy below.
function scr_menu_grid_nav(_index, _count, _cols, _right, _left, _up, _down) {
	var _idx = _index;
	var _moved = false;

	if (_count <= 0) {
		return { index: 0, col: 0, row: 0, row_count: 0, moved: false };
	}

	_cols = max(1, _cols);
	var _row_count = ceil(_count / _cols);

	if (_right) {
		_idx += 1;
		if (_idx >= _count) { _idx = 0; }
		_moved = true;
	}
	else if (_left) {
		_idx -= 1;
		if (_idx < 0) { _idx = _count - 1; }
		_moved = true;
	}
	else if (_down) {
		var _next = _idx + _cols;
		if (_next >= _count) {
			// Wrap to same column, row 0 (clamped if that column doesn't
			// exist in row 0 for a ragged final row - falls back to last col)
			_next = _idx mod _cols;
			if (_next >= _count) { _next = _count - 1; }
		}
		_idx = _next;
		_moved = true;
	}
	else if (_up) {
		var _next = _idx - _cols;
		if (_next < 0) {
			// Wrap to the last row, same column; clamp if ragged
			var _col = _idx mod _cols;
			var _last_row_start = (_row_count - 1) * _cols;
			_next = _last_row_start + _col;
			if (_next >= _count) { _next -= _cols; }
		}
		_idx = _next;
		_moved = true;
	}

	var _col = _idx mod _cols;
	var _row = _idx div _cols;

	return { index: _idx, col: _col, row: _row, row_count: _row_count, moved: _moved };
}

/// scr_menu_cell_to_xy(origin_x, origin_y, col, row, cell_w, cell_h)
/// Small helper to turn a grid cell into a pixel position, so panel
/// layout stays in one readable call instead of inline arithmetic
/// scattered through draw code.
function scr_menu_cell_to_xy(_ox, _oy, _col, _row, _cw, _ch) {
	return { x: _ox + (_col * _cw), y: _oy + (_row * _ch) };
}
