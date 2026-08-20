function scr_Macros() {
	// Set Player Speeds
	#macro SPEED_WALK     1.2
	#macro SPEED_RUN      2.4
	#macro SPEED_PUSH     0.8
	#macro SPEED_STAIR    0.8
	#macro SPEED_CLIMB    0.8
	#macro SLOPE_ACCEL    0.15
	#macro SLOPE_MAX      3.5

	// Set Player Input Keys
	#macro KEY_RUN        ord("X")
	#macro KEY_INTERACT   ord("Z")
	#macro KEY_MENU       ord("C")
	
	// Set Animation Strip Direction Indices
	#macro DIR_DOWN       0
	#macro DIR_DOWN_RIGHT 1
	#macro DIR_RIGHT      2
	#macro DIR_UP_RIGHT   3
	#macro DIR_UP         4
	#macro DIR_UP_LEFT    5
	#macro DIR_LEFT       6
	#macro DIR_DOWN_LEFT  7

	// Terrain Tile Tags
	#macro TILE_SIZE          32
	#macro TAG_STAIR_UP       obj_terrain_stair_up
	#macro TAG_STAIR_DN       obj_terrain_stair_down
	#macro TAG_CLIMBABLE      obj_terrain_ladder
	#macro TAG_SLOPE          obj_terrain_slope
	#macro TAG_PUSHABLE       obj_pushable
	#macro TAG_INTERACT       obj_interact
	#macro TAG_GAP            obj_terrain_gap
	#macro TAG_LANDING        obj_terrain_landing
	#macro TAG_CLIFF_EDGE     obj_terrain_cliff_edge
	#macro TAG_CLIFF_BOTTOM   obj_terrain_cliff_bottom
	#macro TAG_STAIR_DIAGONAL obj_terrain_stair_diagonal_test
	
	// Z-Level Depth Macros
	#macro DEPTH_Z_STEP  2000                 // How much depth separates each Z-level
	#macro DEPTH_FLOOR   (DEPTH_Z_STEP / 2)   // The base depth for the floor the player is walking on
	#macro DEPTH_OBJECTS 0                    // The base depth for the instance layer
	#macro DEPTH_CEILING -(DEPTH_Z_STEP / 2)  // The base depth for the ceiling tiles above the player
	
	// Jumping
	#macro GAP_HOLD_FRAMES  20
	#macro JUMP_FRAMES      20
	#macro JUMP_SPEED       (1 / JUMP_FRAMES)
	
	// Slope / Fall
	#macro SLOPE_SLIP_DELAY      8    // Number of frames before the acual slip begins
	#macro FALL_GRAVITY          0.45 // Accelleration per frame while falling
	#macro FALL_MAX              9.0  // Terminal veliocty
	#macro FALL_LAND_FRAMES      12   // Landing recovery frames after hitting the ground
	#macro FALL_HURT_VEL         6.0  // How fast the player needs to fall to trigger the hard landing anim
	#macro PUSH_FALL_FRAMES      18   // How long a falling objects takes to fall one Z-level
	#macro PUSH_FALL_LAND_FRAMES 8    // Brief landing pause before the fall is over, used to show debris/dust kick-up
	
	// Stairs
	#macro FALL_STAIR_VEL_PER_PROGRESS 6
	#macro FALL_STEER_STRENGTH  0.15
	#macro FALL_STEER_MAX_VEL   3
}