function on_players_level() {
	// Checks to see if the calling object is on the same layer as the Player
	// Returns true if it is
	return z_level == Player.z_level;
}