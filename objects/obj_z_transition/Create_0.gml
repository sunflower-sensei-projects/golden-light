// obj_z_transition — Create Event
target_z   = 0;    // set per instance in room editor
direction  = 0;    // which facing direction triggers this (optional)

// Check to see what collision layer you're on
cur_layer = layer_get_name(layer);