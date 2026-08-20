// ============================================================
// Create Event
// ============================================================

// List of effects to cycle through. Add new obj_fx_* here as you build them.
fx_list = [
	{
		name: "Quake",
		obj: asset_get_index("obj_bfx_quake")
	},
	{
		name: "Ignite",
		obj: asset_get_index("obj_bfx_ignite")
	},
	{
		name: "Spark",
		obj: asset_get_index("obj_bfx_spark")
	}
];

selected = 0;

// where the effect will be cast — draggable via Left/Right, Up/Down while holding Shift
marker_x = room_width / 2;
marker_y = room_height * 0.62;

// simple input debounce so holding a key doesn't spam-fire
input_delay = 0;

// last cast effect instance, so we can check if it's still alive / clear it manually
active_fx = noone;

// visual style
menu_x = 16;
menu_y = 16;
row_height = 16;