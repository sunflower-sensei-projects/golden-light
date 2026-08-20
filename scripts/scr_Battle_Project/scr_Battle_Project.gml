function scr_Battle_Project(_fx, _fz) {
	var _mgr = obj_battle_controller;
	var _angle = _mgr.battle_angle; // Current floor rotation in degrees
	var _tilt = _mgr.floor_tilt; // Vertical squash (isometric feel, e.g. 0.5)
	var _scale = _mgr.floor_scale; // World unit to pixel scale
	var _cx = _mgr.battle_center_x; // The X-coordinate of the center of the battle
	var _cy = _mgr.battle_center_y; // The Y-coordinate of the center of the battle
	
	// Rotate floor x and floor z around the Y-axis
	var _rad = degtorad(_angle);
	var _rx = _fx * cos(_rad) - _fz * sin(_rad);
	var _rz = _fx * sin(_rad) + _fz * cos(_rad);
	
	// Project to screen: X is direct, Z becomes the screen Y (suqshed by the tilt)
	var _sx = _cx + _rx * _scale;
	var _sy = _cy + _rz * _scale * _tilt;
	
	// Depth: further from the camera = lower depth
	var _depth = -_rz;
	
	return { x: _sx, y: _sy, depth: _depth };
}