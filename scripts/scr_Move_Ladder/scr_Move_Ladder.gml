function scr_Move_Ladder(){
	// Snap x to center of ladder tile while climbing
	var _ladder_inst = scr_Get_Terrain_Instance(TAG_LADDER);
	if (instance_exists(_ladder_inst)) {
		// Gently snap to ladder center x
		x = lerp(x, _ladder_inst.bbox_left + (_ladder_inst.bbox_right - _ladder_inst.bbox_left) / 2, 0.25);
	}
	
	// Only vertical movement allowed
	y += input_y * SPEED_LADDER;
	
	// Optionally, add gentle sway to vines
	// x += sin(current_time * 0.003) * 0.3;
}