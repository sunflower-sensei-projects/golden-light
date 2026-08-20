_cardinal_dir = round(Player.dir / 90) * 90;
if (_cardinal_dir >= 360) _cardinal_dir -= 360; // 315-360 range rounds up to 360, wrap back to 0

_gap_x  = Player.x + lengthdir_x(1, _cardinal_dir);
_gap_y  = Player.y + lengthdir_y(1, _cardinal_dir);
_land_x = Player.x + lengthdir_x(TILE_SIZE, _cardinal_dir);
_land_y = Player.y + lengthdir_y(TILE_SIZE, _cardinal_dir);