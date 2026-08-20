// obj_z_transition — Step Event
if (place_meeting(x, y, Player)) {
    if (Player.z_level != target_z) {
        Player.z_level = target_z;
        scr_update_z_layers(target_z);
    }
}