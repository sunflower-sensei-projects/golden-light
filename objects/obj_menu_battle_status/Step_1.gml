// Check to make sure you are actually in a battle
if global.player_battle == false {
	instance_destroy(self);
}