// obj_camera — Create Event
follow_target = noone;
cam_x         = 0;
cam_y         = 0;
smoothing     = 0.18;
deadzone_w    = 48;
deadzone_h    = 32;

enum eCamMode {
    FOLLOW,   // standard lerped follow with deadzone (overworld, large dungeons)
    FIXED,    // camera locked to room center (small interior cells)
    SNAP,     // instant follow, no lerp (cutscenes, battle)
}

cam_mode = eCamMode.FOLLOW; // default