function scr_update_z_layers(_player_z) {
    var _z_max = global.max_z_level;

    for (var _z = 0; _z <= _z_max; _z++) {
        var _relative = _z - _player_z;
        // _relative < 0 = below player, = 0 = same level, > 0 = above player

        // Floor layer — always behind objects on same level
        var _floor_layer = "Z" + string(_z) + "_Tiles";
        if (layer_exists(_floor_layer)) {
            layer_depth(_floor_layer,
                _relative * -DEPTH_Z_STEP + DEPTH_FLOOR);
        }

        // Objects layer
        var _obj_layer = "Z" + string(_z) + "_Instances";
        if (layer_exists(_obj_layer)) {
            if (_relative <= 0) {
                // Same level or below — renders behind player
                layer_depth(_obj_layer,
                    _relative * -DEPTH_Z_STEP + DEPTH_OBJECTS);
            } else {
                // Above player — renders in front
                layer_depth(_obj_layer,
                    _relative * -DEPTH_Z_STEP + DEPTH_CEILING);
            }
        }

        // Ceiling layer — always in front when above player
        var _ceil_layer = "Z" + string(_z) + "_Ceiling";
        if (layer_exists(_ceil_layer)) {
            if (_relative <= 0) {
                // Below or same — hide ceiling (player has climbed above it)
                layer_depth(_ceil_layer, 9999);
            } else {
                // Above player — show ceiling in front
                layer_depth(_ceil_layer,
                    _relative * -DEPTH_Z_STEP + DEPTH_CEILING - 10);
            }
        }
    }
}