if (on_players_level()) {
	depth = (Player.y < y) ? Player.depth - 1 : Player.depth + 1	
} else {
	depth = layer_get_depth(self.layer);
}