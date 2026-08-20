function scr_Player_Depth_Sort(_inst){
	var _layer = _inst.layer;
	_inst.depth = _layer.depth;
}

function scr_Get_Pushable_Depth_Offset() {
	if (!instance_exists(Player)) return 0; // safety fallback
	var _relative = z_level - Player.z_level;
	return _relative * -DEPTH_Z_STEP;
}